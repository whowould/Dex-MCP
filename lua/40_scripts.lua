-- 40_scripts: script discovery, decompile, bytecode, constants, environments, function mapping
local H = B.H
local C = B.C
local Dex = B.Dex
local env = Dex.env
local Settings = Dex.Settings
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local gm = game
local clock = os.clock

-- run fn in its own thread with a timeout; returns ok, result_or_err
function B.timed(fn, timeout)
	local done, ok, res = false, nil, nil
	local th = task.spawn(function()
		ok, res = pcall(fn)
		done = true
	end)
	local t0 = clock()
	while not done and clock() - t0 < timeout do task.wait() end
	if not done then
		pcall(task.cancel, th)
		return false, "timed out after " .. timeout .. "s"
	end
	return ok, res
end

local function isScript(inst)
	local ok, r = pcall(inst.IsA, inst, "LuaSourceContainer")
	return ok and r
end

local function inCore(inst)
	local ok, r = pcall(function()
		return inst:IsDescendantOf(service.CoreGui) or inst:IsDescendantOf(game:GetService("CorePackages"))
	end)
	return ok and r
end

local function scriptSummary(s)
	local out = { ref = B.ref(s), class = s.ClassName, name = s.Name, path = B.instPath(s) }
	local okFn, fullName = pcall(s.GetFullName, s)
	if okFn then out.full_name = fullName end
	local ok, dis = pcall(function() return s.Disabled end)
	if ok and dis ~= nil then out.disabled = dis end
	local ok2, rc = pcall(function() return s.RunContext end)
	if ok2 and rc ~= nil and s.ClassName ~= "ModuleScript" then out.run_context = tostring(rc):gsub("Enum.RunContext.", "") end
	return out
end

-- build a sorted candidate list. opts: root, source (tree|getscripts|running|modules|nil), class, name, include_core, viable_only
local function collect(p)
	local list = {}
	local seen = {}
	local function add(s)
		if not seen[s] and isScript(s) then
			seen[s] = true
			list[#list + 1] = s
		end
	end
	local source = p.source or (C.getscripts and "getscripts" or "tree")
	if source == "tree" then
		local root = B.inst(p.root or "game")
		if isScript(root) then add(root) end
		for i, d in ipairs(root:GetDescendants()) do
			add(d)
			if i % 3000 == 0 then B.yield() end
		end
	elseif source == "getscripts" then
		for _, s in ipairs(B.need("getscripts")()) do add(s) end
	elseif source == "running" then
		for _, s in ipairs(B.need("getrunningscripts")()) do add(s) end
	elseif source == "modules" then
		for _, s in ipairs(B.need("getloadedmodules")()) do add(s) end
	elseif source == "nil" then
		for _, s in ipairs(B.need("getnilinstances")()) do
			add(s)
			for _, d in ipairs(s:GetDescendants()) do add(d) end
		end
	else
		error("unknown source '" .. tostring(source) .. "'", 0)
	end
	local nameM = B.matcher(p.name, p.name_mode, p.case_insensitive ~= false)
	local filtered = {}
	local rootInst = (p.root and source ~= "tree") and B.inst(p.root) or nil
	for _, s in ipairs(list) do
		local keep = true
		if p.class and not s:IsA(p.class) then keep = false end
		if keep and p.name and not nameM(s.Name) then keep = false end
		if keep and not p.include_core and inCore(s) then keep = false end
		if keep and p.viable_only and env.isViableDecompileScript and not env.isViableDecompileScript(s) then keep = false end
		if keep and rootInst and not (s == rootInst or s:IsDescendantOf(rootInst)) then keep = false end
		if keep then filtered[#filtered + 1] = s end
	end
	-- stable order so paging/resume works
	local keyOf = {}
	for _, s in ipairs(filtered) do
		local ok, fn = pcall(s.GetFullName, s)
		keyOf[s] = (ok and fn or s.Name) .. "\0" .. s.ClassName
	end
	table.sort(filtered, function(a, b) return keyOf[a] < keyOf[b] end)
	return filtered
end
B.collectScripts = collect

H.list_scripts = function(p)
	local list = collect(p)
	local offset, limit = p.offset or 0, p.limit or 200
	local out = {}
	for i = offset + 1, math.min(#list, offset + limit) do
		local entry = scriptSummary(list[i])
		if p.with_hash and C.getscripthash then
			local ok, h = pcall(C.getscripthash, list[i])
			if ok then entry.hash = h end
		end
		out[#out + 1] = entry
	end
	return { total = #list, returned = #out, next_offset = (offset + #out < #list) and (offset + #out) or nil, scripts = out }
end

----------------------------------------------------------------------------------------------------
-- decompile
----------------------------------------------------------------------------------------------------
local cache = setmetatable({}, { __mode = "k" })

local ENGINES = { konstant = "Konstant", shiny = "Shiny", advanced = "AdvancedDecompiler" }

local function decompileOne(scr, engine, useCache)
	local hash
	if C.getscripthash then
		local ok, h = pcall(C.getscripthash, scr)
		if ok then hash = h end
	end
	engine = engine or "dex"
	local ck = engine
	if useCache ~= false then
		local c = cache[scr]
		if c and c[ck] and (hash == nil or c[ck].hash == hash) then
			return true, c[ck].src, true
		end
	end
	local ok, res
	if engine == "builtin" then
		local dec = C.decompile or error("executor has no native decompile", 0)
		ok, res = pcall(dec, scr)
	elseif ENGINES[engine] then
		local d = Settings.Decompiler
		local oldFb, oldPref = d.DecompilerFallback, d.PreferDecompilerFallback
		d.DecompilerFallback = ENGINES[engine]
		d.PreferDecompilerFallback = true
		ok, res = pcall(env.decompile, scr)
		d.DecompilerFallback, d.PreferDecompilerFallback = oldFb, oldPref
	else
		ok, res = pcall(env.decompile, scr)
	end
	if not ok then return false, tostring(res) end
	if type(res) ~= "string" then return false, "decompiler returned " .. typeof(res) end
	cache[scr] = cache[scr] or {}
	cache[scr][ck] = { src = res, hash = hash }
	return true, res, false
end
B.decompileOne = decompileOne

-- decompile with a hard timeout; returns ok, src_or_err, cached
local function decompileTimed(scr, engine, timeout, useCache)
	local ok, res = B.timed(function()
		return B.pack(decompileOne(scr, engine, useCache))
	end, timeout or 30)
	if not ok then return false, tostring(res) end
	if not res[1] then return false, tostring(res[2]) end
	return true, res[2], res[3]
end
B.decompileTimed = decompileTimed

H.decompile_script = function(p)
	local scr = B.inst(p.target)
	if not isScript(scr) then error(scr.ClassName .. " is not a script", 0) end
	local t0 = clock()
	local ok, src, cached = decompileTimed(scr, p.engine, p.timeout or 45, p.use_cache)
	if not ok then error("decompile failed: " .. tostring(src), 0) end
	local offset = p.offset or 0
	local limit = p.max_chars or 60000
	local total = #src
	local chunk = src:sub(offset + 1, offset + limit)
	return {
		script = scriptSummary(scr),
		cached = cached,
		elapsed = clock() - t0,
		total_chars = total,
		total_lines = select(2, src:gsub("\n", "\n")) + 1,
		offset = offset,
		returned_chars = #chunk,
		next_offset = (offset + #chunk < total) and (offset + #chunk) or nil,
		source = chunk,
	}
end

H.get_script_source = function(p)
	local scr = B.inst(p.target)
	local ok, src = pcall(function() return scr.Source end)
	if ok and type(src) == "string" and src ~= "" then
		return { source = src, via = "Source" }
	end
	local a, b = decompileTimed(scr, p.engine, 30, true)
	if a then return { source = b, via = "decompile" } end
	error("no source available (Source empty; decompile: " .. tostring(b) .. ")", 0)
end

H.set_decompiler = function(p)
	local d = Settings.Decompiler
	if p.engine then
		local map = { konstant = "Konstant", shiny = "Shiny", advanced = "AdvancedDecompiler" }
		local v = map[p.engine:lower()] or p.engine
		d.DecompilerFallback = v
	end
	if p.prefer_fallback ~= nil then d.PreferDecompilerFallback = p.prefer_fallback end
	if p.shiny_port then d.ShinyDecompilerPort = p.shiny_port end
	if Dex.Main.SaveCurrentSettings and p.save then Dex.Main.SaveCurrentSettings() end
	return {
		fallback = d.DecompilerFallback,
		prefer_fallback = d.PreferDecompilerFallback,
		shiny_port = d.ShinyDecompilerPort,
		native_decompile = C.decompile ~= nil,
		getscriptbytecode = C.getscriptbytecode ~= nil,
	}
end

----------------------------------------------------------------------------------------------------
-- bytecode / hash / info
----------------------------------------------------------------------------------------------------
H.get_script_bytecode = function(p)
	local scr = B.inst(p.target)
	local f = B.need("getscriptbytecode")
	local bc = f(scr)
	if type(bc) ~= "string" then error("getscriptbytecode returned " .. typeof(bc), 0) end
	if #bc == 0 then error("script has no bytecode (empty): it was created by the executor/Dex++ or is stripped, so there is nothing to disassemble", 0) end
	local out = { size = #bc, script = scriptSummary(scr) }
	if C.getscripthash then
		local ok, h = pcall(C.getscripthash, scr)
		if ok then out.hash = h end
	end
	local offset = p.offset or 0
	local maxBytes = p.max_bytes or 1000000
	local chunk = bc:sub(offset + 1, offset + maxBytes)
	out.offset = offset
	out.returned = #chunk
	out.next_offset = (offset + #chunk < #bc) and (offset + #chunk) or nil
	if p.format == "hex" then out.hex = B.hex(chunk) else out.base64 = B.b64encode(chunk) end
	return out
end

H.get_script_hash = function(p)
	local scr = B.inst(p.target)
	local f = B.need("getscripthash")
	return { hash = f(scr), script = scriptSummary(scr) }
end

H.get_script_info = function(p)
	local scr = B.inst(p.target)
	local out = scriptSummary(scr)
	out.viable_decompile = env.isViableDecompileScript and env.isViableDecompileScript(scr) or nil
	if C.getscripthash then
		local ok, h = pcall(C.getscripthash, scr)
		if ok then out.hash = h end
	end
	if C.getscriptbytecode then
		local ok, bc = pcall(C.getscriptbytecode, scr)
		if ok and type(bc) == "string" then out.bytecode_size = #bc end
	end
	if scr.ClassName == "ModuleScript" and C.getloadedmodules then
		local ok, mods = pcall(C.getloadedmodules)
		if ok then
			for _, m in ipairs(mods) do if m == scr then out.loaded = true break end end
		end
	end
	if C.getrunningscripts then
		local ok, running = pcall(C.getrunningscripts)
		if ok then
			for _, m in ipairs(running) do if m == scr then out.running = true break end end
		end
	end
	local okl, linked = pcall(function() return scr.LinkedSource end)
	if okl and linked and linked ~= "" then out.linked_source = linked end
	if C.getscriptclosure then
		local ok, cl = pcall(C.getscriptclosure, scr)
		if ok and cl then out.closure = B.ser(cl) end
	end
	return out
end

----------------------------------------------------------------------------------------------------
-- grep over decompiled sources
----------------------------------------------------------------------------------------------------
local function grepSource(src, matchFn, ctx, maxHits)
	local hits = {}
	local lines = {}
	for line in (src .. "\n"):gmatch("(.-)\r?\n") do lines[#lines + 1] = line end
	for i, line in ipairs(lines) do
		if matchFn(line) then
			local h = { line = i, text = B.trunc(line, 240) }
			if ctx > 0 then
				local before, after = {}, {}
				for j = math.max(1, i - ctx), i - 1 do before[#before + 1] = B.trunc(lines[j], 200) end
				for j = i + 1, math.min(#lines, i + ctx) do after[#after + 1] = B.trunc(lines[j], 200) end
				h.before, h.after = before, after
			end
			hits[#hits + 1] = h
			if #hits >= maxHits then break end
		end
	end
	return hits, #lines
end

H.search_scripts = function(p)
	if not p.pattern or p.pattern == "" then error("pattern is required", 0) end
	local list = collect(p)
	local matchFn = B.matcher(p.pattern, p.mode or "plain", p.case_insensitive ~= false)
	local ctx = p.context or 0
	local maxResults = p.max_results or 50
	local budget = p.time_budget or 25
	local t0 = clock()
	local start = p.start_index or 1
	local results, scanned, failed, totalHits = {}, 0, {}, 0
	local nextIndex = nil
	for i = start, #list do
		if clock() - t0 > budget then nextIndex = i break end
		local scr = list[i]
		local a, b = decompileTimed(scr, p.engine, p.decompile_timeout or 20, true)
		scanned = scanned + 1
		if a then
			local hits, nlines = grepSource(b, matchFn, ctx, p.max_hits_per_script or 10)
			if #hits > 0 then
				totalHits = totalHits + #hits
				results[#results + 1] = { script = scriptSummary(scr), lines = nlines, hits = hits }
				if #results >= maxResults then nextIndex = i + 1 break end
			end
		else
			failed[#failed + 1] = { path = B.instPath(scr), error = B.trunc(tostring(b), 120) }
		end
		B.yield()
	end
	if nextIndex and nextIndex > #list then nextIndex = nil end
	return {
		candidates = #list,
		scanned = scanned,
		scripts_with_hits = #results,
		total_hits = totalHits,
		partial = nextIndex ~= nil,
		next_start_index = nextIndex,
		failed_count = #failed,
		failed_sample = { unpack(failed, 1, 10) },
		elapsed = clock() - t0,
		results = results,
	}
end

----------------------------------------------------------------------------------------------------
-- constants (no decompiler needed): walk closure + protos
----------------------------------------------------------------------------------------------------
local function walkProtos(fn, visit, depth, state)
	state.count = state.count or 0
	if depth > (state.maxDepth or 10) or state.count > (state.maxNodes or 4000) then return end
	state.count = state.count + 1
	visit(fn, depth)
	if C.getprotos then
		local ok, protos = pcall(C.getprotos, fn)
		if ok and type(protos) == "table" then
			for _, pr in ipairs(protos) do walkProtos(pr, visit, depth + 1, state) end
		end
	end
end

local function closureOf(scr)
	local f = B.need("getscriptclosure")
	local ok, cl = pcall(f, scr)
	if not ok or type(cl) ~= "function" then return nil end
	return cl
end

local function constantsOf(fn)
	if not C.getconstants then return {} end
	local ok, cs = pcall(C.getconstants, fn)
	if ok and type(cs) == "table" then return cs end
	return {}
end

H.get_script_strings = function(p)
	local scr = B.inst(p.target)
	local cl = closureOf(scr)
	if not cl then error("could not get the script's closure (getscriptclosure failed): the script has no bytecode, is executor-created, or is not loadable. Try decompile_script or get_script_functions instead.", 0) end
	local matchFn = p.pattern and B.matcher(p.pattern, p.mode or "plain", p.case_insensitive ~= false) or function() return true end
	local minLen = p.min_length or 1
	local funcs = {}
	local all, seen = {}, {}
	walkProtos(cl, function(fn, depth)
		local info = B.funcInfo(fn)
		local strs = {}
		for _, c in pairs(constantsOf(fn)) do
			if type(c) == "string" and #c >= minLen and matchFn(c) then
				strs[#strs + 1] = B.trunc(c, 300)
				if not seen[c] then seen[c] = true all[#all + 1] = B.trunc(c, 300) end
			elseif p.include_numbers and type(c) == "number" then
				strs[#strs + 1] = c
			end
		end
		if #strs > 0 or p.include_empty then
			funcs[#funcs + 1] = { name = info.name, line = info.line, depth = depth, numparams = info.numparams, nups = info.nups, constants = strs }
		end
	end, 0, { maxDepth = p.max_depth or 10, maxNodes = 4000 })
	table.sort(all)
	return { script = scriptSummary(scr), unique_strings = all, functions = funcs, string_count = #all }
end

H.search_constants = function(p)
	if not p.pattern then error("pattern is required", 0) end
	local list = collect(p)
	local matchFn = B.matcher(p.pattern, p.mode or "plain", p.case_insensitive ~= false)
	local budget = p.time_budget or 25
	local t0 = clock()
	local results, scanned = {}, 0
	local nextIndex
	for i = (p.start_index or 1), #list do
		if clock() - t0 > budget then nextIndex = i break end
		local scr = list[i]
		scanned = scanned + 1
		local cl = C.getscriptclosure and closureOf(scr)
		if cl then
			local hits = {}
			walkProtos(cl, function(fn)
				for _, c in pairs(constantsOf(fn)) do
					if type(c) == "string" and matchFn(c) then
						hits[#hits + 1] = { constant = B.trunc(c, 200), fn = B.funcInfo(fn).name, line = B.funcInfo(fn).line }
						if #hits >= (p.max_hits_per_script or 15) then return end
					end
				end
			end, 0, { maxDepth = 10, maxNodes = 3000 })
			if #hits > 0 then
				results[#results + 1] = { script = scriptSummary(scr), hits = hits }
				if #results >= (p.max_results or 50) then nextIndex = i + 1 break end
			end
		end
		B.yield()
	end
	if nextIndex and nextIndex > #list then nextIndex = nil end
	return { candidates = #list, scanned = scanned, partial = nextIndex ~= nil, next_start_index = nextIndex, elapsed = clock() - t0, results = results }
end

----------------------------------------------------------------------------------------------------
-- environments / closures / module returns
----------------------------------------------------------------------------------------------------
H.get_script_env = function(p)
	local scr = B.inst(p.target)
	local okEnv, senv = pcall(B.need("getsenv"), scr)
	if not okEnv then
		error("getsenv failed: " .. tostring(senv) .. " (getsenv only works on scripts that are currently running; try get_script_functions or require_module for a ModuleScript)", 0)
	end
	if type(senv) ~= "table" then error("getsenv returned " .. typeof(senv), 0) end
	local matchFn = p.filter and B.matcher(p.filter, p.mode or "plain", true) or nil
	local fields, n, total = {}, 0, 0
	local limit = p.max_items or 150
	local o = { depth = p.depth or 1, maxItems = 20, maxStr = 300 }
	local keys = {}
	for k in pairs(senv) do keys[#keys + 1] = k end
	table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
	for _, k in ipairs(keys) do
		if not matchFn or matchFn(tostring(k)) then
			total = total + 1
			if n < limit then
				n = n + 1
				local sv = B.ser(rawget(senv, k), o, 1)
				if sv == nil then sv = NULL end
				fields[tostring(k)] = sv
			end
		end
	end
	return { script = scriptSummary(scr), env_ref = B.ref(senv), total = total, returned = n, env = B.obj(fields) }
end

H.get_script_closure = function(p)
	local scr = B.inst(p.target)
	local f = B.need("getscriptclosure")
	local cl = f(scr)
	return { closure = B.ser(cl), info = B.funcInfo(cl) }
end

H.require_module = function(p)
	local scr = B.inst(p.target)
	if scr.ClassName ~= "ModuleScript" then error("target is not a ModuleScript", 0) end
	local ok, res = B.timed(function() return B.pack(require(scr)) end, p.timeout or 15)
	if not ok then error("require failed: " .. tostring(res), 0) end
	return { script = scriptSummary(scr), results = B.serPack(res, { depth = p.depth or 2, maxItems = p.max_items or 80, maxStr = 500 }) }
end

-- functions defined by a script (via GC scan on function environment)
H.get_script_functions = function(p)
	local scr = B.inst(p.target)
	local getgc = B.need("getgc")
	local nameM = B.matcher(p.name, p.name_mode, true)
	local out, total = {}, 0
	local limit = p.limit or 100
	local ig = getgc(true)
	for i, f in ipairs(ig) do
		if type(f) == "function" then
			local ok, fe = pcall(getfenv, f)
			if ok and type(fe) == "table" and rawget(fe, "script") == scr then
				local isExec = false
				if C.isexecutorclosure then
					local ok2, r = pcall(C.isexecutorclosure, f)
					isExec = ok2 and r
				end
				if not isExec then
					local info = B.funcInfo(f)
					if nameM(info.name or "") then
						total = total + 1
						if #out < limit then
							local e = { ref = B.ref(f), name = info.name, line = info.line, numparams = info.numparams, nups = info.nups, is_vararg = info.is_vararg }
							if p.with_constants and C.getconstants then
								local strs = {}
								for _, c in pairs(constantsOf(f)) do
									if type(c) == "string" then strs[#strs + 1] = B.trunc(c, 80) end
									if #strs >= 12 then break end
								end
								e.string_constants = strs
							end
							out[#out + 1] = e
						end
					end
				end
			end
		end
		if i % 5000 == 0 then B.yield() end
	end
	table.sort(out, function(a, b) return (a.line or 0) < (b.line or 0) end)
	return { script = scriptSummary(scr), total = total, returned = #out, functions = out }
end

----------------------------------------------------------------------------------------------------
-- dump all scripts to the executor workspace
----------------------------------------------------------------------------------------------------
local function safeName(s)
	return (tostring(s):gsub("[^%w_%-%. ]", "_")):sub(1, 90)
end

H.dump_scripts = function(p)
	local wf, mk = B.need("writefile"), B.need("makefolder")
	local list = collect(p)
	local base = p.folder or ("dexmcp_dump_" .. tostring(game.PlaceId))
	pcall(mk, base)
	local budget = p.time_budget or 40
	local t0 = clock()
	local written, failed = 0, {}
	local nextIndex
	local used = {}
	for i = (p.start_index or 1), #list do
		if clock() - t0 > budget then nextIndex = i break end
		local scr = list[i]
		local a, b = decompileTimed(scr, p.engine, p.decompile_timeout or 20, true)
		if a then
			local parts = {}
			local cur = scr
			while cur and cur ~= gm do
				table.insert(parts, 1, safeName(cur.Name))
				cur = cur.Parent
			end
			local rel = table.concat(parts, "/", 1, math.max(1, #parts - 1))
			-- create folders progressively
			local acc = base
			for j = 1, #parts - 1 do
				acc = acc .. "/" .. parts[j]
				pcall(mk, acc)
			end
			local fname = acc .. "/" .. parts[#parts] .. "." .. scr.ClassName .. ".lua"
			if used[fname] then
				used[fname] = used[fname] + 1
				fname = acc .. "/" .. parts[#parts] .. "_" .. used[fname] .. "." .. scr.ClassName .. ".lua"
			else
				used[fname] = 1
			end
			local wok, werr = pcall(wf, fname, "-- " .. B.instPath(scr) .. "\n" .. b)
			if wok then written = written + 1 else failed[#failed + 1] = { path = fname, error = tostring(werr) } end
		else
			failed[#failed + 1] = { path = B.instPath(scr), error = B.trunc(tostring(b), 120) }
		end
		B.yield()
	end
	if nextIndex and nextIndex > #list then nextIndex = nil end
	return {
		folder = base,
		candidates = #list,
		written = written,
		failed_count = #failed,
		failed_sample = { unpack(failed, 1, 10) },
		partial = nextIndex ~= nil,
		next_start_index = nextIndex,
		elapsed = clock() - t0,
	}
end
