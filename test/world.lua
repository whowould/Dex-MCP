-- Mock game world for the e2e test.
local function mk(class, name, parent, props)
	local i = Instance.new(class)
	i.Name = name
	for k, v in pairs(props or {}) do i[k] = v end
	i.Parent = parent
	return i
end

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local map = mk("Folder", "Map", workspace)
mk("Part", "Baseplate", map, { Anchored = true, Size = Vector3.new(512, 1, 512) })
mk("Part", "Door", map, { Position = Vector3.new(10, 5, 0) })
mk("Part", "Door", map) -- duplicate name on purpose
mk("Part", "Part With Space", map)
local dummy = mk("Model", "Dummy", workspace)
mk("Part", "Torso", dummy)
local cfg = mk("StringValue", "Config", workspace, { Value = "abc" })
cfg:SetAttribute("Level", 5)

local hit = mk("RemoteEvent", "Hit", RS)
local ask = mk("RemoteFunction", "Ask", RS)
local events = mk("Folder", "Events", RS)
mk("RemoteEvent", "Spam", events)

-- scripts
local ps = mk("Folder", "PlayerScripts", lp)
local combat = mk("LocalScript", "Combat", ps)
rawget(combat, "_p").Source = "local Hit = game.ReplicatedStorage.Hit\nHit:FireServer('swing', 1)\nprint('combat ready')\nlocal ANTICHEAT_KEY = 'xk93'\n"
local util = mk("ModuleScript", "Util", ps)
rawget(util, "_p").Source = "local M = {}\nfunction M.add(a, b) return a + b end\nreturn M\n"
local serverLogic = mk("Script", "ServerLogic", game:GetService("Players"))
rawget(serverLogic, "_p").Source = "print('server only')"

-- GC contents: a state table and closures with upvalues
__state = { coins = 1234, name = "Tester", inventory = { "sword", "shield" }, nested = { deep = { value = 99 } } }
local secret = { hp = 100 }
local function takeDamage(n) secret.hp = secret.hp - n return secret.hp end
local function heal(n) secret.hp = secret.hp + n return secret.hp end
__takeDamage, __heal, __secret = takeDamage, heal, secret
__fnames[takeDamage] = "takeDamage"
__fnames[heal] = "heal"
__constants[takeDamage] = { "hp", "Damage", 42 }
__constants[heal] = { "hp", "Heal" }
__fenv_script[takeDamage] = combat
__fenv_script[heal] = combat
__protos[takeDamage] = {}
__script_closures[combat] = takeDamage
__gc = { __state, __state.inventory, secret, takeDamage, heal, { coins = 55, other = true } }

-- connections
local btn = mk("TextButton", "BuyButton", __player_gui, { Text = "Buy sword" })
__clicks = 0
btn.MouseButton1Click:Connect(function() __clicks = __clicks + 1 end)
local sg = mk("ScreenGui", "HUD", __player_gui)
mk("TextLabel", "CoinsLabel", sg, { Text = "Coins: 1234" })
hit.OnClientEvent:Connect(function(...) __last_client_event = table.pack(...) end)
