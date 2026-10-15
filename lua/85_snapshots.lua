-- 85_snapshots: instance-tree and property snapshots with diffing ("what changed when I did X?")
local H = B.H
local C = B.C
local NULL = B.NULL
local typeof = typeof or type

local treeSnaps = {}
local propSnaps = {}

local function propString(inst, prop)
	local ok, v = pcall(function() return inst[prop] end)
	if not ok then return "<unreadable>" end
	local s = B.json(B.ser(v, { depth = 1, maxItems = 8, maxStr = 120 }))
	if #s > 240 then s = s:sub(1, 240) end
	return s
end

local function scan(root, depth, props, limit)
	local items, order = {}, {}
	local n = 0
	local function add(inst)
		n = n + 1
		local id
		local ok, did = pcall(inst.GetDebugId, inst)
		id = ok and did or tostring(inst)
		local item = { id = id, path = B.instPath(inst), class = inst.ClassName, name = inst.Name }
		if props and #props > 0 then
			local pv = {}
			for _, pn in ipairs(props) do pv[pn] = propString(inst, pn) end
			item.props = pv
		end
		items[id] = item
		order[#order + 1] = id
	end
	add(root)
	B.walk(root, depth, function(d)
		if n >= limit then return true end
		add(d)
	end)
	return items, order, n >= limit
end

H.snapshot_tree = function(p)
	local root = B.inst(p.root or "game")
	local name = p.name or "default"
	local limit = p.limit or 300000
	local items, order, capped = scan(root, p.max_depth, p.props, limit)
	treeSnaps[name] = { root = root, depth = p.max_depth, props = p.props, limit = limit, items = items, order = order, at = B.now() }
	return { name = name, instances = #order, capped = capped, root = B.instPath(root) }
end

local function diffItems(a, b, props, limit)
	local added, removed, changed = {}, {}, {}
	local nAdded, nRemoved, nChanged = 0, 0, 0
	for id, it in pairs(b) do
		local old = a[id]
		if not old then
			nAdded = nAdded + 1
			if #added < limit then added[#added + 1] = { path = it.path, class = it.class } end
		else
			local diffs = {}
			if old.path ~= it.path then diffs.path = { from = old.path, to = it.path } end
			if old.name ~= it.name then diffs.name = { from = old.name, to = it.name } end
			if props and old.props and it.props then
				for pn, pv in pairs(it.props) do
					if old.props[pn] ~= pv then diffs[pn] = { from = old.props[pn], to = pv } end
				end
			end
			if next(diffs) ~= nil then
				nChanged = nChanged + 1
				if #changed < limit then changed[#changed + 1] = { path = it.path, class = it.class, changes = B.obj(diffs) } end
			end
		end
	end
	for id, it in pairs(a) do
		if not b[id] then
			nRemoved = nRemoved + 1
			if #removed < limit then removed[#removed + 1] = { path = it.path, class = it.class } end
		end
	end
	local sortFn = function(x, y) return x.path < y.path end
	table.sort(added, sortFn) table.sort(removed, sortFn) table.sort(changed, sortFn)
	return {
		added_count = nAdded, removed_count = nRemoved, changed_count = nChanged,
		added = added, removed = removed, changed = changed,
	}
end

H.diff_tree_snapshot = function(p)
	local name = p.name or "default"
	local snap = treeSnaps[name]
	if not snap then error("no tree snapshot '" .. name .. "'", 0) end
	local other
	if p.against then
		local o = treeSnaps[p.against]
		if not o then error("no tree snapshot '" .. p.against .. "'", 0) end
		other = o.items
	else
		local root = snap.root
		other = scan(root, snap.depth, snap.props, snap.limit)
	end
	local res = diffItems(snap.items, other, snap.props, p.limit or 100)
	if p.update and not p.against then
		local items, order = scan(snap.root, snap.depth, snap.props, snap.limit)
		snap.items, snap.order = items, order
	end
	return res
end

H.snapshot_properties = function(p)
	local inst = B.inst(p.target)
	local name = p.name or "default"
	local info = B.classProps(inst.ClassName)
	local values = {}
	for _, pr in ipairs(info.list) do
		local tags = pr.Tags or {}
		if not tags.Deprecated and (p.include_hidden or not tags.NotScriptable) then
			values[pr.Name] = propString(inst, pr.Name)
		end
	end
	for k, v in pairs(inst:GetAttributes()) do values["@" .. k] = B.json(B.ser(v, { depth = 1 })) end
	propSnaps[name] = { inst = inst, values = values, include_hidden = p.include_hidden }
	return { name = name, properties = B.count(values) }
end

H.diff_properties = function(p)
	local name = p.name or "default"
	local snap = propSnaps[name]
	if not snap then error("no property snapshot '" .. name .. "'", 0) end
	local inst = snap.inst
	local info = B.classProps(inst.ClassName)
	local now = {}
	for _, pr in ipairs(info.list) do
		local tags = pr.Tags or {}
		if not tags.Deprecated and (snap.include_hidden or not tags.NotScriptable) then
			now[pr.Name] = propString(inst, pr.Name)
		end
	end
	for k, v in pairs(inst:GetAttributes()) do now["@" .. k] = B.json(B.ser(v, { depth = 1 })) end
	local changes = {}
	for k, v in pairs(now) do
		if snap.values[k] ~= v then changes[k] = { from = snap.values[k], to = v } end
	end
	for k, v in pairs(snap.values) do
		if now[k] == nil then changes[k] = { from = v, to = NULL } end
	end
	if p.update then snap.values = now end
	return { instance = B.ser(inst), changed_count = B.count(changes), changes = B.obj(changes) }
end

H.list_snapshots = function(p)
	local trees, props = {}, {}
	for name, s in pairs(treeSnaps) do trees[#trees + 1] = { name = name, instances = #s.order, root = B.instPath(s.root) } end
	for name, s in pairs(propSnaps) do props[#props + 1] = { name = name, properties = B.count(s.values) } end
	return { tree_snapshots = trees, property_snapshots = props }
end

H.delete_snapshot = function(p)
	local name = p.name or "default"
	local was = treeSnaps[name] ~= nil or propSnaps[name] ~= nil
	treeSnaps[name] = nil
	propSnaps[name] = nil
	return { deleted = was }
end
