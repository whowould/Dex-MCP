-- 60_hooks: shared __namecall/__index/__newindex hook, traps, function hooks, watches, executor/http spy
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local E = B.Events
local NULL = B.NULL
local typeof = typeof or type
local gm = game

local function callerScript()
	if not C.getcallingscript then return nil end
	local ok, s = pcall(C.getcallingscript)
	if ok and typeof(s) == "Instance" then
		local ok2, p = pcall(B.pathOf, s)
		return ok2 and p or tostring(s)
	end
	return nil
end
B.callerScript = callerScript

local function trace(maxLen)
	if not C.traceback then return nil end
	local ok, t = pcall(C.traceback, "", 2)
	if ok and t then return B.trunc(t, maxLen or 1500) end
	return nil
end
B.trace = trace

local function isExecCaller()
	if not C.checkcaller then return false end
	local ok, r = pcall(C.checkcaller)
	return ok and r
end
B.isExecCaller = isExecCaller

----------------------------------------------------------------------------------------------------
-- shared __namecall hook with per-method handler chains
----------------------------------------------------------------------------------------------------
local NC = { handlers = {}, nextId = 1, composed = {}, installed = false }
B.NC = NC
local oldNamecall

local function rebuild(method)
	local list = NC.handlers[method]
	if not list or #list == 0 then
		NC.handlers[method] = nil
		NC.composed[method] = nil
		return
	end
	local snm = C.setnamecallmethod
	local nextf = function(self, ...)
		if snm then snm(method) end
		return oldNamecall(self, ...)
	end
	for i = #list, 1, -1 do
		local h, nf = list[i].fn, nextf
		nextf = function(self, ...) return h(nf, self, ...) end
	end
	NC.composed[method] = nextf
end

local function installNamecall()
	if NC.installed then return end
	local hmm = B.need("hookmetamethod")
	local gnm = B.need("getnamecallmethod")
	local nccl = C.newcclosure or function(f) return f end
	local composed = NC.composed
	oldNamecall = hmm(gm, "__namecall", nccl(function(self, ...)
		local f = composed[gnm()]
		if f then return f(self, ...) end
		return oldNamecall(self, ...)
	end))
	NC.installed = true
end

function NC.add(method, fn, owner)
	installNamecall()
	local id = NC.nextId
	NC.nextId = id + 1
	local list = NC.handlers[method]
	if not list then list = {} NC.handlers[method] = list end
	list[#list + 1] = { id = id, fn = fn, owner = owner }
	rebuild(method)
	return id
end

function NC.remove(id)
	for method, list in pairs(NC.handlers) do
		for i, h in ipairs(list) do
			if h.id == id then
				table.remove(list, i)
				rebuild(method)
				return true
			end
		end
	end
	return false
end

function NC.callOld(method, self, ...)
	if C.setnamecallmethod then C.setnamecallmethod(method) end
	return oldNamecall(self, ...)
end

----------------------------------------------------------------------------------------------------
-- __index / __newindex hooks (only installed on demand; keyed by member name for a cheap fast path)
----------------------------------------------------------------------------------------------------
local IX = { index = {}, newindex = {}, installed = {} }
local oldIndex, oldNewindex

local function installMeta(kind)
	if IX.installed[kind] then return end
	local hmm = B.need("hookmetamethod")
	local nccl = C.newcclosure or function(f) return f end
	local chk = C.checkcaller
	if kind == "index" then
		oldIndex = hmm(gm, "__index", nccl(function(self, key)
			local hs = IX.index[key]
			if hs and not (chk and chk()) then
				local result = oldIndex(self, key)
				for _, h in ipairs(hs) do
					local ok, over = pcall(h.fn, self, key, result)
					if ok and over ~= nil and over ~= NULL then return over[1] end
				end
				return result
			end
			return oldIndex(self, key)
		end))
	else
		oldNewindex = hmm(gm, "__newindex", nccl(function(self, key, value)
			local hs = IX.newindex[key]
			if hs and not (chk and chk()) then
				for _, h in ipairs(hs) do
					local ok, block = pcall(h.fn, self, key, value)
					if ok and block == true then return end
				end
			end
			return oldNewindex(self, key, value)
		end))
	end
	IX.installed[kind] = true
end

----------------------------------------------------------------------------------------------------
-- traps
----------------------------------------------------------------------------------------------------
local traps = {}
local nextTrap = 1
local busy = false

local function trapMatches(t, self)
	if typeof(self) ~= "Instance" then return false end
	if t.target and self ~= t.target then return false end
	if t.class and not self:IsA(t.class) then return false end
	if t.name_match and not t.name_match(self.Name) then return false end
	return true
end

local function trapLog(t, self, extra)
	t.count = t.count + 1
	if t.log == false then return end
	local ok, path = pcall(B.pathOf, self)
	local ev = {
		key = t.kind .. ":" .. t.member .. " " .. (ok and path or "?"),
		trap = t.id,
		kind = t.kind,
		member = t.member,
		instance = ok and path or tostring(self),
		class = self.ClassName,
	}
	for k, v in pairs(extra or {}) do ev[k] = v end
	if t.capture_script ~= false then ev.script = callerScript() end
	if t.capture_stack then ev.stack = trace(2000) end
	E.push("trap", ev)
end

H.trap_add = function(p)
	local kind = p.kind or "namecall"
	if kind ~= "namecall" and kind ~= "index" and kind ~= "newindex" then error("kind must be namecall|index|newindex", 0) end
	if not p.member then error("member is required (method name for namecall, property name for index/newindex)", 0) end
	local t = {
		id = nextTrap,
		kind = kind,
		member = p.member,
		class = p.class,
		target = p.target and B.inst(p.target) or nil,
		name_match = p.name and B.matcher(p.name, p.name_mode, true) or nil,
		action = p.action or "log",
		value = p.value,
		log = p.log,
		capture_stack = p.capture_stack,
		capture_script = p.capture_script,
		log_args = p.log_args ~= false,
		count = 0,
		include_executor = p.include_executor,
	}
	nextTrap = nextTrap + 1
	if t.action == "return" or t.action == "set" then t.valueDecoded = B.de(p.value) end
	if p.code then
		local fn, err = B.need("loadstring")(p.code, "=trap")
		if not fn then error("compile error: " .. tostring(err), 0) end
		t.fn = fn()
	end

	if kind == "namecall" then
		t.hid = NC.add(p.member, function(nextf, self, ...)
			if busy or not trapMatches(t, self) or (not t.include_executor and isExecCaller()) then return nextf(self, ...) end
			busy = true
			local args = B.pack(...)
			local extra = {}
			if t.log_args then extra.args = B.serPack(args, { depth = 2, maxItems = 20, maxStr = 400 }) end
			local okLog = pcall(trapLog, t, self, extra)
			busy = false
			if t.action == "block" then return end
			if t.action == "return" then return t.valueDecoded end
			if t.action == "lua" and t.fn then return t.fn(nextf, self, ...) end
			return nextf(self, ...)
		end, "trap" .. t.id)
	elseif kind == "index" then
		installMeta("index")
		local list = IX.index[p.member] or {}
		IX.index[p.member] = list
		t.hentry = { fn = function(self, key, result)
			if busy or not trapMatches(t, self) then return nil end
			busy = true
			pcall(trapLog, t, self, { value = B.ser(result, { depth = 1, maxItems = 8, maxStr = 200 }) })
			busy = false
			if t.action == "return" then return { t.valueDecoded } end
			return nil
		end }
		list[#list + 1] = t.hentry
	else
		installMeta("newindex")
		local list = IX.newindex[p.member] or {}
		IX.newindex[p.member] = list
		t.hentry = { fn = function(self, key, value)
			if busy or not trapMatches(t, self) then return false end
			busy = true
			pcall(trapLog, t, self, { new_value = B.ser(value, { depth = 1, maxItems = 8, maxStr = 200 }) })
			busy = false
			return t.action == "block"
		end }
		list[#list + 1] = t.hentry
	end
	traps[t.id] = t
	return { trap = t.id, kind = kind, member = t.member, action = t.action }
end

H.trap_remove = function(p)
	local t = traps[p.id]
	if not t then error("no trap #" .. tostring(p.id), 0) end
	if t.hid then NC.remove(t.hid) end
	if t.hentry then
		local list = (t.kind == "index" and IX.index or IX.newindex)[t.member]
		if list then
			for i, h in ipairs(list) do
				if h == t.hentry then table.remove(list, i) break end
			end
			if #list == 0 then (t.kind == "index" and IX.index or IX.newindex)[t.member] = nil end
		end
	end
	traps[t.id] = nil
	return { removed = t.id, hits = t.count }
end

H.trap_list = function(p)
	local out = {}
	for id, t in pairs(traps) do
		out[#out + 1] = {
			id = id, kind = t.kind, member = t.member, action = t.action, hits = t.count,
			class = t.class, target = t.target and B.instPath(t.target) or nil,
		}
	end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { traps = out }
end

----------------------------------------------------------------------------------------------------
-- function hooks
----------------------------------------------------------------------------------------------------
local hooks = {}
local nextHook = 1

local function newCaller(h)
	return {
		args = nil,
	}
end

H.hook_function = function(p)
	local f = B.func(p.ref or p.target)
	local hookfn = B.need("hookfunction")
	local mode = p.mode or "log"
	local h = { id = nextHook, target = f, mode = mode, calls = 0, name = p.label, include_executor = p.include_executor, max_log = p.max_log or 3000 }
	nextHook = nextHook + 1
	local info = B.funcInfo(f)
	h.name = h.name or info.name or "?"
	local orig
	local outOpts = { depth = 2, maxItems = 20, maxStr = 400 }
	local fixedReturn
	if mode == "return" then fixedReturn = B.deArgs(p.values or { p.value }) end
	local userFn
	if mode == "wrap" or p.code then
		local fn, err = B.need("loadstring")(p.code, "=hook" .. h.id)
		if not fn then error("compile error: " .. tostring(err), 0) end
		userFn = fn()
		if type(userFn) ~= "function" then error("code must evaluate to a function(orig, ...) ... end", 0) end
	end

	local function record(args, res, err)
		h.calls = h.calls + 1
		if h.calls > h.max_log and p.stop_after_max then return end
		local ev = {
			key = h.name,
			hook = h.id,
			name = h.name,
			args = B.serPack(args, outOpts),
		}
		if res then ev.results = B.serPack(res, outOpts) end
		if err then ev.error = tostring(err) end
		ev.script = callerScript()
		if p.capture_stack then ev.stack = trace(2000) end
		E.push("hook", ev)
	end

	local function replacement(...)
		if not h.include_executor and isExecCaller() then return orig(...) end
		if mode == "block" then
			local args = B.pack(...)
			pcall(record, args, nil, nil)
			return
		elseif mode == "return" then
			pcall(record, B.pack(...), nil, nil)
			return B.unpack(fixedReturn)
		elseif userFn then
			pcall(record, B.pack(...), nil, nil)
			return userFn(orig, ...)
		end
		local args = B.pack(...)
		local res = B.pack(pcall(orig, ...))
		local okCall = res[1]
		if okCall then
			local r = { n = res.n - 1 }
			for i = 2, res.n do r[i - 1] = res[i] end
			pcall(record, args, r, nil)
			return B.unpack(r)
		end
		pcall(record, args, nil, res[2])
		error(res[2], 0)
	end

	local repl = replacement
	if C.iscclosure then
		local ok, isC = pcall(C.iscclosure, f)
		if ok and isC and C.newcclosure then repl = C.newcclosure(replacement) end
	end
	orig = hookfn(f, repl)
	h.orig = orig
	hooks[h.id] = h
	return { hook = h.id, name = h.name, mode = mode, target = B.ser(f, { depth = 0 }) }
end

H.hook_global = function(p)
	local f = B.lookup(p.name)
	if type(f) ~= "function" then error("global '" .. tostring(p.name) .. "' is not a function", 0) end
	p.ref = B.ref(f)
	p.label = p.label or p.name
	return H.hook_function(p)
end

H.unhook_function = function(p)
	local h = hooks[p.id]
	if not h then error("no function hook #" .. tostring(p.id), 0) end
	local ok = false
	if C.restorefunction then ok = pcall(C.restorefunction, h.target) end
	if not ok then
		local hookfn = B.need("hookfunction")
		hookfn(h.target, h.orig)
	end
	hooks[h.id] = nil
	return { removed = h.id, calls = h.calls }
end

H.list_hooks = function(p)
	local out = {}
	for id, h in pairs(hooks) do
		out[#out + 1] = { id = id, name = h.name, mode = h.mode, calls = h.calls }
	end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { hooks = out, traps = H.trap_list({}).traps, namecall_installed = NC.installed }
end

----------------------------------------------------------------------------------------------------
-- watches (property / children / attribute / signal)
----------------------------------------------------------------------------------------------------
local watches = {}
local nextWatch = 1

local function addWatch(kind, desc, conns)
	local w = { id = nextWatch, kind = kind, desc = desc, conns = conns, count = 0 }
	nextWatch = nextWatch + 1
	watches[w.id] = w
	return w
end

H.watch_property = function(p)
	local inst = B.inst(p.target)
	local prop = p.property
	local path = B.pathOf(inst)
	local w
	local conn = inst:GetPropertyChangedSignal(prop):Connect(function()
		w.count = w.count + 1
		local ok, v = pcall(function() return inst[prop] end)
		E.push("watch", {
			key = path .. "." .. prop,
			watch = w.id,
			kind = "property",
			instance = path,
			property = prop,
			value = ok and B.ser(v, { depth = 1, maxItems = 10, maxStr = 300 }) or NULL,
			stack = p.capture_stack and trace(1500) or nil,
			script = p.capture_script and callerScript() or nil,
		})
	end)
	w = addWatch("property", path .. "." .. prop, { conn })
	return { watch = w.id, watching = w.desc }
end

H.watch_children = function(p)
	local inst = B.inst(p.target)
	local path = B.pathOf(inst)
	local deep = p.descendants == true
	local w
	local function push(event, child)
		w.count = w.count + 1
		local ok, cp = pcall(B.pathOf, child)
		E.push("tree", { key = event .. " " .. (ok and cp or tostring(child)), watch = w.id, event = event, parent = path, class = child.ClassName, name = child.Name, path = ok and cp or nil, ref = B.ref(child) })
	end
	local c1 = (deep and inst.DescendantAdded or inst.ChildAdded):Connect(function(ch) push("added", ch) end)
	local c2 = (deep and inst.DescendantRemoving or inst.ChildRemoved):Connect(function(ch) push("removed", ch) end)
	w = addWatch("children", path .. (deep and " (descendants)" or " (children)"), { c1, c2 })
	return { watch = w.id, watching = w.desc }
end

H.watch_attribute = function(p)
	local inst = B.inst(p.target)
	local path = B.pathOf(inst)
	local w
	local sig = p.name and inst:GetAttributeChangedSignal(p.name) or inst.AttributeChanged
	local conn = sig:Connect(function(name)
		w.count = w.count + 1
		local attr = p.name or name
		E.push("watch", { key = path .. "@" .. tostring(attr), watch = w.id, kind = "attribute", instance = path, attribute = attr, value = B.ser(inst:GetAttribute(attr), { depth = 1 }) })
	end)
	w = addWatch("attribute", path .. "@" .. (p.name or "*"), { conn })
	return { watch = w.id, watching = w.desc }
end

H.watch_signal = function(p)
	local inst = B.inst(p.target)
	local name = p.signal
	local sig = inst[name]
	if typeof(sig) ~= "RBXScriptSignal" then error(inst.ClassName .. "." .. tostring(name) .. " is not a signal", 0) end
	local path = B.pathOf(inst)
	local w
	local conn = sig:Connect(function(...)
		w.count = w.count + 1
		E.push("signal", { key = path .. "." .. name, watch = w.id, instance = path, signal = name, args = B.serPack(B.pack(...), { depth = 2, maxItems = 15, maxStr = 300 }) })
	end)
	w = addWatch("signal", path .. "." .. name, { conn })
	return { watch = w.id, watching = w.desc }
end

H.unwatch = function(p)
	local w = watches[p.id]
	if not w then error("no watch #" .. tostring(p.id), 0) end
	for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
	watches[w.id] = nil
	return { removed = w.id, events = w.count }
end

H.unwatch_all = function(p)
	local n = 0
	for id, w in pairs(watches) do
		for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
		watches[id] = nil
		n = n + 1
	end
	return { removed = n }
end

H.list_watches = function(p)
	local out = {}
	for id, w in pairs(watches) do out[#out + 1] = { id = id, kind = w.kind, desc = w.desc, events = w.count } end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { watches = out }
end

----------------------------------------------------------------------------------------------------
-- network / executor spy: request, HttpGet/Post, HttpService, WebSocket.connect, loadstring
----------------------------------------------------------------------------------------------------
local spy = { active = false, hooked = {}, ncIds = {}, opts = {} }

local function shortBody(b, n)
	if type(b) ~= "string" then return b end
	return B.trunc(b, n or 4000)
end

local function spyLog(kind, data)
	data.kind = kind
	data.key = data.key or (kind .. " " .. tostring(data.url or data.chunk or ""))
	data.script = callerScript()
	if spy.opts.capture_stack then data.stack = trace(1500) end
	E.push("http", data)
end

H.http_spy_start = function(p)
	spy.opts = { capture_stack = p.capture_stack, body_limit = p.body_limit or 4000 }
	if spy.active then return { already_active = true } end
	spy.active = true
	local started = {}
	local bl = spy.opts.body_limit

	-- executor request()
	if C.request and C.hookfunction then
		local old
		local function repl(opts, ...)
			if spy.active and type(opts) == "table" then
				local res = B.pack(pcall(old, opts, ...))
				local d = {
					url = tostring(opts.Url or opts.url),
					method = tostring(opts.Method or opts.method or "GET"),
					headers = B.serWith(opts.Headers or opts.headers or {}, { depth = 1, maxItems = 20 }),
					body = shortBody(opts.Body or opts.body, bl),
				}
				if res[1] and type(res[2]) == "table" then
					d.status = res[2].StatusCode
					d.response_body = shortBody(res[2].Body, bl)
				elseif not res[1] then
					d.error = tostring(res[2])
				end
				pcall(spyLog, "request", d)
				if not res[1] then error(res[2], 0) end
				return unpack(res, 2, res.n)
			end
			return old(opts, ...)
		end
		old = C.hookfunction(C.request, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = C.request, orig = old }
		started[#started + 1] = "request"
	end

	-- loadstring (shows what code gets compiled and from where)
	if C.loadstring and C.hookfunction and p.loadstring ~= false then
		local old
		local function repl(code, chunk, ...)
			if spy.active and type(code) == "string" then
				pcall(spyLog, "loadstring", { chunk = tostring(chunk), length = #code, head = B.trunc(code, p.loadstring_head or 600), key = "loadstring " .. tostring(chunk) })
			end
			return old(code, chunk, ...)
		end
		old = C.hookfunction(C.loadstring, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = C.loadstring, orig = old }
		started[#started + 1] = "loadstring"
	end

	-- WebSocket.connect
	local ws = C.WebSocket
	if type(ws) == "table" and type(ws.connect) == "function" and C.hookfunction then
		local old
		local function repl(url, ...)
			if spy.active then pcall(spyLog, "websocket", { url = tostring(url) }) end
			return old(url, ...)
		end
		old = C.hookfunction(ws.connect, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = ws.connect, orig = old }
		started[#started + 1] = "WebSocket.connect"
	end

	-- namecall-based: game:HttpGet/HttpPost, HttpService:RequestAsync/GetAsync/PostAsync
	local function ncSpy(method, selfCheck)
		local id = NC.add(method, function(nextf, self, ...)
			if spy.active and not busy and selfCheck(self) then
				local a1, a2 = ...
				if type(a1) == "table" then
					pcall(spyLog, method, { url = tostring(a1.Url), method = tostring(a1.Method or "GET"), body = shortBody(a1.Body, bl), headers = B.serWith(a1.Headers or {}, { depth = 1 }) })
				else
					pcall(spyLog, method, { url = tostring(a1), body = shortBody(a2, bl) })
				end
			end
			return nextf(self, ...)
		end, "httpspy")
		spy.ncIds[#spy.ncIds + 1] = id
	end
	local isGame = function(s) return s == gm end
	local isHttp = function(s) return typeof(s) == "Instance" and s.ClassName == "HttpService" end
	for _, m in ipairs({ "HttpGet", "HttpGetAsync", "HttpPost", "HttpPostAsync" }) do ncSpy(m, isGame) end
	for _, m in ipairs({ "RequestAsync", "GetAsync", "PostAsync" }) do ncSpy(m, isHttp) end
	started[#started + 1] = "namecall:Http*"
	return { active = true, hooked = started }
end

H.http_spy_stop = function(p)
	spy.active = false
	-- leave hooks in place but inert (restoring in-place hooks can race with other scripts); try restore anyway
	for _, h in ipairs(spy.hooked) do
		if C.restorefunction then pcall(C.restorefunction, h.fn) end
	end
	spy.hooked = {}
	for _, id in ipairs(spy.ncIds) do NC.remove(id) end
	spy.ncIds = {}
	return { active = false }
end

H.http_spy_status = function(p)
	return { active = spy.active, hooks = #spy.hooked, events = E.size("http") }
end

----------------------------------------------------------------------------------------------------
-- output + error capture (always on, cheap)
----------------------------------------------------------------------------------------------------
B.startCaptures = function()
	local ok1 = pcall(function()
		service.LogService.MessageOut:Connect(function(message, mtype)
			E.push("output", { key = message, message = message, level = tostring(mtype):gsub("Enum.MessageType.", "") })
		end)
	end)
	local ok2 = pcall(function()
		service.ScriptContext.Error:Connect(function(message, stackTrace, scr)
			local sp
			if typeof(scr) == "Instance" then
				local ok, pth = pcall(B.pathOf, scr)
				sp = ok and pth or tostring(scr)
			end
			E.push("error", { key = tostring(message), message = tostring(message), stack = B.trunc(tostring(stackTrace), 2000), script = sp })
		end)
	end)
	return ok1, ok2
end

H.get_output = function(p)
	-- snapshot of Roblox's own log history merged with captured MessageOut events
	local out = {}
	local limit = p.limit or 100
	local levelM = p.level and B.matcher(p.level, "plain", true) or nil
	local m = p.match and B.matcher(p.match, p.match_mode, true) or nil
	local hist = service.LogService:GetLogHistory()
	local startI = math.max(1, #hist - (p.history or 300) + 1)
	if p.since == nil then
		for i = startI, #hist do
			local h = hist[i]
			local lvl = tostring(h.messageType):gsub("Enum.MessageType.", "")
			if (not levelM or levelM(lvl)) and (not m or m(h.message)) then
				out[#out + 1] = { message = B.trunc(h.message, 1000), level = lvl, t = h.timestamp }
			end
		end
		local n = #out
		if n > limit then
			local trimmed = {}
			for i = n - limit + 1, n do trimmed[#trimmed + 1] = out[i] end
			out = trimmed
		end
		return { messages = out, last_seq = E.seq, source = "log_history" }
	end
	local evs, matched, lastSeq = E.query("output", p.since, function(ev)
		return (not levelM or levelM(ev.level)) and (not m or m(ev.message))
	end, limit, false)
	return { messages = evs, matched = matched, last_seq = lastSeq, source = "events" }
end

H.clear_output = function(p)
	pcall(function() service.LogService:ClearOutput() end)
	E.clear("output")
	return { ok = true }
end
