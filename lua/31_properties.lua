-- 31_properties: properties (via Dex's API dump), hidden props, attributes, tags, class/enum info, method calls
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local API = Dex.API
local CollectionService = service.CollectionService

----------------------------------------------------------------------------------------------------
-- value coercion for set_property / call args based on the API ValueType
----------------------------------------------------------------------------------------------------
local function nums(v, n, label)
	if type(v) == "table" then
		if v.v then v = v.v end
		return v
	end
	if type(v) == "string" then
		local out = {}
		for num in v:gmatch("[%-%+]?[%d%.eE]+") do out[#out + 1] = tonumber(num) end
		return out
	end
	error("cannot coerce " .. typeof(v) .. " to " .. (label or "vector"), 0)
end

local COERCE = {}
COERCE.Vector3 = function(v) local a = nums(v, 3, "Vector3") return Vector3.new(a[1] or 0, a[2] or 0, a[3] or 0) end
COERCE.Vector2 = function(v) local a = nums(v, 2, "Vector2") return Vector2.new(a[1] or 0, a[2] or 0) end
COERCE.Vector3int16 = function(v) local a = nums(v, 3) return Vector3int16.new(a[1] or 0, a[2] or 0, a[3] or 0) end
COERCE.Vector2int16 = function(v) local a = nums(v, 2) return Vector2int16.new(a[1] or 0, a[2] or 0) end
COERCE.UDim = function(v) local a = nums(v, 2) return UDim.new(a[1] or 0, a[2] or 0) end
COERCE.UDim2 = function(v) local a = nums(v, 4) return UDim2.new(a[1] or 0, a[2] or 0, a[3] or 0, a[4] or 0) end
COERCE.Rect = function(v) local a = nums(v, 4) return Rect.new(a[1] or 0, a[2] or 0, a[3] or 0, a[4] or 0) end
COERCE.NumberRange = function(v) local a = nums(v, 2) return NumberRange.new(a[1] or 0, a[2] or a[1] or 0) end
COERCE.CFrame = function(v)
	local a = nums(v, 12, "CFrame")
	if #a >= 12 then return CFrame.new(unpack(a, 1, 12)) end
	if #a == 6 then return CFrame.new(a[1], a[2], a[3]) * CFrame.Angles(math.rad(a[4]), math.rad(a[5]), math.rad(a[6])) end
	return CFrame.new(a[1] or 0, a[2] or 0, a[3] or 0)
end
COERCE.Color3 = function(v)
	if type(v) == "string" then
		local hex = v:match("^#?(%x%x%x%x%x%x)$")
		if hex then return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)) end
	end
	local a = nums(v, 3, "Color3")
	if (a[1] or 0) > 1 or (a[2] or 0) > 1 or (a[3] or 0) > 1 then return Color3.fromRGB(a[1] or 0, a[2] or 0, a[3] or 0) end
	return Color3.new(a[1] or 0, a[2] or 0, a[3] or 0)
end
COERCE.BrickColor = function(v)
	if type(v) == "number" then return BrickColor.new(v) end
	return BrickColor.new(tostring(v))
end
COERCE.string = function(v) return tostring(v) end
COERCE.Content = COERCE.string
COERCE.number = function(v) local n = tonumber(v) if n == nil then error("expected number, got " .. tostring(v), 0) end return n end
COERCE.int = COERCE.number
COERCE.int64 = COERCE.number
COERCE.float = COERCE.number
COERCE.double = COERCE.number
COERCE.bool = function(v)
	if type(v) == "boolean" then return v end
	if v == "true" or v == 1 then return true end
	if v == "false" or v == 0 then return false end
	error("expected boolean, got " .. tostring(v), 0)
end
COERCE.boolean = COERCE.bool

-- coerce `raw` (JSON-decoded) for a property whose API type is `vt` ({Name=,Category=})
function B.coerce(vt, raw)
	if type(raw) == "table" and raw["$t"] ~= nil then
		return B.de(raw)
	end
	if not vt then return B.de(raw) end
	local cat, name = vt.Category, vt.Name
	if cat == "Enum" then
		local e = Enum[name]
		if e then
			if type(raw) == "string" then
				local short = raw:gsub("^Enum%." .. name .. "%.", "")
				if e[short] then return e[short] end
			end
			if type(raw) == "number" then
				for _, it in ipairs(e:GetEnumItems()) do if it.Value == raw then return it end end
			end
			error("unknown " .. name .. " value " .. tostring(raw), 0)
		end
	elseif cat == "Class" then
		if raw == nil or raw == NULL then return nil end
		return B.inst(raw)
	end
	local f = COERCE[name]
	if f then return f(raw) end
	return B.de(raw)
end

----------------------------------------------------------------------------------------------------
-- reading
----------------------------------------------------------------------------------------------------
local propCache = {}
local function classProps(className)
	local c = propCache[className]
	if c then return c end
	local list = API.GetMember(className, "Properties") or {}
	local byName = {}
	for _, pr in ipairs(list) do byName[pr.Name] = pr end
	c = { list = list, by = byName }
	propCache[className] = c
	return c
end
B.classProps = classProps

local function readProp(inst, name)
	local ok, v = pcall(function() return inst[name] end)
	if ok then return true, v, false end
	if C.gethiddenproperty then
		local ok2, v2, isHidden = pcall(C.gethiddenproperty, inst, name)
		if ok2 then return true, v2, true end
	end
	return false, v, false
end

local function propEntry(inst, pr, opts)
	local ok, v, hidden = readProp(inst, pr.Name)
	local e = {
		name = pr.Name,
		type = pr.ValueType and pr.ValueType.Name or "?",
		category = pr.Category,
	}
	if ok then
		e.value = B.ser(v, opts)
		if e.value == nil then e.value = NULL end
	else
		e.error = B.trunc(tostring(v), 160)
	end
	if hidden then e.hidden = true end
	local tags = pr.Tags
	if tags then
		if tags.ReadOnly then e.readonly = true end
		if tags.NotScriptable then e.not_scriptable = true end
		if tags.Deprecated then e.deprecated = true end
		if tags.Hidden then e.hidden_tag = true end
	end
	if pr.Security and pr.Security.Write and pr.Security.Write ~= "None" then e.write_security = pr.Security.Write end
	if pr.Security and pr.Security.Read and pr.Security.Read ~= "None" then e.read_security = pr.Security.Read end
	return e
end

H.get_properties = function(p)
	local inst = B.inst(p.target)
	local info = classProps(inst.ClassName)
	local opts = { depth = p.depth or 2, maxItems = p.max_items or 20, maxStr = p.max_str or 500 }
	local nameM = B.matcher(p.name, p.name_mode, true)
	local catM = p.category and B.matcher(p.category, "plain", true) or nil
	local out = {}
	for _, pr in ipairs(info.list) do
		local tags = pr.Tags or {}
		local show = true
		if tags.Deprecated and not p.include_deprecated then show = false end
		if tags.NotScriptable and not p.include_hidden then show = false end
		if p.name and not nameM(pr.Name) then show = false end
		if catM and not catM(pr.Category or "") then show = false end
		if show then out[#out + 1] = propEntry(inst, pr, opts) end
	end
	if p.only_non_default then
		local ok, tmp = pcall(Instance.new, inst.ClassName)
		if ok and tmp then
			local filtered = {}
			for _, e in ipairs(out) do
				local ok2, dv = pcall(function() return tmp[e.name] end)
				local ok3, cv = pcall(function() return inst[e.name] end)
				local differs = true
				if ok2 and ok3 then
					if dv == cv then differs = false
					elseif typeof(dv) == typeof(cv) and tostring(dv) == tostring(cv) then differs = false end
				end
				if differs then filtered[#filtered + 1] = e end
			end
			out = filtered
			pcall(tmp.Destroy, tmp)
		end
	end
	local res = { instance = B.ser(inst), count = #out, properties = out }
	if p.include_attributes ~= false then
		local attrs = inst:GetAttributes()
		if next(attrs) ~= nil then res.attributes = B.serWith(attrs, opts).fields or {} end
		local tags = CollectionService:GetTags(inst)
		if #tags > 0 then res.tags = tags end
	end
	return res
end

H.get_property = function(p)
	local inst = B.inst(p.target)
	local name = p.name
	local ok, v, hidden = readProp(inst, name)
	if not ok then
		error("cannot read property '" .. name .. "' of " .. inst.ClassName .. ": " .. tostring(v), 0)
	end
	local out = { value = B.serWith(v, { depth = p.depth or 3, maxItems = p.max_items or 100, maxStr = p.max_str or 20000 }), type = typeof(v) }
	if out.value == nil then out.value = NULL end
	if hidden then out.hidden = true end
	return out
end

H.get_properties_bulk = function(p)
	local out = {}
	for _, t in ipairs(p.targets) do
		local inst = B.tryInst(t)
		if inst then
			local row = { ref = B.ref(inst), name = inst.Name, class = inst.ClassName, values = {} }
			for _, pn in ipairs(p.properties) do
				local ok, v = readProp(inst, pn)
				if ok then row.values[pn] = B.ser(v, { depth = 1, maxItems = 10, maxStr = 300 }) else row.values[pn] = { ["$t"] = "error" } end
			end
			row.values = B.obj(row.values)
			out[#out + 1] = row
		end
	end
	return { rows = out }
end

----------------------------------------------------------------------------------------------------
-- writing
----------------------------------------------------------------------------------------------------
local function writeProp(inst, name, raw)
	local info = classProps(inst.ClassName)
	local pr = info.by[name]
	local vt = pr and pr.ValueType
	local val = B.coerce(vt, raw)
	local ok, err = pcall(function() inst[name] = val end)
	if ok then return true end
	if C.sethiddenproperty then
		local ok2, err2 = pcall(C.sethiddenproperty, inst, name, val)
		if ok2 then return true, "hidden" end
		err = err2
	end
	error("cannot set '" .. name .. "': " .. tostring(err), 0)
end

function B.setProps(inst, props)
	for k, v in pairs(props) do writeProp(inst, k, v) end
end

H.set_property = function(p)
	local inst = B.inst(p.target)
	local _, how = writeProp(inst, p.name, p.value)
	local ok, v = readProp(inst, p.name)
	return { ok = true, via = how, new_value = ok and B.ser(v, { depth = 1, maxItems = 10 }) or NULL }
end

H.set_properties = function(p)
	local inst = B.inst(p.target)
	local results = {}
	for name, raw in pairs(p.properties) do
		local ok, err = pcall(writeProp, inst, name, raw)
		results[name] = ok and "ok" or tostring(err)
	end
	return { results = B.obj(results) }
end

H.set_property_many = function(p)
	-- same property on many instances: {targets:[...], name, value}
	local results = {}
	for i, t in ipairs(p.targets) do
		local inst, err = B.tryInst(t)
		if inst then
			local ok, e2 = pcall(writeProp, inst, p.name, p.value)
			results[i] = { ref = B.ref(inst), ok = ok, error = (not ok) and tostring(e2) or nil }
		else
			results[i] = { ok = false, error = tostring(err) }
		end
	end
	return { results = results }
end

H.get_hidden_property = function(p)
	local inst = B.inst(p.target)
	local f = B.need("gethiddenproperty")
	local v, hidden = f(inst, p.name)
	return { value = B.serWith(v, p), is_hidden = hidden }
end

H.set_hidden_property = function(p)
	local inst = B.inst(p.target)
	local f = B.need("sethiddenproperty")
	local info = classProps(inst.ClassName).by[p.name]
	local val = B.coerce(info and info.ValueType, p.value)
	f(inst, p.name, val)
	return { ok = true }
end

H.is_scriptable = function(p)
	local inst = B.inst(p.target)
	return { scriptable = B.need("isscriptable")(inst, p.name) }
end

H.set_scriptable = function(p)
	local inst = B.inst(p.target)
	local was = B.need("setscriptable")(inst, p.name, p.value ~= false)
	return { previous = was }
end

----------------------------------------------------------------------------------------------------
-- attributes + tags
----------------------------------------------------------------------------------------------------
H.get_attributes = function(p)
	local inst = B.inst(p.target)
	local attrs = inst:GetAttributes()
	local out = {}
	for k, v in pairs(attrs) do out[k] = B.ser(v, { depth = 2, maxItems = 20, maxStr = 1000 }) end
	return { attributes = B.obj(out), count = B.count(attrs) }
end

H.set_attribute = function(p)
	local inst = B.inst(p.target)
	inst:SetAttribute(p.name, B.de(p.value))
	return { ok = true, value = B.ser(inst:GetAttribute(p.name)) }
end

H.delete_attribute = function(p)
	local inst = B.inst(p.target)
	inst:SetAttribute(p.name, nil)
	return { ok = true }
end

H.get_tags = function(p)
	local inst = B.inst(p.target)
	return { tags = CollectionService:GetTags(inst) }
end

H.add_tag = function(p)
	local inst = B.inst(p.target)
	CollectionService:AddTag(inst, p.tag)
	return { tags = CollectionService:GetTags(inst) }
end

H.remove_tag = function(p)
	local inst = B.inst(p.target)
	CollectionService:RemoveTag(inst, p.tag)
	return { tags = CollectionService:GetTags(inst) }
end

H.find_by_tag = function(p)
	local list = CollectionService:GetTagged(p.tag)
	local out = {}
	for i = 1, math.min(#list, p.limit or 200) do
		local s = B.summ(list[i], false)
		s.path = B.instPath(list[i])
		out[i] = s
	end
	return { total = #list, instances = out }
end

H.list_tags = function(p)
	local ok, tags = pcall(CollectionService.GetAllTags, CollectionService)
	if ok then return { tags = tags } end
	-- fall back: collect from descendants
	local seen, out = {}, {}
	for i, d in ipairs(game:GetDescendants()) do
		for _, t in ipairs(CollectionService:GetTags(d)) do
			if not seen[t] then seen[t] = true out[#out + 1] = t end
		end
		if i % 3000 == 0 then B.yield() end
	end
	table.sort(out)
	return { tags = out }
end

----------------------------------------------------------------------------------------------------
-- class / enum reflection
----------------------------------------------------------------------------------------------------
H.get_class_info = function(p)
	local cls = API.Classes[p.class]
	if not cls then error("unknown class '" .. tostring(p.class) .. "'", 0) end
	local chain = {}
	local c = cls
	while c do chain[#chain + 1] = c.Name c = c.Superclass end
	local function members(kind)
		local out = {}
		for _, m in ipairs(API.GetMember(p.class, kind) or {}) do
			local e = { name = m.Name, defined_in = m.Class }
			if m.ValueType then e.type = m.ValueType.Name end
			if m.ReturnType then e.returns = m.ReturnType end
			if m.Parameters then
				local ps = {}
				for i, par in ipairs(m.Parameters) do ps[i] = par.Name .. ": " .. par.Type end
				e.params = ps
			end
			if m.Tags then
				local t = {}
				for k in pairs(m.Tags) do t[#t + 1] = k end
				table.sort(t)
				if #t > 0 then e.tags = t end
			end
			if m.Security then
				if type(m.Security) == "table" then
					local r, w = m.Security.Read, m.Security.Write
					if (r and r ~= "None") or (w and w ~= "None") then e.security = { read = r, write = w } end
				elseif m.Security ~= "None" then
					e.security = m.Security
				end
			end
			if m.Category then e.category = m.Category end
			out[#out + 1] = e
		end
		return out
	end
	local tags = {}
	for k in pairs(cls.Tags) do tags[#tags + 1] = k end
	table.sort(tags)
	return {
		class = cls.Name,
		superclass_chain = chain,
		tags = tags,
		properties = p.members ~= false and members("Properties") or nil,
		functions = p.members ~= false and members("Functions") or nil,
		events = p.members ~= false and members("Events") or nil,
	}
end

H.list_classes = function(p)
	local nameM = B.matcher(p.filter, "plain", true)
	local out = {}
	for name, cls in pairs(API.Classes) do
		if nameM(name) and (not p.subclass_of or (function()
			local c = cls
			while c do if c.Name == p.subclass_of then return true end c = c.Superclass end
			return false
		end)()) then
			out[#out + 1] = { name = name, superclass = cls.Superclass and cls.Superclass.Name or nil }
		end
	end
	table.sort(out, function(a, b) return a.name < b.name end)
	local limit = p.limit or 300
	local trimmed = {}
	for i = 1, math.min(#out, limit) do trimmed[i] = out[i] end
	return { total = #out, classes = trimmed }
end

H.get_enum = function(p)
	local e = API.Enums[p.name]
	if not e then error("unknown enum '" .. tostring(p.name) .. "'", 0) end
	local items = {}
	for _, it in ipairs(e.Items) do items[#items + 1] = { name = it.Name, value = it.Value } end
	table.sort(items, function(a, b) return a.value < b.value end)
	return { name = e.Name, items = items }
end

H.list_enums = function(p)
	local nameM = B.matcher(p.filter, "plain", true)
	local out = {}
	for name in pairs(API.Enums) do if nameM(name) then out[#out + 1] = name end end
	table.sort(out)
	return { enums = out }
end

----------------------------------------------------------------------------------------------------
-- method calls
----------------------------------------------------------------------------------------------------
H.call_method = function(p)
	local inst = B.inst(p.target)
	local method = p.method
	local args = B.deArgs(p.args)
	local fn = inst[method]
	if type(fn) ~= "function" then error(inst.ClassName .. " has no callable method '" .. tostring(method) .. "'", 0) end
	local res = B.pack(fn(inst, B.unpack(args)))
	return { results = B.serPack(res, p), count = res.n }
end

----------------------------------------------------------------------------------------------------
-- compare two instances
----------------------------------------------------------------------------------------------------
H.compare_properties = function(p)
	local a, b = B.inst(p.a), B.inst(p.b)
	local pa, pb = classProps(a.ClassName), classProps(b.ClassName)
	local differing, same = {}, 0
	local names = {}
	for _, pr in ipairs(pa.list) do
		local tags = pr.Tags or {}
		if pb.by[pr.Name] and not tags.Deprecated and (p.include_hidden or not tags.NotScriptable) then names[#names + 1] = pr.Name end
	end
	local skip = {}
	for _, n in ipairs(p.ignore or {}) do skip[n] = true end
	if p.ignore_identity ~= false then skip.Name = true skip.Parent = true end
	local o = { depth = 1, maxItems = 8, maxStr = 200 }
	for _, name in ipairs(names) do
		if not skip[name] then
			local oka, va = readProp(a, name)
			local okb, vb = readProp(b, name)
			if oka and okb then
				local sa = B.json(B.ser(va, o))
				local sb = B.json(B.ser(vb, o))
				if sa == sb then
					same = same + 1
				else
					differing[#differing + 1] = { name = name, type = pa.by[name].ValueType and pa.by[name].ValueType.Name, a = B.ser(va, o), b = B.ser(vb, o) }
				end
			end
		end
	end
	-- attributes
	local aa, ab = a:GetAttributes(), b:GetAttributes()
	local attrDiff = {}
	for k, v in pairs(aa) do
		if B.json(B.ser(v)) ~= B.json(B.ser(ab[k])) then attrDiff[#attrDiff + 1] = { name = k, a = B.ser(v), b = B.ser(ab[k]) } end
	end
	for k, v in pairs(ab) do
		if aa[k] == nil then attrDiff[#attrDiff + 1] = { name = k, a = NULL, b = B.ser(v) } end
	end
	table.sort(differing, function(x, y) return x.name < y.name end)
	table.sort(attrDiff, function(x, y) return x.name < y.name end)
	return { a = B.ser(a), b = B.ser(b), same_count = same, differing = differing, attribute_differences = attrDiff }
end
