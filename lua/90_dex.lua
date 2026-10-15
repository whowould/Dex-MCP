-- 90_dex: Dex++ integration (selection, explorer search, notepad, settings, apps, SaveInstance, 3D viewer)
local H = B.H
local C = B.C
local Dex = B.Dex
local env = Dex.env
local NULL = B.NULL
local typeof = typeof or type

local function apps() return Dex.Apps end

H.dex_get_selection = function(p)
	local out = {}
	local sel = Dex.getSelection and Dex.getSelection()
	if not sel then return { selection = {}, note = "Explorer not initialised" } end
	for _, node in ipairs(sel.List) do
		local obj = node.Obj
		if obj then
			local s = B.summ(obj, true)
			s.path = B.instPath(obj)
			out[#out + 1] = s
		end
	end
	return { count = #out, selection = out }
end

H.dex_set_selection = function(p)
	local sel = Dex.getSelection and Dex.getSelection()
	local nodes = Dex.getNodes and Dex.getNodes()
	if not sel or not nodes then error("Explorer not initialised", 0) end
	local list, missing = {}, {}
	for _, spec in ipairs(p.targets or { p.target }) do
		local inst = B.inst(spec)
		local node = nodes[inst]
		if node then list[#list + 1] = node else missing[#missing + 1] = B.instPath(inst) end
	end
	sel:SetTable(list)
	if p.view ~= false and #list > 0 and apps().Explorer then
		apps().Explorer.ViewNode(list[#list])
	end
	return { selected = #list, not_in_explorer = missing }
end

H.dex_clear_selection = function(p)
	local sel = Dex.getSelection and Dex.getSelection()
	if sel then sel:Clear() end
	return { ok = true }
end

H.dex_view_object = function(p)
	local inst = B.inst(p.target)
	local ex = apps().Explorer
	if not ex then error("Explorer not loaded", 0) end
	ex.ViewObj(inst)
	return { ok = true }
end

H.dex_search = function(p)
	local ex = apps().Explorer
	if not ex then error("Explorer not loaded", 0) end
	local box = ex.GuiElems and ex.GuiElems.SearchBar
	if box then box.Text = p.query or "" end
	ex.DoSearch(p.query or "")
	return { ok = true, query = p.query }
end

H.dex_clear_search = function(p)
	local ex = apps().Explorer
	if not ex then error("Explorer not loaded", 0) end
	ex.ClearSearch()
	ex.DoSearch("")
	return { ok = true }
end

H.dex_open_script = function(p)
	local sv = apps().ScriptViewer
	if not sv then error("ScriptViewer not loaded", 0) end
	sv.ViewScript(B.inst(p.target))
	return { ok = true }
end

H.dex_dump_functions = function(p)
	local sv = apps().ScriptViewer
	if not sv then error("ScriptViewer not loaded", 0) end
	sv.DumpFunctions(B.inst(p.target))
	return { ok = true, note = "dump appended to the Notepad window" }
end

H.dex_view_model = function(p)
	local mv = apps().ModelViewer
	if not mv then error("ModelViewer not loaded", 0) end
	mv.ViewModel(B.inst(p.target))
	return { ok = true }
end

H.dex_list_apps = function(p)
	local out = {}
	for name, ctl in pairs(Dex.Main.MenuApps) do out[#out + 1] = name end
	table.sort(out)
	return { apps = out }
end

H.dex_toggle_app = function(p)
	local ctl = Dex.Main.MenuApps[p.name]
	if not ctl then error("unknown app '" .. tostring(p.name) .. "'", 0) end
	if p.open == false then ctl.Disable() else ctl.Enable() end
	return { ok = true }
end

H.dex_open_ui = function(p)
	Dex.Main.SetMainGuiOpen(p.open ~= false)
	return { ok = true }
end

H.dex_get_settings = function(p)
	local function copy(t, depth)
		local out = {}
		for k, v in pairs(t) do
			if type(v) == "table" then
				if depth < 3 then out[k] = copy(v, depth + 1) end
			else
				out[k] = B.ser(v, { depth = 0 })
			end
		end
		return B.obj(out)
	end
	local s = Dex.Settings
	if p.section then
		local sec = s[p.section]
		if sec == nil then error("no settings section '" .. p.section .. "'", 0) end
		return { section = p.section, settings = type(sec) == "table" and copy(sec, 1) or B.ser(sec) }
	end
	local names = {}
	for k, v in pairs(s) do names[#names + 1] = k end
	table.sort(names)
	return { sections = names, settings = copy(s, 0) }
end

H.dex_set_setting = function(p)
	local path = p.path
	local parts = {}
	for seg in path:gmatch("[^%.]+") do parts[#parts + 1] = seg end
	if #parts == 0 then error("path required, e.g. Explorer.Sorting", 0) end
	local cur = Dex.Settings
	for i = 1, #parts - 1 do
		cur = cur[parts[i]]
		if type(cur) ~= "table" then error("no settings path " .. table.concat(parts, ".", 1, i), 0) end
	end
	local key = parts[#parts]
	local old = cur[key]
	local val = B.de(p.value)
	-- keep type of existing value when possible (Color3 etc come through $t tags)
	cur[key] = val
	if p.save then Dex.Main.SaveCurrentSettings() end
	return { path = path, previous = B.ser(old, { depth = 1 }), value = B.ser(val, { depth = 1 }), saved = p.save == true }
end

H.dex_save_settings = function(p)
	Dex.Main.SaveCurrentSettings()
	return { ok = true }
end

H.dex_reinit = function(p)
	task.defer(function() Dex.Main.Reinit() end)
	return { ok = true, note = "Dex++ is reinitialising; the bridge will reconnect" }
end

H.save_instance = function(p)
	local si = env.saveinstance
	if not si then error("executor has no saveinstance", 0) end
	local target = p.target and B.inst(p.target) or game
	local opts = p.options or {}
	if opts.Decompile == nil then opts.Decompile = true end
	local filename = p.filename or ("Place_" .. game.PlaceId .. "_" .. os.time())
	local rec = { done = false, started = os.clock() }
	B.saveStatus = rec
	task.spawn(function()
		local ok, err = pcall(si, target, filename, opts)
		rec.done = true
		rec.ok = ok
		rec.error = (not ok) and tostring(err) or nil
		rec.finished = os.clock()
	end)
	local t0 = os.clock()
	local wait = p.wait or 5
	while not rec.done and os.clock() - t0 < wait do task.wait(0.1) end
	return { filename = filename, done = rec.done, ok = rec.ok, error = rec.error, note = (not rec.done) and "still saving; poll save_instance_status" or nil }
end

H.save_instance_status = function(p)
	local rec = B.saveStatus
	if not rec then return { running = false } end
	return { running = not rec.done, ok = rec.ok, error = rec.error, elapsed = (rec.finished or os.clock()) - rec.started }
end

H.dex_console_print = function(p)
	local con = apps().Console
	if con and con.Print then
		con.Print(p.text)
		return { ok = true }
	end
	print(p.text)
	return { ok = true, via = "print" }
end
