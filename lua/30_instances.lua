-- 30_instances: tree navigation, search, lifecycle
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local gm = game

local CollectionService = service.CollectionService

local function isA(inst, cls)
	local ok, r = pcall(inst.IsA, inst, cls)
	return ok and r
end

-- one-line summary used everywhere an instance is listed
local function summ(inst, withCount)
	local out = {
		ref = B.ref(inst),
		class = inst.ClassName,
		name = inst.Name,
	}
	if withCount then
		local ok, kids = pcall(inst.GetChildren, inst)
		if ok then out.children = #kids end
	end
	if isA(inst, "ValueBase") then
		local ok, v = pcall(function() return inst.Value end)
		if ok then out.value = B.ser(v, { depth = 1, maxItems = 8, maxStr = 200 }) end
	elseif isA(inst, "BasePart") then
		local ok, v = pcall(function() return inst.Position end)
		if ok then out.pos = { v.X, v.Y, v.Z } end
	elseif isA(inst, "LuaSourceContainer") then
		local ok, d = pcall(function() return inst.Enabled == nil and inst.Disabled or (inst.Disabled) end)
		if ok then out.disabled = d end
	elseif isA(inst, "GuiObject") then
		local ok, tx = pcall(function() return inst.Text end)
		if ok and type(tx) == "string" then out.text = B.trunc(tx, 80) end
	end
	return out
end
B.summ = summ

function B.instPath(inst)
	local ok, p = pcall(B.pathOf, inst)
	if ok then return p end
	return tostring(inst)
end

H.get_children = function(p)
	local inst = B.inst(p.target or "game")
	local kids = inst:GetChildren()
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local out, matched = {}, 0
	local offset = p.offset or 0
	local limit = p.limit or 200
	for _, k in ipairs(kids) do
		if (not p.class or isA(k, p.class)) and nameM(k.Name) then
			matched = matched + 1
			if matched > offset and #out < limit then
				out[#out + 1] = summ(k, p.counts ~= false and #kids <= 300)
			end
		end
	end
	return {
		parent = B.ser(inst),
		total_children = #kids,
		matched = matched,
		returned = #out,
		next_offset = (offset + #out < matched) and (offset + #out) or nil,
		children = out,
	}
end

-- iterate descendants honoring max_depth; fn returns true to stop
local function walk(root, maxDepth, fn)
	if not maxDepth then
		local list = root:GetDescendants()
		for i, d in ipairs(list) do
			if fn(d, nil) then return end
			if i % 2000 == 0 then B.yield() end
		end
		return
	end
	local stack = { { root, 0 } }
	local visited = 0
	while #stack > 0 do
		local item = table.remove(stack)
		local node, depth = item[1], item[2]
		if depth > 0 then
			if fn(node, depth) then return end
		end
		if depth < maxDepth then
			local kids = node:GetChildren()
			for i = #kids, 1, -1 do stack[#stack + 1] = { kids[i], depth + 1 } end
		end
		visited = visited + 1
		if visited % 2000 == 0 then B.yield() end
	end
end
B.walk = walk

H.get_descendants = function(p)
	local root = B.inst(p.target or "game")
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local out, matched = {}, 0
	local offset = p.offset or 0
	local limit = p.limit or 200
	walk(root, p.max_depth, function(d)
		if (not p.class or (p.class_exact and d.ClassName == p.class) or (not p.class_exact and isA(d, p.class))) and nameM(d.Name) then
			matched = matched + 1
			if matched > offset and #out < limit then
				local s = summ(d, false)
				s.path = B.instPath(d)
				out[#out + 1] = s
			end
		end
	end)
	return {
		root = B.ser(root),
		matched = matched,
		returned = #out,
		next_offset = (offset + #out < matched) and (offset + #out) or nil,
		descendants = out,
	}
end

H.get_tree = function(p)
	local root = B.inst(p.target or "game")
	local depth = p.depth or 3
	local maxNodes = p.max_nodes or 400
	local lines = {}
	local count = 0
	local truncated = false
	local showRefs = p.refs == true
	local classFilter = p.class
	local function label(inst)
		local s = inst.Name .. " [" .. inst.ClassName .. "]"
		if showRefs then s = s .. " #" .. B.ref(inst) end
		return s
	end
	local function rec(node, d, prefix)
		if truncated then return end
		local kids = node:GetChildren()
		local i = 1
		while i <= #kids do
			local k = kids[i]
			if count >= maxNodes then truncated = true return end
			local sub = k:GetChildren()
			if not classFilter or isA(k, classFilter) or #sub > 0 then
				-- collapse runs of identical leaf siblings (e.g. 54 SpawnLocations) into one line
				local run = 1
				if #sub == 0 and not showRefs then
					local nm, cn = k.Name, k.ClassName
					while kids[i + run] and kids[i + run].Name == nm and kids[i + run].ClassName == cn and #kids[i + run]:GetChildren() == 0 do
						run = run + 1
					end
				end
				count = count + 1
				local line = prefix .. label(k)
				if run > 1 then line = line .. "  x" .. run end
				if d >= depth and #sub > 0 then line = line .. "  (+" .. #sub .. " children)" end
				lines[#lines + 1] = line
				if d < depth then rec(k, d + 1, prefix .. "  ") end
				i = i + run - 1
			end
			i = i + 1
			if count % 500 == 0 then B.yield() end
		end
	end
	lines[1] = label(root)
	rec(root, 1, "  ")
	return { tree = table.concat(lines, "\n"), nodes = count, truncated = truncated, root = B.ser(root) }
end

local function propMatch(inst, spec)
	local ok, v = pcall(function() return inst[spec.name] end)
	if not ok then return false end
	if spec.value == nil then return true end
	local want = spec.value
	if type(want) == "table" then want = B.de(want) end
	if type(v) == "string" and type(want) == "string" then
		return B.matcher(want, spec.mode or "plain", spec.case_insensitive ~= false)(v)
	end
	if typeof(v) == typeof(want) then return v == want end
	return tostring(v) == tostring(want)
end

H.find_instances = function(p)
	local root = B.inst(p.root or "game")
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local textM = p.text and B.matcher(p.text, p.text_mode, p.case_insensitive ~= false) or nil
	local limit = p.limit or 100
	local out, matched, scanned = {}, 0, 0

	local function test(d)
		if p.class then
			if p.class_exact then
				if d.ClassName ~= p.class then return false end
			elseif not isA(d, p.class) then
				return false
			end
		end
		if p.name and not nameM(d.Name) then return false end
		if p.tag and not CollectionService:HasTag(d, p.tag) then return false end
		if p.attribute then
			local a = d:GetAttribute(p.attribute.name)
			if a == nil then return false end
			if p.attribute.value ~= nil and tostring(a) ~= tostring(p.attribute.value) then return false end
		end
		if p.property and not propMatch(d, p.property) then return false end
		if p.has_children ~= nil then
			if (#d:GetChildren() > 0) ~= p.has_children then return false end
		end
		if textM then
			local ok, tx = pcall(function() return d.Text end)
			if not ok or type(tx) ~= "string" or not textM(tx) then return false end
		end
		return true
	end

	local function consider(d)
		scanned = scanned + 1
		local ok, res = pcall(test, d)
		if ok and res then
			matched = matched + 1
			if #out < limit then
				local s = summ(d, false)
				s.path = B.instPath(d)
				out[#out + 1] = s
			end
		end
	end

	if p.include_self then consider(root) end
	walk(root, p.max_depth, function(d)
		consider(d)
		return p.stop_at_limit == true and #out >= limit
	end)

	if p.include_nil and C.getnilinstances then
		for _, d in ipairs(C.getnilinstances()) do
			consider(d)
			if p.deep_nil then
				for _, dd in ipairs(d:GetDescendants()) do consider(dd) end
			end
		end
	end

	return { matched = matched, scanned = scanned, returned = #out, truncated = matched > #out, results = out }
end

H.get_instance = function(p)
	local inst = B.inst(p.target)
	local out = {
		ref = B.ref(inst),
		class = inst.ClassName,
		name = inst.Name,
		path = B.instPath(inst),
		full_name = inst:GetFullName(),
	}
	local par = inst.Parent
	out.parent = par and B.ser(par) or NULL
	local kids = inst:GetChildren()
	out.child_count = #kids
	if p.count_descendants ~= false and #kids < 5000 then
		out.descendant_count = #inst:GetDescendants()
	end
	out.archivable = inst.Archivable
	local okid, did = pcall(inst.GetDebugId, inst)
	if okid then out.debug_id = did end
	local attrs = inst:GetAttributes()
	if next(attrs) ~= nil then
		out.attributes = B.obj(B.serWith(attrs, { depth = 2 }).fields or {})
	end
	local tags = CollectionService:GetTags(inst)
	if #tags > 0 then out.tags = tags end
	-- class hierarchy via API dump
	local chain = {}
	local cls = Dex.API.Classes[inst.ClassName]
	while cls do
		chain[#chain + 1] = cls.Name
		cls = cls.Superclass
	end
	out.class_chain = chain
	local s = summ(inst, false)
	out.value = s.value
	out.pos = s.pos
	out.text = s.text
	out.disabled = s.disabled
	if p.children ~= false and #kids > 0 then
		local list = {}
		for i = 1, math.min(#kids, p.max_children or 50) do list[i] = summ(kids[i], false) end
		out.children = list
		if #kids > #list then out.children_truncated = #kids - #list end
	end
	return out
end

H.get_path = function(p)
	local inst = B.inst(p.target)
	local style = p.style or "dex"
	local out = { ref = B.ref(inst), full_name = inst:GetFullName() }
	if style == "dex" and Dex.Apps.Explorer and Dex.Apps.Explorer.GetInstancePath then
		out.path = Dex.Apps.Explorer.GetInstancePath(inst)
	else
		out.path = B.pathOf(inst)
	end
	-- unambiguous variant using child indices
	local parts, cur = {}, inst
	while cur and cur ~= gm do
		local par = cur.Parent
		if not par then break end
		local idx = table.find(par:GetChildren(), cur)
		table.insert(parts, 1, ":GetChildren()[" .. tostring(idx) .. "]")
		cur = par
	end
	if cur == gm then out.index_path = "game" .. table.concat(parts) end
	return out
end

H.resolve_path = function(p)
	local inst, err = B.resolvePath(p.path)
	if not inst then return { found = false, error = err } end
	return { found = true, instance = B.ser(inst), class = inst.ClassName }
end

H.get_ancestors = function(p)
	local inst = B.inst(p.target)
	local out = {}
	local cur = inst.Parent
	while cur do
		out[#out + 1] = { class = cur.ClassName, name = cur.Name, ref = B.ref(cur) }
		cur = cur.Parent
	end
	return { ancestors = out }
end

H.get_services = function(p)
	local out = {}
	for _, c in ipairs(gm:GetChildren()) do
		out[#out + 1] = { class = c.ClassName, name = c.Name, children = #c:GetChildren(), ref = B.ref(c) }
	end
	return { services = out }
end

H.get_nil_instances = function(p)
	local list = B.need("getnilinstances")()
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local out, matched = {}, 0
	local offset, limit = p.offset or 0, p.limit or 200
	for _, d in ipairs(list) do
		if (not p.class or (p.class_exact and d.ClassName == p.class) or (not p.class_exact and isA(d, p.class))) and nameM(d.Name) then
			matched = matched + 1
			if matched > offset and #out < limit then out[#out + 1] = summ(d, true) end
		end
	end
	return { total = #list, matched = matched, returned = #out, next_offset = (offset + #out < matched) and (offset + #out) or nil, instances = out }
end

H.get_all_instances = function(p)
	local list = B.need("getinstances")()
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local out, matched = {}, 0
	local offset, limit = p.offset or 0, p.limit or 200
	for i, d in ipairs(list) do
		if (not p.class or (p.class_exact and d.ClassName == p.class) or (not p.class_exact and isA(d, p.class))) and nameM(d.Name) then
			if not p.nil_only or d.Parent == nil then
				matched = matched + 1
				if matched > offset and #out < limit then
					local s = summ(d, false)
					s.path = B.instPath(d)
					out[#out + 1] = s
				end
			end
		end
		if i % 4000 == 0 then B.yield() end
	end
	return { total = #list, matched = matched, returned = #out, next_offset = (offset + #out < matched) and (offset + #out) or nil, instances = out }
end

H.create_instance = function(p)
	local inst = Instance.new(p.class)
	if p.name then inst.Name = p.name end
	if p.props then B.setProps(inst, p.props) end
	if p.parent then inst.Parent = B.inst(p.parent) end
	return { instance = B.ser(inst) }
end

H.clone_instance = function(p)
	local inst = B.inst(p.target)
	local wasArch = inst.Archivable
	if not wasArch then inst.Archivable = true end
	local c = inst:Clone()
	if not wasArch then inst.Archivable = false end
	if not c then error("Clone returned nil (instance may be non-cloneable)", 0) end
	if p.name then c.Name = p.name end
	if p.parent then c.Parent = B.inst(p.parent) end
	return { instance = B.ser(c) }
end

H.destroy_instance = function(p)
	local inst = B.inst(p.target)
	local desc = B.instPath(inst)
	if p.clear_children then
		inst:ClearAllChildren()
		return { cleared = desc }
	end
	inst:Destroy()
	return { destroyed = desc }
end

H.set_parent = function(p)
	local inst = B.inst(p.target)
	local newParent = nil
	if p.parent ~= nil and p.parent ~= NULL then newParent = B.inst(p.parent) end
	inst.Parent = newParent
	return { instance = B.ser(inst), parent = newParent and B.ser(newParent) or NULL }
end

H.compare_instances = function(p)
	local a, b = B.inst(p.a), B.inst(p.b)
	local same
	if C.compareinstances then same = C.compareinstances(a, b) else same = (a == b) end
	return { same = same, a = B.ser(a), b = B.ser(b) }
end

H.get_debug_id = function(p)
	local inst = B.inst(p.target)
	return { debug_id = inst:GetDebugId(), instance = B.ser(inst) }
end

H.find_by_debug_id = function(p)
	local inst, err = B.findByDebugId(p.debug_id)
	if not inst then return { found = false, error = err } end
	return { found = true, instance = B.ser(inst) }
end

H.get_instance_signals = function(p)
	local inst = B.inst(p.target)
	local events = Dex.API.GetMember(inst.ClassName, "Events") or {}
	local out = {}
	for _, ev in ipairs(events) do
		local entry = { name = ev.Name, class = ev.Class, params = {} }
		for i, par in ipairs(ev.Parameters or {}) do entry.params[i] = par.Name .. ": " .. par.Type end
		if C.getconnections then
			local ok, sig = pcall(function() return inst[ev.Name] end)
			if ok and sig then
				local ok2, conns = pcall(C.getconnections, sig)
				if ok2 then entry.connections = #conns end
			end
		end
		if p.all or (entry.connections and entry.connections > 0) then out[#out + 1] = entry end
	end
	table.sort(out, function(a, b) return a.name < b.name end)
	return { instance = B.ser(inst), signals = out }
end
