-- 70_exec: Lua execution (with output capture, async results), files, http, clipboard, identity
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local clock = os.clock

----------------------------------------------------------------------------------------------------
-- execute
----------------------------------------------------------------------------------------------------
local execs = {}
local nextExec = 1
local MAX_KEPT = 50

local function tostr(v)
	local ok, s = pcall(tostring, v)
	return ok and s or "<unprintable>"
end

local function makeEnv(rec)
	local out = rec.output
	local function capture(level)
		return function(...)
			local n = select("#", ...)
			local parts = {}
			for i = 1, n do parts[i] = tostr((select(i, ...))) end
			out[#out + 1] = { level = level, text = table.concat(parts, "\t") }
			if #out > 2000 then table.remove(out, 1) end
		end
	end
	local env = {}
	env.print = capture("info")
	env.warn = capture("warn")
	env.ref = function(id) return B.getref(id) end
	env.R = env.ref
	env.inst = function(spec) return B.inst(spec) end
	env.ser = function(v, depth) return B.serWith(v, { depth = depth or 2 }) end
	env.dex = { bridge = B, ref = B.ref, inst = B.inst, path = B.pathOf, ser = B.ser, events = B.Events, H = B.H }
	return setmetatable(env, {
		__index = function(_, k) return B.root[k] end,
		__newindex = function(_, k, v) B.root[k] = v end,
	})
end

local function startExec(code, p, chunk)
	local compile = B.need("loadstring")
	local fn, err = compile(code, "=" .. (chunk or "dexmcp"))
	if not fn then
		return nil, err
	end
	local rec = { id = nextExec, done = false, output = {}, started = clock(), code_len = #code }
	nextExec = nextExec + 1
	execs[rec.id] = rec
	-- bound memory
	local keys = {}
	for k in pairs(execs) do keys[#keys + 1] = k end
	if #keys > MAX_KEPT then
		table.sort(keys)
		for i = 1, #keys - MAX_KEPT do execs[keys[i]] = nil end
	end
	if C.setfenv then pcall(C.setfenv, fn, makeEnv(rec)) end
	rec.thread = task.spawn(function()
		if p.identity and C.setthreadidentity then pcall(C.setthreadidentity, p.identity) end
		local res = B.pack(pcall(fn))
		rec.finished = clock()
		if res[1] then
			local r = { n = res.n - 1 }
			for i = 2, res.n do r[i - 1] = res[i] end
			rec.ok = true
			rec.results = r
		else
			rec.ok = false
			rec.error = tostring(res[2])
			if C.traceback then
				local okt, tb = pcall(C.traceback)
			end
		end
		rec.done = true
	end)
	return rec
end

local function execReport(rec, p)
	local rep = {
		id = rec.id,
		done = rec.done,
		elapsed = (rec.finished or clock()) - rec.started,
		output = rec.output,
	}
	if rec.done then
		rep.ok = rec.ok
		if rec.ok then
			rep.results = B.serPack(rec.results, p)
			rep.result_count = rec.results.n
		else
			rep.error = rec.error
		end
	else
		rep.pending = true
	end
	return rep
end

H.execute_lua = function(p)
	local rec, err = startExec(p.code, p, p.chunk_name)
	if not rec then return { ok = false, phase = "compile", error = tostring(err) } end
	local timeout = p.timeout or 15
	local t0 = clock()
	while not rec.done and clock() - t0 < timeout do task.wait() end
	local rep = execReport(rec, p)
	if rep.pending then rep.note = "still running; use get_exec_result with this id (or cancel_exec)" end
	return rep
end

H.evaluate = function(p)
	local code = "return " .. p.expression
	local compile = B.need("loadstring")
	local fn = compile(code, "=dexmcp")
	if not fn then code = p.expression end
	local rec, err = startExec(code, p, "eval")
	if not rec then return { ok = false, phase = "compile", error = tostring(err) } end
	local t0 = clock()
	while not rec.done and clock() - t0 < (p.timeout or 15) do task.wait() end
	return execReport(rec, p)
end

H.get_exec_result = function(p)
	local rec = execs[p.id]
	if not rec then error("no execution #" .. tostring(p.id), 0) end
	local t0 = clock()
	while not rec.done and p.wait and clock() - t0 < p.wait do task.wait() end
	return execReport(rec, p)
end

H.cancel_exec = function(p)
	local rec = execs[p.id]
	if not rec then error("no execution #" .. tostring(p.id), 0) end
	if rec.done then return { already_done = true } end
	pcall(task.cancel, rec.thread)
	rec.done = true
	rec.ok = false
	rec.error = "cancelled"
	return { cancelled = true }
end

H.list_execs = function(p)
	local out = {}
	for id, rec in pairs(execs) do
		out[#out + 1] = { id = id, done = rec.done, ok = rec.ok, code_len = rec.code_len, elapsed = (rec.finished or clock()) - rec.started }
	end
	table.sort(out, function(a, b) return a.id > b.id end)
	return { executions = out }
end

H.compile_check = function(p)
	local compile = B.need("loadstring")
	local fn, err = compile(p.code, "=check")
	return { ok = fn ~= nil, error = err }
end

----------------------------------------------------------------------------------------------------
-- identity
----------------------------------------------------------------------------------------------------
H.get_identity = function(p)
	local id
	if C.getthreadidentity then
		local ok, v = pcall(C.getthreadidentity)
		if ok then id = v end
	end
	return { identity = id, default_identity = B.defaultIdentity }
end

H.set_identity = function(p)
	local f = B.need("setthreadidentity")
	f(p.identity)
	B.defaultIdentity = p.identity
	return { identity = p.identity, note = "applied to this command and all later commands" }
end

----------------------------------------------------------------------------------------------------
-- filesystem (executor workspace)
----------------------------------------------------------------------------------------------------
H.read_file = function(p)
	local f = B.need("readfile")
	local data = f(p.path)
	local offset = p.offset or 0
	local maxBytes = p.max_bytes or 500000
	local chunk = data:sub(offset + 1, offset + maxBytes)
	local out = { path = p.path, size = #data, offset = offset, returned = #chunk, next_offset = (offset + #chunk < #data) and (offset + #chunk) or nil }
	if p.encoding == "base64" then out.base64 = B.b64encode(chunk) else out.content = chunk end
	return out
end

H.write_file = function(p)
	local content = p.content or ""
	if p.base64 then content = B.b64decode(p.base64) end
	if p.append then B.need("appendfile")(p.path, content) else B.need("writefile")(p.path, content) end
	return { ok = true, path = p.path, bytes = #content }
end

H.list_files = function(p)
	local f = B.need("listfiles")
	local path = p.path or ""
	local list = f(path)
	local out = {}
	for i, entry in ipairs(list) do
		if i > (p.limit or 500) then break end
		local e = { path = entry }
		if C.isfolder then
			local ok, isf = pcall(C.isfolder, entry)
			if ok then e.is_folder = isf end
		end
		out[#out + 1] = e
	end
	return { total = #list, entries = out }
end

H.file_exists = function(p)
	local out = { path = p.path }
	if C.isfile then out.is_file = C.isfile(p.path) end
	if C.isfolder then out.is_folder = C.isfolder(p.path) end
	return out
end

H.delete_file = function(p)
	B.need("delfile")(p.path)
	return { ok = true }
end

H.make_folder = function(p)
	B.need("makefolder")(p.path)
	return { ok = true }
end

H.delete_folder = function(p)
	B.need("delfolder")(p.path)
	return { ok = true }
end

----------------------------------------------------------------------------------------------------
-- network / clipboard
----------------------------------------------------------------------------------------------------
H.http_request = function(p)
	local req = B.need("request")
	local opts = { Url = p.url, Method = p.method or "GET", Headers = p.headers, Body = p.body }
	local ok, res = B.timed(function() return req(opts) end, p.timeout or 30)
	if not ok then error("request failed: " .. tostring(res), 0) end
	local body = res.Body
	local limit = p.max_body or 200000
	local truncated = false
	if type(body) == "string" and #body > limit then body = body:sub(1, limit) truncated = true end
	return {
		status = res.StatusCode,
		status_message = res.StatusMessage,
		success = res.Success,
		headers = B.obj(B.serWith(res.Headers or {}, { depth = 1, maxItems = 60 }).fields or {}),
		body = body,
		truncated = truncated,
	}
end

H.set_clipboard = function(p)
	B.need("setclipboard")(p.text)
	return { ok = true, length = #p.text }
end
