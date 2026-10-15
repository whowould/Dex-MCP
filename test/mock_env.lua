-- Minimal Roblox/executor mock used to exercise the Dex++ MCP bridge Lua code under plain Lua 5.3 (fengari).
-- It is deliberately small: just enough fidelity for the bridge's handlers (instances, properties, signals,
-- namecall hooking, GC, debug library, services).

unpack = table.unpack
loadstring = function(code, chunk) return load(code, chunk) end
function table.clear(t) for k in pairs(t) do t[k] = nil end end
function table.find(t, v) for i = 1, #t do if t[i] == v then return i end end return nil end

---------------------------------------------------------------------------------------------------
-- clock + scheduler
---------------------------------------------------------------------------------------------------
__now = 0
os.clock = function() return __now end
local threads = {}
local dead = setmetatable({}, { __mode = "k" })

local function step(co, ...)
	if dead[co] then return end
	local ok, res = coroutine.resume(co, ...)
	if not ok then
		__js_log("LUA THREAD ERROR: " .. tostring(res))
		return
	end
	if coroutine.status(co) ~= "dead" then
		threads[#threads + 1] = { co = co, at = __now + (type(res) == "table" and res.wait or 0) }
	end
end

task = {}
function task.spawn(fn, ...)
	local co = coroutine.create(fn)
	step(co, ...)
	return co
end
function task.defer(fn, ...)
	local co = coroutine.create(fn)
	local args = table.pack(...)
	threads[#threads + 1] = { co = co, at = __now, args = args }
	return co
end
function task.wait(t)
	local start = __now
	coroutine.yield({ wait = t or 0.03 })
	return __now - start
end
function task.cancel(co) dead[co] = true end

function __pump(dt)
	__now = __now + dt
	local due = {}
	local keep = {}
	for _, th in ipairs(threads) do
		if th.at <= __now then due[#due + 1] = th else keep[#keep + 1] = th end
	end
	threads = keep
	for _, th in ipairs(due) do
		if th.args then step(th.co, table.unpack(th.args, 1, th.args.n)) else step(th.co) end
	end
end

---------------------------------------------------------------------------------------------------
-- datatypes
---------------------------------------------------------------------------------------------------
function typeof(v)
	local t = type(v)
	if t == "table" then
		local mt = getmetatable(v)
		if mt and mt.__type then return mt.__type end
	end
	return t
end

local function datatype(name, fields)
	local mt = { __type = name }
	mt.__tostring = function(v)
		local parts = {}
		for _, f in ipairs(fields) do parts[#parts + 1] = tostring(v[f]) end
		return table.concat(parts, ", ")
	end
	mt.__eq = function(a, b)
		for _, f in ipairs(fields) do if a[f] ~= b[f] then return false end end
		return true
	end
	return mt
end

local V3mt = datatype("Vector3", { "X", "Y", "Z" })
V3mt.__index = function(v, k)
	if k == "Unit" then local m = math.sqrt(v.X ^ 2 + v.Y ^ 2 + v.Z ^ 2) if m == 0 then return v end return Vector3.new(v.X / m, v.Y / m, v.Z / m) end
	if k == "Magnitude" then return math.sqrt(v.X ^ 2 + v.Y ^ 2 + v.Z ^ 2) end
end
V3mt.__mul = function(a, b) if type(b) == "number" then return Vector3.new(a.X * b, a.Y * b, a.Z * b) end return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z) end
Vector3 = { new = function(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3mt) end }
local V2mt = datatype("Vector2", { "X", "Y" })
Vector2 = { new = function(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, V2mt) end }
local C3mt = datatype("Color3", { "R", "G", "B" })
Color3 = {
	new = function(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, C3mt) end,
	fromRGB = function(r, g, b) return setmetatable({ R = r / 255, G = g / 255, B = b / 255 }, C3mt) end,
}
local CFmt = { __type = "CFrame", __tostring = function(c) return "CFrame" end }
CFrame = {
	new = function(x, y, z)
		local c = setmetatable({ Position = Vector3.new(x or 0, y or 0, z or 0) }, CFmt)
		c.GetComponents = function() return x or 0, y or 0, z or 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 end
		return c
	end,
}
local UD2mt = { __type = "UDim2" }
UDim2 = { new = function(xs, xo, ys, yo) return setmetatable({ X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } }, UD2mt) end }

local EnumItemMt = { __type = "EnumItem" }
EnumItemMt.__tostring = function(i) return "Enum." .. tostring(i.EnumType) .. "." .. i.Name end
local EnumMt = { __type = "Enum" }
EnumMt.__tostring = function(e) return e.__name end
EnumMt.__index = function(e, k)
	if k == "GetEnumItems" then return function(self) return self.__items end end
	return nil
end
local function mkEnum(name, items)
	local e = setmetatable({ __name = name, __items = {} }, EnumMt)
	for i, n in ipairs(items) do
		local it = setmetatable({ Name = n, Value = i - 1, EnumType = e }, EnumItemMt)
		rawset(e, n, it)
		e.__items[#e.__items + 1] = it
	end
	return e
end
Enum = {
	Material = mkEnum("Material", { "Plastic", "Neon", "Wood" }),
	MessageType = mkEnum("MessageType", { "MessageOutput", "MessageInfo", "MessageWarning", "MessageError" }),
	CreatorType = mkEnum("CreatorType", { "User", "Group" }),
	InfoType = mkEnum("InfoType", { "Asset", "Product", "GamePass" }),
	RunContext = mkEnum("RunContext", { "Legacy", "Server", "Client" }),
}
EnumItemMt.__tostring = EnumItemMt.__tostring

DateTime = { now = function() return { UnixTimestampMillis = 1700000000000 + math.floor(__now * 1000) } end }

---------------------------------------------------------------------------------------------------
-- signals
---------------------------------------------------------------------------------------------------
local SigMt = { __type = "RBXScriptSignal", __tostring = function() return "Signal" end }
local ConnMt = { __type = "RBXScriptConnection" }
ConnMt.__index = function(c, k)
	if k == "Disconnect" then return function(self) rawset(self, "_off", true); rawset(self, "Connected", false) end end
	if k == "Enable" then return function(self) rawset(self, "Enabled", true) end end
	if k == "Disable" then return function(self) rawset(self, "Enabled", false) end end
	if k == "Fire" then return function(self, ...) if self.Function and self.Enabled then self.Function(...) end end end
	return nil
end
local function newSignal()
	local s = setmetatable({ _conns = {} }, SigMt)
	return s
end
SigMt.__index = function(s, k)
	if k == "Connect" then
		return function(self, fn)
			local c = setmetatable({ Function = fn, Connected = true, Enabled = true, State = true, ForeignState = false }, ConnMt)
			s._conns[#s._conns + 1] = c
			return c
		end
	end
	if k == "Wait" then return function(self) task.wait(0.01) return 0.016 end end
	return nil
end
local function fireSignal(s, ...)
	for _, c in ipairs(s._conns) do
		if not rawget(c, "_off") and c.Enabled then
			local co = coroutine.create(c.Function)
			local ok, err = coroutine.resume(co, ...)
			if not ok then __js_log("signal handler error: " .. tostring(err)) end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- class tables
---------------------------------------------------------------------------------------------------
local SUPER = {
	Instance = nil, Folder = "Instance", Model = "Instance", BasePart = "Instance", Part = "BasePart",
	ValueBase = "Instance", StringValue = "ValueBase", NumberValue = "ValueBase", BoolValue = "ValueBase",
	LuaSourceContainer = "Instance", BaseScript = "LuaSourceContainer", Script = "BaseScript", LocalScript = "BaseScript", ModuleScript = "LuaSourceContainer",
	RemoteEvent = "Instance", RemoteFunction = "Instance", UnreliableRemoteEvent = "Instance", BindableEvent = "Instance",
	GuiObject = "Instance", TextLabel = "GuiObject", Frame = "GuiObject", GuiButton = "GuiObject", TextButton = "GuiButton",
	LayerCollector = "Instance", ScreenGui = "LayerCollector", PlayerGui = "Instance",
	Humanoid = "Instance", Player = "Instance", DataModel = "Instance", Workspace = "Instance", Players = "Instance",
	ReplicatedStorage = "Instance", StarterPlayer = "Instance", Lighting = "Instance", CoreGui = "Instance", CollectionService = "Instance",
	HttpService = "Instance", LogService = "Instance", ScriptContext = "Instance", RunService = "Instance", MarketplaceService = "Instance",
	Stats = "Instance", UserInputService = "Instance", TextService = "Instance", TweenService = "Instance", CorePackages = "Instance", SoundService = "Instance",
	StarterGui = "Instance", Backpack = "Instance", ClickDetector = "Instance",
}
local DEFAULTS = {
	Instance = { Archivable = true },
	Part = { Position = Vector3.new(0, 0, 0), Size = Vector3.new(4, 1, 2), Anchored = false, CanCollide = true, Material = Enum.Material.Plastic },
	StringValue = { Value = "" }, NumberValue = { Value = 0 }, BoolValue = { Value = false },
	Script = { Disabled = false, RunContext = Enum.RunContext.Legacy }, LocalScript = { Disabled = false, RunContext = Enum.RunContext.Legacy }, ModuleScript = {},
	TextLabel = { Text = "", Visible = true, AbsolutePosition = Vector2.new(0, 0), AbsoluteSize = Vector2.new(100, 20) },
	TextButton = { Text = "", Visible = true, AbsolutePosition = Vector2.new(5, 6), AbsoluteSize = Vector2.new(100, 20) },
	ScreenGui = { Enabled = true },
	Humanoid = { Health = 100, MaxHealth = 100, WalkSpeed = 16 },
	Player = { DisplayName = "", UserId = 1, AccountAge = 100 },
	Workspace = { Gravity = 196.2, StreamingEnabled = false },
}

local function isA(cls, target)
	while cls do
		if cls == target then return true end
		cls = SUPER[cls]
	end
	return false
end

-- API dump mock (what Dex's FetchAPI produces)
local PROPS = {
	Instance = { Name = "string", Archivable = "bool", Parent = "Instance:Class" },
	BasePart = { Position = "Vector3", Size = "Vector3", Anchored = "bool", CanCollide = "bool", Material = "Material:Enum" },
	StringValue = { Value = "string" }, NumberValue = { Value = "double" }, BoolValue = { Value = "bool" },
	GuiObject = {}, TextLabel = { Text = "string", Visible = "bool" }, TextButton = { Text = "string", Visible = "bool" },
	Script = { Disabled = "bool" }, LocalScript = { Disabled = "bool" },
	Humanoid = { Health = "float", MaxHealth = "float", WalkSpeed = "float" },
}
local function API_GetMember(cls, kind)
	if kind ~= "Properties" then
		if kind == "Events" then return { { Name = "ChildAdded", Class = "Instance", Parameters = { { Name = "child", Type = "Instance" } } } } end
		return {}
	end
	local out = {}
	local c = cls
	while c do
		for name, ty in pairs(PROPS[c] or {}) do
			local tn, cat = ty:match("^(.-):(%a+)$")
			if not tn then tn, cat = ty, "Primitive" end
			out[#out + 1] = { Name = name, Class = c, ValueType = { Name = tn, Category = cat }, Category = "Data", Tags = {}, Security = { Read = "None", Write = "None" } }
		end
		c = SUPER[c]
	end
	table.sort(out, function(a, b) return a.Name < b.Name end)
	return out
end
local API_Classes = {}
for name in pairs(SUPER) do API_Classes[name] = { Name = name, Tags = {} } end
API_Classes.Instance = { Name = "Instance", Tags = {} }
for name, c in pairs(API_Classes) do c.Superclass = SUPER[name] and API_Classes[SUPER[name]] or nil end

function __make_api()
	return { Classes = API_Classes, Enums = { Material = { Name = "Material", Items = { { Name = "Plastic", Value = 0 }, { Name = "Neon", Value = 1 } } } }, GetMember = API_GetMember }
end

---------------------------------------------------------------------------------------------------
-- instances
---------------------------------------------------------------------------------------------------
local IMT = { __type = "Instance" }
local Methods = {}
local nextDebug = 1
__ncm = nil
__nc_hook = nil
__all_instances = setmetatable({}, { __mode = "k" })

local function new(class, name)
	local inst = setmetatable({}, IMT)
	local p = {}
	local c = class
	local chain = {}
	while c do table.insert(chain, 1, c) c = SUPER[c] end
	for _, cn in ipairs(chain) do for k, v in pairs(DEFAULTS[cn] or {}) do p[k] = v end end
	rawset(inst, "_p", p)
	rawset(inst, "_class", class)
	rawset(inst, "_name", name or class)
	rawset(inst, "_kids", {})
	rawset(inst, "_sig", {})
	rawset(inst, "_attrs", {})
	rawset(inst, "_id", "DBG" .. nextDebug)
	nextDebug = nextDebug + 1
	__all_instances[inst] = true
	return inst
end

local function sig(inst, name)
	local s = rawget(inst, "_sig")
	if not s[name] then s[name] = newSignal() end
	return s[name]
end

local function removeFrom(list, v) for i = #list, 1, -1 do if list[i] == v then table.remove(list, i) end end end

local function setParent(inst, par)
	local old = rawget(inst, "_parent")
	if old then
		removeFrom(rawget(old, "_kids"), inst)
		fireSignal(sig(old, "ChildRemoved"), inst)
	end
	rawset(inst, "_parent", par)
	if par then
		table.insert(rawget(par, "_kids"), inst)
		fireSignal(sig(par, "ChildAdded"), inst)
		local a = par
		while a do
			fireSignal(sig(a, "DescendantAdded"), inst)
			a = rawget(a, "_parent")
		end
	end
	fireSignal(sig(inst, "prop:Parent"))
end

local function descendants(inst, out)
	for _, k in ipairs(rawget(inst, "_kids")) do
		out[#out + 1] = k
		descendants(k, out)
	end
	return out
end

IMT.__tostring = function(i) return rawget(i, "_name") end
IMT.__index = function(inst, k)
	if k == "ClassName" then return rawget(inst, "_class") end
	if k == "Name" then return rawget(inst, "_name") end
	if k == "Parent" then return rawget(inst, "_parent") end
	local p = rawget(inst, "_p")
	if p[k] ~= nil then return p[k] end
	local m = Methods[k]
	if m then
		return function(self, ...)
			__ncm = k
			if __nc_hook then return __nc_hook(self, ...) end
			return m(self, ...)
		end
	end
	local sigNames = { ChildAdded = 1, ChildRemoved = 1, DescendantAdded = 1, DescendantRemoving = 1, AttributeChanged = 1, Changed = 1, OnClientEvent = 1, MouseButton1Click = 1, MouseButton1Down = 1, MouseButton1Up = 1, Activated = 1, FocusLost = 1, Event = 1, MessageOut = 1, Error = 1, Heartbeat = 1 }
	if sigNames[k] then return sig(inst, k) end
	for _, kid in ipairs(rawget(inst, "_kids")) do
		if rawget(kid, "_name") == k then return kid end
	end
	if k == "OnClientInvoke" then return rawget(inst, "_cb") end
	if k == "Team" or k == "Character" or k == "CameraSubject" then return nil end
	error(tostring(k) .. " is not a valid member of " .. rawget(inst, "_class"), 2)
end
IMT.__newindex = function(inst, k, v)
	if k == "Parent" then setParent(inst, v) return end
	if k == "Name" then rawset(inst, "_name", v) fireSignal(sig(inst, "prop:Name")) return end
	if k == "OnClientInvoke" then rawset(inst, "_cb", v) return end
	if k == "ClassName" then error("ClassName is read-only", 2) end
	local p = rawget(inst, "_p")
	local isProp = false
	local c = rawget(inst, "_class")
	while c do if (PROPS[c] and PROPS[c][k]) or (DEFAULTS[c] and DEFAULTS[c][k] ~= nil) then isProp = true break end c = SUPER[c] end
	if not isProp then error(tostring(k) .. " is not a valid member of " .. rawget(inst, "_class"), 2) end
	p[k] = v
	fireSignal(sig(inst, "prop:" .. k))
end

Methods.GetChildren = function(self) local out = {} for i, k in ipairs(rawget(self, "_kids")) do out[i] = k end return out end
Methods.GetDescendants = function(self) return descendants(self, {}) end
Methods.FindFirstChild = function(self, name, rec)
	for _, k in ipairs(rawget(self, "_kids")) do if rawget(k, "_name") == name then return k end end
	if rec then for _, d in ipairs(descendants(self, {})) do if rawget(d, "_name") == name then return d end end end
	return nil
end
Methods.WaitForChild = Methods.FindFirstChild
Methods.FindFirstChildOfClass = function(self, cls) for _, k in ipairs(rawget(self, "_kids")) do if rawget(k, "_class") == cls then return k end end return nil end
Methods.FindFirstChildWhichIsA = function(self, cls, rec)
	local list = rec and descendants(self, {}) or rawget(self, "_kids")
	for _, k in ipairs(list) do if isA(rawget(k, "_class"), cls) then return k end end
	return nil
end
Methods.IsA = function(self, cls) return isA(rawget(self, "_class"), cls) end
Methods.IsDescendantOf = function(self, anc)
	local a = rawget(self, "_parent")
	while a do if a == anc then return true end a = rawget(a, "_parent") end
	return false
end
Methods.GetFullName = function(self)
	local parts = {}
	local c = self
	while c and c ~= game do table.insert(parts, 1, rawget(c, "_name")) c = rawget(c, "_parent") end
	return table.concat(parts, ".")
end
Methods.Destroy = function(self)
	for _, k in ipairs(Methods.GetChildren(self)) do Methods.Destroy(k) end
	setParent(self, nil)
end
Methods.ClearAllChildren = function(self) for _, k in ipairs(Methods.GetChildren(self)) do Methods.Destroy(k) end end
Methods.Clone = function(self)
	if not self.Archivable then return nil end
	local c = new(rawget(self, "_class"), rawget(self, "_name"))
	for k, v in pairs(rawget(self, "_p")) do rawget(c, "_p")[k] = v end
	for k, v in pairs(rawget(self, "_attrs")) do rawget(c, "_attrs")[k] = v end
	for _, kid in ipairs(rawget(self, "_kids")) do Methods.Clone(kid).Parent = c end
	return c
end
Methods.GetAttribute = function(self, n) return rawget(self, "_attrs")[n] end
Methods.GetAttributes = function(self) local o = {} for k, v in pairs(rawget(self, "_attrs")) do o[k] = v end return o end
Methods.SetAttribute = function(self, n, v)
	rawget(self, "_attrs")[n] = v
	fireSignal(sig(self, "attr:" .. n))
	fireSignal(sig(self, "AttributeChanged"), n)
end
Methods.GetAttributeChangedSignal = function(self, n) return sig(self, "attr:" .. n) end
Methods.GetPropertyChangedSignal = function(self, n) return sig(self, "prop:" .. n) end
Methods.GetDebugId = function(self) return rawget(self, "_id") end
Methods.GetService = function(self, name)
	for _, k in ipairs(rawget(self, "_kids")) do if rawget(k, "_class") == name then return k end end
	if SUPER[name] then
		local s = new(name, name)
		setParent(s, self)
		return s
	end
	error("'" .. tostring(name) .. "' is not a valid Service name", 2)
end
Methods.FireServer = function(self, ...) __remote_log[#__remote_log + 1] = { rawget(self, "_name"), "FireServer", table.pack(...) } end
Methods.InvokeServer = function(self, ...) __remote_log[#__remote_log + 1] = { rawget(self, "_name"), "InvokeServer", table.pack(...) } return "invoked", 7 end
Methods.Fire = function(self, ...) end
__remote_log = {}

-- CollectionService
local tags = setmetatable({}, { __mode = "k" })
Methods.AddTag = function(self, inst, tag) tags[inst] = tags[inst] or {} tags[inst][tag] = true end
Methods.RemoveTag = function(self, inst, tag) if tags[inst] then tags[inst][tag] = nil end end
Methods.HasTag = function(self, inst, tag) return tags[inst] ~= nil and tags[inst][tag] == true end
Methods.GetTags = function(self, inst) local o = {} for t in pairs(tags[inst] or {}) do o[#o + 1] = t end table.sort(o) return o end
Methods.GetTagged = function(self, tag) local o = {} for inst, t in pairs(tags) do if t[tag] then o[#o + 1] = inst end end return o end
Methods.GetAllTags = function(self) local seen, o = {}, {} for _, t in pairs(tags) do for n in pairs(t) do if not seen[n] then seen[n] = true o[#o + 1] = n end end end table.sort(o) return o end

-- HttpService / LogService / misc
Methods.JSONDecode = function(self, s) return __js_jsondecode(s) end
Methods.GenerateGUID = function(self) return "GUID-" .. tostring(math.random(100000, 999999)) end
Methods.GetLogHistory = function(self) return __log_history end
Methods.ClearOutput = function(self) __log_history = {} end
Methods.GetProductInfo = function(self, id) return { Name = "Mock Place", Description = "mock", Creator = { Name = "Maker" } } end
Methods.GetPlayers = function(self) return { __local_player } end
Methods.GetPlayerByUserId = function(self, id) return __local_player end
Methods.GetMouse = function(self) return { X = 1, Y = 2, Target = nil, Hit = nil, TargetSurface = Enum.Material.Plastic } end
Methods.GetState = function(self) return "Running" end
Methods.IsStudio = function(self) return false end
__log_history = {}

Instance = { new = function(class) if not SUPER[class] then error("Unable to create an Instance of type \"" .. tostring(class) .. "\"", 2) end return new(class) end }

---------------------------------------------------------------------------------------------------
-- world
---------------------------------------------------------------------------------------------------
game = new("DataModel", "Game")
rawget(game, "_p").PlaceId = 123
rawget(game, "_p").GameId = 456
rawget(game, "_p").JobId = "job-1"
rawget(game, "_p").CreatorId = 9
rawget(game, "_p").CreatorType = Enum.CreatorType.User
workspace = game:GetService("Workspace")
game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
game:GetService("CollectionService")
game:GetService("HttpService")
game:GetService("LogService")
game:GetService("ScriptContext")
game:GetService("CoreGui")
game:GetService("Lighting")
local Players = game:GetService("Players")
__local_player = new("Player", "Tester")
rawget(__local_player, "_p").DisplayName = "Tester"
rawget(__local_player, "_p").UserId = 42
rawget(__local_player, "_p").MembershipType = Enum.CreatorType.User
__local_player.Parent = Players
rawget(Players, "_p").LocalPlayer = __local_player
rawget(Players, "_p").MaxPlayers = 10
local pg = new("PlayerGui", "PlayerGui")
pg.Parent = __local_player
__player_gui = pg

function version() return "0.700.0" end
shared = {}
RaycastParams = { new = function() return { FilterDescendantsInstances = {}, IgnoreWater = false } end }
Enum.RaycastFilterType = mkEnum("RaycastFilterType", { "Exclude", "Include" })
Methods.Raycast = function(self, origin, dir, params) return nil end
function require(m) return { exported = true, add = function(a, b) return a + b end } end

---------------------------------------------------------------------------------------------------
-- executor API
---------------------------------------------------------------------------------------------------
__caller_is_exec = false
function getgenv() return _G end
function identifyexecutor() return "MockExec", "1.0" end
function checkcaller() return __caller_is_exec end
function newcclosure(f) return f end
function getnamecallmethod() return __ncm end
function setnamecallmethod(m) __ncm = m end
function hookmetamethod(obj, mm, fn)
	if mm == "__namecall" then
		__nc_hook = fn
		return function(self, ...) return Methods[__ncm](self, ...) end
	end
	if mm == "__index" then
		local old = IMT.__index
		IMT.__index = function(self, k) return fn(self, k) end
		return old
	end
	if mm == "__newindex" then
		local old = IMT.__newindex
		IMT.__newindex = function(self, k, v) return fn(self, k, v) end
		return old
	end
end
local hooked = {}
function hookfunction(f, repl) hooked[f] = repl return f end
function restorefunction(f) hooked[f] = nil end
function getrawmetatable(o) return getmetatable(o) end
function setrawmetatable(o, mt) return setmetatable(o, mt) end
local readonly = setmetatable({}, { __mode = "k" })
function setreadonly(t, v) readonly[t] = v end
function isreadonly(t) return readonly[t] == true end
function islclosure(f) return not __cfuncs[f] end
function iscclosure(f) return __cfuncs[f] == true end
__cfuncs = setmetatable({}, { __mode = "k" })
function isexecutorclosure(f) return __exec_closures[f] == true end
__exec_closures = setmetatable({}, { __mode = "k" })
function clonefunction(f) return function(...) return f(...) end end
function getfunctionhash(f) return "hash-" .. tostring(f):sub(-6) end
function getscripthash(s) return "sh-" .. rawget(s, "_id") end
function getscriptbytecode(s) return "BYTECODE:" .. rawget(s, "_name") end
function getscriptclosure(s) return __script_closures[s] end
__script_closures = setmetatable({}, { __mode = "k" })
__fenv_script = setmetatable({}, { __mode = "k" })
function getfenv(f)
	if f == 0 or f == nil then return _G end
	return { script = __fenv_script[f] }
end
function setfenv(f, env) debug.setupvalue(f, 1, env) return f end
__constants = setmetatable({}, { __mode = "k" })
function getconstants(f) return __constants[f] or {} end
function getupvalues(f)
	local out, i = {}, 1
	while true do
		local n, v = debug.getupvalue(f, i)
		if not n then break end
		if n ~= "_ENV" then out[i] = v end
		i = i + 1
	end
	return out
end
function setupvalue(f, idx, v) debug.setupvalue(f, idx, v) end
function getupvalue(f, idx) local _, v = debug.getupvalue(f, idx) return v end
function getprotos(f) return __protos[f] or {} end
__protos = setmetatable({}, { __mode = "k" })
__fnames = setmetatable({}, { __mode = "k" })
-- Roblox-style debug.getinfo (name/numparams/is_vararg)
local realGetinfo = debug.getinfo
debug.getinfo = function(f, what)
	local i = realGetinfo(f, "Slu")
	if not i then return nil end
	return { name = __fnames[f] or "", source = i.source, short_src = i.short_src, linedefined = i.linedefined, currentline = i.currentline, nups = i.nups, numparams = i.nparams, is_vararg = i.isvararg, what = i.what }
end
function __fire_signal(inst, name, ...) fireSignal(sig(inst, name), ...) end
__gc = {}
function getgc(include) local out = {} for _, v in ipairs(__gc) do out[#out + 1] = v end return out end
function getinstances() local out = {} for i in pairs(__all_instances) do out[#out + 1] = i end return out end
function getnilinstances() local out = {} for i in pairs(__all_instances) do if rawget(i, "_parent") == nil and i ~= game then out[#out + 1] = i end end return out end
function getscripts() local out = {} for i in pairs(__all_instances) do if isA(rawget(i, "_class"), "LuaSourceContainer") then out[#out + 1] = i end end return out end
function getrunningscripts() return getscripts() end
function getloadedmodules() local out = {} for i in pairs(__all_instances) do if rawget(i, "_class") == "ModuleScript" then out[#out + 1] = i end end return out end
function getconnections(s) local out = {} for _, c in ipairs(s._conns) do if not rawget(c, "_off") then out[#out + 1] = c end end return out end
function firesignal(s, ...) fireSignal(s, ...) end
function gethiddenproperty(inst, name) return nil, false end
function sethiddenproperty() return false end
function isscriptable() return true end
function setscriptable() return true end
function compareinstances(a, b) return a == b end
function cloneref(x) return x end
function getcallbackvalue(inst, name) return rawget(inst, "_cb") end
function getthreadidentity() return __identity or 2 end
function setthreadidentity(i) __identity = i end
function decompile(s) return "-- decompiled: " .. rawget(s, "_name") .. "\n" .. (rawget(s, "_p").Source or ("local x = 1\nreturn x")) end
local files = {}
function writefile(p, c) files[p] = c end
function appendfile(p, c) files[p] = (files[p] or "") .. c end
function readfile(p) if not files[p] then error("file not found: " .. p) end return files[p] end
function isfile(p) return files[p] ~= nil end
function isfolder(p) return false end
function listfiles(p) local o = {} for k in pairs(files) do o[#o + 1] = k end table.sort(o) return o end
function makefolder() end
function delfile(p) files[p] = nil end
function delfolder() end
function request(o)
	local port = o.Url:match("^http://[^:/]+:(%d+)")
	local path = o.Url:match("^http://[^/]+(/[^?]*)")
	if __server_port and path == "/health" then
		if tonumber(port) == __server_port then return { StatusCode = 200, Success = true, Body = '{"server":"dexpp-mcp"}' } end
		return { StatusCode = 0, StatusMessage = "ConnectFail", Success = false, Body = "" }
	end
	if __fake_http_server then return __fake_http_server(o, path) end
	return { StatusCode = 200, StatusMessage = "OK", Success = true, Headers = { ["content-type"] = "text/plain" }, Body = "echo:" .. tostring(o.Url) }
end
function setclipboard(s) __clipboard = s end
function saveinstance() end
crypt = {}

-- real websocket via the host (fengari host provides __js_ws_*)
WebSocket = {
	connect = function(url)
		local id = __js_ws_connect(url)
		local sock = { _id = id }
		local msgSig, closeSig = newSignal(), newSignal()
		sock.OnMessage = msgSig
		sock.OnClose = closeSig
		function sock:Send(data) __js_ws_send(id, data) end
		function sock:Close() __js_ws_close(id) end
		__ws_sockets[id] = { msg = msgSig, close = closeSig }
		return sock
	end,
}
__ws_sockets = {}
function __ws_event(id, kind, payload)
	local s = __ws_sockets[id]
	if not s then return end
	if kind == "message" then fireSignal(s.msg, payload) elseif kind == "close" then fireSignal(s.close) end
end
