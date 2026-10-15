-- 99_transport: command dispatcher, WebSocket/HTTP transport to the MCP server, status commands, Dex++ window
local H = B.H
local C = B.C
local Dex = B.Dex
local Settings = Dex.Settings
local service = Dex.service
local E = B.Events
local NULL = B.NULL
local typeof = typeof or type
local clock = os.clock
local HttpService = service.HttpService

local PROTOCOL = 1
local FRAME_LIMIT = 200000 -- payloads larger than this are sent in chunks over WebSocket

local T = {
	state = "stopped",
	detail = "",
	running = false,
	commands = 0,
	errors = 0,
	sent = 0,
	received = 0,
	connects = 0,
	started = clock(),
	transport = nil,
	clientId = nil,
	preferHttp = false,
	failures = 0,
}
B.T = T
B.sessionId = HttpService:GenerateGUID(false)

function B.executorName()
	if C.identifyexecutor then
		local ok, name, ver = pcall(C.identifyexecutor)
		if ok then return tostring(name) .. (ver and (" " .. tostring(ver)) or "") end
	end
	return "unknown"
end

local function cfg() return Settings.MCP end

----------------------------------------------------------------------------------------------------
-- status helpers
----------------------------------------------------------------------------------------------------
local function capsPresent()
	local present, missing = {}, {}
	for group, names in pairs(B.CapGroups) do
		for _, n in ipairs(names) do
			if C[n] ~= nil then present[#present + 1] = n else missing[#missing + 1] = n end
		end
	end
	table.sort(present) table.sort(missing)
	return present, missing
end

local function helloInfo()
	local present = capsPresent()
	local identity
	if C.getthreadidentity then
		local ok, v = pcall(C.getthreadidentity)
		if ok then identity = v end
	end
	return {
		type = "hello",
		protocol = PROTOCOL,
		session = B.sessionId,
		token = cfg().Token ~= "" and cfg().Token or nil,
		place_id = game.PlaceId,
		game_id = game.GameId,
		job_id = game.JobId,
		user = Dex.plr.Name,
		user_id = Dex.plr.UserId,
		executor = B.executorName(),
		dex_version = Dex.Main.Version,
		identity = identity,
		capabilities = present,
	}
end

H.ping = function(p)
	return { pong = true, t = B.now(), echo = p.echo }
end

H.get_status = function(p)
	local present, missing = capsPresent()
	local identity
	if C.getthreadidentity then
		local ok, v = pcall(C.getthreadidentity)
		if ok then identity = v end
	end
	local channels = {}
	for name, c in pairs(E.chans) do channels[name] = c.tail - c.head + 1 end
	return {
		bridge = {
			protocol = PROTOCOL,
			session = B.sessionId,
			transport = T.transport,
			state = T.state,
			uptime = clock() - T.started,
			commands_handled = T.commands,
			errors = T.errors,
			connects = T.connects,
			refs = B.refStats(),
			event_buffers = B.obj(channels),
			default_identity = B.defaultIdentity,
		},
		game = { place_id = game.PlaceId, game_id = game.GameId, job_id = game.JobId, user = Dex.plr.Name, user_id = Dex.plr.UserId },
		executor = B.executorName(),
		dex_version = Dex.Main.Version,
		identity = identity,
		capabilities_present = #present,
		capabilities_missing = missing,
		elevated = Dex.Main.Elevated,
	}
end

H.get_capabilities = function(p)
	local groups = {}
	for group, names in pairs(B.CapGroups) do
		local g = {}
		for _, n in ipairs(names) do g[n] = C[n] ~= nil end
		groups[group] = B.obj(g)
	end
	local extra = {}
	for _, n in ipairs(p.probe or {}) do extra[n] = B.lookup(n) ~= nil end
	return { executor = B.executorName(), groups = B.obj(groups), probed = B.obj(extra) }
end

H.list_commands = function(p)
	local names = {}
	for k in pairs(H) do names[#names + 1] = k end
	table.sort(names)
	return { count = #names, commands = names }
end

H.disconnect_bridge = function(p)
	task.defer(function() T.stop() end)
	return { ok = true, note = "bridge will disconnect now" }
end

----------------------------------------------------------------------------------------------------
-- dispatcher
----------------------------------------------------------------------------------------------------
local function fail(e)
	local msg = tostring(e)
	if C.traceback and (cfg().DebugTrace) then msg = msg .. "\n" .. C.traceback() end
	return msg
end

local function buildReply(msg)
	local reply = { id = msg.id }
	local handler = H[msg.cmd]
	local t0 = clock()
	if not handler then
		reply.ok = false
		reply.error = "unknown command '" .. tostring(msg.cmd) .. "' (this Dex++ build has " .. B.count(H) .. " commands; see list_commands)"
		return reply
	end
	if B.defaultIdentity and C.setthreadidentity then pcall(C.setthreadidentity, B.defaultIdentity) end
	local ok, res = xpcall(handler, fail, msg.params or {})
	reply.ms = math.floor((clock() - t0) * 1000)
	if ok then
		reply.ok = true
		reply.result = res == nil and NULL or res
	else
		T.errors = T.errors + 1
		reply.ok = false
		reply.error = tostring(res)
	end
	return reply
end

local function encodeReply(reply)
	local ok, payload = pcall(B.json, reply)
	if ok then return payload end
	return B.json({ id = reply.id, ok = false, error = "failed to encode result: " .. tostring(payload) })
end

local function dispatch(msg, send)
	T.commands = T.commands + 1
	task.spawn(function()
		local reply = buildReply(msg)
		local payload = encodeReply(reply)
		send(payload, msg.id)
	end)
end

local function handleRaw(raw, send, onControl)
	T.received = T.received + 1
	local ok, msg = pcall(B.unjson, raw)
	if not ok or type(msg) ~= "table" then return end
	if msg.cmd then
		dispatch(msg, send)
	elseif onControl then
		onControl(msg)
	end
end

----------------------------------------------------------------------------------------------------
-- UI state (set later by Init)
----------------------------------------------------------------------------------------------------
local ui = {}

local function refreshUI()
	if not ui.status then return end
	local colors = { connected = Color3.fromRGB(110, 220, 130), connecting = Color3.fromRGB(240, 200, 90), stopped = Color3.fromRGB(180, 180, 180), error = Color3.fromRGB(240, 100, 100), disconnected = Color3.fromRGB(240, 150, 90) }
	ui.status.Text = "Status: " .. T.state .. (T.detail ~= "" and (" - " .. T.detail) or "")
	ui.status.TextColor3 = colors[T.state] or Color3.new(1, 1, 1)
	ui.info.Text = string.format("Transport: %s\nCommands: %d (errors %d)\nReceived: %d  Sent: %d\nRefs: %d  Events: %d\nSession: %s", tostring(T.transport or "-"), T.commands, T.errors, T.received, T.sent, B.refStats().count, E.seq, B.sessionId:sub(1, 8))
	if ui.toggle then ui.toggle.Text = T.running and "Disconnect" or "Connect" end
end

local function setState(state, detail)
	T.state = state
	T.detail = detail or ""
	refreshUI()
end

----------------------------------------------------------------------------------------------------
-- transports
----------------------------------------------------------------------------------------------------
local function runWebSocket(url)
	local WS = C.WebSocket
	local connect = type(WS) == "table" and WS.connect or nil
	if not connect then error("WebSocket API not available", 0) end
	local ok, sock = pcall(connect, url)
	if not ok then error("WebSocket connect failed: " .. tostring(sock), 0) end
	T.transport = "websocket"
	local closed = false
	local welcomed = false
	local function send(payload, id)
		if closed then return end
		T.sent = T.sent + 1
		if #payload <= FRAME_LIMIT then
			sock:Send(payload)
		else
			local n = math.ceil(#payload / FRAME_LIMIT)
			for i = 1, n do
				sock:Send(B.json({ id = id, chunk = i, of = n, data = payload:sub((i - 1) * FRAME_LIMIT + 1, i * FRAME_LIMIT) }))
				if i % 8 == 0 then task.wait() end
			end
		end
	end
	local function control(msg)
		if msg.type == "welcome" then
			welcomed = true
			T.reached = true
			T.clientId = msg.client
			T.failures = 0
			T.connects = T.connects + 1
			setState("connected", msg.server or "")
		elseif msg.type == "error" then
			setState("error", tostring(msg.error))
			closed = true
		elseif msg.type == "ping" then
			sock:Send(B.json({ type = "pong", t = msg.t }))
		end
	end
	sock.OnMessage:Connect(function(m) handleRaw(m, send, control) end)
	sock.OnClose:Connect(function() closed = true end)
	sock:Send(B.json(helloInfo()))
	local t0 = clock()
	local resent = false
	while not closed and T.running do
		task.wait(0.25)
		local waited = clock() - t0
		-- some executors return from connect() before the socket is open and drop the first frame
		if not welcomed and not resent and waited > 1.5 then
			resent = true
			pcall(sock.Send, sock, B.json(helloInfo()))
		end
		if not welcomed and waited > 6 then
			closed = true
			pcall(sock.Close, sock)
			error("server did not answer the hello within 6s", 0)
		end
	end
	pcall(sock.Close, sock)
end

local function runHttp(base)
	local request = C.request
	if not request then error("no HTTP request function available", 0) end
	T.transport = "http-poll"
	local function post(path, body)
		return request({ Url = base .. path, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
	end
	local res = post("/hello", B.json(helloInfo()))
	if type(res) ~= "table" or res.StatusCode ~= 200 then
		local body = (type(res) == "table" and type(res.Body) == "string") and res.Body:sub(1, 80) or ""
		error(string.format("hello failed (HTTP %s %s %s)", tostring(type(res) == "table" and res.StatusCode or res), tostring(type(res) == "table" and res.StatusMessage or ""), body), 0)
	end
	local welcome = B.unjson(res.Body)
	if welcome.type == "error" then error(tostring(welcome.error), 0) end
	T.clientId = welcome.client
	T.reached = true
	T.failures = 0
	T.connects = T.connects + 1
	setState("connected", welcome.server or "")
	local function send(payload, id)
		T.sent = T.sent + 1
		local r = request({ Url = base .. "/result?client=" .. T.clientId .. "&id=" .. tostring(id), Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
		return r
	end
	while T.running do
		local pr = request({ Url = base .. "/poll?client=" .. T.clientId, Method = "GET" })
		if not pr or pr.StatusCode ~= 200 then
			error("poll failed: " .. tostring(pr and pr.StatusCode), 0)
		end
		local list = B.unjson(pr.Body)
		if type(list) == "table" then
			for _, m in ipairs(list) do
				T.received = T.received + 1
				if m.cmd then dispatch(m, send) end
			end
		end
	end
end

-- Is a Dex++ MCP server listening on host:port? Uses HTTP GET /health, which answers even when WebSockets are
-- blocked; a refused port fails fast.
local function isServer(host, port)
	local ok, res = pcall(C.request, { Url = "http://" .. host .. ":" .. tostring(port) .. "/health", Method = "GET" })
	return ok and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" and res.Body:find("dexpp-mcp", 1, true) ~= nil
end

-- The server falls back to the next free port (up to +9) when its port is busy. Look for it deterministically:
-- last known good port first, then the configured one, then the fallback range. Returns nil when nothing answers
-- (or when the executor cannot probe at all).
local function locate(host, base)
	if not C.request then return nil end
	local candidates = {}
	if T.port then candidates[#candidates + 1] = T.port end
	local last = (cfg().PortScan == false) and 0 or 9
	for off = 0, last do
		if base + off ~= T.port then candidates[#candidates + 1] = base + off end
	end
	for _, port in ipairs(candidates) do
		if isServer(host, port) then
			T.port = port
			return port
		end
	end
	return nil
end

local function connectOnce()
	local c = cfg()
	local host = c.Host or "127.0.0.1"
	local base = c.Port or 18764
	local mode = c.Transport or "auto"
	T.reached = false
	setState("connecting", host .. ":" .. tostring(base))

	local canWs = mode ~= "http" and C.WebSocket ~= nil
	local canHttp = mode ~= "websocket" and C.request ~= nil
	if not canWs and not canHttp then error("no usable transport (need WebSocket.connect or request)", 0) end

	local port = locate(host, base)
	if not port then
		if C.request and not canWs then
			error("no Dex++ MCP server answering on " .. host .. ":" .. tostring(base) .. "-" .. tostring(base + 9) .. " (is the MCP server running?)", 0)
		end
		-- cannot probe (or the probe was blocked): try the configured port directly
		port = T.port or base
	end

	local errs = {}
	-- websocket first, unless it has already proven unusable here and http works
	if canWs and not (mode == "auto" and T.preferHttp and canHttp) then
		setState("connecting", "ws://" .. host .. ":" .. tostring(port))
		local ok, err = pcall(runWebSocket, "ws://" .. host .. ":" .. tostring(port) .. "/ws")
		if T.reached then return end
		errs[#errs + 1] = "websocket: " .. (ok and "closed before the server welcomed us" or tostring(err))
	end
	-- fall back to http on the SAME port within the same attempt (no waiting, no port wandering)
	if canHttp then
		setState("connecting", "http://" .. host .. ":" .. tostring(port))
		local ok, err = pcall(runHttp, "http://" .. host .. ":" .. tostring(port))
		if T.reached then
			if #errs > 0 then
				T.wsFails = (T.wsFails or 0) + 1
				if T.wsFails >= 2 then T.preferHttp = true end
			end
			if not ok then T.detail = B.trunc(tostring(err), 90) end
			return
		end
		errs[#errs + 1] = "http: " .. tostring(ok and "closed before the server welcomed us" or err)
	end
	error(table.concat(errs, " | "), 0)
end

function T.start()
	if T.running then return end
	T.running = true
	T.failures = 0
	task.spawn(function()
		local backoff = 1
		while T.running do
			local ok, err = pcall(connectOnce)
			if not T.running then break end
			T.failures = T.failures + 1
			local detail = ok and "connection closed" or tostring(err)
			setState(ok and "disconnected" or "error", B.trunc(detail, 90))
			if cfg().Reconnect == false then T.running = false break end
			task.wait(backoff)
			backoff = math.min(backoff * 1.6, 12)
			if ok then backoff = 1 end
		end
		setState("stopped", "")
	end)
	refreshUI()
end

function T.stop()
	T.running = false
	setState("stopped", "")
end

----------------------------------------------------------------------------------------------------
-- Dex++ window
----------------------------------------------------------------------------------------------------
function B.buildUI(window)
	local theme = Settings.Theme
	local content = window.GuiElems.Content

	local function label(text, y, h)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.new(0, 8, 0, y)
		l.Size = UDim2.new(1, -16, 0, h or 18)
		l.Font = Enum.Font.SourceSans
		l.TextSize = 14
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.TextColor3 = theme.Text
		l.Text = text
		l.Parent = content
		return l
	end
	local function box(text, x, y, w)
		local b = Instance.new("TextBox")
		b.BackgroundColor3 = theme.TextBox
		b.BorderColor3 = theme.Outline3
		b.ClearTextOnFocus = false
		b.TextColor3 = theme.Text
		b.Font = Enum.Font.SourceSans
		b.TextSize = 14
		b.Text = text
		b.Position = UDim2.new(0, x, 0, y)
		b.Size = UDim2.new(0, w, 0, 20)
		b.Parent = content
		return b
	end
	local function button(text, x, y, w)
		local b = Instance.new("TextButton")
		b.BackgroundColor3 = theme.Button
		b.BorderColor3 = theme.Outline2
		b.TextColor3 = theme.Text
		b.Font = Enum.Font.SourceSans
		b.TextSize = 14
		b.AutoButtonColor = true
		b.Text = text
		b.Position = UDim2.new(0, x, 0, y)
		b.Size = UDim2.new(0, w, 0, 22)
		b.Parent = content
		return b
	end

	ui.status = label("Status: stopped", 6, 18)
	label("Host", 30, 18)
	local hostBox = box(tostring(cfg().Host), 44, 28, 110)
	label("Port", 30, 18).Position = UDim2.new(0, 164, 0, 30)
	local portBox = box(tostring(cfg().Port), 196, 28, 60)
	ui.toggle = button("Connect", 8, 56, 100)
	local auto = button("Auto: " .. (cfg().AutoConnect and "on" or "off"), 116, 56, 100)
	ui.info = label("", 86, 90)

	hostBox.FocusLost:Connect(function()
		local t = hostBox.Text:match("^%s*(.-)%s*$")
		if t ~= "" then cfg().Host = t T.port = nil Dex.Main.SaveCurrentSettings() end
	end)
	portBox.FocusLost:Connect(function()
		local n = tonumber(portBox.Text)
		if n then cfg().Port = n T.port = nil Dex.Main.SaveCurrentSettings() end
	end)
	ui.toggle.MouseButton1Click:Connect(function()
		if T.running then T.stop() else T.start() end
	end)
	auto.MouseButton1Click:Connect(function()
		cfg().AutoConnect = not cfg().AutoConnect
		auto.Text = "Auto: " .. (cfg().AutoConnect and "on" or "off")
		Dex.Main.SaveCurrentSettings()
	end)
	refreshUI()
	task.spawn(function()
		while ui.status and ui.status.Parent do
			refreshUI()
			task.wait(1.5)
		end
	end)
end

B.MCP = {
	Start = function() T.start() end,
	Stop = function() T.stop() end,
	Bridge = B,
}
