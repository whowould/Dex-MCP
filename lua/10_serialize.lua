-- 10_serialize: ref registry, value serializer/deserializer, instance path building + resolution
local C = B.C
local Dex = B.Dex
local service = Dex.service
local typeof = typeof or type
local NULL = B.NULL
local gm = game

----------------------------------------------------------------------------------------------------
-- Ref registry: opaque ids for functions/tables/instances/userdata so the client can address them later
----------------------------------------------------------------------------------------------------
local refs = {}
local refIds = setmetatable({}, { __mode = "k" })
local nextRef = 1
local refCount = 0
local refQueue, qHead, qTail = {}, 1, 0
B.refs = refs

local function refable(v)
	local t = type(v)
	return t == "table" or t == "function" or t == "userdata" or t == "thread"
end

function B.ref(v)
	if not refable(v) then return nil end
	local id = refIds[v]
	if id and refs[id] == v then return id end
	id = nextRef
	nextRef = nextRef + 1
	refs[id] = v
	refIds[v] = id
	refCount = refCount + 1
	qTail = qTail + 1
	refQueue[qTail] = id
	local max = (B.cfg and B.cfg.MaxRefs) or 50000
	while refCount > max and qHead <= qTail do
		local old = refQueue[qHead]
		refQueue[qHead] = nil
		qHead = qHead + 1
		local ov = refs[old]
		if ov ~= nil then
			refs[old] = nil
			refIds[ov] = nil
			refCount = refCount - 1
		end
	end
	return id
end

function B.getref(id)
	local v = refs[id]
	if v == nil then error("ref #" .. tostring(id) .. " does not exist (released, evicted or never created)", 0) end
	return v
end

function B.unref(id)
	local v = refs[id]
	if v ~= nil then
		refs[id] = nil
		refIds[v] = nil
		refCount = refCount - 1
		return true
	end
	return false
end

function B.refStats()
	return { count = refCount, next_id = nextRef }
end

function B.clearRefs()
	local n = refCount
	for id, v in pairs(refs) do refIds[v] = nil end
	table.clear(refs)
	refCount = 0
	refQueue, qHead, qTail = {}, 1, 0
	return n
end

----------------------------------------------------------------------------------------------------
-- Function info
----------------------------------------------------------------------------------------------------
function B.funcInfo(f)
	local info = {}
	local ok, i = false, nil
	if C.getinfo then ok, i = pcall(C.getinfo, f) end
	if ok and type(i) == "table" then
		info.name = i.name ~= "" and i.name or nil
		info.source = i.source
		info.short_src = i.short_src
		info.line = i.linedefined or i.currentline
		info.nups = i.nups
		info.numparams = i.numparams
		info.is_vararg = i.is_vararg
		info.what = i.what
	elseif debug and debug.info then
		local ok2, src, line, name, nparams, vararg = pcall(debug.info, f, "slna")
		if ok2 then
			info.source = src
			info.line = line
			info.name = name ~= "" and name or nil
			info.numparams = nparams
			info.is_vararg = vararg
		end
	end
	if C.islclosure then
		local ok3, v = pcall(C.islclosure, f)
		if ok3 then info.lua_closure = v end
	elseif C.iscclosure then
		local ok3, v = pcall(C.iscclosure, f)
		if ok3 then info.lua_closure = not v end
	end
	if C.isexecutorclosure then
		local ok4, v = pcall(C.isexecutorclosure, f)
		if ok4 then info.executor_closure = v end
	end
	return info
end

----------------------------------------------------------------------------------------------------
-- Lua string quoting used in instance paths
----------------------------------------------------------------------------------------------------
local QESC = { ["\\"] = "\\\\", ['"'] = '\\"', ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
local function luaQuote(s)
	return '"' .. (s:gsub('[%c"\\]', function(c)
		return QESC[c] or string.format("\\%d", c:byte())
	end)) .. '"'
end
B.luaQuote = luaQuote

local KEYWORDS = {}
for _, k in ipairs({ "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "continue", "export", "type" }) do
	KEYWORDS[k] = true
end

function B.identOk(name)
	return name:match("^[%a_][%w_]*$") ~= nil and not KEYWORDS[name]
end

-- Lua expression that re-finds `inst` (what B.resolvePath parses)
function B.pathOf(inst)
	local chain, cur, guard = {}, inst, 0
	while cur ~= nil and cur ~= gm and guard < 400 do
		chain[#chain + 1] = cur
		cur = cur.Parent
		guard = guard + 1
	end
	local first
	if cur == gm then
		first = "game"
	else
		local top = chain[#chain]
		chain[#chain] = nil
		if not top then return "game" end
		first = "getnil(" .. luaQuote(top.ClassName) .. "," .. luaQuote(top.Name) .. ")"
	end
	local out = { first }
	for i = #chain, 1, -1 do
		local name = chain[i].Name
		if B.identOk(name) then
			out[#out + 1] = "." .. name
		else
			out[#out + 1] = "[" .. luaQuote(name) .. "]"
		end
	end
	return table.concat(out)
end

----------------------------------------------------------------------------------------------------
-- Serializer: Lua/Roblox value -> JSON-ready tree. Complex values get {"$t":<type>,...}
----------------------------------------------------------------------------------------------------
local SER = {}
B.SER = SER
B.serOpts = { depth = 2, maxItems = 40, maxStr = 4000, bytes = 256 }

local function newOpts(o)
	local d = B.serOpts
	if not o then return d end
	return {
		depth = o.depth or d.depth,
		maxItems = o.maxItems or d.maxItems,
		maxStr = o.maxStr or d.maxStr,
		bytes = o.bytes or d.bytes,
	}
end

local function tag(t, extra)
	extra = extra or {}
	extra["$t"] = t
	return extra
end

local function n(v) return v end

SER.Vector3 = function(v) return tag("Vector3", { v = { v.X, v.Y, v.Z } }) end
SER.Vector2 = function(v) return tag("Vector2", { v = { v.X, v.Y } }) end
SER.Vector3int16 = function(v) return tag("Vector3int16", { v = { v.X, v.Y, v.Z } }) end
SER.Vector2int16 = function(v) return tag("Vector2int16", { v = { v.X, v.Y } }) end
SER.CFrame = function(v) return tag("CFrame", { v = { v:GetComponents() } }) end
SER.Color3 = function(v)
	return tag("Color3", {
		v = { v.R, v.G, v.B },
		hex = string.format("#%02x%02x%02x", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)),
	})
end
SER.BrickColor = function(v) return tag("BrickColor", { name = v.Name, number = v.Number }) end
SER.UDim = function(v) return tag("UDim", { v = { v.Scale, v.Offset } }) end
SER.UDim2 = function(v) return tag("UDim2", { v = { v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset } }) end
SER.Rect = function(v) return tag("Rect", { v = { v.Min.X, v.Min.Y, v.Max.X, v.Max.Y } }) end
SER.Ray = function(v) return tag("Ray", { origin = { v.Origin.X, v.Origin.Y, v.Origin.Z }, direction = { v.Direction.X, v.Direction.Y, v.Direction.Z } }) end
SER.Region3 = function(v)
	local c, s = v.CFrame.Position, v.Size
	return tag("Region3", { center = { c.X, c.Y, c.Z }, size = { s.X, s.Y, s.Z } })
end
SER.NumberRange = function(v) return tag("NumberRange", { v = { v.Min, v.Max } }) end
SER.NumberSequence = function(v)
	local kp = {}
	for i, k in ipairs(v.Keypoints) do kp[i] = { k.Time, k.Value, k.Envelope } end
	return tag("NumberSequence", { keypoints = kp })
end
SER.ColorSequence = function(v)
	local kp = {}
	for i, k in ipairs(v.Keypoints) do kp[i] = { k.Time, k.Value.R, k.Value.G, k.Value.B } end
	return tag("ColorSequence", { keypoints = kp })
end
SER.NumberSequenceKeypoint = function(v) return tag("NumberSequenceKeypoint", { time = v.Time, value = v.Value, envelope = v.Envelope }) end
SER.ColorSequenceKeypoint = function(v) return tag("ColorSequenceKeypoint", { time = v.Time, value = { v.Value.R, v.Value.G, v.Value.B } }) end
SER.PhysicalProperties = function(v)
	return tag("PhysicalProperties", { density = v.Density, friction = v.Friction, elasticity = v.Elasticity, friction_weight = v.FrictionWeight, elasticity_weight = v.ElasticityWeight })
end
SER.Font = function(v) return tag("Font", { family = v.Family, weight = tostring(v.Weight), style = tostring(v.Style) }) end
SER.TweenInfo = function(v)
	return tag("TweenInfo", { time = v.Time, easing_style = tostring(v.EasingStyle), easing_direction = tostring(v.EasingDirection), repeat_count = v.RepeatCount, reverses = v.Reverses, delay = v.DelayTime })
end
SER.DateTime = function(v) return tag("DateTime", { unix_ms = v.UnixTimestampMillis, iso = v:ToIsoDate() }) end
SER.Random = function(v) return tag("Random") end
SER.Axes = function(v) return tag("Axes", { str = tostring(v) }) end
SER.Faces = function(v) return tag("Faces", { str = tostring(v) }) end
SER.EnumItem = function(v) return tag("EnumItem", { enum = tostring(v.EnumType), name = v.Name, value = v.Value }) end
SER.Enum = function(v) return tag("Enum", { name = tostring(v) }) end
SER.Enums = function(v) return tag("Enums") end
SER.RBXScriptSignal = function(v) return tag("Signal", { str = tostring(v), ref = B.ref(v) }) end
SER.RBXScriptConnection = function(v)
	local ok, c = pcall(function() return v.Connected end)
	return tag("Connection", { connected = ok and c or nil, ref = B.ref(v) })
end
SER.RaycastResult = function(v)
	return tag("RaycastResult", {
		instance = B.ser(v.Instance),
		position = { v.Position.X, v.Position.Y, v.Position.Z },
		normal = { v.Normal.X, v.Normal.Y, v.Normal.Z },
		material = tostring(v.Material),
		distance = v.Distance,
	})
end
SER.thread = function(v)
	return tag("thread", { status = coroutine.status(v), ref = B.ref(v) })
end
SER.buffer = function(v, o)
	local len = buffer.len(v)
	local out = tag("buffer", { len = len, ref = B.ref(v) })
	if len > 0 then
		local take = math.min(len, o.bytes)
		out.hex = B.hex(buffer.readstring(v, 0, take))
		if take < len then out.truncated = true end
	end
	return out
end

SER.Instance = function(v)
	local ok, out = pcall(function()
		return tag("Instance", {
			class = v.ClassName,
			name = v.Name,
			path = B.pathOf(v),
			ref = B.ref(v),
		})
	end)
	if ok then return out end
	return tag("Instance", { str = tostring(v), ref = B.ref(v) })
end

SER["function"] = function(f)
	local info = B.funcInfo(f)
	info["$t"] = "function"
	info.ref = B.ref(f)
	return info
end

local function keyLabel(k, o)
	local kt = typeof(k)
	if kt == "string" then return k end
	if kt == "number" or kt == "boolean" then return "[" .. tostring(k) .. "]" end
	if kt == "Instance" then
		local ok, s = pcall(function() return k.ClassName .. ":" .. k.Name end)
		return "[Instance " .. (ok and s or "?") .. " #" .. tostring(B.ref(k)) .. "]"
	end
	local id = B.ref(k)
	return "[" .. kt .. (id and (" #" .. id) or "") .. "]"
end

SER.table = function(t, o, depth, path)
	local id = B.ref(t)
	local out = tag("table", { ref = id })
	path = path or {}
	if path[t] then
		out.cycle = true
		return out
	end
	local mt
	if C.getrawmetatable then
		local ok, m = pcall(C.getrawmetatable, t)
		if ok then mt = m end
	else
		local ok, m = pcall(getmetatable, t)
		if ok then mt = m end
	end
	if type(mt) == "table" then out.has_metatable = true end

	-- classify
	local len = #t
	local total, nonSeq = 0, 0
	for k in next, t do
		total = total + 1
		if not (type(k) == "number" and k >= 1 and k <= len and k == math.floor(k)) then nonSeq = nonSeq + 1 end
		if total > 100000 then break end
	end
	out.count = total
	if total == 0 then return out end
	if depth >= o.depth then
		out.collapsed = true
		return out
	end

	path[t] = true
	if nonSeq == 0 then
		out["$t"] = "array"
		local items = {}
		for i = 1, math.min(len, o.maxItems) do
			items[i] = B.ser(t[i], o, depth + 1, path)
			if items[i] == nil then items[i] = NULL end
		end
		out.items = items
		if len > o.maxItems then out.more = len - o.maxItems end
	else
		local fields, shown = {}, 0
		for k, v in next, t do
			if shown >= o.maxItems then
				out.more = total - shown
				break
			end
			shown = shown + 1
			local sv = B.ser(v, o, depth + 1, path)
			if sv == nil then sv = NULL end
			fields[keyLabel(k, o)] = sv
		end
		out.fields = B.obj(fields)
	end
	path[t] = nil
	return out
end

SER.userdata = function(v)
	return tag("userdata", { str = tostring(v), ref = B.ref(v) })
end

function B.ser(v, o, depth, path)
	local t = typeof(v)
	if t == "nil" then return NULL end
	if t == "string" then
		local limit = (o and o.maxStr) or B.serOpts.maxStr
		if #v > limit then
			return tag("string", { len = #v, v = v:sub(1, limit), truncated = true })
		end
		return v
	end
	if t == "number" or t == "boolean" then return v end
	o = o and (o.depth and o) or B.serOpts
	local f = SER[t]
	if f then
		local ok, r = pcall(f, v, o, depth or 0, path)
		if ok then return r end
		return tag(t, { str = tostring(v), error = tostring(r) })
	end
	if type(v) == "table" then return SER.table(v, o, depth or 0, path) end
	local ok, s = pcall(tostring, v)
	return tag(t, { str = ok and s or "?", ref = refable(v) and B.ref(v) or nil })
end

-- serialize with fresh options (used by handlers: depth/maxItems/maxStr come from request params)
function B.serWith(v, p)
	return B.ser(v, newOpts(p))
end

-- serialize a pack of return values -> array
function B.serPack(pk, p)
	local o = newOpts(p)
	local out = {}
	for i = 1, pk.n do
		local s = B.ser(pk[i], o, 0)
		if s == nil then s = NULL end
		out[i] = s
	end
	return out
end

----------------------------------------------------------------------------------------------------
-- Path parsing + resolution (no loadstring)
----------------------------------------------------------------------------------------------------
local function readQuoted(s, i)
	local q = s:sub(i, i)
	local j = i + 1
	local buf = {}
	while j <= #s do
		local c = s:sub(j, j)
		if c == "\\" then
			local nx = s:sub(j + 1, j + 1)
			if nx == "n" then buf[#buf + 1] = "\n" j = j + 2
			elseif nx == "r" then buf[#buf + 1] = "\r" j = j + 2
			elseif nx == "t" then buf[#buf + 1] = "\t" j = j + 2
			elseif nx:match("%d") then
				local d = s:match("^%d%d?%d?", j + 1)
				buf[#buf + 1] = string.char(tonumber(d) % 256)
				j = j + 1 + #d
			else
				buf[#buf + 1] = nx
				j = j + 2
			end
		elseif c == q then
			return table.concat(buf), j + 1
		else
			buf[#buf + 1] = c
			j = j + 1
		end
	end
	return nil, "unterminated string in path"
end

-- parse argument list "( ... )" starting at i (the '('). returns list, nextIndex
local function readArgs(s, i)
	local args = {}
	i = i + 1
	while true do
		i = s:match("^%s*()", i)
		local c = s:sub(i, i)
		if c == ")" then return args, i + 1 end
		if c == "" then return nil, "unterminated argument list" end
		if c == '"' or c == "'" then
			local str, nx = readQuoted(s, i)
			if not str then return nil, nx end
			args[#args + 1] = str
			i = nx
		else
			local word = s:match("^[%w_%.%-]+", i)
			if not word then return nil, "bad argument at " .. i end
			if word == "true" then args[#args + 1] = true
			elseif word == "false" then args[#args + 1] = false
			elseif tonumber(word) then args[#args + 1] = tonumber(word)
			else args[#args + 1] = word end
			i = i + #word
		end
		i = s:match("^%s*()", i)
		if s:sub(i, i) == "," then i = i + 1 end
	end
end

local function childNames(inst, limit)
	local names = {}
	local ok, kids = pcall(inst.GetChildren, inst)
	if not ok then return "" end
	for i = 1, math.min(#kids, limit or 12) do names[i] = kids[i].Name end
	local s = table.concat(names, ", ")
	if #kids > (limit or 12) then s = s .. ", ... (" .. #kids .. " total)" end
	return s
end

local function getChild(cur, name)
	local ok, r = pcall(cur.FindFirstChild, cur, name)
	if ok and r then return r end
	if cur == gm then
		local ok2, svc = pcall(gm.GetService, gm, name)
		if ok2 and svc then return svc end
	end
	return nil
end

local function findNil(class, name)
	if not C.getnilinstances then return nil, "getnilinstances unavailable" end
	for _, v in ipairs(C.getnilinstances()) do
		if (class == nil or v.ClassName == class) and (name == nil or v.Name == name) then return v end
	end
	return nil, "no nil-parented " .. tostring(class) .. " named " .. tostring(name)
end

local debugIdIndex
local function findByDebugId(id)
	if not debugIdIndex then debugIdIndex = {} end
	local hit = debugIdIndex[id]
	if hit and hit.Parent ~= nil then return hit end
	local pools = {}
	if C.getinstances then pools[#pools + 1] = C.getinstances() end
	if C.getnilinstances then pools[#pools + 1] = C.getnilinstances() end
	if #pools == 0 then pools[1] = gm:GetDescendants() end
	for _, pool in ipairs(pools) do
		for i, v in ipairs(pool) do
			local ok, did = pcall(v.GetDebugId, v)
			if ok then
				debugIdIndex[did] = v
				if did == id then return v end
			end
			if i % 5000 == 0 then B.yield() end
		end
	end
	return nil, "no instance with debug id " .. tostring(id)
end
B.findByDebugId = findByDebugId

function B.resolvePath(s)
	s = s:match("^%s*(.-)%s*$")
	if s == "" then return nil, "empty path" end
	local i = 1
	local cur

	-- root forms
	local refId = s:match("^#(%d+)$") or s:match("^ref%((%d+)%)$") or s:match("^(%d+)$")
	if refId then
		local v = refs[tonumber(refId)]
		if v == nil then return nil, "ref #" .. refId .. " does not exist" end
		if typeof(v) ~= "Instance" then return nil, "ref #" .. refId .. " is a " .. typeof(v) .. ", not an Instance" end
		return v
	end
	local did = s:match("^debugid%(%s*[\"']([^\"']+)[\"']%s*%)$") or s:match("^debugid:(.+)$")
	if did then return findByDebugId(did) end

	if s:sub(1, 3) == "nil" and s:sub(4, 4) == ":" then
		-- nil:Class:Name  (also nil:Name)
		local rest = s:sub(5)
		local a, b = rest:match("^([^:]+):(.+)$")
		if a then return findNil(a, b) end
		return findNil(nil, rest)
	end

	local gn = s:match("^getnil%s*%(")
	if gn then
		local args, nx = readArgs(s, s:find("%("))
		if not args then return nil, nx end
		cur = findNil(args[1], args[2])
		if not cur then return nil, "no nil-parented instance " .. tostring(args[1]) .. "/" .. tostring(args[2]) end
		i = nx
	else
		local word = s:match("^[%w_]+")
		if word == "game" then
			cur = gm
			i = 5
		elseif word == "workspace" then
			cur = workspace
			i = 10
		elseif word == "script" then
			return nil, "'script' has no meaning here"
		else
			cur = gm
			i = 1
			-- implicit leading child name (e.g. "Workspace.Part"); allow free-form names with spaces up to next separator
			local name = s:match("^([^%.%[%]:%(%)]+)")
			if not name then return nil, "cannot parse path start: " .. s end
			local c = getChild(gm, name)
			if not c then return nil, "game has no child '" .. name .. "'" end
			cur = c
			i = #name + 1
		end
	end

	while i <= #s do
		i = s:match("^%s*()", i)
		local c = s:sub(i, i)
		if c == "" then break end
		if c == "." then
			local name = s:match("^%.([^%.%[%]:%(%)]+)", i)
			if not name then return nil, "bad path segment at " .. i .. " in " .. s end
			name = name:match("^%s*(.-)%s*$")
			if name == "Parent" then
				local par = cur.Parent
				if not par then return nil, cur:GetFullName() .. " has no Parent" end
				cur = par
			else
				local nx = getChild(cur, name)
				if not nx then
					return nil, "no child '" .. name .. "' under " .. B.pathOf(cur) .. " (children: " .. childNames(cur) .. ")"
				end
				cur = nx
			end
			i = i + 1 + #(s:match("^%.([^%.%[%]:%(%)]+)", i))
		elseif c == "[" then
			local q = s:sub(i + 1, i + 1)
			if q == '"' or q == "'" then
				local str, nx = readQuoted(s, i + 1)
				if not str then return nil, nx end
				if s:sub(nx, nx) ~= "]" then return nil, "expected ] at " .. nx end
				local child = getChild(cur, str)
				if not child then
					return nil, "no child '" .. str .. "' under " .. B.pathOf(cur) .. " (children: " .. childNames(cur) .. ")"
				end
				cur = child
				i = nx + 1
			else
				local num = s:match("^%[%s*(%d+)%s*%]", i)
				if not num then return nil, "bad index at " .. i end
				local kids = cur:GetChildren()
				local child = kids[tonumber(num)]
				if not child then return nil, "child index " .. num .. " out of range (" .. #kids .. " children)" end
				cur = child
				i = s:find("%]", i) + 1
			end
		elseif c == ":" then
			local method = s:match("^:([%a_]+)%s*%(", i)
			if not method then return nil, "bad method call at " .. i end
			local args, nx = readArgs(s, s:find("%(", i))
			if not args then return nil, nx end
			i = nx
			local lm = method:lower()
			if lm == "getservice" or lm == "service" then
				local ok, svc = pcall(gm.GetService, gm, args[1])
				if not ok or not svc then return nil, "no service " .. tostring(args[1]) end
				cur = svc
			elseif lm == "findfirstchild" or lm == "waitforchild" then
				local ok, r = pcall(cur.FindFirstChild, cur, args[1], args[2] == true)
				if not ok or not r then return nil, "FindFirstChild(" .. tostring(args[1]) .. ") found nothing under " .. B.pathOf(cur) end
				cur = r
			elseif lm == "findfirstchildofclass" then
				local r = cur:FindFirstChildOfClass(args[1])
				if not r then return nil, "no child of class " .. tostring(args[1]) end
				cur = r
			elseif lm == "findfirstchildwhichisa" then
				local r = cur:FindFirstChildWhichIsA(args[1])
				if not r then return nil, "no child which is a " .. tostring(args[1]) end
				cur = r
			elseif lm == "findfirstancestor" or lm == "findfirstancestorofclass" or lm == "findfirstancestorwhichisa" then
				local r = cur[method](cur, args[1])
				if not r then return nil, "no ancestor " .. tostring(args[1]) end
				cur = r
			elseif lm == "getchildren" or lm == "getdescendants" then
				local idx = s:match("^%s*%[%s*(%d+)%s*%]", i)
				if not idx then return nil, method .. "() must be followed by [index]" end
				local list = cur[method](cur)
				local r = list[tonumber(idx)]
				if not r then return nil, method .. "()[" .. idx .. "] out of range (" .. #list .. ")" end
				cur = r
				i = s:find("%]", i) + 1
			else
				return nil, "unsupported method in path: " .. method
			end
		else
			return nil, "unexpected character '" .. c .. "' at " .. i .. " in path: " .. s
		end
	end
	return cur
end

-- resolve any instance spec: Instance | ref number | "#12" | path string | {ref=}|{path=}|{["$t"]="Instance",...}
function B.inst(spec)
	local t = typeof(spec)
	if t == "Instance" then return spec end
	if t == "number" then
		local v = refs[spec]
		if v == nil then error("ref #" .. spec .. " does not exist", 0) end
		if typeof(v) ~= "Instance" then error("ref #" .. spec .. " is a " .. typeof(v) .. ", not an Instance", 0) end
		return v
	end
	if t == "string" then
		local r, err = B.resolvePath(spec)
		if not r then error(err or ("cannot resolve '" .. spec .. "'"), 0) end
		return r
	end
	if t == "table" then
		if spec.ref then return B.inst(tonumber(spec.ref)) end
		if spec.id then return B.inst(tonumber(spec.id)) end
		if spec.path then return B.inst(spec.path) end
		if spec.debug_id then
			local r, err = findByDebugId(spec.debug_id)
			if not r then error(err, 0) end
			return r
		end
	end
	error("invalid instance target (expected path string, ref number or {ref|path})", 0)
end

-- like B.inst but returns nil on failure instead of raising
function B.tryInst(spec)
	local ok, r = pcall(B.inst, spec)
	if ok then return r end
	return nil, r
end

-- resolve a ref to any value
function B.val(spec)
	local t = type(spec)
	if t == "number" then return B.getref(spec) end
	if t == "string" then
		local id = spec:match("^#?(%d+)$") or spec:match("^ref%((%d+)%)$")
		if id then return B.getref(tonumber(id)) end
		return B.inst(spec)
	end
	if t == "table" then
		if spec.ref then return B.getref(tonumber(spec.ref)) end
		if spec.id then return B.getref(tonumber(spec.id)) end
		return B.inst(spec)
	end
	error("invalid value target", 0)
end

-- typed function resolver: ref to a function, or a script instance -> its closure
function B.func(spec)
	local v = B.val(spec)
	if type(v) == "function" then return v end
	error("target is a " .. typeof(v) .. ", not a function", 0)
end

----------------------------------------------------------------------------------------------------
-- Deserializer: JSON-decoded tagged tree -> Lua values
----------------------------------------------------------------------------------------------------
local DE = {}
B.DE = DE

local function vec(x, k, d)
	return x.v or { x.x or x.X or d, x.y or x.Y or d, x.z or x.Z or d }
end

DE["nil"] = function() return nil end
DE.Vector3 = function(x) local v = vec(x) return Vector3.new(v[1] or 0, v[2] or 0, v[3] or 0) end
DE.Vector2 = function(x) local v = vec(x) return Vector2.new(v[1] or 0, v[2] or 0) end
DE.Vector3int16 = function(x) local v = vec(x) return Vector3int16.new(v[1] or 0, v[2] or 0, v[3] or 0) end
DE.Vector2int16 = function(x) local v = vec(x) return Vector2int16.new(v[1] or 0, v[2] or 0) end
DE.CFrame = function(x)
	local v = x.v or {}
	if #v >= 12 then return CFrame.new(unpack(v, 1, 12)) end
	if #v == 3 then return CFrame.new(v[1], v[2], v[3]) end
	if x.position then
		local p = x.position
		local cf = CFrame.new(p[1], p[2], p[3])
		if x.angles then
			local a = x.angles
			cf = cf * CFrame.Angles(math.rad(a[1]), math.rad(a[2]), math.rad(a[3]))
		end
		return cf
	end
	return CFrame.new()
end
DE.Color3 = function(x)
	if x.hex then
		local h = x.hex:gsub("#", "")
		return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
	end
	local v = x.v or {}
	if x.rgb255 or (v[1] and v[1] > 1) or (v[2] and v[2] > 1) or (v[3] and v[3] > 1) then
		return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
	end
	return Color3.new(v[1] or 0, v[2] or 0, v[3] or 0)
end
DE.BrickColor = function(x)
	if x.name then return BrickColor.new(x.name) end
	return BrickColor.new(x.number or 194)
end
DE.UDim = function(x) local v = x.v or {} return UDim.new(v[1] or 0, v[2] or 0) end
DE.UDim2 = function(x) local v = x.v or {} return UDim2.new(v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0) end
DE.Rect = function(x) local v = x.v or {} return Rect.new(v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0) end
DE.NumberRange = function(x) local v = x.v or {} return NumberRange.new(v[1] or 0, v[2] or v[1] or 0) end
DE.NumberSequence = function(x)
	local kp = {}
	for i, k in ipairs(x.keypoints or {}) do kp[i] = NumberSequenceKeypoint.new(k[1], k[2], k[3] or 0) end
	return NumberSequence.new(kp)
end
DE.ColorSequence = function(x)
	local kp = {}
	for i, k in ipairs(x.keypoints or {}) do kp[i] = ColorSequenceKeypoint.new(k[1], Color3.new(k[2], k[3], k[4])) end
	return ColorSequence.new(kp)
end
DE.Ray = function(x) local o, d = x.origin or {0,0,0}, x.direction or {0,0,0} return Ray.new(Vector3.new(unpack(o)), Vector3.new(unpack(d))) end
DE.PhysicalProperties = function(x) return PhysicalProperties.new(x.density, x.friction, x.elasticity, x.friction_weight or 1, x.elasticity_weight or 1) end
DE.EnumItem = function(x)
	local e = Enum[x.enum]
	if not e then error("unknown Enum '" .. tostring(x.enum) .. "'", 0) end
	if x.name then
		local it = e[x.name]
		if it then return it end
	end
	if x.value then
		for _, it in ipairs(e:GetEnumItems()) do if it.Value == x.value then return it end end
	end
	error("unknown enum item " .. tostring(x.enum) .. "." .. tostring(x.name or x.value), 0)
end
DE.Enum = function(x) return Enum[x.name:gsub("^Enum%.", "")] end
DE.Font = function(x)
	return Font.new(x.family or "rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight[x.weight and tostring(x.weight):gsub("^Enum%.FontWeight%.", "") or "Regular"], Enum.FontStyle[x.style and tostring(x.style):gsub("^Enum%.FontStyle%.", "") or "Normal"])
end
DE.TweenInfo = function(x)
	return TweenInfo.new(x.time or 1, Enum.EasingStyle[(x.easing_style or "Quad"):gsub("^Enum%.EasingStyle%.", "")], Enum.EasingDirection[(x.easing_direction or "Out"):gsub("^Enum%.EasingDirection%.", "")], x.repeat_count or 0, x.reverses or false, x.delay or 0)
end

DE.Instance = function(x)
	if x.ref then return B.inst(tonumber(x.ref)) end
	if x.path then return B.inst(x.path) end
	if x.debug_id then return B.inst({ debug_id = x.debug_id }) end
	error("Instance value needs ref or path", 0)
end
DE.ref = function(x) return B.getref(tonumber(x.id or x.ref)) end
DE.Ref = DE.ref

local function deTable(x, depth)
	local out = {}
	for k, v in pairs(x) do
		if k ~= "$t" then
			local nk = k
			out[nk] = B.de(v, depth + 1)
		end
	end
	return out
end

local function deRefTag(x)
	if x.ref then return true, B.getref(tonumber(x.ref)) end
	return false
end
DE["function"] = function(x) local ok, v = deRefTag(x) if ok then return v end error("function value needs ref", 0) end
DE.thread = DE["function"]
DE.userdata = DE["function"]
DE.Signal = DE["function"]
DE.Connection = DE["function"]
DE.buffer = function(x)
	if x.ref then return B.getref(tonumber(x.ref)) end
	local s = x.b64 and B.b64decode(x.b64) or (x.hex and (x.hex:gsub("%x%x", function(h) return string.char(tonumber(h, 16)) end))) or ""
	local b = buffer.create(#s)
	buffer.writestring(b, 0, s)
	return b
end
DE.bytes = function(x) return B.b64decode(x.b64 or "") end
DE.number = function(x)
	local v = x.v
	if v == "nan" then return 0 / 0 end
	if v == "inf" then return math.huge end
	if v == "-inf" then return -math.huge end
	return tonumber(v)
end
DE.string = function(x) return x.v end
DE.table = function(x, depth)
	local okr, v = deRefTag(x)
	if okr then return v end
	local out = {}
	if x.fields then
		for k, v2 in pairs(x.fields) do out[k] = B.de(v2, (depth or 0) + 1) end
	end
	return out
end
DE.array = function(x, depth)
	local okr, v = deRefTag(x)
	if okr then return v end
	local out = {}
	local items = x.items or {}
	for i = 1, #items do out[i] = B.de(items[i], (depth or 0) + 1) end
	return out
end
DE.RBXScriptSignal = DE.Signal

function B.de(x, depth)
	if type(x) ~= "table" then return x end
	depth = depth or 0
	if depth > 40 then error("value nested too deeply", 0) end
	local tg = x["$t"]
	if tg ~= nil then
		local f = DE[tg]
		if not f then error("unknown value tag '$t': '" .. tostring(tg) .. "'", 0) end
		return f(x, depth)
	end
	local out = {}
	for k, v in pairs(x) do out[k] = B.de(v, depth + 1) end
	return out
end

-- decode a JSON args list to a pack preserving nils ({"$t":"nil"} entries)
function B.deArgs(list)
	if list == nil then return { n = 0 } end
	if type(list) ~= "table" then return { n = 1, B.de(list) } end
	local maxn = 0
	for k in pairs(list) do if type(k) == "number" and k > maxn then maxn = k end end
	local pk = { n = maxn }
	for i = 1, maxn do pk[i] = B.de(list[i]) end
	return pk
end
