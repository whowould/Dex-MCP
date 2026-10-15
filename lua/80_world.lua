-- 80_world: game/player/camera/GUI/physics info and interaction helpers
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local gm = game
local plr = Dex.plr

local function v3(v) return { v.X, v.Y, v.Z } end

local function pgetp(inst, name)
	local ok, v = pcall(function() return inst[name] end)
	if ok then return v end
	return nil
end

----------------------------------------------------------------------------------------------------
-- game / players
----------------------------------------------------------------------------------------------------
H.get_game_info = function(p)
	local out = {
		place_id = gm.PlaceId,
		game_id = gm.GameId,
		job_id = gm.JobId,
		place_version = pgetp(gm, "PlaceVersion"),
		creator_id = gm.CreatorId,
		creator_type = tostring(gm.CreatorType):gsub("Enum.CreatorType.", ""),
		private_server_id = pgetp(gm, "PrivateServerId"),
		private_server_owner_id = pgetp(gm, "PrivateServerOwnerId"),
		players = #service.Players:GetPlayers(),
		max_players = service.Players.MaxPlayers,
		streaming_enabled = pgetp(workspace, "StreamingEnabled"),
		gravity = workspace.Gravity,
		client_version = pcall(version) and version() or nil,
		is_studio = service.RunService:IsStudio(),
		executor = B.executorName(),
	}
	local ok, info = pcall(function() return service.MarketplaceService:GetProductInfo(gm.PlaceId) end)
	if ok and type(info) == "table" then
		out.name = info.Name
		out.description = B.trunc(info.Description or "", 500)
		out.creator = info.Creator and info.Creator.Name
		out.created = info.Created
		out.updated = info.Updated
	end
	return out
end

local function playerBrief(pl)
	local e = {
		name = pl.Name,
		display_name = pl.DisplayName,
		user_id = pl.UserId,
		team = pl.Team and pl.Team.Name or nil,
		account_age = pl.AccountAge,
		ref = B.ref(pl),
	}
	local ch = pl.Character
	if ch then
		e.character = B.pathOf(ch)
		local hum = ch:FindFirstChildOfClass("Humanoid")
		if hum then e.health = hum.Health e.max_health = hum.MaxHealth end
		local hrp = ch:FindFirstChild("HumanoidRootPart")
		if hrp then e.position = v3(hrp.Position) end
	end
	return e
end

H.get_players = function(p)
	local out = {}
	for _, pl in ipairs(service.Players:GetPlayers()) do out[#out + 1] = playerBrief(pl) end
	return { count = #out, players = out, local_player = plr.Name }
end

local function findPlayer(spec)
	if spec == nil or spec == "local" then return plr end
	if type(spec) == "number" then return service.Players:GetPlayerByUserId(spec) end
	local pl = service.Players:FindFirstChild(tostring(spec))
	if pl then return pl end
	local lower = tostring(spec):lower()
	for _, x in ipairs(service.Players:GetPlayers()) do
		if x.Name:lower():find(lower, 1, true) or x.DisplayName:lower():find(lower, 1, true) then return x end
	end
	error("player not found: " .. tostring(spec), 0)
end

H.get_character = function(p)
	local pl = findPlayer(p.player)
	local ch = pl.Character
	if not ch then return { player = pl.Name, character = NULL } end
	local out = { player = pl.Name, character = B.ser(ch) }
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum then
		out.humanoid = {
			health = hum.Health, max_health = hum.MaxHealth, walk_speed = hum.WalkSpeed,
			jump_power = hum.JumpPower, jump_height = hum.JumpHeight, hip_height = hum.HipHeight,
			state = tostring(hum:GetState()):gsub("Enum.HumanoidStateType.", ""),
			rig_type = tostring(hum.RigType):gsub("Enum.HumanoidRigType.", ""),
			move_direction = v3(hum.MoveDirection),
			auto_rotate = hum.AutoRotate,
			ref = B.ref(hum),
		}
	end
	local parts = {}
	for _, d in ipairs(ch:GetChildren()) do
		local e = { class = d.ClassName, name = d.Name, ref = B.ref(d) }
		if d:IsA("BasePart") then e.position = v3(d.Position) e.size = v3(d.Size) e.anchored = d.Anchored e.can_collide = d.CanCollide end
		parts[#parts + 1] = e
	end
	out.children = parts
	return out
end

H.get_local_player = function(p)
	local out = playerBrief(plr)
	local ch = plr.Character
	if ch then
		local hum = ch:FindFirstChildOfClass("Humanoid")
		if hum then
			out.humanoid = {
				walk_speed = hum.WalkSpeed, jump_power = hum.JumpPower, jump_height = hum.JumpHeight,
				state = tostring(hum:GetState()):gsub("Enum.HumanoidStateType.", ""), ref = B.ref(hum),
			}
		end
		local tools = {}
		for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") then tools[#tools + 1] = t.Name end end
		out.equipped_tools = tools
	end
	local bp = plr:FindFirstChildOfClass("Backpack")
	if bp then
		local tools = {}
		for _, t in ipairs(bp:GetChildren()) do tools[#tools + 1] = { name = t.Name, class = t.ClassName, ref = B.ref(t) } end
		out.backpack = tools
	end
	local ls = plr:FindFirstChild("leaderstats")
	if ls then
		local stats = {}
		for _, v in ipairs(ls:GetChildren()) do
			local ok, val = pcall(function() return v.Value end)
			stats[v.Name] = ok and B.ser(val) or NULL
		end
		out.leaderstats = B.obj(stats)
	end
	local attrs = plr:GetAttributes()
	if next(attrs) then out.attributes = B.serWith(attrs, { depth = 1 }).fields end
	local pg = plr:FindFirstChildOfClass("PlayerGui")
	if pg then
		local guis = {}
		for _, g in ipairs(pg:GetChildren()) do guis[#guis + 1] = g.Name .. " [" .. g.ClassName .. "]" end
		out.player_gui = guis
	end
	out.account_age = plr.AccountAge
	out.membership = tostring(plr.MembershipType):gsub("Enum.MembershipType.", "")
	return out
end

H.teleport = function(p)
	local ch = plr.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hrp then error("local character has no HumanoidRootPart", 0) end
	local cf
	if p.position then
		local pos = p.position
		cf = CFrame.new(pos[1], pos[2], pos[3])
	elseif p.target then
		local t = B.inst(p.target)
		if t:IsA("BasePart") then cf = t.CFrame
		elseif t:IsA("Model") then cf = t:GetPivot()
		elseif t:IsA("Attachment") then cf = t.WorldCFrame
		else error("target must be BasePart/Model/Attachment/position", 0) end
	else
		error("need position [x,y,z] or target", 0)
	end
	if p.offset then cf = cf + Vector3.new(p.offset[1] or 0, p.offset[2] or 0, p.offset[3] or 0) end
	local pl = p.player and findPlayer(p.player) or plr
	if pl ~= plr then error("can only teleport the local player", 0) end
	hrp.CFrame = cf
	return { ok = true, position = v3(cf.Position) }
end

----------------------------------------------------------------------------------------------------
-- camera / raycast
----------------------------------------------------------------------------------------------------
H.get_camera = function(p)
	local cam = workspace.CurrentCamera
	return {
		cframe = B.ser(cam.CFrame),
		position = v3(cam.CFrame.Position),
		look_vector = v3(cam.CFrame.LookVector),
		field_of_view = cam.FieldOfView,
		camera_type = tostring(cam.CameraType):gsub("Enum.CameraType.", ""),
		camera_subject = cam.CameraSubject and B.ser(cam.CameraSubject) or NULL,
		viewport = { cam.ViewportSize.X, cam.ViewportSize.Y },
	}
end

H.set_camera = function(p)
	local cam = workspace.CurrentCamera
	if p.field_of_view then cam.FieldOfView = p.field_of_view end
	if p.camera_type then cam.CameraType = Enum.CameraType[p.camera_type] end
	if p.subject then cam.CameraSubject = B.inst(p.subject) end
	if p.position and p.look_at then
		cam.CFrame = CFrame.lookAt(Vector3.new(unpack(p.position)), Vector3.new(unpack(p.look_at)))
	elseif p.cframe then
		cam.CFrame = B.de(p.cframe)
	end
	return H.get_camera({})
end

H.raycast = function(p)
	local origin = Vector3.new(unpack(p.origin))
	local dir = Vector3.new(unpack(p.direction))
	if p.length then dir = dir.Unit * p.length end
	local params = RaycastParams.new()
	if p.ignore then
		local list = {}
		for _, spec in ipairs(p.ignore) do list[#list + 1] = B.inst(spec) end
		params.FilterDescendantsInstances = list
		params.FilterType = Enum.RaycastFilterType.Exclude
	elseif p.include then
		local list = {}
		for _, spec in ipairs(p.include) do list[#list + 1] = B.inst(spec) end
		params.FilterDescendantsInstances = list
		params.FilterType = Enum.RaycastFilterType.Include
	end
	if p.ignore_water ~= nil then params.IgnoreWater = p.ignore_water end
	local res = workspace:Raycast(origin, dir, params)
	if not res then return { hit = false } end
	return { hit = true, result = B.ser(res) }
end

H.world_to_screen = function(p)
	local cam = workspace.CurrentCamera
	local out = {}
	for i, pos in ipairs(p.positions or { p.position }) do
		local sp, on = cam:WorldToViewportPoint(Vector3.new(unpack(pos)))
		out[i] = { x = sp.X, y = sp.Y, depth = sp.Z, on_screen = on }
	end
	return { points = out }
end

H.screen_to_ray = function(p)
	local cam = workspace.CurrentCamera
	local ray = cam:ViewportPointToRay(p.x, p.y)
	local out = { origin = v3(ray.Origin), direction = v3(ray.Direction) }
	if p.cast ~= false then
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { plr.Character }
		params.FilterType = Enum.RaycastFilterType.Exclude
		local res = workspace:Raycast(ray.Origin, ray.Direction * (p.length or 1000), params)
		out.hit = res and B.ser(res) or NULL
	end
	return out
end

H.get_mouse_target = function(p)
	local mouse = plr:GetMouse()
	local out = { x = mouse.X, y = mouse.Y }
	local t = mouse.Target
	out.target = t and B.ser(t) or NULL
	if mouse.Hit then out.hit_position = v3(mouse.Hit.Position) end
	out.target_surface = tostring(mouse.TargetSurface):gsub("Enum.NormalId.", "")
	return out
end

----------------------------------------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------------------------------------
local function guiRoot(which)
	which = which or "PlayerGui"
	if which == "PlayerGui" then return plr:WaitForChild("PlayerGui", 2) end
	if which == "CoreGui" then return service.CoreGui end
	if which == "gethui" then return B.need("gethui")() end
	if which == "StarterGui" then return service.StarterGui end
	return B.inst(which)
end

local function effectiveVisible(g)
	local cur = g
	while cur and cur ~= gm do
		local ok, v = pcall(function()
			if cur:IsA("GuiObject") then return cur.Visible end
			if cur:IsA("ScreenGui") or cur:IsA("LayerCollector") then return cur.Enabled end
			return true
		end)
		if ok and v == false then return false end
		cur = cur.Parent
	end
	return true
end

H.get_gui_tree = function(p)
	local root = guiRoot(p.root)
	if not root then error("no such GUI root", 0) end
	local depth = p.depth or 4
	local maxNodes = p.max_nodes or 300
	local lines, count, truncated = {}, 0, false
	local textM = p.text and B.matcher(p.text, "plain", true) or nil
	local function describe(g)
		local s = g.Name .. " [" .. g.ClassName .. "]"
		if g:IsA("GuiObject") then
			local flags = {}
			if not g.Visible then flags[#flags + 1] = "hidden" end
			local okT, tx = pcall(function() return g.Text end)
			if okT and type(tx) == "string" and tx ~= "" then flags[#flags + 1] = 'text="' .. B.trunc(tx:gsub("\n", " "), 60) .. '"' end
			if p.geometry then
				flags[#flags + 1] = string.format("pos=(%d,%d) size=(%d,%d)", g.AbsolutePosition.X, g.AbsolutePosition.Y, g.AbsoluteSize.X, g.AbsoluteSize.Y)
			end
			if #flags > 0 then s = s .. " {" .. table.concat(flags, ", ") .. "}"
			end
		elseif g:IsA("LayerCollector") then
			if not g.Enabled then s = s .. " {disabled}" end
		end
		if p.refs then s = s .. " #" .. B.ref(g) end
		return s
	end
	local function visibleOk(g)
		if not p.only_visible then return true end
		return effectiveVisible(g)
	end
	local function hasMatchingDesc(g)
		if not textM then return true end
		for _, d in ipairs(g:GetDescendants()) do
			local ok, tx = pcall(function() return d.Text end)
			if ok and type(tx) == "string" and textM(tx) then return true end
		end
		return false
	end
	local function rec(node, d, prefix)
		for _, k in ipairs(node:GetChildren()) do
			if count >= maxNodes then truncated = true return end
			if visibleOk(k) then
				local okText = true
				if textM then
					local ok, tx = pcall(function() return k.Text end)
					okText = (ok and type(tx) == "string" and textM(tx)) or hasMatchingDesc(k)
				end
				if okText then
					count = count + 1
					lines[#lines + 1] = prefix .. describe(k)
					if d < depth then rec(k, d + 1, prefix .. "  ") end
				end
			end
		end
	end
	lines[1] = describe(root)
	rec(root, 1, "  ")
	return { tree = table.concat(lines, "\n"), nodes = count, truncated = truncated }
end

H.find_gui = function(p)
	local root = guiRoot(p.root)
	local textM = p.text and B.matcher(p.text, p.text_mode, p.case_insensitive ~= false) or nil
	local nameM = p.name and B.matcher(p.name, p.name_mode, p.case_insensitive ~= false) or nil
	local out, matched = {}, 0
	for i, g in ipairs(root:GetDescendants()) do
		if g:IsA("GuiObject") then
			local ok = true
			if p.class and not g:IsA(p.class) then ok = false end
			if ok and nameM and not nameM(g.Name) then ok = false end
			if ok and textM then
				local okT, tx = pcall(function() return g.Text end)
				if not (okT and type(tx) == "string" and textM(tx)) then ok = false end
			end
			if ok and p.visible_only and not effectiveVisible(g) then ok = false end
			if ok then
				matched = matched + 1
				if #out < (p.limit or 50) then
					local e = B.summ(g, false)
					e.path = B.instPath(g)
					e.visible = effectiveVisible(g)
					e.abs_pos = { g.AbsolutePosition.X, g.AbsolutePosition.Y }
					e.abs_size = { g.AbsoluteSize.X, g.AbsoluteSize.Y }
					out[#out + 1] = e
				end
			end
		end
		if i % 3000 == 0 then B.yield() end
	end
	return { matched = matched, returned = #out, results = out }
end

local BUTTON_SIGNALS = { "MouseButton1Down", "MouseButton1Click", "MouseButton1Up", "Activated" }

H.click_gui = function(p)
	local g = B.inst(p.target)
	local fired = {}
	local sigs = p.signals or BUTTON_SIGNALS
	for _, name in ipairs(sigs) do
		local ok, sig = pcall(function() return g[name] end)
		if ok and typeof(sig) == "RBXScriptSignal" then
			local n = 0
			if C.getconnections then
				local ok2, conns = pcall(C.getconnections, sig)
				if ok2 then
					for _, c in ipairs(conns) do
						if pcall(function() c:Fire() end) then n = n + 1 end
					end
				end
			elseif C.firesignal then
				if pcall(C.firesignal, sig) then n = 1 end
			end
			fired[name] = n
		end
	end
	return { ok = true, fired = B.obj(fired) }
end

H.set_gui_text = function(p)
	local g = B.inst(p.target)
	g.Text = p.text
	local focusLost = 0
	if p.submit and g:IsA("TextBox") then
		if C.getconnections then
			local ok, conns = pcall(C.getconnections, g.FocusLost)
			if ok then
				for _, c in ipairs(conns) do if pcall(function() c:Fire(true) end) then focusLost = focusLost + 1 end end
			end
		elseif C.firesignal then
			pcall(C.firesignal, g.FocusLost, true)
			focusLost = 1
		end
	end
	return { ok = true, text = g.Text, focus_lost_handlers_fired = focusLost }
end

----------------------------------------------------------------------------------------------------
-- interaction
----------------------------------------------------------------------------------------------------
H.fire_click_detector = function(p)
	local cd = B.inst(p.target)
	if not cd:IsA("ClickDetector") then
		local found = cd:FindFirstChildWhichIsA("ClickDetector", true)
		if not found then error("no ClickDetector at/below " .. cd.ClassName, 0) end
		cd = found
	end
	B.need("fireclickdetector")(cd, p.distance or 0, p.event)
	return { ok = true, detector = B.ser(cd) }
end

H.fire_proximity_prompt = function(p)
	local pp = B.inst(p.target)
	if not pp:IsA("ProximityPrompt") then
		local found = pp:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not found then error("no ProximityPrompt at/below " .. pp.ClassName, 0) end
		pp = found
	end
	B.need("fireproximityprompt")(pp, p.hold)
	return { ok = true, prompt = B.ser(pp) }
end

H.fire_touch_interest = function(p)
	local part = B.inst(p.part)
	local ch = plr.Character
	local with = p.target and B.inst(p.target) or (ch and ch:FindFirstChild("HumanoidRootPart"))
	if not with then error("no touching part available", 0) end
	local f = B.need("firetouchinterest")
	f(with, part, 0)
	task.wait(p.hold or 0.05)
	f(with, part, 1)
	return { ok = true }
end

H.get_network_owner = function(p)
	local part = B.inst(p.target)
	local out = { part = B.ser(part) }
	if C.isnetworkowner then
		local ok, r = pcall(C.isnetworkowner, part)
		if ok then out.is_local_network_owner = r end
	end
	if C.gethiddenproperty then
		local ok, r = pcall(C.gethiddenproperty, part, "NetworkOwnerV3")
		if ok then out.network_owner_v3 = r end
	end
	local okA, anch = pcall(function() return part.Anchored end)
	if okA then out.anchored = anch end
	return out
end

----------------------------------------------------------------------------------------------------
-- stats / marketplace / sounds
----------------------------------------------------------------------------------------------------
H.get_stats = function(p)
	local out = {}
	local St = service.Stats
	local function item(path)
		local ok, v = pcall(function()
			local cur = St
			for part in path:gmatch("[^/]+") do cur = cur[part] end
			return cur:GetValue()
		end)
		return ok and v or nil
	end
	out.ping_ms = item("Network/ServerStatsItem/Data Ping")
	out.heartbeat_ms = item("Workspace/Heartbeat")
	out.receive_kbps = item("Network/ServerStatsItem/Receive Throughput")
	out.send_kbps = item("Network/ServerStatsItem/Send Throughput")
	out.total_memory_mb = pcall(St.GetTotalMemoryUsageMb, St) and St:GetTotalMemoryUsageMb() or nil
	out.instance_count = pcall(function() return St.InstanceCount end) and St.InstanceCount or nil
	out.primitive_count = pcall(function() return St.PrimitivesCount end) and St.PrimitivesCount or nil
	local ok, fps = pcall(function() return 1 / service.RunService.Heartbeat:Wait() end)
	if ok then out.fps = fps end
	return out
end

H.get_marketplace_info = function(p)
	local ms = service.MarketplaceService
	local it = Enum.InfoType[p.info_type or "Asset"]
	local ok, info = pcall(ms.GetProductInfo, ms, p.asset_id, it)
	if not ok then error("GetProductInfo failed: " .. tostring(info), 0) end
	return { info = B.serWith(info, { depth = 3, maxItems = 40, maxStr = 600 }) }
end

H.get_sounds = function(p)
	local out = {}
	for _, root in ipairs({ workspace, service.SoundService, plr }) do
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("Sound") and (not p.playing_only or d.Playing) then
				out[#out + 1] = { ref = B.ref(d), path = B.instPath(d), sound_id = d.SoundId, playing = d.Playing, volume = d.Volume, time_position = d.TimePosition, looped = d.Looped }
				if #out >= (p.limit or 100) then break end
			end
		end
	end
	return { sounds = out }
end

H.get_lighting = function(p)
	local L = service.Lighting
	local out = {
		clock_time = L.ClockTime, brightness = L.Brightness, ambient = B.ser(L.Ambient),
		outdoor_ambient = B.ser(L.OutdoorAmbient), fog_end = L.FogEnd, fog_color = B.ser(L.FogColor),
		technology = tostring(L.Technology):gsub("Enum.Technology.", ""), global_shadows = L.GlobalShadows,
	}
	local fx = {}
	for _, c in ipairs(L:GetChildren()) do fx[#fx + 1] = c.Name .. " [" .. c.ClassName .. "]" end
	out.children = fx
	return out
end

----------------------------------------------------------------------------------------------------
-- input simulation (VirtualInputManager)
----------------------------------------------------------------------------------------------------
local function vim()
	local ok, v = pcall(function() return gm:GetService("VirtualInputManager") end)
	if ok and v then return v end
	return nil
end

H.send_input = function(p)
	local kind = p.kind
	local V = vim()
	local hold = p.hold or 0.05
	if kind == "key" then
		if not V then error("VirtualInputManager is unavailable in this executor/identity", 0) end
		local kc = Enum.KeyCode[p.key]
		if not kc then error("unknown KeyCode '" .. tostring(p.key) .. "' (e.g. E, Space, LeftShift, One)", 0) end
		local sequence = p.action or "tap"
		if sequence == "tap" or sequence == "down" then V:SendKeyEvent(true, kc, false, gm) end
		if sequence == "tap" then task.wait(hold) end
		if sequence == "tap" or sequence == "up" then V:SendKeyEvent(false, kc, false, gm) end
		return { ok = true, key = p.key, action = sequence }
	elseif kind == "text" then
		-- type a string: tap each character's KeyCode when one exists
		if not V then error("VirtualInputManager is unavailable in this executor/identity", 0) end
		local typed = 0
		for ch in tostring(p.text):gmatch(".") do
			local name = ch:match("%a") and ch:upper() or (ch == " " and "Space") or nil
			local kc = name and Enum.KeyCode[name]
			if kc then
				V:SendKeyEvent(true, kc, false, gm)
				task.wait(p.delay or 0.03)
				V:SendKeyEvent(false, kc, false, gm)
				typed = typed + 1
			end
		end
		return { ok = true, typed = typed }
	elseif kind == "mouse_click" or kind == "mouse_down" or kind == "mouse_up" then
		local button = (p.button or 1) - 1 -- 0 left, 1 right, 2 middle
		local x, y = p.x, p.y
		if V and x and y then
			if kind ~= "mouse_up" then V:SendMouseButtonEvent(x, y, button, true, gm, 0) end
			if kind == "mouse_click" then task.wait(hold) end
			if kind ~= "mouse_down" then V:SendMouseButtonEvent(x, y, button, false, gm, 0) end
			return { ok = true, via = "VirtualInputManager" }
		end
		local f = B.pick("mouse1click", "mouse1press")
		if kind == "mouse_click" and f then f() return { ok = true, via = "mouse1click" } end
		error("need x,y and VirtualInputManager (or the executor's mouse1click) to click", 0)
	elseif kind == "mouse_move" then
		if V then
			V:SendMouseMoveEvent(p.x, p.y, gm)
			return { ok = true, via = "VirtualInputManager" }
		end
		local f = B.pick("mousemoveabs")
		if f then f(p.x, p.y) return { ok = true, via = "mousemoveabs" } end
		error("no way to move the mouse (VirtualInputManager/mousemoveabs unavailable)", 0)
	elseif kind == "mouse_scroll" then
		if V then
			V:SendMouseWheelEvent(p.x or 0, p.y or 0, (p.amount or 1) > 0, gm)
			return { ok = true, via = "VirtualInputManager" }
		end
		local f = B.pick("mousescroll")
		if f then f(p.amount or 1) return { ok = true, via = "mousescroll" } end
		error("no way to scroll (VirtualInputManager/mousescroll unavailable)", 0)
	end
	error("kind must be key|text|mouse_click|mouse_down|mouse_up|mouse_move|mouse_scroll", 0)
end
