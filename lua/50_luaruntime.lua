-- 50_luaruntime: closures (upvalues/constants/protos), GC scanning, tables, metatables, connections, environments
local H = B.H
local C = B.C
local Dex = B.Dex
local NULL = B.NULL
local typeof = typeof or type
local clock = os.clock

local function funcArg(p, key)
	return B.func(p[key or "ref"] or p.target or p["function"])
end

----------------------------------------------------------------------------------------------------
-- closures
----------------------------------------------------------------------------------------------------
H.get_function_info = function(p)
	local f = funcArg(p)
	local info = B.funcInfo(f)
	info.ref = B.ref(f)
	if C.getfunctionhash then
		local ok, h = pcall(C.getfunctionhash, f)
		if ok then info.hash = h end
	end
	if C.getupvalues then
		local ok, ups = pcall(C.getupvalues, f)
		if ok and type(ups) == "table" then info.upvalue_count = B.count(ups) end
	end
	if C.getconstants then
		local ok, cs = pcall(C.getconstants, f)
		if ok and type(cs) == "table" then info.constant_count = B.count(cs) end
	end
	if C.getprotos then
		local ok, ps = pcall(C.getprotos, f)
		if ok and type(ps) == "table" then info.proto_count = #ps end
	end
	local ok, fe = pcall(getfenv, f)
	if ok and type(fe) == "table" then
		local scr = rawget(fe, "script")
		if typeof(scr) == "Instance" then info.script = B.ser(scr) end
	end
	return info
end

H.get_upvalues = function(p)
	local f = funcArg(p)
	local ups = B.need("getupvalues")(f)
	local out = {}
	local o = { depth = p.depth or 1, maxItems = p.max_items or 20, maxStr = p.max_str or 500 }
	local keys = {}
	for k in pairs(ups) do keys[#keys + 1] = k end
	table.sort(keys)
	for _, k in ipairs(keys) do
		local sv = B.ser(ups[k], o, 0)
		if sv == nil then sv = NULL end
		out[#out + 1] = { index = k, value = sv }
	end
	return { count = #out, upvalues = out }
end

H.set_upvalue = function(p)
	local f = funcArg(p)
	local val = B.de(p.value)
	B.need("setupvalue")(f, p.index, val)
	local ok, v = pcall(B.need("getupvalue"), f, p.index)
	return { ok = true, new_value = ok and B.ser(v, { depth = 1 }) or NULL }
end

H.get_constants = function(p)
	local f = funcArg(p)
	local cs = B.need("getconstants")(f)
	local out = {}
	local keys = {}
	for k in pairs(cs) do keys[#keys + 1] = k end
	table.sort(keys)
	local limit = p.limit or 500
	for _, k in ipairs(keys) do
		local v = cs[k]
		if #out < limit and (not p.type or typeof(v) == p.type) then
			local sv
			if v == nil then sv = NULL else sv = B.ser(v, { depth = 1, maxStr = 300 }) end
			out[#out + 1] = { index = k, value = sv, type = typeof(v) }
		end
	end
	return { count = B.count(cs), returned = #out, constants = out }
end

H.set_constant = function(p)
	local f = funcArg(p)
	B.need("setconstant")(f, p.index, B.de(p.value))
	return { ok = true }
end

H.get_protos = function(p)
	local f = funcArg(p)
	local protos = B.need("getprotos")(f)
	local out = {}
	for i, pr in ipairs(protos) do
		local info = B.funcInfo(pr)
		info.index = i
		info.ref = B.ref(pr)
		out[i] = info
	end
	return { count = #out, protos = out }
end

local function dumpFn(f, depth, maxDepth, state, o)
	state.n = state.n + 1
	local info = B.funcInfo(f)
	local node = { name = info.name, line = info.line, numparams = info.numparams, nups = info.nups, is_vararg = info.is_vararg, ref = B.ref(f) }
	if C.getconstants then
		local ok, cs = pcall(C.getconstants, f)
		if ok and type(cs) == "table" then
			local list = {}
			local keys = {}
			for k in pairs(cs) do keys[#keys + 1] = k end
			table.sort(keys)
			for _, k in ipairs(keys) do
				local v = cs[k]
				if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
					if #list < state.maxConsts then list[#list + 1] = type(v) == "string" and B.trunc(v, 160) or v end
				end
			end
			node.constants = list
		end
	end
	if state.upvalues and C.getupvalues then
		local ok, ups = pcall(C.getupvalues, f)
		if ok and type(ups) == "table" then
			local list = {}
			for k, v in pairs(ups) do
				list[#list + 1] = { index = k, value = B.ser(v, o, 1) }
			end
			table.sort(list, function(a, b) return a.index < b.index end)
			node.upvalues = list
		end
	end
	if depth < maxDepth and C.getprotos and state.n < state.maxNodes then
		local ok, protos = pcall(C.getprotos, f)
		if ok and type(protos) == "table" and #protos > 0 then
			node.protos = {}
			for _, pr in ipairs(protos) do
				if state.n >= state.maxNodes then break end
				node.protos[#node.protos + 1] = dumpFn(pr, depth + 1, maxDepth, state, o)
			end
		end
	end
	return node
end

H.dump_function = function(p)
	local f = funcArg(p)
	local state = { n = 0, maxNodes = p.max_nodes or 300, maxConsts = p.max_constants or 60, upvalues = p.upvalues ~= false }
	local o = { depth = 1, maxItems = 10, maxStr = 200 }
	return { function_dump = dumpFn(f, 0, p.depth or 3, state, o), nodes = state.n }
end

H.call_function = function(p)
	local f = funcArg(p)
	local args = B.deArgs(p.args)
	local ok, res = B.timed(function() return B.pack(f(B.unpack(args))) end, p.timeout or 15)
	if not ok then error("call failed: " .. tostring(res), 0) end
	return { results = B.serPack(res, p), count = res.n }
end

H.clone_function = function(p)
	local f = funcArg(p)
	local g = B.need("clonefunction")(f)
	return { clone = B.ser(g) }
end

H.get_function_env = function(p)
	local f = funcArg(p)
	local fe = getfenv(f)
	return { env = B.serWith(fe, { depth = p.depth or 1, maxItems = p.max_items or 100 }), ref = B.ref(fe) }
end

----------------------------------------------------------------------------------------------------
-- GC
----------------------------------------------------------------------------------------------------
local function getGc()
	return B.need("getgc")(true)
end

local function isExecutor(f)
	if not C.isexecutorclosure then return false end
	local ok, r = pcall(C.isexecutorclosure, f)
	return ok and r
end

local function fnScript(f)
	local ok, fe = pcall(getfenv, f)
	if ok and type(fe) == "table" then
		local s = rawget(fe, "script")
		if typeof(s) == "Instance" then return s end
	end
	return nil
end

local function valueEquals(a, b)
	if a == b then return true end
	if typeof(a) ~= typeof(b) then return false end
	return false
end

local function tableHasValue(t, want, wantKey)
	for k, v in next, t do
		if (wantKey == nil or k == wantKey) and v == want then return true, k end
	end
	return false
end

local function resolveWanted(raw)
	if type(raw) == "table" then return B.de(raw) end
	return raw
end

H.gc_search = function(p)
	local list = getGc()
	local kind = p.kind or "function"
	local nameM = p.name and B.matcher(p.name, p.name_mode, p.case_insensitive ~= false) or nil
	local limit = p.limit or 50
	local budget = p.time_budget or 25
	local t0 = clock()
	local out, matched, scanned = {}, 0, 0
	local script = p.script and B.inst(p.script) or nil
	local hasConst = p.has_constant
	local hasConstM = (type(hasConst) == "string") and B.matcher(hasConst, p.constant_mode, p.case_insensitive ~= false) or nil
	local hasUp = p.has_upvalue ~= nil and resolveWanted(p.has_upvalue) or nil
	local hasKeys = p.has_keys
	local keyValues = p.key_values
	local valueEq = p.value_equals ~= nil and resolveWanted(p.value_equals) or nil
	local keyM = p.key_pattern and B.matcher(p.key_pattern, "plain", true) or nil
	local ignoreExec = p.ignore_executor ~= false
	local partial = false

	for i, obj in ipairs(list) do
		local ty = type(obj)
		if (kind == "all" or ty == kind) and (ty == "function" or ty == "table" or ty == "userdata") then
			scanned = scanned + 1
			local ok = true
			if ty == "function" then
				if ignoreExec and isExecutor(obj) then ok = false end
				if ok and (nameM or script or hasConst ~= nil or hasUp ~= nil or p.min_params or p.line) then
					local info
					if nameM or p.min_params or p.line then info = B.funcInfo(obj) end
					if nameM and not nameM(info.name or "") then ok = false end
					if ok and p.min_params and (info.numparams or 0) < p.min_params then ok = false end
					if ok and p.line and info.line ~= p.line then ok = false end
					if ok and script and fnScript(obj) ~= script then ok = false end
					if ok and hasConst ~= nil then
						local found = false
						if C.getconstants then
							local cok, cs = pcall(C.getconstants, obj)
							if cok and type(cs) == "table" then
								for _, c in pairs(cs) do
									if hasConstM then
										if type(c) == "string" and hasConstM(c) then found = true break end
									elseif c == hasConst then found = true break end
								end
							end
						end
						if not found then ok = false end
					end
					if ok and hasUp ~= nil then
						local found = false
						if C.getupvalues then
							local uok, ups = pcall(C.getupvalues, obj)
							if uok and type(ups) == "table" then
								for _, u in pairs(ups) do if u == hasUp then found = true break end end
							end
						end
						if not found then ok = false end
					end
				end
			elseif ty == "table" then
				if hasKeys then
					for _, k in ipairs(hasKeys) do
						if rawget(obj, k) == nil then ok = false break end
					end
				end
				if ok and keyValues then
					for k, v in pairs(keyValues) do
						local want = resolveWanted(v)
						local got = rawget(obj, k)
						if got ~= want and tostring(got) ~= tostring(want) then ok = false break end
					end
				end
				if ok and valueEq ~= nil then
					if not tableHasValue(obj, valueEq, p.at_key) then ok = false end
				end
				if ok and keyM then
					local found = false
					for k in next, obj do
						if type(k) == "string" and keyM(k) then found = true break end
					end
					if not found then ok = false end
				end
				if ok and p.min_size then
					local cnt = 0
					for _ in next, obj do cnt = cnt + 1 if cnt >= p.min_size then break end end
					if cnt < p.min_size then ok = false end
				end
				if ok and p.has_metatable ~= nil then
					local mt = C.getrawmetatable and select(2, pcall(C.getrawmetatable, obj)) or getmetatable(obj)
					if (type(mt) == "table") ~= p.has_metatable then ok = false end
				end
				-- when no table filter given at all, never return every table
				if ok and not (hasKeys or keyValues or valueEq ~= nil or keyM or p.min_size or p.has_metatable ~= nil) then ok = false end
			else
				if not (p.name and nameM and nameM(tostring(obj))) then ok = false end
			end
			if ok then
				matched = matched + 1
				if #out < limit then
					local s = B.ser(obj, { depth = p.depth or 1, maxItems = p.max_items or 12, maxStr = 200 }, 0)
					out[#out + 1] = s
				end
			end
		end
		if i % 8000 == 0 then
			B.yield()
			if clock() - t0 > budget then partial = true break end
		end
	end
	return { gc_size = #list, scanned = scanned, matched = matched, returned = #out, partial = partial, elapsed = clock() - t0, results = out }
end

-- "cheat engine for lua": find tables/upvalues/constants holding a given value
H.gc_find_value = function(p)
	if p.value == nil then error("value is required", 0) end
	local want = resolveWanted(p.value)
	local list = getGc()
	local types = {}
	for _, t in ipairs(p.where or { "table", "upvalue" }) do types[t] = true end
	local limit = p.limit or 40
	local budget = p.time_budget or 25
	local t0 = clock()
	local out, matched = {}, 0
	local partial = false
	local keyM = p.key and B.matcher(p.key, "plain", true) or nil
	local approx = p.tolerance
	local function eq(v)
		if v == want then return true end
		if approx and type(v) == "number" and type(want) == "number" then return math.abs(v - want) <= approx end
		return false
	end
	for i, obj in ipairs(list) do
		local ty = type(obj)
		if ty == "table" and types.table then
			for k, v in next, obj do
				if eq(v) and (not keyM or (type(k) == "string" and keyM(k))) then
					matched = matched + 1
					if #out < limit then
						out[#out + 1] = {
							where = "table",
							table = B.ser(obj, { depth = 0 }),
							key = B.ser(k, { depth = 0 }),
							value = B.ser(v, { depth = 0 }),
							preview_keys = (function()
								local ks, n = {}, 0
								for kk in next, obj do
									n = n + 1
									ks[#ks + 1] = tostring(kk)
									if n >= 8 then break end
								end
								return ks
							end)(),
						}
					end
				end
			end
		elseif ty == "function" and (types.upvalue or types.constant) then
			if not isExecutor(obj) then
				if types.upvalue and C.getupvalues then
					local ok, ups = pcall(C.getupvalues, obj)
					if ok and type(ups) == "table" then
						for idx, u in pairs(ups) do
							if eq(u) then
								matched = matched + 1
								if #out < limit then
									local info = B.funcInfo(obj)
									out[#out + 1] = { where = "upvalue", ["function"] = B.ser(obj, { depth = 0 }), name = info.name, index = idx, value = B.ser(u, { depth = 0 }) }
								end
							end
						end
					end
				end
				if types.constant and C.getconstants then
					local ok, cs = pcall(C.getconstants, obj)
					if ok and type(cs) == "table" then
						for idx, c in pairs(cs) do
							if eq(c) then
								matched = matched + 1
								if #out < limit then
									local info = B.funcInfo(obj)
									out[#out + 1] = { where = "constant", ["function"] = B.ser(obj, { depth = 0 }), name = info.name, index = idx, value = B.ser(c, { depth = 0 }) }
								end
							end
						end
					end
				end
			end
		end
		if i % 6000 == 0 then
			B.yield()
			if clock() - t0 > budget then partial = true break end
		end
	end
	return { matched = matched, returned = #out, partial = partial, elapsed = clock() - t0, results = out }
end

H.find_references = function(p)
	local target = B.val(p.target)
	local list = getGc()
	local limit = p.limit or 40
	local out, matched = {}, 0
	local t0 = clock()
	for i, obj in ipairs(list) do
		local ty = type(obj)
		if obj ~= target then
			if ty == "table" then
				local found, key = tableHasValue(obj, target)
				if not found then
					for k in next, obj do if k == target then found, key = true, k break end end
				end
				if found then
					matched = matched + 1
					if #out < limit then
						out[#out + 1] = { where = "table", table = B.ser(obj, { depth = 0 }), key = B.ser(key, { depth = 0 }) }
					end
				end
			elseif ty == "function" and C.getupvalues and not isExecutor(obj) then
				local ok, ups = pcall(C.getupvalues, obj)
				if ok and type(ups) == "table" then
					for idx, u in pairs(ups) do
						if u == target then
							matched = matched + 1
							if #out < limit then
								local info = B.funcInfo(obj)
								out[#out + 1] = { where = "upvalue", ["function"] = B.ser(obj, { depth = 0 }), name = info.name, index = idx }
							end
							break
						end
					end
				end
			end
		end
		if i % 6000 == 0 then
			B.yield()
			if clock() - t0 > (p.time_budget or 25) then break end
		end
	end
	return { matched = matched, returned = #out, results = out, elapsed = clock() - t0 }
end

local gcSnaps = {}
H.gc_snapshot = function(p)
	local list = getGc()
	local set = setmetatable({}, { __mode = "k" })
	local kinds = {}
	for _, k in ipairs(p.kinds or { "function", "table" }) do kinds[k] = true end
	local n = 0
	for i, obj in ipairs(list) do
		if kinds[type(obj)] then set[obj] = true n = n + 1 end
		if i % 20000 == 0 then B.yield() end
	end
	gcSnaps[p.name or "default"] = { set = set, kinds = kinds, count = n, at = B.now() }
	return { name = p.name or "default", objects = n }
end

H.gc_diff = function(p)
	local snap = gcSnaps[p.name or "default"]
	if not snap then error("no gc snapshot named '" .. tostring(p.name or "default") .. "' (call gc_snapshot first)", 0) end
	local list = getGc()
	local limit = p.limit or 40
	local out, newCount = {}, 0
	local byType = { ["function"] = 0, table = 0, userdata = 0 }
	local want = p.kind
	local nameM = p.name_filter and B.matcher(p.name_filter, "plain", true) or nil
	local minSize = p.min_size or 0
	for i, obj in ipairs(list) do
		local ty = type(obj)
		if snap.kinds[ty] and not snap.set[obj] and (not want or ty == want) then
			local keep = true
			if ty == "function" and isExecutor(obj) then keep = false end
			if keep and ty == "table" and minSize > 0 then
				local cnt = 0
				for _ in next, obj do cnt = cnt + 1 if cnt >= minSize then break end end
				if cnt < minSize then keep = false end
			end
			if keep and nameM and ty == "function" then
				local info = B.funcInfo(obj)
				if not nameM(info.name or "") then keep = false end
			end
			if keep then
				newCount = newCount + 1
				byType[ty] = (byType[ty] or 0) + 1
				if #out < limit then out[#out + 1] = B.ser(obj, { depth = 1, maxItems = 10, maxStr = 160 }, 0) end
			end
		end
		if i % 8000 == 0 then B.yield() end
	end
	if p.update then
		local fresh = setmetatable({}, { __mode = "k" })
		for _, obj in ipairs(list) do if snap.kinds[type(obj)] then fresh[obj] = true end end
		snap.set = fresh
	end
	return { new_objects = newCount, by_type = byType, returned = #out, results = out }
end

H.gc_stats = function(p)
	local list = getGc()
	local counts = {}
	local execFns = 0
	for i, obj in ipairs(list) do
		local ty = typeof(obj)
		counts[ty] = (counts[ty] or 0) + 1
		if i % 20000 == 0 then B.yield() end
	end
	return { total = #list, by_type = B.obj(counts) }
end

----------------------------------------------------------------------------------------------------
-- tables + metatables
----------------------------------------------------------------------------------------------------
local function tableArg(p)
	local t = B.val(p.ref or p.target)
	if type(t) ~= "table" then error("target is a " .. typeof(t) .. ", not a table", 0) end
	return t
end

H.get_table = function(p)
	local t = tableArg(p)
	local keys = {}
	for k in next, t do keys[#keys + 1] = k end
	local numeric = true
	for _, k in ipairs(keys) do if type(k) ~= "number" then numeric = false break end end
	if numeric then table.sort(keys) else
		table.sort(keys, function(a, b)
			local ta, tb = type(a), type(b)
			if ta ~= tb then return ta < tb end
			if ta == "number" or ta == "string" then return a < b end
			return tostring(a) < tostring(b)
		end)
	end
	local keyM = p.key and B.matcher(p.key, p.key_mode, true) or nil
	local offset, limit = p.offset or 0, p.limit or 100
	local o = { depth = p.depth or 1, maxItems = p.max_items or 12, maxStr = p.max_str or 500 }
	local entries, matched = {}, 0
	for _, k in ipairs(keys) do
		if not keyM or keyM(tostring(k)) then
			matched = matched + 1
			if matched > offset and #entries < limit then
				local sv = B.ser(t[k], o, 0)
				if sv == nil then sv = NULL end
				entries[#entries + 1] = { key = B.ser(k, { depth = 0, maxStr = 200 }), value = sv }
			end
		end
	end
	local mt
	if C.getrawmetatable then
		local ok, m = pcall(C.getrawmetatable, t)
		if ok then mt = m end
	end
	return {
		ref = B.ref(t),
		total = #keys,
		matched = matched,
		returned = #entries,
		next_offset = (offset + #entries < matched) and (offset + #entries) or nil,
		has_metatable = type(mt) == "table",
		readonly = C.isreadonly and select(2, pcall(C.isreadonly, t)) or nil,
		entries = entries,
	}
end

H.set_table_field = function(p)
	local t = tableArg(p)
	local key = B.de(p.key)
	local val = B.de(p.value)
	if C.isreadonly and C.setreadonly then
		local ok, ro = pcall(C.isreadonly, t)
		if ok and ro then pcall(C.setreadonly, t, false) end
	end
	if p.raw == false then t[key] = val else rawset(t, key, val) end
	return { ok = true, new_value = B.ser(rawget(t, key), { depth = 1 }) }
end

H.delete_table_field = function(p)
	local t = tableArg(p)
	local key = B.de(p.key)
	if C.isreadonly and C.setreadonly then
		local ok, ro = pcall(C.isreadonly, t)
		if ok and ro then pcall(C.setreadonly, t, false) end
	end
	rawset(t, key, nil)
	return { ok = true }
end

-- recursive search for keys/values in a table; returns access paths
H.table_search = function(p)
	local root = tableArg(p)
	local keyM = p.key and B.matcher(p.key, p.key_mode, p.case_insensitive ~= false) or nil
	local valM = p.value and B.matcher(tostring(p.value), p.value_mode, p.case_insensitive ~= false) or nil
	local maxDepth = p.depth or 5
	local limit = p.limit or 60
	local out, seen, visited = {}, {}, 0
	local function fmtKey(k)
		if type(k) == "string" and B.identOk(k) then return "." .. k end
		if type(k) == "string" then return "[" .. B.luaQuote(k) .. "]" end
		return "[" .. tostring(k) .. "]"
	end
	local function rec(t, path, depth)
		if #out >= limit or visited > 50000 then return end
		seen[t] = true
		for k, v in next, t do
			visited = visited + 1
			local kmatch = keyM and type(k) == "string" and keyM(k)
			local vmatch = false
			if valM then
				local tv = type(v)
				if tv == "string" or tv == "number" or tv == "boolean" then vmatch = valM(tostring(v)) end
			end
			if (keyM and kmatch and not valM) or (valM and vmatch and not keyM) or (keyM and valM and kmatch and vmatch) then
				if #out < limit then
					out[#out + 1] = { path = path .. fmtKey(k), value = B.ser(v, { depth = 0, maxStr = 200 }) }
				end
			end
			if type(v) == "table" and not seen[v] and depth < maxDepth then rec(v, path .. fmtKey(k), depth + 1) end
			if visited % 5000 == 0 then B.yield() end
		end
	end
	rec(root, "ref#" .. tostring(B.ref(root)), 1)
	return { visited = visited, returned = #out, results = out }
end

H.get_metatable = function(p)
	local v = B.val(p.ref or p.target)
	local gm_ = C.getrawmetatable
	local mt
	if gm_ then mt = gm_(v) else mt = getmetatable(v) end
	if mt == nil then return { has_metatable = false } end
	if type(mt) ~= "table" then return { has_metatable = true, value = B.ser(mt) } end
	local readonly
	if C.isreadonly then
		local ok, r = pcall(C.isreadonly, mt)
		if ok then readonly = r end
	end
	return { has_metatable = true, ref = B.ref(mt), readonly = readonly, metatable = B.serWith(mt, { depth = 1, maxItems = 60, maxStr = 200 }) }
end

H.set_metatable = function(p)
	local v = B.val(p.ref or p.target)
	local mt = p.metatable ~= nil and B.val(p.metatable) or nil
	local f = B.need("setrawmetatable")
	f(v, mt)
	return { ok = true }
end

H.set_readonly = function(p)
	local t = tableArg(p)
	B.need("setreadonly")(t, p.value ~= false)
	return { readonly = B.need("isreadonly")(t) }
end

H.set_metamethod = function(p)
	-- patch a single metamethod on an object's metatable with a Lua function from code
	local v = B.val(p.ref or p.target)
	local getmt, setro = B.need("getrawmetatable"), C.setreadonly
	local mt = getmt(v)
	if type(mt) ~= "table" then error("target has no metatable table", 0) end
	local wasRo = C.isreadonly and C.isreadonly(mt)
	if setro and wasRo then setro(mt, false) end
	local old = rawget(mt, p.name)
	if p.code then
		local fn, err = B.need("loadstring")(p.code, "=metamethod")
		if not fn then error("compile error: " .. tostring(err), 0) end
		rawset(mt, p.name, fn())
	elseif p.value ~= nil then
		rawset(mt, p.name, B.val(p.value))
	else
		rawset(mt, p.name, nil)
	end
	if setro and wasRo then setro(mt, true) end
	return { ok = true, previous = B.ser(old, { depth = 0 }) }
end

H.get_registry = function(p)
	local reg = B.need("getreg")()
	local matchFn = p.filter and B.matcher(p.filter, "plain", true) or nil
	local out, total = {}, 0
	local limit = p.limit or 100
	for k, v in pairs(reg) do
		local label = tostring(k)
		if not matchFn or matchFn(label) or matchFn(tostring(v)) then
			total = total + 1
			if #out < limit then out[#out + 1] = { key = B.ser(k, { depth = 0 }), value = B.ser(v, { depth = 0 }) } end
		end
	end
	return { total = total, returned = #out, entries = out }
end

H.get_threads = function(p)
	local list = B.need("getthreads")()
	local out = {}
	for i = 1, math.min(#list, p.limit or 50) do
		local th = list[i]
		out[#out + 1] = { ref = B.ref(th), status = coroutine.status(th) }
	end
	return { total = #list, threads = out }
end

----------------------------------------------------------------------------------------------------
-- signal connections
----------------------------------------------------------------------------------------------------
local function signalFrom(p)
	if p.signal_ref then
		local s = B.val(p.signal_ref)
		return s, "signal"
	end
	local inst = B.inst(p.target)
	local name = p.signal or p.event
	if not name then error("signal (event name) is required", 0) end
	local sig = inst[name]
	if typeof(sig) ~= "RBXScriptSignal" then error(inst.ClassName .. "." .. name .. " is not a signal", 0) end
	return sig, inst.ClassName .. "." .. name
end

local function connInfo(c, idx)
	local e = { index = idx, ref = B.ref(c) }
	local ok, v = pcall(function() return c.Enabled end)
	if ok then e.enabled = v end
	local ok2, st = pcall(function() return c.State end)
	if ok2 and st ~= nil then e.state = st end
	local ok3, fo = pcall(function() return c.ForeignState end)
	if ok3 then e.foreign = fo end
	local ok4, fn = pcall(function() return c.Function end)
	if ok4 and type(fn) == "function" then
		e["function"] = B.ser(fn, { depth = 0 })
		local scr = fnScript(fn)
		if scr then e.script = B.instPath(scr) end
		if B.ownFns[fn] then e.ours = true end
	end
	local ok5, th = pcall(function() return c.Thread end)
	if ok5 and th ~= nil then e.thread = B.ser(th) end
	return e
end

H.get_connections = function(p)
	local sig, label = signalFrom(p)
	local conns = B.need("getconnections")(sig)
	local out = {}
	for i, c in ipairs(conns) do
		out[#out + 1] = connInfo(c, i)
		if #out >= (p.limit or 100) then break end
	end
	return { signal = label, count = #conns, connections = out }
end

H.connection_action = function(p)
	local c = B.val(p.ref)
	local act = p.action
	local map = { enable = "Enable", disable = "Disable", fire = "Fire", defer = "Defer", disconnect = "Disconnect" }
	local m = map[act]
	if not m then error("action must be one of enable|disable|fire|defer|disconnect", 0) end
	if m == "Fire" or m == "Defer" then
		local args = B.deArgs(p.args)
		c[m](c, B.unpack(args))
	else
		c[m](c)
	end
	return { ok = true, connection = connInfo(c, 0) }
end

H.disable_all_connections = function(p)
	local sig, label = signalFrom(p)
	local conns = B.need("getconnections")(sig)
	local n = 0
	for _, c in ipairs(conns) do
		local ok = pcall(function() if p.enable then c:Enable() else c:Disable() end end)
		if ok then n = n + 1 end
	end
	return { signal = label, affected = n }
end

H.fire_signal = function(p)
	local sig, label = signalFrom(p)
	local f = B.need("firesignal")
	local args = B.deArgs(p.args)
	f(sig, B.unpack(args))
	return { ok = true, signal = label }
end

H.get_callback = function(p)
	local inst = B.inst(p.target)
	local f = B.need("getcallbackvalue")
	local v = f(inst, p.name or "OnClientInvoke")
	return { value = B.ser(v) }
end

-- which signals of this instance have connections from a given script/function
H.list_connected_signals = function(p)
	local inst = B.inst(p.target)
	local getconns = B.need("getconnections")
	local events = Dex.API.GetMember(inst.ClassName, "Events") or {}
	local out = {}
	for _, ev in ipairs(events) do
		local ok, sig = pcall(function() return inst[ev.Name] end)
		if ok and typeof(sig) == "RBXScriptSignal" then
			local ok2, conns = pcall(getconns, sig)
			if ok2 and #conns > 0 then
				local fns = {}
				for i, c in ipairs(conns) do
					local ok3, fn = pcall(function() return c.Function end)
					if ok3 and type(fn) == "function" then
						local info = B.funcInfo(fn)
						local scr = fnScript(fn)
						fns[#fns + 1] = { ref = B.ref(fn), name = info.name, line = info.line, script = scr and B.instPath(scr) or nil }
					end
					if i >= 10 then break end
				end
				out[#out + 1] = { signal = ev.Name, connections = #conns, handlers = fns }
			end
		end
	end
	return { instance = B.ser(inst), signals = out }
end

----------------------------------------------------------------------------------------------------
-- environments
----------------------------------------------------------------------------------------------------
H.get_env = function(p)
	local which = p.which or "genv"
	local tbl
	if which == "genv" then tbl = B.need("getgenv")()
	elseif which == "renv" then tbl = B.need("getrenv")()
	elseif which == "shared" then tbl = shared
	elseif which == "_G" then tbl = _G
	elseif which == "script" then
		local scr = B.inst(p.script)
		tbl = B.need("getsenv")(scr)
	elseif which == "function" then
		tbl = getfenv(B.func(p.ref))
	else
		error("which must be genv|renv|shared|_G|script|function", 0)
	end
	if type(tbl) ~= "table" then error(which .. " is not available in this executor", 0) end
	local matchFn = p.filter and B.matcher(p.filter, p.mode or "plain", true) or nil
	local keys = {}
	for k in pairs(tbl) do
		if not matchFn or matchFn(tostring(k)) then keys[#keys + 1] = k end
	end
	table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
	local out, o = {}, { depth = p.depth or 0, maxItems = 12, maxStr = 200 }
	local limit = p.limit or 150
	for i = 1, math.min(#keys, limit) do
		local sv = B.ser(rawget(tbl, keys[i]), o, 0)
		if sv == nil then sv = NULL end
		out[tostring(keys[i])] = sv
	end
	return { which = which, total = #keys, returned = math.min(#keys, limit), env = B.obj(out), ref = B.ref(tbl) }
end

H.set_global = function(p)
	local which = p.which or "genv"
	local tbl = (which == "shared" and shared) or (which == "_G" and _G) or B.need("getgenv")()
	tbl[p.name] = B.de(p.value)
	return { ok = true }
end
