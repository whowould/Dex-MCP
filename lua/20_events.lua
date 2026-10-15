-- 20_events: event ring buffers (remote spy, hooks, watches, output...) + ref registry commands
local H = B.H
local NULL = B.NULL

local E = { chans = {}, seq = 0 }
B.Events = E

local DEFAULT_CAP = 2000
local CAPS = { remote = 5000, hook = 5000, trap = 3000, http = 1000, output = 2000, error = 500, signal = 3000, watch = 3000, tree = 3000 }

local function chan(name)
	local c = E.chans[name]
	if not c then
		c = { name = name, items = {}, head = 1, tail = 0, cap = CAPS[name] or DEFAULT_CAP, total = 0, dropped = 0 }
		E.chans[name] = c
	end
	return c
end

function E.push(name, data)
	local c = chan(name)
	E.seq = E.seq + 1
	data.seq = E.seq
	data.ch = name
	data.t = data.t or B.now()
	c.tail = c.tail + 1
	c.items[c.tail] = data
	c.total = c.total + 1
	if c.tail - c.head + 1 > c.cap then
		c.items[c.head] = nil
		c.head = c.head + 1
		c.dropped = c.dropped + 1
	end
	return E.seq
end

function E.size(name)
	local c = E.chans[name]
	if not c then return 0 end
	return c.tail - c.head + 1
end

function E.clear(name)
	local c = E.chans[name]
	if not c then return 0 end
	local n = c.tail - c.head + 1
	c.items = {}
	c.head = c.tail + 1
	return n
end

function E.setCap(name, cap)
	chan(name).cap = cap
end

-- returns list (oldest->newest) of events with seq > since matching pred
function E.query(name, since, pred, limit, tailMode)
	local out = {}
	local lastSeq = since or 0
	local matched = 0
	local names = {}
	if name then names[1] = name else for k in pairs(E.chans) do names[#names + 1] = k end end
	local all = {}
	for _, nm in ipairs(names) do
		local c = E.chans[nm]
		if c then
			for i = c.head, c.tail do
				local ev = c.items[i]
				if ev and ev.seq > (since or 0) and (not pred or pred(ev)) then
					all[#all + 1] = ev
				end
			end
		end
	end
	table.sort(all, function(a, b) return a.seq < b.seq end)
	matched = #all
	limit = limit or 100
	if matched > limit then
		local first = tailMode and (matched - limit + 1) or 1
		for i = first, first + limit - 1 do out[#out + 1] = all[i] end
	else
		out = all
	end
	if #out > 0 then lastSeq = out[#out].seq end
	return out, matched, lastSeq
end

H.get_events = function(p)
	local pat = p.match and B.matcher(p.match, p.match_mode or "plain", true) or nil
	local pred
	if pat then
		pred = function(ev)
			local key = ev.key or ev.name or ev.summary
			if key == nil then return false end
			return pat(tostring(key))
		end
	end
	local tailMode = p.since == nil or p.tail == true
	local evs, matched, lastSeq = E.query(p.channel, p.since, pred, p.limit or 100, tailMode)
	return {
		events = evs,
		returned = #evs,
		matched = matched,
		last_seq = lastSeq,
		current_seq = E.seq,
	}
end

H.clear_events = function(p)
	if p.channel then return { cleared = E.clear(p.channel) } end
	local n = 0
	for name in pairs(E.chans) do n = n + E.clear(name) end
	return { cleared = n }
end

H.list_event_channels = function(p)
	local out = {}
	for name, c in pairs(E.chans) do
		out[#out + 1] = { channel = name, buffered = c.tail - c.head + 1, total = c.total, dropped = c.dropped, capacity = c.cap }
	end
	table.sort(out, function(a, b) return a.channel < b.channel end)
	return { channels = out, current_seq = E.seq }
end

H.set_event_capacity = function(p)
	E.setCap(p.channel, p.capacity)
	return { channel = p.channel, capacity = p.capacity }
end

----------------------------------------------------------------------------------------------------
-- Refs
----------------------------------------------------------------------------------------------------
H.inspect_ref = function(p)
	local v = B.val(p.ref)
	return { value = B.serWith(v, { depth = p.depth or 3, maxItems = p.max_items or 100, maxStr = p.max_str or 8000 }) }
end

H.release_ref = function(p)
	local n = 0
	local list = p.refs or { p.ref }
	for _, id in ipairs(list) do
		if B.unref(tonumber(id)) then n = n + 1 end
	end
	return { released = n }
end

H.clear_refs = function(p)
	return { released = B.clearRefs() }
end

H.ref_stats = function(p)
	return B.refStats()
end

H.list_refs = function(p)
	local out = {}
	local limit = p.limit or 100
	local want = p.type
	local ids = {}
	for id in pairs(B.refs) do ids[#ids + 1] = id end
	table.sort(ids, function(a, b) return a > b end)
	for _, id in ipairs(ids) do
		local v = B.refs[id]
		local ty = typeof(v)
		if not want or ty == want then
			local entry = { ref = id, type = ty }
			if ty == "Instance" then
				local ok, s = pcall(function() return v.ClassName .. " " .. v:GetFullName() end)
				entry.desc = ok and s or "?"
			elseif ty == "function" then
				local info = B.funcInfo(v)
				entry.desc = tostring(info.name or "?") .. " @ " .. tostring(info.short_src or info.source or "?") .. ":" .. tostring(info.line or "?")
			else
				entry.desc = B.trunc(tostring(v), 80)
			end
			out[#out + 1] = entry
			if #out >= limit then break end
		end
	end
	return { refs = out, stats = B.refStats() }
end
