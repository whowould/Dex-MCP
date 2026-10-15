-- 61_remotes: remote spy (outgoing FireServer/InvokeServer, incoming OnClientEvent), block/ignore, replay, handler mapping
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local E = B.Events
local NC = B.NC
local NULL = B.NULL
local typeof = typeof or type
local gm = game

local REMOTE_OUT = { RemoteEvent = "FireServer", UnreliableRemoteEvent = "FireServer", RemoteFunction = "InvokeServer" }
local BINDABLE_OUT = { BindableEvent = "Fire", BindableFunction = "Invoke" }

local RS = {
	active = false,
	opts = {},
	ncIds = {},
	fnHooks = {},
	inNC = setmetatable({}, { __mode = "k" }),
	stats = setmetatable({}, { __mode = "k" }),
	ignored = setmetatable({}, { __mode = "k" }),
	ignoreNames = {},
	blocked = setmetatable({}, { __mode = "k" }),
	pathCache = setmetatable({}, { __mode = "k" }),
	raw = {},
	rawOrder = {},
	incomingConns = {},
	total = 0,
}
B.RS = RS

local function remotePath(r)
	local p = RS.pathCache[r]
	if p then return p end
	local ok, s = pcall(B.pathOf, r)
	p = ok and s or tostring(r)
	RS.pathCache[r] = p
	return p
end

local function sigOf(pk)
	local t = {}
	for i = 1, pk.n do
		local ty = typeof(pk[i])
		if ty == "table" then
			local n = 0
			for _ in next, pk[i] do n = n + 1 if n > 50 then break end end
			ty = "table(" .. n .. ")"
		end
		t[i] = ty
	end
	return table.concat(t, ",")
end

local function isIgnored(r)
	if RS.ignored[r] then return true end
	if #RS.ignoreNames > 0 then
		local nm = r.Name
		for _, m in ipairs(RS.ignoreNames) do if m(nm) then return true end end
	end
	return false
end

local function rememberRaw(seq, entry)
	RS.raw[seq] = entry
	RS.rawOrder[#RS.rawOrder + 1] = seq
	local cap = RS.opts.raw_cap or 500
	while #RS.rawOrder > cap do
		local old = table.remove(RS.rawOrder, 1)
		RS.raw[old] = nil
	end
end

local function logCall(remote, method, dir, args, results, err, elapsed, blocked)
	RS.total = RS.total + 1
	local st = RS.stats[remote]
	if not st then
		st = { count = 0, first = B.now(), sigs = {}, class = remote.ClassName, path = remotePath(remote), logged = 0 }
		RS.stats[remote] = st
	end
	st.count = st.count + 1
	st.last = B.now()
	local sig = sigOf(args)
	st.sigs[sig] = (st.sigs[sig] or 0) + 1
	if blocked then st.blocked = (st.blocked or 0) + 1 end

	local perRemote = RS.opts.max_per_remote or 2000
	if st.logged >= perRemote then return end
	local every = RS.opts.sample_every or 1
	if every > 1 and st.count % every ~= 1 then return end
	st.logged = st.logged + 1

	local ev = {
		key = st.path .. " " .. method,
		remote = st.path,
		remote_ref = B.ref(remote),
		class = st.class,
		method = method,
		dir = dir,
		args = B.serPack(args, RS.opts.ser or { depth = 3, maxItems = 30, maxStr = 1500 }),
		arg_count = args.n,
	}
	if results then ev.results = B.serPack(results, RS.opts.ser or { depth = 3, maxItems = 30, maxStr = 1500 }) end
	if err then ev.error = tostring(err) end
	if elapsed then ev.elapsed = elapsed end
	if blocked then ev.blocked = true end
	if dir == "out" then
		if RS.opts.capture_script ~= false then ev.script = B.callerScript() end
		if RS.opts.capture_stack then ev.stack = B.trace(2500) end
		if C.checkcaller and RS.opts.include_executor then
			local ok, r = pcall(C.checkcaller)
			ev.from_executor = ok and r or nil
		end
	end
	local seq = E.push("remote", ev)
	rememberRaw(seq, { remote = remote, method = method, args = args, dir = dir })
	return seq
end

local function shouldHandle(self)
	if not RS.active then return false end
	if typeof(self) ~= "Instance" then return false end
	if isIgnored(self) then return false end
	if not RS.opts.include_executor and B.isExecCaller() then return false end
	return true
end

local function outHandler(method, classMap)
	return function(nextf, self, ...)
		local cls
		if RS.active and typeof(self) == "Instance" then cls = self.ClassName end
		if not cls or classMap[cls] ~= method or not shouldHandle(self) then return nextf(self, ...) end
		local th = coroutine.running()
		RS.inNC[th] = true
		local args = B.pack(...)
		local blk = RS.blocked[self]
		if blk then
			pcall(logCall, self, method, "out", args, nil, nil, nil, true)
			RS.inNC[th] = nil
			if blk.mode == "return" then return B.unpack(blk.values) end
			return
		end
		if method == "InvokeServer" or method == "Invoke" then
			local t0 = os.clock()
			local res = B.pack(pcall(nextf, self, ...))
			RS.inNC[th] = nil
			if res[1] then
				local r = { n = res.n - 1 }
				for i = 2, res.n do r[i - 1] = res[i] end
				pcall(logCall, self, method, "out", args, r, nil, os.clock() - t0)
				return B.unpack(r)
			end
			pcall(logCall, self, method, "out", args, nil, res[2], os.clock() - t0)
			error(res[2], 0)
		end
		pcall(logCall, self, method, "out", args)
		-- keep the dedupe flag set while the original runs: it may route through the function-level hook
		local res = B.pack(pcall(nextf, self, ...))
		RS.inNC[th] = nil
		if not res[1] then error(res[2], 0) end
		return unpack(res, 2, res.n)
	end
end

local function connectIncoming(remote)
	local cn = remote.ClassName
	if cn ~= "RemoteEvent" and cn ~= "UnreliableRemoteEvent" then return end
	if RS.incomingConns[remote] then return end
	local handler = function(...)
		if not RS.active or isIgnored(remote) then return end
		pcall(logCall, remote, "OnClientEvent", "in", B.pack(...))
	end
	B.ownFns[handler] = true
	local ok, conn = pcall(function() return remote.OnClientEvent:Connect(handler) end)
	if ok then RS.incomingConns[remote] = conn end
end

H.remote_spy_start = function(p)
	if RS.active then
		-- allow reconfiguration
		for k, v in pairs(p) do RS.opts[k] = v end
		return { active = true, reconfigured = true }
	end
	RS.opts = {
		include_executor = p.include_executor,
		capture_stack = p.capture_stack,
		capture_script = p.capture_script,
		max_per_remote = p.max_per_remote,
		sample_every = p.sample_every,
		raw_cap = p.raw_cap,
		ser = p.depth and { depth = p.depth, maxItems = p.max_items or 30, maxStr = p.max_str or 1500 } or nil,
	}
	RS.active = true
	local started = {}

	RS.ncIds[#RS.ncIds + 1] = NC.add("FireServer", outHandler("FireServer", REMOTE_OUT), "remotespy")
	RS.ncIds[#RS.ncIds + 1] = NC.add("InvokeServer", outHandler("InvokeServer", REMOTE_OUT), "remotespy")
	started[#started + 1] = "namecall:FireServer/InvokeServer"
	if p.bindables then
		RS.ncIds[#RS.ncIds + 1] = NC.add("Fire", outHandler("Fire", BINDABLE_OUT), "remotespy")
		RS.ncIds[#RS.ncIds + 1] = NC.add("Invoke", outHandler("Invoke", BINDABLE_OUT), "remotespy")
		started[#started + 1] = "namecall:Fire/Invoke(bindables)"
	end

	-- direct calls: remote.FireServer(remote, ...) bypasses __namecall
	if p.hook_functions ~= false and C.hookfunction then
		local function hookMethod(className, method)
			local ok, err = pcall(function()
				local inst = Instance.new(className)
				local fn = inst[method]
				local orig
				local function replacement(self, ...)
					if RS.active and not RS.inNC[coroutine.running()] and typeof(self) == "Instance" and REMOTE_OUT[self.ClassName] == method and shouldHandle(self) then
						local args = B.pack(...)
						local blk = RS.blocked[self]
						if blk then
							pcall(logCall, self, method, "out", args, nil, nil, nil, true)
							if blk.mode == "return" then return B.unpack(blk.values) end
							return
						end
						if method == "InvokeServer" then
							local t0 = os.clock()
							local res = B.pack(pcall(orig, self, ...))
							if res[1] then
								local r = { n = res.n - 1 }
								for i = 2, res.n do r[i - 1] = res[i] end
								pcall(logCall, self, method, "out", args, r, nil, os.clock() - t0)
								return B.unpack(r)
							end
							pcall(logCall, self, method, "out", args, nil, res[2], os.clock() - t0)
							error(res[2], 0)
						end
						pcall(logCall, self, method, "out", args)
					end
					return orig(self, ...)
				end
				orig = C.hookfunction(fn, C.newcclosure and C.newcclosure(replacement) or replacement)
				RS.fnHooks[#RS.fnHooks + 1] = { fn = fn, orig = orig }
				pcall(inst.Destroy, inst)
			end)
			if ok then started[#started + 1] = "function:" .. className .. "." .. method end
		end
		hookMethod("RemoteEvent", "FireServer")
		hookMethod("RemoteFunction", "InvokeServer")
		hookMethod("UnreliableRemoteEvent", "FireServer")
	end

	if p.incoming ~= false then
		local n = 0
		for _, d in ipairs(gm:GetDescendants()) do
			if d.ClassName == "RemoteEvent" or d.ClassName == "UnreliableRemoteEvent" then connectIncoming(d) n = n + 1 end
		end
		if C.getnilinstances then
			for _, d in ipairs(C.getnilinstances()) do
				if d.ClassName == "RemoteEvent" or d.ClassName == "UnreliableRemoteEvent" then connectIncoming(d) n = n + 1 end
			end
		end
		RS.descConn = gm.DescendantAdded:Connect(function(d)
			if RS.active then connectIncoming(d) end
		end)
		started[#started + 1] = "incoming:" .. n .. " RemoteEvents"
	end
	return { active = true, hooked = started }
end

H.remote_spy_stop = function(p)
	RS.active = false
	for _, id in ipairs(RS.ncIds) do NC.remove(id) end
	RS.ncIds = {}
	for _, h in ipairs(RS.fnHooks) do
		local ok = false
		if C.restorefunction then ok = pcall(C.restorefunction, h.fn) end
		if not ok and C.hookfunction then pcall(C.hookfunction, h.fn, h.orig) end
	end
	RS.fnHooks = {}
	for r, c in pairs(RS.incomingConns) do pcall(function() c:Disconnect() end) end
	RS.incomingConns = {}
	if RS.descConn then RS.descConn:Disconnect() RS.descConn = nil end
	return { active = false, total_calls_seen = RS.total }
end

H.remote_spy_status = function(p)
	local remotes = 0
	for _ in pairs(RS.stats) do remotes = remotes + 1 end
	return {
		active = RS.active,
		total_calls_seen = RS.total,
		distinct_remotes = remotes,
		buffered = E.size("remote"),
		ignored = B.count(RS.ignored) + #RS.ignoreNames,
		blocked = B.count(RS.blocked),
		hooks = { namecall = #RS.ncIds, functions = #RS.fnHooks },
		options = RS.opts,
	}
end

H.remote_spy_clear = function(p)
	local n = E.clear("remote")
	if p.reset_stats then
		RS.stats = setmetatable({}, { __mode = "k" })
		RS.total = 0
	end
	RS.raw, RS.rawOrder = {}, {}
	return { cleared = n }
end

H.remote_spy_get = function(p)
	local keyM = p.remote and B.matcher(p.remote, p.remote_mode, true) or nil
	local methodM = p.method and B.matcher(p.method, "exact", false) or nil
	local scriptM = p.script and B.matcher(p.script, "plain", true) or nil
	local argsM = p.args_match and B.matcher(p.args_match, "plain", true) or nil
	local pred = function(ev)
		if p.direction and ev.dir ~= p.direction then return false end
		if keyM and not keyM(ev.remote or "") then return false end
		if methodM and not methodM(ev.method or "") then return false end
		if scriptM and not scriptM(ev.script or "") then return false end
		if p.errors_only and not ev.error then return false end
		if argsM and not argsM(B.json(ev.args)) then return false end
		return true
	end
	local tailMode = p.since == nil or p.tail == true
	local evs, matched, lastSeq = E.query("remote", p.since, pred, p.limit or 50, tailMode)
	return { events = evs, returned = #evs, matched = matched, last_seq = lastSeq, active = RS.active }
end

H.remote_call_detail = function(p)
	local raw = RS.raw[p.seq]
	if not raw then error("call #" .. tostring(p.seq) .. " is no longer buffered (raw buffer holds the most recent " .. (RS.opts.raw_cap or 500) .. " calls)", 0) end
	return {
		seq = p.seq,
		remote = B.ser(raw.remote),
		method = raw.method,
		dir = raw.dir,
		args = B.serPack(raw.args, { depth = p.depth or 6, maxItems = p.max_items or 200, maxStr = p.max_str or 10000 }),
	}
end

H.remote_spy_summary = function(p)
	local rows = {}
	for r, st in pairs(RS.stats) do
		local sigs = {}
		for s, n in pairs(st.sigs) do sigs[#sigs + 1] = { signature = s, count = n } end
		table.sort(sigs, function(a, b) return a.count > b.count end)
		local top = {}
		for i = 1, math.min(#sigs, p.max_signatures or 4) do top[i] = sigs[i] end
		local span = (st.last or st.first) - st.first
		rows[#rows + 1] = {
			remote = st.path,
			ref = B.ref(r),
			class = st.class,
			calls = st.count,
			per_second = span > 0 and (st.count / span) or nil,
			blocked_calls = st.blocked,
			ignored = RS.ignored[r] or nil,
			signatures = top,
		}
	end
	table.sort(rows, function(a, b) return a.calls > b.calls end)
	local limit = p.limit or 50
	local out = {}
	for i = 1, math.min(#rows, limit) do out[i] = rows[i] end
	return { total_remotes = #rows, remotes = out, total_calls = RS.total, active = RS.active }
end

local function remotesFrom(p)
	local list = {}
	if p.remotes then
		for _, spec in ipairs(p.remotes) do list[#list + 1] = B.inst(spec) end
	elseif p.target then
		list[1] = B.inst(p.target)
	end
	return list
end

H.remote_ignore = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do RS.ignored[r] = true n = n + 1 end
	if p.name then
		RS.ignoreNames[#RS.ignoreNames + 1] = B.matcher(p.name, p.name_mode, true)
		n = n + 1
	end
	return { ignored = n }
end

H.remote_unignore = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do if RS.ignored[r] then RS.ignored[r] = nil n = n + 1 end end
	if p.all then
		RS.ignoreNames = {}
		RS.ignored = setmetatable({}, { __mode = "k" })
	end
	return { removed = n }
end

H.remote_block = function(p)
	local n = 0
	local values
	if p.return_values then values = B.deArgs(p.return_values) end
	for _, r in ipairs(remotesFrom(p)) do
		RS.blocked[r] = { mode = values and "return" or "block", values = values }
		n = n + 1
	end
	if not RS.active then
		-- blocking needs the hooks; start a quiet spy that only enforces blocks
		H.remote_spy_start({ incoming = false, max_per_remote = 0 })
	end
	return { blocked = n, spy_active = RS.active }
end

H.remote_unblock = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do if RS.blocked[r] then RS.blocked[r] = nil n = n + 1 end end
	if p.all then RS.blocked = setmetatable({}, { __mode = "k" }) end
	return { unblocked = n }
end

H.list_remotes = function(p)
	local classes = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }
	if p.bindables then classes.BindableEvent = true classes.BindableFunction = true end
	local nameM = B.matcher(p.name, p.name_mode, true)
	local root = B.inst(p.root or "game")
	local out = {}
	local function consider(d)
		if classes[d.ClassName] and nameM(d.Name) then
			local st = RS.stats[d]
			local e = {
				ref = B.ref(d),
				class = d.ClassName,
				name = d.Name,
				path = remotePath(d),
				calls = st and st.count or 0,
				blocked = RS.blocked[d] and true or nil,
				ignored = RS.ignored[d] and true or nil,
			}
			if p.with_handlers and C.getconnections and d.ClassName == "RemoteEvent" then
				local ok, conns = pcall(C.getconnections, d.OnClientEvent)
				if ok then
					local n = 0
					for _, c in ipairs(conns) do
						local okf, fn = pcall(function() return c.Function end)
						if not (okf and B.ownFns[fn]) then n = n + 1 end
					end
					e.client_handlers = n
				end
			end
			out[#out + 1] = e
		end
	end
	for i, d in ipairs(root:GetDescendants()) do
		consider(d)
		if i % 4000 == 0 then B.yield() end
	end
	if p.include_nil ~= false and C.getnilinstances then
		for _, d in ipairs(C.getnilinstances()) do consider(d) end
	end
	table.sort(out, function(a, b) return a.path < b.path end)
	local limit = p.limit or 300
	local trimmed = {}
	for i = 1, math.min(#out, limit) do trimmed[i] = out[i] end
	return { total = #out, returned = #trimmed, remotes = trimmed }
end

-- who handles this remote on the client?
H.get_remote_handlers = function(p)
	local r = B.inst(p.target)
	local out = { remote = B.ser(r), handlers = {} }
	local function addFn(fn, extra)
		local info = B.funcInfo(fn)
		local e = { ref = B.ref(fn), name = info.name, line = info.line, source = info.short_src or info.source, numparams = info.numparams, nups = info.nups }
		local ok, fe = pcall(getfenv, fn)
		if ok and type(fe) == "table" then
			local s = rawget(fe, "script")
			if typeof(s) == "Instance" then e.script = B.instPath(s) end
		end
		for k, v in pairs(extra or {}) do e[k] = v end
		out.handlers[#out.handlers + 1] = e
	end
	if r.ClassName == "RemoteEvent" or r.ClassName == "UnreliableRemoteEvent" then
		local conns = B.need("getconnections")(r.OnClientEvent)
		for i, c in ipairs(conns) do
			local ok, fn = pcall(function() return c.Function end)
			if ok and type(fn) == "function" then
				if not B.ownFns[fn] then addFn(fn, { connection = B.ref(c), index = i, enabled = c.Enabled }) end
			else out.handlers[#out.handlers + 1] = { index = i, connection = B.ref(c), note = "no Lua function (C connection)" } end
		end
	elseif r.ClassName == "RemoteFunction" then
		local fn = B.need("getcallbackvalue")(r, "OnClientInvoke")
		if type(fn) == "function" then addFn(fn, { kind = "OnClientInvoke" }) end
	elseif r.ClassName == "BindableEvent" then
		local conns = B.need("getconnections")(r.Event)
		for i, c in ipairs(conns) do
			local ok, fn = pcall(function() return c.Function end)
			if ok and type(fn) == "function" then addFn(fn, { connection = B.ref(c), index = i }) end
		end
	else
		error("not a remote/bindable: " .. r.ClassName, 0)
	end
	out.count = #out.handlers
	return out
end

local function doCall(remote, method, args, timeout)
	local fn = remote[method]
	if method == "InvokeServer" or method == "Invoke" then
		local ok, res = B.timed(function() return B.pack(fn(remote, B.unpack(args))) end, timeout or 20)
		if not ok then error("invoke failed: " .. tostring(res), 0) end
		return res
	end
	fn(remote, B.unpack(args))
	return nil
end

local METHOD_FOR = { RemoteEvent = "FireServer", UnreliableRemoteEvent = "FireServer", RemoteFunction = "InvokeServer", BindableEvent = "Fire", BindableFunction = "Invoke" }

H.fire_remote = function(p)
	local r = B.inst(p.target)
	local method = METHOD_FOR[r.ClassName]
	if not method then error(r.ClassName .. " is not a remote/bindable", 0) end
	local args = B.deArgs(p.args)
	local times = p.times or 1
	local last
	for i = 1, times do
		last = doCall(r, method, args, p.timeout)
		if p.delay and i < times then task.wait(p.delay) end
	end
	return { ok = true, method = method, times = times, results = last and B.serPack(last, p) or nil }
end
H.invoke_remote = H.fire_remote

H.remote_replay = function(p)
	local raw = RS.raw[p.seq]
	if not raw then error("call #" .. tostring(p.seq) .. " not in raw buffer", 0) end
	local args = raw.args
	if p.args then args = B.deArgs(p.args) end
	if p.modify then
		-- {index:1-based, value:...} patches on top of the captured args
		local copy = { n = args.n }
		for i = 1, args.n do copy[i] = args[i] end
		for _, m in ipairs(p.modify) do
			copy[m.index] = B.de(m.value)
			if m.index > copy.n then copy.n = m.index end
		end
		args = copy
	end
	local times = p.times or 1
	local last
	for i = 1, times do
		last = doCall(raw.remote, raw.method, args, p.timeout)
		if p.delay and i < times then task.wait(p.delay) end
	end
	return { ok = true, remote = remotePath(raw.remote), method = raw.method, times = times, results = last and B.serPack(last, p) or nil }
end
