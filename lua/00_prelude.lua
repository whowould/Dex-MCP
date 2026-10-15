-- 00_prelude: executor capability resolver, JSON, base64, small utilities
local Dex = B.Dex
local service = Dex.service
local C = {}
B.C = C

local root = (getgenv and getgenv()) or getfenv(0)
B.root = root

local function lookup(name)
	local cur = root
	for part in string.gmatch(name, "[^%.]+") do
		if type(cur) ~= "table" then return nil end
		local ok, v = pcall(function() return cur[part] end)
		if not ok then return nil end
		cur = v
		if cur == nil then return nil end
	end
	return cur
end
B.lookup = lookup

-- first existing alias wins
local function pick(...)
	for i = 1, select("#", ...) do
		local v = lookup((select(i, ...)))
		if v ~= nil then return v end
	end
	return nil
end
B.pick = pick

-- Executor API table. Every entry may be nil; handlers call B.need("name") to fail with a clear message.
C.getgc = pick("getgc", "get_gc_objects")
C.filtergc = pick("filtergc")
C.getinstances = pick("getinstances", "get_instances")
C.getnilinstances = pick("getnilinstances", "get_nil_instances")
C.getscripts = pick("getscripts", "get_scripts")
C.getrunningscripts = pick("getrunningscripts", "get_running_scripts")
C.getloadedmodules = pick("getloadedmodules", "get_loaded_modules")
C.getsenv = pick("getsenv", "getmenv")
C.getconnections = pick("getconnections", "get_signal_cons")
C.firesignal = pick("firesignal")
C.getrawmetatable = pick("getrawmetatable", "debug.getmetatable")
C.setrawmetatable = pick("setrawmetatable", "debug.setmetatable")
C.setreadonly = pick("setreadonly")
C.isreadonly = pick("isreadonly")
C.hookfunction = pick("hookfunction", "replaceclosure", "detour_function")
C.restorefunction = pick("restorefunction")
C.hookmetamethod = pick("hookmetamethod")
C.newcclosure = pick("newcclosure")
C.clonefunction = pick("clonefunction")
C.checkcaller = pick("checkcaller")
C.getcallingscript = pick("getcallingscript")
C.getnamecallmethod = pick("getnamecallmethod", "get_namecall_method")
C.setnamecallmethod = pick("setnamecallmethod", "set_namecall_method")
C.gethiddenproperty = pick("gethiddenproperty", "get_hidden_property")
C.sethiddenproperty = pick("sethiddenproperty", "set_hidden_property")
C.isscriptable = pick("isscriptable")
C.setscriptable = pick("setscriptable")
C.getthreadidentity = pick("getthreadidentity", "getidentity", "get_thread_identity", "syn.get_thread_identity", "syn.get_thread_context", "getthreadcontext")
C.setthreadidentity = pick("setthreadidentity", "setidentity", "set_thread_identity", "syn.set_thread_identity", "syn.set_thread_context", "setthreadcontext")
C.getfunctionhash = pick("getfunctionhash")
C.getscripthash = pick("getscripthash")
C.getscriptbytecode = pick("getscriptbytecode", "dumpstring")
C.getscriptclosure = pick("getscriptclosure", "getscriptfunction")
C.decompile = pick("decompile")
C.islclosure = pick("islclosure", "is_l_closure")
C.iscclosure = pick("iscclosure", "is_c_closure")
C.isexecutorclosure = pick("isexecutorclosure", "checkclosure", "isourclosure", "is_synapse_function", "is_executor_closure")
C.getupvalues = pick("debug.getupvalues", "getupvalues", "getupvals")
C.getupvalue = pick("debug.getupvalue", "getupvalue", "getupval")
C.setupvalue = pick("debug.setupvalue", "setupvalue", "setupval")
C.getconstants = pick("debug.getconstants", "getconstants", "getconsts")
C.getconstant = pick("debug.getconstant", "getconstant", "getconst")
C.setconstant = pick("debug.setconstant", "setconstant", "setconst")
C.getprotos = pick("debug.getprotos", "getprotos")
C.getproto = pick("debug.getproto", "getproto")
C.getstack = pick("debug.getstack", "getstack")
C.setstack = pick("debug.setstack", "setstack")
C.getinfo = pick("debug.getinfo", "getinfo")
C.debuginfo = (debug and debug.info) or nil
C.traceback = (debug and debug.traceback) or nil
C.getreg = pick("getreg", "debug.getregistry")
C.getthreads = pick("getthreads")
C.getcallbackvalue = pick("getcallbackvalue")
C.compareinstances = pick("compareinstances")
C.cloneref = pick("cloneref")
C.isnetworkowner = pick("isnetworkowner")
C.gethui = pick("gethui")
C.fireclickdetector = pick("fireclickdetector")
C.fireproximityprompt = pick("fireproximityprompt")
C.firetouchinterest = pick("firetouchinterest")
C.getcustomasset = pick("getcustomasset", "getsynasset")
C.saveinstance = pick("saveinstance", "syn.saveinstance")
C.request = pick("request", "http_request", "syn.request", "http.request", "fluxus.request")
C.identifyexecutor = pick("identifyexecutor", "getexecutorname")
C.setclipboard = pick("setclipboard", "toclipboard", "set_clipboard")
C.readfile = pick("readfile")
C.writefile = pick("writefile")
C.appendfile = pick("appendfile")
C.isfile = pick("isfile")
C.isfolder = pick("isfolder")
C.listfiles = pick("listfiles")
C.makefolder = pick("makefolder")
C.delfile = pick("delfile")
C.delfolder = pick("delfolder")
C.loadstring = pick("loadstring")
C.lz4decompress = pick("lz4decompress")
C.crypt = pick("crypt")
C.WebSocket = pick("WebSocket", "syn.websocket")
C.getfflag = pick("getfflag", "getfflagvalue")
C.firesignal = pick("firesignal")
C.getgenv = getgenv
C.getrenv = pick("getrenv")
C.getfenv = getfenv
C.setfenv = setfenv

function B.need(name)
	local f = C[name]
	if f == nil then
		error("executor does not provide '" .. name .. "'", 0)
	end
	return f
end

-- every probe name used for get_capabilities, grouped
B.CapGroups = {
	instances = { "getgc", "filtergc", "getinstances", "getnilinstances", "getscripts", "getrunningscripts", "getloadedmodules", "getsenv", "cloneref", "compareinstances", "gethui" },
	hooks = { "hookfunction", "restorefunction", "hookmetamethod", "newcclosure", "clonefunction", "checkcaller", "getcallingscript", "getnamecallmethod", "setnamecallmethod" },
	metatables = { "getrawmetatable", "setrawmetatable", "setreadonly", "isreadonly" },
	properties = { "gethiddenproperty", "sethiddenproperty", "isscriptable", "setscriptable" },
	identity = { "getthreadidentity", "setthreadidentity" },
	scripts = { "decompile", "getscriptbytecode", "getscripthash", "getscriptclosure", "getfunctionhash" },
	closures = { "islclosure", "iscclosure", "isexecutorclosure", "getupvalues", "getupvalue", "setupvalue", "getconstants", "getconstant", "setconstant", "getprotos", "getproto", "getstack", "setstack", "getinfo" },
	signals = { "getconnections", "firesignal", "getcallbackvalue" },
	interaction = { "fireclickdetector", "fireproximityprompt", "firetouchinterest", "isnetworkowner" },
	network = { "request", "WebSocket" },
	filesystem = { "readfile", "writefile", "appendfile", "isfile", "isfolder", "listfiles", "makefolder", "delfile", "delfolder", "getcustomasset" },
	misc = { "saveinstance", "setclipboard", "loadstring", "getreg", "getthreads", "crypt", "lz4decompress", "identifyexecutor", "getfflag" },
}

----------------------------------------------------------------------------------------------------
-- Small helpers
----------------------------------------------------------------------------------------------------
local NULL = setmetatable({}, { __tostring = function() return "null" end })
B.NULL = NULL

-- closures created by the bridge itself (spy/watch handlers): hidden from handler listings
B.ownFns = setmetatable({}, { __mode = "k" })

local objMarks = setmetatable({}, { __mode = "k" })
function B.obj(t) objMarks[t] = true return t end
function B.arr(t) objMarks[t] = nil return t end

function B.now()
	local ok, ms = pcall(function() return DateTime.now().UnixTimestampMillis end)
	if ok and ms then return ms / 1000 end
	return os.time()
end

local clock = os.clock
local lastYield = clock()
-- cooperative yield: call inside long loops
function B.yield(budget)
	if clock() - lastYield > (budget or 0.008) then
		task.wait()
		lastYield = clock()
		return true
	end
	return false
end

function B.pack(...)
	return { n = select("#", ...), ... }
end

function B.unpack(t, i, j)
	return unpack(t, i or 1, j or t.n or #t)
end

function B.safe(f, ...)
	local ok, a, b, c, d = pcall(f, ...)
	if ok then return a, b, c, d end
	return nil
end

function B.trunc(s, n)
	s = tostring(s)
	if #s > n then return s:sub(1, n) .. "...(+" .. (#s - n) .. ")" end
	return s
end

function B.keys(t)
	local out = {}
	for k in pairs(t) do out[#out + 1] = k end
	table.sort(out, function(a, b) return tostring(a) < tostring(b) end)
	return out
end

function B.count(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

function B.escapePattern(s)
	return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- build a string matcher: mode "plain" | "pattern" | "exact"; case-insensitive optional
function B.matcher(query, mode, ci)
	if query == nil or query == "" then return function() return true end end
	local q = query
	if ci then q = q:lower() end
	mode = mode or "plain"
	if mode == "exact" then
		return function(s)
			if ci then s = s:lower() end
			return s == q
		end
	elseif mode == "pattern" then
		return function(s)
			if ci then s = s:lower() end
			local ok, r = pcall(string.find, s, q)
			return ok and r ~= nil
		end
	else
		return function(s)
			if ci then s = s:lower() end
			return string.find(s, q, 1, true) ~= nil
		end
	end
end

----------------------------------------------------------------------------------------------------
-- base64
----------------------------------------------------------------------------------------------------
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64enc, b64dec = {}, {}
for i = 1, 64 do
	local c = b64chars:sub(i, i)
	b64enc[i - 1] = c
	b64dec[c:byte()] = i - 1
end

function B.b64encode(s)
	local out, n = {}, 0
	local len = #s
	for i = 1, len - 2, 3 do
		local a, b, c = s:byte(i, i + 2)
		local v = a * 65536 + b * 256 + c
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. b64enc[math.floor(v / 64) % 64] .. b64enc[v % 64]
	end
	local rem = len % 3
	if rem == 1 then
		local a = s:byte(len)
		local v = a * 65536
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. "=="
	elseif rem == 2 then
		local a, b = s:byte(len - 1, len)
		local v = a * 65536 + b * 256
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. b64enc[math.floor(v / 64) % 64] .. "="
	end
	return table.concat(out)
end

function B.b64decode(s)
	s = s:gsub("[^%w%+/=]", "")
	local out, n = {}, 0
	for i = 1, #s, 4 do
		local c1, c2, c3, c4 = s:byte(i, i + 3)
		local d1, d2 = b64dec[c1], b64dec[c2]
		if not d1 or not d2 then break end
		local d3 = c3 and b64dec[c3]
		local d4 = c4 and b64dec[c4]
		local v = d1 * 262144 + d2 * 4096 + (d3 or 0) * 64 + (d4 or 0)
		n = n + 1
		if d3 and d4 then
			out[n] = string.char(math.floor(v / 65536) % 256, math.floor(v / 256) % 256, v % 256)
		elseif d3 then
			out[n] = string.char(math.floor(v / 65536) % 256, math.floor(v / 256) % 256)
		else
			out[n] = string.char(math.floor(v / 65536) % 256)
		end
	end
	return table.concat(out)
end

function B.hex(s, maxLen)
	if maxLen and #s > maxLen then s = s:sub(1, maxLen) end
	return (s:gsub(".", function(c) return string.format("%02x", c:byte()) end))
end

----------------------------------------------------------------------------------------------------
-- JSON encoder (tolerates Roblox values, cycles, invalid UTF-8)
----------------------------------------------------------------------------------------------------
local J = {}
B.J = J

local ESC = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
for i = 0, 31 do
	local ch = string.char(i)
	if not ESC[ch] then ESC[ch] = string.format("\\u%04x", i) end
end
ESC["\127"] = "\\u007f"

local utf8len = utf8 and utf8.len
local function validUtf8(s)
	if not utf8len then return true end
	local ok, r = pcall(utf8len, s)
	return ok and r ~= nil
end

local function encStr(s)
	if validUtf8(s) then
		return '"' .. (s:gsub('[%c"\\]', ESC)) .. '"'
	end
	return '{"$t":"bytes","len":' .. #s .. ',"b64":"' .. B.b64encode(s) .. '"}'
end

local function encKey(k)
	k = tostring(k)
	if not validUtf8(k) then
		k = k:gsub("[\128-\255]", "?")
	end
	return '"' .. (k:gsub('[%c"\\]', ESC)) .. '"'
end

local function encNum(n)
	if n ~= n then return '{"$t":"number","v":"nan"}' end
	if n == math.huge then return '{"$t":"number","v":"inf"}' end
	if n == -math.huge then return '{"$t":"number","v":"-inf"}' end
	if n == math.floor(n) and n > -1e15 and n < 1e15 then return string.format("%d", n) end
	return string.format("%.15g", n)
end

local function isArray(t)
	local n = #t
	if n == 0 then return next(t) == nil end
	local cnt = 0
	for k in pairs(t) do
		if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then return false end
		cnt = cnt + 1
	end
	return cnt == n
end

local MAXDEPTH = 64

local function enc(v, buf, depth, seen)
	local t = type(v)
	if v == nil or v == NULL then
		buf[#buf + 1] = "null"
	elseif t == "string" then
		buf[#buf + 1] = encStr(v)
	elseif t == "number" then
		buf[#buf + 1] = encNum(v)
	elseif t == "boolean" then
		buf[#buf + 1] = v and "true" or "false"
	elseif t == "table" then
		if depth > MAXDEPTH then buf[#buf + 1] = '"<max depth>"' return end
		if seen[v] then buf[#buf + 1] = '"<cycle>"' return end
		seen[v] = true
		if not objMarks[v] and isArray(v) then
			buf[#buf + 1] = "["
			for i = 1, #v do
				if i > 1 then buf[#buf + 1] = "," end
				enc(v[i], buf, depth + 1, seen)
			end
			buf[#buf + 1] = "]"
		else
			buf[#buf + 1] = "{"
			local first = true
			local ks = {}
			for k in pairs(v) do ks[#ks + 1] = k end
			table.sort(ks, function(a, b) return tostring(a) < tostring(b) end)
			for _, k in ipairs(ks) do
				local val = v[k]
				if val ~= nil then
					if not first then buf[#buf + 1] = "," end
					first = false
					buf[#buf + 1] = encKey(k)
					buf[#buf + 1] = ":"
					enc(val, buf, depth + 1, seen)
				end
			end
			buf[#buf + 1] = "}"
		end
		seen[v] = nil
	else
		-- userdata / function / thread / roblox datatypes: serialize with refs
		if B.ser then
			local ok, tree = pcall(B.ser, v)
			if ok then enc(tree, buf, depth + 1, seen) return end
		end
		buf[#buf + 1] = encStr(tostring(v))
	end
end

function J.encode(v)
	local buf = {}
	enc(v, buf, 0, {})
	return table.concat(buf)
end

local HttpService = service.HttpService
function J.decode(s)
	return HttpService:JSONDecode(s)
end

B.json = J.encode
B.unjson = J.decode
