--[[
	Dex++
	Version 3.0
	
	Developed by Chillz
	
	Dex++ is a revival of Moon's Dex, made to fulfill Moon's Dex prophecy.
]]

local selection
local nodes = {}

local oldgame = game
local game = workspace.Parent

cloneref = cloneref or function(ref)
	if not getreg then return ref end
	
	local InstanceList
	
	local a = Instance.new("Part")
	for _, c in pairs(getreg()) do
		if type(c) == "table" and #c then
			if rawget(c, "__mode") == "kvs" then
				for d, e in pairs(c) do
					if e == a then
						InstanceList = c
						break
					end
				end
			end
		end
	end
	local f = {}
	function f.invalidate(g)
		if not InstanceList then
			return
		end
		for b, c in pairs(InstanceList) do
			if c == g then
				InstanceList[b] = nil
				return g
			end
		end
	end
	return f.invalidate
end

local EmbeddedModules = {
["Console"] = function()
--[[
	Console Module
]]
-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local function main()
	local Console = {}

	local window,ConsoleFrame

	local OutputLimit = 500 -- Same as Roblox Console.


	-- Instances: 29 | Scripts: 1 | Modules: 1 | Tags: 0
	local G2L = {};

	-- StarterGui.ScreenGui
	window = Lib.Window.new()
	window:SetTitle("Console")
	window:Resize(500,400)
	Console.Window = window

	-- StarterGui.ScreenGui.Console
	ConsoleFrame = Instance.new("ImageButton", window.GuiElems.Content);
	ConsoleFrame["BorderSizePixel"] = 0;
	ConsoleFrame["AutoButtonColor"] = false;
	ConsoleFrame["BackgroundTransparency"] = 1;
	ConsoleFrame["BackgroundColor3"] = Color3.fromRGB(47, 47, 47);
	ConsoleFrame["Selectable"] = false;
	ConsoleFrame["Size"] = UDim2.new(1,0,1,0);
	ConsoleFrame["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	ConsoleFrame["Name"] = [[Console]];
	ConsoleFrame["Position"] = UDim2.new(0,0,0,0);


	-- StarterGui.ScreenGui.Console.CommandLine
	G2L["3"] = Lib.Frame.new().Gui--Instance.new("Frame", ConsoleFrame);
	G2L["3"].Parent = ConsoleFrame
	G2L["3"]["BorderSizePixel"] = 0;
	G2L["3"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
	G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 1);
	G2L["3"]["ClipsDescendants"] = true;
	G2L["3"]["Size"] = UDim2.new(1, -8, 0, 22);
	G2L["3"]["Position"] = UDim2.new(0.5, 0, 1, -5);
	G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["3"]["Name"] = [[CommandLine]];


	-- StarterGui.ScreenGui.Console.CommandLine.UIStroke
	G2L["4"] = Instance.new("UIStroke", G2L["3"]);
	G2L["4"]["Transparency"] = 0.65;
	G2L["4"]["Thickness"] = 1.25;


	-- StarterGui.ScreenGui.Console.CommandLine.ScrollingFrame
	G2L["5"] = Instance.new("ScrollingFrame", G2L["3"]);
	G2L["5"]["Active"] = true;
	G2L["5"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
	G2L["5"]["BorderSizePixel"] = 0;
	G2L["5"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
	G2L["5"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
	G2L["5"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
	G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5"]["HorizontalScrollBarInset"] = Enum.ScrollBarInset.Always;
	G2L["5"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
	G2L["5"]["AutomaticCanvasSize"] = Enum.AutomaticSize.X;
	G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
	G2L["5"]["ScrollBarImageColor3"] = Color3.fromRGB(57, 57, 57);
	G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["5"]["ScrollBarThickness"] = 2;
	G2L["5"]["BackgroundTransparency"] = 1;

	-- StarterGui.ScreenGui.Console.CommandLine.ScrollingFrame.TextBox
	G2L["6"] = Instance.new("TextBox", G2L["5"]);
	G2L["6"]["CursorPosition"] = -1;
	G2L["6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["6"]["PlaceholderColor3"] = Color3.fromRGB(211, 211, 211);
	G2L["6"]["BorderSizePixel"] = 0;
	G2L["6"]["TextSize"] = 13;
	G2L["6"]["TextColor3"] = Color3.fromRGB(211, 211, 211);
	G2L["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["6"]["AutomaticSize"] = Enum.AutomaticSize.X;
	G2L["6"]["ClearTextOnFocus"] = false;
	G2L["6"]["PlaceholderText"] = [[Run a command]];
	G2L["6"]["Size"] = UDim2.new(0, 246, 0, 22);
	G2L["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["6"]["Text"] = [[]];
	G2L["6"]["BackgroundTransparency"] = 1;


	-- StarterGui.ScreenGui.Console.CommandLine.ScrollingFrame.TextBox.UIPadding
	G2L["7"] = Instance.new("UIPadding", G2L["6"]);
	G2L["7"]["PaddingLeft"] = UDim.new(0, 7);


	-- StarterGui.ScreenGui.Console.CommandLine.ScrollingFrame.Highlight
	G2L["8"] = Instance.new("TextLabel", G2L["5"]);
	G2L["8"]["Interactable"] = false;
	G2L["8"]["ZIndex"] = 2;
	G2L["8"]["BorderSizePixel"] = 0;
	G2L["8"]["TextSize"] = 13;
	G2L["8"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["8"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8"]["BackgroundTransparency"] = 1;
	G2L["8"]["RichText"] = true;
	G2L["8"]["Size"] = UDim2.new(0, 246, 0, 22);
	G2L["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["8"]["Text"] = [[]];
	G2L["8"]["Selectable"] = true;
	G2L["8"]["AutomaticSize"] = Enum.AutomaticSize.X;
	G2L["8"]["Name"] = [[Highlight]];


	-- StarterGui.ScreenGui.Console.CommandLine.ScrollingFrame.Highlight.UIPadding
	G2L["9"] = Instance.new("UIPadding", G2L["8"]);
	G2L["9"]["PaddingLeft"] = UDim.new(0, 7);

	G2L["backgroundOutput"] = Instance.new("Frame", ConsoleFrame);
	G2L["backgroundOutput"]["BorderSizePixel"] = 0;
	G2L["backgroundOutput"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
	G2L["backgroundOutput"]["Name"] = [[BackgroundOutput]];
	G2L["backgroundOutput"]["AnchorPoint"] = Vector2.new(0, 0);
	G2L["backgroundOutput"]["Size"] = UDim2.new(1, -8, 1, -55);
	G2L["backgroundOutput"]["Position"] = UDim2.new(0, 4, 0, 23);
	G2L["backgroundOutput"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["backgroundOutput"]["ZIndex"] = 1;

	local scrollbar = Lib.ScrollBar.new()
	scrollbar.Gui.Parent = ConsoleFrame
	scrollbar.Gui.Size = UDim2.new(0, 16, 1, -55);
	scrollbar.Gui.Position = UDim2.new(1, -20,0, 23);
	scrollbar.Gui.Up.ZIndex = 3
	scrollbar.Gui.Down.ZIndex = 3

	-- StarterGui.ScreenGui.Console.Output
	G2L["a"] = Instance.new("ScrollingFrame", ConsoleFrame);
	G2L["a"]["Active"] = true;
	G2L["a"]["BorderSizePixel"] = 0;
	G2L["a"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
	G2L["a"]["TopImage"] = '';
	G2L["a"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
	G2L["a"].BackgroundTransparency = 1
	G2L["a"]["Name"] = [[Output]];
	G2L["a"]["ScrollBarImageTransparency"] = 0;
	G2L["a"]["BottomImage"] = '';
	G2L["a"]["AnchorPoint"] = Vector2.new(0, 0);
	G2L["a"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
	G2L["a"]["Size"] = UDim2.new(1, -8, 1, -55);
	G2L["a"]["Position"] = UDim2.new(0, 4, 0, 23);
	G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["a"].ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
	G2L["a"]["ScrollBarThickness"] = 16;
	G2L["a"]["ZIndex"] = 1;

	G2L["a"]:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if G2L["a"].AbsoluteCanvasSize ~= G2L["a"].AbsoluteWindowSize then
			scrollbar.Gui.Visible = true
		else
			scrollbar.Gui.Visible = false
		end
	end)

	-- StarterGui.ScreenGui.Console.Output.UIListLayout
	G2L["b"] = Instance.new("UIListLayout", G2L["a"]);
	G2L["b"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


	-- StarterGui.ScreenGui.Console.Output.UIStroke
	G2L["c"] = Instance.new("UIStroke", G2L["a"]);
	G2L["c"]["Transparency"] = 0.7;
	G2L["c"]["Thickness"] = 1.25;
	G2L["c"]["Color"] = Color3.fromRGB(12, 12, 12);


	-- StarterGui.ScreenGui.Console.Output.OutputTextSize
	G2L["d"] = Instance.new("NumberValue", G2L["a"]);
	G2L["d"]["Name"] = [[OutputTextSize]];
	G2L["d"]["Value"] = 15;


	-- StarterGui.ScreenGui.Console.Output.OutputLimit
	G2L["e"] = Instance.new("NumberValue", G2L["a"]);
	G2L["e"]["Name"] = [[OutputLimit]];
	G2L["e"]["Value"] = OutputLimit;


	-- StarterGui.ScreenGui.Console.Output.UIPadding
	G2L["f"] = Instance.new("UIPadding", G2L["a"]);
	G2L["f"]["PaddingTop"] = UDim.new(0, 2);


	-- StarterGui.ScreenGui.Console.TextSizeBox
	G2L["10"] = Instance.new("Frame", ConsoleFrame);
	G2L["10"]["BorderSizePixel"] = 0;
	G2L["10"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
	G2L["10"]["ClipsDescendants"] = true;
	G2L["10"]["Size"] = UDim2.new(0, 37, 0, 15);
	G2L["10"]["Position"] = UDim2.new(0, 4, 0, 4);
	G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["10"]["Name"] = [[TextSizeBox]];


	-- StarterGui.ScreenGui.Console.TextSizeBox.TextBox
	G2L["11"] = Instance.new("TextBox", G2L["10"]);
	G2L["11"]["PlaceholderColor3"] = Color3.fromRGB(108, 108, 108);
	G2L["11"]["BorderSizePixel"] = 0;
	G2L["11"]["TextWrapped"] = true;
	G2L["11"]["TextSize"] = 15;
	G2L["11"]["TextColor3"] = Color3.fromRGB(211, 211, 211);
	G2L["11"]["TextScaled"] = true;
	G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["11"]["PlaceholderText"] = [[Size]];
	G2L["11"]["Size"] = UDim2.new(1, 0, 1, 0);
	G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["11"]["Text"] = [[]];
	G2L["11"]["BackgroundTransparency"] = 1;


	-- StarterGui.ScreenGui.Console.TextSizeBox.TextBox.UIPadding
	G2L["12"] = Instance.new("UIPadding", G2L["11"]);
	G2L["12"]["PaddingTop"] = UDim.new(0, 2);
	G2L["12"]["PaddingRight"] = UDim.new(0, 5);
	G2L["12"]["PaddingLeft"] = UDim.new(0, 5);
	G2L["12"]["PaddingBottom"] = UDim.new(0, 2);


	-- StarterGui.ScreenGui.Console.TextSizeBox.UIStroke
	G2L["13"] = Instance.new("UIStroke", G2L["10"]);
	G2L["13"]["Transparency"] = 0.65;
	G2L["13"]["Thickness"] = 1.25;


	-- StarterGui.ScreenGui.Console.Clear
	G2L["14"] = Instance.new("ImageButton", ConsoleFrame);
	G2L["14"]["BorderSizePixel"] = 0;
	G2L["14"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
	G2L["14"]["Size"] = UDim2.new(0, 37, 0, 15);
	G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["14"]["Name"] = [[Clear]];
	G2L["14"]["Position"] = UDim2.new(1, -42, 0, 4);


	-- StarterGui.ScreenGui.Console.Clear.TextLabel
	G2L["15"] = Instance.new("TextLabel", G2L["14"]);
	G2L["15"]["TextWrapped"] = true;
	G2L["15"]["Interactable"] = false;
	G2L["15"]["BorderSizePixel"] = 0;
	G2L["15"]["TextSize"] = 20;
	G2L["15"]["TextScaled"] = true;
	G2L["15"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["15"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["15"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["15"]["BackgroundTransparency"] = 1;
	G2L["15"]["Size"] = UDim2.new(1, 0, 1, 0);
	G2L["15"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["15"]["Text"] = [[Clear]];


	-- StarterGui.ScreenGui.Console.Clear.UIPadding
	G2L["16"] = Instance.new("UIPadding", G2L["14"]);
	G2L["16"]["PaddingTop"] = UDim.new(0, 1);
	G2L["16"]["PaddingBottom"] = UDim.new(0, 1);


	-- StarterGui.ScreenGui.Console.OutputTemplate
	G2L["17"] = Instance.new("TextBox", ConsoleFrame);
	G2L["17"]["Visible"] = false;
	G2L["17"]["Active"] = false;
	G2L["17"]["Name"] = [[OutputTemplate]];
	G2L["17"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["17"]["BorderSizePixel"] = 0;
	G2L["17"]["TextEditable"] = false;
	G2L["17"]["TextWrapped"] = true;
	G2L["17"]["TextSize"] = 15;
	G2L["17"]["TextColor3"] = Color3.fromRGB(171, 171, 171);
	G2L["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["17"]["RichText"] = true;
	G2L["17"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["17"]["AutomaticSize"] = Enum.AutomaticSize.Y;
	G2L["17"]["Selectable"] = false;
	G2L["17"]["ClearTextOnFocus"] = false;
	G2L["17"]["Size"] = UDim2.new(1, 0, 0, 1);
	G2L["17"]["Position"] = UDim2.new(0, 20, 0, 0);
	G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["17"]["Text"] = [[(timestamp) <font color="rgb(255, 255, 255)">Output</font>]];
	G2L["17"]["BackgroundTransparency"] = 1;


	-- StarterGui.ScreenGui.Console.OutputTemplate.UIPadding
	G2L["18"] = Instance.new("UIPadding", G2L["17"]);
	G2L["18"]["PaddingRight"] = UDim.new(0, 6);
	G2L["18"]["PaddingLeft"] = UDim.new(0, 6);


	-- StarterGui.ScreenGui.Console.CtrlScroll
	G2L["19"] = Instance.new("ImageButton", ConsoleFrame);
	G2L["19"]["BorderSizePixel"] = 0;
	G2L["19"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
	G2L["19"]["Size"] = UDim2.new(0, 60, 0, 15);
	G2L["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["19"]["Name"] = [[CtrlScroll]];
	G2L["19"]["Position"] = UDim2.new(0, 46, 0, 4);


	-- StarterGui.ScreenGui.Console.CtrlScroll.TextLabel
	G2L["1a"] = Instance.new("TextLabel", G2L["19"]);
	G2L["1a"]["TextWrapped"] = true;
	G2L["1a"]["Interactable"] = false;
	G2L["1a"]["BorderSizePixel"] = 0;
	G2L["1a"]["TextSize"] = 20;
	G2L["1a"]["TextScaled"] = true;
	G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["1a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1a"]["BackgroundTransparency"] = 1;
	G2L["1a"]["Size"] = UDim2.new(1, 0, 1, 0);
	G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["1a"]["Text"] = [[Ctrl Scroll]];


	-- StarterGui.ScreenGui.Console.CtrlScroll.UIPadding
	G2L["1b"] = Instance.new("UIPadding", G2L["19"]);
	G2L["1b"]["PaddingTop"] = UDim.new(0, 1);
	G2L["1b"]["PaddingBottom"] = UDim.new(0, 1);

	-- StarterGui.ScreenGui.Console.AutoScroll
	G2L["20"] = Instance.new("ImageButton", ConsoleFrame);
	G2L["20"]["BorderSizePixel"] = 0;
	G2L["20"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
	G2L["20"]["Size"] = UDim2.new(0, 60, 0, 15);
	G2L["20"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["20"]["Name"] = [[AutoScroll]];
	G2L["20"]["Position"] = UDim2.new(0, 110, 0, 4);


	-- StarterGui.ScreenGui.Console.AutoScroll.TextLabel
	G2L["1e"] = Instance.new("TextLabel", G2L["20"]);
	G2L["1e"]["TextWrapped"] = true;
	G2L["1e"]["Interactable"] = false;
	G2L["1e"]["BorderSizePixel"] = 0;
	G2L["1e"]["TextSize"] = 20;
	G2L["1e"]["TextScaled"] = true;
	G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["1e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1e"]["BackgroundTransparency"] = 1;
	G2L["1e"]["Size"] = UDim2.new(1, 0, 1, 0);
	G2L["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["1e"]["Text"] = [[Auto Scroll]];


	-- StarterGui.ScreenGui.Console.AutoScroll.UIPadding
	G2L["1f"] = Instance.new("UIPadding", G2L["20"]);
	G2L["1f"]["PaddingTop"] = UDim.new(0, 1);
	G2L["1f"]["PaddingBottom"] = UDim.new(0, 1);


	-- StarterGui.ScreenGui.ConsoleHandler
	G2L["1c"] = Instance.new("LocalScript", G2L["1"]);
	G2L["1c"]["Name"] = [[ConsoleHandler]];


	-- StarterGui.ScreenGui.ConsoleHandler.SyntaxHighlighter
	G2L["1d"] = Instance.new("ModuleScript", G2L["1c"]);
	G2L["1d"]["Name"] = [[SyntaxHighlighter]];


	-- Require G2L wrapper
	local G2L_REQUIRE = require;
	local G2L_MODULES = {};
	local function require(Module)
		local ModuleState = G2L_MODULES[Module];
		if ModuleState then
			if not ModuleState.Required then
				ModuleState.Required = true;
				ModuleState.Value = ModuleState.Closure();
			end
			return ModuleState.Value;
		end;
		return G2L_REQUIRE(Module);
	end

	G2L_MODULES[G2L["1d"]] = {
		Closure = function()
			local script = G2L["1d"];local highlighter = {}
			local keywords = {
				lua = {
					"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
					"local", "return", "function", "export"
				},
				rbx = {
					"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
					"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
					"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
					"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
					"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
				},
				exploit = {
					"hookmetamethod", "hookfunction", "getgc", "filtergc", "Drawing", "getgenv", "getsenv", "getrenv", "getfenv", "setfenv",
					"decompile", "saveinstance", "getrawmetatable", "setrawmetatable", "checkcaller", "cloneref", "clonefunction",
					"iscclosure", "islclosure", "isexecutorclosure", "newcclosure", "getfunctionhash", "crypt", "writefile", "appendfile", "loadfile", "readfile", "listfiles",
					"makefolder", "isfolder", "isfile", "delfile", "delfolder", "getcustomasset", "fireclickdetector", "firetouchinterest", "fireproximityprompt"
				},
				operators = {
					"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"
				}
			}

			local colors = {
				numbers = Color3.fromRGB(255, 198, 0),
				boolean = Color3.fromRGB(255, 198, 0),
				operator = Color3.fromRGB(204, 204, 204),
				lua = Color3.fromRGB(132, 214, 247),
				exploit = Color3.fromRGB(171, 84, 247),
				rbx = Color3.fromRGB(248, 109, 124),
				str = Color3.fromRGB(173, 241, 132),
				comment = Color3.fromRGB(102, 102, 102),
				null = Color3.fromRGB(255, 198, 0),
				call = Color3.fromRGB(253, 251, 172),
				self_call = Color3.fromRGB(253, 251, 172),
				local_color = Color3.fromRGB(248, 109, 115),
				function_color = Color3.fromRGB(248, 109, 115),
				self_color = Color3.fromRGB(248, 109, 115),
				local_property = Color3.fromRGB(97, 161, 241),
			}

			local function createKeywordSet(keywords)
				local keywordSet = {}
				for _, keyword in ipairs(keywords) do
					keywordSet[keyword] = true
				end
				return keywordSet
			end

			local luaSet = createKeywordSet(keywords.lua)
			local exploitSet = createKeywordSet(keywords.exploit)
			local rbxSet = createKeywordSet(keywords.rbx)
			local operatorsSet = createKeywordSet(keywords.operators)

			local function getHighlight(tokens, index)
				local token = tokens[index]

				if colors[token .. "_color"] then
					return colors[token .. "_color"]
				end

				if tonumber(token) then
					return colors.numbers
				elseif token == "nil" then
					return colors.null
				elseif token:sub(1, 2) == "--" then
					return colors.comment
				elseif operatorsSet[token] then
					return colors.operator
				elseif luaSet[token] then
					return colors.rbx
				elseif rbxSet[token] then
					return colors.lua
				elseif exploitSet[token] then
					return colors.exploit
				elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
					return colors.str
				elseif token == "true" or token == "false" then
					return colors.boolean
				end

				if tokens[index + 1] == "(" then
					if tokens[index - 1] == ":" then
						return colors.self_call
					end

					return colors.call
				end

				if tokens[index - 1] == "." then
					if tokens[index - 2] == "Enum" then
						return colors.rbx
					end

					return colors.local_property
				end
			end

			function highlighter.run(source)
				local tokens = {}
				local currentToken = ""

				local inString = false
				local inComment = false
				local commentPersist = false

				for i = 1, #source do
					local character = source:sub(i, i)

					if inComment then
						if character == "\n" and not commentPersist then
							table.insert(tokens, currentToken)
							table.insert(tokens, character)
							currentToken = ""

							inComment = false
						elseif source:sub(i - 1, i) == "]]" and commentPersist then
							currentToken ..= "]"

							table.insert(tokens, currentToken)
							currentToken = ""

							inComment = false
							commentPersist = false
						else
							currentToken = currentToken .. character
						end
					elseif inString then
						if character == inString and source:sub(i-1, i-1) ~= "\\" or character == "\n" then
							currentToken = currentToken .. character
							inString = false
						else
							currentToken = currentToken .. character
						end
					else
						if source:sub(i, i + 1) == "--" then
							table.insert(tokens, currentToken)
							currentToken = "-"
							inComment = true
							commentPersist = source:sub(i + 2, i + 3) == "[["
						elseif character == "\"" or character == "\'" then
							table.insert(tokens, currentToken)
							currentToken = character
							inString = character
						elseif operatorsSet[character] then
							table.insert(tokens, currentToken)
							table.insert(tokens, character)
							currentToken = ""
						elseif character:match("[%w_]") then
							currentToken = currentToken .. character
						else
							table.insert(tokens, currentToken)
							table.insert(tokens, character)
							currentToken = ""
						end
					end
				end

				table.insert(tokens, currentToken)

				local highlighted = {}

				for i, token in ipairs(tokens) do
					local highlight = getHighlight(tokens, i)

					if highlight then
						local syntax = string.format("<font color = \"#%s\">%s</font>", highlight:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))

						table.insert(highlighted, syntax)
					else
						table.insert(highlighted, token)
					end
				end

				return table.concat(highlighted)
			end

			return highlighter
		end;
	};

	Console.Init = function()
		-- StarterGui.ScreenGui.ConsoleHandler

		local CtrlScroll = false
		local AutoScroll = false

		local LogService = game:GetService("LogService")
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Mouse = LocalPlayer:GetMouse()
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")

		local Console = ConsoleFrame
		local SyntaxHighlightingModule = require(G2L["1c"].SyntaxHighlighter)
		local OutputTextSize = Console.Output.OutputTextSize

		local function Tween(obj, info, prop)
			local tween = game:GetService("TweenService"):Create(obj, info, prop)
			tween:Play()
			return tween
		end



		-- MOUSE STUFFS

		if CtrlScroll == true then
			Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
		elseif CtrlScroll == false then
			Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
		end
		Console.CtrlScroll.MouseButton1Click:Connect(function()
			CtrlScroll = not CtrlScroll
			if CtrlScroll == true then
				Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
			elseif CtrlScroll == false then
				Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
			end
		end)

		local IsHoldingCTRL = false
		UserInputService.InputBegan:Connect(function(input, gameproc)
			if not gameproc then
				if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
					IsHoldingCTRL = true
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input, gameproc)
			if not gameproc then
				if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
					IsHoldingCTRL = false
				end
			end
		end)

		if AutoScroll == true then
			Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
		elseif AutoScroll == false then
			Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
		end
		Console.AutoScroll.MouseButton1Click:Connect(function()
			AutoScroll = not AutoScroll
			if AutoScroll == true then
				Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
				Console.Output.CanvasPosition = Vector2.new(0, 9e9)
			elseif AutoScroll == false then
				Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
			end
		end)

		-- Console part
		local displayedOutput = {}
		local OutputLimit = Console.Output.OutputLimit

		Console.TextSizeBox.TextBox.Text = tostring(OutputTextSize.Value)

		Console.TextSizeBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local tonum = tonumber(Console.TextSizeBox.TextBox.Text)
			if tonum then
				OutputTextSize.Value = tonum
			end
		end)
		OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
			Console.TextSizeBox.TextBox.Text = tostring(OutputTextSize.Value)
		end)

		local scrollConsoleInput
		Console.Output.MouseEnter:Connect(function()
			scrollConsoleInput = UserInputService.InputChanged:Connect(function(input)
				if CtrlScroll and input.UserInputType == Enum.UserInputType.MouseWheel and IsHoldingCTRL == true then
					Console.Output.ScrollingEnabled = false
					local newTextSize = OutputTextSize.Value + input.Position.Z
					if newTextSize >= 1 then
						OutputTextSize.Value = newTextSize
					end
				else
					Console.Output.ScrollingEnabled = true
				end
			end)
		end)
		Console.Output.MouseLeave:Connect(function()
			if scrollConsoleInput then
				scrollConsoleInput:Disconnect()
				scrollConsoleInput = nil
			end
		end)


		Console.Clear.MouseButton1Click:Connect(function()
			for _, log in pairs(Console.Output:GetChildren()) do
				if log:IsA("TextBox") then
					log:Destroy()
				end
			end
		end)

		local focussedOutput

		LogService.MessageOut:Connect(function(msg, msgtype)
			local formattedText = ""
			local unformattedText = ""
			local newOutputText = Console.OutputTemplate:Clone()
			table.insert(displayedOutput, newOutputText)

			if #displayedOutput > OutputLimit.Value then
				local oldest = table.remove(displayedOutput, 1)
				if oldest and typeof(oldest) == "Instance" then
					oldest:Destroy()
				end
			end

			unformattedText = os.date("%H:%M:%S")..'   '..msg
			if msgtype == Enum.MessageType.MessageOutput then
				formattedText = os.date("%H:%M:%S")..'   <font color="rgb(204, 204, 204)">'..msg..'</font>'
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageWarning then
				formattedText = os.date("%H:%M:%S")..'   <b><font color="rgb(255, 142, 60)">'..msg..'</font></b>'
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageError then
				formattedText = os.date("%H:%M:%S")..'   <b><font color="rgb(255, 68, 68)">'..msg..'</font></b>'
				newOutputText.Text = formattedText
			elseif msgtype == Enum.MessageType.MessageInfo then
				formattedText = os.date("%H:%M:%S")..'   <font color="rgb(128, 215, 255)">'..msg..'</font>'
				newOutputText.Text = formattedText
			end

			newOutputText.TextSize = OutputTextSize.Value
			OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
				newOutputText.TextSize = OutputTextSize.Value
			end)

			newOutputText.Focused:Connect(function()
				focussedOutput = newOutputText
				newOutputText.Text = unformattedText
			end)
			newOutputText.FocusLost:Connect(function()
				focussedOutput = nil
				newOutputText.Text = formattedText
			end)

			newOutputText.Parent = Console.Output
			newOutputText.Visible = true

			if AutoScroll then
				Console.Output.CanvasPosition = Vector2.new(0, 9e9)
			end
		end)

		Console.Output.MouseLeave:Connect(function()
			if focussedOutput then
				focussedOutput:ReleaseFocus()
			end
		end)

		Console.CommandLine.ScrollingFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()

			local oneliner = string.gsub(Console.CommandLine.ScrollingFrame.TextBox.Text, "\n", "    ")
			Console.CommandLine.ScrollingFrame.TextBox.Text = oneliner

			Console.CommandLine.ScrollingFrame.Highlight.Text = SyntaxHighlightingModule.run(Console.CommandLine.ScrollingFrame.TextBox.Text)
		end)



		Console.CommandLine.ScrollingFrame.TextBox.FocusLost:Connect(function(enterPressed)
			if enterPressed and Console.CommandLine.ScrollingFrame.TextBox.Text ~= "" then
				print("> "..Console.CommandLine.ScrollingFrame.TextBox.Text)
				loadstring(Console.CommandLine.ScrollingFrame.TextBox.Text)()
			end
		end)
	end

	return Console
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end,
["Explorer"] = function()
--[[
	Explorer App Module
	
	The main explorer interface
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, ModelViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	ModelViewer = Apps.ModelViewer
	Notebook = Apps.Notebook
end

local function main()
	local Explorer = {}
	local tree,listEntries,explorerOrders,searchResults,specResults = {},{},{},{},{}
	local expanded
	local entryTemplate,treeFrame,toolBar,descendantAddedCon,descendantRemovingCon,itemChangedCon
	local ffa = game.FindFirstAncestorWhichIsA
	local getDescendants = game.GetDescendants
	local getTextSize = service.TextService.GetTextSize
	local updateDebounce,refreshDebounce = false,false
	local nilNode = {Obj = Instance.new("Folder")}
	local idCounter = 0
	local scrollV,scrollH,clipboard
	local renameBox,renamingNode,searchFunc
	local sortingEnabled,autoUpdateSearch
	local table,math = table,math
	local nilMap,nilCons = {},{}
	local connectSignal = game.DescendantAdded.Connect
	local addObject,removeObject,moveObject = nil,nil,nil

	local iconData
	local remote_blocklist = {} -- list of remotes beng blocked, k = the remote instance, v = their old function :3
	nodes = nodes or {}

	addObject = function(root)
		if nodes[root] then return end

		local isNil = false
		local rootParObj = ffa(root,"Instance")
		local par = nodes[rootParObj]

		-- Nil Handling
		if not par then
			if nilMap[root] then
				nilCons[root] = nilCons[root] or {
					connectSignal(root.ChildAdded,addObject),
					connectSignal(root.AncestryChanged,moveObject),
				}
				par = nilNode
				isNil = true
			else
				return
			end
		elseif nilMap[rootParObj] or par == nilNode then
			nilMap[root] = true
			nilCons[root] = nilCons[root] or {
				connectSignal(root.ChildAdded,addObject),
				connectSignal(root.AncestryChanged,moveObject),
			}
			isNil = true
		end

		local newNode = {Obj = root, Parent = par}
		nodes[root] = newNode

		-- Automatic sorting if expanded
		if sortingEnabled and expanded[par] and par.Sorted then
			local left,right = 1,#par
			local floor = math.floor
			local sorter = Explorer.NodeSorter
			local pos = (right == 0 and 1)

			if not pos then
				while true do
					if left >= right then
						if sorter(newNode,par[left]) then
							pos = left
						else
							pos = left+1
						end
						break
					end

					local mid = floor((left+right)/2)
					if sorter(newNode,par[mid]) then
						right = mid-1
					else
						left = mid+1
					end
				end
			end

			table.insert(par,pos,newNode)
		else
			par[#par+1] = newNode
			par.Sorted = nil
		end

		local insts = getDescendants(root)
		for i = 1,#insts do
			local obj = insts[i]
			if nodes[obj] then continue end -- Deferred

			local par = nodes[ffa(obj,"Instance")]
			if not par then continue end
			local newNode = {Obj = obj, Parent = par}
			nodes[obj] = newNode
			par[#par+1] = newNode

			-- Nil Handling
			if isNil then
				nilMap[obj] = true
				nilCons[obj] = nilCons[obj] or {
					connectSignal(obj.ChildAdded,addObject),
					connectSignal(obj.AncestryChanged,moveObject),
				}
			end
		end

		if searchFunc and autoUpdateSearch then
			searchFunc({newNode})
		end

		if not updateDebounce and Explorer.IsNodeVisible(par) then
			if expanded[par] then
				Explorer.PerformUpdate()
			elseif not refreshDebounce then
				Explorer.PerformRefresh()
			end
		end
	end

	removeObject = function(root)
		local node = nodes[root]
		if not node then return end

		-- Nil Handling
		if nilMap[node.Obj] then
			moveObject(node.Obj)
			return
		end

		local par = node.Parent
		if par then
			par.HasDel = true
		end

		local function recur(root)
			for i = 1,#root do
				local node = root[i]
				if not node.Del then
					nodes[node.Obj] = nil
					if #node > 0 then recur(node) end
				end
			end
		end
		recur(node)
		node.Del = true
		nodes[root] = nil

		if par and not updateDebounce and Explorer.IsNodeVisible(par) then
			if expanded[par] then
				Explorer.PerformUpdate()
			elseif not refreshDebounce then
				Explorer.PerformRefresh()
			end
		end
	end

	moveObject = function(obj)
		local node = nodes[obj]
		if not node then return end

		local oldPar = node.Parent
		local newPar = nodes[ffa(obj,"Instance")]
		if oldPar == newPar then return end

		-- Nil Handling
		if not newPar then
			if nilMap[obj] then
				newPar = nilNode
			else
				return
			end
		elseif nilMap[newPar.Obj] or newPar == nilNode then
			nilMap[obj] = true
			nilCons[obj] = nilCons[obj] or {
				connectSignal(obj.ChildAdded,addObject),
				connectSignal(obj.AncestryChanged,moveObject),
			}
		end

		if oldPar then
			local parPos = table.find(oldPar,node)
			if parPos then table.remove(oldPar,parPos) end
		end

		node.Id = nil
		node.Parent = newPar

		if sortingEnabled and expanded[newPar] and newPar.Sorted then
			local left,right = 1,#newPar
			local floor = math.floor
			local sorter = Explorer.NodeSorter
			local pos = (right == 0 and 1)

			if not pos then
				while true do
					if left >= right then
						if sorter(node,newPar[left]) then
							pos = left
						else
							pos = left+1
						end
						break
					end

					local mid = floor((left+right)/2)
					if sorter(node,newPar[mid]) then
						right = mid-1
					else
						left = mid+1
					end
				end
			end

			table.insert(newPar,pos,node)
		else
			newPar[#newPar+1] = node
			newPar.Sorted = nil
		end

		if searchFunc and searchResults[node] then
			local currentNode = node.Parent
			while currentNode and (not searchResults[currentNode] or expanded[currentNode] == 0) do
				expanded[currentNode] = true
				searchResults[currentNode] = true
				currentNode = currentNode.Parent
			end
		end

		if not updateDebounce and (Explorer.IsNodeVisible(newPar) or Explorer.IsNodeVisible(oldPar)) then
			if expanded[newPar] or expanded[oldPar] then
				Explorer.PerformUpdate()
			elseif not refreshDebounce then
				Explorer.PerformRefresh()
			end
		end
	end

	Explorer.ViewWidth = 0
	Explorer.Index = 0
	Explorer.EntryIndent = 20
	Explorer.FreeWidth = 32
	Explorer.GuiElems = {}

	Explorer.InitRenameBox = function()
		renameBox = create({{1,"TextBox",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.062745101749897,0.51764708757401,1),BorderMode=2,ClearTextOnFocus=false,Font=3,Name="RenameBox",PlaceholderColor3=Color3.new(0.69803923368454,0.69803923368454,0.69803923368454),Position=UDim2.new(0,26,0,2),Size=UDim2.new(0,200,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,Visible=false,ZIndex=2}}})

		renameBox.Parent = Explorer.Window.GuiElems.Content.List

		renameBox.FocusLost:Connect(function()
			if not renamingNode then return end

			pcall(function() renamingNode.Obj.Name = renameBox.Text end)
			renamingNode = nil
			Explorer.Refresh()
		end)

		renameBox.Focused:Connect(function()
			renameBox.SelectionStart = 1
			renameBox.CursorPosition = #renameBox.Text + 1
		end)
	end

	Explorer.SetRenamingNode = function(node)
		renamingNode = node
		renameBox.Text = tostring(node.Obj)
		renameBox:CaptureFocus()
		Explorer.Refresh()
	end

	Explorer.SetSortingEnabled = function(val)
		sortingEnabled = val
		Settings.Explorer.Sorting = val
	end

	Explorer.UpdateView = function()
		local maxNodes = math.ceil(treeFrame.AbsoluteSize.Y / 20)
		local maxX = treeFrame.AbsoluteSize.X
		local totalWidth = Explorer.ViewWidth + Explorer.FreeWidth

		scrollV.VisibleSpace = maxNodes
		scrollV.TotalSpace = #tree + 1
		scrollH.VisibleSpace = maxX
		scrollH.TotalSpace = totalWidth

		scrollV.Gui.Visible = #tree + 1 > maxNodes
		scrollH.Gui.Visible = totalWidth > maxX

		local oldSize = treeFrame.Size
		treeFrame.Size = UDim2.new(1,(scrollV.Gui.Visible and -16 or 0),1,(scrollH.Gui.Visible and -39 or -23))
		if oldSize ~= treeFrame.Size then
			Explorer.UpdateView()
		else
			scrollV:Update()
			scrollH:Update()

			renameBox.Size = UDim2.new(0,maxX-100,0,16)

			if scrollV.Gui.Visible and scrollH.Gui.Visible then
				scrollV.Gui.Size = UDim2.new(0,16,1,-39)
				scrollH.Gui.Size = UDim2.new(1,-16,0,16)
				Explorer.Window.GuiElems.Content.ScrollCorner.Visible = true
			else
				scrollV.Gui.Size = UDim2.new(0,16,1,-23)
				scrollH.Gui.Size = UDim2.new(1,0,0,16)
				Explorer.Window.GuiElems.Content.ScrollCorner.Visible = false
			end

			Explorer.Index = scrollV.Index
		end
	end

	Explorer.NodeSorter = function(a,b)
		if a.Del or b.Del then return false end -- Ghost node

		local aClass = a.Class
		local bClass = b.Class
		if not aClass then aClass = a.Obj.ClassName a.Class = aClass end
		if not bClass then bClass = b.Obj.ClassName b.Class = bClass end

		local aOrder = explorerOrders[aClass]
		local bOrder = explorerOrders[bClass]
		if not aOrder then aOrder = RMD.Classes[aClass] and tonumber(RMD.Classes[aClass].ExplorerOrder) or 9999 explorerOrders[aClass] = aOrder end
		if not bOrder then bOrder = RMD.Classes[bClass] and tonumber(RMD.Classes[bClass].ExplorerOrder) or 9999 explorerOrders[bClass] = bOrder end

		if aOrder ~= bOrder then
			return aOrder < bOrder
		else
			local aName,bName = tostring(a.Obj),tostring(b.Obj)
			if aName ~= bName then
				return aName < bName
			elseif aClass ~= bClass then
				return aClass < bClass
			else
				local aId = a.Id if not aId then aId = idCounter idCounter = (idCounter+0.001)%999999999 a.Id = aId end
				local bId = b.Id if not bId then bId = idCounter idCounter = (idCounter+0.001)%999999999 b.Id = bId end
				return aId < bId
			end
		end
	end

	Explorer.Update = function()
		table.clear(tree)
		local maxNameWidth,maxDepth,count = 0,1,1
		local nameCache = {}
		local font = Enum.Font.SourceSans
		local size = Vector2.new(math.huge,20)
		local useNameWidth = Settings.Explorer.UseNameWidth
		local tSort = table.sort
		local sortFunc = Explorer.NodeSorter
		local isSearching = (expanded == Explorer.SearchExpanded)
		local textServ = service.TextService

		local function recur(root,depth)
			if depth > maxDepth then maxDepth = depth end
			depth = depth + 1
			if sortingEnabled and not root.Sorted then
				tSort(root,sortFunc)
				root.Sorted = true
			end
			for i = 1,#root do
				local n = root[i]

				if (isSearching and not searchResults[n]) or n.Del then continue end

				if useNameWidth then
					local nameWidth = n.NameWidth
					if not nameWidth then
						local objName = tostring(n.Obj)
						nameWidth = nameCache[objName]
						if not nameWidth then
							nameWidth = getTextSize(textServ,objName,14,font,size).X
							nameCache[objName] = nameWidth
						end
						n.NameWidth = nameWidth
					end
					if nameWidth > maxNameWidth then
						maxNameWidth = nameWidth
					end
				end

				tree[count] = n
				count = count + 1
				if expanded[n] and #n > 0 then
					recur(n,depth)
				end
			end
		end

		recur(nodes[game],1)

		-- Nil Instances
		if env.getnilinstances then
			if not (isSearching and not searchResults[nilNode]) then
				tree[count] = nilNode
				count = count + 1
				if expanded[nilNode] then
					recur(nilNode,2)
				end
			end
		end

		Explorer.MaxNameWidth = maxNameWidth
		Explorer.MaxDepth = maxDepth
		Explorer.ViewWidth = useNameWidth and Explorer.EntryIndent*maxDepth + maxNameWidth + 26 or Explorer.EntryIndent*maxDepth + 226
		Explorer.UpdateView()
	end

	Explorer.StartDrag = function(offX,offY)
		if Explorer.Dragging then return end
		for i,v in next, selection.List do
			local Obj = v.Obj
			if Obj.Parent == game or Obj:IsA("Player") then
				return
			end
		end
		Explorer.Dragging = true

		local dragTree = treeFrame:Clone()
		dragTree:ClearAllChildren()

		for i,v in pairs(listEntries) do
			local node = tree[i + Explorer.Index]
			if node and selection.Map[node] then
				local clone = v:Clone()
				clone.Active = false
				clone.Indent.Expand.Visible = false
				clone.Parent = dragTree
			end
		end

		local newGui = Instance.new("ScreenGui")
		newGui.DisplayOrder = Main.DisplayOrders.Menu
		dragTree.Parent = newGui
		Lib.ShowGui(newGui)

		local dragOutline = create({
			{1,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="DragSelect",Size=UDim2.new(1,0,1,0),}},
			{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Size=UDim2.new(1,0,0,1),ZIndex=2,}},
			{3,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),ZIndex=2,}},
			{4,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Size=UDim2.new(0,1,1,0),ZIndex=2,}},
			{5,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),ZIndex=2,}},
		})
		dragOutline.Parent = treeFrame

		local mouse = Main.Mouse or service.Players.LocalPlayer:GetMouse()
		local function move()
			local posX = mouse.X - offX
			local posY = mouse.Y - offY
			dragTree.Position = UDim2.new(0,posX,0,posY)

			for i = 1,#listEntries do
				local entry = listEntries[i]
				if Lib.CheckMouseInGui(entry) then
					dragOutline.Position = UDim2.new(0,entry.Indent.Position.X.Offset-scrollH.Index,0,entry.Position.Y.Offset)
					dragOutline.Size = UDim2.new(0,entry.Size.X.Offset-entry.Indent.Position.X.Offset,0,20)
					dragOutline.Visible = true
					return
				end
			end
			dragOutline.Visible = false
		end
		move()

		local input = service.UserInputService
		local mouseEvent,releaseEvent

		mouseEvent = input.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				move()
			end
		end)

		releaseEvent = input.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				releaseEvent:Disconnect()
				mouseEvent:Disconnect()
				newGui:Destroy()
				dragOutline:Destroy()
				Explorer.Dragging = false

				for i = 1,#listEntries do
					if Lib.CheckMouseInGui(listEntries[i]) then
						local node = tree[i + Explorer.Index]
						if node then
							if selection.Map[node] then return end
							local newPar = node.Obj
							local sList = selection.List
							for i = 1,#sList do
								local n = sList[i]
								pcall(function() n.Obj.Parent = newPar end)
							end
							Explorer.ViewNode(sList[1])
						end
						break
					end
				end
			end
		end)
	end

	Explorer.NewListEntry = function(index)
		local newEntry = entryTemplate:Clone()
		newEntry.Position = UDim2.new(0,0,0,20*(index-1))

		local isRenaming = false

		newEntry.InputBegan:Connect(function(input)
			local node = tree[index + Explorer.Index]
			if not node or selection.Map[node] or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

			newEntry.Indent.BackgroundColor3 = Settings.Theme.Button
			newEntry.Indent.BorderSizePixel = 0
			newEntry.Indent.BackgroundTransparency = 0
		end)

		newEntry.InputEnded:Connect(function(input)
			local node = tree[index + Explorer.Index]
			if not node or selection.Map[node] or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

			newEntry.Indent.BackgroundTransparency = 1
		end)

		newEntry.MouseButton1Down:Connect(function()

		end)

		newEntry.MouseButton1Up:Connect(function()

		end)

		newEntry.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local releaseEvent, mouseEvent

				local mouse = Main.Mouse or plr:GetMouse()
				local startX, startY

				if input.UserInputType == Enum.UserInputType.Touch then
					startX = input.Position.X
					startY = input.Position.Y
				else
					startX = mouse.X
					startY = mouse.Y
				end

				local listOffsetX = startX - treeFrame.AbsolutePosition.X
				local listOffsetY = startY - treeFrame.AbsolutePosition.Y

				releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						releaseEvent:Disconnect()
						mouseEvent:Disconnect()
					end
				end)

				mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						local currentX, currentY

						if input.UserInputType == Enum.UserInputType.Touch then
							currentX = input.Position.X
							currentY = input.Position.Y
						else
							currentX = mouse.X
							currentY = mouse.Y
						end

						local deltaX = currentX - startX
						local deltaY = currentY - startY
						local dist = math.sqrt(deltaX^2 + deltaY^2)

						if dist > 5 then
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
							isRenaming = false
							Explorer.StartDrag(listOffsetX, listOffsetY)
						end
					end
				end)
			end
		end)

		newEntry.MouseButton2Down:Connect(function()

		end)

		newEntry.Indent.Expand.InputBegan:Connect(function(input)
			local node = tree[index + Explorer.Index]
			if not node or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

			if input.UserInputType == Enum.UserInputType.Touch then
				Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
			end
		end)

		newEntry.Indent.Expand.InputEnded:Connect(function(input)
			local node = tree[index + Explorer.Index]
			if not node or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

			if input.UserInputType == Enum.UserInputType.Touch then
				Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
			end
		end)

		newEntry.Indent.Expand.MouseButton1Down:Connect(function()
			local node = tree[index + Explorer.Index]
			if not node or #node == 0 then return end

			expanded[node] = not expanded[node]
			Explorer.Update()
			Explorer.Refresh()
		end)

		newEntry.Parent = treeFrame
		return newEntry
	end

	Explorer.Refresh = function()
		local maxNodes = math.max(math.ceil((treeFrame.AbsoluteSize.Y) / 20), 0)	
		local renameNodeVisible = false
		local isa = game.IsA

		for i = 1,maxNodes do
			local entry = listEntries[i]
			if not listEntries[i] then entry = Explorer.NewListEntry(i) listEntries[i] = entry Explorer.ClickSystem:Add(entry) end

			local node = tree[i + Explorer.Index]
			if node then
				local obj = node.Obj
				local depth = Explorer.EntryIndent*Explorer.NodeDepth(node)

				entry.Visible = true
				entry.Position = UDim2.new(0,-scrollH.Index,0,entry.Position.Y.Offset)
				entry.Size = UDim2.new(0,Explorer.ViewWidth,0,20)
				entry.Indent.EntryName.Text = tostring(node.Obj)
				entry.Indent.Position = UDim2.new(0,depth,0,0)
				entry.Indent.Size = UDim2.new(1,-depth,1,0)

				entry.Indent.EntryName.TextTruncate = (Settings.Explorer.UseNameWidth and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd)

				Explorer.MiscIcons:DisplayExplorerIcons(entry.Indent.Icon, obj.ClassName)

				if selection.Map[node] then
					entry.Indent.BackgroundColor3 = Settings.Theme.ListSelection
					entry.Indent.BorderSizePixel = 0
					entry.Indent.BackgroundTransparency = 0
				else
					if Lib.CheckMouseInGui(entry) then
						entry.Indent.BackgroundColor3 = Settings.Theme.Button
					else
						entry.Indent.BackgroundTransparency = 1
					end
				end

				if node == renamingNode then
					renameNodeVisible = true
					renameBox.Position = UDim2.new(0,depth+25-scrollH.Index,0,entry.Position.Y.Offset+2)
					renameBox.Visible = true
				end

				if #node > 0 and expanded[node] ~= 0 then
					if Lib.CheckMouseInGui(entry.Indent.Expand) then
						Explorer.MiscIcons:DisplayByKey(entry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
					else
						Explorer.MiscIcons:DisplayByKey(entry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
					end
					entry.Indent.Expand.Visible = true
				else
					entry.Indent.Expand.Visible = false
				end
			else
				entry.Visible = false
			end
		end

		if not renameNodeVisible then
			renameBox.Visible = false
		end

		for i = maxNodes+1, #listEntries do
			Explorer.ClickSystem:Remove(listEntries[i])
			listEntries[i]:Destroy()
			listEntries[i] = nil
		end
	end

	Explorer.PerformUpdate = function(instant)
		updateDebounce = true
		Lib.FastWait(not instant and 0.1)
		if not updateDebounce then return end
		updateDebounce = false
		if not Explorer.Window:IsVisible() then return end
		Explorer.Update()
		Explorer.Refresh()
	end

	Explorer.ForceUpdate = function(norefresh)
		updateDebounce = false
		Explorer.Update()
		if not norefresh then Explorer.Refresh() end
	end

	Explorer.PerformRefresh = function()
		refreshDebounce = true
		Lib.FastWait(0.1)
		refreshDebounce = false
		if updateDebounce or not Explorer.Window:IsVisible() then return end
		Explorer.Refresh()
	end

	Explorer.IsNodeVisible = function(node)
		if not node then return end

		local curNode = node.Parent
		while curNode do
			if not expanded[curNode] then return false end
			curNode = curNode.Parent
		end
		return true
	end

	Explorer.NodeDepth = function(node)
		local depth = 0

		if node == nilNode then
			return 1
		end

		local curNode = node.Parent
		while curNode do
			if curNode == nilNode then depth = depth + 1 end
			curNode = curNode.Parent
			depth = depth + 1
		end
		return depth
	end

	Explorer.SetupConnections = function()
		if descendantAddedCon then descendantAddedCon:Disconnect() end
		if descendantRemovingCon then descendantRemovingCon:Disconnect() end
		if itemChangedCon then itemChangedCon:Disconnect() end

		if Main.Elevated then
			descendantAddedCon = game.DescendantAdded:Connect(addObject)
			descendantRemovingCon = game.DescendantRemoving:Connect(removeObject)
		else
			descendantAddedCon = game.DescendantAdded:Connect(function(obj) pcall(addObject,obj) end)
			descendantRemovingCon = game.DescendantRemoving:Connect(function(obj) pcall(removeObject,obj) end)
		end

		if Settings.Explorer.UseNameWidth then
			itemChangedCon = game.ItemChanged:Connect(function(obj,prop)
				if prop == "Parent" and nodes[obj] then
					moveObject(obj)
				elseif prop == "Name" and nodes[obj] then
					nodes[obj].NameWidth = nil
				end
			end)
		else
			itemChangedCon = game.ItemChanged:Connect(function(obj,prop)
				if prop == "Parent" and nodes[obj] then
					moveObject(obj)
				end
			end)
		end
	end

	Explorer.ViewNode = function(node)
		if not node then return end

		Explorer.MakeNodeVisible(node)
		Explorer.ForceUpdate(true)
		local visibleSpace = scrollV.VisibleSpace

		for i,v in next,tree do
			if v == node then
				local relative = i - 1
				if Explorer.Index > relative then
					scrollV.Index = relative
				elseif Explorer.Index + visibleSpace - 1 <= relative then
					scrollV.Index = relative - visibleSpace + 2
				end
			end
		end

		scrollV:Update() Explorer.Index = scrollV.Index
		Explorer.Refresh()
	end

	Explorer.ViewObj = function(obj)
		Explorer.ViewNode(nodes[obj])
	end

	Explorer.MakeNodeVisible = function(node,expandRoot)
		if not node then return end

		local hasExpanded = false

		if expandRoot and not expanded[node] then
			expanded[node] = true
			hasExpanded = true
		end

		local currentNode = node.Parent
		while currentNode do
			hasExpanded = true
			expanded[currentNode] = true
			currentNode = currentNode.Parent
		end

		if hasExpanded and not updateDebounce then
			coroutine.wrap(Explorer.PerformUpdate)(true)
		end
	end

	Explorer.ShowRightClick = function(MousePos)
		local Mouse = MousePos or Main.Mouse
		local context = Explorer.RightClickContext
		local absoluteSize = context.Gui.AbsoluteSize
		context.MaxHeight = (absoluteSize.Y <= 600 and (absoluteSize.Y - 40)) or nil
		context:Clear()

		local sList = selection.List
		local sMap = selection.Map
		local emptyClipboard = #clipboard == 0
		local presentClasses = {}
		local apiClasses = API.Classes

		for i = 1, #sList do
			local node = sList[i]
			local class = node.Class
			local obj = node.Obj

			if not presentClasses.isViableDecompileScript then
				presentClasses.isViableDecompileScript = env.isViableDecompileScript(obj)
			end
			if not class then
				class = obj.ClassName
				node.Class = class
			end

			local curClass = apiClasses[class]
			while curClass and not presentClasses[curClass.Name] do
				presentClasses[curClass.Name] = true
				curClass = curClass.Superclass
			end
		end

		context:AddRegistered("CUT")
		context:AddRegistered("COPY")
		context:AddRegistered("PASTE", emptyClipboard)
		context:AddRegistered("DUPLICATE")
		context:AddRegistered("DELETE")
		context:AddRegistered("DELETE_CHILDREN", #sList ~= 1)
		context:AddRegistered("RENAME", #sList ~= 1)

		context:AddDivider()
		context:AddRegistered("GROUP")
		context:AddRegistered("UNGROUP")
		context:AddRegistered("SELECT_CHILDREN")
		context:AddRegistered("JUMP_TO_PARENT")
		context:AddRegistered("EXPAND_ALL")
		context:AddRegistered("COLLAPSE_ALL")

		context:AddDivider()

		if expanded == Explorer.SearchExpanded then context:AddRegistered("CLEAR_SEARCH_AND_JUMP_TO") end
		if env.setclipboard then context:AddRegistered("COPY_PATH") end
		context:AddRegistered("INSERT_OBJECT")
		context:AddRegistered("SAVE_INST")
		-- context:AddRegistered("CALL_FUNCTION")
		-- context:AddRegistered("VIEW_CONNECTIONS")
		-- context:AddRegistered("GET_REFERENCES")
		context:AddRegistered("COPY_API_PAGE")

		context:QueueDivider()

		if presentClasses["BasePart"] or presentClasses["Model"] then
			context:AddRegistered("TELEPORT_TO")
			context:AddRegistered("VIEW_OBJECT")
			context:AddRegistered("3DVIEW_MODEL")
		end
		if presentClasses["Tween"] then context:AddRegistered("PLAY_TWEEN") end
		if presentClasses["Animation"] then
			context:AddRegistered("LOAD_ANIMATION")
			context:AddRegistered("STOP_ANIMATION")
		end

		if presentClasses["TouchTransmitter"] then context:AddRegistered("FIRE_TOUCHTRANSMITTER", firetouchinterest == nil) end
		if presentClasses["ClickDetector"] then context:AddRegistered("FIRE_CLICKDETECTOR", fireclickdetector == nil) end
		if presentClasses["ProximityPrompt"] then context:AddRegistered("FIRE_PROXIMITYPROMPT", fireproximityprompt == nil) end
		
		
		if presentClasses["RemoteEvent"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end
		if presentClasses["RemoteEvent"] then context:AddRegistered("UNBLOCK_REMOTE", env.hookfunction == nil) end
		
		if presentClasses["RemoteFunction"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end
		if presentClasses["RemoteFunction"] then context:AddRegistered("UNBLOCK_REMOTE", env.hookfunction == nil) end

		if presentClasses["UnreliableRemoteEvent"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end
		if presentClasses["UnreliableRemoteEvent"] then context:AddRegistered("UNBLOCK_REMOTE", env.hookfunction == nil) end
		
		
		if presentClasses["BindableEvent"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end
		if presentClasses["BindableEvent"] then context:AddRegistered("UNBLOCK_REMOTE", env.hookfunction == nil) end
		
		if presentClasses["BindableFunction"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end
		if presentClasses["BindableFunction"] then context:AddRegistered("UNBLOCK_REMOTE", env.hookfunction == nil) end
		
		
		
		if presentClasses["Player"] then context:AddRegistered("SELECT_CHARACTER")context:AddRegistered("VIEW_PLAYER") end
		if presentClasses["Players"] then
			context:AddRegistered("SELECT_LOCAL_PLAYER")
			context:AddRegistered("SELECT_ALL_CHARACTERS")
		end

		if presentClasses["LuaSourceContainer"] then
			context:AddRegistered("VIEW_SCRIPT", not presentClasses.isViableDecompileScript or not env.isdecompile)
			context:AddRegistered("DUMP_FUNCTIONS", not presentClasses.isViableDecompileScript or env.getupvalues == nil or env.getconstants == nil)
			context:AddRegistered("SAVE_SCRIPT", not presentClasses.isViableDecompileScript or not env.isdecompile or env.writefile == nil)
			context:AddRegistered("SAVE_BYTECODE", not presentClasses.isViableDecompileScript or env.getscriptbytecode == nil or env.writefile == nil)

		end

		if sMap[nilNode] then
			context:AddRegistered("REFRESH_NIL")
			context:AddRegistered("HIDE_NIL")
		end

		Explorer.LastRightClickX, Explorer.LastRightClickY = Mouse.X, Mouse.Y
		context:Show(Mouse.X, Mouse.Y)
	end

	Explorer.InitRightClick = function()
		local context = Lib.ContextMenu.new()

		context:Register("CUT",{Name = "Cut", IconMap = Explorer.MiscIcons, Icon = "Cut", DisabledIcon = "Cut_Disabled", Shortcut = "Ctrl+Z", OnClick = function()
			local destroy,clone = game.Destroy,game.Clone
			local sList,newClipboard = selection.List,{}
			local count = 1
			for i = 1,#sList do
				local inst = sList[i].Obj
				local s,cloned = pcall(clone,inst)
				if s and cloned then
					newClipboard[count] = cloned
					count = count + 1
				end
				pcall(destroy,inst)
			end
			clipboard = newClipboard
			selection:Clear()
		end})

		context:Register("COPY",{Name = "Copy", IconMap = Explorer.MiscIcons, Icon = "Copy", DisabledIcon = "Copy_Disabled", Shortcut = "Ctrl+C", OnClick = function()
			local clone = game.Clone
			local sList,newClipboard = selection.List,{}
			local count = 1
			for i = 1,#sList do
				local inst = sList[i].Obj
				local s,cloned = pcall(clone,inst)
				if s and cloned then
					newClipboard[count] = cloned
					count = count + 1
				end
			end
			clipboard = newClipboard
		end})

		context:Register("PASTE",{Name = "Paste Into", IconMap = Explorer.MiscIcons, Icon = "Paste", DisabledIcon = "Paste_Disabled", Shortcut = "Ctrl+Shift+V", OnClick = function()
			local sList = selection.List
			local newSelection = {}
			local count = 1
			for i = 1,#sList do
				local node = sList[i]
				local inst = node.Obj
				Explorer.MakeNodeVisible(node,true)
				for c = 1,#clipboard do
					local cloned = clipboard[c]:Clone()
					if cloned then
						cloned.Parent = inst
						local clonedNode = nodes[cloned]
						if clonedNode then newSelection[count] = clonedNode count = count + 1 end
					end
				end
			end
			selection:SetTable(newSelection)

			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			end
		end})

		context:Register("DUPLICATE",{Name = "Duplicate", IconMap = Explorer.MiscIcons, Icon = "Copy", DisabledIcon = "Copy_Disabled", Shortcut = "Ctrl+D", OnClick = function()
			local clone = game.Clone
			local sList = selection.List
			local newSelection = {}
			local count = 1
			for i = 1,#sList do
				local node = sList[i]
				local inst = node.Obj
				local instPar = node.Parent and node.Parent.Obj
				Explorer.MakeNodeVisible(node)
				local s,cloned = pcall(clone,inst)
				if s and cloned then
					cloned.Parent = instPar
					local clonedNode = nodes[cloned]
					if clonedNode then newSelection[count] = clonedNode count = count + 1 end
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			end
		end})

		context:Register("DELETE",{Name = "Delete", IconMap = Explorer.MiscIcons, Icon = "Delete", DisabledIcon = "Delete_Disabled", Shortcut = "Del", OnClick = function()
			local destroy = game.Destroy
			local sList = selection.List
			for i = 1,#sList do
				pcall(destroy,sList[i].Obj)
			end
			selection:Clear()
		end})
		
		context:Register("DELETE_CHILDREN",{Name = "Delete Children", IconMap = Explorer.MiscIcons, Icon = "Delete", DisabledIcon = "Delete_Disabled", Shortcut = "Shift+Del", OnClick = function()
			local sList = selection.List
			for i = 1,#sList do
				pcall(sList[i].Obj.ClearAllChildren,sList[i].Obj)
			end
			selection:Clear()
		end})
		context:Register("RENAME",{Name = "Rename", IconMap = Explorer.MiscIcons, Icon = "Rename", DisabledIcon = "Rename_Disabled", Shortcut = "F2", OnClick = function()
			local sList = selection.List
			if sList[1] then
				Explorer.SetRenamingNode(sList[1])
			end
		end})

		context:Register("GROUP",{Name = "Group", IconMap = Explorer.MiscIcons, Icon = "Group", DisabledIcon = "Group_Disabled", Shortcut = "Ctrl+G", OnClick = function()
			local sList = selection.List
			if #sList == 0 then return end

			local model = Instance.new("Model",sList[#sList].Obj.Parent)
			for i = 1,#sList do
				pcall(function() sList[i].Obj.Parent = model end)
			end

			if nodes[model] then
				selection:Set(nodes[model])
				Explorer.ViewNode(nodes[model])
			end
		end})

		context:Register("UNGROUP",{Name = "Ungroup", IconMap = Explorer.MiscIcons, Icon = "Ungroup", DisabledIcon = "Ungroup_Disabled", Shortcut = "Ctrl+U", OnClick = function()
			local newSelection = {}
			local count = 1
			local isa = game.IsA

			local function ungroup(node)
				local par = node.Parent.Obj
				local ch = {}
				local chCount = 1

				for i = 1,#node do
					local n = node[i]
					newSelection[count] = n
					ch[chCount] = n
					count = count + 1
					chCount = chCount + 1
				end

				for i = 1,#ch do
					pcall(function() ch[i].Obj.Parent = par end)
				end

				node.Obj:Destroy()
			end

			for i,v in next,selection.List do
				if isa(v.Obj,"Model") then
					ungroup(v)
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			end
		end})

		context:Register("SELECT_CHILDREN",{Name = "Select Children", IconMap = Explorer.MiscIcons, Icon = "SelectChildren", DisabledIcon = "SelectChildren_Disabled", OnClick = function()
			local newSelection = {}
			local count = 1
			local sList = selection.List

			for i = 1,#sList do
				local node = sList[i]
				for ind = 1,#node do
					local cNode = node[ind]
					if ind == 1 then Explorer.MakeNodeVisible(cNode) end

					newSelection[count] = cNode
					count = count + 1
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			else
				Explorer.Refresh()
			end
		end})

		context:Register("JUMP_TO_PARENT",{Name = "Jump to Parent", IconMap = Explorer.MiscIcons, Icon = "JumpToParent", OnClick = function()
			local newSelection = {}
			local count = 1
			local sList = selection.List

			for i = 1,#sList do
				local node = sList[i]
				if node.Parent then
					newSelection[count] = node.Parent
					count = count + 1
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			else
				Explorer.Refresh()
			end
		end})

		context:Register("TELEPORT_TO",{Name = "Teleport To", IconMap = Explorer.MiscIcons, Icon = "TeleportTo", OnClick = function()
			local sList = selection.List
			local plrRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

			if not plrRP then return end

			for _,node in next, sList do
				local Obj = node.Obj

				if Obj:IsA("BasePart") then
					if Obj.CanCollide then
						plr.Character:MoveTo(Obj.Position)
					else
						plrRP.CFrame = CFrame.new(Obj.Position + Settings.Explorer.TeleportToOffset)
					end
					break
				elseif Obj:IsA("Model") then
					if Obj.PrimaryPart then
						if Obj.PrimaryPart.CanCollide then
							plr.Character:MoveTo(Obj.PrimaryPart.Position)
						else
							plrRP.CFrame = CFrame.new(Obj.PrimaryPart.Position + Settings.Explorer.TeleportToOffset)
						end
						break
					else
						local part = Obj:FindFirstChildWhichIsA("BasePart", true)
						if part and nodes[part] then
							if part.CanCollide then
								plr.Character:MoveTo(part.Position)
							else
								plrRP.CFrame = CFrame.new(part.Position + Settings.Explorer.TeleportToOffset)
							end
							break
						elseif Obj.WorldPivot then
							plrRP.CFrame = Obj.WorldPivot
						end
					end
				end
			end
		end})

		local OldAnimation
		context:Register("PLAY_TWEEN",{Name = "Play Tween", IconMap = Explorer.MiscIcons, Icon = "Play", OnClick = function()
			local sList = selection.List

			for i = 1, #sList do
				local node = sList[i]
				local Obj = node.Obj

				if Obj:IsA("Tween") then Obj:Play() end
			end
		end})

		local OldAnimation
		context:Register("LOAD_ANIMATION",{Name = "Load Animation", IconMap = Explorer.MiscIcons, Icon = "Play", OnClick = function()
			local sList = selection.List

			local Humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if not Humanoid then return end

			for i = 1, #sList do
				local node = sList[i]
				local Obj = node.Obj

				if Obj:IsA("Animation") then
					if OldAnimation then OldAnimation:Stop() end
					OldAnimation = Humanoid:LoadAnimation(Obj)
					OldAnimation:Play()
					break
				end
			end
		end})

		context:Register("STOP_ANIMATION",{Name = "Stop Animation", IconMap = Explorer.MiscIcons, Icon = "Pause", OnClick = function()
			local sList = selection.List

			local Humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if not Humanoid then return end

			for i = 1, #sList do
				local node = sList[i]
				local Obj = node.Obj

				if Obj:IsA("Animation") then
					if OldAnimation then OldAnimation:Stop() end
					Humanoid:LoadAnimation(Obj):Stop()
					break
				end
			end
		end})

		context:Register("EXPAND_ALL",{Name = "Expand All", OnClick = function()
			local sList = selection.List

			local function expand(node)
				expanded[node] = true
				for i = 1,#node do
					if #node[i] > 0 then
						expand(node[i])
					end
				end
			end

			for i = 1,#sList do
				expand(sList[i])
			end

			Explorer.ForceUpdate()
		end})

		context:Register("COLLAPSE_ALL",{Name = "Collapse All", OnClick = function()
			local sList = selection.List

			local function expand(node)
				expanded[node] = nil
				for i = 1,#node do
					if #node[i] > 0 then
						expand(node[i])
					end
				end
			end

			for i = 1,#sList do
				expand(sList[i])
			end

			Explorer.ForceUpdate()
		end})

		context:Register("CLEAR_SEARCH_AND_JUMP_TO",{Name = "Clear Search and Jump to", OnClick = function()
			local newSelection = {}
			local count = 1
			local sList = selection.List

			for i = 1,#sList do
				newSelection[count] = sList[i]
				count = count + 1
			end

			selection:SetTable(newSelection)
			Explorer.ClearSearch()
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			end
		end})

		-- this code is very bad but im lazy and it works so cope
		local clth = function(str)
			if str:sub(1, 28) == "game:GetService(\"Workspace\")" then str = str:gsub("game:GetService%(\"Workspace\"%)", "workspace", 1) end
			if str:sub(1, 27 + #plr.Name) == "game:GetService(\"Players\")." .. plr.Name then str = str:gsub("game:GetService%(\"Players\"%)." .. plr.Name, "game:GetService(\"Players\").LocalPlayer", 1) end
			return str
		end

		context:Register("COPY_PATH",{Name = "Copy Path", IconMap = Explorer.LegacyClassIcons, Icon = 50, OnClick = function()
			local sList = selection.List
			if #sList == 1 then
				env.setclipboard(clth(Explorer.GetInstancePath(sList[1].Obj)))
			elseif #sList > 1 then
				local resList = {"{"}
				local count = 2
				for i = 1,#sList do
					local path = "\t"..clth(Explorer.GetInstancePath(sList[i].Obj))..","
					if #path > 0 then
						resList[count] = path
						count = count+1
					end
				end
				resList[count] = "}"
				env.setclipboard(table.concat(resList,"\n"))
			end
		end})

		context:Register("INSERT_OBJECT",{Name = "Insert Object", IconMap = Explorer.MiscIcons, Icon = "InsertObject", OnClick = function()
			local mouse = Main.Mouse
			local x,y = Explorer.LastRightClickX or mouse.X, Explorer.LastRightClickY or mouse.Y
			Explorer.InsertObjectContext:Show(x,y)
		end})

		--[[context:Register("CALL_FUNCTION",{Name = "Call Function", IconMap = Explorer.ClassIcons, Icon = 66, OnClick = function()

		end})

		context:Register("GET_REFERENCES",{Name = "Get Lua References", IconMap = Explorer.ClassIcons, Icon = 34, OnClick = function()

		end})]]

		context:Register("SAVE_INST",{Name = "Save to File", IconMap = Explorer.MiscIcons, Icon = "Save", OnClick = function()
			local sList = selection.List
			if #sList == 1 then
				Lib.SaveAsPrompt("Place_"..game.PlaceId.."_"..sList[1].Obj.ClassName.."_"..sList[1].Obj.Name.."_"..os.time(), function(filename)
					env.saveinstance(sList[1].Obj, filename, {
						Decompile = true,
						RemovePlayerCharacters = false
					})
				end)
			elseif #sList > 1 then
				for i = 1,#sList do
					-- sList[i].Obj.Name.." ("..sList[1].Obj.ClassName..")"
					-- "Place_"..game.PlaceId.."_"..sList[1].Obj.ClassName.."_"..sList[i].Obj.Name.."_"..os.time()
					Lib.SaveAsPrompt("Place_"..game.PlaceId.."_"..sList[i].Obj.ClassName.."_"..sList[i].Obj.Name.."_"..os.time(), function(filename)
						env.saveinstance(sList[i].Obj, filename, {
							Decompile = true,
							RemovePlayerCharacters = false
						})
					end)
					
					task.wait(0.1)
				end
			end
		end})

        --[[context:Register("VIEW_CONNECTIONS",{Name = "View Connections", OnClick = function()
            
        end})]]
		local ClassFire = {
			RemoteEvent = "FireServer",
			RemoteFunction = "InvokeServer",
			UnreliableRemoteEvent = "FireServer",

			BindableRemote = "Fire",
			BindableFunction = "Invoke",
		}
		context:Register("BLOCK_REMOTE",{Name = "Block From Firing", IconMap = Explorer.MiscIcons, Icon = "Delete", DisabledIcon = "Empty", OnClick = function()
			local sList = selection.List
			for i, list in sList do
				local obj = list.Obj
				if not remote_blocklist[obj] then
					local functionToHook = ClassFire[obj.ClassName]
					remote_blocklist[obj] = true
					local old; old = env.hookmetamethod((oldgame or game), "__namecall", function(self, ...)
						if remote_blocklist[obj] and self == obj and getnamecallmethod() == functionToHook then
							return nil
						end
						return old(self,...)
					end)
					if Settings.RemoteBlockWriteAttribute then
						obj:SetAttribute("IsBlocked", true)
					end
					--print("blocking ",functionToHook)
				end
			end
		end})
		
		context:Register("UNBLOCK_REMOTE",{Name = "Unblock", IconMap = Explorer.MiscIcons, Icon = "Play", DisabledIcon = "Empty", OnClick = function()
			local sList = selection.List
			for i, list in sList do
				local obj = list.Obj
				if remote_blocklist[obj] then
					remote_blocklist[obj] = nil
					if Settings.RemoteBlockWriteAttribute then
						list.Obj:SetAttribute("IsBlocked", false)
					end
					--print("unblocking ",functionToHook)
				end
			end
		end})

		context:Register("COPY_API_PAGE",{Name = "Copy Roblox API Page URL", IconMap = Explorer.MiscIcons, Icon = "Reference", OnClick = function()
			local sList = selection.List
			if #sList == 1 then
				env.setclipboard(
					"https://create.roblox.com/docs/reference/engine/classes/"..sList[1].Obj.ClassName
				)
			end
		end})

		context:Register("3DVIEW_MODEL",{Name = "3D Preview Object", IconMap = Explorer.LegacyClassIcons, Icon = 54, OnClick = function()
			local sList = selection.List
			local isa = game.IsA
			
			if #sList == 1 then
				if isa(sList[1].Obj,"BasePart") or isa(sList[1].Obj,"Model") then
					ModelViewer.ViewModel(sList[1].Obj)
					return
				end
			end
		end})
		
		context:Register("VIEW_OBJECT",{Name = "View Object (Right click to reset)", IconMap = Explorer.LegacyClassIcons, Icon = 5, OnClick = function()
			local sList = selection.List
			local isa = game.IsA

			for i = 1,#sList do
				local node = sList[i]

				if isa(node.Obj,"BasePart") or isa(node.Obj,"Model") then
					workspace.CurrentCamera.CameraSubject = node.Obj
					break
				end
			end
		end, OnRightClick = function()
			workspace.CurrentCamera.CameraSubject = plr.Character
		end})

		context:Register("VIEW_SCRIPT",{Name = "View Script", IconMap = Explorer.MiscIcons, Icon = "ViewScript", DisabledIcon = "Empty", OnClick = function()
			local scr = selection.List[1] and selection.List[1].Obj
			if scr then ScriptViewer.ViewScript(scr) end
		end})
		context:Register("DUMP_FUNCTIONS",{Name = "Dump Functions", IconMap = Explorer.MiscIcons, Icon = "SelectChildren", DisabledIcon = "Empty", OnClick = function()
			local scr = selection.List[1] and selection.List[1].Obj
			if scr then ScriptViewer.DumpFunctions(scr) end
		end})

		context:Register("FIRE_TOUCHTRANSMITTER",{Name = "Fire TouchTransmitter", OnClick = function()
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("TouchTransmitter") then firetouchinterest(hrp, v.Obj.Parent, 0) end end
		end})

		context:Register("FIRE_CLICKDETECTOR",{Name = "Fire ClickDetector", OnClick = function()
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("ClickDetector") then fireclickdetector(v.Obj) end end
		end})

		context:Register("FIRE_PROXIMITYPROMPT",{Name = "Fire ProximityPrompt", OnClick = function()
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("ProximityPrompt") then fireproximityprompt(v.Obj) end end
		end})

		context:Register("VIEW_SCRIPT",{Name = "View Script", IconMap = Explorer.MiscIcons, Icon = "ViewScript", DisabledIcon = "Empty", OnClick = function()
			local scr = selection.List[1] and selection.List[1].Obj
			if scr then ScriptViewer.ViewScript(scr) end
		end})

		context:Register("SAVE_SCRIPT",{Name = "Save Script", IconMap = Explorer.MiscIcons, Icon = "Save", DisabledIcon = "Empty", OnClick = function()
			for _, v in next, selection.List do
				if v.Obj:IsA("LuaSourceContainer") and env.isViableDecompileScript(v.Obj) then
					local success, source = pcall(env.decompile, v.Obj)
					if not success or not source then source = ("-- DEX - %s failed to decompile %s"):format(env.executor, v.Obj.ClassName) end
					local fileName = ("%s_%s_%i_Source.txt"):format(env.parsefile(v.Obj.Name), v.Obj.ClassName, game.PlaceId)
					--env.writefile(fileName, source)
					Lib.SaveAsPrompt(fileName, source)
					
					task.wait(0.2)
				end
			end
		end})

		context:Register("SAVE_BYTECODE",{Name = "Save Script Bytecode", IconMap = Explorer.MiscIcons, Icon = "Save", DisabledIcon = "Empty", OnClick = function()
			for _, v in next, selection.List do
				if v.Obj:IsA("LuaSourceContainer") and env.isViableDecompileScript(v.Obj) then
					local success, bytecode = pcall(env.getscriptbytecode, v.Obj)
					if success and type(bytecode) == "string" then
						local fileName = ("%s_%s_%i_Bytecode.txt"):format(env.parsefile(v.Obj.Name), v.Obj.ClassName, game.PlaceId)
						--env.writefile(fileName, bytecode)
						Lib.SaveAsPrompt(fileName, bytecode)
						task.wait(0.2)
					end
				end
			end
		end})

		context:Register("SELECT_CHARACTER",{Name = "Select Character", IconMap = Explorer.LegacyClassIcons, Icon = 9, OnClick = function()
			local newSelection = {}
			local count = 1
			local sList = selection.List
			local isa = game.IsA

			for i = 1,#sList do
				local node = sList[i]
				if isa(node.Obj,"Player") and nodes[node.Obj.Character] then
					newSelection[count] = nodes[node.Obj.Character]
					count = count + 1
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			else
				Explorer.Refresh()
			end
		end})

		context:Register("VIEW_PLAYER",{Name = "View Player", IconMap = Explorer.LegacyClassIcons, Icon = 5, OnClick = function()
			local newSelection = {}
			local count = 1
			local sList = selection.List
			local isa = game.IsA

			for i = 1,#sList do
				local node = sList[i]
				local Obj = node.Obj
				if Obj:IsA("Player") and Obj.Character then
					workspace.CurrentCamera.CameraSubject = Obj.Character
					break
				end
			end
		end})

		context:Register("SELECT_LOCAL_PLAYER",{Name = "Select Local Player", IconMap = Explorer.LegacyClassIcons, Icon = 9, OnClick = function()
			pcall(function() if nodes[plr] then selection:Set(nodes[plr]) Explorer.ViewNode(nodes[plr]) end end)
		end})

		context:Register("SELECT_ALL_CHARACTERS",{Name = "Select All Characters", IconMap = Explorer.LegacyClassIcons, Icon = 2, OnClick = function()
			local newSelection = {}
			local sList = selection.List

			for i,v in next, service.Players:GetPlayers() do
				if v.Character and nodes[v.Character] then
					if i == 1 then Explorer.MakeNodeVisible(v.Character) end
					table.insert(newSelection, nodes[v.Character])
				end
			end

			selection:SetTable(newSelection)
			if #newSelection > 0 then
				Explorer.ViewNode(newSelection[1])
			else
				Explorer.Refresh()
			end
		end})

		context:Register("REFRESH_NIL",{Name = "Refresh Nil Instances", OnClick = function()
			Explorer.RefreshNilInstances()
		end})

		context:Register("HIDE_NIL",{Name = "Hide Nil Instances", OnClick = function()
			Explorer.HideNilInstances()
		end})

		Explorer.RightClickContext = context
	end

	Explorer.HideNilInstances = function()
		table.clear(nilMap)

		local disconnectCon = Instance.new("Folder").ChildAdded:Connect(function() end).Disconnect
		for i,v in next,nilCons do
			disconnectCon(v[1])
			disconnectCon(v[2])
		end
		table.clear(nilCons)

		for i = 1,#nilNode do
			coroutine.wrap(removeObject)(nilNode[i].Obj)
		end

		Explorer.Update()
		Explorer.Refresh()
	end

	Explorer.RefreshNilInstances = function()
		if not env.getnilinstances then return end

		local nilInsts = env.getnilinstances()
		local game = game
		local getDescs = game.GetDescendants
		--local newNilMap = {}
		--local newNilRoots = {}
		--local nilRoots = Explorer.NilRoots
		--local connect = game.DescendantAdded.Connect
		--local disconnect
		--if not nilRoots then nilRoots = {} Explorer.NilRoots = nilRoots end

		for i = 1,#nilInsts do
			local obj = nilInsts[i]
			if obj ~= game then
				nilMap[obj] = true
				--newNilRoots[obj] = true

				local descs = getDescs(obj)
				for j = 1,#descs do
					nilMap[descs[j]] = true
				end
			end
		end

		-- Remove unmapped nil nodes
		--[[for i = 1,#nilNode do
			local node = nilNode[i]
			if not newNilMap[node.Obj] then
				nilMap[node.Obj] = nil
				coroutine.wrap(removeObject)(node)
			end
		end]]

		--nilMap = newNilMap

		for i = 1,#nilInsts do
			local obj = nilInsts[i]
			local node = nodes[obj]
			if not node then coroutine.wrap(addObject)(obj) end
		end

		--[[
		-- Remove old root connections
		for obj in next,nilRoots do
			if not newNilRoots[obj] then
				if not disconnect then disconnect = obj[1].Disconnect end
				disconnect(obj[1])
				disconnect(obj[2])
			end
		end
		
		for obj in next,newNilRoots do
			if not nilRoots[obj] then
				nilRoots[obj] = {
					connect(obj.DescendantAdded,addObject),
					connect(obj.DescendantRemoving,removeObject)
				}
			end
		end]]

		--nilMap = newNilMap
		--Explorer.NilRoots = newNilRoots

		Explorer.Update()
		Explorer.Refresh()
	end

	Explorer.GetInstancePath = function(obj)
		local ffc = game.FindFirstChild
		local getCh = game.GetChildren
		local path = ""
		local curObj = obj
		local ts = tostring
		local match = string.match
		local gsub = string.gsub
		local tableFind = table.find
		local useGetCh = Settings.Explorer.CopyPathUseGetChildren
		local formatLuaString = Lib.FormatLuaString

		while curObj do
			if curObj == game then
				path = "game"..path
				break
			end

			local className = curObj.ClassName
			local curName = ts(curObj)
			local indexName
			if match(curName,"^[%a_][%w_]*$") then
				indexName = "."..curName
			else
				local cleanName = formatLuaString(curName)
				indexName = '["'..cleanName..'"]'
			end

			local parObj = curObj.Parent
			if parObj then
				local fc = ffc(parObj,curName)
				if useGetCh and fc and fc ~= curObj then
					local parCh = getCh(parObj)
					local fcInd = tableFind(parCh,curObj)
					indexName = ":GetChildren()["..fcInd.."]"
				elseif parObj == game and API.Classes[className] and API.Classes[className].Tags.Service then
					indexName = ':GetService("'..className..'")'
				end
			elseif parObj == nil then
				local getnil = "local getNil = function(name, class) for _, v in next, getnilinstances() do if v.ClassName == class and v.Name == name then return v end end end"
				local gotnil = "\n\ngetNil(\"%s\", \"%s\")"
				indexName = getnil .. gotnil:format(curObj.Name, className)
			end

			path = indexName..path
			curObj = parObj
		end

		return path
	end

	Explorer.DefaultProps = {
		["BasePart"] = {
			Position = function(Obj)
				local Player = service.Players.LocalPlayer
				if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
					Obj.Position = (Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)).p
				end
				return Obj.Position
			end,
			Anchored = true
		},
		["GuiObject"] = {
			Position = function(Obj) return (Obj.Parent:IsA("ScreenGui") and UDim2.new(0.5, 0, 0.5, 0)) or Obj.Position end,
			Active = true
		}
	}

	Explorer.InitInsertObject = function()
		local context = Lib.ContextMenu.new()
		context.SearchEnabled = true
		context.MaxHeight = 400
		context:ApplyTheme({
			ContentColor = Settings.Theme.Main2,
			OutlineColor = Settings.Theme.Outline1,
			DividerColor = Settings.Theme.Outline1,
			TextColor = Settings.Theme.Text,
			HighlightColor = Settings.Theme.ButtonHover
		})

		local classes = {}
		for i,class in next,API.Classes do
			local tags = class.Tags
			if not tags.NotCreatable and not tags.Service then
				local rmdEntry = RMD.Classes[class.Name]
				classes[#classes+1] = {class,rmdEntry and rmdEntry.ClassCategory or "Uncategorized"}
			end
		end
		table.sort(classes,function(a,b)
			if a[2] ~= b[2] then
				return a[2] < b[2]
			else
				return a[1].Name < b[1].Name
			end
		end)

		local function defaultProps(obj)
			for class, props in pairs(Explorer.DefaultProps) do
				if obj:IsA(class) then
					for prop, value in pairs(props) do
						obj[prop] = (type(value) == "function" and value(obj)) or value
					end
				end
			end
		end

		local function onClick(className)
			local sList = selection.List
			local instNew = Instance.new
			for i = 1,#sList do
				local node = sList[i]
				local obj = node.Obj
				Explorer.MakeNodeVisible(node, true)
				local success, obj = pcall(instNew, className, obj)
				if success and obj then defaultProps(obj) end
			end
		end

		local lastCategory = ""
		for i = 1,#classes do
			local class = classes[i][1]
			local rmdEntry = RMD.Classes[class.Name]
			local iconInd = rmdEntry and tonumber(rmdEntry.ExplorerImageIndex) or 0
			local category = classes[i][2]

			if lastCategory ~= category then
				context:AddDivider(category)
				lastCategory = category
			end
			
			local icon
			if iconData then
				icon = iconData.Icons[class.Name] or iconData.Icons.Placeholder
			else
				icon = iconInd
			end
			context:Add({Name = class.Name, IconMap = Explorer.ClassIcons, Icon = icon, OnClick = onClick})
		end

		Explorer.InsertObjectContext = context
	end
	
	--[[
		Headers, Setups, Predicate, ObjectDefs
	]]
	Explorer.SearchFilters = { -- TODO: Use data table (so we can disable some if funcs don't exist)
		Comparison = {
			["isa"] = function(argString)
				local lower = string.lower
				local find = string.find
				local classQuery = string.split(argString)[1]
				if not classQuery then return end
				classQuery = lower(classQuery)

				local className
				for class,_ in pairs(API.Classes) do
					local cName = lower(class)
					if cName == classQuery then
						className = class
						break
					elseif find(cName,classQuery,1,true) then
						className = class
					end
				end
				if not className then return end

				return {
					Headers = {"local isa = game.IsA"},
					Predicate = "isa(obj,'"..className.."')"
				}
			end,
			["remotes"] = function(argString)
				return {
					Headers = {"local isa = game.IsA"},
					Predicate = "isa(obj,'RemoteEvent') or isa(obj,'RemoteFunction') or isa(obj,'UnreliableRemoteEvent')"
				}
			end,
			["bindables"] = function(argString)
				return {
					Headers = {"local isa = game.IsA"},
					Predicate = "isa(obj,'BindableEvent') or isa(obj,'BindableFunction')"
				}
			end,
			["rad"] = function(argString)
				local num = tonumber(argString)
				if not num then return end

				if not service.Players.LocalPlayer.Character or not service.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not service.Players.LocalPlayer.Character.HumanoidRootPart:IsA("BasePart") then return end

				return {
					Headers = {"local isa = game.IsA", "local hrp = service.Players.LocalPlayer.Character.HumanoidRootPart"},
					Setups = {"local hrpPos = hrp.Position"},
					ObjectDefs = {"local isBasePart = isa(obj,'BasePart')"},
					Predicate = "(isBasePart and (obj.Position-hrpPos).Magnitude <= "..num..")"
				}
			end,
		},
		Specific = {
			["players"] = function()
				return function() return service.Players:GetPlayers() end
			end,
			["loadedmodules"] = function()
				return env.getloadedmodules
			end,
		},
		Default = function(argString,caseSensitive)
			local cleanString = argString:gsub("\"","\\\""):gsub("\n","\\n")
			if caseSensitive then
				return {
					Headers = {"local find = string.find"},
					ObjectDefs = {"local objName = tostring(obj)"},
					Predicate = "find(objName,\"" .. cleanString .. "\",1,true)"
				}
			else
				return {
					Headers = {"local lower = string.lower","local find = string.find","local tostring = tostring"},
					ObjectDefs = {"local lowerName = lower(tostring(obj))"},
					Predicate = "find(lowerName,\"" .. cleanString:lower() .. "\",1,true)"
				}
			end
		end,
		SpecificDefault = function(n)
			return {
				Headers = {},
				ObjectDefs = {"local isSpec"..n.." = specResults["..n.."][node]"},
				Predicate = "isSpec"..n
			}
		end,
	}

	Explorer.BuildSearchFunc = function(query)
		local specFilterList,specMap = {},{}
		local finalPredicate = ""
		local rep = string.rep
		local formatQuery = query:gsub("\\.","  "):gsub('".-"',function(str) return rep(" ",#str) end)
		local headers = {}
		local objectDefs = {}
		local setups = {}
		local find = string.find
		local sub = string.sub
		local lower = string.lower
		local match = string.match
		local ops = {
			["("] = "(",
			[")"] = ")",
			["||"] = " or ",
			["&&"] = " and "
		}
		local filterCount = 0
		local compFilters = Explorer.SearchFilters.Comparison
		local specFilters = Explorer.SearchFilters.Specific
		local init = 1
		local lastOp = nil

		local function processFilter(dat)
			if dat.Headers then
				local t = dat.Headers
				for i = 1,#t do
					headers[t[i]] = true
				end
			end

			if dat.ObjectDefs then
				local t = dat.ObjectDefs
				for i = 1,#t do
					objectDefs[t[i]] = true
				end
			end

			if dat.Setups then
				local t = dat.Setups
				for i = 1,#t do
					setups[t[i]] = true
				end
			end

			finalPredicate = finalPredicate..dat.Predicate
		end

		local found = {}
		local foundData = {}
		local find = string.find
		local sub = string.sub

		local function findAll(str,pattern)
			local count = #found+1
			local init = 1
			local sz = #pattern
			local x,y,extra = find(str,pattern,init,true)
			while x do
				found[count] = x
				foundData[x] = {sz,pattern}

				count = count+1
				init = y+1
				x,y,extra = find(str,pattern,init,true)
			end
		end
		local start = tick()
		findAll(formatQuery,'&&')
		findAll(formatQuery,"||")
		findAll(formatQuery,"(")
		findAll(formatQuery,")")
		table.sort(found)
		table.insert(found,#formatQuery+1)

		local function inQuotes(str)
			local len = #str
			if sub(str,1,1) == '"' and sub(str,len,len) == '"' then
				return sub(str,2,len-1)
			end
		end

		for i = 1,#found do
			local nextInd = found[i]
			local nextData = foundData[nextInd] or {1}
			local op = ops[nextData[2]]
			local term = sub(query,init,nextInd-1)
			term = match(term,"^%s*(.-)%s*$") or "" -- Trim

			if #term > 0 then
				if sub(term,1,1) == "!" then
					term = sub(term,2)
					finalPredicate = finalPredicate.."not "
				end

				local qTerm = inQuotes(term)
				if qTerm then
					processFilter(Explorer.SearchFilters.Default(qTerm,true))
				else
					local x,y = find(term,"%S+")
					if x then
						local first = sub(term,x,y)
						local specifier = sub(first,1,1) == "/" and lower(sub(first,2))
						local compFunc = specifier and compFilters[specifier]
						local specFunc = specifier and specFilters[specifier]

						if compFunc then
							local argStr = sub(term,y+2)
							local ret = compFunc(inQuotes(argStr) or argStr)
							if ret then
								processFilter(ret)
							else
								finalPredicate = finalPredicate.."false"
							end
						elseif specFunc then
							local argStr = sub(term,y+2)
							local ret = specFunc(inQuotes(argStr) or argStr)
							if ret then
								if not specMap[term] then
									specFilterList[#specFilterList + 1] = ret
									specMap[term] = #specFilterList
								end
								processFilter(Explorer.SearchFilters.SpecificDefault(specMap[term]))
							else
								finalPredicate = finalPredicate.."false"
							end
						else
							processFilter(Explorer.SearchFilters.Default(term))
						end
					end
				end				
			end

			if op then
				finalPredicate = finalPredicate..op
				if op == "(" and (#term > 0 or lastOp == ")") then -- Handle bracket glitch
					return
				else
					lastOp = op
				end
			end
			init = nextInd+nextData[1]
		end

		local finalSetups = ""
		local finalHeaders = ""
		local finalObjectDefs = ""

		for setup,_ in next,setups do finalSetups = finalSetups..setup.."\n" end
		for header,_ in next,headers do finalHeaders = finalHeaders..header.."\n" end
		for oDef,_ in next,objectDefs do finalObjectDefs = finalObjectDefs..oDef.."\n" end

		local template = [==[
local searchResults = searchResults
local nodes = nodes
local expandTable = Explorer.SearchExpanded
local specResults = specResults
local service = service

%s
local function search(root)	
%s
	
	local expandedpar = false
	for i = 1,#root do
		local node = root[i]
		local obj = node.Obj
		
%s
		
		if %s then
			expandTable[node] = 0
			searchResults[node] = true
			if not expandedpar then
				local parnode = node.Parent
				while parnode and (not searchResults[parnode] or expandTable[parnode] == 0) do
					expandTable[parnode] = true
					searchResults[parnode] = true
					parnode = parnode.Parent
				end
				expandedpar = true
			end
		end
		
		if #node > 0 then search(node) end
	end
end
return search]==]

		local funcStr = template:format(finalHeaders,finalSetups,finalObjectDefs,finalPredicate)
		local s,func = pcall(loadstring,funcStr)
		if not s or not func then return nil,specFilterList end

		local env = setmetatable({["searchResults"] = searchResults, ["nodes"] = nodes, ["Explorer"] = Explorer, ["specResults"] = specResults,
			["service"] = service},{__index = getfenv()})
		setfenv(func,env)

		return func(),specFilterList
	end

	Explorer.DoSearch = function(query)
		table.clear(Explorer.SearchExpanded)
		table.clear(searchResults)
		expanded = (#query == 0 and Explorer.Expanded or Explorer.SearchExpanded)
		searchFunc = nil

		if #query > 0 then	
			local expandTable = Explorer.SearchExpanded
			local specFilters

			local lower = string.lower
			local find = string.find
			local tostring = tostring

			local lowerQuery = lower(query)

			local function defaultSearch(root)
				local expandedpar = false
				for i = 1,#root do
					local node = root[i]
					local obj = node.Obj

					if find(lower(tostring(obj)),lowerQuery,1,true) then
						expandTable[node] = 0
						searchResults[node] = true
						if not expandedpar then
							local parnode = node.Parent
							while parnode and (not searchResults[parnode] or expandTable[parnode] == 0) do
								expanded[parnode] = true
								searchResults[parnode] = true
								parnode = parnode.Parent
							end
							expandedpar = true
						end
					end

					if #node > 0 then defaultSearch(node) end
				end
			end

			if Main.Elevated then
				local start = tick()
				searchFunc,specFilters = Explorer.BuildSearchFunc(query)
				--print("BUILD SEARCH",tick()-start)
			else
				searchFunc = defaultSearch
			end

			if specFilters then
				table.clear(specResults)
				for i = 1,#specFilters do -- Specific search filers that returns list of matches
					local resMap = {}
					specResults[i] = resMap
					local objs = specFilters[i]()
					for c = 1,#objs do
						local node = nodes[objs[c]]
						if node then
							resMap[node] = true
						end
					end
				end
			end

			if searchFunc then
				local start = tick()
				searchFunc(nodes[game])
				searchFunc(nilNode)
				--warn(tick()-start)
			end
		end

		Explorer.ForceUpdate()
	end

	Explorer.ClearSearch = function()
		Explorer.GuiElems.SearchBar.Text = ""
		expanded = Explorer.Expanded
		searchFunc = nil
	end

	Explorer.InitSearch = function()
		local searchBox = Explorer.GuiElems.ToolBar.SearchFrame.SearchBox
		Explorer.GuiElems.SearchBar = searchBox

		Lib.ViewportTextBox.convert(searchBox)

		searchBox.FocusLost:Connect(function()
			Explorer.DoSearch(searchBox.Text)
		end)
	end

	Explorer.InitEntryTemplate = function()
		entryTemplate = create({
			{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderColor3=Color3.new(0,0,0),Font=3,Name="Entry",Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,250,0,20),Text="",TextSize=14,}},
			{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="Indent",Parent={1},Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-20,1,0),}},
			{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="EntryName",Parent={2},Position=UDim2.new(0,26,0,0),Size=UDim2.new(1,-26,1,0),Text="Workspace",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
			{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Font=3,Name="Expand",Parent={2},Position=UDim2.new(0,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextSize=14,}},
			{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={4},Position=UDim2.new(0,2,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
			{6,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ImageRectOffset=Vector2.new(304,0),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={2},Position=UDim2.new(0,4,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
		})

		local sys = Lib.ClickSystem.new()
		sys.AllowedButtons = {1,2}
		sys.OnDown:Connect(function(item,combo,button)
			local ind = table.find(listEntries,item)
			if not ind then return end
			local node = tree[ind + Explorer.Index]
			if not node then return end

			local entry = listEntries[ind]

			if button == 1 then
				if combo == 2 then
					if node.Obj:IsA("LuaSourceContainer") then
						ScriptViewer.ViewScript(node.Obj)
					elseif #node > 0 and expanded[node] ~= 0 then
						expanded[node] = not expanded[node]
						Explorer.Update()
					end
				end

				if Properties.SelectObject(node.Obj) then
					sys.IsRenaming = false
					return
				end

				sys.IsRenaming = selection.Map[node]

				if Lib.IsShiftDown() then
					if not selection.Piviot then return end

					local fromIndex = table.find(tree,selection.Piviot)
					local toIndex = table.find(tree,node)
					if not fromIndex or not toIndex then return end
					fromIndex,toIndex = math.min(fromIndex,toIndex),math.max(fromIndex,toIndex)

					local sList = selection.List
					for i = #sList,1,-1 do
						local elem = sList[i]
						if selection.ShiftSet[elem] then
							selection.Map[elem] = nil
							table.remove(sList,i)
						end
					end
					selection.ShiftSet = {}
					for i = fromIndex,toIndex do
						local elem = tree[i]
						if not selection.Map[elem] then
							selection.ShiftSet[elem] = true
							selection.Map[elem] = true
							sList[#sList+1] = elem
						end
					end
					selection.Changed:Fire()
				elseif Lib.IsCtrlDown() then
					selection.ShiftSet = {}
					if selection.Map[node] then selection:Remove(node) else selection:Add(node) end
					selection.Piviot = node
					sys.IsRenaming = false
				elseif not selection.Map[node] then
					selection.ShiftSet = {}
					selection:Set(node)
					selection.Piviot = node
				end
			elseif button == 2 then
				if Properties.SelectObject(node.Obj) then
					return
				end

				if not Lib.IsCtrlDown() and not selection.Map[node] then
					selection.ShiftSet = {}
					selection:Set(node)
					selection.Piviot = node
					Explorer.Refresh()
				end
			end

			Explorer.Refresh()
		end)

		sys.OnRelease:Connect(function(item,combo,button,position)
			local ind = table.find(listEntries,item)
			if not ind then return end
			local node = tree[ind + Explorer.Index]
			if not node then return end

			if button == 1 then
				if selection.Map[node] and not Lib.IsShiftDown() and not Lib.IsCtrlDown() then
					selection.ShiftSet = {}
					selection:Set(node)
					selection.Piviot = node
					Explorer.Refresh()
				end

				local id = sys.ClickId
				Lib.FastWait(sys.ComboTime)
				if combo == 1 and id == sys.ClickId and sys.IsRenaming and selection.Map[node] then
					Explorer.SetRenamingNode(node)
				end
			elseif button == 2 then
				Explorer.ShowRightClick(position)
			end
		end)
		Explorer.ClickSystem = sys
	end

	Explorer.InitDelCleaner = function()
		coroutine.wrap(function()
			local fw = Lib.FastWait
			while true do
				local processed = false
				local c = 0
				for _,node in next,nodes do
					if node.HasDel then
						local delInd
						for i = 1,#node do
							if node[i].Del then
								delInd = i
								break
							end
						end
						if delInd then
							for i = delInd+1,#node do
								local cn = node[i]
								if not cn.Del then
									node[delInd] = cn
									delInd = delInd+1
								end
							end
							for i = delInd,#node do
								node[i] = nil
							end
						end
						node.HasDel = false
						processed = true
						fw()
					end
					c = c + 1
					if c > 10000 then
						c = 0
						fw()
					end
				end
				if processed and not refreshDebounce then Explorer.PerformRefresh() end
				fw(0.5)
			end
		end)()
	end

	Explorer.UpdateSelectionVisuals = function()
		local holder = Explorer.SelectionVisualsHolder
		local isa = game.IsA
		local clone = game.Clone
		if not holder then
			holder = Instance.new("ScreenGui")
			holder.Name = "ExplorerSelections"
			holder.DisplayOrder = Main.DisplayOrders.Core
			Lib.ShowGui(holder)
			Explorer.SelectionVisualsHolder = holder
			Explorer.SelectionVisualCons = {}

			local guiTemplate = create({
				{1,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.new(0,100,0,100),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,0,-1),Size=UDim2.new(1,2,0,1),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,1,0),Size=UDim2.new(1,2,0,1),}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,0,0),Size=UDim2.new(0,1,1,0),}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,1,1,0),}},
			})
			Explorer.SelectionVisualGui = guiTemplate

			local boxTemplate = Instance.new("SelectionBox")
			boxTemplate.LineThickness = 0.03
			boxTemplate.Color3 = Color3.fromRGB(0, 170, 255)
			Explorer.SelectionVisualBox = boxTemplate
		end
		holder:ClearAllChildren()

		-- Updates theme
		for i,v in pairs(Explorer.SelectionVisualGui:GetChildren()) do
			v.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		end

		local attachCons = Explorer.SelectionVisualCons
		for i = 1,#attachCons do
			attachCons[i].Destroy()
		end
		table.clear(attachCons)

		local partEnabled = Settings.Explorer.PartSelectionBox
		local guiEnabled = Settings.Explorer.GuiSelectionBox
		if not partEnabled and not guiEnabled then return end

		local svg = Explorer.SelectionVisualGui
		local svb = Explorer.SelectionVisualBox
		local attachTo = Lib.AttachTo
		local sList = selection.List
		local count = 1
		local boxCount = 0
		local workspaceNode = nodes[workspace]
		for i = 1,#sList do
			if boxCount > 1000 then break end
			local node = sList[i]
			local obj = node.Obj

			if node ~= workspaceNode then
				if isa(obj,"GuiObject") and guiEnabled then
					local newVisual = clone(svg)
					attachCons[count] = attachTo(newVisual,{Target = obj, Resize = true})
					count = count + 1
					newVisual.Parent = holder
					boxCount = boxCount + 1
				elseif isa(obj,"PVInstance") and partEnabled then
					local newBox = clone(svb)
					newBox.Adornee = obj
					newBox.Parent = holder
					boxCount = boxCount + 1
				end
			end
		end
	end

	Explorer.Init = function()
		Explorer.LegacyClassIcons = Lib.IconMap.newLinear("rbxasset://textures/ClassImages.PNG", 16,16)
		if Settings.ClassIcon ~= nil and Settings.ClassIcon ~= "Old" then
			iconData = Lib.IconMap.getIconDataFromName(Settings.ClassIcon)
			
			Explorer.ClassIcons = Lib.IconMap.new("rbxassetid://"..tostring(iconData.MapId), iconData.IconSize * iconData.Witdh, iconData.IconSize * iconData.Height,iconData.IconSize,iconData.IconSize)
			-- move every value dict 1 behind because SetDict starts at 0 not 1 lol
			local fixed = {}
			for i,v in pairs(iconData.Icons) do
				fixed[i] = v - 1
			end
			
			iconData.Icons = fixed
			Explorer.ClassIcons:SetDict(fixed)
		else
			Explorer.ClassIcons = Lib.IconMap.newLinear("rbxasset://textures/ClassImages.PNG", 16,16)
		end
		
		Explorer.MiscIcons = Main.MiscIcons

		clipboard = {}

		selection = Lib.Set.new()
		selection.ShiftSet = {}
		selection.Changed:Connect(Properties.ShowExplorerProps)
		Explorer.Selection = selection

		Explorer.InitRightClick()
		Explorer.InitInsertObject()
		Explorer.SetSortingEnabled(Settings.Explorer.Sorting)
		Explorer.Expanded = setmetatable({},{__mode = "k"})
		Explorer.SearchExpanded = setmetatable({},{__mode = "k"})
		expanded = Explorer.Expanded

		nilNode.Obj.Name = "Nil Instances"
		nilNode.Locked = true

		local explorerItems = create({
			{1,"Folder",{Name="ExplorerItems",}},
			{2,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ToolBar",Parent={1},Size=UDim2.new(1,0,0,22),}},
			{3,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchFrame",Parent={2},Position=UDim2.new(0,3,0,1),Size=UDim2.new(1,-6,0,18),}},
			{4,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Name="SearchBox",Parent={3},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search workspace",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-24,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
			{5,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
			{6,"UIStroke",{Thickness=1.4,Parent={3},Color=Color3.fromRGB(42,42,42)}},
			{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Reset",Parent={3},Position=UDim2.new(1,-17,0,1),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718129",ImageColor3=Color3.new(0.39215686917305,0.39215686917305,0.39215686917305),Parent={7},Size=UDim2.new(0,16,0,16),}},
			{9,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Refresh",Parent={2},Position=UDim2.new(1,-20,0,1),Size=UDim2.new(0,18,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
			{10,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642310344",Parent={9},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,12,0,12),}},
			{11,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Parent={1},Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}},
			{12,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Name="List",Parent={1},Position=UDim2.new(0,0,0,23),Size=UDim2.new(1,0,1,-23),}}
		})

		toolBar = explorerItems.ToolBar
		treeFrame = explorerItems.List

		Explorer.GuiElems.ToolBar = toolBar
		Explorer.GuiElems.TreeFrame = treeFrame

		scrollV = Lib.ScrollBar.new()		
		scrollV.WheelIncrement = 3
		scrollV.Gui.Position = UDim2.new(1,-16,0,23)
		scrollV:SetScrollFrame(treeFrame)
		scrollV.Scrolled:Connect(function()
			Explorer.Index = scrollV.Index
			Explorer.Refresh()
		end)

		scrollH = Lib.ScrollBar.new(true)
		scrollH.Increment = 5
		scrollH.WheelIncrement = Explorer.EntryIndent
		scrollH.Gui.Position = UDim2.new(0,0,1,-16)
		scrollH.Scrolled:Connect(function()
			Explorer.Refresh()
		end)

		local window = Lib.Window.new()
		Explorer.Window = window
		window:SetTitle("Explorer")
		window.GuiElems.Line.Position = UDim2.new(0,0,0,22)

		Explorer.InitEntryTemplate()
		toolBar.Parent = window.GuiElems.Content
		treeFrame.Parent = window.GuiElems.Content
		explorerItems.ScrollCorner.Parent = window.GuiElems.Content
		scrollV.Gui.Parent = window.GuiElems.Content
		scrollH.Gui.Parent = window.GuiElems.Content

		-- Init stuff that requires the window
		Explorer.InitRenameBox()
		Explorer.InitSearch()
		Explorer.InitDelCleaner()
		selection.Changed:Connect(Explorer.UpdateSelectionVisuals)

		-- Window events
		window.GuiElems.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if Explorer.Active then
				Explorer.UpdateView()
				Explorer.Refresh()
			end
		end)
		window.OnActivate:Connect(function()
			Explorer.Active = true
			Explorer.UpdateView()
			Explorer.Update()
			Explorer.Refresh()
		end)
		window.OnRestore:Connect(function()
			Explorer.Active = true
			Explorer.UpdateView()
			Explorer.Update()
			Explorer.Refresh()
		end)
		window.OnDeactivate:Connect(function() Explorer.Active = false end)
		window.OnMinimize:Connect(function() Explorer.Active = false end)

		-- Settings
		autoUpdateSearch = Settings.Explorer.AutoUpdateSearch

		-- Fill in nodes
		nodes[game] = {Obj = game}
		expanded[nodes[game]] = true

		-- Nil Instances
		if env.getnilinstances then
			nodes[nilNode.Obj] = nilNode
		end

		Explorer.SetupConnections()

		local insts = getDescendants(game)
		if Main.Elevated then
			for i = 1,#insts do
				local obj = insts[i]
				local par = nodes[ffa(obj,"Instance")]
				if not par then continue end
				local newNode = {
					Obj = obj,
					Parent = par,
				}
				nodes[obj] = newNode
				par[#par+1] = newNode
			end
		else
			for i = 1,#insts do
				local obj = insts[i]
				local s,parObj = pcall(ffa,obj,"Instance")
				local par = nodes[parObj]
				if not par then continue end
				local newNode = {
					Obj = obj,
					Parent = par,
				}
				nodes[obj] = newNode
				par[#par+1] = newNode
			end
		end
	end

	return Explorer
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end,
["Lib"] = function()
--[[
	Lib Module
	
	Container for functions and classes
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local function main()
	local Lib = {}

	local renderStepped = service.RunService.RenderStepped
	local signalWait = renderStepped.wait
	local PH = newproxy() -- Placeholder, must be replaced in constructor
	local SIGNAL = newproxy()

	-- Usually for classes that work with a Roblox Object
	local function initObj(props,mt)
		local type = type
		local function copy(t)
			local res = {}
			for i,v in pairs(t) do
				if v == SIGNAL then
					res[i] = Lib.Signal.new()
				elseif type(v) == "table" then
					res[i] = copy(v)
				else
					res[i] = v
				end
			end		
			return res
		end

		local newObj = copy(props)
		return setmetatable(newObj,mt)
	end

	local function getGuiMT(props,funcs)
		return {__index = function(self,ind) if not props[ind] then return funcs[ind] or self.Gui[ind] end end,
		__newindex = function(self,ind,val) if not props[ind] then self.Gui[ind] = val else rawset(self,ind,val) end end}
	end

	-- Functions

	Lib.FormatLuaString = (function()
		local string = string
		local gsub = string.gsub
		local format = string.format
		local char = string.char
		local cleanTable = {['"'] = '\\"', ['\\'] = '\\\\'}
		for i = 0,31 do
			cleanTable[char(i)] = "\\"..format("%03d",i)
		end
		for i = 127,255 do
			cleanTable[char(i)] = "\\"..format("%03d",i)
		end

		return function(str)
			return gsub(str,"[\"\\\0-\31\127-\255]",cleanTable)
		end
	end)()

	Lib.CheckMouseInGui = function(gui)
		if gui == nil then return false end
		local mouse = Main.Mouse
		local guiPosition = gui.AbsolutePosition
		local guiSize = gui.AbsoluteSize	

		return mouse.X >= guiPosition.X and mouse.X < guiPosition.X + guiSize.X and mouse.Y >= guiPosition.Y and mouse.Y < guiPosition.Y + guiSize.Y
	end

	Lib.IsShiftDown = function()
		return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end

	Lib.IsCtrlDown = function()
		return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	end

	Lib.CreateArrow = function(size,num,dir)
		local max = num
		local arrowFrame = createSimple("Frame",{
			BackgroundTransparency = 1,
			Name = "Arrow",
			Size = UDim2.new(0,size,0,size)
		})
		if dir == "up" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)+i-math.floor(max/2)-1),
					Size = UDim2.new(0,i+(i-1),0,1),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "down" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)-i+math.floor(max/2)+1),
					Size = UDim2.new(0,i+(i-1),0,1),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "left" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)+i-math.floor(max/2)-1,0,math.floor(size/2)-(i-1)),
					Size = UDim2.new(0,1,0,i+(i-1)),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "right" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-i+math.floor(max/2)+1,0,math.floor(size/2)-(i-1)),
					Size = UDim2.new(0,1,0,i+(i-1)),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		end
		error("r u ok")
	end

	Lib.ParseXML = (function()
		local func = function()
			-- Only exists to parse RMD
			-- from https://github.com/jonathanpoelen/xmlparser

			local string, print, pairs = string, print, pairs

			-- http://lua-users.org/wiki/StringTrim
			local trim = function(s)
				local from = s:match"^%s*()"
				return from > #s and "" or s:match(".*%S", from)
			end

			local gtchar = string.byte('>', 1)
			local slashchar = string.byte('/', 1)
			local D = string.byte('D', 1)
			local E = string.byte('E', 1)

			function parse(s, evalEntities)
				-- remove comments
				s = s:gsub('<!%-%-(.-)%-%->', '')

				local entities, tentities = {}

				if evalEntities then
					local pos = s:find('<[_%w]')
					if pos then
						s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
							entities[#entities+1] = {name=name, value=entity}
						end)
						tentities = createEntityTable(entities)
						s = replaceEntities(s:sub(pos), tentities)
					end
				end

				local t, l = {}, {}

				local addtext = function(txt)
					txt = txt:match'^%s*(.*%S)' or ''
					if #txt ~= 0 then
						t[#t+1] = {text=txt}
					end		
				end

				s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
					-- open
					if #type == 0 then
						local a = {}
						if #closed == 0 then
							local len = 0
							for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
								len = len + #all
								a[aname] = value
								if #starttxt ~= 0 then
									txt = txt:sub(len+1)
									closed = starttxt
									break
								end
							end
						end
						t[#t+1] = {tag=name, attrs=a, children={}}

						if closed:byte(1) ~= slashchar then
							l[#l+1] = t
							t = t[#t].children
						end

						addtext(txt)
						-- close
					elseif '/' == type then
						t = l[#l]
						l[#l] = nil

						addtext(txt)
						-- ENTITY
					elseif '!' == type then
						if E == name:byte(1) then
							txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
								entities[#entities+1] = {name=name, value=entity}
							end, 1)
						end
						-- elseif '?' == type then
						--	 print('?	' .. name .. ' // ' .. attrs .. '$$')
						-- elseif '-' == type then
						--	 print('comment	' .. name .. ' // ' .. attrs .. '$$')
						-- else
						--	 print('o	' .. #p .. ' // ' .. name .. ' // ' .. attrs .. '$$')
					end
				end)

				return {children=t, entities=entities, tentities=tentities}
			end

			function parseText(txt)
				return parse(txt)
			end

			function defaultEntityTable()
				return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
			end

			function replaceEntities(s, entities)
				return s:gsub('&([^;]+);', entities)
			end

			function createEntityTable(docEntities, resultEntities)
				entities = resultEntities or defaultEntityTable()
				for _,e in pairs(docEntities) do
					e.value = replaceEntities(e.value, entities)
					entities[e.name] = e.value
				end
				return entities
			end

			return parseText
		end
		local newEnv = setmetatable({},{__index = getfenv()})
		setfenv(func,newEnv)
		return func()
	end)()

	Lib.FastWait = function(s)
		if not s then return signalWait(renderStepped) end
		local start = tick()
		while tick() - start < s do signalWait(renderStepped) end
	end

	Lib.ButtonAnim = function(button,data)
		local holding = false
		local disabled = false
		local mode = data and data.Mode or 1
		local control = {}

		if mode == 2 then
			local lerpTo = data.LerpTo or Color3.new(0,0,0)
			local delta = data.LerpDelta or 0.2
			control.StartColor = data.StartColor or button.BackgroundColor3
			control.PressColor = data.PressColor or control.StartColor:lerp(lerpTo,delta)
			control.HoverColor = data.HoverColor or control.StartColor:lerp(control.PressColor,0.6)
			control.OutlineColor = data.OutlineColor
		end

		button.InputBegan:Connect(function(input)
			if disabled then return end

			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if not holding then
					if mode == 1 then
						button.BackgroundTransparency = 0.4
					elseif mode == 2 then
						button.BackgroundColor3 = control.HoverColor
					end
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = true
				if mode == 1 then
					button.BackgroundTransparency = 0
				elseif mode == 2 then
					button.BackgroundColor3 = control.PressColor
					if control.OutlineColor then button.BorderColor3 = control.PressColor end
				end
			end
		end)

		button.InputEnded:Connect(function(input)
			if disabled then return end

			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if not holding then
					if mode == 1 then
						button.BackgroundTransparency = 1
					elseif mode == 2 then
						button.BackgroundColor3 = control.StartColor
					end
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = false
				if mode == 1 then
					button.BackgroundTransparency = Lib.CheckMouseInGui(button) and 0.4 or 1
				elseif mode == 2 then
					button.BackgroundColor3 = Lib.CheckMouseInGui(button) and control.HoverColor or control.StartColor
					if control.OutlineColor then button.BorderColor3 = control.OutlineColor end
				end
			end
		end)

		control.Disable = function()
			disabled = true
			holding = false

			if mode == 1 then
				button.BackgroundTransparency = 1
			elseif mode == 2 then
				button.BackgroundColor3 = control.StartColor
			end
		end

		control.Enable = function()
			disabled = false
		end

		return control
	end

	Lib.FindAndRemove = function(t,item)
		local pos = table.find(t,item)
		if pos then table.remove(t,pos) end
	end

	Lib.AttachTo = function(obj,data)
		local target,posOffX,posOffY,sizeOffX,sizeOffY,resize,con
		local disabled = false

		local function update()
			if not obj or not target then return end

			local targetPos = target.AbsolutePosition
			local targetSize = target.AbsoluteSize
			obj.Position = UDim2.new(0,targetPos.X + posOffX,0,targetPos.Y + posOffY)
			if resize then obj.Size = UDim2.new(0,targetSize.X + sizeOffX,0,targetSize.Y + sizeOffY) end
		end

		local function setup(o,data)
			obj = o
			data = data or {}
			target = data.Target
			posOffX = data.PosOffX or 0
			posOffY = data.PosOffY or 0
			sizeOffX = data.SizeOffX or 0
			sizeOffY = data.SizeOffY or 0
			resize = data.Resize or false

			if con then con:Disconnect() con = nil end
			if target then
				con = target.Changed:Connect(function(prop)
					if not disabled and prop == "AbsolutePosition" or prop == "AbsoluteSize" then
						update()
					end
				end)
			end

			update()
		end
		setup(obj,data)

		return {
			SetData = function(obj,data)
				setup(obj,data)
			end,
			Enable = function()
				disabled = false
				update()
			end,
			Disable = function()
				disabled = true
			end,
			Destroy = function()
				con:Disconnect()
				con = nil
			end,
		}
	end

	Lib.ProtectedGuis = {}

	Lib.ShowGui = Main.SecureGui

	Lib.ColorToBytes = function(col)
		local round = math.round
		return string.format("%d, %d, %d",round(col.r*255),round(col.g*255),round(col.b*255))
	end

	Lib.ReadFile = function(filename)
		if not env.readfile then return end

		local s,contents = pcall(env.readfile,filename)
		if s and contents then return contents end
	end

	Lib.DeferFunc = function(f,...)
		signalWait(renderStepped)
		return f(...)
	end

	Lib.LoadCustomAsset = function(filepath)
		if not env.getcustomasset or not env.isfile or not env.isfile(filepath) then return end

		return env.getcustomasset(filepath)
	end

	Lib.FetchCustomAsset = function(url,filepath)
		if not env.writefile then return end

		local s,data = pcall(oldgame.HttpGet,game,url)
		if not s then return end

		env.writefile(filepath,data)
		return Lib.LoadCustomAsset(filepath)
	end
	
	local currentfilename, currentextension, currentclickhandler
	currentclickhandler = function() end
	Lib.SaveAsPrompt = function(filename, codeToSave, ext)		
		local win = ScriptViewer.SaveAsWindow
		if not win then
			win = Lib.Window.new()
			win.Alignable = false
			win.Resizable = false
			win:SetTitle("Save As")
			win:SetSize(300,95)

			local saveButton = Lib.Button.new()
			local nameLabel = Lib.Label.new()
			nameLabel.Text = "Name"
			nameLabel.Position = UDim2.new(0,30,0,10)
			nameLabel.Size = UDim2.new(0,40,0,20)
			win:Add(nameLabel)

			local nameBox = Lib.ViewportTextBox.new()
			nameBox.Position = UDim2.new(0,75,0,10)
			nameBox.Size = UDim2.new(0,220,0,20)
			win:Add(nameBox,"NameBox")

			--nameBox.TextBox.Text = filename or ""

			nameBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				saveButton:SetDisabled(#nameBox:GetText() == 0)
			end)

			local errorLabel = Lib.Label.new()
			errorLabel.Text = ""
			errorLabel.Position = UDim2.new(0,5,1,-45)
			errorLabel.Size = UDim2.new(1,-10,0,20)
			errorLabel.TextColor3 = Settings.Theme.Important
			win.ErrorLabel = errorLabel
			win:Add(errorLabel,"Error")

			local cancelButton = Lib.Button.new()
			cancelButton.AnchorPoint = Vector2.new(1,1)
			cancelButton.Text = "Cancel"
			cancelButton.Position = UDim2.new(1,-5,1,-5)
			cancelButton.Size = UDim2.new(0.5,-10,0,20)
			cancelButton.OnClick:Connect(function()
				win:Close()
			end)
			win:Add(cancelButton)

			saveButton.Text = "Save"
			saveButton.AnchorPoint = Vector2.new(0,1)
			saveButton.Position = UDim2.new(0,5,1,-5)
			saveButton.Size = UDim2.new(0.5,-5,0,20)
			saveButton.OnClick:Connect(function()
				currentclickhandler()
			end)

			win:Add(saveButton,"SaveButton")

			ScriptViewer.SaveAsWindow = win
		end

		currentclickhandler = function()
			if type(codeToSave) == "string" then
				filename = (win.Elements.NameBox.TextBox.Text ~= "" and win.Elements.NameBox.TextBox.Text) or filename
				currentextension = ext or filename:match("%.([^%.]+)$") or "txt"
				filename = filename:gsub("%.[^.]+$", "") .. "." .. currentextension

				local codeText = codeToSave or ""
				if env.writefile then
					local s, msg = pcall(env.writefile, filename, codeText)
					if not s then
						win.Elements.Error.Text = "Error: " .. msg
						task.spawn(error, msg)
						task.wait(1)
					end
				else
					win.Elements.Error.Text = "Your executor does not support 'writefile'"
					task.wait(1)
				end
			elseif type(codeToSave) == "function" then
				filename = (win.Elements.NameBox.TextBox.Text ~= "" and win.Elements.NameBox.TextBox.Text) or filename
				currentextension = ext or filename:match("%.([^%.]+)$") or "txt"
				filename = filename:gsub("%.[^.]+$", "") .. "." .. currentextension

				local s, msg = pcall(codeToSave,filename) -- callback
				if not s then
					win.Elements.Error.Text = "Error: " .. msg
					task.spawn(error, msg)
					Lib.FastWait(1)
				end
			end
			win:Close()
		end

		win:SetTitle("Save As")
		win.Elements.Error.Text = ""
		win.Elements.NameBox:SetText(filename or "")
		
		win.Elements.SaveButton:SetDisabled(win.Elements.NameBox:GetText() == 0)
		
		win:Show()
	end
	
	-- Classes

	Lib.Signal = (function()
		local funcs = {}

		local disconnect = function(con)
			local pos = table.find(con.Signal.Connections,con)
			if pos then table.remove(con.Signal.Connections,pos) end
		end

		funcs.Connect = function(self,func)
			if type(func) ~= "function" then error("Attempt to connect a non-function") end		
			local con = {
				Signal = self,
				Func = func,
				Disconnect = disconnect
			}
			self.Connections[#self.Connections+1] = con
			return con
		end

		funcs.Fire = function(self,...)
			for i,v in next,self.Connections do
				xpcall(coroutine.wrap(v.Func),function(e) warn(e.."\n"..debug.traceback()) end,...)
			end
		end

		local mt = {
			__index = funcs,
			__tostring = function(self)
				return "Signal: " .. tostring(#self.Connections) .. " Connections"
			end
		}

		local function new()
			local obj = {}
			obj.Connections = {}

			return setmetatable(obj,mt)
		end

		return {new = new}
	end)()

	Lib.Set = (function()
		local funcs = {}

		funcs.Add = function(self,obj)
			if self.Map[obj] then return end

			local list = self.List
			list[#list+1] = obj
			self.Map[obj] = true
			self.Changed:Fire()
		end

		funcs.AddTable = function(self,t)
			local changed
			local list,map = self.List,self.Map
			for i = 1,#t do
				local elem = t[i]
				if not map[elem] then
					list[#list+1] = elem
					map[elem] = true
					changed = true
				end
			end
			if changed then self.Changed:Fire() end
		end

		funcs.Remove = function(self,obj)
			if not self.Map[obj] then return end

			local list = self.List
			local pos = table.find(list,obj)
			if pos then table.remove(list,pos) end
			self.Map[obj] = nil
			self.Changed:Fire()
		end

		funcs.RemoveTable = function(self,t)
			local changed
			local list,map = self.List,self.Map
			local removeSet = {}
			for i = 1,#t do
				local elem = t[i]
				map[elem] = nil
				removeSet[elem] = true
			end

			for i = #list,1,-1 do
				local elem = list[i]
				if removeSet[elem] then
					table.remove(list,i)
					changed = true
				end
			end
			if changed then self.Changed:Fire() end
		end

		funcs.Set = function(self,obj)
			if #self.List == 1 and self.List[1] == obj then return end

			self.List = {obj}
			self.Map = {[obj] = true}
			self.Changed:Fire()
		end

		funcs.SetTable = function(self,t)
			local newList,newMap = {},{}
			self.List,self.Map = newList,newMap
			table.move(t,1,#t,1,newList)
			for i = 1,#t do
				newMap[t[i]] = true
			end
			self.Changed:Fire()
		end

		funcs.Clear = function(self)
			if #self.List == 0 then return end
			self.List = {}
			self.Map = {}
			self.Changed:Fire()
		end

		local mt = {__index = funcs}

		local function new()
			local obj = setmetatable({
				List = {},
				Map = {},
				Changed = Lib.Signal.new()
			},mt)

			return obj
		end

		return {new = new}
	end)()
	
	Lib.IconMap = (function()
		local funcs = {}
		local IconList = {
			Old = {
				MapId = 483448923,
				IconSize = 16,
				Witdh = 16,
				Height = 16,
				Icons = {
					["Accessory"] = 32;
					["Accoutrement"] = 32;
					["AdService"] = 73;
					["Animation"] = 60;
					["AnimationController"] = 60;
					["AnimationTrack"] = 60;
					["Animator"] = 60;
					["ArcHandles"] = 56;
					["AssetService"] = 72;
					["Attachment"] = 34;
					["Backpack"] = 20;
					["BadgeService"] = 75;
					["BallSocketConstraint"] = 89;
					["BillboardGui"] = 64;
					["BinaryStringValue"] = 4;
					["BindableEvent"] = 67;
					["BindableFunction"] = 66;
					["BlockMesh"] = 8;
					["BloomEffect"] = 90;
					["BlurEffect"] = 90;
					["BodyAngularVelocity"] = 14;
					["BodyForce"] = 14;
					["BodyGyro"] = 14;
					["BodyPosition"] = 14;
					["BodyThrust"] = 14;
					["BodyVelocity"] = 14;
					["BoolValue"] = 4;
					["BoxHandleAdornment"] = 54;
					["BrickColorValue"] = 4;
					["Camera"] = 5;
					["CFrameValue"] = 4;
					["CharacterMesh"] = 60;
					["Chat"] = 33;
					["ClickDetector"] = 41;
					["CollectionService"] = 30;
					["Color3Value"] = 4;
					["ColorCorrectionEffect"] = 90;
					["ConeHandleAdornment"] = 54;
					["Configuration"] = 58;
					["ContentProvider"] = 72;
					["ContextActionService"] = 41;
					["CoreGui"] = 46;
					["CoreScript"] = 18;
					["CornerWedgePart"] = 1;
					["CustomEvent"] = 4;
					["CustomEventReceiver"] = 4;
					["CylinderHandleAdornment"] = 54;
					["CylinderMesh"] = 8;
					["CylindricalConstraint"] = 89;
					["Debris"] = 30;
					["Decal"] = 7;
					["Dialog"] = 62;
					["DialogChoice"] = 63;
					["DoubleConstrainedValue"] = 4;
					["Explosion"] = 36;
					["FileMesh"] = 8;
					["Fire"] = 61;
					["Flag"] = 38;
					["FlagStand"] = 39;
					["FloorWire"] = 4;
					["Folder"] = 70;
					["ForceField"] = 37;
					["Frame"] = 48;
					["GamePassService"] = 19;
					["Glue"] = 34;
					["GuiButton"] = 52;
					["GuiMain"] = 47;
					["GuiService"] = 47;
					["Handles"] = 53;
					["HapticService"] = 84;
					["Hat"] = 45;
					["HingeConstraint"] = 89;
					["Hint"] = 33;
					["HopperBin"] = 22;
					["HttpService"] = 76;
					["Humanoid"] = 9;
					["ImageButton"] = 52;
					["ImageLabel"] = 49;
					["InsertService"] = 72;
					["IntConstrainedValue"] = 4;
					["IntValue"] = 4;
					["JointInstance"] = 34;
					["JointsService"] = 34;
					["Keyframe"] = 60;
					["KeyframeSequence"] = 60;
					["KeyframeSequenceProvider"] = 60;
					["Lighting"] = 13;
					["LineHandleAdornment"] = 54;
					["LocalScript"] = 18;
					["LogService"] = 87;
					["MarketplaceService"] = 46;
					["Message"] = 33;
					["Model"] = 2;
					["ModuleScript"] = 71;
					["Motor"] = 34;
					["Motor6D"] = 34;
					["MoveToConstraint"] = 89;
					["NegateOperation"] = 78;
					["NetworkClient"] = 16;
					["NetworkReplicator"] = 29;
					["NetworkServer"] = 15;
					["NumberValue"] = 4;
					["ObjectValue"] = 4;
					["Pants"] = 44;
					["ParallelRampPart"] = 1;
					["Part"] = 1;
					["ParticleEmitter"] = 69;
					["PartPairLasso"] = 57;
					["PathfindingService"] = 37;
					["Platform"] = 35;
					["Player"] = 12;
					["PlayerGui"] = 46;
					["Players"] = 21;
					["PlayerScripts"] = 82;
					["PointLight"] = 13;
					["PointsService"] = 83;
					["Pose"] = 60;
					["PrismaticConstraint"] = 89;
					["PrismPart"] = 1;
					["PyramidPart"] = 1;
					["RayValue"] = 4;
					["ReflectionMetadata"] = 86;
					["ReflectionMetadataCallbacks"] = 86;
					["ReflectionMetadataClass"] = 86;
					["ReflectionMetadataClasses"] = 86;
					["ReflectionMetadataEnum"] = 86;
					["ReflectionMetadataEnumItem"] = 86;
					["ReflectionMetadataEnums"] = 86;
					["ReflectionMetadataEvents"] = 86;
					["ReflectionMetadataFunctions"] = 86;
					["ReflectionMetadataMember"] = 86;
					["ReflectionMetadataProperties"] = 86;
					["ReflectionMetadataYieldFunctions"] = 86;
					["RemoteEvent"] = 80;
					["RemoteFunction"] = 79;
					["ReplicatedFirst"] = 72;
					["ReplicatedStorage"] = 72;
					["RightAngleRampPart"] = 1;
					["RocketPropulsion"] = 14;
					["RodConstraint"] = 89;
					["RopeConstraint"] = 89;
					["Rotate"] = 34;
					["RotateP"] = 34;
					["RotateV"] = 34;
					["RunService"] = 66;
					["ScreenGui"] = 47;
					["Script"] = 6;
					["ScrollingFrame"] = 48;
					["Seat"] = 35;
					["Selection"] = 55;
					["SelectionBox"] = 54;
					["SelectionPartLasso"] = 57;
					["SelectionPointLasso"] = 57;
					["SelectionSphere"] = 54;
					["ServerScriptService"] = 0;
					["ServerStorage"] = 74;
					["Shirt"] = 43;
					["ShirtGraphic"] = 40;
					["SkateboardPlatform"] = 35;
					["Sky"] = 28;
					["SlidingBallConstraint"] = 89;
					["Smoke"] = 59;
					["Snap"] = 34;
					["Sound"] = 11;
					["SoundService"] = 31;
					["Sparkles"] = 42;
					["SpawnLocation"] = 25;
					["SpecialMesh"] = 8;
					["SphereHandleAdornment"] = 54;
					["SpotLight"] = 13;
					["SpringConstraint"] = 89;
					["StarterCharacterScripts"] = 82;
					["StarterGear"] = 20;
					["StarterGui"] = 46;
					["StarterPack"] = 20;
					["StarterPlayer"] = 88;
					["StarterPlayerScripts"] = 82;
					["Status"] = 2;
					["StringValue"] = 4;
					["SunRaysEffect"] = 90;
					["SurfaceGui"] = 64;
					["SurfaceLight"] = 13;
					["SurfaceSelection"] = 55;
					["Team"] = 24;
					["Teams"] = 23;
					["TeleportService"] = 81;
					["Terrain"] = 65;
					["TerrainRegion"] = 65;
					["TestService"] = 68;
					["TextBox"] = 51;
					["TextButton"] = 51;
					["TextLabel"] = 50;
					["Texture"] = 10;
					["TextureTrail"] = 4;
					["Tool"] = 17;
					["TouchTransmitter"] = 37;
					["TrussPart"] = 1;
					["UnionOperation"] = 77;
					["UserInputService"] = 84;
					["Vector3Value"] = 4;
					["VehicleSeat"] = 35;
					["VelocityMotor"] = 34;
					["WedgePart"] = 1;
					["Weld"] = 34;
					["Workspace"] = 19;

				}
			},
			Vanilla3 = {
				MapId = (114851699900089),
				IconSize = 32,
				Witdh = 25,
				Height = 25,
				Icons = {
					Accessory = 1,
					Accoutrement = 2,
					Actor = 3,
					AdGui = 4,
					AdPortal = 5,
					AdService = 6,
					AdvancedDragger = 7,
					AirController = 8,
					AlignOrientation = 9,
					AlignPosition = 10,
					AnalysticsService = 11,
					AnalysticsSettings = 12,
					AnalyticsService = 13,
					AngularVelocity = 14,
					Animation = 15,
					AnimationClip = 16,
					AnimationClipProvider = 17,
					AnimationController = 18,
					AnimationFromVideoCreatorService = 19,
					AnimationFromVideoCreatorStudioService = 20,
					AnimationRigData = 21,
					AnimationStreamTrack = 22,
					AnimationTrack = 23,
					Animator = 24,
					AppStorageService = 25,
					AppUpdateService = 26,
					ArcHandles = 27,
					AssetCounterService = 28,
					AssetDeliveryProxy = 29,
					AssetImportService = 30,
					AssetImportSession = 31,
					AssetManagerService = 32,
					AssetService = 33,
					AssetSoundEffect = 34,
					Atmosphere = 35,
					Attachment = 36,
					AvatarEditorService = 37,
					AvatarImportService = 38,
					Backpack = 39,
					BackpackItem = 40,
					BadgeService = 41,
					BallSocketConstraint = 42,
					BasePart = 43,
					BasePlayerGui = 44,
					BaseScript = 45,
					BaseWrap = 46,
					Beam = 47,
					BevelMesh = 48,
					BillboardGui = 49,
					BinaryStringValue = 50,
					BindableEvent = 51,
					BindableFunction = 52,
					BlockMesh = 53,
					BloomEffect = 54,
					BlurEffect = 55,
					BodyAngularVelocity = 56,
					BodyColors = 57,
					BodyForce = 58,
					BodyGyro = 59,
					BodyMover = 60,
					BodyPosition = 61,
					BodyThrust = 62,
					BodyVelocity = 63,
					Bone = 64,
					BoolValue = 65,
					BoxHandleAdornment = 66,
					Breakpoint = 67,
					BreakpointManager = 68,
					BrickColorValue = 69,
					BrowserService = 70,
					BubbleChatConfiguration = 71,
					BulkImportService = 72,
					CacheableContentProvider = 73,
					CalloutService = 74,
					Camera = 75,
					CanvasGroup = 76,
					CatalogPages = 77,
					CFrameValue = 78,
					ChangeHistoryService = 79,
					ChannelSelectorSoundEffect = 80,
					CharacterAppearance = 81,
					CharacterMesh = 82,
					Chat = 83,
					ChatInputBarConfiguration = 84,
					ChatWindowConfiguration = 85,
					ChorusSoundEffect = 86,
					ClickDetector = 87,
					ClientReplicator = 88,
					ClimbController = 89,
					Clothing = 90,
					Clouds = 91,
					ClusterPacketCache = 92,
					CollectionService = 93,
					Color3Value = 94,
					ColorCorrectionEffect = 95,
					CommandInstance = 96,
					CommandService = 97,
					CompressorSoundEffect = 98,
					ConeHandleAdornment = 99,
					Configuration = 100,
					ConfigureServerService = 101,
					Constraint = 102,
					ContentProvider = 103,
					ContextActionService = 104,
					Controller = 105,
					ControllerBase = 106,
					ControllerManager = 107,
					ControllerService = 108,
					CookiesService = 109,
					CoreGui = 110,
					CorePackages = 111,
					CoreScript = 112,
					CoreScriptSyncService = 113,
					CornerWedgePart = 114,
					CrossDMScriptChangeListener = 115,
					CSGDictionaryService = 116,
					CurveAnimation = 117,
					CustomEvent = 118,
					CustomEventReceiver = 119,
					CustomSoundEffect = 120,
					CylinderHandleAdornment = 121,
					CylinderMesh = 122,
					CylindricalConstraint = 123,
					DataModel = 124,
					DataModelMesh = 125,
					DataModelPatchService = 126,
					DataModelSession = 127,
					DataStore = 128,
					DataStoreIncrementOptions = 129,
					DataStoreInfo = 130,
					DataStoreKey = 131,
					DataStoreKeyInfo = 132,
					DataStoreKeyPages = 133,
					DataStoreListingPages = 134,
					DataStoreObjectVersionInfo = 135,
					DataStoreOptions = 136,
					DataStorePages = 137,
					DataStoreService = 138,
					DataStoreSetOptions = 139,
					DataStoreVersionPages = 140,
					Debris = 141,
					DebuggablePluginWatcher = 142,
					DebuggerBreakpoint = 143,
					DebuggerConnection = 144,
					DebuggerConnectionManager = 145,
					DebuggerLuaResponse = 146,
					DebuggerManager = 147,
					DebuggerUIService = 148,
					DebuggerVariable = 149,
					DebuggerWatch = 150,
					DebugSettings = 151,
					Decal = 152,
					DepthOfFieldEffect = 153,
					DeviceIdService = 154,
					Dialog = 155,
					DialogChoice = 156,
					DistortionSoundEffect = 157,
					DockWidgetPluginGui = 158,
					DoubleConstrainedValue = 159,
					DraftsService = 160,
					Dragger = 161,
					DraggerService = 162,
					DynamicRotate = 163,
					EchoSoundEffect = 164,
					EmotesPages = 165,
					EqualizerSoundEffect = 166,
					EulerRotationCurve = 167,
					EventIngestService = 168,
					Explosion = 169,
					FaceAnimatorService = 170,
					FaceControls = 171,
					FaceInstance = 172,
					FacialAnimationRecordingService = 173,
					FacialAnimationStreamingService = 174,
					Feature = 175,
					File = 176,
					FileMesh = 177,
					Fire = 178,
					Flag = 179,
					FlagStand = 180,
					FlagStandService = 181,
					FlangeSoundEffect = 182,
					FloatCurve = 183,
					FloorWire = 184,
					FlyweightService = 185,
					Folder = 186,
					ForceField = 187,
					FormFactorPart = 188,
					Frame = 189,
					FriendPages = 190,
					FriendService = 191,
					FunctionalTest = 192,
					GamepadService = 193,
					GamePassService = 194,
					GameSettings = 195,
					GenericSettings = 196,
					Geometry = 197,
					GetTextBoundsParams = 198,
					GlobalDataStore = 199,
					GlobalSettings = 200,
					Glue = 201,
					GoogleAnalyticsConfiguration = 202,
					GroundController = 203,
					GroupService = 204,
					GuiBase = 205,
					GuiBase2d = 206,
					GuiBase3d = 207,
					GuiButton = 208,
					GuidRegistryService = 209,
					GuiLabel = 210,
					GuiMain = 211,
					GuiObject = 212,
					GuiService = 213,
					HandleAdornment = 214,
					Handles = 215,
					HandlesBase = 216,
					HapticService = 217,
					Hat = 218,
					HeightmapImporterService = 219,
					HiddenSurfaceRemovalAsset = 220,
					Highlight = 221,
					HingeConstraint = 222,
					Hint = 223,
					Hole = 224,
					Hopper = 225,
					HopperBin = 226,
					HSRDataContentProvider = 227,
					HttpRbxApiService = 228,
					HttpRequest = 229,
					HttpService = 230,
					Humanoid = 231,
					HumanoidController = 232,
					HumanoidDescription = 233,
					IKControl = 234,
					ILegacyStudioBridge = 235,
					ImageButton = 236,
					ImageHandleAdornment = 237,
					ImageLabel = 238,
					ImporterAnimationSettings = 239,
					ImporterBaseSettings = 240,
					ImporterFacsSettings = 241,
					ImporterGroupSettings = 242,
					ImporterJointSettings = 243,
					ImporterMaterialSettings = 244,
					ImporterMeshSettings = 245,
					ImporterRootSettings = 246,
					IncrementalPatchBuilder = 247,
					InputObject = 248,
					InsertService = 249,
					Instance = 250,
					InstanceAdornment = 251,
					IntConstrainedValue = 252,
					IntValue = 253,
					InventoryPages = 254,
					IXPService = 255,
					JointInstance = 256,
					JointsService = 257,
					KeyboardService = 258,
					Keyframe = 259,
					KeyframeMarker = 260,
					KeyframeSequence = 261,
					KeyframeSequenceProvider = 262,
					LanguageService = 263,
					LayerCollector = 264,
					LegacyStudioBridge = 265,
					Light = 266,
					Lighting = 267,
					LinearVelocity = 268,
					LineForce = 269,
					LineHandleAdornment = 270,
					LocalDebuggerConnection = 271,
					LocalizationService = 272,
					LocalizationTable = 273,
					LocalScript = 274,
					LocalStorageService = 275,
					LodDataEntity = 276,
					LodDataService = 277,
					LoginService = 278,
					LogService = 279,
					LSPFileSyncService = 280,
					LuaSettings = 281,
					LuaSourceContainer = 282,
					LuauScriptAnalyzerService = 283,
					LuaWebService = 284,
					ManualGlue = 285,
					ManualSurfaceJointInstance = 286,
					ManualWeld = 287,
					MarkerCurve = 288,
					MarketplaceService = 289,
					MaterialService = 290,
					MaterialVariant = 291,
					MemoryStoreQueue = 292,
					MemoryStoreService = 293,
					MemoryStoreSortedMap = 294,
					MemStorageConnection = 295,
					MemStorageService = 296,
					MeshContentProvider = 297,
					MeshPart = 298,
					Message = 299,
					MessageBusConnection = 300,
					MessageBusService = 301,
					MessagingService = 302,
					MetaBreakpoint = 303,
					MetaBreakpointContext = 304,
					MetaBreakpointManager = 305,
					Model = 306,
					ModuleScript = 307,
					Motor = 308,
					Motor6D = 309,
					MotorFeature = 310,
					Mouse = 311,
					MouseService = 312,
					MultipleDocumentInterfaceInstance = 313,
					NegateOperation = 314,
					NetworkClient = 315,
					NetworkMarker = 316,
					NetworkPeer = 317,
					NetworkReplicator = 318,
					NetworkServer = 319,
					NetworkSettings = 320,
					NoCollisionConstraint = 321,
					NonReplicatedCSGDictionaryService = 322,
					NotificationService = 323,
					NumberPose = 324,
					NumberValue = 325,
					ObjectValue = 326,
					OrderedDataStore = 327,
					OutfitPages = 328,
					PackageLink = 329,
					PackageService = 330,
					PackageUIService = 331,
					Pages = 332,
					Pants = 333,
					ParabolaAdornment = 334,
					Part = 335,
					PartAdornment = 336,
					ParticleEmitter = 337,
					PartOperation = 338,
					PartOperationAsset = 339,
					PatchMapping = 340,
					Path = 341,
					PathfindingLink = 342,
					PathfindingModifier = 343,
					PathfindingService = 344,
					PausedState = 345,
					PausedStateBreakpoint = 346,
					PausedStateException = 347,
					PermissionsService = 348,
					PhysicsService = 349,
					PhysicsSettings = 350,
					PitchShiftSoundEffect = 351,
					Plane = 352,
					PlaneConstraint = 353,
					Platform = 354,
					Player = 355,
					PlayerEmulatorService = 356,
					PlayerGui = 357,
					PlayerMouse = 358,
					Players = 359,
					PlayerScripts = 360,
					Plugin = 361,
					PluginAction = 362,
					PluginDebugService = 363,
					PluginDragEvent = 364,
					PluginGui = 365,
					PluginGuiService = 366,
					PluginManagementService = 367,
					PluginManager = 368,
					PluginManagerInterface = 369,
					PluginMenu = 370,
					PluginMouse = 371,
					PluginPolicyService = 372,
					PluginToolbar = 373,
					PluginToolbarButton = 374,
					PointLight = 375,
					PointsService = 376,
					PolicyService = 377,
					Pose = 378,
					PoseBase = 379,
					PostEffect = 380,
					PrismaticConstraint = 381,
					ProcessInstancePhysicsService = 382,
					ProximityPrompt = 383,
					ProximityPromptService = 384,
					PublishService = 385,
					PVAdornment = 386,
					PVInstance = 387,
					QWidgetPluginGui = 388,
					RayValue = 389,
					RbxAnalyticsService = 390,
					ReflectionMetadata = 391,
					ReflectionMetadataCallbacks = 392,
					ReflectionMetadataClass = 393,
					ReflectionMetadataClasses = 394,
					ReflectionMetadataEnum = 395,
					ReflectionMetadataEnumItem = 396,
					ReflectionMetadataEnums = 397,
					ReflectionMetadataEvents = 398,
					ReflectionMetadataFunctions = 399,
					ReflectionMetadataItem = 400,
					ReflectionMetadataMember = 401,
					ReflectionMetadataProperties = 402,
					ReflectionMetadataYieldFunctions = 403,
					RemoteDebuggerServer = 404,
					RemoteEvent = 405,
					RemoteFunction = 406,
					RenderingTest = 407,
					RenderSettings = 408,
					ReplicatedFirst = 409,
					ReplicatedStorage = 410,
					ReverbSoundEffect = 411,
					RigidConstraint = 412,
					RobloxPluginGuiService = 413,
					RobloxReplicatedStorage = 414,
					RocketPropulsion = 415,
					RodConstraint = 416,
					RopeConstraint = 417,
					Rotate = 418,
					RotateP = 419,
					RotateV = 420,
					RotationCurve = 421,
					RtMessagingService = 422,
					RunningAverageItemDouble = 423,
					RunningAverageItemInt = 424,
					RunningAverageTimeIntervalItem = 425,
					RunService = 426,
					RuntimeScriptService = 427,
					ScreenGui = 428,
					ScreenshotHud = 429,
					Script = 430,
					ScriptChangeService = 431,
					ScriptCloneWatcher = 432,
					ScriptCloneWatcherHelper = 433,
					ScriptContext = 434,
					ScriptDebugger = 435,
					ScriptDocument = 436,
					ScriptEditorService = 437,
					ScriptRegistrationService = 438,
					ScriptService = 439,
					ScrollingFrame = 440,
					Seat = 441,
					Selection = 442,
					SelectionBox = 443,
					SelectionLasso = 444,
					SelectionPartLasso = 445,
					SelectionPointLasso = 446,
					SelectionSphere = 447,
					ServerReplicator = 448,
					ServerScriptService = 449,
					ServerStorage = 450,
					ServiceProvider = 451,
					SessionService = 452,
					Shirt = 453,
					ShirtGraphic = 454,
					SkateboardController = 455,
					SkateboardPlatform = 456,
					Skin = 457,
					Sky = 458,
					SlidingBallConstraint = 459,
					Smoke = 460,
					Snap = 461,
					SnippetService = 462,
					SocialService = 463,
					SolidModelContentProvider = 464,
					Sound = 465,
					SoundEffect = 466,
					SoundGroup = 467,
					SoundService = 468,
					Sparkles = 469,
					SpawnerService = 470,
					SpawnLocation = 471,
					Speaker = 472,
					SpecialMesh = 473,
					SphereHandleAdornment = 474,
					SpotLight = 475,
					SpringConstraint = 476,
					StackFrame = 477,
					StandalonePluginScripts = 478,
					StandardPages = 479,
					StarterCharacterScripts = 480,
					StarterGear = 481,
					StarterGui = 482,
					StarterPack = 483,
					StarterPlayer = 484,
					StarterPlayerScripts = 485,
					Stats = 486,
					StatsItem = 487,
					Status = 488,
					StopWatchReporter = 489,
					StringValue = 490,
					Studio = 491,
					StudioAssetService = 492,
					StudioData = 493,
					StudioDeviceEmulatorService = 494,
					StudioHighDpiService = 495,
					StudioPublishService = 496,
					StudioScriptDebugEventListener = 497,
					StudioService = 498,
					StudioTheme = 499,
					SunRaysEffect = 500,
					SurfaceAppearance = 501,
					SurfaceGui = 502,
					SurfaceGuiBase = 503,
					SurfaceLight = 504,
					SurfaceSelection = 505,
					SwimController = 506,
					TaskScheduler = 507,
					Team = 508,
					TeamCreateService = 509,
					Teams = 510,
					TeleportAsyncResult = 511,
					TeleportOptions = 512,
					TeleportService = 513,
					TemporaryCageMeshProvider = 514,
					TemporaryScriptService = 515,
					Terrain = 516,
					TerrainDetail = 517,
					TerrainRegion = 518,
					TestService = 519,
					TextBox = 520,
					TextBoxService = 521,
					TextButton = 522,
					TextChannel = 523,
					TextChatCommand = 524,
					TextChatConfigurations = 525,
					TextChatMessage = 526,
					TextChatMessageProperties = 527,
					TextChatService = 528,
					TextFilterResult = 529,
					TextLabel = 530,
					TextService = 531,
					TextSource = 532,
					Texture = 533,
					ThirdPartyUserService = 534,
					ThreadState = 535,
					TimerService = 536,
					ToastNotificationService = 537,
					Tool = 538,
					ToolboxService = 539,
					Torque = 540,
					TorsionSpringConstraint = 541,
					TotalCountTimeIntervalItem = 542,
					TouchInputService = 543,
					TouchTransmitter = 544,
					TracerService = 545,
					TrackerStreamAnimation = 546,
					Trail = 547,
					Translator = 548,
					TremoloSoundEffect = 549,
					TriangleMeshPart = 550,
					TrussPart = 551,
					Tween = 552,
					TweenBase = 553,
					TweenService = 554,
					UGCValidationService = 555,
					UIAspectRatioConstraint = 556,
					UIBase = 557,
					UIComponent = 558,
					UIConstraint = 559,
					UICorner = 560,
					UIGradient = 561,
					UIGridLayout = 562,
					UIGridStyleLayout = 563,
					UILayout = 564,
					UIListLayout = 565,
					UIPadding = 566,
					UIPageLayout = 567,
					UIScale = 568,
					UISizeConstraint = 569,
					UIStroke = 570,
					UITableLayout = 571,
					UITextSizeConstraint = 572,
					UnionOperation = 573,
					UniversalConstraint = 574,
					UnvalidatedAssetService = 575,
					UserGameSettings = 576,
					UserInputService = 577,
					UserService = 578,
					UserSettings = 579,
					UserStorageService = 580,
					ValueBase = 581,
					Vector3Curve = 582,
					Vector3Value = 583,
					VectorForce = 584,
					VehicleController = 585,
					VehicleSeat = 586,
					VelocityMotor = 587,
					VersionControlService = 588,
					VideoCaptureService = 589,
					VideoFrame = 590,
					ViewportFrame = 591,
					VirtualInputManager = 592,
					VirtualUser = 593,
					VisibilityService = 594,
					Visit = 595,
					VoiceChannel = 596,
					VoiceChatInternal = 597,
					VoiceChatService = 598,
					VoiceSource = 599,
					VRService = 600,
					WedgePart = 601,
					Weld = 602,
					WeldConstraint = 603,
					WireframeHandleAdornment = 604,
					Workspace = 605,
					WorldModel = 606,
					WorldRoot = 607,
					WrapLayer = 608,
					WrapTarget = 609,

				}
			},
			NewDark = {
				MapId = 135148380892747,
				Icons = {
					Accessory = 1,
					Actor = 2,
					AdGui = 3,
					AdPortal = 4,
					AirController = 5,
					AlignOrientation = 6,
					AlignPosition = 7,
					AngularVelocity = 8,
					Animation = 9,
					AnimationConstraint = 10,
					AnimationController = 11,
					AnimationFromVideoCreatorService = 12,
					Animator = 13,
					ArcHandles = 14,
					Atmosphere = 15,
					Attachment = 16,
					AudioAnalyzer = 17,
					AudioChannelMixer = 18,
					AudioChannelSplitter = 19,
					AudioChorus = 20,
					AudioCompressor = 21,
					AudioDeviceInput = 22,
					AudioDeviceOutput = 23,
					AudioDistortion = 24,
					AudioEcho = 25,
					AudioEmitter = 26,
					AudioEqualizer = 27,
					AudioFader = 28,
					AudioFilter = 29,
					AudioFlanger = 30,
					AudioGate = 31,
					AudioLimiter = 32,
					AudioListener = 33,
					AudioPitchShifter = 34,
					AudioPlayer = 35,
					AudioRecorder = 36,
					AudioReverb = 37,
					AudioTextToSpeech = 38,
					AuroraScript = 39,
					AvatarEditorService = 40,
					AvatarSettings = 41,
					Backpack = 42,
					BallSocketConstraint = 43,
					BasePlate = 44,
					Beam = 45,
					BillboardGui = 46,
					BindableEvent = 47,
					BindableFunction = 48,
					BlockMesh = 49,
					BloomEffect = 50,
					BlurEffect = 51,
					BodyAngularVelocity = 52,
					BodyColors = 53,
					BodyForce = 54,
					BodyGyro = 55,
					BodyPosition = 56,
					BodyThrust = 57,
					BodyVelocity = 58,
					Bone = 59,
					BoolValue = 60,
					BoxHandleAdornment = 61,
					Breakpoint = 62,
					BrickColorValue = 63,
					BubbleChatConfiguration = 64,
					Buggaroo = 65,
					Camera = 66,
					CanvasGroup = 67,
					CFrameValue = 68,
					ChannelTabsConfiguration = 69,
					CharacterControllerManager = 70,
					CharacterMesh = 71,
					Chat = 72,
					ChatInputBarConfiguration = 73,
					ChatWindowConfiguration = 74,
					ChorusSoundEffect = 75,
					Class = 76,
					Cleanup = 77,
					ClickDetector = 78,
					ClientReplicator = 79,
					ClimbController = 80,
					Clouds = 81,
					Color = 82,
					ColorCorrectionEffect = 83,
					CompressorSoundEffect = 84,
					ConeHandleAdornment = 85,
					Configuration = 86,
					Constant = 87,
					Constructor = 88,
					Controller = 89,
					CoreGui = 90,
					CornerWedgePart = 91,
					CylinderHandleAdornment = 92,
					CylindricalConstraint = 93,
					Decal = 94,
					DepthOfFieldEffect = 95,
					Dialog = 96,
					DialogChoice = 97,
					DistortionSoundEffect = 98,
					DragDetector = 99,
					EchoSoundEffect = 100,
					EditableImage = 101,
					EditableMesh = 102,
					Enum = 103,
					EnumMember = 104,
					EqualizerSoundEffect = 105,
					Event = 106,
					Explosion = 107,
					FaceControls = 108,
					Field = 109,
					File = 110,
					Fire = 111,
					FlangeSoundEffect = 112,
					Folder = 113,
					ForceField = 114,
					Frame = 115,
					Function = 116,
					GameSettings = 117,
					GroundController = 118,
					Handles = 119,
					HapticEffect = 120,
					HapticService = 121,
					HeightmapImporterService = 122,
					Highlight = 123,
					HingeConstraint = 124,
					Humanoid = 125,
					HumanoidDescription = 126,
					IKControl = 127,
					ImageButton = 128,
					ImageHandleAdornment = 129,
					ImageLabel = 130,
					InputAction = 131,
					InputBinding = 132,
					InputContext = 133,
					Interface = 134,
					IntersectOperation = 135,
					Keyword = 136,
					Lighting = 137,
					LinearVelocity = 138,
					LineForce = 139,
					LineHandleAdornment = 140,
					LocalFile = 141,
					LocalizationService = 142,
					LocalizationTable = 143,
					LocalScript = 144,
					MaterialService = 145,
					MaterialVariant = 146,
					MemoryStoreService = 147,
					MeshPart = 148,
					Meshparts = 149,
					MessagingService = 150,
					Method = 151,
					Model = 152,
					Modelgroups = 153,
					Module = 154,
					ModuleScript = 155,
					Motor6D = 156,
					NegateOperation = 157,
					NetworkClient = 158,
					NoCollisionConstraint = 159,
					Operator = 160,
					PackageLink = 161,
					Pants = 162,
					Part = 163,
					ParticleEmitter = 164,
					Path2D = 165,
					PathfindingLink = 166,
					PathfindingModifier = 167,
					PathfindingService = 168,
					PitchShiftSoundEffect = 169,
					Place = 170,
					Placeholder = 171,
					Plane = 172,
					PlaneConstraint = 173,
					Player = 174,
					Players = 175,
					PluginGuiService = 176,
					PointLight = 177,
					PrismaticConstraint = 178,
					Property = 179,
					ProximityPrompt = 180,
					PublishService = 181,
					Reference = 182,
					RemoteEvent = 183,
					RemoteFunction = 184,
					RenderingTest = 185,
					ReplicatedFirst = 186,
					ReplicatedScriptService = 187,
					ReplicatedStorage = 188,
					ReverbSoundEffect = 189,
					RigidConstraint = 190,
					RobloxPluginGuiService = 191,
					RocketPropulsion = 192,
					RodConstraint = 193,
					RopeConstraint = 194,
					Rotate = 195,
					ScreenGui = 196,
					Script = 197,
					ScrollingFrame = 198,
					Seat = 199,
					Selected_Workspace = 200,
					SelectionBox = 201,
					SelectionSphere = 202,
					ServerScriptService = 203,
					ServerStorage = 204,
					Service = 205,
					Shirt = 206,
					ShirtGraphic = 207,
					SkinnedMeshPart = 208,
					Sky = 209,
					Smoke = 210,
					Snap = 211,
					Snippet = 212,
					SocialService = 213,
					Sound = 214,
					SoundEffect = 215,
					SoundGroup = 216,
					SoundService = 217,
					Sparkles = 218,
					SpawnLocation = 219,
					SpecialMesh = 220,
					SphereHandleAdornment = 221,
					SpotLight = 222,
					SpringConstraint = 223,
					StandalonePluginScripts = 224,
					StarterCharacterScripts = 225,
					StarterGui = 226,
					StarterPack = 227,
					StarterPlayer = 228,
					StarterPlayerScripts = 229,
					Struct = 230,
					StyleDerive = 231,
					StyleLink = 232,
					StyleRule = 233,
					StyleSheet = 234,
					SunRaysEffect = 235,
					SurfaceAppearance = 236,
					SurfaceGui = 237,
					SurfaceLight = 238,
					SurfaceSelection = 239,
					SwimController = 240,
					TaskScheduler = 241,
					Team = 242,
					Teams = 243,
					Terrain = 244,
					TerrainDetail = 245,
					TestService = 246,
					TextBox = 247,
					TextBoxService = 248,
					TextButton = 249,
					TextChannel = 250,
					TextChatCommand = 251,
					TextChatService = 252,
					TextLabel = 253,
					TextString = 254,
					Texture = 255,
					Tool = 256,
					Torque = 257,
					TorsionSpringConstraint = 258,
					Trail = 259,
					TremoloSoundEffect = 260,
					TrussPart = 261,
					TypeParameter = 262,
					UGCValidationService = 263,
					UIAspectRatioConstraint = 264,
					UICorner = 265,
					UIDragDetector = 266,
					UIFlexItem = 267,
					UIGradient = 268,
					UIGridLayout = 269,
					UIListLayout = 270,
					UIPadding = 271,
					UIPageLayout = 272,
					UIScale = 273,
					UISizeConstraint = 274,
					UIStroke = 275,
					UITableLayout = 276,
					UITextSizeConstraint = 277,
					UnionOperation = 278,
					Unit = 279,
					UniversalConstraint = 280,
					UnreliableRemoteEvent = 281,
					UpdateAvailable = 282,
					UserService = 283,
					Value = 284,
					Variable = 285,
					VectorForce = 286,
					VehicleSeat = 287,
					VideoDisplay = 288,
					VideoFrame = 289,
					VideoPlayer = 290,
					ViewportFrame = 291,
					VirtualUser = 292,
					VoiceChannel = 293,
					Voicechat = 294,
					VoiceChatService = 295,
					VRService = 296,
					WedgePart = 297,
					Weld = 298,
					WeldConstraint = 299,
					Wire = 300,
					WireframeHandleAdornment = 301,
					Workspace = 302,
					WorldModel = 303,
					WrapDeformer = 304,
					WrapLayer = 305,
					WrapTarget = 306,
					
					Color3Value = 284,
					IntValue = 284,
					NumberValue = 284,
					ObjectValue = 284,
					RayValue = 284,
					StringValue = 284,
					Vector3Value = 284,
				},
				IconSize = 32,
				Witdh = 18,
				Height = 18,
			},
			NewLight = {
				MapId = "",
				Icons = {
					Class = "rbxasset://studio_svg_textures/Shared/InsertableObjects/Light/Standard/",
				},
				IconSize = 16,
				Witdh = 18,
				Height = 18,
			}
		}
		if Settings.ClassIcon and IconList[Settings.ClassIcon] then
			funcs.ExplorerIcons = {
				["MapId"] = IconList[Settings.ClassIcon].MapId,
				["Icons"] = IconList[Settings.ClassIcon].Icons,
				["IconSize"] = IconList[Settings.ClassIcon].IconSize,
				["Witdh"] = IconList[Settings.ClassIcon].Witdh,
				["Height"] = IconList[Settings.ClassIcon].Height}
		else
			funcs.ExplorerIcons = { ["MapId"] = IconList.Old.MapId, ["Icons"] = IconList.Old.Icons, ["IconSize"] = IconList.Old.IconSize }
		end
		
		

		funcs.GetLabel = function(self)
			local label = Instance.new("ImageLabel")
			self:SetupLabel(label)
			return label
		end

		funcs.SetupLabel = function(self,obj)
			obj.BackgroundTransparency = 1
			obj.ImageRectOffset = Vector2.new(0, 0)
			obj.ImageRectSize = Vector2.new(self.IconSizeX, self.IconSizeY)
			obj.ScaleType = Enum.ScaleType.Crop
			obj.Size = UDim2.new(0, self.IconSizeX, 0, self.IconSizeY)
		end

		funcs.Display = function(self,obj,index)
			obj.Image = self.MapId
			obj.ImageRectSize = Vector2.new(self.IconSizeX, self.IconSizeY)
			if not self.NumX then
				obj.ImageRectOffset = Vector2.new(self.IconSizeX*index, 0)
			else
				obj.ImageRectOffset = Vector2.new(self.IconSizeX*(index % self.NumX), self.IconSizeY*math.floor(index / self.NumX))
			end
		end

		funcs.DisplayByKey = function(self, obj, key)
			if self.IndexDict[key] then
				self:Display(obj, self.IndexDict[key])
			else
				local rmdEntry = RMD.Classes[obj.ClassName]
				Explorer.ClassIcons:Display(obj, rmdEntry and rmdEntry.ExplorerImageIndex or 0)
			end
		end

		funcs.IconDehash = function(self, _id)
			return math.floor(_id / 14 % 14), math.floor(_id % 14)
		end
		
		local ClassNameNoImage = {}
		funcs.GetExplorerIcon = function(self, obj, index)
			if Settings.ClassIcon == "Vanilla3" then
				obj.Size = UDim2.fromOffset(16, 16)

				index = (self.ExplorerIcons.Icons[index] or 250) - 1
				obj.ImageRectOffset = Vector2.new(funcs.ExplorerIcons.IconSize * (index % funcs.ExplorerIcons.Height), funcs.ExplorerIcons.IconSize * math.floor(index / funcs.ExplorerIcons.Height))
				obj.ImageRectSize = Vector2.new(funcs.ExplorerIcons.IconSize, funcs.ExplorerIcons.IconSize)
			elseif Settings.ClassIcon == "Old" then
				index = (self.ExplorerIcons.Icons[index] or 0)
				local row, col = self:IconDehash(index)
				local MapSize = Vector2.new(256, 256)
				local pad, border = 2, 1

				obj.Position = UDim2.new(-col - (pad * (col + 1) + border) / funcs.ExplorerIcons.IconSize, 0, -row - (pad * (row + 1) + border) / funcs.ExplorerIcons.IconSize, 0)
				obj.Size = UDim2.new(MapSize.X / funcs.ExplorerIcons.IconSize, 0, MapSize.Y / funcs.ExplorerIcons.IconSize, 0)
			elseif Settings.ClassIcon == "NewLight" or Settings.ClassIcon == "NewDark" then
				local isService = string.find(index, "Service") and game:GetService(index)
				
				obj.Size = UDim2.fromOffset(16, 16)
				index = (self.ExplorerIcons.Icons[index] or (isService and self.ExplorerIcons.Icons.Service) or self.ExplorerIcons.Icons.Placeholder) - 1
				obj.ImageRectOffset = Vector2.new(funcs.ExplorerIcons.IconSize * (index % funcs.ExplorerIcons.Height), funcs.ExplorerIcons.IconSize * math.floor(index / funcs.ExplorerIcons.Height))
				obj.ImageRectSize = Vector2.new(funcs.ExplorerIcons.IconSize, funcs.ExplorerIcons.IconSize)
			else
				index = (self.ExplorerIcons.Icons[index] or 0)
				local row, col = self:IconDehash(index)
				local MapSize = Vector2.new(256, 256)
				local pad, border = 2, 1

				obj.Position = UDim2.new(-col - (pad * (col + 1) + border) / funcs.ExplorerIcons.IconSize, 0, -row - (pad * (row + 1) + border) / funcs.ExplorerIcons.IconSize, 0)
				obj.Size = UDim2.new(MapSize.X / funcs.ExplorerIcons.IconSize, 0, MapSize.Y / funcs.ExplorerIcons.IconSize, 0)
			end
			
		end

		funcs.DisplayExplorerIcons = function(self, Frame, index)
			if Frame:FindFirstChild("IconMap") then
				self:GetExplorerIcon(Frame.IconMap, index)
			else
				Frame.ClipsDescendants = true

				local obj = Instance.new("ImageLabel", Frame)
				obj.BackgroundTransparency = 1
				obj.Image = ("http://www.roblox.com/asset/?id=" .. (self.ExplorerIcons.MapId))
				obj.Name = "IconMap"
				self:GetExplorerIcon(obj, index)
			end
		end

		funcs.SetDict = function(self,dict)
			self.IndexDict = dict
		end

		local mt = {}
		mt.__index = funcs

		local function new(mapId,mapSizeX,mapSizeY,iconSizeX,iconSizeY)
			local obj = setmetatable({
				MapId = mapId,
				MapSizeX = mapSizeX,
				MapSizeY = mapSizeY,
				IconSizeX = iconSizeX,
				IconSizeY = iconSizeY,
				NumX = mapSizeX/iconSizeX,
				IndexDict = {}
			}, mt)
			return obj
		end

		local function newLinear(mapId,iconSizeX,iconSizeY)
			local obj = setmetatable({
				MapId = mapId,
				IconSizeX = iconSizeX,
				IconSizeY = iconSizeY,
				IndexDict = {}
			},mt)
			return obj
		end
		
		local function getIconDataFromName(name)
			return IconList[name] or error("Name not found")
		end

		return {new = new, newLinear = newLinear, getIconDataFromName = getIconDataFromName}
	end)()

	Lib.ScrollBar = (function()
		local funcs = {}
		local user = service.UserInputService
		local mouse = plr:GetMouse()
		local checkMouseInGui = Lib.CheckMouseInGui
		local createArrow = Lib.CreateArrow

		local function drawThumb(self)
			local total = self.TotalSpace
			local visible = self.VisibleSpace
			local index = self.Index
			local scrollThumb = self.GuiElems.ScrollThumb
			local scrollThumbFrame = self.GuiElems.ScrollThumbFrame

			if not (self:CanScrollUp()	or self:CanScrollDown()) then
				scrollThumb.Visible = false
			else
				scrollThumb.Visible = true
			end

			if self.Horizontal then
				scrollThumb.Size = UDim2.new(visible/total,0,1,0)
				if scrollThumb.AbsoluteSize.X < 16 then
					scrollThumb.Size = UDim2.new(0,16,1,0)
				end
				local fs = scrollThumbFrame.AbsoluteSize.X
				local bs = scrollThumb.AbsoluteSize.X
				scrollThumb.Position = UDim2.new(self:GetScrollPercent()*(fs-bs)/fs,0,0,0)
			else
				scrollThumb.Size = UDim2.new(1,0,visible/total,0)
				if scrollThumb.AbsoluteSize.Y < 16 then
					scrollThumb.Size = UDim2.new(1,0,0,16)
				end
				local fs = scrollThumbFrame.AbsoluteSize.Y
				local bs = scrollThumb.AbsoluteSize.Y
				scrollThumb.Position = UDim2.new(0,0,self:GetScrollPercent()*(fs-bs)/fs,0)
			end
		end

		local function createFrame(self)
			local newFrame = createSimple("Frame",{Style=0,Active=true,AnchorPoint=Vector2.new(0,0),BackgroundColor3=Color3.new(0.35294118523598,0.35294118523598,0.35294118523598),BackgroundTransparency=0,BorderColor3=Color3.new(0.10588236153126,0.16470588743687,0.20784315466881),BorderSizePixel=0,ClipsDescendants=false,Draggable=false,Position=UDim2.new(1,-16,0,0),Rotation=0,Selectable=false,Size=UDim2.new(0,16,1,0),SizeConstraint=0,Visible=true,ZIndex=1,Name="ScrollBar",})
			local button1, button2

			if self.Horizontal then
				newFrame.Size = UDim2.new(1,0,0,16)
				button1 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Left",
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"left").Parent = button1
				button2 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Right",
					Position = UDim2.new(1,-16,0,0),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"right").Parent = button2
			else
				newFrame.Size = UDim2.new(0,16,1,0)
				button1 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Up",
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"up").Parent = button1
				button2 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Down",
					Position = UDim2.new(0,0,1,-16),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"down").Parent = button2
			end

			local scrollThumbFrame = createSimple("ImageButton", {
				BackgroundTransparency = 1,
				Parent = newFrame
			})
			if self.Horizontal then
				scrollThumbFrame.Position = UDim2.new(0,16,0,0)
				scrollThumbFrame.Size = UDim2.new(1,-32,1,0)
			else
				scrollThumbFrame.Position = UDim2.new(0,0,0,16)
				scrollThumbFrame.Size = UDim2.new(1,0,1,-32)
			end

			local scrollThumb = createSimple("Frame", {
				BackgroundColor3 = Color3.new(120/255, 120/255, 120/255),
				BorderSizePixel = 0,
				Parent = scrollThumbFrame
			})

			local markerFrame = createSimple("Frame", {
				BackgroundTransparency = 1,
				Name = "Markers",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = scrollThumbFrame
			})

			local buttonPress = false
			local thumbPress = false
			local thumbFramePress = false

			local function handleButtonPress(button, scrollDirection)
				if self:CanScroll(scrollDirection) then
					button.BackgroundTransparency = 0.5
					self:ScrollToDirection(scrollDirection)
					self.Scrolled:Fire()
					local buttonTick = tick()
					local releaseEvent
					releaseEvent = user.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							releaseEvent:Disconnect()
							button.BackgroundTransparency = checkMouseInGui(button) and 0.8 or 1
							buttonPress = false
						end
					end)
					while buttonPress do
						if tick() - buttonTick >= 0.25 and self:CanScroll(scrollDirection) then
							self:ScrollToDirection(scrollDirection)
							self.Scrolled:Fire()
						end
						task.wait()
					end
				end
			end

			button1.MouseButton1Down:Connect(function(input)
				buttonPress = true
				handleButtonPress(button1, "Up")
			end)

			button1.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					button1.BackgroundTransparency = 1
				end
			end)

			button2.MouseButton1Down:Connect(function(input)
				buttonPress = true
				handleButtonPress(button2, "Down")
			end)

			button2.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					button2.BackgroundTransparency = 1
				end
			end)

			scrollThumb.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					local dir = self.Horizontal and "X" or "Y"
					local lastThumbPos = nil
					thumbPress = true
					scrollThumb.BackgroundTransparency = 0
					local mouseOffset = mouse[dir] - scrollThumb.AbsolutePosition[dir]
					local releaseEvent
					local mouseEvent

					releaseEvent = user.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							releaseEvent:Disconnect()
							if mouseEvent then mouseEvent:Disconnect() end
							scrollThumb.BackgroundTransparency = 0.2
							thumbPress = false
						end
					end)

					mouseEvent = user.InputChanged:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and thumbPress then
							local thumbFrameSize = scrollThumbFrame.AbsoluteSize[dir] - scrollThumb.AbsoluteSize[dir]
							local pos = mouse[dir] - scrollThumbFrame.AbsolutePosition[dir] - mouseOffset
							if pos > thumbFrameSize then pos = thumbFrameSize
							elseif pos < 0 then pos = 0 end
							if lastThumbPos ~= pos then
								lastThumbPos = pos
								self:ScrollTo(math.floor(0.5 + pos / thumbFrameSize * (self.TotalSpace - self.VisibleSpace)))
							end
						end
					end)
				end
			end)

			scrollThumb.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					scrollThumb.BackgroundTransparency = 0
				end
			end)

			scrollThumbFrame.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not checkMouseInGui(scrollThumb) then
					local dir = self.Horizontal and "X" or "Y"
					local scrollDir = (mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir]) and 1 or 0
					local function doTick()
						local scrollSize = self.VisibleSpace - 1
						if scrollDir == 0 and mouse[dir] < scrollThumb.AbsolutePosition[dir] then
							self:ScrollTo(self.Index - scrollSize)
						elseif scrollDir == 1 and mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
							self:ScrollTo(self.Index + scrollSize)
						end
					end

					thumbPress = false
					thumbFramePress = true
					doTick()
					local thumbFrameTick = tick()
					local releaseEvent
					releaseEvent = user.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							releaseEvent:Disconnect()
							thumbFramePress = false
						end
					end)

					while thumbFramePress do
						if tick() - thumbFrameTick >= 0.3 and checkMouseInGui(scrollThumbFrame) then
							doTick()
						end
						task.wait()
					end
				end
			end)

			newFrame.MouseWheelForward:Connect(function()
				self:ScrollTo(self.Index - self.WheelIncrement)
			end)

			newFrame.MouseWheelBackward:Connect(function()
				self:ScrollTo(self.Index + self.WheelIncrement)
			end)

			self.GuiElems.ScrollThumb = scrollThumb
			self.GuiElems.ScrollThumbFrame = scrollThumbFrame
			self.GuiElems.Button1 = button1
			self.GuiElems.Button2 = button2
			self.GuiElems.MarkerFrame = markerFrame

			return newFrame
		end

		funcs.Update = function(self,nocallback)
			local total = self.TotalSpace
			local visible = self.VisibleSpace
			local index = self.Index
			local button1 = self.GuiElems.Button1
			local button2 = self.GuiElems.Button2

			self.Index = math.clamp(self.Index, 0, math.max(0, total - visible))

			if self.LastTotalSpace ~= self.TotalSpace then
				self.LastTotalSpace = self.TotalSpace
				self:UpdateMarkers()
			end

			if self:CanScrollUp() then
				for i,v in pairs(button1.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0
				end
			else
				button1.BackgroundTransparency = 1
				for i,v in pairs(button1.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0.5
				end
			end
			if self:CanScrollDown() then
				for i,v in pairs(button2.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0
				end
			else
				button2.BackgroundTransparency = 1
				for i,v in pairs(button2.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0.5
				end
			end

			drawThumb(self)
		end

		funcs.UpdateMarkers = function(self)
			local markerFrame = self.GuiElems.MarkerFrame
			markerFrame:ClearAllChildren()

			for i,v in pairs(self.Markers) do
				if i < self.TotalSpace then
					createSimple("Frame", {
						BackgroundTransparency = 0,
						BackgroundColor3 = v,
						BorderSizePixel = 0,
						Position = self.Horizontal and UDim2.new(i/self.TotalSpace,0,1,-6) or UDim2.new(1,-6,i/self.TotalSpace,0),
						Size = self.Horizontal and UDim2.new(0,1,0,6) or UDim2.new(0,6,0,1),
						Name = "Marker"..tostring(i),
						Parent = markerFrame
					})
				end
			end
		end

		funcs.AddMarker = function(self,ind,color)
			self.Markers[ind] = color or Color3.new(0,0,0)
		end
		funcs.ScrollTo = function(self, ind, nocallback)
			self.Index = ind
			self:Update()
			if not nocallback then
				self.Scrolled:Fire()
			end
		end
		funcs.ScrollUp = function(self)
			self.Index = self.Index - self.Increment
			self:Update()
		end
		funcs.CanScroll = function(self, direction)
			if direction == "Up" then
				return self:CanScrollUp()
			elseif direction == "Down" then
				return self:CanScrollDown()
			end
			return false
		end
		funcs.ScrollDown = function(self)
			self.Index = self.Index + self.Increment
			self:Update()
		end
		funcs.CanScrollUp = function(self)
			return self.Index > 0
		end
		funcs.CanScrollDown = function(self)
			return self.Index + self.VisibleSpace < self.TotalSpace
		end
		funcs.GetScrollPercent = function(self)
			return self.Index/(self.TotalSpace-self.VisibleSpace)
		end
		funcs.SetScrollPercent = function(self,perc)
			self.Index = math.floor(perc*(self.TotalSpace-self.VisibleSpace))
			self:Update()
		end
		funcs.ScrollToDirection = function(self, Direaction)
			if Direaction == "Up" then
				self:ScrollUp()
			elseif Direaction == "Down" then
				self:ScrollDown()
			end
		end

		funcs.Texture = function(self,data)
			self.ThumbColor = data.ThumbColor or Color3.new(0,0,0)
			self.ThumbSelectColor = data.ThumbSelectColor or Color3.new(0,0,0)
			self.GuiElems.ScrollThumb.BackgroundColor3 = data.ThumbColor or Color3.new(0,0,0)
			self.Gui.BackgroundColor3 = data.FrameColor or Color3.new(0,0,0)
			self.GuiElems.Button1.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
			self.GuiElems.Button2.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
			for i,v in pairs(self.GuiElems.Button1.Arrow:GetChildren()) do
				v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
			end
			for i,v in pairs(self.GuiElems.Button2.Arrow:GetChildren()) do
				v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
			end
		end

		funcs.SetScrollFrame = function(self,frame)
			if self.ScrollUpEvent then self.ScrollUpEvent:Disconnect() self.ScrollUpEvent = nil end
			if self.ScrollDownEvent then self.ScrollDownEvent:Disconnect() self.ScrollDownEvent = nil end
			self.ScrollUpEvent = frame.MouseWheelForward:Connect(function() self:ScrollTo(self.Index - self.WheelIncrement) end)
			self.ScrollDownEvent = frame.MouseWheelBackward:Connect(function() self:ScrollTo(self.Index + self.WheelIncrement) end)
		end

		local mt = {}
		mt.__index = funcs

		local function new(hor)
			local obj = setmetatable({
				Index = 0,
				VisibleSpace = 0,
				TotalSpace = 0,
				Increment = 1,
				WheelIncrement = 1,
				Markers = {},
				GuiElems = {},
				Horizontal = hor,
				LastTotalSpace = 0,
				Scrolled = Lib.Signal.new()
			},mt)
			obj.Gui = createFrame(obj)
			obj:Texture({
				ThumbColor = Color3.fromRGB(60,60,60),
				ThumbSelectColor = Color3.fromRGB(75,75,75),
				ArrowColor = Color3.new(1,1,1),
				FrameColor = Color3.fromRGB(40,40,40),
				ButtonColor = Color3.fromRGB(75,75,75)
			})
			return obj
		end

		return {new = new}
	end)()

	Lib.Window = (function()
		local funcs = {}
		local static = {MinWidth = 200, FreeWidth = 200}
		local mouse = plr:GetMouse()
		local sidesGui,alignIndicator
		local visibleWindows = {}
		local leftSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}
		local rightSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}

		local displayOrderStart
		local sideDisplayOrder
		local sideTweenInfo = TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		local tweens = {}
		local isA = game.IsA

		local theme = {
			MainColor1 = Color3.fromRGB(52,52,52),
			MainColor2 = Color3.fromRGB(45,45,45),
			Button = Color3.fromRGB(60,60,60)
		}

		local function stopTweens()
			for i = 1,#tweens do
				tweens[i]:Cancel()
			end
			tweens = {}
		end

		local function resizeHook(self,resizer,dir)
			local pressing = false
			
			local guiMain = self.GuiElems.Main
			
			resizer.MouseEnter:Connect(function() resizer.BackgroundTransparency = 0.5 end)
			resizer.MouseButton1Down:Connect(function() pressing = true resizer.BackgroundTransparency = 0.5 end)
			resizer.MouseButton1Up:Connect(function() pressing = false resizer.BackgroundTransparency = 1 end)
			
			
			
			resizer.InputBegan:Connect(function(input)
				if not self.Dragging and not self.Resizing and self.Resizable and self.ResizableInternal and pressing then
					local isH = dir:find("[WE]") and true
					local isV = dir:find("[NS]") and true
					local signX = dir:find("W",1,true) and -1 or 1
					local signY = dir:find("N",1,true) and -1 or 1

					if self.Minimized and isV then return end
					
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						
						local releaseEvent, mouseEvent

						local offX = input.Position.X - resizer.AbsolutePosition.X
						local offY = input.Position.Y - resizer.AbsolutePosition.Y

						self.Resizing = resizer
						
						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								if mouseEvent then mouseEvent:Disconnect() end
								self.Resizing = false
								resizer.BackgroundTransparency = 1
							end
						end)

						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if self.Resizable and self.ResizableInternal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
								self:StopTweens()
								local deltaX = input.Position.X - resizer.AbsolutePosition.X - offX
								local deltaY = input.Position.Y - resizer.AbsolutePosition.Y - offY

								if guiMain.AbsoluteSize.X + deltaX * signX < self.MinX then deltaX = signX * (self.MinX - guiMain.AbsoluteSize.X) end
								if guiMain.AbsoluteSize.Y + deltaY * signY < self.MinY then deltaY = signY * (self.MinY - guiMain.AbsoluteSize.Y) end
								if signY < 0 and guiMain.AbsolutePosition.Y + deltaY < 0 then deltaY = -guiMain.AbsolutePosition.Y end

								guiMain.Position = guiMain.Position + UDim2.new(0, (signX < 0 and deltaX or 0), 0, (signY < 0 and deltaY or 0))
								self.SizeX = self.SizeX + (isH and deltaX * signX or 0)
								self.SizeY = self.SizeY + (isV and deltaY * signY or 0)
								guiMain.Size = UDim2.new(0, self.SizeX, 0, self.Minimized and 20 or self.SizeY)
							end
						end)
					end
				end
			end)

			resizer.InputEnded:Connect(function(input)
				--if input.UserInputType == Enum.UserInputType.Touch and Main.AllowDraggableOnMobile == false then return end
				if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.Resizing ~= resizer then
					resizer.BackgroundTransparency = 1
				end
			end)
		end

		local updateWindows

		local function moveToTop(window)
			local found = table.find(visibleWindows,window)
			if found then
				table.remove(visibleWindows,found)
				table.insert(visibleWindows,1,window)
				updateWindows()
			end
		end

		local function sideHasRoom(side,neededSize)
			local maxY = sidesGui.AbsoluteSize.Y - (math.max(0,#side.Windows - 1) * 4)
			local inc = 0
			for i,v in pairs(side.Windows) do
				inc = inc + (v.MinY or 100)
				if inc > maxY - neededSize then return false end
			end

			return true
		end

		local function getSideInsertPos(side,curY)
			local pos = #side.Windows + 1
			local range = {0,sidesGui.AbsoluteSize.Y}

			for i,v in pairs(side.Windows) do
				local midPos = v.PosY + v.SizeY/2
				if curY <= midPos then
					pos = i
					range[2] = midPos
					break
				else
					range[1] = midPos
				end
			end

			return pos,range
		end

		local function focusInput(self,obj)
			if isA(obj,"GuiButton") then
				obj.MouseButton1Down:Connect(function()
					moveToTop(self)
				end)
			elseif isA(obj,"TextBox") then
				obj.Focused:Connect(function()
					moveToTop(self)
				end)
			end
		end

		local createGui = function(self)
			local gui = create({
				{1,"ScreenGui",{Name="Window",}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,300,0,300),}},
				--[[background mod set to 0.05]]	{3,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,Name="Content",Parent={2},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ClipsDescendants=true}},
				{4,"Frame",{BackgroundColor3=Color3.fromRGB(33,33,33),BorderSizePixel=0,Name="Line",Parent={3},Size=UDim2.new(1,0,0,1),}},
				{5,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="TopBar",Parent={2},Size=UDim2.new(1,0,0,20),Text = ""}},
				{6,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={5},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,20),Text="Window",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Close",Parent={5},Position=UDim2.new(1,-18,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5054663650",Parent={7},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
				{9,"UICorner",{CornerRadius=UDim.new(0,4),Parent={7},}},
				--[[lol mod]]	{9,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
				{10,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Minimize",Parent={5},Position=UDim2.new(1,-36,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{11,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034768003",Parent={10},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
				{12,"UICorner",{CornerRadius=UDim.new(0,4),Parent={10},}},
				{13,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1427967925",Name="Outlines",Parent={2},Position=UDim2.new(0,-5,0,-5),ScaleType=1,Size=UDim2.new(1,10,1,10),SliceCenter=Rect.new(6,6,25,25),TileSize=UDim2.new(0,20,0,20),}},
				{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="ResizeControls",Parent={2},Position=UDim2.new(0,-5,0,-5),Size=UDim2.new(1,10,1,10),}},
				{15,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="North",Parent={14},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{16,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="South",Parent={14},Position=UDim2.new(0,5,1,-5),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{17,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthEast",Parent={14},Position=UDim2.new(1,-5,0,0),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{18,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="East",Parent={14},Position=UDim2.new(1,-5,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{19,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="West",Parent={14},Position=UDim2.new(0,0,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{20,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthEast",Parent={14},Position=UDim2.new(1,-5,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{21,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthWest",Parent={14},Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{22,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthWest",Parent={14},Position=UDim2.new(0,0,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
			})

			local guiMain = gui.Main
			local guiTopBar = guiMain.TopBar
			local guiResizeControls = guiMain.ResizeControls

			self.GuiElems.Main = guiMain
			self.GuiElems.TopBar = guiMain.TopBar
			self.GuiElems.Content = guiMain.Content
			self.GuiElems.Line = guiMain.Content.Line
			self.GuiElems.Outlines = guiMain.Outlines
			self.GuiElems.Title = guiTopBar.Title
			self.GuiElems.Close = guiTopBar.Close
			self.GuiElems.Minimize = guiTopBar.Minimize
			self.GuiElems.ResizeControls = guiResizeControls
			self.ContentPane = guiMain.Content
			
			-- dont mind this, im testing what if the frame background is blurry 
			--blur.new(guiMain.Content, "Rectangle")

			--blur.updateAll()
			
			local ButtonDown = false
			guiTopBar.MouseButton1Down:Connect(function() ButtonDown = true end)
			guiTopBar.MouseButton1Up:Connect(function() ButtonDown = false end)

			if Settings.Window.TitleOnMiddle then
				self.GuiElems.Title.TextXAlignment = 2
				self.GuiElems.Title.Size = UDim2.new(1,-20,0,20)
			end

			if Settings.Window.Transparency then
				self.GuiElems.Content.BackgroundTransparency = Settings.Window.Transparency
				--self.GuiElems
			end


			guiTopBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if self.Draggable then
						local releaseEvent, mouseEvent

						local maxX = sidesGui.AbsoluteSize.X
						local initX = guiMain.AbsolutePosition.X
						local initY = guiMain.AbsolutePosition.Y
						local offX = input.Position.X - initX
						local offY = input.Position.Y - initY

						local alignInsertPos, alignInsertSide

						guiDragging = true

						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								if mouseEvent then mouseEvent:Disconnect() end
								guiDragging = false
								alignIndicator.Parent = nil
								if alignInsertSide then
									local targetSide = (alignInsertSide == "left" and leftSide) or (alignInsertSide == "right" and rightSide)
									self:AlignTo(targetSide, alignInsertPos)
								end
							end
						end)

						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.Draggable and not self.Closed and ButtonDown then
								if self.Aligned then
									if leftSide.Resizing or rightSide.Resizing then return end
									local posX, posY = input.Position.X - offX, input.Position.Y - offY
									local delta = math.sqrt((posX - initX)^2 + (posY - initY)^2)
									if delta >= 5 then
										self:SetAligned(false)
									end
								else
									local inputX, inputY = input.Position.X, input.Position.Y
									local posX, posY = inputX - offX, inputY - offY
									if posY < 0 then posY = 0 end
									guiMain.Position = UDim2.new(0, posX, 0, posY)

									if self.Resizable and self.Alignable then
										if inputX < 25 then
											if sideHasRoom(leftSide, self.MinY or 100) then
												local insertPos, range = getSideInsertPos(leftSide, inputY)
												alignIndicator.Indicator.Position = UDim2.new(0, -15, 0, range[1])
												alignIndicator.Indicator.Size = UDim2.new(0, 40, 0, range[2] - range[1])
												Lib.ShowGui(alignIndicator)
												alignInsertPos = insertPos
												alignInsertSide = "left"
												return
											end
										elseif inputX >= maxX - 25 then
											if sideHasRoom(rightSide, self.MinY or 100) then
												local insertPos, range = getSideInsertPos(rightSide, inputY)
												alignIndicator.Indicator.Position = UDim2.new(0, maxX - 25, 0, range[1])
												alignIndicator.Indicator.Size = UDim2.new(0, 40, 0, range[2] - range[1])
												Lib.ShowGui(alignIndicator)
												alignInsertPos = insertPos
												alignInsertSide = "right"
												return
											end
										end
									end
									alignIndicator.Parent = nil
									alignInsertPos = nil
									alignInsertSide = nil
								end
							end
						end)
					end
				end
			end)

			guiTopBar.Close.MouseButton1Click:Connect(function()
				if self.Closed then return end
				self:Close()
			end)

			guiTopBar.Minimize.MouseButton1Click:Connect(function()
				if self.Closed then return end
				if self.Aligned then
					self:SetAligned(false)
				else
					self:SetMinimized()
				end
			end)

			guiTopBar.Minimize.MouseButton2Click:Connect(function()
				if self.Closed then return end
				if not self.Aligned then
					self:SetMinimized(nil,2)
					guiTopBar.Minimize.BackgroundTransparency = 1
				end
			end)

			guiMain.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and not self.Aligned and not self.Closed then
					moveToTop(self)
				end
			end)

			guiMain:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				local absPos = guiMain.AbsolutePosition
				self.PosX = absPos.X
				self.PosY = absPos.Y
			end)

			resizeHook(self,guiResizeControls.North,"N")
			resizeHook(self,guiResizeControls.NorthEast,"NE")
			resizeHook(self,guiResizeControls.East,"E")
			resizeHook(self,guiResizeControls.SouthEast,"SE")
			resizeHook(self,guiResizeControls.South,"S")
			resizeHook(self,guiResizeControls.SouthWest,"SW")
			resizeHook(self,guiResizeControls.West,"W")
			resizeHook(self,guiResizeControls.NorthWest,"NW")

			guiMain.Size = UDim2.new(0,self.SizeX,0,self.SizeY)

			gui.DescendantAdded:Connect(function(obj) focusInput(self,obj) end)
			local descs = gui:GetDescendants()
			for i = 1,#descs do
				focusInput(self,descs[i])
			end

			self.MinimizeAnim = Lib.ButtonAnim(guiTopBar.Minimize)
			self.CloseAnim = Lib.ButtonAnim(guiTopBar.Close)

			return gui
		end

		local function updateSideFrames(noTween)
			stopTweens()
			leftSide.Frame.Size = UDim2.new(0,leftSide.Width,1,0)
			rightSide.Frame.Size = UDim2.new(0,rightSide.Width,1,0)
			leftSide.Frame.Resizer.Position = UDim2.new(0,leftSide.Width,0,0)
			rightSide.Frame.Resizer.Position = UDim2.new(0,-5,0,0)

			--leftSide.Frame.Visible = (#leftSide.Windows > 0)
			--rightSide.Frame.Visible = (#rightSide.Windows > 0)

			--[[if #leftSide.Windows > 0 and leftSide.Frame.Position == UDim2.new(0,-leftSide.Width-5,0,0) then
				leftSide.Frame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			elseif #leftSide.Windows == 0 and leftSide.Frame.Position == UDim2.new(0,0,0,0) then
				leftSide.Frame:TweenPosition(UDim2.new(0,-leftSide.Width-5,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end
			local rightTweenPos = (#rightSide.Windows == 0 and UDim2.new(1,5,0,0) or UDim2.new(1,-rightSide.Width,0,0))
			rightSide.Frame:TweenPosition(rightTweenPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)]]
			local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
			local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
			local leftPos = (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
			local rightPos = (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))

			sidesGui.LeftToggle.Text = leftHidden and ">" or "<"
			sidesGui.RightToggle.Text = rightHidden and "<" or ">"

			if not noTween then
				local function insertTween(...)
					local tween = service.TweenService:Create(...)
					tweens[#tweens+1] = tween
					tween:Play()
				end
				insertTween(leftSide.Frame,sideTweenInfo,{Position = leftPos})
				insertTween(rightSide.Frame,sideTweenInfo,{Position = rightPos})
				insertTween(sidesGui.LeftToggle,sideTweenInfo,{Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)})
				insertTween(sidesGui.RightToggle,sideTweenInfo,{Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)})
			else
				leftSide.Frame.Position = leftPos
				rightSide.Frame.Position = rightPos
				sidesGui.LeftToggle.Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)
				sidesGui.RightToggle.Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)
			end
		end

		local function getSideFramePos(side)
			local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
			local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
			if side == leftSide then
				return (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
			else
				return (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))
			end
		end

		local function sideResized(side)
			local currentPos = 0
			local sideFramePos = getSideFramePos(side)
			for i,v in pairs(side.Windows) do
				v.SizeX = side.Width
				v.GuiElems.Main.Size = UDim2.new(0,side.Width,0,v.SizeY)
				v.GuiElems.Main.Position = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
				currentPos = currentPos + v.SizeY+4
			end
		end

		local function sideResizerHook(resizer,dir,side,pos)
			local pressing = false
			
			local mouse = Main.Mouse
			local windows = side.Windows

			resizer.MouseEnter:Connect(function() resizer.BackgroundColor3 = theme.MainColor2 end)
			resizer.MouseButton1Down:Connect(function() pressing = true resizer.BackgroundColor3 = theme.MainColor2 end)
			resizer.MouseButton1Up:Connect(function() pressing = false resizer.BackgroundColor3 = theme.Button end)


			resizer.InputBegan:Connect(function(input)
				if not side.Resizing and pressing then
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						resizer.BackgroundColor3 = theme.MainColor2
					end 
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local releaseEvent,mouseEvent

						local offX = mouse.X - resizer.AbsolutePosition.X
						local offY = mouse.Y - resizer.AbsolutePosition.Y

						side.Resizing = resizer
						resizer.BackgroundColor3 = theme.MainColor2

						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
								side.Resizing = false
								resizer.BackgroundColor3 = theme.Button
							end
						end)

						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if not resizer.Parent then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
								side.Resizing = false
								return
							end
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								if dir == "V" then
									local delta = input.Position.Y - resizer.AbsolutePosition.Y - offY

									if delta > 0 then
										local neededSize = delta
										for i = pos+1,#windows do
											local window = windows[i]
											local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
											neededSize = neededSize - (window.SizeY - newSize)
											window.SizeY = newSize
										end
										windows[pos].SizeY = windows[pos].SizeY + math.max(0,delta-neededSize)
									else
										local neededSize = -delta
										for i = pos,1,-1 do
											local window = windows[i]
											local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
											neededSize = neededSize - (window.SizeY - newSize)
											window.SizeY = newSize
										end
										windows[pos+1].SizeY = windows[pos+1].SizeY + math.max(0,-delta-neededSize)
									end

									updateSideFrames()
									sideResized(side)
								elseif dir == "H" then
									local maxWidth = math.max(300,sidesGui.AbsoluteSize.X-static.FreeWidth)
									local otherSide = (side == leftSide and rightSide or leftSide)
									local delta = input.Position.X - resizer.AbsolutePosition.X - offX
									delta = (side == leftSide and delta or -delta)

									local proposedSize = math.max(static.MinWidth,side.Width + delta)
									if proposedSize + otherSide.Width <= maxWidth then
										side.Width = proposedSize
									else
										local newOtherSize = maxWidth - proposedSize
										if newOtherSize >= static.MinWidth then
											side.Width = proposedSize
											otherSide.Width = newOtherSize
										else
											side.Width = maxWidth - static.MinWidth
											otherSide.Width = static.MinWidth
										end
									end

									updateSideFrames(true)
									sideResized(side)
									sideResized(otherSide)
								end
							end
						end)
					end
				end
			end)

			resizer.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch and side.Resizing ~= resizer then
					resizer.BackgroundColor3 = theme.Button
				end
			end)
		end

		local function renderSide(side,noTween) -- TODO: Use existing resizers
			local currentPos = 0
			local sideFramePos = getSideFramePos(side)
			local template = side.WindowResizer:Clone()
			for i,v in pairs(side.ResizeCons) do v:Disconnect() end
			for i,v in pairs(side.Frame:GetChildren()) do if v.Name == "WindowResizer" then v:Destroy() end end
			side.ResizeCons = {}
			side.Resizing = nil

			for i,v in pairs(side.Windows) do
				v.SidePos = i
				local isEnd = i == #side.Windows
				local size = UDim2.new(0,side.Width,0,v.SizeY)
				local pos = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
				Lib.ShowGui(v.Gui)
				--v.GuiElems.Main:TweenSizeAndPosition(size,pos,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
				if noTween then
					v.GuiElems.Main.Size = size
					v.GuiElems.Main.Position = pos
				else
					local tween = service.TweenService:Create(v.GuiElems.Main,sideTweenInfo,{Size = size, Position = pos})
					tweens[#tweens+1] = tween
					tween:Play()
				end
				currentPos = currentPos + v.SizeY+4

				if not isEnd then
					local newTemplate = template:Clone()
					newTemplate.Position = UDim2.new(1,-side.Width,0,currentPos-4)
					side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Size"):Connect(function()
						newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
					end)
					side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Position"):Connect(function()
						newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
					end)
					sideResizerHook(newTemplate,"V",side,i)
					newTemplate.Parent = side.Frame
				end
			end

			--side.Frame.Back.Position = UDim2.new(0,0,0,0)
			--side.Frame.Back.Size = UDim2.new(0,side.Width,1,0)
		end

		local function updateSide(side,noTween)
			local oldHeight = 0
			local currentPos = 0
			local neededSize = 0
			local windows = side.Windows
			local height = sidesGui.AbsoluteSize.Y - (math.max(0,#windows - 1) * 4)

			for i,v in pairs(windows) do oldHeight = oldHeight + v.SizeY end
			for i,v in pairs(windows) do
				if i == #windows then
					v.SizeY = height-currentPos
					neededSize = math.max(0,(v.MinY or 100)-v.SizeY)
				else
					v.SizeY = math.max(math.floor(v.SizeY/oldHeight*height),v.MinY or 100)
				end
				currentPos = currentPos + v.SizeY
			end

			if neededSize > 0 then
				for i = #windows-1,1,-1 do
					local window = windows[i]
					local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
					neededSize = neededSize - (window.SizeY - newSize)
					window.SizeY = newSize
				end
				local lastWindow = windows[#windows]
				lastWindow.SizeY = (lastWindow.MinY or 100)-neededSize
			end
			renderSide(side,noTween)
		end

		updateWindows = function(noTween)
			updateSideFrames(noTween)
			updateSide(leftSide,noTween)
			updateSide(rightSide,noTween)
			local count = 0
			for i = #visibleWindows,1,-1 do
				visibleWindows[i].Gui.DisplayOrder = displayOrderStart + count
				Lib.ShowGui(visibleWindows[i].Gui)
				count = count + 1
			end

			--[[local leftTweenPos = (#leftSide.Windows == 0 and UDim2.new(0,-leftSide.Width-5,0,0) or UDim2.new(0,0,0,0))
			leftSide.Frame:TweenPosition(leftTweenPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			local rightTweenPos = (#rightSide.Windows == 0 and UDim2.new(1,5,0,0) or UDim2.new(1,-rightSide.Width,0,0))
			rightSide.Frame:TweenPosition(rightTweenPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)]]
		end

		funcs.SetMinimized = function(self,set,mode)
			local oldVal = self.Minimized
			local newVal
			if set == nil then newVal = not self.Minimized else newVal = set end
			self.Minimized = newVal
			if not mode then mode = 1 end

			local resizeControls = self.GuiElems.ResizeControls
			local minimizeControls = {"North","NorthEast","NorthWest","South","SouthEast","SouthWest"}
			for i = 1,#minimizeControls do
				local control = resizeControls:FindFirstChild(minimizeControls[i])
				if control then control.Visible = not newVal end
			end

			if mode == 1 or mode == 2 then
				self:StopTweens()
				if mode == 1 then
					self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				else
					local maxY = sidesGui.AbsoluteSize.Y
					local newPos = UDim2.new(0,self.PosX,0,newVal and math.min(maxY-20,self.PosY + self.SizeY - 20) or math.max(0,self.PosY - self.SizeY + 20))

					self.GuiElems.Main:TweenPosition(newPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
					self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				end
				self.GuiElems.Minimize.ImageLabel.Image = newVal and "rbxassetid://5060023708" or "rbxassetid://5034768003"
			end

			if oldVal ~= newVal then
				if newVal then
					self.OnMinimize:Fire()
				else
					self.OnRestore:Fire()
				end
			end
		end

		funcs.Resize = function(self,sizeX,sizeY)
			self.SizeX = sizeX or self.SizeX
			self.SizeY = sizeY or self.SizeY
			self.GuiElems.Main.Size = UDim2.new(0,self.SizeX,0,self.SizeY)
		end

		funcs.SetSize = funcs.Resize

		funcs.SetTitle = function(self,title)
			self.GuiElems.Title.Text = title
		end

		funcs.SetResizable = function(self,val)
			self.Resizable = val
			self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
		end

		funcs.SetResizableInternal = function(self,val)
			self.ResizableInternal = val
			self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
		end

		funcs.SetAligned = function(self,val)
			self.Aligned = val
			self:SetResizableInternal(not val)
			self.GuiElems.Main.Active = not val
			self.GuiElems.Main.Outlines.Visible = not val
			if not val then
				for i,v in pairs(leftSide.Windows) do if v == self then table.remove(leftSide.Windows,i) break end end
				for i,v in pairs(rightSide.Windows) do if v == self then table.remove(rightSide.Windows,i) break end end
				if not table.find(visibleWindows,self) then table.insert(visibleWindows,1,self) end
				self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
				self.Side = nil
				updateWindows()
			else
				self:SetMinimized(false,3)
				for i,v in pairs(visibleWindows) do if v == self then table.remove(visibleWindows,i) break end end
				self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5448127505"
			end
		end

		funcs.Add = function(self,obj,name)
			if type(obj) == "table" and obj.Gui and obj.Gui:IsA("GuiObject") then
				obj.Gui.Parent = self.ContentPane
			else
				obj.Parent = self.ContentPane
			end
			if name then self.Elements[name] = obj end
		end

		funcs.GetElement = function(self,obj,name)
			return self.Elements[name]
		end

		funcs.AlignTo = function(self,side,pos,size,silent)
			if table.find(side.Windows,self) or self.Closed then return end

			size = size or self.SizeY
			if size > 0 and size <= 1 then
				local totalSideHeight = 0
				for i,v in pairs(side.Windows) do totalSideHeight = totalSideHeight + v.SizeY end
				self.SizeY = (totalSideHeight > 0 and totalSideHeight * size * 2) or size
			else
				self.SizeY = (size > 0 and size or 100)
			end

			self:SetAligned(true)
			self.Side = side
			self.SizeX = side.Width
			self.Gui.DisplayOrder = sideDisplayOrder + 1
			for i,v in pairs(side.Windows) do v.Gui.DisplayOrder = sideDisplayOrder end
			pos = math.min(#side.Windows+1, pos or 1)
			self.SidePos = pos
			table.insert(side.Windows, pos, self)

			if not silent then
				side.Hidden = false
			end
			updateWindows(silent)
		end

		funcs.Close = function(self)
			self.Closed = true
			self:SetResizableInternal(false)

			Lib.FindAndRemove(leftSide.Windows,self)
			Lib.FindAndRemove(rightSide.Windows,self)
			Lib.FindAndRemove(visibleWindows,self)

			self.MinimizeAnim.Disable()
			self.CloseAnim.Disable()
			self.ClosedSide = self.Side
			self.Side = nil
			self.OnDeactivate:Fire()

			if not self.Aligned then
				self:StopTweens()
				local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

				local closeTime = tick()
				self.LastClose = closeTime

				self:DoTween(self.GuiElems.Main,ti,{Size = UDim2.new(0,self.SizeX,0,20)})
				self:DoTween(self.GuiElems.Title,ti,{TextTransparency = 1})
				self:DoTween(self.GuiElems.Minimize.ImageLabel,ti,{ImageTransparency = 1})
				self:DoTween(self.GuiElems.Close.ImageLabel,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end

				self:DoTween(self.GuiElems.TopBar,ti,{BackgroundTransparency = 1})
				self:DoTween(self.GuiElems.Outlines,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end
			end

			self.Aligned = false
			self.Gui.Parent = nil
			updateWindows(true)
		end
		
		funcs.Destroy = function(self)
			self.Closed = true
			self:SetResizableInternal(false)

			Lib.FindAndRemove(leftSide.Windows,self)
			Lib.FindAndRemove(rightSide.Windows,self)
			Lib.FindAndRemove(visibleWindows,self)

			self.MinimizeAnim.Disable()
			self.CloseAnim.Disable()
			self.ClosedSide = self.Side
			self.Side = nil
			self.OnDeactivate:Fire()

			if not self.Aligned then
				self:StopTweens()
				local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

				local closeTime = tick()
				self.LastClose = closeTime

				self:DoTween(self.GuiElems.Main,ti,{Size = UDim2.new(0,self.SizeX,0,20)})
				self:DoTween(self.GuiElems.Title,ti,{TextTransparency = 1})
				self:DoTween(self.GuiElems.Minimize.ImageLabel,ti,{ImageTransparency = 1})
				self:DoTween(self.GuiElems.Close.ImageLabel,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end

				self:DoTween(self.GuiElems.TopBar,ti,{BackgroundTransparency = 1})
				self:DoTween(self.GuiElems.Outlines,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end
			end

			self.Aligned = false
			--self.Gui.Parent = nil
			updateWindows(true)
			self.Gui:Destroy()
		end

		funcs.Hide = funcs.Close

		funcs.IsVisible = function(self)
			return not self.Closed and ((self.Side and not self.Side.Hidden) or not self.Side)
		end

		funcs.IsContentVisible = function(self)
			return self:IsVisible() and not self.Minimized
		end

		funcs.Focus = function(self)
			moveToTop(self)
		end

		funcs.MoveInBoundary = function(self)
			local posX,posY = self.PosX,self.PosY
			local maxX,maxY = sidesGui.AbsoluteSize.X,sidesGui.AbsoluteSize.Y
			posX = math.min(posX,maxX-self.SizeX)
			posY = math.min(posY,maxY-20)
			self.GuiElems.Main.Position = UDim2.new(0,posX,0,posY)
		end

		funcs.DoTween = function(self,...)
			local tween = service.TweenService:Create(...)
			self.Tweens[#self.Tweens+1] = tween
			tween:Play()
		end

		funcs.StopTweens = function(self)
			for i,v in pairs(self.Tweens) do
				v:Cancel()
			end
			self.Tweens = {}
		end

		funcs.Show = function(self,data)
			return static.ShowWindow(self,data)
		end

		funcs.ShowAndFocus = function(self,data)
			static.ShowWindow(self,data)
			service.RunService.RenderStepped:wait()
			self:Focus()
		end

		static.ShowWindow = function(window,data)
			data = data or {}
			local align = data.Align
			local pos = data.Pos
			local size = data.Size
			local targetSide = (align == "left" and leftSide) or (align == "right" and rightSide)

			if not window.Closed then
				if not window.Aligned then
					window:SetMinimized(false)
				elseif window.Side and not data.Silent then
					static.SetSideVisible(window.Side,true)
				end
				return
			end

			window.Closed = false
			window.LastClose = tick()
			window.GuiElems.Title.TextTransparency = 0
			window.GuiElems.Minimize.ImageLabel.ImageTransparency = 0
			window.GuiElems.Close.ImageLabel.ImageTransparency = 0
			window.GuiElems.TopBar.BackgroundTransparency = 0
			window.GuiElems.Outlines.ImageTransparency = 0
			window.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
			window.GuiElems.Main.Active = true
			window.GuiElems.Main.Outlines.Visible = true
			window:SetMinimized(false,3)
			window:SetResizableInternal(true)
			window.MinimizeAnim.Enable()
			window.CloseAnim.Enable()

			if align then
				window:AlignTo(targetSide,pos,size,data.Silent)
			else
				if align == nil and window.ClosedSide then -- Regular open
					window:AlignTo(window.ClosedSide,window.SidePos,size,true)
					static.SetSideVisible(window.ClosedSide,true)
				else
					if table.find(visibleWindows,window) then return end

					-- TODO: make better
					window.GuiElems.Main.Size = UDim2.new(0,window.SizeX,0,20)
					local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
					window:StopTweens()
					window:DoTween(window.GuiElems.Main,ti,{Size = UDim2.new(0,window.SizeX,0,window.SizeY)})

					window.SizeY = size or window.SizeY
					table.insert(visibleWindows,1,window)
					updateWindows()
				end
			end

			window.ClosedSide = nil
			window.OnActivate:Fire()
		end

		static.ToggleSide = function(name)
			local side = (name == "left" and leftSide or rightSide)
			side.Hidden = not side.Hidden
			for i,v in pairs(side.Windows) do
				if side.Hidden then
					v.OnDeactivate:Fire()
				else
					v.OnActivate:Fire()
				end
			end
			updateWindows()
		end

		static.SetSideVisible = function(s,vis)
			local side = (type(s) == "table" and s) or (s == "left" and leftSide or rightSide)
			side.Hidden = not vis
			for i,v in pairs(side.Windows) do
				if side.Hidden then
					v.OnDeactivate:Fire()
				else
					v.OnActivate:Fire()
				end
			end
			updateWindows()
		end

		static.Init = function()
			displayOrderStart = Main.DisplayOrders.Window
			sideDisplayOrder = Main.DisplayOrders.SideWindow

			sidesGui = Instance.new("ScreenGui")
			local leftFrame = create({
				{1,"Frame",{Active=true,Name="LeftSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
				{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,1,1,0),}},
				{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
			})
			leftSide.Frame = leftFrame
			leftFrame.Position = UDim2.new(0,-leftSide.Width-10,0,0)
			leftSide.WindowResizer = leftFrame.WindowResizer
			leftFrame.WindowResizer.Parent = nil
			leftFrame.Parent = sidesGui

			local rightFrame = create({
				{1,"Frame",{Active=true,Name="RightSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
				{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,4,0,0),Size=UDim2.new(0,1,1,0),}},
				{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
			})
			rightSide.Frame = rightFrame
			rightFrame.Position = UDim2.new(1,10,0,0)
			rightSide.WindowResizer = rightFrame.WindowResizer
			rightFrame.WindowResizer.Parent = nil
			rightFrame.Parent = sidesGui

			if Settings.Window.Transparency and Settings.Window.Transparency > 0 then
				leftSide.BackgroundTransparency = 1
				rightSide.BackgroundTransparency = 1

				leftFrame.BackgroundTransparency = 1
				rightFrame.BackgroundTransparency = 1
			end

			sideResizerHook(leftFrame.Resizer,"H",leftSide)
			sideResizerHook(rightFrame.Resizer,"H",rightSide)

			alignIndicator = Instance.new("ScreenGui")
			alignIndicator.DisplayOrder = Main.DisplayOrders.Core
			local indicator = Instance.new("Frame",alignIndicator)
			indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			indicator.BorderSizePixel = 0
			indicator.BackgroundTransparency = 0.8
			indicator.Name = "Indicator"
			local corner = Instance.new("UICorner",indicator)
			corner.CornerRadius = UDim.new(0,10)

			local leftToggle = create({{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderMode=2,Font=10,Name="LeftToggle",Position=UDim2.new(0,0,0,-36),Size=UDim2.new(0,16,0,36),Text="<",TextColor3=Color3.new(1,1,1),TextSize=14,}}})
			local rightToggle = leftToggle:Clone()
			rightToggle.Name = "RightToggle"
			rightToggle.Position = UDim2.new(1,-16,0,-36)
			Lib.ButtonAnim(leftToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})
			Lib.ButtonAnim(rightToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})

			leftToggle.MouseButton1Click:Connect(function()
				static.ToggleSide("left")
			end)

			rightToggle.MouseButton1Click:Connect(function()
				static.ToggleSide("right")
			end)

			leftToggle.Parent = sidesGui
			rightToggle.Parent = sidesGui

			sidesGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local maxWidth = math.max(300,sidesGui.AbsoluteSize.X-static.FreeWidth)
				leftSide.Width = math.max(static.MinWidth,math.min(leftSide.Width,maxWidth-rightSide.Width))
				rightSide.Width = math.max(static.MinWidth,math.min(rightSide.Width,maxWidth-leftSide.Width))
				for i = 1,#visibleWindows do
					visibleWindows[i]:MoveInBoundary()
				end
				updateWindows(true)
			end)

			sidesGui.DisplayOrder = sideDisplayOrder - 1
			Lib.ShowGui(sidesGui)
			updateSideFrames()
		end

		local mt = {__index = funcs}
		static.new = function()
			local obj = setmetatable({
				Minimized = false,
				Dragging = false,
				Resizing = false,
				Aligned = false,
				Draggable = true,
				Resizable = true,
				ResizableInternal = true,
				Alignable = true,
				Closed = true,
				SizeX = 300,
				SizeY = 300,
				MinX = 200,
				MinY = 200,
				PosX = 0,
				PosY = 0,
				GuiElems = {},
				Tweens = {},
				Elements = {},
				OnActivate = Lib.Signal.new(),
				OnDeactivate = Lib.Signal.new(),
				OnMinimize = Lib.Signal.new(),
				OnRestore = Lib.Signal.new()
			},mt)
			obj.Gui = createGui(obj)
			return obj
		end

		return static
	end)()

	Lib.ContextMenu = (function()
		local funcs = {}
		local mouse

		local function createGui(self)
			local contextGui = create({
				{1,"ScreenGui",{DisplayOrder=1000000,Name="Context",ZIndexBehavior=1,}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),Name="Main",Parent={1},Position=UDim2.new(0.5,-100,0.5,-150),Size=UDim2.new(0,200,0,100),}},
				{3,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),Name="Container",Parent={2},Position=UDim2.new(0,1,0,1),Size=UDim2.new(1,-2,1,-2),}},
				{5,"UICorner",{CornerRadius=UDim.new(0,4),Parent={4},}},
				{6,"ScrollingFrame",{Active=true,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),Name="List",Parent={4},Position=UDim2.new(0,2,0,2),ScrollBarImageColor3=Color3.new(0,0,0),ScrollBarThickness=4,Size=UDim2.new(1,-4,1,-4),VerticalScrollBarInset=1,}},
				{7,"UIListLayout",{Parent={6},SortOrder=2,}},
				{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="SearchFrame",Parent={4},Size=UDim2.new(1,0,0,24),Visible=false,}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchContainer",Parent={8},Position=UDim2.new(0,3,0,3),Size=UDim2.new(1,-6,0,18),}},
				{10,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="SearchBox",Parent={9},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-8,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
				{11,"UICorner",{CornerRadius=UDim.new(0,2),Parent={9},}},
				{12,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),}},
				{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Font=3,Name="Entry",Parent={1},Size=UDim2.new(1,0,0,22),Text="",TextSize=14,Visible=false,}},
				{14,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="EntryName",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-24,1,0),Text="Duplicate",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Shortcut",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-30,1,0),Text="Ctrl+D",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{16,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ImageRectOffset=Vector2.new(304,0),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={13},Position=UDim2.new(0,2,0,3),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
				{17,"UICorner",{CornerRadius=UDim.new(0,4),Parent={13},}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.21568629145622,0.21568629145622,0.21568629145622),BackgroundTransparency=1,BorderSizePixel=0,Name="Divider",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,7),Visible=false,}},
				{19,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="Line",Parent={18},Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),}},
				{20,"TextLabel",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="DividerName",Parent={18},Position=UDim2.new(0,2,0.5,0),Size=UDim2.new(1,-4,1,0),Text="Objects",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.60000002384186,TextXAlignment=0,Visible=false,}}
			})

			self.GuiElems.Main = contextGui.Main
			self.GuiElems.List = contextGui.Main.Container.List
			self.GuiElems.Entry = contextGui.Entry
			self.GuiElems.Divider = contextGui.Divider
			self.GuiElems.SearchFrame = contextGui.Main.Container.SearchFrame
			self.GuiElems.SearchBar = self.GuiElems.SearchFrame.SearchContainer.SearchBox
			Lib.ViewportTextBox.convert(self.GuiElems.SearchBar)

			self.GuiElems.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
				local lower,find = string.lower,string.find
				local searchText = lower(self.GuiElems.SearchBar.Text)
				local items = self.Items
				local map = self.ItemToEntryMap

				if searchText ~= "" then
					local results = {}
					local count = 1
					for i = 1,#items do
						local item = items[i]
						local entry = map[item]
						if entry then
							if not item.Divider and find(lower(item.Name),searchText,1,true) then
								results[count] = item
								count = count + 1
							else
								entry.Visible = false
							end
						end
					end
					table.sort(results,function(a,b) return a.Name < b.Name end)
					for i = 1,#results do
						local entry = map[results[i]]
						entry.LayoutOrder = i
						entry.Visible = true
					end
				else
					for i = 1,#items do
						local entry = map[items[i]]
						if entry then entry.LayoutOrder = i entry.Visible = true end
					end
				end

				local toSize = self.GuiElems.List.UIListLayout.AbsoluteContentSize.Y + 6
				self.GuiElems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
			end)

			return contextGui
		end

		funcs.Add = function(self,item)
			local newItem = {
				Name = item.Name or "Item",
				Icon = item.Icon or "",
				Shortcut = item.Shortcut or "",
				OnClick = item.OnClick,
				OnHover = item.OnHover,
				Disabled = item.Disabled or false,
				DisabledIcon = item.DisabledIcon or "",
				IconMap = item.IconMap,
				OnRightClick = item.OnRightClick
			}
			
			newItem.DisabledIcon = newItem.Icon

			if self.QueuedDivider then
				local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
				self:AddDivider(text)
			end
			self.Items[#self.Items+1] = newItem
			self.Updated = nil
		end

		funcs.AddRegistered = function(self,name,disabled)
			if not self.Registered[name] then error(name.." is not registered") end

			if self.QueuedDivider then
				local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
				self:AddDivider(text)
			end
			self.Registered[name].Disabled = disabled
			self.Items[#self.Items+1] = self.Registered[name]
			self.Updated = nil
		end

		funcs.Register = function(self,name,item)
			self.Registered[name] = {
				Name = item.Name or "Item",
				Icon = item.Icon or "",
				Shortcut = item.Shortcut or "",
				OnClick = item.OnClick,
				OnHover = item.OnHover,
				DisabledIcon = item.DisabledIcon or "",
				IconMap = item.IconMap,
				OnRightClick = item.OnRightClick
			}
		end

		funcs.UnRegister = function(self,name)
			self.Registered[name] = nil
		end

		funcs.AddDivider = function(self,text)
			self.QueuedDivider = false
			local textWidth = text and service.TextService:GetTextSize(text,14,Enum.Font.SourceSans,Vector2.new(999999999,20)).X or nil
			table.insert(self.Items,{Divider = true, Text = text, TextSize = textWidth and textWidth+4})
			self.Updated = nil
		end

		funcs.QueueDivider = function(self,text)
			self.QueuedDivider = true
			self.QueuedDividerText = text or ""
		end

		funcs.Clear = function(self)
			self.Items = {}
			self.Updated = nil
		end

		funcs.Refresh = function(self)
			for i,v in pairs(self.GuiElems.List:GetChildren()) do
				if not v:IsA("UIListLayout") then
					v:Destroy()
				end
			end
			local map = {}
			self.ItemToEntryMap = map

			local dividerFrame = self.GuiElems.Divider
			local contextList = self.GuiElems.List
			local entryFrame = self.GuiElems.Entry
			local items = self.Items

			for i = 1,#items do
				local item = items[i]
				if item.Divider then
					local newDivider = dividerFrame:Clone()
					newDivider.Line.BackgroundColor3 = self.Theme.DividerColor
					if item.Text then
						newDivider.Size = UDim2.new(1,0,0,20)
						newDivider.Line.Position = UDim2.new(0,item.TextSize,0.5,0)
						newDivider.Line.Size = UDim2.new(1,-item.TextSize,0,1)
						newDivider.DividerName.TextColor3 = self.Theme.TextColor
						newDivider.DividerName.Text = item.Text
						newDivider.DividerName.Visible = true
					end
					newDivider.Visible = true
					map[item] = newDivider
					newDivider.Parent = contextList
				else
					local newEntry = entryFrame:Clone()
					newEntry.BackgroundColor3 = self.Theme.HighlightColor
					newEntry.EntryName.TextColor3 = self.Theme.TextColor
					newEntry.EntryName.Text = item.Name
					newEntry.Shortcut.Text = item.Shortcut
					if item.Disabled then
						newEntry.EntryName.TextColor3 = Color3.new(150/255,150/255,150/255)
						newEntry.Shortcut.TextColor3 = Color3.new(150/255,150/255,150/255)
					end

					if self.Iconless then
						newEntry.EntryName.Position = UDim2.new(0,2,0,0)
						newEntry.EntryName.Size = UDim2.new(1,-4,0,20)
						newEntry.Icon.Visible = false
					else			
						local iconIndex
						if item.Disabled and item.DisabledIcon then
							iconIndex = item.DisabledIcon
						elseif item.Icon then
							iconIndex =  item.Icon
						end
						
						-- Explorer.MiscIcons:DisplayExplorerIcons(newEntry.Icon, iconIndex)
						if item.IconMap then
							if type(iconIndex) == "number" then
								item.IconMap:Display(newEntry.Icon, iconIndex)
							elseif type(iconIndex) == "string" then
								item.IconMap:DisplayByKey(newEntry.Icon, iconIndex)
							end
						elseif type(iconIndex) == "string" then
							newEntry.Icon.Image = iconIndex
						end
					end

					if not item.Disabled then
						if item.OnClick then
							newEntry.MouseButton1Click:Connect(function()
								item.OnClick(item.Name)
								if not item.NoHide then
									self:Hide()
								end
							end)
						end

						if item.OnRightClick then
							newEntry.MouseButton2Click:Connect(function()
								item.OnRightClick(item.Name)
								if not item.NoHide then
									self:Hide()
								end
							end)
						end
					end

					newEntry.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							newEntry.BackgroundTransparency = 0
						end
					end)

					newEntry.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							newEntry.BackgroundTransparency = 1
						end
					end)

					newEntry.Visible = true
					map[item] = newEntry
					newEntry.Parent = contextList
				end
			end
			self.Updated = true
		end

		funcs.Show = function(self,x,y)
			local elems = self.GuiElems
			elems.SearchFrame.Visible = self.SearchEnabled
			elems.List.Position = UDim2.new(0,2,0,2 + (self.SearchEnabled and 24 or 0))
			elems.List.Size = UDim2.new(1,-4,1,-4 - (self.SearchEnabled and 24 or 0))
			if self.SearchEnabled and self.ClearSearchOnShow then elems.SearchBar.Text = "" end
			self.GuiElems.List.CanvasPosition = Vector2.new(0,0)

			if not self.Updated then
				self:Refresh()
			end

			-- Vars
			local reverseY = false
			local x,y = x or mouse.X, y or mouse.Y
			local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY

			-- Position and show
			if x + self.Width > maxX then
				x = self.ReverseX and x - self.Width or maxX - self.Width
			end
			elems.Main.Position = UDim2.new(0,x,0,y)
			elems.Main.Size = UDim2.new(0,self.Width,0,0)
			self.Gui.DisplayOrder = Main.DisplayOrders.Menu
			Lib.ShowGui(self.Gui)

			-- Size adjustment
			local toSize = elems.List.UIListLayout.AbsoluteContentSize.Y + 6 -- Padding
			if self.MaxHeight and toSize > self.MaxHeight then
				elems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
				toSize = self.MaxHeight
			else
				elems.List.CanvasSize = UDim2.new(0,0,0,0)
			end
			if y + toSize > maxY then reverseY = true end

			-- Close event
			local closable
			if self.CloseEvent then self.CloseEvent:Disconnect() end
			self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if not closable then return end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if not Lib.CheckMouseInGui(elems.Main) then
						self.CloseEvent:Disconnect()
						self:Hide()
					end
				end
			end)

			-- Resize
			if reverseY then
				elems.Main.Position = UDim2.new(0,x,0,y-(self.ReverseYOffset or 0))
				local newY = y - toSize - (self.ReverseYOffset or 0)
				y = newY >= 0 and newY or 0
				elems.Main:TweenSizeAndPosition(UDim2.new(0,self.Width,0,toSize),UDim2.new(0,x,0,y),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
			else
				elems.Main:TweenSize(UDim2.new(0,self.Width,0,toSize),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
			end

			-- Close debounce
			Lib.FastWait()
			if self.SearchEnabled and self.FocusSearchOnShow then elems.SearchBar:CaptureFocus() end
			closable = true
		end

		funcs.Hide = function(self)
			self.Gui.Parent = nil
		end

		funcs.ApplyTheme = function(self,data)
			local theme = self.Theme
			theme.ContentColor = data.ContentColor or Settings.Theme.Menu
			theme.OutlineColor = data.OutlineColor or Settings.Theme.Menu
			theme.DividerColor = data.DividerColor or Settings.Theme.Outline2
			theme.TextColor = data.TextColor or Settings.Theme.Text
			theme.HighlightColor = data.HighlightColor or Settings.Theme.Main1

			self.GuiElems.Main.BackgroundColor3 = theme.OutlineColor
			self.GuiElems.Main.Container.BackgroundColor3 = theme.ContentColor
		end

		local mt = {__index = funcs}
		local function new()
			if not mouse then mouse = Main.Mouse or service.Players.LocalPlayer:GetMouse() end

			local obj = setmetatable({
				Width = 200,
				MaxHeight = nil,
				Iconless = false,
				SearchEnabled = false,
				ClearSearchOnShow = true,
				FocusSearchOnShow = true,
				Updated = false,
				QueuedDivider = false,
				QueuedDividerText = "",
				Items = {},
				Registered = {},
				GuiElems = {},
				Theme = {}
			},mt)
			obj.Gui = createGui(obj)
			obj:ApplyTheme({})
			return obj
		end

		return {new = new}
	end)()

	Lib.CodeFrame = (function()
		local funcs = {}

		local typeMap = {
			[1] = "String",
			[2] = "String",
			[3] = "String",
			[4] = "Comment",
			[5] = "Operator",
			[6] = "Number",
			[7] = "Keyword",
			[8] = "BuiltIn",
			[9] = "LocalMethod",
			[10] = "LocalProperty",
			[11] = "Nil",
			[12] = "Bool",
			[13] = "Function",
			[14] = "Local",
			[15] = "Self",
			[16] = "FunctionName",
			[17] = "Bracket"
		}

		local specialKeywordsTypes = {
			["nil"] = 11,
			["true"] = 12,
			["false"] = 12,
			["function"] = 13,
			["local"] = 14,
			["self"] = 15
		}

		local keywords = {
			["and"] = true,
			["break"] = true, 
			["do"] = true,
			["else"] = true,
			["elseif"] = true,
			["end"] = true,
			["false"] = true,
			["for"] = true,
			["function"] = true,
			["if"] = true,
			["in"] = true,
			["local"] = true,
			["nil"] = true,
			["not"] = true,
			["or"] = true,
			["repeat"] = true,
			["return"] = true,
			["then"] = true,
			["true"] = true,
			["until"] = true,
			["while"] = true,
			["plugin"] = true
		}

		local builtIns = {
			["delay"] = true,
			["elapsedTime"] = true,
			["require"] = true,
			["spawn"] = true,
			["tick"] = true,
			["time"] = true,
			["typeof"] = true,
			["UserSettings"] = true,
			["wait"] = true,
			["warn"] = true,
			["game"] = true,
			["shared"] = true,
			["script"] = true,
			["workspace"] = true,
			["assert"] = true,
			["collectgarbage"] = true,
			["error"] = true,
			["getfenv"] = true,
			["getmetatable"] = true,
			["ipairs"] = true,
			["loadstring"] = true,
			["newproxy"] = true,
			["next"] = true,
			["pairs"] = true,
			["pcall"] = true,
			["print"] = true,
			["rawequal"] = true,
			["rawget"] = true,
			["rawset"] = true,
			["select"] = true,
			["setfenv"] = true,
			["setmetatable"] = true,
			["tonumber"] = true,
			["tostring"] = true,
			["type"] = true,
			["unpack"] = true,
			["xpcall"] = true,
			["_G"] = true,
			["_VERSION"] = true,
			["coroutine"] = true,
			["debug"] = true,
			["math"] = true,
			["os"] = true,
			["string"] = true,
			["table"] = true,
			["bit32"] = true,
			["utf8"] = true,
			["Axes"] = true,
			["BrickColor"] = true,
			["CFrame"] = true,
			["Color3"] = true,
			["ColorSequence"] = true,
			["ColorSequenceKeypoint"] = true,
			["DockWidgetPluginGuiInfo"] = true,
			["Enum"] = true,
			["Faces"] = true,
			["Instance"] = true,
			["NumberRange"] = true,
			["NumberSequence"] = true,
			["NumberSequenceKeypoint"] = true,
			["PathWaypoint"] = true,
			["PhysicalProperties"] = true,
			["Random"] = true,
			["Ray"] = true,
			["Rect"] = true,
			["Region3"] = true,
			["Region3int16"] = true,
			["TweenInfo"] = true,
			["UDim"] = true,
			["UDim2"] = true,
			["Vector2"] = true,
			["Vector2int16"] = true,
			["Vector3"] = true,
			["Vector3int16"] = true,

			["getgenv"] = true,
			["getrenv"] = true,
			["getsenv"] = true,
			["getgc"] = true,
			["getreg"] = true,
			["filtergc"] = true,
			["saveinstave"] = true,
			["decompile"] = true,
			["syn"] = true,
			["getupvalue"] = true,
			["getupvalues"] = true,
			["setupvalue"] = true,
			["getstack"] = true,
			["setstack"] = true,
			["getconstants"] = true,
			["getconstant"] = true,
			["setconstant"] = true,
			["getproto"] = true,
			["getprotos"] = true,
			["checkcaller"] = true,
			["clonefunction"] = true,
			["cloneref"] = true,
			["getfunctionhash"] = true,
			["gethwid"] = true,
			["hookfunction"] = true,
			["hookmetamethod"] = true,
			["iscclosure"] = true,
			["islclosure"] = true,
			["newcclosure"] = true,
			["isexecutorclosure"] = true,
			["restorefunction"] = true,
			["crypt"] = true,
			["Drawing"] = true,

		}

		local builtInInited = false

		local richReplace = {
			["'"] = "&apos;",
			["\""] = "&quot;",
			["<"] = "&lt;",
			[">"] = "&gt;",
			["&"] = "&amp;"
		}

		local tabSub = "\205"
		local tabReplacement = (" %s%s "):format(tabSub,tabSub)

		local tabJumps = {
			[("[^%s] %s"):format(tabSub,tabSub)] = 0,
			[(" %s%s"):format(tabSub,tabSub)] = -1,
			[("%s%s "):format(tabSub,tabSub)] = 2,
			[("%s [^%s]"):format(tabSub,tabSub)] = 1,
		}

		local tweenService = service.TweenService
		local lineTweens = {}

		local function initBuiltIn()
			local env = getfenv()
			local type = type
			local tostring = tostring
			for name,_ in next,builtIns do
				local envVal = env[name]
				if type(envVal) == "table" then
					local items = {}
					for i,v in next,envVal do
						items[i] = true
					end
					builtIns[name] = items
				end
			end

			local enumEntries = {}
			local enums = Enum:GetEnums()
			for i = 1,#enums do
				enumEntries[tostring(enums[i])] = true
			end
			builtIns["Enum"] = enumEntries

			builtInInited = true
		end

		local function setupEditBox(obj)
			local editBox = obj.GuiElems.EditBox

			editBox.Focused:Connect(function()
				obj:ConnectEditBoxEvent()
				obj.Editing = true
			end)

			editBox.FocusLost:Connect(function()
				obj:DisconnectEditBoxEvent()
				obj.Editing = false
			end)

			editBox:GetPropertyChangedSignal("Text"):Connect(function()
				local text = editBox.Text
				if #text == 0 or obj.EditBoxCopying then return end
				editBox.Text = ""
				obj:AppendText(text)
			end)
		end

		local function setupMouseSelection(obj)
			local mouse = plr:GetMouse()
			local codeFrame = obj.GuiElems.LinesFrame
			local lines = obj.Lines

			codeFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local fontSizeX,fontSizeY = math.ceil(obj.FontSize/2),obj.FontSize

					local relX = mouse.X - codeFrame.AbsolutePosition.X
					local relY = mouse.Y - codeFrame.AbsolutePosition.Y
					local selX = math.round(relX / fontSizeX) + obj.ViewX
					local selY = math.floor(relY / fontSizeY) + obj.ViewY
					local releaseEvent,mouseEvent,scrollEvent
					local scrollPowerV,scrollPowerH = 0,0
					selY = math.min(#lines-1,selY)
					local relativeLine = lines[selY+1] or ""
					selX = math.min(#relativeLine, selX + obj:TabAdjust(selX,selY))

					obj.SelectionRange = {{-1,-1},{-1,-1}}
					obj:MoveCursor(selX,selY)
					obj.FloatCursorX = selX

					local function updateSelection()
						local relX = mouse.X - codeFrame.AbsolutePosition.X
						local relY = mouse.Y - codeFrame.AbsolutePosition.Y
						local sel2X = math.max(0,math.round(relX / fontSizeX) + obj.ViewX)
						local sel2Y = math.max(0,math.floor(relY / fontSizeY) + obj.ViewY)

						sel2Y = math.min(#lines-1,sel2Y)
						local relativeLine = lines[sel2Y+1] or ""
						sel2X = math.min(#relativeLine, sel2X + obj:TabAdjust(sel2X,sel2Y))

						if sel2Y < selY or (sel2Y == selY and sel2X < selX) then
							obj.SelectionRange = {{sel2X,sel2Y},{selX,selY}}
						else						
							obj.SelectionRange = {{selX,selY},{sel2X,sel2Y}}
						end

						obj:MoveCursor(sel2X,sel2Y)
						obj.FloatCursorX = sel2X
						obj:Refresh()
					end

					releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
							scrollEvent:Disconnect()
							obj:SetCopyableSelection()
							--updateSelection()
						end
					end)

					mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							local upDelta = mouse.Y - codeFrame.AbsolutePosition.Y
							local downDelta = mouse.Y - codeFrame.AbsolutePosition.Y - codeFrame.AbsoluteSize.Y
							local leftDelta = mouse.X - codeFrame.AbsolutePosition.X
							local rightDelta = mouse.X - codeFrame.AbsolutePosition.X - codeFrame.AbsoluteSize.X
							scrollPowerV = 0
							scrollPowerH = 0
							if downDelta > 0 then
								scrollPowerV = math.floor(downDelta*0.05) + 1
							elseif upDelta < 0 then
								scrollPowerV = math.ceil(upDelta*0.05) - 1
							end
							if rightDelta > 0 then
								scrollPowerH = math.floor(rightDelta*0.05) + 1
							elseif leftDelta < 0 then
								scrollPowerH = math.ceil(leftDelta*0.05) - 1
							end
							updateSelection()
						end
					end)

					scrollEvent = game:GetService("RunService").RenderStepped:Connect(function()
						if scrollPowerV ~= 0 or scrollPowerH ~= 0 then
							obj:ScrollDelta(scrollPowerH,scrollPowerV)
							updateSelection()
						end
					end)

					obj:Refresh()
				end
			end)
		end

		local function makeFrame(obj)
			local frame = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel = 0,Position=UDim2.new(0.5,-300,0.5,-200),Size=UDim2.new(0,600,0,400),}},
			})

			if Settings.Window.Transparency and Settings.Window.Transparency > 0 then
				frame.BackgroundTransparency = 0.5
			end

			local elems = {}

			local linesFrame = Instance.new("Frame")
			linesFrame.Name = "Lines"
			linesFrame.BackgroundTransparency = 1
			linesFrame.Size = UDim2.new(1,0,1,0)
			linesFrame.ClipsDescendants = true
			linesFrame.Parent = frame

			local lineNumbersLabel = Instance.new("TextLabel")
			lineNumbersLabel.Name = "LineNumbers"
			lineNumbersLabel.BackgroundTransparency = 1
			lineNumbersLabel.Font = Enum.Font.Code
			lineNumbersLabel.TextXAlignment = Enum.TextXAlignment.Right
			lineNumbersLabel.TextYAlignment = Enum.TextYAlignment.Top
			lineNumbersLabel.ClipsDescendants = true
			lineNumbersLabel.RichText = true
			lineNumbersLabel.Parent = frame

			local cursor = Instance.new("Frame")
			cursor.Name = "Cursor"
			cursor.BackgroundColor3 = Color3.fromRGB(220,220,220)
			cursor.BorderSizePixel = 0
			cursor.Parent = frame

			local editBox = Instance.new("TextBox")
			editBox.Name = "EditBox"
			editBox.MultiLine = true
			editBox.Visible = false
			editBox.Parent = frame

			lineTweens.Invis = tweenService:Create(cursor,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 1})
			lineTweens.Vis = tweenService:Create(cursor,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 0})

			elems.LinesFrame = linesFrame
			elems.LineNumbersLabel = lineNumbersLabel
			elems.Cursor = cursor
			elems.EditBox = editBox
			elems.ScrollCorner = create({{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}}})

			elems.ScrollCorner.Parent = frame
			linesFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					obj:SetEditing(true,input)
				end
			end)

			obj.Frame = frame
			obj.Gui = frame
			obj.GuiElems = elems
			setupEditBox(obj)
			setupMouseSelection(obj)

			return frame
		end

		funcs.GetSelectionText = function(self)
			if not self:IsValidRange() then return "" end

			local selectionRange = self.SelectionRange
			local selX,selY = selectionRange[1][1], selectionRange[1][2]
			local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]
			local deltaLines = sel2Y-selY
			local lines = self.Lines

			if not lines[selY+1] or not lines[sel2Y+1] then return "" end

			if deltaLines == 0 then
				return self:ConvertText(lines[selY+1]:sub(selX+1,sel2X), false)
			end

			local leftSub = lines[selY+1]:sub(selX+1)
			local rightSub = lines[sel2Y+1]:sub(1,sel2X)

			local result = leftSub.."\n" 
			for i = selY+1,sel2Y-1 do
				result = result..lines[i+1].."\n"
			end
			result = result..rightSub

			return self:ConvertText(result,false)
		end

		funcs.SetCopyableSelection = function(self)
			local text = self:GetSelectionText()
			local editBox = self.GuiElems.EditBox

			self.EditBoxCopying = true
			editBox.Text = text
			editBox.SelectionStart = 1
			editBox.CursorPosition = #editBox.Text + 1
			self.EditBoxCopying = false
		end

		funcs.ConnectEditBoxEvent = function(self)
			if self.EditBoxEvent then
				self.EditBoxEvent:Disconnect()
			end

			self.EditBoxEvent = service.UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

				local keycodes = Enum.KeyCode
				local keycode = input.KeyCode

				local function setupMove(key,func)
					local endCon,finished
					endCon = service.UserInputService.InputEnded:Connect(function(input)
						if input.KeyCode ~= key then return end
						endCon:Disconnect()
						finished = true
					end)
					func()
					Lib.FastWait(0.5)
					while not finished do func() Lib.FastWait(0.03) end
				end

				if keycode == keycodes.Down then
					setupMove(keycodes.Down,function()
						self.CursorX = self.FloatCursorX
						self.CursorY = self.CursorY + 1
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Up then
					setupMove(keycodes.Up,function()
						self.CursorX = self.FloatCursorX
						self.CursorY = self.CursorY - 1
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Left then
					setupMove(keycodes.Left,function()
						local line = self.Lines[self.CursorY+1] or ""
						self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
						if self.CursorX < 0 then
							self.CursorY = self.CursorY - 1
							local line2 = self.Lines[self.CursorY+1] or ""
							self.CursorX = #line2
						end
						self.FloatCursorX = self.CursorX
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Right then
					setupMove(keycodes.Right,function()
						local line = self.Lines[self.CursorY+1] or ""
						self.CursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
						if self.CursorX > #line then
							self.CursorY = self.CursorY + 1
							self.CursorX = 0
						end
						self.FloatCursorX = self.CursorX
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Backspace then
					setupMove(keycodes.Backspace,function()
						local startRange,endRange
						if self:IsValidRange() then
							startRange = self.SelectionRange[1]
							endRange = self.SelectionRange[2]
						else
							endRange = {self.CursorX,self.CursorY}
						end

						if not startRange then
							local line = self.Lines[self.CursorY+1] or ""
							self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
							if self.CursorX < 0 then
								self.CursorY = self.CursorY - 1
								local line2 = self.Lines[self.CursorY+1] or ""
								self.CursorX = #line2
							end
							self.FloatCursorX = self.CursorX
							self:UpdateCursor()

							startRange = startRange or {self.CursorX,self.CursorY}
						end

						self:DeleteRange({startRange,endRange},false,true)
						self:ResetSelection(true)
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Delete then
					setupMove(keycodes.Delete,function()
						local startRange,endRange
						if self:IsValidRange() then
							startRange = self.SelectionRange[1]
							endRange = self.SelectionRange[2]
						else
							startRange = {self.CursorX,self.CursorY}
						end

						if not endRange then
							local line = self.Lines[self.CursorY+1] or ""
							local endCursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
							local endCursorY = self.CursorY
							if endCursorX > #line then
								endCursorY = endCursorY + 1
								endCursorX = 0
							end
							self:UpdateCursor()

							endRange = endRange or {endCursorX,endCursorY}
						end

						self:DeleteRange({startRange,endRange},false,true)
						self:ResetSelection(true)
						self:JumpToCursor()
					end)
				elseif service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					if keycode == keycodes.A then
						self.SelectionRange = {{0,0},{#self.Lines[#self.Lines],#self.Lines-1}}
						self:SetCopyableSelection()
						self:Refresh()
					end
				end
			end)
		end

		funcs.DisconnectEditBoxEvent = function(self)
			if self.EditBoxEvent then
				self.EditBoxEvent:Disconnect()
			end
		end

		funcs.ResetSelection = function(self,norefresh)
			self.SelectionRange = {{-1,-1},{-1,-1}}
			if not norefresh then self:Refresh() end
		end

		funcs.IsValidRange = function(self,range)
			local selectionRange = range or self.SelectionRange
			local selX,selY = selectionRange[1][1], selectionRange[1][2]
			local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]

			if selX == -1 or (selX == sel2X and selY == sel2Y) then return false end

			return true
		end

		funcs.DeleteRange = function(self,range,noprocess,updatemouse)
			range = range or self.SelectionRange
			if not self:IsValidRange(range) then return end

			local lines = self.Lines
			local selX,selY = range[1][1], range[1][2]
			local sel2X,sel2Y = range[2][1], range[2][2]
			local deltaLines = sel2Y-selY

			if not lines[selY+1] or not lines[sel2Y+1] then return end

			local leftSub = lines[selY+1]:sub(1,selX)
			local rightSub = lines[sel2Y+1]:sub(sel2X+1)
			lines[selY+1] = leftSub..rightSub

			local remove = table.remove
			for i = 1,deltaLines do
				remove(lines,selY+2)
			end

			if range == self.SelectionRange then self.SelectionRange = {{-1,-1},{-1,-1}} end
			if updatemouse then
				self.CursorX = selX
				self.CursorY = selY
				self:UpdateCursor()
			end

			if not noprocess then
				self:ProcessTextChange()
			end
		end

		funcs.AppendText = function(self,text)
			self:DeleteRange(nil,true,true)
			local lines,cursorX,cursorY = self.Lines,self.CursorX,self.CursorY
			local line = lines[cursorY+1]
			local before = line:sub(1,cursorX)
			local after = line:sub(cursorX+1)

			text = text:gsub("\r\n","\n")
			text = self:ConvertText(text,true) -- Tab Convert

			local textLines = text:split("\n")
			local insert = table.insert

			for i = 1,#textLines do
				local linePos = cursorY+i
				if i > 1 then insert(lines,linePos,"") end

				local textLine = textLines[i]
				local newBefore = (i == 1 and before or "")
				local newAfter = (i == #textLines and after or "")

				lines[linePos] = newBefore..textLine..newAfter
			end

			if #textLines > 1 then cursorX = 0 end

			self:ProcessTextChange()
			self.CursorX = cursorX + #textLines[#textLines]
			self.CursorY = cursorY + #textLines-1
			self:UpdateCursor()
		end

		funcs.ScrollDelta = function(self,x,y)
			self.ScrollV:ScrollTo(self.ScrollV.Index + y)
			self.ScrollH:ScrollTo(self.ScrollH.Index + x)
		end

		-- x and y starts at 0
		funcs.TabAdjust = function(self,x,y)
			local lines = self.Lines
			local line = lines[y+1]
			x=x+1

			if line then
				local left = line:sub(x-1,x-1)
				local middle = line:sub(x,x)
				local right = line:sub(x+1,x+1)
				local selRange = (#left > 0 and left or " ") .. (#middle > 0 and middle or " ") .. (#right > 0 and right or " ")

				for i,v in pairs(tabJumps) do
					if selRange:find(i) then
						return v
					end
				end
			end
			return 0
		end

		funcs.SetEditing = function(self,on,input)			
			self:UpdateCursor(input)

			if on then
				if self.Editable then
					self.GuiElems.EditBox.Text = ""
					self.GuiElems.EditBox:CaptureFocus()
				end
			else
				self.GuiElems.EditBox:ReleaseFocus()
			end
		end

		funcs.CursorAnim = function(self,on)
			local cursor = self.GuiElems.Cursor
			local animTime = tick()
			self.LastAnimTime = animTime

			if not on then return end

			lineTweens.Invis:Cancel()
			lineTweens.Vis:Cancel()
			cursor.BackgroundTransparency = 0

			coroutine.wrap(function()
				while self.Editable do
					Lib.FastWait(0.5)
					if self.LastAnimTime ~= animTime then return end
					lineTweens.Invis:Play()
					Lib.FastWait(0.4)
					if self.LastAnimTime ~= animTime then return end
					lineTweens.Vis:Play()
					Lib.FastWait(0.2)
				end
			end)()
		end

		funcs.MoveCursor = function(self,x,y)
			self.CursorX = x
			self.CursorY = y
			self:UpdateCursor()
			self:JumpToCursor()
		end

		funcs.JumpToCursor = function(self)
			self:Refresh()
		end

		funcs.UpdateCursor = function(self,input)
			local linesFrame = self.GuiElems.LinesFrame
			local cursor = self.GuiElems.Cursor			
			local hSize = math.max(0,linesFrame.AbsoluteSize.X)
			local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
			local maxLines = math.ceil(vSize / self.FontSize)
			local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
			local viewX,viewY = self.ViewX,self.ViewY
			local totalLinesStr = tostring(#self.Lines)
			local fontWidth = math.ceil(self.FontSize / 2)
			local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

			if input then
				local linesFrame = self.GuiElems.LinesFrame
				local frameX,frameY = linesFrame.AbsolutePosition.X,linesFrame.AbsolutePosition.Y
				local mouseX,mouseY = input.Position.X,input.Position.Y
				local fontSizeX,fontSizeY = math.ceil(self.FontSize/2),self.FontSize

				self.CursorX = self.ViewX + math.round((mouseX - frameX) / fontSizeX)
				self.CursorY = self.ViewY + math.floor((mouseY - frameY) / fontSizeY)
			end

			local cursorX,cursorY = self.CursorX,self.CursorY

			local line = self.Lines[cursorY+1] or ""
			if cursorX > #line then cursorX = #line
			elseif cursorX < 0 then cursorX = 0 end

			if cursorY >= #self.Lines then
				cursorY = math.max(0,#self.Lines-1)
			elseif cursorY < 0 then
				cursorY = 0
			end

			cursorX = cursorX + self:TabAdjust(cursorX,cursorY)

			-- Update modified
			self.CursorX = cursorX
			self.CursorY = cursorY

			local cursorVisible = (cursorX >= viewX) and (cursorY >= viewY) and (cursorX <= viewX + maxCols) and (cursorY <= viewY + maxLines)
			if cursorVisible then
				local offX = (cursorX - viewX)
				local offY = (cursorY - viewY)
				cursor.Position = UDim2.new(0,linesOffset + offX*math.ceil(self.FontSize/2) - 1,0,offY*self.FontSize)
				cursor.Size = UDim2.new(0,1,0,self.FontSize+2)
				cursor.Visible = true
				self:CursorAnim(true)
			else
				cursor.Visible = false
			end
		end

		funcs.MapNewLines = function(self)
			local newLines = {}
			local count = 1
			local text = self.Text
			local find = string.find
			local init = 1

			local pos = find(text,"\n",init,true)
			while pos do
				newLines[count] = pos
				count = count + 1
				init = pos + 1
				pos = find(text,"\n",init,true)
			end

			self.NewLines = newLines
		end

		funcs.PreHighlight = function(self)
			local start = tick()
			local text = self.Text:gsub("\\\\","  ")
			--print("BACKSLASH SUB",tick()-start)
			local textLen = #text
			local found = {}
			local foundMap = {}
			local extras = {}
			local find = string.find
			local sub = string.sub
			self.ColoredLines = {}

			local function findAll(str,pattern,typ,raw)
				local count = #found+1
				local init = 1
				local x,y,extra = find(str,pattern,init,raw)
				while x do
					found[count] = x
					foundMap[x] = typ
					if extra then
						extras[x] = extra
					end

					count = count+1
					init = y+1
					x,y,extra = find(str,pattern,init,raw)
				end
			end
			local start = tick()
			findAll(text,'"',1,true)
			findAll(text,"'",2,true)
			findAll(text,"%[(=*)%[",3)
			findAll(text,"--",4,true)
			table.sort(found)

			local newLines = self.NewLines
			local curLine = 0
			local lineTableCount = 1
			local lineStart = 0
			local lineEnd = 0
			local lastEnding = 0
			local foundHighlights = {}

			for i = 1,#found do
				local pos = found[i]
				if pos <= lastEnding then continue end

				local ending = pos
				local typ = foundMap[pos]
				if typ == 1 then
					ending = find(text,'"',pos+1,true)
					while ending and sub(text,ending-1,ending-1) == "\\" do
						ending = find(text,'"',ending+1,true)
					end
					if not ending then ending = textLen end
				elseif typ == 2 then
					ending = find(text,"'",pos+1,true)
					while ending and sub(text,ending-1,ending-1) == "\\" do
						ending = find(text,"'",ending+1,true)
					end
					if not ending then ending = textLen end
				elseif typ == 3 then
					_,ending = find(text,"]"..extras[pos].."]",pos+1,true)
					if not ending then ending = textLen end
				elseif typ == 4 then
					local ahead = foundMap[pos+2]

					if ahead == 3 then
						_,ending = find(text,"]"..extras[pos+2].."]",pos+1,true)
						if not ending then ending = textLen end
					else
						ending = find(text,"\n",pos+1,true) or textLen
					end
				end

				while pos > lineEnd do
					curLine = curLine + 1
					--lineTableCount = 1
					lineEnd = newLines[curLine] or textLen+1
				end
				while true do
					local lineTable = foundHighlights[curLine]
					if not lineTable then lineTable = {} foundHighlights[curLine] = lineTable end
					lineTable[pos] = {typ,ending}
					--lineTableCount = lineTableCount + 1

					if ending > lineEnd then
						curLine = curLine + 1
						lineEnd = newLines[curLine] or textLen+1
					else
						break
					end
				end

				lastEnding = ending
				--if i < 200 then print(curLine) end
			end
			self.PreHighlights = foundHighlights
			--print(tick()-start)
			--print(#found,curLine)
		end

		funcs.HighlightLine = function(self,line)
			local cached = self.ColoredLines[line]
			if cached then return cached end

			local sub = string.sub
			local find = string.find
			local match = string.match
			local highlights = {}
			local preHighlights = self.PreHighlights[line] or {}
			local lineText = self.Lines[line] or ""
			local lineLen = #lineText
			local lastEnding = 0
			local currentType = 0
			local lastWord = nil
			local wordBeginsDotted = false
			local funcStatus = 0
			local lineStart = self.NewLines[line-1] or 0

			local preHighlightMap = {}
			for pos,data in next,preHighlights do
				local relativePos = pos-lineStart
				if relativePos < 1 then
					currentType = data[1]
					lastEnding = data[2] - lineStart
					--warn(pos,data[2])
				else
					preHighlightMap[relativePos] = {data[1],data[2]-lineStart}
				end
			end

			for col = 1,#lineText do
				if col <= lastEnding then highlights[col] = currentType continue end

				local pre = preHighlightMap[col]
				if pre then
					currentType = pre[1]
					lastEnding = pre[2]
					highlights[col] = currentType
					wordBeginsDotted = false
					lastWord = nil
					funcStatus = 0
				else
					local char = sub(lineText,col,col)
					if find(char,"[%a_]") then
						local word = match(lineText,"[%a%d_]+",col)
						local wordType = (keywords[word] and 7) or (builtIns[word] and 8)

						lastEnding = col+#word-1

						if wordType ~= 7 then
							if wordBeginsDotted then
								local prevBuiltIn = lastWord and builtIns[lastWord]
								wordType = (prevBuiltIn and type(prevBuiltIn) == "table" and prevBuiltIn[word] and 8) or 10
							end

							if wordType ~= 8 then
								local x,y,br = find(lineText,"^%s*([%({\"'])",lastEnding+1)
								if x then
									wordType = (funcStatus > 0 and br == "(" and 16) or 9
									funcStatus = 0
								end
							end
						else
							wordType = specialKeywordsTypes[word] or wordType
							funcStatus = (word == "function" and 1 or 0)
						end

						lastWord = word
						wordBeginsDotted = false
						if funcStatus > 0 then funcStatus = 1 end

						if wordType then
							currentType = wordType
							highlights[col] = currentType
						else
							currentType = nil
						end
					elseif find(char,"%p") then
						local isDot = (char == ".")
						local isNum = isDot and find(sub(lineText,col+1,col+1),"%d")
						highlights[col] = (isNum and 6 or 5)

						if not isNum then
							local dotStr = isDot and match(lineText,"%.%.?%.?",col)
							if dotStr and #dotStr > 1 then
								currentType = 5
								lastEnding = col+#dotStr-1
								wordBeginsDotted = false
								lastWord = nil
								funcStatus = 0
							else
								if isDot then
									if wordBeginsDotted then
										lastWord = nil
									else
										wordBeginsDotted = true
									end
								else
									wordBeginsDotted = false
									lastWord = nil
								end

								funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
							end
						end
					elseif find(char,"%d") then
						local _,endPos = find(lineText,"%x+",col)
						local endPart = sub(lineText,endPos,endPos+1)
						if (endPart == "e+" or endPart == "e-") and find(sub(lineText,endPos+2,endPos+2),"%d") then
							endPos = endPos + 1
						end
						currentType = 6
						lastEnding = endPos
						highlights[col] = 6
						wordBeginsDotted = false
						lastWord = nil
						funcStatus = 0
					else
						highlights[col] = currentType
						local _,endPos = find(lineText,"%s+",col)
						if endPos then
							lastEnding = endPos
						end
					end
				end
			end

			self.ColoredLines[line] = highlights
			return highlights
		end

		funcs.Refresh = function(self)
			local start = tick()

			local linesFrame = self.Frame.Lines
			local hSize = math.max(0,linesFrame.AbsoluteSize.X)
			local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
			local maxLines = math.ceil(vSize / self.FontSize)
			local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
			local gsub = string.gsub
			local sub = string.sub

			local viewX,viewY = self.ViewX,self.ViewY

			local lineNumberStr = ""

			for row = 1,maxLines do
				local lineFrame = self.LineFrames[row]
				if not lineFrame then
					lineFrame = Instance.new("Frame")
					lineFrame.Name = "Line"
					lineFrame.Position = UDim2.new(0,0,0,(row-1)*self.FontSize)
					lineFrame.Size = UDim2.new(1,0,0,self.FontSize)
					lineFrame.BorderSizePixel = 0
					lineFrame.BackgroundTransparency = 1

					local selectionHighlight = Instance.new("Frame")
					selectionHighlight.Name = "SelectionHighlight"
					selectionHighlight.BorderSizePixel = 0
					selectionHighlight.BackgroundColor3 = Settings.Theme.Syntax.SelectionBack
					selectionHighlight.Parent = lineFrame

					local label = Instance.new("TextLabel")
					label.Name = "Label"
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.Code
					label.TextSize = self.FontSize
					label.Size = UDim2.new(1,0,0,self.FontSize)
					label.RichText = true
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextColor3 = self.Colors.Text
					label.ZIndex = 2
					label.Parent = lineFrame

					lineFrame.Parent = linesFrame
					self.LineFrames[row] = lineFrame
				end

				local relaY = viewY + row
				local lineText = self.Lines[relaY] or ""
				local resText = ""
				local highlights = self:HighlightLine(relaY)
				local colStart = viewX + 1

				local richTemplates = self.RichTemplates
				local textTemplate = richTemplates.Text
				local selectionTemplate = richTemplates.Selection
				local curType = highlights[colStart]
				local curTemplate = richTemplates[typeMap[curType]] or textTemplate

				-- Selection Highlight
				local selectionRange = self.SelectionRange
				local selPos1 = selectionRange[1]
				local selPos2 = selectionRange[2]
				local selRow,selColumn = selPos1[2],selPos1[1]
				local sel2Row,sel2Column = selPos2[2],selPos2[1]
				local selRelaX,selRelaY = viewX,relaY-1

				if selRelaY >= selPos1[2] and selRelaY <= selPos2[2] then
					local fontSizeX = math.ceil(self.FontSize/2)
					local posX = (selRelaY == selPos1[2] and selPos1[1] or 0) - viewX
					local sizeX = (selRelaY == selPos2[2] and selPos2[1]-posX-viewX or maxCols+viewX)

					lineFrame.SelectionHighlight.Position = UDim2.new(0,posX*fontSizeX,0,0)
					lineFrame.SelectionHighlight.Size = UDim2.new(0,sizeX*fontSizeX,1,0)
					lineFrame.SelectionHighlight.Visible = true
				else
					lineFrame.SelectionHighlight.Visible = false
				end

				-- Selection Text Color for first char
				local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and viewX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and viewX < sel2Column or selRelaY ~= sel2Row)
				if inSelection then
					curType = -999
					curTemplate = selectionTemplate
				end

				for col = 2,maxCols do
					local relaX = viewX + col
					local selRelaX = relaX-1
					local posType = highlights[relaX]

					-- Selection Text Color
					local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and selRelaX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and selRelaX < sel2Column or selRelaY ~= sel2Row)
					if inSelection then
						posType = -999
					end

					if posType ~= curType then
						local template = (inSelection and selectionTemplate) or richTemplates[typeMap[posType]] or textTemplate

						if template ~= curTemplate then
							local nextText = gsub(sub(lineText,colStart,relaX-1),"['\"<>&]",richReplace)
							resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. nextText .. "</font>") or nextText)
							colStart = relaX
							curTemplate = template
						end
						curType = posType
					end
				end

				local lastText = gsub(sub(lineText,colStart,viewX+maxCols),"['\"<>&]",richReplace)
				--warn("SUB",colStart,viewX+maxCols-1)
				if #lastText > 0 then
					resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. lastText .. "</font>") or lastText)
				end

				if self.Lines[relaY] then

					-- REMOVED LINE HIGHLIGHT DUE TO BUG OFFSET
					lineNumberStr = lineNumberStr .. (relaY == self.CursorY and ("<b>"..relaY.."</b>\n") or relaY .. "\n")
					--lineNumberStr = lineNumberStr .. (relaY == self.CursorY and (relaY.."\n") or relaY .. "\n")
				end

				lineFrame.Label.Text = resText
			end

			for i = maxLines+1,#self.LineFrames do
				self.LineFrames[i]:Destroy()
				self.LineFrames[i] = nil
			end

			self.Frame.LineNumbers.Text = lineNumberStr
			self:UpdateCursor()

			--print("REFRESH TIME",tick()-start)
		end

		funcs.UpdateView = function(self)
			local totalLinesStr = tostring(#self.Lines)
			local fontWidth = math.ceil(self.FontSize / 2)
			local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

			local linesFrame = self.Frame.Lines
			local hSize = linesFrame.AbsoluteSize.X
			local vSize = linesFrame.AbsoluteSize.Y
			local maxLines = math.ceil(vSize / self.FontSize)
			local totalWidth = self.MaxTextCols*fontWidth
			local scrollV = self.ScrollV
			local scrollH = self.ScrollH

			scrollV.VisibleSpace = maxLines
			scrollV.TotalSpace = #self.Lines + 1
			scrollH.VisibleSpace = math.ceil(hSize/fontWidth)
			scrollH.TotalSpace = self.MaxTextCols + 1

			scrollV.Gui.Visible = #self.Lines + 1 > maxLines
			scrollH.Gui.Visible = totalWidth > hSize

			local oldOffsets = self.FrameOffsets
			self.FrameOffsets = Vector2.new(scrollV.Gui.Visible and -16 or 0, scrollH.Gui.Visible and -16 or 0)
			if oldOffsets ~= self.FrameOffsets then
				self:UpdateView()
			else
				scrollV:ScrollTo(self.ViewY,true)
				scrollH:ScrollTo(self.ViewX,true)

				if scrollV.Gui.Visible and scrollH.Gui.Visible then
					scrollV.Gui.Size = UDim2.new(0,16,1,-16)
					scrollH.Gui.Size = UDim2.new(1,-16,0,16)
					self.GuiElems.ScrollCorner.Visible = true
				else
					scrollV.Gui.Size = UDim2.new(0,16,1,0)
					scrollH.Gui.Size = UDim2.new(1,0,0,16)
					self.GuiElems.ScrollCorner.Visible = false
				end

				self.ViewY = scrollV.Index
				self.ViewX = scrollH.Index
				self.Frame.Lines.Position = UDim2.new(0,linesOffset,0,0)
				self.Frame.Lines.Size = UDim2.new(1,-linesOffset+oldOffsets.X,1,oldOffsets.Y)
				self.Frame.LineNumbers.Position = UDim2.new(0,fontWidth,0,0)
				self.Frame.LineNumbers.Size = UDim2.new(0,#totalLinesStr*fontWidth,1,oldOffsets.Y)
				self.Frame.LineNumbers.TextSize = self.FontSize
			end
		end

		funcs.ProcessTextChange = function(self)
			local maxCols = 0
			local lines = self.Lines

			for i = 1,#lines do
				local lineLen = #lines[i]
				if lineLen > maxCols then
					maxCols = lineLen
				end
			end

			self.MaxTextCols = maxCols
			self:UpdateView()	
			self.Text = table.concat(self.Lines,"\n")
			self:MapNewLines()
			self:PreHighlight()
			self:Refresh()
			--self.TextChanged:Fire()
		end

		funcs.ConvertText = function(self,text,toEditor)
			if toEditor then
				--return text:gsub("\t",(" %s%s "):format(tabSub,tabSub))
				return text:gsub("\t","    ") -- Fixed unknown unicode showing when pressing TAB
			else
				return text:gsub((" %s%s "):format(tabSub,tabSub),"\t")
			end
		end

		funcs.GetText = function(self) -- TODO: better (use new tab format)
			local source = table.concat(self.Lines,"\n")
			return self:ConvertText(source,false) -- Tab Convert
		end

		funcs.SetText = function(self,txt)
			txt = self:ConvertText(txt,true) -- Tab Convert
			local lines = self.Lines
			table.clear(lines)
			local count = 1

			for line in txt:gmatch("([^\n\r]*)[\n\r]?") do
				local len = #line
				lines[count] = line
				count = count + 1
			end

			self:ProcessTextChange()
		end

		funcs.MakeRichTemplates = function(self)
			local floor = math.floor
			local templates = {}

			for name,color in pairs(self.Colors) do
				templates[name] = ('<font color="rgb(%s,%s,%s)">'):format(floor(color.r*255),floor(color.g*255),floor(color.b*255))
			end

			self.RichTemplates = templates
		end

		funcs.ApplyTheme = function(self)
			local colors = Settings.Theme.Syntax
			self.Colors = colors
			self.Frame.LineNumbers.TextColor3 = colors.Text
			self.Frame.BackgroundColor3 = colors.Background
		end

		local mt = {__index = funcs}

		local function new()
			if not builtInInited then initBuiltIn() end

			local scrollV = Lib.ScrollBar.new()
			local scrollH = Lib.ScrollBar.new(true)
			scrollH.Gui.Position = UDim2.new(0,0,1,-16)
			local obj = setmetatable({
				FontSize = 16,
				ViewX = 0,
				ViewY = 0,
				Colors = Settings.Theme.Syntax,
				ColoredLines = {},
				Lines = {""},
				LineFrames = {},
				Editable = true,
				Editing = false,
				CursorX = 0,
				CursorY = 0,
				FloatCursorX = 0,
				Text = "",
				PreHighlights = {},
				SelectionRange = {{-1,-1},{-1,-1}},
				NewLines = {},
				FrameOffsets = Vector2.new(0,0),
				MaxTextCols = 0,
				ScrollV = scrollV,
				ScrollH = scrollH
			},mt)

			scrollV.WheelIncrement = 3
			scrollH.Increment = 2
			scrollH.WheelIncrement = 7

			scrollV.Scrolled:Connect(function()
				obj.ViewY = scrollV.Index
				obj:Refresh()
			end)

			scrollH.Scrolled:Connect(function()
				obj.ViewX = scrollH.Index
				obj:Refresh()
			end)

			makeFrame(obj)
			obj:MakeRichTemplates()
			obj:ApplyTheme()
			scrollV:SetScrollFrame(obj.Frame.Lines)
			scrollV.Gui.Parent = obj.Frame
			scrollH.Gui.Parent = obj.Frame

			obj:UpdateView()
			obj.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				obj:UpdateView()
				obj:Refresh()
			end)

			return obj
		end

		return {new = new}
	end)()

	Lib.Checkbox = (function()
		local funcs = {}
		local c3 = Color3.fromRGB
		local v2 = Vector2.new
		local ud2s = UDim2.fromScale
		local ud2o = UDim2.fromOffset
		local ud = UDim.new
		local max = math.max
		local new = Instance.new
		local TweenSize = new("Frame").TweenSize
		local ti = TweenInfo.new
		local delay = delay

		local function ripple(object, color)
			local circle = new('Frame')
			circle.BackgroundColor3 = color
			circle.BackgroundTransparency = 0.75
			circle.BorderSizePixel = 0
			circle.AnchorPoint = v2(0.5, 0.5)
			circle.Size = ud2o()
			circle.Position = ud2s(0.5, 0.5)
			circle.Parent = object
			local rounding = new('UICorner')
			rounding.CornerRadius = ud(1)
			rounding.Parent = circle

			local abssz = object.AbsoluteSize
			local size = max(abssz.X, abssz.Y) * 5/3

			TweenSize(circle, ud2o(size, size), "Out", "Quart", 0.4)
			service.TweenService:Create(circle, ti(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

			service.Debris:AddItem(circle, 0.4)
		end

		local function initGui(self,frame)
			local checkbox = frame or create({
				{1,"ImageButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Checkbox",Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,16,0,16),}},
				{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ripples",Parent={1},Size=UDim2.new(1,0,1,0),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.10196078568697,0.10196078568697,0.10196078568697),BorderSizePixel=0,Name="outline",Parent={1},Size=UDim2.new(0,16,0,16),}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="filler",Parent={3},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,14,0,14),}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="top",Parent={4},Size=UDim2.new(0,16,0,0),}},
				{6,"Frame",{AnchorPoint=Vector2.new(0,1),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="bottom",Parent={4},Position=UDim2.new(0,0,0,14),Size=UDim2.new(0,16,0,0),}},
				{7,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="left",Parent={4},Size=UDim2.new(0,0,0,16),}},
				{8,"Frame",{AnchorPoint=Vector2.new(1,0),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="right",Parent={4},Position=UDim2.new(0,14,0,0),Size=UDim2.new(0,0,0,16),}},
				{9,"Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Name="checkmark",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,0,0,20),}},
				{10,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6234266378",Parent={9},Position=UDim2.new(0.5,0,0.5,0),ScaleType=3,Size=UDim2.new(0,15,0,11),}},
				{11,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6401617475",ImageColor3=Color3.new(0.20784313976765,0.69803923368454,0.98431372642517),Name="checkmark2",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,12,0,12),Visible=false,}},
				{12,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6425281788",ImageTransparency=0.20000000298023,Name="middle",Parent={4},ScaleType=2,Size=UDim2.new(1,0,1,0),TileSize=UDim2.new(0,2,0,2),Visible=false,}},
				{13,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
			})
			local outline = checkbox.outline
			local filler = outline.filler
			local checkmark = filler.checkmark
			local ripples_container = checkbox.ripples

			-- walls
			local top, bottom, left, right = filler.top, filler.bottom, filler.left, filler.right

			self.Gui = checkbox
			self.GuiElems = {
				Top = top,
				Bottom = bottom,
				Left = left,
				Right = right,
				Outline = outline,
				Filler = filler,
				Checkmark = checkmark,
				Checkmark2 = filler.checkmark2,
				Middle = filler.middle
			}
	
			-- New:
			--[[checkbox.Activated:Connect(function()
				if Lib.CheckMouseInGui(checkbox) then
					if self.Style == 0 then
						ripple(ripples_container, self.Disabled and self.Colors.Disabled or self.Colors.Primary)
					end

					if not self.Disabled then
						self:SetState(not self.Toggled,true)
					else
						self:Paint()
					end

					self.OnInput:Fire()
				end
			end)]]
			
			-- Best input compatibility:
			checkbox.MouseButton1Up:Connect(function()
				if Lib.CheckMouseInGui(checkbox) then
					if self.Style == 0 then
						ripple(ripples_container, self.Disabled and self.Colors.Disabled or self.Colors.Primary)
					end

					if not self.Disabled then
						self:SetState(not self.Toggled,true)
					else
						self:Paint()
					end

					self.OnInput:Fire()
				end
			end)

			-- Old:
			--[[checkbox.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					local release
					release = service.UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							release:Disconnect()

							if Lib.CheckMouseInGui(checkbox) then
								if self.Style == 0 then
									ripple(ripples_container, self.Disabled and self.Colors.Disabled or self.Colors.Primary)
								end

								if not self.Disabled then
									self:SetState(not self.Toggled,true)
								else
									self:Paint()
								end
								
								self.OnInput:Fire()
							end
						end
					end)
				end
			end)]]

			self:Paint()
		end

		funcs.Collapse = function(self,anim)
			local guiElems = self.GuiElems
			if anim then
				TweenSize(guiElems.Top, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Bottom, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Left, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Right, ud2o(14, 14), "In", "Quart", 4/15, true)
			else
				guiElems.Top.Size = ud2o(14, 14)
				guiElems.Bottom.Size = ud2o(14, 14)
				guiElems.Left.Size = ud2o(14, 14)
				guiElems.Right.Size = ud2o(14, 14)
			end
		end

		funcs.Expand = function(self,anim)
			local guiElems = self.GuiElems
			if anim then
				TweenSize(guiElems.Top, ud2o(14, 0), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Bottom, ud2o(14, 0), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Left, ud2o(0, 14), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Right, ud2o(0, 14), "InOut", "Quart", 4/15, true)
			else
				guiElems.Top.Size = ud2o(14, 0)
				guiElems.Bottom.Size = ud2o(14, 0)
				guiElems.Left.Size = ud2o(0, 14)
				guiElems.Right.Size = ud2o(0, 14)
			end
		end

		funcs.Paint = function(self)
			local guiElems = self.GuiElems

			if self.Style == 0 then
				local color_base = self.Disabled and self.Colors.Disabled
				guiElems.Outline.BackgroundColor3 = color_base or (self.Toggled and self.Colors.Primary) or self.Colors.Secondary
				local walls_color = color_base or self.Colors.Primary
				guiElems.Top.BackgroundColor3 = walls_color
				guiElems.Bottom.BackgroundColor3 = walls_color
				guiElems.Left.BackgroundColor3 = walls_color
				guiElems.Right.BackgroundColor3 = walls_color
			else
				guiElems.Outline.BackgroundColor3 = self.Disabled and self.Colors.Disabled or self.Colors.Secondary
				guiElems.Filler.BackgroundColor3 = self.Disabled and self.Colors.DisabledBackground or self.Colors.Background
				guiElems.Checkmark2.ImageColor3 = self.Disabled and self.Colors.DisabledCheck or self.Colors.Primary
			end
		end

		funcs.SetState = function(self,val,anim)
			self.Toggled = val

			if self.OutlineColorTween then self.OutlineColorTween:Cancel() end
			local setStateTime = tick()
			self.LastSetStateTime = setStateTime

			if self.Toggled then
				if self.Style == 0 then
					if anim then
						self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {BackgroundColor3 = self.Colors.Primary})
						self.OutlineColorTween:Play()
						delay(0.15, function()
							if setStateTime ~= self.LastSetStateTime then return end
							self:Paint()
							TweenSize(self.GuiElems.Checkmark, ud2o(14, 20), "Out", "Bounce", 2/15, true)
						end)
					else
						self.GuiElems.Outline.BackgroundColor3 = self.Colors.Primary
						self:Paint()
						self.GuiElems.Checkmark.Size = ud2o(14, 20)
					end
					self:Collapse(anim)
				else
					self:Paint()
					self.GuiElems.Checkmark2.Visible = true
					self.GuiElems.Middle.Visible = false
				end
			else
				if self.Style == 0 then
					if anim then
						self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {BackgroundColor3 = self.Colors.Secondary})
						self.OutlineColorTween:Play()
						delay(0.15, function()
							if setStateTime ~= self.LastSetStateTime then return end
							self:Paint()
							TweenSize(self.GuiElems.Checkmark, ud2o(0, 20), "Out", "Quad", 1/15, true)
						end)
					else
						self.GuiElems.Outline.BackgroundColor3 = self.Colors.Secondary
						self:Paint()
						self.GuiElems.Checkmark.Size = ud2o(0, 20)
					end
					self:Expand(anim)
				else
					self:Paint()
					self.GuiElems.Checkmark2.Visible = false
					self.GuiElems.Middle.Visible = self.Toggled == nil
				end
			end
		end

		local mt = {__index = funcs}

		local function new(style)
			local obj = setmetatable({
				Toggled = false,
				Disabled = false,
				OnInput = Lib.Signal.new(),
				Style = style or 0,
				Colors = {
					Background = c3(36,36,36),
					Primary = c3(49,176,230),
					Secondary = c3(25,25,25),
					Disabled = c3(64,64,64),
					DisabledBackground = c3(52,52,52),
					DisabledCheck = c3(80,80,80)
				}
			},mt)
			initGui(obj)
			return obj
		end

		local function fromFrame(frame)
			local obj = setmetatable({
				Toggled = false,
				Disabled = false,
				Colors = {
					Background = c3(36,36,36),
					Primary = c3(49,176,230),
					Secondary = c3(25,25,25),
					Disabled = c3(64,64,64),
					DisabledBackground = c3(52,52,52)
				}
			},mt)
			initGui(obj,frame)
			return obj
		end

		return {new = new, fromFrame}
	end)()

	Lib.BrickColorPicker = (function()
		local funcs = {}
		local paletteCount = 0
		local mouse = service.Players.LocalPlayer:GetMouse()
		local hexStartX = 4
		local hexSizeX = 27
		local hexTriangleStart = 1
		local hexTriangleSize = 8

		local bottomColors = {
			Color3.fromRGB(17,17,17),
			Color3.fromRGB(99,95,98),
			Color3.fromRGB(163,162,165),
			Color3.fromRGB(205,205,205),
			Color3.fromRGB(223,223,222),
			Color3.fromRGB(237,234,234),
			Color3.fromRGB(27,42,53),
			Color3.fromRGB(91,93,105),
			Color3.fromRGB(159,161,172),
			Color3.fromRGB(202,203,209),
			Color3.fromRGB(231,231,236),
			Color3.fromRGB(248,248,248)
		}

		local function isMouseInHexagon(hex, touchPos)
			local relativeX = touchPos.X - hex.AbsolutePosition.X
			local relativeY = touchPos.Y - hex.AbsolutePosition.Y
			if relativeX >= hexStartX and relativeX < hexStartX + hexSizeX then
				relativeX = relativeX - 4
				local relativeWidth = (13 - math.min(relativeX, 26 - relativeX)) / 13
				if relativeY >= hexTriangleStart + hexTriangleSize * relativeWidth and relativeY < hex.AbsoluteSize.Y - hexTriangleStart - hexTriangleSize * relativeWidth then
					return true
				end
			end
			return false
		end

		local function hexInput(self, hex, color)
			hex.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if isMouseInHexagon(hex, input.Position) then
						self.OnSelect:Fire(color)
						self:Close()
					end
				end
			end)

			hex.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					if isMouseInHexagon(hex, input.Position) then
						self.OnPreview:Fire(color)
					end
				end
			end)
		end

		local function createGui(self)
			local gui = create({
				{1,"ScreenGui",{Name="BrickColor",}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,337,0,380),}},
				{3,"TextButton",{BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="MoreColors",Parent={2},Position=UDim2.new(0,5,1,-30),Size=UDim2.new(1,-10,0,25),Text="More Colors",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{4,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1281023007",ImageColor3=Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Name="Hex",Parent={2},Size=UDim2.new(0,35,0,35),Visible=false,}},
			})
			local colorFrame = gui.Frame
			local hex = colorFrame.Hex

			for row = 1,13 do
				local columns = math.min(row,14-row)+6
				for column = 1,columns do
					local nextColor = BrickColor.palette(paletteCount).Color
					local newHex = hex:Clone()
					newHex.Position = UDim2.new(0, (column-1)*25-(columns-7)*13+3*26 + 1, 0, (row-1)*23 + 4)
					newHex.ImageColor3 = nextColor
					newHex.Visible = true
					hexInput(self,newHex,nextColor)
					newHex.Parent = colorFrame
					paletteCount = paletteCount + 1
				end
			end

			for column = 1,12 do
				local nextColor = bottomColors[column]
				local newHex = hex:Clone()
				newHex.Position = UDim2.new(0, (column-1)*25-(12-7)*13+3*26 + 3, 0, 308)
				newHex.ImageColor3 = nextColor
				newHex.Visible = true
				hexInput(self,newHex,nextColor)
				newHex.Parent = colorFrame
				paletteCount = paletteCount + 1
			end

			colorFrame.MoreColors.MouseButton1Click:Connect(function()
				self.OnMoreColors:Fire()
				self:Close()
			end)

			self.Gui = gui
		end

		funcs.SetMoreColorsVisible = function(self,vis)
			local colorFrame = self.Gui.Frame
			colorFrame.Size = UDim2.new(0,337,0,380 - (not vis and 33 or 0))
			colorFrame.MoreColors.Visible = vis
		end

		funcs.Show = function(self,x,y,prevColor)
			self.PrevColor = prevColor or self.PrevColor

			local reverseY = false

			local x,y = x or mouse.X, y or mouse.Y
			local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY
			Lib.ShowGui(self.Gui)
			local sizeX,sizeY = self.Gui.Frame.AbsoluteSize.X,self.Gui.Frame.AbsoluteSize.Y

			if x + sizeX > maxX then x = self.ReverseX and x - sizeX or maxX - sizeX end
			if y + sizeY > maxY then reverseY = true end

			local closable = false
			if self.CloseEvent then self.CloseEvent:Disconnect() end

			self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if not closable or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then
					return
				end

				if not Lib.CheckMouseInGui(self.Gui.Frame) then
					self.CloseEvent:Disconnect()
					self:Close()
				end
			end)


			if reverseY then
				local newY = y - sizeY - (self.ReverseYOffset or 0)
				y = newY >= 0 and newY or 0
			end

			self.Gui.Frame.Position = UDim2.new(0,x,0,y)

			Lib.FastWait()
			closable = true
		end

		funcs.Close = function(self)
			self.Gui.Parent = nil
			self.OnCancel:Fire()
		end

		local mt = {__index = funcs}

		local function new()
			local obj = setmetatable({
				OnPreview = Lib.Signal.new(),
				OnSelect = Lib.Signal.new(),
				OnCancel = Lib.Signal.new(),
				OnMoreColors = Lib.Signal.new(),
				PrevColor = Color3.new(0,0,0)
			}, mt)
			createGui(obj)
			return obj
		end

		return {new = new}
	end)()

	Lib.ColorPicker = (function() -- TODO: Convert to newer class model
		local funcs = {}

		local function new()
			local newMt = setmetatable({},{})

			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()

			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="BasicColors",Parent={1},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,180,0,200),}},
				{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,-5),Size=UDim2.new(1,0,0,26),Text="Basic Colors",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Blue",Parent={1},Position=UDim2.new(1,-63,0,255),Size=UDim2.new(0,52,0,16),}},
				{5,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={4},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{6,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={5},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={6},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{8,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={7},Size=UDim2.new(0,16,0,8),}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{10,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{11,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={6},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{13,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={12},Size=UDim2.new(0,16,0,8),}},
				{14,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{15,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={4},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Blue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,ClipsDescendants=true,Name="ColorSpaceFrame",Parent={1},Position=UDim2.new(1,-261,0,4),Size=UDim2.new(0,222,0,202),}},
				{19,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),BorderSizePixel=0,Image="rbxassetid://1072518406",Name="ColorSpace",Parent={18},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,220,0,200),}},
				{20,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Scope",Parent={19},Position=UDim2.new(0,210,0,190),Size=UDim2.new(0,20,0,20),}},
				{21,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,9,0,0),Size=UDim2.new(0,2,0,20),}},
				{22,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,0,0,9),Size=UDim2.new(0,20,0,2),}},
				{23,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="CustomColors",Parent={1},Position=UDim2.new(0,5,0,210),Size=UDim2.new(0,180,0,90),}},
				{24,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={23},Size=UDim2.new(1,0,0,20),Text="Custom Colors (RC = Set)",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{25,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Green",Parent={1},Position=UDim2.new(1,-63,0,233),Size=UDim2.new(0,52,0,16),}},
				{26,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={25},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{27,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={26},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{28,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={27},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{29,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={28},Size=UDim2.new(0,16,0,8),}},
				{30,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{31,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{32,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{33,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={27},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{34,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={33},Size=UDim2.new(0,16,0,8),}},
				{35,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{36,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{37,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={25},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Green:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{39,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Hue",Parent={1},Position=UDim2.new(1,-180,0,211),Size=UDim2.new(0,52,0,16),}},
				{40,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={39},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{41,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={40},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{42,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={41},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{43,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={42},Size=UDim2.new(0,16,0,8),}},
				{44,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{45,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{46,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{47,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={41},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{48,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={47},Size=UDim2.new(0,16,0,8),}},
				{49,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{50,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{51,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={39},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Hue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{53,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="Preview",Parent={1},Position=UDim2.new(1,-260,0,211),Size=UDim2.new(0,35,1,-245),}},
				{54,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Red",Parent={1},Position=UDim2.new(1,-63,0,211),Size=UDim2.new(0,52,0,16),}},
				{55,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={54},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{56,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={55},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{57,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={56},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{58,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={57},Size=UDim2.new(0,16,0,8),}},
				{59,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{60,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{61,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{62,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={56},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{63,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={62},Size=UDim2.new(0,16,0,8),}},
				{64,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{65,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{66,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Red:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{68,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Sat",Parent={1},Position=UDim2.new(1,-180,0,233),Size=UDim2.new(0,52,0,16),}},
				{69,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={68},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{70,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={69},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{71,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={70},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{72,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={71},Size=UDim2.new(0,16,0,8),}},
				{73,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{74,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{75,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{76,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={70},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{77,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={76},Size=UDim2.new(0,16,0,8),}},
				{78,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{79,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{80,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={68},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Sat:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{82,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Val",Parent={1},Position=UDim2.new(1,-180,0,255),Size=UDim2.new(0,52,0,16),}},
				{83,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={82},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="255",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={83},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{85,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={84},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{86,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={85},Size=UDim2.new(0,16,0,8),}},
				{87,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{88,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{89,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{90,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={84},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{91,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={90},Size=UDim2.new(0,16,0,8),}},
				{92,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{93,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{94,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={82},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Val:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{96,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Cancel",Parent={1},Position=UDim2.new(1,-105,1,-28),Size=UDim2.new(0,100,0,25),Text="Cancel",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{97,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Ok",Parent={1},Position=UDim2.new(1,-210,1,-28),Size=UDim2.new(0,100,0,25),Text="OK",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{98,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Image="rbxassetid://1072518502",Name="ColorStrip",Parent={1},Position=UDim2.new(1,-30,0,5),Size=UDim2.new(0,13,0,200),}},
				{99,"Frame",{BackgroundColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={1},Position=UDim2.new(1,-16,0,1),Size=UDim2.new(0,5,0,208),}},
				{100,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={99},Position=UDim2.new(0,-2,0,-4),Size=UDim2.new(0,8,0,16),}},
				{101,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,2,0,8),Size=UDim2.new(0,1,0,1),}},
				{102,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,3,0,7),Size=UDim2.new(0,1,0,3),}},
				{103,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,4,0,6),Size=UDim2.new(0,1,0,5),}},
				{104,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,1,0,7),}},
				{105,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,6,0,4),Size=UDim2.new(0,1,0,9),}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window.Alignable = false
			window:SetTitle("Color Picker")
			window:Resize(450,330)
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			newMt.Window = window
			newMt.Gui = window.Gui
			local pickerGui = window.Gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
			local colorStrip = pickerFrame.ColorStrip
			local previewFrame = pickerFrame.Preview
			local basicColorsFrame = pickerFrame.BasicColors
			local customColorsFrame = pickerFrame.CustomColors
			local okButton = pickerFrame.Ok
			local cancelButton = pickerFrame.Cancel
			local closeButton = pickerTopBar.Close

			local colorScope = colorSpace.Scope
			local colorArrow = pickerFrame.ArrowFrame.Arrow

			local hueInput = pickerFrame.Hue.Input
			local satInput = pickerFrame.Sat.Input
			local valInput = pickerFrame.Val.Input

			local redInput = pickerFrame.Red.Input
			local greenInput = pickerFrame.Green.Input
			local blueInput = pickerFrame.Blue.Input

			local user = service.UserInputService
			local mouse = service.Players.LocalPlayer:GetMouse()

			local hue,sat,val = 0,0,1
			local red,green,blue = 1,1,1
			local chosenColor = Color3.new(0,0,0)

			local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
			local customColors = {}

			local function updateColor(noupdate)
				local relativeX, relativeY, relativeStripY = 219 - hue * 219, 199 - sat * 199, 199 - val * 199
				local hsvColor = Color3.fromHSV(hue, sat, val)

				if noupdate == 2 or not noupdate then
					hueInput.Text = tostring(math.ceil(359 * hue))
					satInput.Text = tostring(math.ceil(255 * sat))
					valInput.Text = tostring(math.floor(255 * val))
				end
				if noupdate == 1 or not noupdate then
					redInput.Text = tostring(math.floor(255 * red))
					greenInput.Text = tostring(math.floor(255 * green))
					blueInput.Text = tostring(math.floor(255 * blue))
				end

				chosenColor = Color3.new(red, green, blue)
				colorScope.Position = UDim2.new(0, (relativeX - 9), 0, (relativeY - 9))
				colorStrip.ImageColor3 = Color3.fromHSV(hue, sat, 1)
				colorArrow.Position = UDim2.new(0, -2, 0, (relativeStripY - 4))
				previewFrame.BackgroundColor3 = chosenColor

				newMt.Color = chosenColor
				newMt.OnPreview:Fire(chosenColor)
			end

			local function handleInputBegan(input, updateFunc)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					while user:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						updateFunc()task.wait()
					end
				end
			end

			local function colorSpaceInput()
				local relativeX = mouse.X - colorSpace.AbsolutePosition.X
				local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

				if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
				if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

				hue = (219 - relativeX) / 219
				sat = (199 - relativeY) / 199

				local hsvColor = Color3.fromHSV(hue, sat, val)
				red, green, blue = hsvColor.R, hsvColor.G, hsvColor.B
				updateColor()
			end

			local function colorStripInput()
				local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

				if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

				val = (199 - relativeY) / 199

				local hsvColor = Color3.fromHSV(hue, sat, val)
				red, green, blue = hsvColor.R, hsvColor.G, hsvColor.B
				updateColor()
			end

			colorSpace.InputBegan:Connect(function(input) handleInputBegan(input, colorSpaceInput) end)
			colorStrip.InputBegan:Connect(function(input) handleInputBegan(input, colorStripInput) end)

			local function hookButtons(frame, func)
				frame.ArrowFrame.Up.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local releaseEvent, runEvent
						local startTime = tick()
						local pressing = true
						local startNum = tonumber(frame.Text)

						if not startNum then return end

						releaseEvent = user.InputEnded:Connect(function(endInput)
							if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								pressing = false
							end
						end)

						startNum = startNum + 1
						func(startNum)
						while pressing do
							if tick() - startTime > 0.3 then
								startNum = startNum + 1
								func(startNum)
								startTime = tick()
							end
							task.wait(0.1)
						end
					end
				end)

				frame.ArrowFrame.Down.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local releaseEvent, runEvent
						local startTime = tick()
						local pressing = true
						local startNum = tonumber(frame.Text)

						if not startNum then return end

						releaseEvent = user.InputEnded:Connect(function(endInput)
							if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								pressing = false
							end
						end)

						startNum = startNum - 1
						func(startNum)
						while pressing do
							if tick() - startTime > 0.3 then
								startNum = startNum - 1
								func(startNum)
								startTime = tick()
							end
							task.wait(0.1)
						end
					end
				end)
			end

			--[[local function UpdateBox(TextBox, Value, IsHSV, ...)
				local number = tonumber(TextBox.Text)
				if number then
					number = math.clamp(math.floor(number), 0, Value) / Value
					local HSV = Color3.fromHSV(func(number))
					red, green, blue = HSV.R, HSV.G, HSV.B
					
					TextBox.Text = tostring(number):sub(4)
					updateColor(IsHSV)
				end
			end]]

			local function updateHue(str)
				local num = tonumber(str)
				if num then
					hue = math.clamp(math.floor(num),0,359)/359
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					hueInput.Text = tostring(hue*359)
					updateColor(1)
				end
			end
			hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput, hueInput)

			local function updateSat(str)
				local num = tonumber(str)
				if num then
					sat = math.clamp(math.floor(num),0,255)/255
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
					satInput.Text = tostring(sat*255)
					updateColor(1)
				end
			end
			satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

			local function updateVal(str)
				local num = tonumber(str)
				if num then
					val = math.clamp(math.floor(num),0,255)/255
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
					valInput.Text = tostring(val*255)
					updateColor(1)
				end
			end
			valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

			local function updateRed(str)
				local num = tonumber(str)
				if num then
					red = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					redInput.Text = tostring(red*255)
					updateColor(2)
				end
			end
			redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

			local function updateGreen(str)
				local num = tonumber(str)
				if num then
					green = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					greenInput.Text = tostring(green*255)
					updateColor(2)
				end
			end
			greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

			local function updateBlue(str)
				local num = tonumber(str)
				if num then
					blue = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					blueInput.Text = tostring(blue*255)
					updateColor(2)
				end
			end
			blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

			local colorChoice = Instance.new("TextButton")
			colorChoice.Name = "Choice"
			colorChoice.Size = UDim2.new(0,25,0,18)
			colorChoice.BorderColor3 = Color3.fromRGB(55,55,55)
			colorChoice.Text = ""
			colorChoice.AutoButtonColor = false

			local row = 0
			local column = 0
			for i,v in pairs(basicColors) do
				local newColor = colorChoice:Clone()
				newColor.BackgroundColor3 = v
				newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

				newColor.MouseButton1Click:Connect(function()
					red,green,blue = v.r,v.g,v.b
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					updateColor()
				end)

				newColor.Parent = basicColorsFrame
				column = column + 1
				if column == 6 then row = row + 1 column = 0 end
			end

			row = 0
			column = 0
			for i = 1,12 do
				local color = customColors[i] or Color3.new(0,0,0)
				local newColor = colorChoice:Clone()
				newColor.BackgroundColor3 = color
				newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

				newColor.MouseButton1Click:Connect(function()
					local curColor = customColors[i] or Color3.new(0,0,0)
					red,green,blue = curColor.r,curColor.g,curColor.b
					hue,sat,val = Color3.toHSV(curColor)
					updateColor()
				end)

				newColor.MouseButton2Click:Connect(function()
					customColors[i] = chosenColor
					newColor.BackgroundColor3 = chosenColor
				end)

				newColor.Parent = customColorsFrame
				column = column + 1
				if column == 6 then row = row + 1 column = 0 end
			end

			okButton.MouseButton1Click:Connect(function() newMt.OnSelect:Fire(chosenColor) window:Close() end)
			okButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then okButton.BackgroundTransparency = 0.4 end end)
			okButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then okButton.BackgroundTransparency = 0 end end)


			cancelButton.MouseButton1Click:Connect(function() newMt.OnCancel:Fire() window:Close() end)
			cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then cancelButton.BackgroundTransparency = 0.4 end end)
			cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then cancelButton.BackgroundTransparency = 0 end end)

			updateColor()

			newMt.SetColor = function(self,color)
				red,green,blue = color.r,color.g,color.b
				hue,sat,val = Color3.toHSV(color)
				updateColor()
			end

			newMt.Show = function(self)
				self.Window:Show()
			end

			return newMt
		end

		return {new = new}
	end)()

	Lib.NumberSequenceEditor = (function()
		local function new() -- TODO: Convert to newer class model
			local newMt = setmetatable({},{})
			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()

			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,210),Size=UDim2.new(0,60,0,20),}},
				{3,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={2},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{4,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{5,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,210),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{6,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,210),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,380,0,210),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{8,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="NumberLineOutlines",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Name="NumberLine",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
				{10,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Value",Parent={1},Position=UDim2.new(0,170,0,210),Size=UDim2.new(0,60,0,20),}},
				{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Value",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{12,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={10},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{13,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Envelope",Parent={1},Position=UDim2.new(0,300,0,210),Size=UDim2.new(0,60,0,20),}},
				{14,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={13},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={13},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Envelope",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window:Resize(680,265)
			window:SetTitle("NumberSequence Editor")
			newMt.Window = window
			newMt.Gui = window.Gui
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			local gui = window.Gui
			local pickerGui = gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local numberLine = pickerFrame.NumberLine
			local numberLineOutlines = pickerFrame.NumberLineOutlines
			local timeBox = pickerFrame.Time.Input
			local valueBox = pickerFrame.Value.Input
			local envelopeBox = pickerFrame.Envelope.Input
			local deleteButton = pickerFrame.Delete
			local resetButton = pickerFrame.Reset
			local closeButton = pickerFrame.Close
			local topClose = pickerTopBar.Close

			local points = {{1,0,3},{8,0.05,1},{5,0.6,2},{4,0.7,4},{6,1,4}}
			local lines = {}
			local eLines = {}
			local beginPoint = points[1]
			local endPoint = points[#points]
			local currentlySelected = nil
			local currentPoint = nil
			local resetSequence = nil

			local user = service.UserInputService
			local mouse = service.Players.LocalPlayer:GetMouse()

			for i = 2,10 do
				local newLine = Instance.new("Frame")
				newLine.BackgroundTransparency = 0.5
				newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
				newLine.BorderSizePixel = 0
				newLine.Size = UDim2.new(0,1,1,0)
				newLine.Position = UDim2.new((i-1)/(11-1),0,0,0)
				newLine.Parent = numberLineOutlines
			end

			for i = 2,4 do
				local newLine = Instance.new("Frame")
				newLine.BackgroundTransparency = 0.5
				newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
				newLine.BorderSizePixel = 0
				newLine.Size = UDim2.new(1,0,0,1)
				newLine.Position = UDim2.new(0,0,(i-1)/(5-1),0)
				newLine.Parent = numberLineOutlines
			end

			local lineTemp = Instance.new("Frame")
			lineTemp.BackgroundColor3 = Color3.new(0,0,0)
			lineTemp.BorderSizePixel = 0
			lineTemp.Size = UDim2.new(0,1,0,1)

			local sequenceLine = Instance.new("Frame")
			sequenceLine.BackgroundColor3 = Color3.new(0,0,0)
			sequenceLine.BorderSizePixel = 0
			sequenceLine.Size = UDim2.new(0,1,0,0)

			for i = 1,numberLine.AbsoluteSize.X do
				local line = sequenceLine:Clone()
				eLines[i] = line
				line.Name = "E"..tostring(i)
				line.BackgroundTransparency = 0.5
				line.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
				line.Position = UDim2.new(0,i-1,0,0)
				line.Parent = numberLine
			end

			for i = 1,numberLine.AbsoluteSize.X do
				local line = sequenceLine:Clone()
				lines[i] = line
				line.Name = tostring(i)
				line.Position = UDim2.new(0,i-1,0,0)
				line.Parent = numberLine
			end

			local envelopeDrag = Instance.new("Frame")
			envelopeDrag.BackgroundTransparency = 1
			envelopeDrag.BackgroundColor3 = Color3.new(0,0,0)
			envelopeDrag.BorderSizePixel = 0
			envelopeDrag.Size = UDim2.new(0,7,0,20)
			envelopeDrag.Visible = false
			envelopeDrag.ZIndex = 2
			local envelopeDragLine = Instance.new("Frame",envelopeDrag)
			envelopeDragLine.Name = "Line"
			envelopeDragLine.BackgroundColor3 = Color3.new(0,0,0)
			envelopeDragLine.BorderSizePixel = 0
			envelopeDragLine.Position = UDim2.new(0,3,0,0)
			envelopeDragLine.Size = UDim2.new(0,1,0,20)
			envelopeDragLine.ZIndex = 2

			local envelopeDragTop,envelopeDragBottom = envelopeDrag:Clone(),envelopeDrag:Clone()
			envelopeDragTop.Parent = numberLine
			envelopeDragBottom.Parent = numberLine

			local function buildSequence()
				local newPoints = {}
				for i,v in pairs(points) do
					table.insert(newPoints,NumberSequenceKeypoint.new(v[2],v[1],v[3]))
				end
				newMt.Sequence = NumberSequence.new(newPoints)
				newMt.OnSelect:Fire(newMt.Sequence)
			end

			local function round(num,places)
				local multi = 10^places
				return math.floor(num*multi + 0.5)/multi
			end

			local function updateInputs(point)
				if point then
					currentPoint = point
					local rawT,rawV,rawE = point[2],point[1],point[3]
					timeBox.Text = round(rawT,(rawT < 0.01 and 5) or (rawT < 0.1 and 4) or 3)
					valueBox.Text = round(rawV,(rawV < 0.01 and 5) or (rawV < 0.1 and 4) or (rawV < 1 and 3) or 2)
					envelopeBox.Text = round(rawE,(rawE < 0.01 and 5) or (rawE < 0.1 and 4) or (rawV < 1 and 3) or 2)

					local envelopeDistance = numberLine.AbsoluteSize.Y*(point[3]/10)
					envelopeDragTop.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset-envelopeDistance-17)
					envelopeDragTop.Visible = true
					envelopeDragBottom.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset+envelopeDistance+2)
					envelopeDragBottom.Visible = true
				end
			end

			envelopeDragTop.InputBegan:Connect(function(input)
				if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end

				local mouseEvent, releaseEvent
				local maxSize = numberLine.AbsoluteSize.Y
				local mouseDelta = math.abs(envelopeDragTop.AbsolutePosition.Y - mouse.Y)

				envelopeDragTop.Line.Position = UDim2.new(0, 2, 0, 0)
				envelopeDragTop.Line.Size = UDim2.new(0, 3, 0, 20)

				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
					mouseEvent:Disconnect()
					releaseEvent:Disconnect()
					envelopeDragTop.Line.Position = UDim2.new(0, 3, 0, 0)
					envelopeDragTop.Line.Size = UDim2.new(0, 1, 0, 20)
				end)

				mouseEvent = user.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						local topDiff = (currentPoint[4].AbsolutePosition.Y + 2) - (mouse.Y - mouseDelta) - 19
						local newEnvelope = 10 * (math.max(topDiff, 0) / maxSize)
						local maxEnvelope = math.min(currentPoint[1], 10 - currentPoint[1])
						currentPoint[3] = math.min(newEnvelope, maxEnvelope)
						newMt:Redraw()
						buildSequence()
						updateInputs(currentPoint)
					end
				end)
			end)

			envelopeDragBottom.InputBegan:Connect(function(input)
				if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end

				local mouseEvent, releaseEvent
				local maxSize = numberLine.AbsoluteSize.Y
				local mouseDelta = math.abs(envelopeDragBottom.AbsolutePosition.Y - mouse.Y)

				envelopeDragBottom.Line.Position = UDim2.new(0, 2, 0, 0)
				envelopeDragBottom.Line.Size = UDim2.new(0, 3, 0, 20)

				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
					mouseEvent:Disconnect()
					releaseEvent:Disconnect()
					envelopeDragBottom.Line.Position = UDim2.new(0, 3, 0, 0)
					envelopeDragBottom.Line.Size = UDim2.new(0, 1, 0, 20)
				end)

				mouseEvent = user.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						local bottomDiff = (mouse.Y + (20 - mouseDelta)) - (currentPoint[4].AbsolutePosition.Y + 2) - 19
						local newEnvelope = 10 * (math.max(bottomDiff, 0) / maxSize)
						local maxEnvelope = math.min(currentPoint[1], 10 - currentPoint[1])
						currentPoint[3] = math.min(newEnvelope, maxEnvelope)
						newMt:Redraw()
						buildSequence()
						updateInputs(currentPoint)
					end
				end)
			end)

			local function placePoint(point)
				local newPoint = Instance.new("Frame")
				newPoint.Name = "Point"
				newPoint.BorderSizePixel = 0
				newPoint.Size = UDim2.new(0,5,0,5)
				newPoint.Position = UDim2.new(0,math.floor((numberLine.AbsoluteSize.X-1) * point[2])-2,0,numberLine.AbsoluteSize.Y*(10-point[1])/10-2)
				newPoint.BackgroundColor3 = Color3.new(0,0,0)

				local newSelect = Instance.new("Frame")
				newSelect.Name = "Select"
				newSelect.BackgroundTransparency = 1
				newSelect.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
				newSelect.Position = UDim2.new(0,-2,0,-2)
				newSelect.Size = UDim2.new(0,9,0,9)
				newSelect.Parent = newPoint

				newPoint.Parent = numberLine


				newSelect.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						for i, v in pairs(points) do 
							v[4].Select.BackgroundTransparency = 1 
						end

						newSelect.BackgroundTransparency = 0
						updateInputs(point)
					end

					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not currentlySelected then
						currentPoint = point
						local mouseEvent, releaseEvent
						currentlySelected = true
						newSelect.BackgroundColor3 = Color3.new(249/255, 191/255, 59/255)

						local oldEnvelope = point[3]

						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then	return end

							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							currentlySelected = nil
							newSelect.BackgroundColor3 = Color3.new(199/255, 44/255, 28/255)
						end)

						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								local maxX = numberLine.AbsoluteSize.X - 1
								local relativeX = (input.Position.X - numberLine.AbsolutePosition.X)
								if relativeX < 0 then relativeX = 0 end
								if relativeX > maxX then relativeX = maxX end

								local maxY = numberLine.AbsoluteSize.Y - 1
								local relativeY = (input.Position.Y - numberLine.AbsolutePosition.Y)
								if relativeY < 0 then relativeY = 0 end
								if relativeY > maxY then relativeY = maxY end

								if point ~= beginPoint and point ~= endPoint then
									point[2] = relativeX / maxX
								end

								point[1] = 10 - (relativeY / maxY) * 10
								local maxEnvelope = math.min(point[1], 10 - point[1])
								point[3] = math.min(oldEnvelope, maxEnvelope)
								newMt:Redraw()
								updateInputs(point)

								for i, v in pairs(points) do 
									v[4].Select.BackgroundTransparency = 1 
								end

								newSelect.BackgroundTransparency = 0
								buildSequence()
							end
						end)
					end
				end)

				return newPoint
			end

			local function placePoints()
				for i,v in pairs(points) do
					v[4] = placePoint(v)
				end
			end

			local function redraw(self)
				local numberLineSize = numberLine.AbsoluteSize
				table.sort(points,function(a,b) return a[2] < b[2] end)
				for i,v in pairs(points) do
					v[4].Position = UDim2.new(0,math.floor((numberLineSize.X-1) * v[2])-2,0,(numberLineSize.Y-1)*(10-v[1])/10-2)
				end
				lines[1].Size = UDim2.new(0,1,0,0)
				for i = 1,#points-1 do
					local fromPoint = points[i]
					local toPoint = points[i+1]
					local deltaY = toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset
					local deltaX = toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset
					local slope = deltaY/deltaX

					local fromEnvelope = fromPoint[3]
					local nextEnvelope = toPoint[3]

					local currentRise = math.abs(slope)
					local totalRise = 0
					local maxRise = math.abs(toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset)

					for lineCount = math.min(fromPoint[4].Position.X.Offset+1,toPoint[4].Position.X.Offset),toPoint[4].Position.X.Offset do
						if deltaX == 0 and deltaY == 0 then return end
						local riseNow = math.floor(currentRise)
						local line = lines[lineCount+3]
						if line then
							if totalRise+riseNow > maxRise then riseNow = maxRise-totalRise end
							if math.sign(slope) == -1 then
								line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + -(totalRise+riseNow)+2)
							else
								line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + totalRise+2)
							end
							line.Size = UDim2.new(0,1,0,math.max(riseNow,1))
						end
						totalRise = totalRise + riseNow
						currentRise = currentRise - riseNow + math.abs(slope)

						local envPercent = (lineCount-fromPoint[4].Position.X.Offset)/(toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset)
						local envLerp = fromEnvelope+(nextEnvelope-fromEnvelope)*envPercent
						local relativeSize = (envLerp/10)*numberLineSize.Y						

						local line = eLines[lineCount + 3]
						if line then
							line.Position = UDim2.new(0,lineCount+2,0,lines[lineCount+3].Position.Y.Offset-math.floor(relativeSize))
							line.Size = UDim2.new(0,1,0,math.floor(relativeSize*2))
						end
					end
				end
			end
			newMt.Redraw = redraw



			local function loadSequence(self,seq)
				resetSequence = seq
				for i,v in pairs(points) do if v[4] then v[4]:Destroy() end end
				points = {}
				for i,v in pairs(seq.Keypoints) do
					local maxEnvelope = math.min(v.Value,10-v.Value)
					local newPoint = {v.Value,v.Time,math.min(v.Envelope,maxEnvelope)}
					newPoint[4] = placePoint(newPoint)
					table.insert(points,newPoint)
				end
				beginPoint = points[1]
				endPoint = points[#points]
				currentlySelected = nil
				redraw()
				envelopeDragTop.Visible = false
				envelopeDragBottom.Visible = false
			end
			newMt.SetSequence = loadSequence

			timeBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(timeBox.Text)
				if point and num and point ~= beginPoint and point ~= endPoint then
					num = math.clamp(num,0,1)
					point[2] = num
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)

			valueBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(valueBox.Text)
				if point and num then
					local oldEnvelope = point[3]
					num = math.clamp(num,0,10)
					point[1] = num
					local maxEnvelope = math.min(point[1],10-point[1])
					point[3] = math.min(oldEnvelope,maxEnvelope)
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)

			envelopeBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(envelopeBox.Text)
				if point and num then
					num = math.clamp(num,0,5)
					local maxEnvelope = math.min(point[1],10-point[1])
					point[3] = math.min(num,maxEnvelope)
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)

			local function buttonAnimations(button,inverse)
				button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
				button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 1 or 0) end end)
			end

			numberLine.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and #points < 20 then

					if Lib.CheckMouseInGui(envelopeDragTop) or Lib.CheckMouseInGui(envelopeDragBottom) then return end

					for i, v in pairs(points) do
						if Lib.CheckMouseInGui(v[4].Select) then
							return
						end
					end

					local maxX = numberLine.AbsoluteSize.X - 1
					local relativeX = (input.Position.X - numberLine.AbsolutePosition.X)
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxX then relativeX = maxX end

					local maxY = numberLine.AbsoluteSize.Y - 1
					local relativeY = (input.Position.Y - numberLine.AbsolutePosition.Y)
					if relativeY < 0 then relativeY = 0 end
					if relativeY > maxY then relativeY = maxY end

					local raw = relativeX / maxX
					local newPoint = {10 - (relativeY / maxY) * 10, raw, 0}
					newPoint[4] = placePoint(newPoint)
					table.insert(points, newPoint)
					redraw()
					buildSequence()
				end
			end)

			deleteButton.MouseButton1Click:Connect(function()
				if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
					for i,v in pairs(points) do
						if v == currentPoint then
							v[4]:Destroy()
							table.remove(points,i)
							break
						end
					end
					currentlySelected = nil
					redraw()
					buildSequence()
					updateInputs(points[1])
				end
			end)

			resetButton.MouseButton1Click:Connect(function()
				if resetSequence then
					newMt:SetSequence(resetSequence)
					buildSequence()
				end
			end)

			closeButton.MouseButton1Click:Connect(function()
				window:Close()
			end)

			buttonAnimations(deleteButton)
			buttonAnimations(resetButton)
			buttonAnimations(closeButton)

			placePoints()
			redraw()

			newMt.Show = function(self)
				window:Show()
			end

			return newMt
		end

		return {new = new}
	end)()

	Lib.ColorSequenceEditor = (function() -- TODO: Convert to newer class model
		local function new()
			local newMt = setmetatable({},{})
			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()
			newMt.OnPickColor = Lib.Signal.new()

			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorLine",Parent={1},Position=UDim2.new(0,10,0,5),Size=UDim2.new(1,-20,0,70),}},
				{3,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Gradient",Parent={2},Size=UDim2.new(1,0,1,0),}},
				{4,"UIGradient",{Parent={3},}},
				{5,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Arrows",Parent={1},Position=UDim2.new(0,1,0,73),Size=UDim2.new(1,-2,0,16),}},
				{6,"Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0,Name="Cursor",Parent={1},Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,1,0,80),}},
				{7,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,95),Size=UDim2.new(0,100,0,20),}},
				{8,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={7},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,98,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{9,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={7},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{10,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorBox",Parent={1},Position=UDim2.new(0,220,0,95),Size=UDim2.new(0,20,0,20),}},
				{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Color",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,95),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,95),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{14,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,280,0,95),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{15,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={1},Size=UDim2.new(0,16,0,16),Visible=false,}},
				{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,2),}},
				{17,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,7,0,5),Size=UDim2.new(0,3,0,2),}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,2),}},
				{19,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,5,0,9),Size=UDim2.new(0,7,0,2),}},
				{20,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,4,0,11),Size=UDim2.new(0,9,0,2),}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window:Resize(650,150)
			window:SetTitle("ColorSequence Editor")
			newMt.Window = window
			newMt.Gui = window.Gui
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			local gui = window.Gui
			local pickerGui = gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local colorLine = pickerFrame.ColorLine
			local gradient = colorLine.Gradient.UIGradient
			local arrowFrame = pickerFrame.Arrows
			local arrow = pickerFrame.Arrow
			local cursor = pickerFrame.Cursor
			local timeBox = pickerFrame.Time.Input
			local colorBox = pickerFrame.ColorBox
			local deleteButton = pickerFrame.Delete
			local resetButton = pickerFrame.Reset
			local closeButton = pickerFrame.Close
			local topClose = pickerTopBar.Close

			local user = service.UserInputService
			local mouse = service.Players.LocalPlayer:GetMouse()

			local colors = {{Color3.new(1,0,1),0},{Color3.new(0.2,0.9,0.2),0.2},{Color3.new(0.4,0.5,0.9),0.7},{Color3.new(0.6,1,1),1}}
			local resetSequence = nil

			local beginPoint = colors[1]
			local endPoint = colors[#colors]

			local currentlySelected = nil
			local currentPoint = nil

			local sequenceLine = Instance.new("Frame")
			sequenceLine.BorderSizePixel = 0
			sequenceLine.Size = UDim2.new(0,1,1,0)

			newMt.Sequence = ColorSequence.new(Color3.new(1,1,1))
			local function buildSequence(noupdate)
				local newPoints = {}
				table.sort(colors,function(a,b) return a[2] < b[2] end)
				for i,v in pairs(colors) do
					table.insert(newPoints,ColorSequenceKeypoint.new(v[2],v[1]))
				end
				newMt.Sequence = ColorSequence.new(newPoints)
				if not noupdate then newMt.OnSelect:Fire(newMt.Sequence) end
			end

			local function round(num,places)
				local multi = 10^places
				return math.floor(num*multi + 0.5)/multi
			end

			local function updateInputs(point)
				if point then
					currentPoint = point
					local raw = point[2]
					timeBox.Text = round(raw,(raw < 0.01 and 5) or (raw < 0.1 and 4) or 3)
					colorBox.BackgroundColor3 = point[1]
				end
			end

			local function placeArrow(ind,point)
				local newArrow = arrow:Clone()
				newArrow.Position = UDim2.new(0,ind-1,0,0)
				newArrow.Visible = true
				newArrow.Parent = arrowFrame

				newArrow.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						cursor.Visible = true
						cursor.Position = UDim2.new(0, 9 + newArrow.Position.X.Offset, 0, 0)
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						updateInputs(point)
						if point == beginPoint or point == endPoint or currentlySelected then return end

						local mouseEvent, releaseEvent
						currentlySelected = true

						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							currentlySelected = nil
							cursor.Visible = false
						end)

						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								local maxSize = colorLine.AbsoluteSize.X - 1
								local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
								if relativeX < 0 then relativeX = 0 end
								if relativeX > maxSize then relativeX = maxSize end
								local raw = relativeX / maxSize
								point[2] = relativeX / maxSize
								updateInputs(point)
								cursor.Visible = true
								cursor.Position = UDim2.new(0, 9 + newArrow.Position.X.Offset, 0, 0)
								buildSequence()
								newMt:Redraw()
							end
						end)
					end
				end)

				newArrow.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						cursor.Visible = false
					end
				end)



				return newArrow
			end

			local function placeArrows()
				for i,v in pairs(colors) do
					v[3] = placeArrow(math.floor((colorLine.AbsoluteSize.X-1) * v[2]) + 1,v)
				end
			end

			local function redraw(self)
				gradient.Color = newMt.Sequence or ColorSequence.new(Color3.new(1,1,1))

				for i = 2,#colors do
					local nextColor = colors[i]
					local endPos = math.floor((colorLine.AbsoluteSize.X-1) * nextColor[2]) + 1
					nextColor[3].Position = UDim2.new(0,endPos,0,0)
				end		
			end
			newMt.Redraw = redraw

			local function loadSequence(self,seq)
				resetSequence = seq
				for i,v in pairs(colors) do if v[3] then v[3]:Destroy() end end
				colors = {}
				currentlySelected = nil
				for i,v in pairs(seq.Keypoints) do
					local newPoint = {v.Value,v.Time}
					newPoint[3] = placeArrow(v.Time,newPoint)
					table.insert(colors,newPoint)
				end
				beginPoint = colors[1]
				endPoint = colors[#colors]
				currentlySelected = nil
				updateInputs(colors[1])
				buildSequence(true)
				redraw()
			end
			newMt.SetSequence = loadSequence

			local function buttonAnimations(button,inverse)
				button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
				button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 1 or 0) end end)
			end

			colorLine.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and #colors < 20 then
					local maxSize = colorLine.AbsoluteSize.X - 1
					local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxSize then relativeX = maxSize end

					local raw = relativeX / maxSize
					local fromColor = nil
					local toColor = nil
					for i, col in pairs(colors) do
						if col[2] >= raw then
							fromColor = colors[math.max(i - 1, 1)]
							toColor = colors[i]
							break
						end
					end
					local lerpColor = fromColor[1]:lerp(toColor[1], (raw - fromColor[2]) / (toColor[2] - fromColor[2]))
					local newPoint = {lerpColor, raw}
					newPoint[3] = placeArrow(newPoint[2], newPoint)
					table.insert(colors, newPoint)
					updateInputs(newPoint)
					buildSequence()
					redraw()
				end
			end)

			colorLine.InputChanged:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local maxSize = colorLine.AbsoluteSize.X - 1
					local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxSize then relativeX = maxSize end
					cursor.Visible = true
					cursor.Position = UDim2.new(0, 10 + relativeX, 0, 0)
				end
			end)

			colorLine.InputEnded:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local inArrow = false
					for i, v in pairs(colors) do
						if Lib.CheckMouseInGui(v[3]) then
							inArrow = v[3]
						end
					end
					cursor.Visible = inArrow and true or false
					if inArrow then cursor.Position = UDim2.new(0, 9 + inArrow.Position.X.Offset, 0, 0) end
				end
			end)

			timeBox:GetPropertyChangedSignal("Text"):Connect(function()
				local point = currentPoint
				local num = tonumber(timeBox.Text)
				if point and num and point ~= beginPoint and point ~= endPoint then
					num = math.clamp(num,0,1)
					point[2] = num
					buildSequence()
					redraw()
				end
			end)

			colorBox.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					local editor = newMt.ColorPicker
					if not editor then
						editor = Lib.ColorPicker.new()
						editor.Window:SetTitle("ColorSequence Color Picker")

						editor.OnSelect:Connect(function(col)
							if currentPoint then
								currentPoint[1] = col
							end
							buildSequence()
							redraw()
						end)

						newMt.ColorPicker = editor
					end

					editor.Window:ShowAndFocus()
				end
			end)

			deleteButton.MouseButton1Click:Connect(function()
				if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
					for i,v in pairs(colors) do
						if v == currentPoint then
							v[3]:Destroy()
							table.remove(colors,i)
							break
						end
					end
					currentlySelected = nil
					updateInputs(colors[1])
					buildSequence()
					redraw()
				end
			end)

			resetButton.MouseButton1Click:Connect(function()
				if resetSequence then
					newMt:SetSequence(resetSequence)
				end
			end)

			closeButton.MouseButton1Click:Connect(function()
				window:Close()
			end)

			topClose.MouseButton1Click:Connect(function()
				window:Close()
			end)

			buttonAnimations(deleteButton)
			buttonAnimations(resetButton)
			buttonAnimations(closeButton)

			placeArrows()
			redraw()

			newMt.Show = function(self)
				window:Show()
			end

			return newMt
		end

		return {new = new}
	end)()

	Lib.ViewportTextBox = (function()
		local textService = service.TextService

		local props = {
			OffsetX = 0,
			TextBox = PH,
			CursorPos = -1,
			Gui = PH,
			View = PH
		}
		local funcs = {}
		funcs.Update = function(self)
			local cursorPos = self.CursorPos or -1
			local text = self.TextBox.Text
			if text == "" then self.TextBox.Position = UDim2.new(0,0,0,0) return end
			if cursorPos == -1 then return end

			local cursorText = text:sub(1,cursorPos-1)
			local pos = nil
			local leftEnd = -self.TextBox.Position.X.Offset
			local rightEnd = leftEnd + self.View.AbsoluteSize.X

			local totalTextSize = textService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
			local cursorTextSize = textService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

			if cursorTextSize > rightEnd then
				pos = math.max(-1,cursorTextSize - self.View.AbsoluteSize.X + 2)
			elseif cursorTextSize < leftEnd then
				pos = math.max(-1,cursorTextSize-2)
			elseif totalTextSize < rightEnd then
				pos = math.max(-1,totalTextSize - self.View.AbsoluteSize.X + 2)
			end

			if pos then
				self.TextBox.Position = UDim2.new(0,-pos,0,0)
				self.TextBox.Size = UDim2.new(1,pos,1,0)
			end
		end

		funcs.GetText = function(self)
			return self.TextBox.Text
		end

		funcs.SetText = function(self,text)
			self.TextBox.Text = text
		end

		local mt = getGuiMT(props,funcs)

		local function convert(textbox)
			local obj = initObj(props,mt)

			local view = Instance.new("Frame")
			view.BackgroundTransparency = textbox.BackgroundTransparency
			view.BackgroundColor3 = textbox.BackgroundColor3
			view.BorderSizePixel = textbox.BorderSizePixel
			view.BorderColor3 = textbox.BorderColor3
			view.Position = textbox.Position
			view.Size = textbox.Size
			view.ClipsDescendants = true
			view.Name = textbox.Name
			textbox.BackgroundTransparency = 1
			textbox.Position = UDim2.new(0,0,0,0)
			textbox.Size = UDim2.new(1,0,1,0)
			textbox.TextXAlignment = Enum.TextXAlignment.Left
			textbox.Name = "Input"

			obj.TextBox = textbox
			obj.View = view
			obj.Gui = view

			textbox.Changed:Connect(function(prop)
				if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
					local cursorPos = obj.TextBox.CursorPosition
					if cursorPos ~= -1 then obj.CursorPos = cursorPos end
					obj:Update()
				end
			end)

			obj:Update()

			view.Parent = textbox.Parent
			textbox.Parent = view

			return obj
		end

		local function new()
			local textBox = Instance.new("TextBox")
			textBox.Active = true
			textBox.Size = UDim2.new(0,100,0,20)
			textBox.BackgroundColor3 = Settings.Theme.TextBox
			textBox.BorderColor3 = Settings.Theme.Outline3
			textBox.ClearTextOnFocus = false
			textBox.TextColor3 = Settings.Theme.Text
			textBox.Font = Enum.Font.SourceSans
			textBox.TextSize = 14
			textBox.Text = ""
			return convert(textBox)
		end

		return {new = new, convert = convert}
	end)()

	Lib.Label = (function()
		local props,funcs = {},{}

		local mt = getGuiMT(props,funcs)

		local function new()
			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = Settings.Theme.Text
			label.TextTransparency = 0.1
			label.Size = UDim2.new(0,100,0,20)
			label.Font = Enum.Font.SourceSans
			label.TextSize = 14

			local obj = setmetatable({
				Gui = label
			},mt)
			return obj
		end

		return {new = new}
	end)()

	Lib.Frame = (function()
		local props,funcs = {},{}

		local mt = getGuiMT(props,funcs)

		local function new()
			local fr = Instance.new("Frame")
			fr.BackgroundColor3 = Settings.Theme.Main1
			fr.BorderColor3 = Settings.Theme.Outline1
			fr.Size = UDim2.new(0,50,0,50)

			local obj = setmetatable({
				Gui = fr
			},mt)
			return obj
		end

		return {new = new}
	end)()

	Lib.Button = (function()
		local props = {
			Gui = PH,
			Anim = PH,
			Disabled = false,
			OnClick = SIGNAL,
			OnDown = SIGNAL,
			OnUp = SIGNAL,
			AllowedButtons = {1}
		}
		local funcs = {}
		local tableFind = table.find

		funcs.Trigger = function(self,event,button)
			if not self.Disabled and tableFind(self.AllowedButtons,button) then
				self["On"..event]:Fire(button)
			end
		end

		funcs.SetDisabled = function(self,dis)
			self.Disabled = dis

			if dis then
				self.Anim:Disable()
				self.Gui.TextTransparency = 0.5
			else
				self.Anim.Enable()
				self.Gui.TextTransparency = 0
			end
		end

		local mt = getGuiMT(props,funcs)

		local function new()
			local b = Instance.new("TextButton")
			b.AutoButtonColor = false
			b.TextColor3 = Settings.Theme.Text
			b.TextTransparency = 0.1
			b.Size = UDim2.new(0,100,0,20)
			b.Font = Enum.Font.SourceSans
			b.TextSize = 14
			b.BackgroundColor3 = Settings.Theme.Button
			b.BorderColor3 = Settings.Theme.Outline2

			local obj = initObj(props,mt)
			obj.Gui = b
			obj.Anim = Lib.ButtonAnim(b,{Mode = 2, StartColor = Settings.Theme.Button, HoverColor = Settings.Theme.ButtonHover, PressColor = Settings.Theme.ButtonPress, OutlineColor = Settings.Theme.Outline2})

			b.MouseButton1Click:Connect(function() obj:Trigger("Click",1) end)
			b.MouseButton1Down:Connect(function() obj:Trigger("Down",1) end)
			b.MouseButton1Up:Connect(function() obj:Trigger("Up",1) end)

			b.MouseButton2Click:Connect(function() obj:Trigger("Click",2) end)
			b.MouseButton2Down:Connect(function() obj:Trigger("Down",2) end)
			b.MouseButton2Up:Connect(function() obj:Trigger("Up",2) end)

			return obj
		end

		return {new = new}
	end)()

	Lib.DropDown = (function()
		local props = {
			Gui = PH,
			Anim = PH,
			Context = PH,
			Selected = PH,
			Disabled = false,
			CanBeEmpty = true,
			Options = {},
			GuiElems = {},
			OnSelect = SIGNAL
		}
		local funcs = {}

		funcs.Update = function(self)
			local options = self.Options

			if #options > 0 then
				if not self.Selected then
					if not self.CanBeEmpty then
						self.Selected = options[1]
						self.GuiElems.Label.Text = options[1]
					else
						self.GuiElems.Label.Text = "- Select -"
					end
				else
					self.GuiElems.Label.Text = self.Selected
				end
			else
				self.GuiElems.Label.Text = "- Select -"
			end
		end

		funcs.ShowOptions = function(self)
			local context = self.Context

			context.Width = self.Gui.AbsoluteSize.X
			context.ReverseYOffset = self.Gui.AbsoluteSize.Y
			context:Show(self.Gui.AbsolutePosition.X, self.Gui.AbsolutePosition.Y + context.ReverseYOffset)
		end

		funcs.SetOptions = function(self,opts)
			self.Options = opts

			local context = self.Context
			local options = self.Options
			context:Clear()

			local onClick = function(option) self.Selected = option self.OnSelect:Fire(option) self:Update() end

			if self.CanBeEmpty then
				context:Add({Name = "- Select -", function() self.Selected = nil self.OnSelect:Fire(nil) self:Update() end})
			end

			for i = 1,#options do
				context:Add({Name = options[i], OnClick = onClick})
			end

			self:Update()
		end

		funcs.SetSelected = function(self,opt)
			self.Selected = type(opt) == "number" and self.Options[opt] or opt
			self:Update()
		end

		local mt = getGuiMT(props,funcs)

		local function new()
			local f = Instance.new("TextButton")
			f.AutoButtonColor = false
			f.Text = ""
			f.Size = UDim2.new(0,100,0,20)
			f.BackgroundColor3 = Settings.Theme.TextBox
			f.BorderColor3 = Settings.Theme.Outline3

			local label = Lib.Label.new()
			label.Position = UDim2.new(0,2,0,0)
			label.Size = UDim2.new(1,-22,1,0)
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Parent = f
			local arrow = create({
				{1,"Frame",{BackgroundTransparency=1,Name="EnumArrow",Position=UDim2.new(1,-16,0,2),Size=UDim2.new(0,16,0,16),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,8,0,9),Size=UDim2.new(0,1,0,1),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,7,0,8),Size=UDim2.new(0,3,0,1),}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,1),}},
			})
			arrow.Parent = f

			local obj = initObj(props,mt)
			obj.Gui = f
			obj.Anim = Lib.ButtonAnim(f,{Mode = 2, StartColor = Settings.Theme.TextBox, LerpTo = Settings.Theme.Button, LerpDelta = 0.15})
			obj.Context = Lib.ContextMenu.new()
			obj.Context.Iconless = true
			obj.Context.MaxHeight = 200
			obj.Selected = nil
			obj.GuiElems = {Label = label}
			f.MouseButton1Down:Connect(function() obj:ShowOptions() end)
			obj:Update()
			return obj
		end

		return {new = new}
	end)()

	Lib.ClickSystem = (function()
		local props = {
			LastItem = PH,
			OnDown = SIGNAL,
			OnRelease = SIGNAL,
			AllowedButtons = {1},
			Combo = 0,
			MaxCombo = 2,
			ComboTime = 0.5,
			Items = {},
			ItemCons = {},
			ClickId = -1,
			LastButton = ""
		}
		local funcs = {}
		local tostring = tostring

		local disconnect = function(con)
			local pos = table.find(con.Signal.Connections,con)
			if pos then table.remove(con.Signal.Connections,pos) end
		end

		funcs.Trigger = function(self, item, button, X, Y)
			if table.find(self.AllowedButtons, button) then
				if self.LastButton ~= button or self.LastItem ~= item or self.Combo == self.MaxCombo or tick() - self.ClickId > self.ComboTime then
					self.Combo = 0
					self.LastButton = button
					self.LastItem = item
				end

				self.Combo = self.Combo + 1
				self.ClickId = tick()

				task.spawn(function()
					if self.InputDown then
						self.InputDown = false
					else
						self.InputDown = tick()

						local Connection = item.MouseButton1Up:Once(function()
							self.InputDown = false
						end)

						while self.InputDown and not Explorer.Dragging do
							if (tick() - self.InputDown) >= 0.4 then
								self.InputDown = false
								self["OnRelease"]:Fire(item, self.Combo, 2, Vector2.new(X, Y))
								break
							end;task.wait()
						end
					end
				end)

				local release
				release = service.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType["MouseButton" .. button] then
						release:Disconnect()
						if Lib.CheckMouseInGui(item) and self.LastButton == button and self.LastItem == item then
							self.InputDown = false -- infinite yield dev forgot to do this, and ended up OnRelease fired twice ??
							self["OnRelease"]:Fire(item,self.Combo,button)
						end
					end
				end)

				self["OnDown"]:Fire(item,self.Combo,button)
			end
		end

		funcs.Add = function(self,item)
			if table.find(self.Items,item) then return end

			local cons = {}
			cons[1] = item.MouseButton1Down:Connect(function(X, Y) self:Trigger(item, 1, X, Y) end)
			cons[2] = item.MouseButton2Down:Connect(function(X, Y) self:Trigger(item, 2, X, Y) end)

			self.ItemCons[item] = cons
			self.Items[#self.Items+1] = item
		end

		funcs.Remove = function(self,item)
			local ind = table.find(self.Items,item)
			if not ind then return end

			for i,v in pairs(self.ItemCons[item]) do
				v:Disconnect()
			end
			self.ItemCons[item] = nil
			table.remove(self.Items,ind)
		end

		local mt = {__index = funcs}

		local function new()
			local obj = initObj(props,mt)

			return obj
		end

		return {new = new}
	end)()

	return Lib
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end,
["ModelViewer"] = function()
--[[
	Model Viewer App Module
	
	A model viewer :3
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, ModelViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local function getPath(obj)
	if obj.Parent == nil then
		return "Nil parented"
	else
		return Explorer.GetInstancePath(obj)
	end
end

local function main()
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	
	local ModelViewer = {
		EnableInputCamera = true,
		IsViewing = false,
		AutoRefresh = false,
		ZoomMultiplier = 2,
		AutoRotate = true,
		RotationSpeed = 0.01,
		RefreshRate = 30 -- hertz
	}
	
	local window, viewportFrame, pathLabel, settingsButton
	local model, camera, originalModel
	
	
	ModelViewer.StopViewModel = function(updating)
		if updating then
			viewportFrame:FindFirstChildOfClass("Model"):Destroy()
		else
			if camera then camera = nil end
			if model then model = nil end
			viewportFrame:ClearAllChildren()
			
			ModelViewer.IsViewing = false
			window:SetTitle("3D Preview")
			pathLabel.Gui.Text = ""
		end
	end

	ModelViewer.ViewModel = function(item, updating)
		if not item then return end
		ModelViewer.StopViewModel(updating)
		
		if item ~= workspace and not item:IsA("Terrain") then
			-- why Model == workspace
			-- wtf?
			
			if item:IsA("BasePart") and not item:IsA("Model") then			
				model = Instance.new("Model")
				model.Parent = viewportFrame

				local clone = item:Clone()
				clone.Parent = model
				model.PrimaryPart = clone
				model:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
			elseif item:IsA("Model") then
				item.Archivable = true

			--[[if not item.PrimaryPart then
				pathLabel.Gui.Text = "Failed to view model: No PrimaryPart is found."
				return
			end]]
				if #item:GetChildren() == 0 then return end
				
				model = item:Clone()
				model.Parent = viewportFrame

				-- fallback
				if not model.PrimaryPart then
					local found = false
					for _, child in model:GetDescendants() do
						if child:IsA("BasePart") then
							model.PrimaryPart = child
							model:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
							found = true
							break
						end
					end
					if not found then
						model:Destroy()
						model = nil
						return
					end
				end
			else
				return
			end
		end
		
		originalModel = item
		
		if ModelViewer.AutoRefresh and not updating then
			task.spawn(function()
				while model and ModelViewer.AutoRefresh do
					
					ModelViewer.ViewModel(originalModel, true)
					task.wait(1 / ModelViewer.RefreshRate)
				end
			end)
		end
		
		if not updating then
			camera = Instance.new("Camera")
			viewportFrame.CurrentCamera = camera

			camera.Parent = viewportFrame
			camera.FieldOfView = 60
			
			window:SetTitle(item.Name.." - 3D Preview")
			pathLabel.Gui.Text = "path: " .. getPath(originalModel)
			window:Show()
			ModelViewer.IsViewing = true
		end
	end

	ModelViewer.Init = function()
		window = Lib.Window.new()
		window:SetTitle("3D Preview")
		window:Resize(350,200)
		ModelViewer.Window =  window
		
		viewportFrame = Instance.new("ViewportFrame")
		viewportFrame.Parent = window.GuiElems.Content
		viewportFrame.BackgroundTransparency = 1
		viewportFrame.Size = UDim2.new(1,0,1,0)
		
		pathLabel = Lib.Label.new()
		pathLabel.Gui.Parent = window.GuiElems.Content
		pathLabel.Gui.AnchorPoint = Vector2.new(0,1)
		pathLabel.Gui.Text = ""
		pathLabel.Gui.TextSize = 12
		pathLabel.Gui.TextTransparency = 0.8
		pathLabel.Gui.Position = UDim2.new(0,1,1,0)
		pathLabel.Gui.Size = UDim2.new(1,-1,0,15)
		pathLabel.Gui.BackgroundTransparency = 1
		
		settingsButton = Instance.new("ImageButton",window.GuiElems.Content)
		settingsButton.AnchorPoint = Vector2.new(1,0)
		settingsButton.BackgroundTransparency = 1
		settingsButton.Size = UDim2.new(0,15,0,15)
		settingsButton.Position = UDim2.new(1,-3,0,3)
		settingsButton.Image = "rbxassetid://6578871732"
		settingsButton.ImageTransparency = 0.5
		-- mobile input check
		if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
			settingsButton.Visible = true
		else
			settingsButton.Visible = false
		end

		local rotationX, rotationY = -15, 0
		local distance = 10
		local dragging = false
		local hovering = false
		local lastpos = Vector2.zero

		viewportFrame.InputBegan:Connect(function(input)
			if not ModelViewer.EnableInputCamera then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				lastpos = input.Position
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				ModelViewer.ZoomMultiplier = 10
			end
		end)
		

		viewportFrame.MouseEnter:Connect(function()
			hovering = true
		end)
		viewportFrame.MouseLeave:Connect(function()
			hovering = false
		end)

		viewportFrame.InputEnded:Connect(function(input)
			if not ModelViewer.EnableInputCamera then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				ModelViewer.ZoomMultiplier = 2
			end
		end)

		viewportFrame.InputChanged:Connect(function(input)
			if not ModelViewer.EnableInputCamera then return end
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - lastpos
				lastpos = input.Position

				rotationY -= delta.X * 0.01
				rotationX -= delta.Y * 0.01
				rotationX = math.clamp(rotationX, -math.pi/2 + 0.1, math.pi/2 - 0.1)
			end

			if input.UserInputType == Enum.UserInputType.MouseWheel and hovering then
				distance = math.clamp(distance - (input.Position.Z * ModelViewer.ZoomMultiplier), 0.1, math.huge)
			end
		end)

		RunService.RenderStepped:Connect(function(dt)
			if camera and model then
				if not dragging and ModelViewer.AutoRotate then
					rotationY += ModelViewer.RotationSpeed * dt * 60
				end
				
				local center = model.PrimaryPart.Position
				local offset = CFrame.new(0, 0, distance)
				local rotation = CFrame.Angles(0, rotationY, 0) * CFrame.Angles(rotationX, 0, 0)

				local camCF = CFrame.new(center) * rotation * offset

				camera.CFrame = CFrame.lookAt(camCF.Position, center)
				
			end
		end)
		
		-- context stuffs
		local context = Lib.ContextMenu.new()
		
		local absoluteSize = context.Gui.AbsoluteSize
		context.MaxHeight = (absoluteSize.Y <= 600 and (absoluteSize.Y - 40)) or nil

		-- Registers
		context:Register("STOP",{Name = "Stop Viewing", OnClick = function()
			ModelViewer.StopViewModel()
		end})
		context:Register("EXIT",{Name = "Exit", OnClick = function()
			ModelViewer.StopViewModel()
			context:Hide()
			window:Hide()
		end})
		context:Register("COPY_PATH",{Name = "Copy Path", OnClick = function()
			if model then
				env.setclipboard(getPath(originalModel))
			end
		end})
		context:Register("REFRESH",{Name = "Refresh", OnClick = function()
			if originalModel then
				ModelViewer.ViewModel(originalModel)
			end
		end})
		context:Register("ENABLE_AUTO_REFRESH",{Name = "Enable Auto Refresh", OnClick = function()
			if originalModel then
				ModelViewer.AutoRefresh = true
				ModelViewer.ViewModel(originalModel)
			end
		end})
		context:Register("DISABLE_AUTO_REFRESH",{Name = "Disable Auto Refresh", OnClick = function()
			if originalModel then
				ModelViewer.AutoRefresh = false
				ModelViewer.ViewModel(originalModel)
			end
		end})
		context:Register("SAVE_INST",{Name = "Save to File", OnClick = function()
			if model then
				Lib.SaveAsPrompt("Place_"..game.PlaceId.."_"..originalModel.Name.."_"..os.time(), function(filename)
					window:SetTitle(originalModel.Name.." - Model Viewer - Saving")	
					
					local success, result = pcall(env.saveinstance,
					originalModel, filename,
						{
							Decompile = true,
							RemovePlayerCharacters = false
						}
					)
					
					if success then
						window:SetTitle(originalModel.Name.." - Model Viewer - Saved")
						context:Hide()
						task.wait(5)
						if model then
							window:SetTitle(originalModel.Name.." - Model Viewer")
						end
					else
						window:SetTitle(originalModel.Name.." - Model Viewer - Error")
						warn("Error while saving model: "..result)
						context:Hide()
						task.wait(5)
						if model then
							window:SetTitle(originalModel.Name.." - Model Viewer")
						end
					end
				end)
			end
		end})
		
		context:Register("ENABLE_AUTO_ROTATE",{Name = "Enable Auto Rotate", OnClick = function()
			ModelViewer.AutoRotate = true
			
		end})
		context:Register("DISABLE_AUTO_ROTATE",{Name = "Disable Auto Rotate", OnClick = function()
			ModelViewer.AutoRotate = false
		end})
		context:Register("LOCK_CAM",{Name = "Lock Camera", OnClick = function()
			ModelViewer.EnableInputCamera = false
		end})
		context:Register("UNLOCK_CAM",{Name = "Unlock Camera", OnClick = function()
			ModelViewer.EnableInputCamera = true
		end})
		
		context:Register("ZOOM_IN",{Name = "Zoom In", OnClick = function()
			distance = math.clamp(distance - (ModelViewer.ZoomMultiplier * 2), 2, math.huge)
		end})
		
		context:Register("ZOOM_OUT",{Name = "Zoom Out", OnClick = function()
			distance = math.clamp(distance + (ModelViewer.ZoomMultiplier * 2), 2, math.huge)
		end})
		
		local function ShowContext()
			context:Clear()

			context:AddRegistered("STOP", not ModelViewer.IsViewing)	
			context:AddRegistered("REFRESH", not ModelViewer.IsViewing)
			context:AddRegistered("COPY_PATH", not ModelViewer.IsViewing)
			context:AddRegistered("SAVE_INST", not ModelViewer.IsViewing)
			context:AddDivider()
			
			if env.isonmobile then
				context:AddRegistered("ZOOM_IN")
				context:AddRegistered("ZOOM_OUT")
				context:AddDivider()
			end

			if ModelViewer.AutoRotate then
				context:AddRegistered("DISABLE_AUTO_ROTATE")
			else
				context:AddRegistered("ENABLE_AUTO_ROTATE")
			end
			if ModelViewer.AutoRefresh then
				context:AddRegistered("DISABLE_AUTO_REFRESH")
			else
				context:AddRegistered("ENABLE_AUTO_REFRESH")
			end
			if ModelViewer.EnableInputCamera then
				context:AddRegistered("LOCK_CAM")
			else
				context:AddRegistered("UNLOCK_CAM")
			end

			context:AddDivider()

			context:AddRegistered("EXIT")

			context:Show()
		end
		
		local function HideContext()
			context:Hide()
		end
		
		viewportFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				ShowContext()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 and Lib.CheckMouseInGui(context.Gui) then
				HideContext()
			end
		end)
		settingsButton.MouseButton1Click:Connect(function()
			ShowContext()
		end)
	end

	return ModelViewer
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
end,
["Properties"] = function()
--[[
	Properties App Module
	
	The main properties interface
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local function main()
	local Properties = {}

	local window, toolBar, propsFrame
	local scrollV, scrollH
	local categoryOrder
	local props,viewList,expanded,indexableProps,propEntries,autoUpdateObjs = {},{},{},{},{},{}
	local inputBox,inputTextBox,inputProp
	local checkboxes,propCons = {},{}
	local table,string = table,string
	local getPropChangedSignal = game.GetPropertyChangedSignal
	local getAttributeChangedSignal = game.GetAttributeChangedSignal
	local isa = game.IsA
	local getAttribute = game.GetAttribute
	local setAttribute = game.SetAttribute

	Properties.GuiElems = {}
	Properties.Index = 0
	Properties.ViewWidth = 0
	Properties.MinInputWidth = 100
	Properties.EntryIndent = 16
	Properties.EntryOffset = 4
	Properties.NameWidthCache = {}
	Properties.SubPropCache = {}
	Properties.ClassLists = {}
	Properties.SearchText = ""

	Properties.AddAttributeProp = {Category = "Attributes", Class = "", Name = "", SpecialRow = "AddAttribute", Tags = {}}
	Properties.SoundPreviewProp = {Category = "Data", ValueType = {Name = "SoundPlayer"}, Class = "Sound", Name = "Preview", Tags = {}}

	Properties.IgnoreProps = {
		["DataModel"] = {
			["PrivateServerId"] = true,
			["PrivateServerOwnerId"] = true,
			["VIPServerId"] = true,
			["VIPServerOwnerId"] = true
		}
	}

	Properties.ExpandableTypes = {
		["Vector2"] = true,
		["Vector3"] = true,
		["UDim"] = true,
		["UDim2"] = true,
		["CFrame"] = true,
		["Rect"] = true,
		["PhysicalProperties"] = true,
		["Ray"] = true,
		["NumberRange"] = true,
		["Faces"] = true,
		["Axes"] = true,
	}

	Properties.ExpandableProps = {
		["Sound.SoundId"] = true
	}

	Properties.CollapsedCategories = {
		["Surface Inputs"] = true,
		["Surface"] = true
	}

	Properties.ConflictSubProps = {
		["Vector2"] = {"X","Y"},
		["Vector3"] = {"X","Y","Z"},
		["UDim"] = {"Scale","Offset"},
		["UDim2"] = {"X","X.Scale","X.Offset","Y","Y.Scale","Y.Offset"},
		["CFrame"] = {"Position","Position.X","Position.Y","Position.Z",
			"RightVector","RightVector.X","RightVector.Y","RightVector.Z",
			"UpVector","UpVector.X","UpVector.Y","UpVector.Z",
			"LookVector","LookVector.X","LookVector.Y","LookVector.Z"},
		["Rect"] = {"Min.X","Min.Y","Max.X","Max.Y"},
		["PhysicalProperties"] = {"Density","Elasticity","ElasticityWeight","Friction","FrictionWeight"},
		["Ray"] = {"Origin","Origin.X","Origin.Y","Origin.Z","Direction","Direction.X","Direction.Y","Direction.Z"},
		["NumberRange"] = {"Min","Max"},
		["Faces"] = {"Back","Bottom","Front","Left","Right","Top"},
		["Axes"] = {"X","Y","Z"}
	}

	Properties.ConflictIgnore = {
		["BasePart"] = {
			["ResizableFaces"] = true
		}
	}

	Properties.RoundableTypes = {
		["float"] = true,
		["double"] = true,
		["Color3"] = true,
		["UDim"] = true,
		["UDim2"] = true,
		["Vector2"] = true,
		["Vector3"] = true,
		["NumberRange"] = true,
		["Rect"] = true,
		["NumberSequence"] = true,
		["ColorSequence"] = true,
		["Ray"] = true,
		["CFrame"] = true
	}

	Properties.TypeNameConvert = {
		["number"] = "double",
		["boolean"] = "bool"
	}

	Properties.ToNumberTypes = {
		["int"] = true,
		["int64"] = true,
		["float"] = true,
		["double"] = true
	}

	Properties.DefaultPropValue = {
		string = "",
		bool = false,
		double = 0,
		UDim = UDim.new(0,0),
		UDim2 = UDim2.new(0,0,0,0),
		BrickColor = BrickColor.new("Medium stone grey"),
		Color3 = Color3.new(1,1,1),
		Vector2 = Vector2.new(0,0),
		Vector3 = Vector3.new(0,0,0),
		NumberSequence = NumberSequence.new(1),
		ColorSequence = ColorSequence.new(Color3.new(1,1,1)),
		NumberRange = NumberRange.new(0),
		Rect = Rect.new(0,0,0,0)
	}

	Properties.AllowedAttributeTypes = {"string","boolean","number","UDim","UDim2","BrickColor","Color3","Vector2","Vector3","NumberSequence","ColorSequence","NumberRange","Rect"}

	Properties.StringToValue = function(prop,str)
		local typeData = prop.ValueType
		local typeName = typeData.Name

		if typeName == "string" or typeName == "Content" then
			return str
		elseif Properties.ToNumberTypes[typeName] then
			return tonumber(str)
		elseif typeName == "Vector2" then
			local vals = str:split(",")
			local x,y = tonumber(vals[1]),tonumber(vals[2])
			if x and y and #vals >= 2 then return Vector2.new(x,y) end
		elseif typeName == "Vector3" then
			local vals = str:split(",")
			local x,y,z = tonumber(vals[1]),tonumber(vals[2]),tonumber(vals[3])
			if x and y and z and #vals >= 3 then return Vector3.new(x,y,z) end
		elseif typeName == "UDim" then
			local vals = str:split(",")
			local scale,offset = tonumber(vals[1]),tonumber(vals[2])
			if scale and offset and #vals >= 2 then return UDim.new(scale,offset) end
		elseif typeName == "UDim2" then
			local vals = str:gsub("[{}]",""):split(",")
			local xScale,xOffset,yScale,yOffset = tonumber(vals[1]),tonumber(vals[2]),tonumber(vals[3]),tonumber(vals[4])
			if xScale and xOffset and yScale and yOffset and #vals >= 4 then return UDim2.new(xScale,xOffset,yScale,yOffset) end
		elseif typeName == "CFrame" then
			local vals = str:split(",")
			local s,result = pcall(CFrame.new,unpack(vals))
			if s and #vals >= 12 then return result end
		elseif typeName == "Rect" then
			local vals = str:split(",")
			local s,result = pcall(Rect.new,unpack(vals))
			if s and #vals >= 4 then return result end
		elseif typeName == "Ray" then
			local vals = str:gsub("[{}]",""):split(",")
			local s,origin = pcall(Vector3.new,unpack(vals,1,3))
			local s2,direction = pcall(Vector3.new,unpack(vals,4,6))
			if s and s2 and #vals >= 6 then return Ray.new(origin,direction) end
		elseif typeName == "NumberRange" then
			local vals = str:split(",")
			local s,result = pcall(NumberRange.new,unpack(vals))
			if s and #vals >= 1 then return result end
		elseif typeName == "Color3" then
			local vals = str:gsub("[{}]",""):split(",")
			local s,result = pcall(Color3.fromRGB,unpack(vals))
			if s and #vals >= 3 then return result end
		end

		return nil
	end

	Properties.ValueToString = function(prop,val)
		local typeData = prop.ValueType
		local typeName = typeData.Name

		if typeName == "Color3" then
			return Lib.ColorToBytes(val)
		elseif typeName == "NumberRange" then
			return val.Min..", "..val.Max
		end

		return tostring(val)
	end

	Properties.GetIndexableProps = function(obj,classData)
		if not Main.Elevated then
			if not pcall(function() return obj.ClassName end) then return nil end
		end

		local ignoreProps = Properties.IgnoreProps[classData.Name] or {}

		local result = {}
		local count = 1
		local props = classData.Properties
		for i = 1,#props do
			local prop = props[i]
			if not ignoreProps[prop.Name] then
				local s = pcall(function() return obj[prop.Name] end)
				if s then
					result[count] = prop
					count = count + 1
				end
			end
		end

		return result
	end

	Properties.FindFirstObjWhichIsA = function(class)
		local classList = Properties.ClassLists[class] or {}
		if classList and #classList > 0 then
			return classList[1]
		end

		return nil
	end

	Properties.ComputeConflicts = function(p)
		local maxConflictCheck = Settings.Properties.MaxConflictCheck
		local sList = Explorer.Selection.List
		local classLists = Properties.ClassLists
		local stringSplit = string.split
		local t_clear = table.clear
		local conflictIgnore = Properties.ConflictIgnore
		local conflictMap = {}
		local propList = p and {p} or props

		if p then
			local gName = p.Class.."."..p.Name
			autoUpdateObjs[gName] = nil
			local subProps = Properties.ConflictSubProps[p.ValueType.Name] or {}
			for i = 1,#subProps do
				autoUpdateObjs[gName.."."..subProps[i]] = nil
			end
		else
			table.clear(autoUpdateObjs)
		end

		if #sList > 0 then
			for i = 1,#propList do
				local prop = propList[i]
				local propName,propClass = prop.Name,prop.Class
				local typeData = prop.RootType or prop.ValueType
				local typeName = typeData.Name
				local attributeName = prop.AttributeName
				local gName = propClass.."."..propName

				local checked = 0
				local subProps = Properties.ConflictSubProps[typeName] or {}
				local subPropCount = #subProps
				local toCheck = subPropCount + 1
				local conflictsFound = 0
				local indexNames = {}
				local ignored = conflictIgnore[propClass] and conflictIgnore[propClass][propName]
				local truthyCheck = (typeName == "PhysicalProperties")
				local isAttribute = prop.IsAttribute
				local isMultiType = prop.MultiType

				t_clear(conflictMap)

				if not isMultiType then
					local firstVal,firstObj,firstSet
					local classList = classLists[prop.Class] or {}
					for c = 1,#classList do
						local obj = classList[c]
						if not firstSet then
							if isAttribute then
								firstVal = getAttribute(obj,attributeName)
								if firstVal ~= nil then
									firstObj = obj
									firstSet = true
								end
							else
								firstVal = obj[propName]
								firstObj = obj
								firstSet = true
							end
							if ignored then break end
						else
							local propVal,skip
							if isAttribute then
								propVal = getAttribute(obj,attributeName)
								if propVal == nil then skip = true end
							else
								propVal = obj[propName]
							end

							if not skip then
								if not conflictMap[1] then
									if truthyCheck then
										if (firstVal and true or false) ~= (propVal and true or false) then
											conflictMap[1] = true
											conflictsFound = conflictsFound + 1
										end
									elseif firstVal ~= propVal then
										conflictMap[1] = true
										conflictsFound = conflictsFound + 1
									end
								end

								if subPropCount > 0 then
									for sPropInd = 1,subPropCount do
										local indexes = indexNames[sPropInd]
										if not indexes then indexes = stringSplit(subProps[sPropInd],".") indexNames[sPropInd] = indexes end

										local firstValSub = firstVal
										local propValSub = propVal

										for j = 1,#indexes do
											if not firstValSub or not propValSub then break end -- PhysicalProperties
											local indexName = indexes[j]
											firstValSub = firstValSub[indexName]
											propValSub = propValSub[indexName]
										end

										local mapInd = sPropInd + 1
										if not conflictMap[mapInd] and firstValSub ~= propValSub then
											conflictMap[mapInd] = true
											conflictsFound = conflictsFound + 1
										end
									end
								end

								if conflictsFound == toCheck then break end
							end
						end

						checked = checked + 1
						if checked == maxConflictCheck then break end
					end

					if not conflictMap[1] then autoUpdateObjs[gName] = firstObj end
					for sPropInd = 1,subPropCount do
						if not conflictMap[sPropInd+1] then
							autoUpdateObjs[gName.."."..subProps[sPropInd]] = firstObj
						end
					end
				end
			end
		end

		if p then
			Properties.Refresh()
		end
	end

	-- Fetches the properties to be displayed based on the explorer selection
	Properties.ShowExplorerProps = function()
		local maxConflictCheck = Settings.Properties.MaxConflictCheck
		local sList = Explorer.Selection.List
		local foundClasses = {}
		local propCount = 1
		local elevated = Main.Elevated
		local showDeprecated,showHidden = Settings.Properties.ShowDeprecated,Settings.Properties.ShowHidden
		local Classes = API.Classes
		local classLists = {}
		local lower = string.lower
		local RMDCustomOrders = RMD.PropertyOrders
		local getAttributes = game.GetAttributes
		local maxAttrs = Settings.Properties.MaxAttributes
		local showingAttrs = Settings.Properties.ShowAttributes
		local foundAttrs = {}
		local attrCount = 0
		local typeof = typeof
		local typeNameConvert = Properties.TypeNameConvert

		table.clear(props)

		for i = 1,#sList do
			local node = sList[i]
			local obj = node.Obj
			local class = node.Class
			if not class then class = obj.ClassName node.Class = class end

			local apiClass = Classes[class]
			while apiClass do
				local APIClassName = apiClass.Name
				if not foundClasses[APIClassName] then
					local apiProps = indexableProps[APIClassName]
					if not apiProps then apiProps = Properties.GetIndexableProps(obj,apiClass) indexableProps[APIClassName] = apiProps end

					for i = 1,#apiProps do
						local prop = apiProps[i]
						local tags = prop.Tags
						if (not tags.Deprecated or showDeprecated) and (not tags.Hidden or showHidden) then
							props[propCount] = prop
							propCount = propCount + 1
						end
					end
					foundClasses[APIClassName] = true
				end

				local classList = classLists[APIClassName]
				if not classList then classList = {} classLists[APIClassName] = classList end
				classList[#classList+1] = obj

				apiClass = apiClass.Superclass
			end

			if showingAttrs and attrCount < maxAttrs then
				local attrs = getAttributes(obj)
				for name,val in pairs(attrs) do
					local typ = typeof(val)
					if not foundAttrs[name] then
						local category = (typ == "Instance" and "Class") or (typ == "EnumItem" and "Enum") or "Other"
						local valType = {Name = typeNameConvert[typ] or typ, Category = category}
						local attrProp = {IsAttribute = true, Name = "ATTR_"..name, AttributeName = name, DisplayName = name, Class = "Instance", ValueType = valType, Category = "Attributes", Tags = {}}
						props[propCount] = attrProp
						propCount = propCount + 1
						attrCount = attrCount + 1
						foundAttrs[name] = {typ,attrProp}
						if attrCount == maxAttrs then break end
					elseif foundAttrs[name][1] ~= typ then
						foundAttrs[name][2].MultiType = true
						foundAttrs[name][2].Tags.ReadOnly = true
						foundAttrs[name][2].ValueType = {Name = "string"}
					end
				end
			end
		end

		table.sort(props,function(a,b)
			if a.Category ~= b.Category then
				return (categoryOrder[a.Category] or 9999) < (categoryOrder[b.Category] or 9999)
			else
				local aOrder = (RMDCustomOrders[a.Class] and RMDCustomOrders[a.Class][a.Name]) or 9999999
				local bOrder = (RMDCustomOrders[b.Class] and RMDCustomOrders[b.Class][b.Name]) or 9999999
				if aOrder ~= bOrder then
					return aOrder < bOrder
				else
					return lower(a.Name) < lower(b.Name)
				end
			end
		end)

		-- Find conflicts and get auto-update instances
		Properties.ClassLists = classLists
		Properties.ComputeConflicts()
		--warn("CONFLICT",tick()-start)
		if #props > 0 then
			props[#props+1] = Properties.AddAttributeProp
		end

		Properties.Update()
		Properties.Refresh()
	end

	Properties.UpdateView = function()
		local maxEntries = math.ceil(propsFrame.AbsoluteSize.Y / 23)
		local maxX = propsFrame.AbsoluteSize.X
		local totalWidth = Properties.ViewWidth + Properties.MinInputWidth

		scrollV.VisibleSpace = maxEntries
		scrollV.TotalSpace = #viewList + 1
		scrollH.VisibleSpace = maxX
		scrollH.TotalSpace = totalWidth

		scrollV.Gui.Visible = #viewList + 1 > maxEntries
		scrollH.Gui.Visible = Settings.Properties.ScaleType == 0 and totalWidth > maxX

		local oldSize = propsFrame.Size
		propsFrame.Size = UDim2.new(1,(scrollV.Gui.Visible and -16 or 0),1,(scrollH.Gui.Visible and -39 or -23))
		if oldSize ~= propsFrame.Size then
			Properties.UpdateView()
		else
			scrollV:Update()
			scrollH:Update()

			if scrollV.Gui.Visible and scrollH.Gui.Visible then
				scrollV.Gui.Size = UDim2.new(0,16,1,-39)
				scrollH.Gui.Size = UDim2.new(1,-16,0,16)
				Properties.Window.GuiElems.Content.ScrollCorner.Visible = true
			else
				scrollV.Gui.Size = UDim2.new(0,16,1,-23)
				scrollH.Gui.Size = UDim2.new(1,0,0,16)
				Properties.Window.GuiElems.Content.ScrollCorner.Visible = false
			end

			Properties.Index = scrollV.Index
		end
	end

	Properties.MakeSubProp = function(prop,subName,valueType,displayName)
		local subProp = {}
		for i,v in pairs(prop) do
			subProp[i] = v
		end
		subProp.RootType = subProp.RootType or subProp.ValueType
		subProp.ValueType = valueType
		subProp.SubName = subProp.SubName and (subProp.SubName..subName) or subName
		subProp.DisplayName = displayName

		return subProp
	end

	Properties.GetExpandedProps = function(prop) -- TODO: Optimize using table
		local result = {}
		local typeData = prop.ValueType
		local typeName = typeData.Name
		local makeSubProp = Properties.MakeSubProp

		if typeName == "Vector2" then
			result[1] = makeSubProp(prop,".X",{Name = "float"})
			result[2] = makeSubProp(prop,".Y",{Name = "float"})
		elseif typeName == "Vector3" then
			result[1] = makeSubProp(prop,".X",{Name = "float"})
			result[2] = makeSubProp(prop,".Y",{Name = "float"})
			result[3] = makeSubProp(prop,".Z",{Name = "float"})
		elseif typeName == "CFrame" then
			result[1] = makeSubProp(prop,".Position",{Name = "Vector3"})
			result[2] = makeSubProp(prop,".RightVector",{Name = "Vector3"})
			result[3] = makeSubProp(prop,".UpVector",{Name = "Vector3"})
			result[4] = makeSubProp(prop,".LookVector",{Name = "Vector3"})
		elseif typeName == "UDim" then
			result[1] = makeSubProp(prop,".Scale",{Name = "float"})
			result[2] = makeSubProp(prop,".Offset",{Name = "int"})
		elseif typeName == "UDim2" then
			result[1] = makeSubProp(prop,".X",{Name = "UDim"})
			result[2] = makeSubProp(prop,".Y",{Name = "UDim"})
		elseif typeName == "Rect" then
			result[1] = makeSubProp(prop,".Min.X",{Name = "float"},"X0")
			result[2] = makeSubProp(prop,".Min.Y",{Name = "float"},"Y0")
			result[3] = makeSubProp(prop,".Max.X",{Name = "float"},"X1")
			result[4] = makeSubProp(prop,".Max.Y",{Name = "float"},"Y1")
		elseif typeName == "PhysicalProperties" then
			result[1] = makeSubProp(prop,".Density",{Name = "float"})
			result[2] = makeSubProp(prop,".Elasticity",{Name = "float"})
			result[3] = makeSubProp(prop,".ElasticityWeight",{Name = "float"})
			result[4] = makeSubProp(prop,".Friction",{Name = "float"})
			result[5] = makeSubProp(prop,".FrictionWeight",{Name = "float"})
		elseif typeName == "Ray" then
			result[1] = makeSubProp(prop,".Origin",{Name = "Vector3"})
			result[2] = makeSubProp(prop,".Direction",{Name = "Vector3"})
		elseif typeName == "NumberRange" then
			result[1] = makeSubProp(prop,".Min",{Name = "float"})
			result[2] = makeSubProp(prop,".Max",{Name = "float"})
		elseif typeName == "Faces" then
			result[1] = makeSubProp(prop,".Back",{Name = "bool"})
			result[2] = makeSubProp(prop,".Bottom",{Name = "bool"})
			result[3] = makeSubProp(prop,".Front",{Name = "bool"})
			result[4] = makeSubProp(prop,".Left",{Name = "bool"})
			result[5] = makeSubProp(prop,".Right",{Name = "bool"})
			result[6] = makeSubProp(prop,".Top",{Name = "bool"})
		elseif typeName == "Axes" then
			result[1] = makeSubProp(prop,".X",{Name = "bool"})
			result[2] = makeSubProp(prop,".Y",{Name = "bool"})
			result[3] = makeSubProp(prop,".Z",{Name = "bool"})
		end

		if prop.Name == "SoundId" and prop.Class == "Sound" then
			result[1] = Properties.SoundPreviewProp
		end

		return result
	end

	Properties.Update = function()
		table.clear(viewList)

		local nameWidthCache = Properties.NameWidthCache
		local lastCategory
		local count = 1
		local maxWidth,maxDepth = 0,1

		local textServ = service.TextService
		local getTextSize = textServ.GetTextSize
		local font = Enum.Font.SourceSans
		local size = Vector2.new(math.huge,20)
		local stringSplit = string.split
		local entryIndent = Properties.EntryIndent
		local isFirstScaleType = Settings.Properties.ScaleType == 0
		local find,lower = string.find,string.lower
		local searchText = (#Properties.SearchText > 0 and lower(Properties.SearchText))

		local function recur(props,depth)
			for i = 1,#props do
				local prop = props[i]
				local propName = prop.Name
				local subName = prop.SubName
				local category = prop.Category

				local visible
				if searchText and depth == 1 then
					if find(lower(propName),searchText,1,true) then
						visible = true
					end
				else
					visible = true
				end

				if visible and lastCategory ~= category then
					viewList[count] = {CategoryName = category}
					count = count + 1
					lastCategory = category
				end

				if (expanded["CAT_"..category] and visible) or prop.SpecialRow then
					if depth > 1 then prop.Depth = depth if depth > maxDepth then maxDepth = depth end end

					if isFirstScaleType then
						local nameArr = subName and stringSplit(subName,".")
						local displayName = prop.DisplayName or (nameArr and nameArr[#nameArr]) or propName

						local nameWidth = nameWidthCache[displayName]
						if not nameWidth then nameWidth = getTextSize(textServ,displayName,14,font,size).X nameWidthCache[displayName] = nameWidth end

						local totalWidth = nameWidth + entryIndent*depth
						if totalWidth > maxWidth then
							maxWidth = totalWidth
						end
					end

					viewList[count] = prop
					count = count + 1

					local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
					if expanded[fullName] then
						local nextDepth = depth+1
						local expandedProps = Properties.GetExpandedProps(prop)
						if #expandedProps > 0 then
							recur(expandedProps,nextDepth)
						end
					end
				end
			end
		end
		recur(props,1)

		inputProp = nil
		Properties.ViewWidth = maxWidth + 9 + Properties.EntryOffset
		Properties.UpdateView()
	end

	Properties.NewPropEntry = function(index)
		local newEntry = Properties.EntryTemplate:Clone()
		local nameFrame = newEntry.NameFrame
		local valueFrame = newEntry.ValueFrame
		local newCheckbox = Lib.Checkbox.new(1)
		newCheckbox.Gui.Position = UDim2.new(0,3,0,3)
		newCheckbox.Gui.Parent = valueFrame
		newCheckbox.OnInput:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			if prop.ValueType.Name == "PhysicalProperties" then
				Properties.SetProp(prop,newCheckbox.Toggled and true or nil)
			else
				Properties.SetProp(prop,newCheckbox.Toggled)
			end
		end)
		checkboxes[index] = newCheckbox

		local iconFrame = Main.MiscIcons:GetLabel()
		iconFrame.Position = UDim2.new(0,2,0,3)
		iconFrame.Parent = newEntry.ValueFrame.RightButton

		newEntry.Position = UDim2.new(0,0,0,23*(index-1))

		nameFrame.Expand.InputBegan:Connect(function(input)
			local prop = viewList[index + Properties.Index]
			if not prop or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

			local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

			Main.MiscIcons:DisplayByKey(newEntry.NameFrame.Expand.Icon, expanded[fullName] and "Collapse_Over" or "Expand_Over")
		end)

		nameFrame.Expand.InputEnded:Connect(function(input)
			local prop = viewList[index + Properties.Index]
			if not prop or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

			local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

			Main.MiscIcons:DisplayByKey(newEntry.NameFrame.Expand.Icon, expanded[fullName] and "Collapse" or "Expand")
		end)

		nameFrame.Expand.MouseButton1Down:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")
			if not prop.CategoryName and not Properties.ExpandableTypes[prop.ValueType and prop.ValueType.Name] and not Properties.ExpandableProps[fullName] then return end

			expanded[fullName] = not expanded[fullName]
			Properties.Update()
			Properties.Refresh()
		end)

		nameFrame.PropName.InputBegan:Connect(function(input)
			local prop = viewList[index + Properties.Index]
			if not prop then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement and not nameFrame.PropName.TextFits then
				local fullNameFrame = Properties.FullNameFrame	
				local nameArr = string.split(prop.Class.."."..prop.Name..(prop.SubName or ""),".")
				local dispName = prop.DisplayName or nameArr[#nameArr]
				local sizeX = service.TextService:GetTextSize(dispName,14,Enum.Font.SourceSans,Vector2.new(math.huge,20)).X

				fullNameFrame.TextLabel.Text = dispName
				--fullNameFrame.Position = UDim2.new(0,Properties.EntryIndent*(prop.Depth or 1) + Properties.EntryOffset,0,23*(index-1))
				fullNameFrame.Size = UDim2.new(0,sizeX + 4,0,22)
				fullNameFrame.Visible = true
				Properties.FullNameFrameIndex = index
				Properties.FullNameFrameAttach.SetData(fullNameFrame, {Target = nameFrame})
				Properties.FullNameFrameAttach.Enable()
			end
		end)

		nameFrame.PropName.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and Properties.FullNameFrameIndex == index then
				Properties.FullNameFrame.Visible = false
				Properties.FullNameFrameAttach.Disable()
			end
		end)

		valueFrame.ValueBox.MouseButton1Down:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			Properties.SetInputProp(prop,index)
		end)

		valueFrame.ColorButton.MouseButton1Down:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			Properties.SetInputProp(prop,index,"color")
		end)

		valueFrame.RightButton.MouseButton1Click:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
			local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))

			if fullName == inputFullName and inputProp.ValueType.Category == "Class" then
				inputProp = nil
				Properties.SetProp(prop,nil)
			else
				Properties.SetInputProp(prop,index,"right")
			end
		end)

		nameFrame.ToggleAttributes.MouseButton1Click:Connect(function()
			Settings.Properties.ShowAttributes = not Settings.Properties.ShowAttributes
			Properties.ShowExplorerProps()
		end)

		newEntry.RowButton.MouseButton1Click:Connect(function()
			Properties.DisplayAddAttributeWindow()
		end)

		newEntry.EditAttributeButton.MouseButton1Down:Connect(function()
			local prop = viewList[index + Properties.Index]
			if not prop then return end

			Properties.DisplayAttributeContext(prop)
		end)

		valueFrame.SoundPreview.ControlButton.MouseButton1Click:Connect(function()
			if Properties.PreviewSound and Properties.PreviewSound.Playing then
				Properties.SetSoundPreview(false)
			else
				local soundObj = Properties.FindFirstObjWhichIsA("Sound")
				if soundObj then Properties.SetSoundPreview(soundObj) end
			end
		end)

		valueFrame.SoundPreview.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

			local releaseEvent,mouseEvent
			releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				releaseEvent:Disconnect()
				mouseEvent:Disconnect()
			end)

			local timeLine = newEntry.ValueFrame.SoundPreview.TimeLine
			local soundObj = Properties.FindFirstObjWhichIsA("Sound")
			if soundObj then Properties.SetSoundPreview(soundObj,true) end

			local function update(input)
				local sound = Properties.PreviewSound
				if not sound or sound.TimeLength == 0 then return end

				local mouseX = input.Position.X
				local timeLineSize = timeLine.AbsoluteSize
				local relaX = mouseX - timeLine.AbsolutePosition.X

				if timeLineSize.X <= 1 then return end
				if relaX < 0 then relaX = 0 elseif relaX >= timeLineSize.X then relaX = timeLineSize.X-1 end

				local perc = (relaX/(timeLineSize.X-1))
				sound.TimePosition = perc*sound.TimeLength
				timeLine.Slider.Position = UDim2.new(perc,-4,0,-8)
			end
			update(input)

			mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					update(input)
				end
			end)
		end)

		newEntry.Parent = propsFrame

		return {
			Gui = newEntry,
			GuiElems = {
				NameFrame = nameFrame,
				ValueFrame = valueFrame,
				PropName = nameFrame.PropName,
				ValueBox = valueFrame.ValueBox,
				Expand = nameFrame.Expand,
				ColorButton = valueFrame.ColorButton,
				ColorPreview = valueFrame.ColorButton.ColorPreview,
				Gradient = valueFrame.ColorButton.ColorPreview.UIGradient,
				EnumArrow = valueFrame.EnumArrow,
				Checkbox = valueFrame.Checkbox,
				RightButton = valueFrame.RightButton,
				RightButtonIcon = iconFrame,
				RowButton = newEntry.RowButton,
				EditAttributeButton = newEntry.EditAttributeButton,
				ToggleAttributes = nameFrame.ToggleAttributes,
				SoundPreview = valueFrame.SoundPreview,
				SoundPreviewSlider = valueFrame.SoundPreview.TimeLine.Slider
			}
		}
	end

	Properties.GetSoundPreviewEntry = function()
		for i = 1,#viewList do
			if viewList[i] == Properties.SoundPreviewProp then
				return propEntries[i - Properties.Index]
			end
		end
	end

	Properties.SetSoundPreview = function(soundObj,noplay)
		local sound = Properties.PreviewSound
		if not sound then
			sound = Instance.new("Sound")
			sound.Name = "Preview"
			sound.Paused:Connect(function()
				local entry = Properties.GetSoundPreviewEntry()
				if entry then Main.MiscIcons:DisplayByKey(entry.GuiElems.SoundPreview.ControlButton.Icon, "Play") end
			end)
			sound.Resumed:Connect(function() Properties.Refresh() end)
			sound.Ended:Connect(function()
				local entry = Properties.GetSoundPreviewEntry()
				if entry then entry.GuiElems.SoundPreviewSlider.Position = UDim2.new(0,-4,0,-8) end
				Properties.Refresh()
			end)
			sound.Parent = window.Gui
			Properties.PreviewSound = sound
		end

		if not soundObj then
			sound:Pause()
		else
			local newId = sound.SoundId ~= soundObj.SoundId
			sound.SoundId = soundObj.SoundId
			sound.PlaybackSpeed = soundObj.PlaybackSpeed
			sound.Volume = soundObj.Volume
			if newId then sound.TimePosition = 0 end
			if not noplay then sound:Resume() end

			coroutine.wrap(function()
				local previewTime = tick()
				Properties.SoundPreviewTime = previewTime
				while previewTime == Properties.SoundPreviewTime and sound.Playing do
					local entry = Properties.GetSoundPreviewEntry()
					if entry then
						local tl = sound.TimeLength
						local perc = sound.TimePosition/(tl == 0 and 1 or tl)
						entry.GuiElems.SoundPreviewSlider.Position = UDim2.new(perc,-4,0,-8)
					end
					Lib.FastWait()
				end
			end)()
			Properties.Refresh()
		end
	end

	Properties.DisplayAttributeContext = function(prop)
		local context = Properties.AttributeContext
		if not context then
			context = Lib.ContextMenu.new()
			context.Iconless = true
			context.Width = 80
		end
		context:Clear()

		context:Add({Name = "Edit", OnClick = function()
			Properties.DisplayAddAttributeWindow(prop)
		end})
		context:Add({Name = "Delete", OnClick = function()
			Properties.SetProp(prop,nil,true)
			Properties.ShowExplorerProps()
		end})

		context:Show()
	end

	Properties.DisplayAddAttributeWindow = function(editAttr)
		local win = Properties.AddAttributeWindow
		if not win then
			win = Lib.Window.new()
			win.Alignable = false
			win.Resizable = false
			win:SetTitle("Add Attribute")
			win:SetSize(200,130)

			local saveButton = Lib.Button.new()
			local nameLabel = Lib.Label.new()
			nameLabel.Text = "Name"
			nameLabel.Position = UDim2.new(0,30,0,10)
			nameLabel.Size = UDim2.new(0,40,0,20)
			win:Add(nameLabel)

			local nameBox = Lib.ViewportTextBox.new()
			nameBox.Position = UDim2.new(0,75,0,10)
			nameBox.Size = UDim2.new(0,120,0,20)
			win:Add(nameBox,"NameBox")
			nameBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				saveButton:SetDisabled(#nameBox:GetText() == 0)
			end)

			local typeLabel = Lib.Label.new()
			typeLabel.Text = "Type"
			typeLabel.Position = UDim2.new(0,30,0,40)
			typeLabel.Size = UDim2.new(0,40,0,20)
			win:Add(typeLabel)

			local typeChooser = Lib.DropDown.new()
			typeChooser.CanBeEmpty = false
			typeChooser.Position = UDim2.new(0,75,0,40)
			typeChooser.Size = UDim2.new(0,120,0,20)
			typeChooser:SetOptions(Properties.AllowedAttributeTypes)
			win:Add(typeChooser,"TypeChooser")

			local errorLabel = Lib.Label.new()
			errorLabel.Text = ""
			errorLabel.Position = UDim2.new(0,5,1,-45)
			errorLabel.Size = UDim2.new(1,-10,0,20)
			errorLabel.TextColor3 = Settings.Theme.Important
			win.ErrorLabel = errorLabel
			win:Add(errorLabel,"Error")

			local cancelButton = Lib.Button.new()
			cancelButton.Text = "Cancel"
			cancelButton.Position = UDim2.new(1,-97,1,-25)
			cancelButton.Size = UDim2.new(0,92,0,20)
			cancelButton.OnClick:Connect(function()
				win:Close()
			end)
			win:Add(cancelButton)

			saveButton.Text = "Save"
			saveButton.Position = UDim2.new(0,5,1,-25)
			saveButton.Size = UDim2.new(0,92,0,20)
			saveButton.OnClick:Connect(function()
				local name = nameBox:GetText()
				if #name > 100 then
					errorLabel.Text = "Error: Name over 100 chars"
					return
				elseif name:sub(1,3) == "RBX" then
					errorLabel.Text = "Error: Name begins with 'RBX'"
					return
				end

				local typ = typeChooser.Selected
				local valType = {Name = Properties.TypeNameConvert[typ] or typ, Category = "DataType"}
				local attrProp = {IsAttribute = true, Name = "ATTR_"..name, AttributeName = name, DisplayName = name, Class = "Instance", ValueType = valType, Category = "Attributes", Tags = {}}

				Settings.Properties.ShowAttributes = true
				Properties.SetProp(attrProp,Properties.DefaultPropValue[valType.Name],true,Properties.EditingAttribute)
				Properties.ShowExplorerProps()
				win:Close()
			end)
			win:Add(saveButton,"SaveButton")

			Properties.AddAttributeWindow = win
		end

		Properties.EditingAttribute = editAttr
		win:SetTitle(editAttr and "Edit Attribute "..editAttr.AttributeName or "Add Attribute")
		win.Elements.Error.Text = ""
		win.Elements.NameBox:SetText("")
		win.Elements.SaveButton:SetDisabled(true)
		win.Elements.TypeChooser:SetSelected(1)
		win:Show()
	end

	Properties.IsTextEditable = function(prop)
		local typeData = prop.ValueType
		local typeName = typeData.Name

		return typeName ~= "bool" and typeData.Category ~= "Enum" and typeData.Category ~= "Class" and typeName ~= "BrickColor"
	end

	Properties.DisplayEnumDropdown = function(entryIndex)
		local context = Properties.EnumContext
		if not context then
			context = Lib.ContextMenu.new()
			context.Iconless = true
			context.MaxHeight = 200
			context.ReverseYOffset = 22
			Properties.EnumDropdown = context
		end

		if not inputProp or inputProp.ValueType.Category ~= "Enum" then return end
		local prop = inputProp

		local entry = propEntries[entryIndex]
		local valueFrame = entry.GuiElems.ValueFrame

		local enum = Enum[prop.ValueType.Name]
		if not enum then return end

		local sorted = {}
		for name,enum in next,enum:GetEnumItems() do
			sorted[#sorted+1] = enum
		end
		table.sort(sorted,function(a,b) return a.Name < b.Name end)

		context:Clear()

		local function onClick(name)
			if prop ~= inputProp then return end

			local enumItem = enum[name]
			inputProp = nil
			Properties.SetProp(prop,enumItem)
		end

		for i = 1,#sorted do
			local enumItem = sorted[i]
			context:Add({Name = enumItem.Name, OnClick = onClick})
		end

		context.Width = valueFrame.AbsoluteSize.X
		context:Show(valueFrame.AbsolutePosition.X, valueFrame.AbsolutePosition.Y + 22)
	end

	Properties.DisplayBrickColorEditor = function(prop,entryIndex,col)
		local editor = Properties.BrickColorEditor
		if not editor then
			editor = Lib.BrickColorPicker.new()
			editor.Gui.DisplayOrder = Main.DisplayOrders.Menu
			editor.ReverseYOffset = 22

			editor.OnSelect:Connect(function(col)
				if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "BrickColor" then return end

				if editor.CurrentProp == inputProp then inputProp = nil end
				Properties.SetProp(editor.CurrentProp,BrickColor.new(col))
			end)

			editor.OnMoreColors:Connect(function() -- TODO: Special Case BasePart.BrickColor to BasePart.Color
				editor:Close()
				local colProp
				for i,v in pairs(API.Classes.BasePart.Properties) do
					if v.Name == "Color" then
						colProp = v
						break
					end
				end
				Properties.DisplayColorEditor(colProp,editor.SavedColor.Color)
			end)

			Properties.BrickColorEditor = editor
		end

		local entry = propEntries[entryIndex]
		local valueFrame = entry.GuiElems.ValueFrame

		editor.CurrentProp = prop
		editor.SavedColor = col
		if prop and prop.Class == "BasePart" and prop.Name == "BrickColor" then
			editor:SetMoreColorsVisible(true)
		else
			editor:SetMoreColorsVisible(false)
		end
		editor:Show(valueFrame.AbsolutePosition.X, valueFrame.AbsolutePosition.Y + 22)
	end

	Properties.DisplayColorEditor = function(prop,col)
		local editor = Properties.ColorEditor
		if not editor then
			editor = Lib.ColorPicker.new()

			editor.OnSelect:Connect(function(col)
				if not editor.CurrentProp then return end
				local typeName = editor.CurrentProp.ValueType.Name
				if typeName ~= "Color3" and typeName ~= "BrickColor" then return end

				local colVal = (typeName == "Color3" and col or BrickColor.new(col))

				if editor.CurrentProp == inputProp then inputProp = nil end
				Properties.SetProp(editor.CurrentProp,colVal)
			end)

			Properties.ColorEditor = editor
		end

		editor.CurrentProp = prop
		if col then
			editor:SetColor(col)
		else
			local firstVal = Properties.GetFirstPropVal(prop)
			if firstVal then editor:SetColor(firstVal) end
		end
		editor:Show()
	end

	Properties.DisplayNumberSequenceEditor = function(prop,seq)
		local editor = Properties.NumberSequenceEditor
		if not editor then
			editor = Lib.NumberSequenceEditor.new()

			editor.OnSelect:Connect(function(val)
				if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "NumberSequence" then return end

				if editor.CurrentProp == inputProp then inputProp = nil end
				Properties.SetProp(editor.CurrentProp,val)
			end)

			Properties.NumberSequenceEditor = editor
		end

		editor.CurrentProp = prop
		if seq then
			editor:SetSequence(seq)
		else
			local firstVal = Properties.GetFirstPropVal(prop)
			if firstVal then editor:SetSequence(firstVal) end
		end
		editor:Show()
	end

	Properties.DisplayColorSequenceEditor = function(prop,seq)
		local editor = Properties.ColorSequenceEditor
		if not editor then
			editor = Lib.ColorSequenceEditor.new()

			editor.OnSelect:Connect(function(val)
				if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "ColorSequence" then return end

				if editor.CurrentProp == inputProp then inputProp = nil end
				Properties.SetProp(editor.CurrentProp,val)
			end)

			Properties.ColorSequenceEditor = editor
		end

		editor.CurrentProp = prop
		if seq then
			editor:SetSequence(seq)
		else
			local firstVal = Properties.GetFirstPropVal(prop)
			if firstVal then editor:SetSequence(firstVal) end
		end
		editor:Show()
	end

	Properties.GetFirstPropVal = function(prop)
		local first = Properties.FindFirstObjWhichIsA(prop.Class)
		if first then
			return Properties.GetPropVal(prop,first)
		end
	end

	Properties.GetPropVal = function(prop,obj)
		if prop.MultiType then return "<Multiple Types>" end
		if not obj then return end

		local propVal
		if prop.IsAttribute then
			propVal = getAttribute(obj,prop.AttributeName)
			if propVal == nil then return nil end

			local typ = typeof(propVal)
			local currentType = Properties.TypeNameConvert[typ] or typ
			if prop.RootType then
				if prop.RootType.Name ~= currentType then
					return nil
				end
			elseif prop.ValueType.Name ~= currentType then
				return nil
			end
		else
			propVal = obj[prop.Name]
		end
		if prop.SubName then
			local indexes = string.split(prop.SubName,".")
			for i = 1,#indexes do
				local indexName = indexes[i]
				if #indexName > 0 and propVal then
					propVal = propVal[indexName]
				end
			end
		end

		return propVal
	end

	Properties.SelectObject = function(obj)
		if inputProp and inputProp.ValueType.Category == "Class" then
			local prop = inputProp
			inputProp = nil

			if isa(obj,prop.ValueType.Name) then
				Properties.SetProp(prop,obj)
			else
				Properties.Refresh()
			end

			return true
		end

		return false
	end

	Properties.DisplayProp = function(prop,entryIndex)
		local propName = prop.Name
		local typeData = prop.ValueType
		local typeName = typeData.Name
		local tags = prop.Tags
		local gName = prop.Class.."."..prop.Name..(prop.SubName or "")
		local propObj = autoUpdateObjs[gName]
		local entryData = propEntries[entryIndex]
		local UDim2 = UDim2

		local guiElems = entryData.GuiElems
		local valueFrame = guiElems.ValueFrame
		local valueBox = guiElems.ValueBox
		local colorButton = guiElems.ColorButton
		local colorPreview = guiElems.ColorPreview
		local gradient = guiElems.Gradient
		local enumArrow = guiElems.EnumArrow
		local checkbox = guiElems.Checkbox
		local rightButton = guiElems.RightButton
		local soundPreview = guiElems.SoundPreview

		local propVal = Properties.GetPropVal(prop,propObj)
		local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))

		local offset = 4
		local endOffset = 6

		-- Offsetting the ValueBox for ValueType specific buttons
		if (typeName == "Color3" or typeName == "BrickColor" or typeName == "ColorSequence") then
			colorButton.Visible = true
			enumArrow.Visible = false
			if propVal then
				gradient.Color = (typeName == "Color3" and ColorSequence.new(propVal)) or (typeName == "BrickColor" and ColorSequence.new(propVal.Color)) or propVal
			else
				gradient.Color = ColorSequence.new(Color3.new(1,1,1))
			end
			colorPreview.BorderColor3 = (typeName == "ColorSequence" and Color3.new(1,1,1) or Color3.new(0,0,0))
			offset = 22
			endOffset = 24 + (typeName == "ColorSequence" and 20 or 0)
		elseif typeData.Category == "Enum" then
			colorButton.Visible = false
			enumArrow.Visible = not prop.Tags.ReadOnly
			endOffset = 22
		elseif (gName == inputFullName and typeData.Category == "Class") or typeName == "NumberSequence" then
			colorButton.Visible = false
			enumArrow.Visible = false
			endOffset = 26
		else
			colorButton.Visible = false
			enumArrow.Visible = false
		end

		valueBox.Position = UDim2.new(0,offset,0,0)
		valueBox.Size = UDim2.new(1,-endOffset,1,0)

		-- Right button
		if inputFullName == gName and typeData.Category == "Class" then
			Main.MiscIcons:DisplayByKey(guiElems.RightButtonIcon, "Delete")
			guiElems.RightButtonIcon.Visible = true
			rightButton.Text = ""
			rightButton.Visible = true
		elseif typeName == "NumberSequence" or typeName == "ColorSequence" then
			guiElems.RightButtonIcon.Visible = false
			rightButton.Text = "..."
			rightButton.Visible = true
		else
			rightButton.Visible = false
		end

		-- Displays the correct ValueBox for the ValueType, and sets it to the prop value
		if typeName == "bool" or typeName == "PhysicalProperties" then
			valueBox.Visible = false
			checkbox.Visible = true
			soundPreview.Visible = false
			checkboxes[entryIndex].Disabled = tags.ReadOnly
			if typeName == "PhysicalProperties" and autoUpdateObjs[gName] then
				checkboxes[entryIndex]:SetState(propVal and true or false)
			else
				checkboxes[entryIndex]:SetState(propVal)
			end
		elseif typeName == "SoundPlayer" then
			valueBox.Visible = false
			checkbox.Visible = false
			soundPreview.Visible = true
			local playing = Properties.PreviewSound and Properties.PreviewSound.Playing
			Main.MiscIcons:DisplayByKey(soundPreview.ControlButton.Icon, playing and "Pause" or "Play")
		else
			valueBox.Visible = true
			checkbox.Visible = false
			soundPreview.Visible = false

			if propVal ~= nil then
				if typeName == "Color3" then
					valueBox.Text = "["..Lib.ColorToBytes(propVal).."]"
				elseif typeData.Category == "Enum" then
					valueBox.Text = propVal.Name
				elseif Properties.RoundableTypes[typeName] and Settings.Properties.NumberRounding then
					local rawStr = Properties.ValueToString(prop,propVal)
					valueBox.Text = rawStr:gsub("-?%d+%.%d+",function(num)
						return tostring(tonumber(("%."..Settings.Properties.NumberRounding.."f"):format(num)))
					end)
				else
					valueBox.Text = Properties.ValueToString(prop,propVal)
				end
			else
				valueBox.Text = ""
			end

			valueBox.TextColor3 = tags.ReadOnly and Settings.Theme.PlaceholderText or Settings.Theme.Text
		end
	end

	Properties.Refresh = function()
		local maxEntries = math.max(math.ceil((propsFrame.AbsoluteSize.Y) / 23),0)	
		local maxX = propsFrame.AbsoluteSize.X
		local valueWidth = math.max(Properties.MinInputWidth,maxX-Properties.ViewWidth)
		local inputPropVisible = false
		local isa = game.IsA
		local UDim2 = UDim2
		local stringSplit = string.split
		local scaleType = Settings.Properties.ScaleType

		-- Clear connections
		for i = 1,#propCons do
			propCons[i]:Disconnect()
		end
		table.clear(propCons)

		-- Hide full name viewer
		Properties.FullNameFrame.Visible = false
		Properties.FullNameFrameAttach.Disable()

		for i = 1,maxEntries do
			local entryData = propEntries[i]
			if not propEntries[i] then entryData = Properties.NewPropEntry(i) propEntries[i] = entryData end

			local entry = entryData.Gui
			local guiElems = entryData.GuiElems
			local nameFrame = guiElems.NameFrame
			local propNameLabel = guiElems.PropName
			local valueFrame = guiElems.ValueFrame
			local expand = guiElems.Expand
			local valueBox = guiElems.ValueBox
			local propNameBox = guiElems.PropName
			local rightButton = guiElems.RightButton
			local editAttributeButton = guiElems.EditAttributeButton
			local toggleAttributes = guiElems.ToggleAttributes

			local prop = viewList[i + Properties.Index]
			if prop then
				local entryXOffset = (scaleType == 0 and scrollH.Index or 0)
				entry.Visible = true
				entry.Position = UDim2.new(0,-entryXOffset,0,entry.Position.Y.Offset)
				entry.Size = UDim2.new(scaleType == 0 and 0 or 1, scaleType == 0 and Properties.ViewWidth + valueWidth or 0,0,22)

				if prop.SpecialRow then
					if prop.SpecialRow == "AddAttribute" then
						nameFrame.Visible = false
						valueFrame.Visible = false
						guiElems.RowButton.Visible = true
					end
				else
					-- Revert special row stuff
					nameFrame.Visible = true
					guiElems.RowButton.Visible = false

					local depth = Properties.EntryIndent*(prop.Depth or 1)
					local leftOffset = depth + Properties.EntryOffset
					nameFrame.Position = UDim2.new(0,leftOffset,0,0)
					propNameLabel.Size = UDim2.new(1,-2 - (scaleType == 0 and 0 or 6),1,0)

					local gName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

					if prop.CategoryName then
						entry.BackgroundColor3 = Settings.Theme.Main1
						valueFrame.Visible = false

						propNameBox.Text = prop.CategoryName
						propNameBox.Font = Enum.Font.SourceSansBold
						expand.Visible = true
						propNameBox.TextColor3 = Settings.Theme.Text
						nameFrame.BackgroundTransparency = 1
						nameFrame.Size = UDim2.new(1,0,1,0)
						editAttributeButton.Visible = false

						local showingAttrs = Settings.Properties.ShowAttributes
						toggleAttributes.Position = UDim2.new(1,-85-leftOffset,0,0)
						toggleAttributes.Text = (showingAttrs and "[Setting: ON]" or "[Setting: OFF]")
						toggleAttributes.TextColor3 = Settings.Theme.Text
						toggleAttributes.Visible = (prop.CategoryName == "Attributes")
					else
						local propName = prop.Name
						local typeData = prop.ValueType
						local typeName = typeData.Name
						local tags = prop.Tags
						local propObj = autoUpdateObjs[gName]

						local attributeOffset = (prop.IsAttribute and 20 or 0)
						editAttributeButton.Visible = (prop.IsAttribute and not prop.RootType)
						toggleAttributes.Visible = false

						-- Moving around the frames
						if scaleType == 0 then
							nameFrame.Size = UDim2.new(0,Properties.ViewWidth - leftOffset - 1,1,0)
							valueFrame.Position = UDim2.new(0,Properties.ViewWidth,0,0)
							valueFrame.Size = UDim2.new(0,valueWidth - attributeOffset,1,0)
						else
							nameFrame.Size = UDim2.new(0.5,-leftOffset - 1,1,0)
							valueFrame.Position = UDim2.new(0.5,0,0,0)
							valueFrame.Size = UDim2.new(0.5,-attributeOffset,1,0)
						end

						local nameArr = stringSplit(gName,".")
						propNameBox.Text = prop.DisplayName or nameArr[#nameArr]
						propNameBox.Font = Enum.Font.SourceSans
						entry.BackgroundColor3 = Settings.Theme.Main2
						valueFrame.Visible = true

						expand.Visible = typeData.Category == "DataType" and Properties.ExpandableTypes[typeName] or Properties.ExpandableProps[gName]
						propNameBox.TextColor3 = tags.ReadOnly and Settings.Theme.PlaceholderText or Settings.Theme.Text

						-- Display property value
						Properties.DisplayProp(prop,i)
						if propObj then
							if prop.IsAttribute then
								propCons[#propCons+1] = getAttributeChangedSignal(propObj,prop.AttributeName):Connect(function()
									Properties.DisplayProp(prop,i)
								end)
							else
								propCons[#propCons+1] = getPropChangedSignal(propObj,propName):Connect(function()
									Properties.DisplayProp(prop,i)
								end)
							end
						end

						-- Position and resize Input Box
						local beforeVisible = valueBox.Visible
						local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))
						if gName == inputFullName then
							nameFrame.BackgroundColor3 = Settings.Theme.ListSelection
							nameFrame.BackgroundTransparency = 0
							if typeData.Category == "Class" or typeData.Category == "Enum" or typeName == "BrickColor" then
								valueFrame.BackgroundColor3 = Settings.Theme.TextBox
								valueFrame.BackgroundTransparency = 0
								valueBox.Visible = true
							else
								inputPropVisible = true
								local scale = (scaleType == 0 and 0 or 0.5)
								local offset = (scaleType == 0 and Properties.ViewWidth-scrollH.Index or 0)
								local endOffset = 0

								if typeName == "Color3" or typeName == "ColorSequence" then
									offset = offset + 22
								end

								if typeName == "NumberSequence" or typeName == "ColorSequence" then
									endOffset = 20
								end

								inputBox.Position = UDim2.new(scale,offset,0,entry.Position.Y.Offset)
								inputBox.Size = UDim2.new(1-scale,-offset-endOffset-attributeOffset,0,22)
								inputBox.Visible = true
								valueBox.Visible = false
							end
						else
							nameFrame.BackgroundColor3 = Settings.Theme.Main1
							nameFrame.BackgroundTransparency = 1
							valueFrame.BackgroundColor3 = Settings.Theme.Main1
							valueFrame.BackgroundTransparency = 1
							valueBox.Visible = beforeVisible
						end
					end

					-- Expand
					if prop.CategoryName or Properties.ExpandableTypes[prop.ValueType and prop.ValueType.Name] or Properties.ExpandableProps[gName] then
						if Lib.CheckMouseInGui(expand) then
							Main.MiscIcons:DisplayByKey(expand.Icon, expanded[gName] and "Collapse_Over" or "Expand_Over")
						else
							Main.MiscIcons:DisplayByKey(expand.Icon, expanded[gName] and "Collapse" or "Expand")
						end
						expand.Visible = true
					else
						expand.Visible = false
					end
				end
				entry.Visible = true
			else
				entry.Visible = false
			end
		end

		if not inputPropVisible then
			inputBox.Visible = false
		end

		for i = maxEntries+1,#propEntries do
			propEntries[i].Gui:Destroy()
			propEntries[i] = nil
			checkboxes[i] = nil
		end
	end

	Properties.SetProp = function(prop,val,noupdate,prevAttribute)
		local sList = Explorer.Selection.List
		local propName = prop.Name
		local subName = prop.SubName
		local propClass = prop.Class
		local typeData = prop.ValueType
		local typeName = typeData.Name
		local attributeName = prop.AttributeName
		local rootTypeData = prop.RootType
		local rootTypeName = rootTypeData and rootTypeData.Name
		local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
		local Vector3 = Vector3

		for i = 1,#sList do
			local node = sList[i]
			local obj = node.Obj

			if isa(obj,propClass) then
				pcall(function()
					local setVal = val
					local root
					if prop.IsAttribute then
						root = getAttribute(obj,attributeName)
					else
						root = obj[propName]
					end

					if prevAttribute then
						if prevAttribute.ValueType.Name == typeName then
							setVal = getAttribute(obj,prevAttribute.AttributeName) or setVal
						end
						setAttribute(obj,prevAttribute.AttributeName,nil)
					end

					if rootTypeName then
						if rootTypeName == "Vector2" then
							setVal = Vector2.new((subName == ".X" and setVal) or root.X, (subName == ".Y" and setVal) or root.Y)
						elseif rootTypeName == "Vector3" then
							setVal = Vector3.new((subName == ".X" and setVal) or root.X, (subName == ".Y" and setVal) or root.Y, (subName == ".Z" and setVal) or root.Z)
						elseif rootTypeName == "UDim" then
							setVal = UDim.new((subName == ".Scale" and setVal) or root.Scale, (subName == ".Offset" and setVal) or root.Offset)
						elseif rootTypeName == "UDim2" then
							local rootX,rootY = root.X,root.Y
							local X_UDim = (subName == ".X" and setVal) or UDim.new((subName == ".X.Scale" and setVal) or rootX.Scale, (subName == ".X.Offset" and setVal) or rootX.Offset)
							local Y_UDim = (subName == ".Y" and setVal) or UDim.new((subName == ".Y.Scale" and setVal) or rootY.Scale, (subName == ".Y.Offset" and setVal) or rootY.Offset)
							setVal = UDim2.new(X_UDim,Y_UDim)
						elseif rootTypeName == "CFrame" then
							local rootPos,rootRight,rootUp,rootLook = root.Position,root.RightVector,root.UpVector,root.LookVector
							local pos = (subName == ".Position" and setVal) or Vector3.new((subName == ".Position.X" and setVal) or rootPos.X, (subName == ".Position.Y" and setVal) or rootPos.Y, (subName == ".Position.Z" and setVal) or rootPos.Z)
							local rightV = (subName == ".RightVector" and setVal) or Vector3.new((subName == ".RightVector.X" and setVal) or rootRight.X, (subName == ".RightVector.Y" and setVal) or rootRight.Y, (subName == ".RightVector.Z" and setVal) or rootRight.Z)
							local upV = (subName == ".UpVector" and setVal) or Vector3.new((subName == ".UpVector.X" and setVal) or rootUp.X, (subName == ".UpVector.Y" and setVal) or rootUp.Y, (subName == ".UpVector.Z" and setVal) or rootUp.Z)
							local lookV = (subName == ".LookVector" and setVal) or Vector3.new((subName == ".LookVector.X" and setVal) or rootLook.X, (subName == ".RightVector.Y" and setVal) or rootLook.Y, (subName == ".RightVector.Z" and setVal) or rootLook.Z)
							setVal = CFrame.fromMatrix(pos,rightV,upV,-lookV)
						elseif rootTypeName == "Rect" then
							local rootMin,rootMax = root.Min,root.Max
							local min = Vector2.new((subName == ".Min.X" and setVal) or rootMin.X, (subName == ".Min.Y" and setVal) or rootMin.Y)
							local max = Vector2.new((subName == ".Max.X" and setVal) or rootMax.X, (subName == ".Max.Y" and setVal) or rootMax.Y)
							setVal = Rect.new(min,max)
						elseif rootTypeName == "PhysicalProperties" then
							local rootProps = PhysicalProperties.new(obj.Material)
							local density = (subName == ".Density" and setVal) or (root and root.Density) or rootProps.Density
							local friction = (subName == ".Friction" and setVal) or (root and root.Friction) or rootProps.Friction
							local elasticity = (subName == ".Elasticity" and setVal) or (root and root.Elasticity) or rootProps.Elasticity
							local frictionWeight = (subName == ".FrictionWeight" and setVal) or (root and root.FrictionWeight) or rootProps.FrictionWeight
							local elasticityWeight = (subName == ".ElasticityWeight" and setVal) or (root and root.ElasticityWeight) or rootProps.ElasticityWeight
							setVal = PhysicalProperties.new(density,friction,elasticity,frictionWeight,elasticityWeight)
						elseif rootTypeName == "Ray" then
							local rootOrigin,rootDirection = root.Origin,root.Direction
							local origin = (subName == ".Origin" and setVal) or Vector3.new((subName == ".Origin.X" and setVal) or rootOrigin.X, (subName == ".Origin.Y" and setVal) or rootOrigin.Y, (subName == ".Origin.Z" and setVal) or rootOrigin.Z)
							local direction = (subName == ".Direction" and setVal) or Vector3.new((subName == ".Direction.X" and setVal) or rootDirection.X, (subName == ".Direction.Y" and setVal) or rootDirection.Y, (subName == ".Direction.Z" and setVal) or rootDirection.Z)
							setVal = Ray.new(origin,direction)
						elseif rootTypeName == "Faces" then
							local faces = {}
							local faceList = {"Back","Bottom","Front","Left","Right","Top"}
							for _,face in pairs(faceList) do
								local val
								if subName == "."..face then
									val = setVal
								else
									val = root[face]
								end
								if val then faces[#faces+1] = Enum.NormalId[face] end
							end
							setVal = Faces.new(unpack(faces))
						elseif rootTypeName == "Axes" then
							local axes = {}
							local axesList = {"X","Y","Z"}
							for _,axe in pairs(axesList) do
								local val
								if subName == "."..axe then
									val = setVal
								else
									val = root[axe]
								end
								if val then axes[#axes+1] = Enum.Axis[axe] end
							end
							setVal = Axes.new(unpack(axes))
						elseif rootTypeName == "NumberRange" then
							setVal = NumberRange.new(subName == ".Min" and setVal or root.Min, subName == ".Max" and setVal or root.Max)
						end
					end

					if typeName == "PhysicalProperties" and setVal then
						setVal = root or PhysicalProperties.new(obj.Material)
					end

					if prop.IsAttribute then
						setAttribute(obj,attributeName,setVal)
					else
						obj[propName] = setVal
					end
				end)
			end
		end

		if not noupdate then
			Properties.ComputeConflicts(prop)
		end
	end

	Properties.InitInputBox = function()
		inputBox = create({
			{1,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderSizePixel=0,Name="InputBox",Size=UDim2.new(0,200,0,22),Visible=false,ZIndex=2,}},
			{2,"TextBox",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BackgroundTransparency=1,BorderColor3=Color3.new(0.062745101749897,0.51764708757401,1),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Parent={1},PlaceholderColor3=Color3.new(0.69803923368454,0.69803923368454,0.69803923368454),Position=UDim2.new(0,3,0,0),Size=UDim2.new(1,-6,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=2,}},
		})
		inputTextBox = inputBox.TextBox
		inputBox.BackgroundColor3 = Settings.Theme.TextBox
		inputBox.Parent = Properties.Window.GuiElems.Content.List

		inputTextBox.FocusLost:Connect(function()
			if not inputProp then return end

			local prop = inputProp
			inputProp = nil
			local val = Properties.StringToValue(prop,inputTextBox.Text)
			if val then Properties.SetProp(prop,val) else Properties.Refresh() end
		end)

		inputTextBox.Focused:Connect(function()
			inputTextBox.SelectionStart = 1
			inputTextBox.CursorPosition = #inputTextBox.Text + 1
		end)

		Lib.ViewportTextBox.convert(inputTextBox)
	end

	Properties.SetInputProp = function(prop,entryIndex,special)
		local typeData = prop.ValueType
		local typeName = typeData.Name
		local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
		local propObj = autoUpdateObjs[fullName]
		local propVal = Properties.GetPropVal(prop,propObj)

		if prop.Tags.ReadOnly then return end

		inputProp = prop
		if special then
			if special == "color" then
				if typeName == "Color3" then
					inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
					Properties.DisplayColorEditor(prop,propVal)
				elseif typeName == "BrickColor" then
					Properties.DisplayBrickColorEditor(prop,entryIndex,propVal)
				elseif typeName == "ColorSequence" then
					inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
					Properties.DisplayColorSequenceEditor(prop,propVal)
				end
			elseif special == "right" then
				if typeName == "NumberSequence" then
					inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
					Properties.DisplayNumberSequenceEditor(prop,propVal)
				elseif typeName == "ColorSequence" then
					inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
					Properties.DisplayColorSequenceEditor(prop,propVal)
				end
			end
		else
			if Properties.IsTextEditable(prop) then
				inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
				inputTextBox:CaptureFocus()
			elseif typeData.Category == "Enum" then
				Properties.DisplayEnumDropdown(entryIndex)
			elseif typeName == "BrickColor" then
				Properties.DisplayBrickColorEditor(prop,entryIndex,propVal)
			end
		end
		Properties.Refresh()
	end

	Properties.InitSearch = function()
		local searchBox = Properties.GuiElems.ToolBar.SearchFrame.SearchBox

		Lib.ViewportTextBox.convert(searchBox)

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			Properties.SearchText = searchBox.Text
			Properties.Update()
			Properties.Refresh()
		end)
	end

	Properties.InitEntryStuff = function()
		Properties.EntryTemplate = create({
			{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Font=3,Name="Entry",Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,250,0,22),Text="",TextSize=14,}},
			{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="NameFrame",Parent={1},Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-40,1,0),}},
			{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="PropName",Parent={2},Position=UDim2.new(0,2,0,0),Size=UDim2.new(1,-2,1,0),Text="Anchored",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextXAlignment=0,}},
			{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Font=3,Name="Expand",Parent={2},Position=UDim2.new(0,-20,0,1),Size=UDim2.new(0,20,0,20),Text="",TextSize=14,Visible=false,}},
			{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={4},Position=UDim2.new(0,2,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
			{6,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=4,Name="ToggleAttributes",Parent={2},Position=UDim2.new(1,-85,0,0),Size=UDim2.new(0,85,0,22),Text="[SETTING: OFF]",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,Visible=false,}},
			{7,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019607901573,0.73725491762161),BorderSizePixel=0,Name="ValueFrame",Parent={1},Position=UDim2.new(1,-100,0,0),Size=UDim2.new(0,80,1,0),}},
			{8,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="Line",Parent={7},Position=UDim2.new(0,-1,0,0),Size=UDim2.new(0,1,1,0),}},
			{9,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="ColorButton",Parent={7},Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
			{10,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),Name="ColorPreview",Parent={9},Position=UDim2.new(0,5,0,6),Size=UDim2.new(0,10,0,10),}},
			{11,"UIGradient",{Parent={10},}},
			{12,"Frame",{BackgroundTransparency=1,Name="EnumArrow",Parent={7},Position=UDim2.new(1,-16,0,3),Size=UDim2.new(0,16,0,16),Visible=false,}},
			{13,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,8,0,9),Size=UDim2.new(0,1,0,1),}},
			{14,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,7,0,8),Size=UDim2.new(0,3,0,1),}},
			{15,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,1),}},
			{16,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="ValueBox",Parent={7},Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-8,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextXAlignment=0,}},
			{17,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="RightButton",Parent={7},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="...",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
			{18,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SettingsButton",Parent={7},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
			{19,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="SoundPreview",Parent={7},Size=UDim2.new(1,0,1,0),Visible=false,}},
			{20,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="ControlButton",Parent={19},Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{21,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={20},Position=UDim2.new(0,2,0,3),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
			{22,"Frame",{BackgroundColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="TimeLine",Parent={19},Position=UDim2.new(0,26,0.5,-1),Size=UDim2.new(1,-34,0,2),}},
			{23,"Frame",{BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Name="Slider",Parent={22},Position=UDim2.new(0,-4,0,-8),Size=UDim2.new(0,8,0,18),}},
			{24,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="EditAttributeButton",Parent={1},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{25,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718180",ImageTransparency=0.20000000298023,Name="Icon",Parent={24},Position=UDim2.new(0,2,0,3),Size=UDim2.new(0,16,0,16),}},
			{26,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderSizePixel=0,Font=3,Name="RowButton",Parent={1},Size=UDim2.new(1,0,1,0),Text="Add Attribute",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,Visible=false,}},
			--{27,"UIStroke",{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(33,33,33),Thickness=1,Parent={1}}}
		})

		local fullNameFrame = Lib.Frame.new()
		local label = Lib.Label.new()
		label.Parent = fullNameFrame.Gui
		label.Position = UDim2.new(0,2,0,0)
		label.Size = UDim2.new(1,-4,1,0)
		fullNameFrame.Visible = false
		fullNameFrame.Parent = window.Gui
		
		if Settings.Window.Transparency and Settings.Window.Transparency > 0 then
			Properties.EntryTemplate.BackgroundTransparency = 0.75
		end


		Properties.FullNameFrame = fullNameFrame
		Properties.FullNameFrameAttach = Lib.AttachTo(fullNameFrame)
	end

	Properties.Init = function() -- TODO: MAKE BETTER
		local guiItems = create({
			{1,"Folder",{Name="Items",}},
			{2,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ToolBar",Parent={1},Size=UDim2.new(1,0,0,22),}},
			{3,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchFrame",Parent={2},Position=UDim2.new(0,3,0,1),Size=UDim2.new(1,-6,0,18),}},
			{4,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Name="SearchBox",Parent={3},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search properties",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-24,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
			{5,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
			{6,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Reset",Parent={3},Position=UDim2.new(1,-17,0,1),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{7,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718129",ImageColor3=Color3.new(0.39215686917305,0.39215686917305,0.39215686917305),Parent={6},Size=UDim2.new(0,16,0,16),}},
			{8,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Refresh",Parent={2},Position=UDim2.new(1,-20,0,1),Size=UDim2.new(0,18,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
			{9,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642310344",Parent={8},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,12,0,12),}},
			{10,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Parent={1},Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}},
			{11,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Name="List",Parent={1},Position=UDim2.new(0,0,0,23),Size=UDim2.new(1,0,1,-23),}},
		})

		-- Vars
		categoryOrder =  API.CategoryOrder
		for category,_ in next,categoryOrder do
			if not Properties.CollapsedCategories[category] then
				expanded["CAT_"..category] = true
			end
		end
		expanded["Sound.SoundId"] = true

		-- Init window
		window = Lib.Window.new()
		Properties.Window = window
		window:SetTitle("Properties")

		toolBar = guiItems.ToolBar
		propsFrame = guiItems.List

		Properties.GuiElems.ToolBar = toolBar
		Properties.GuiElems.PropsFrame = propsFrame

		Properties.InitEntryStuff()

		-- Window events
		window.GuiElems.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if Properties.Window:IsContentVisible() then
				Properties.UpdateView()
				Properties.Refresh()
			end
		end)
		window.OnActivate:Connect(function()
			Properties.UpdateView()
			Properties.Update()
			Properties.Refresh()
		end)
		window.OnRestore:Connect(function()
			Properties.UpdateView()
			Properties.Update()
			Properties.Refresh()
		end)

		-- Init scrollbars
		scrollV = Lib.ScrollBar.new()		
		scrollV.WheelIncrement = 3
		scrollV.Gui.Position = UDim2.new(1,-16,0,23)
		scrollV:SetScrollFrame(propsFrame)
		scrollV.Scrolled:Connect(function()
			Properties.Index = scrollV.Index
			Properties.Refresh()
		end)

		scrollH = Lib.ScrollBar.new(true)
		scrollH.Increment = 5
		scrollH.WheelIncrement = 20
		scrollH.Gui.Position = UDim2.new(0,0,1,-16)
		scrollH.Scrolled:Connect(function()
			Properties.Refresh()
		end)

		-- Setup Gui
		window.GuiElems.Line.Position = UDim2.new(0,0,0,22)
		toolBar.Parent = window.GuiElems.Content
		propsFrame.Parent = window.GuiElems.Content
		guiItems.ScrollCorner.Parent = window.GuiElems.Content
		scrollV.Gui.Parent = window.GuiElems.Content
		scrollH.Gui.Parent = window.GuiElems.Content
		Properties.InitInputBox()
		Properties.InitSearch()
	end

	return Properties
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
end,
["SaveInstance"] = function()
--[[
	Save Instance App Module
	
	Revival of the old dex's Save Instance
]] 

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, SaveInstance, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	SaveInstance = Apps.SaveInstance
	Notebook = Apps.Notebook
end

local function main()
	local SaveInstance = {}
	local window, ListFrame
	local fileName = "Place_"..game.PlaceId.."_"..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name.."_{TIMESTAMP}"
	local Saving = false
	
	local SaveInstanceArgs = {
		Decompile = true,
		DecompileTimeout = 10,
		DecompileIgnore = {"Chat", "CoreGui", "CorePackages"},
		NilInstances = false,
		RemovePlayerCharacters = true,
		SavePlayers = false,
		MaxThreads = 3,
		ShowStatus = true,
		IgnoreDefaultProps = true,
		IsolateStarterPlayer = true
	}
	
	local function AddCheckbox(title, default)
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)
		
		local listlayout = Instance.new("UIListLayout")
		listlayout.Parent = frame.Gui
		listlayout.FillDirection = Enum.FillDirection.Horizontal
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listlayout.Padding = UDim.new(0, 10)
		
		-- Checkbox
		local checkbox = Lib.Checkbox.new()
		
		checkbox.Gui.Parent = frame.Gui
		checkbox.Gui.Size = UDim2.new(0,15,0,15)
		
		-- Label
		local label = Lib.Label.new()
		
		label.Gui.Parent = frame.Gui
		label.Gui.Size = UDim2.new(1, 0,1, -15)
		label.Gui.Text = title
		label.TextTruncate = Enum.TextTruncate.AtEnd
		
		checkbox:SetState(default)
		
		return checkbox
	end
	
	local function AddTextbox(title, default, sizeX)
		default = tostring(default)
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)

		local listlayout = Instance.new("UIListLayout")
		listlayout.Parent = frame.Gui
		listlayout.FillDirection = Enum.FillDirection.Horizontal
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listlayout.Padding = UDim.new(0, 10)

		-- Textbox
		local textbox = Instance.new("TextBox") -- replaced cuz why Moon make every inputs only work on mouse/pc users >:( 
		textbox.BackgroundColor3 = Settings.Theme.TextBox
		textbox.BorderColor3 = Settings.Theme.Outline3
		textbox.ClearTextOnFocus = false
		textbox.TextColor3 = Settings.Theme.Text
		textbox.Font = Enum.Font.SourceSans
		textbox.TextSize = 14
		textbox.ZIndex = 2

		textbox.Parent = frame.Gui
		if sizeX and type(sizeX) == "number" then
			textbox.Size = UDim2.new(0,sizeX,0,15)
		else
			textbox.Size = UDim2.new(0,45,0,15)
		end
		
		frame.Gui.AutomaticSize = Enum.AutomaticSize.X
		textbox.AutomaticSize = Enum.AutomaticSize.X

		-- Label
		local label = Lib.Label.new()

		label.Parent = frame.Gui
		label.Size = UDim2.new(1, 0,1, -15)
		label.Text = title
		label.TextTruncate = Enum.TextTruncate.AtEnd

		textbox.Text = default

		return {TextBox = textbox}
	end
	
	SaveInstance.Init = function()
		window = Lib.Window.new()
		window:SetTitle("Save Instance")
		window:Resize(350,350)
		SaveInstance.Window = window
		
		-- ListFrame
		
		-- Fake ScrollBar dex, because its too advanced
		ListFrame = Instance.new("ScrollingFrame")
		ListFrame.Parent = window.GuiElems.Content
		ListFrame.Size = UDim2.new(1, 0,1, -40)
		ListFrame.Position = UDim2.new(0, 0, 0, 0)
		ListFrame.Transparency = 1
		ListFrame.CanvasSize = UDim2.new(0,0,0,0)
		ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ListFrame.ScrollBarThickness = 16
		ListFrame.BottomImage = ""
		ListFrame.TopImage = ""
		ListFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
		ListFrame.ScrollBarImageTransparency = 0
		ListFrame.ZIndex = 2
		ListFrame.BorderSizePixel = 0
		
		local scrollbar = Lib.ScrollBar.new()
		scrollbar.Gui.Parent = window.GuiElems.Content
		scrollbar.Gui.Size = UDim2.new(1, 0,1, -40)
		scrollbar.Gui.Up.ZIndex = 3
		scrollbar.Gui.Down.ZIndex = 3
		
		ListFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
			if ListFrame.AbsoluteCanvasSize ~= ListFrame.AbsoluteWindowSize then
				scrollbar.Gui.Visible = true
			else
				scrollbar.Gui.Visible = false
			end
		end)
		
		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = ListFrame
		ListLayout.Padding = UDim.new(0, 5)
		
		local Padding = Instance.new("UIPadding")
		Padding.Parent = ListFrame
		Padding.PaddingBottom = UDim.new(0, 5)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)
		Padding.PaddingTop = UDim.new(0, 5)
		
		-- Options
		
		local Decompile = AddCheckbox("Decompile Scripts (LocalScript and ModuleScript)", SaveInstanceArgs.Decompile)
		Decompile.OnInput:Connect(function()
			SaveInstanceArgs.Decompile = Decompile.Toggled
		end)
		
		local decompileTimeout = AddTextbox("Decompile Timeout (s)", SaveInstanceArgs.DecompileTimeout, 15)
		decompileTimeout.TextBox.FocusLost:Connect(function()
			SaveInstanceArgs.DecompileTimeout = tonumber(decompileTimeout.TextBox.Text)
		end)
		
		local decompileThread = AddTextbox("Decompiler Max Threads", "3", 15)
		decompileThread.TextBox.FocusLost:Connect(function()
			SaveInstanceArgs.MaxThreads = tonumber(decompileThread.TextBox.Text)
		end)
		
		local decompileIgnore = AddTextbox("Decompile Ignore", table.concat(SaveInstanceArgs.DecompileIgnore, ","), 50)
		decompileIgnore.TextBox.FocusLost:Connect(function()
			local inputText = decompileIgnore.TextBox.Text
			local rawList = string.split(inputText, ", ") or string.split(inputText, ",")
			local finalList = {}

			for _, text in ipairs(rawList) do
				local split = string.split(text, ",") or string.split(text, ", ")
				for _, textFound in ipairs(split) do
					table.insert(finalList, textFound)
				end
			end
			SaveInstanceArgs.DecompileIgnore = finalList
		end)

		
		local NilObj = AddCheckbox("Save Nil Instances", SaveInstanceArgs.NilInstances)
		NilObj.OnInput:Connect(function()
			SaveInstanceArgs.NilInstances = NilObj.Toggled
		end)

		local RemovePlayerChar = AddCheckbox("Remove Player Characters", SaveInstanceArgs.RemovePlayerCharacters)
		RemovePlayerChar.OnInput:Connect(function()
			SaveInstanceArgs.RemovePlayerCharacters = RemovePlayerChar.Toggled
		end)
		
		local SavePlayerObj = AddCheckbox("Save Player Instance", SaveInstanceArgs.SavePlayers)
		SavePlayerObj.OnInput:Connect(function()
			SaveInstanceArgs.SavePlayers = SavePlayerObj.Toggled
		end)
		
		local IsolateStarterPlr = AddCheckbox("Isolate StarterPlayer", SaveInstanceArgs.IsolateStarterPlayer)
		IsolateStarterPlr.OnInput:Connect(function()
			SaveInstanceArgs.IsolateStarterPlayer = IsolateStarterPlr.Toggled
		end)
		
		local IgnoreDefaultProps = AddCheckbox("Ignore Default Properties", SaveInstanceArgs.IgnoreDefaultProps)
		IgnoreDefaultProps.OnInput:Connect(function()
			SaveInstanceArgs.IgnoreDefaultProps = IgnoreDefaultProps.Toggled
		end)
		
		local ShowStat = AddCheckbox("Show Status", SaveInstanceArgs.ShowStatus)
		ShowStat.OnInput:Connect(function()
			SaveInstanceArgs.ShowStatus = ShowStat.Toggled
		end)
		
		
		-- Decompile buttons below
		local FilenameTextBox = Lib.ViewportTextBox.new()
		FilenameTextBox.Gui.Parent = window.GuiElems.Content
		FilenameTextBox.Size = UDim2.new(1,0, 0,20)
		FilenameTextBox.Position = UDim2.new(0,0, 1,-40)
		
		local textpadding = Instance.new("UIPadding")
		textpadding.Parent = FilenameTextBox.Gui
		textpadding.PaddingLeft = UDim.new(0, 5)
		textpadding.PaddingRight = UDim.new(0, 5)
		
		local BackgroundButton = Lib.Frame.new()
		BackgroundButton.Gui.Parent = window.GuiElems.Content
		BackgroundButton.Size = UDim2.new(1,0, 0,20)
		BackgroundButton.Position = UDim2.new(0,0, 1,-20)
		
		local LabelButton = Lib.Label.new()
		LabelButton.Gui.Parent = window.GuiElems.Content
		LabelButton.Size = UDim2.new(1,0, 0,20)
		LabelButton.Position = UDim2.new(0,0, 1,-20)
		LabelButton.Gui.Text = "Save"
		LabelButton.Gui.TextXAlignment = Enum.TextXAlignment.Center
		
		local Button = Instance.new("TextButton")
		Button.Parent = BackgroundButton.Gui
		Button.Size = UDim2.new(1,0, 1,0)
		Button.Position = UDim2.new(0,0, 0,0)
		Button.Transparency = 1
		
		FilenameTextBox.TextBox.Text = fileName
		Button.MouseButton1Click:Connect(function()
			local fileName = FilenameTextBox.TextBox.Text:gsub("{TIMESTAMP}", os.date("%d-%m-%Y_%H-%M-%S"))
			window:SetTitle("Save Instance - Saving")
			local s, result = pcall(env.saveinstance, game, fileName, SaveInstanceArgs)
			if s then
				window:SetTitle("Save Instance - Saved")
			else
				window:SetTitle("Save Instance - Error")
				task.spawn(error("Failed to save the game: "..result))
			end
			task.wait(5)
			window:SetTitle("Save Instance")
			---env.saveinstance(game, fileName, SaveInstanceArgs)
		end)
	end

	return SaveInstance
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
end,
["ScriptViewer"] = function()
--[[
	Script Viewer App Module
	
	A script viewer that is basically a notepad
]]
-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local executorName = "Unknown"
local executorVersion = "???"
if identifyexecutor then
	local name,ver = identifyexecutor()
	executorName = name
	executorVersion = ver
elseif game:GetService("RunService"):IsStudio() then
	executorName = "Studio"
	executorVersion = version()
end

local function getPath(obj)
	if obj.Parent == nil then
		return "Nil parented"
	else
		return Explorer.GetInstancePath(obj)
	end
end

local function main()
	local ScriptViewer = {}
	local window, codeFrame
	
	local execute, clear, dumpbtn
	
	local PreviousScr = nil
	
	ScriptViewer.DumpFunctions = function(scr)
		-- thanks King.Kevin#6025 you'll obviously be credited (no discord tag since that can easily be impersonated)
		local getgc = getgc or get_gc_objects
		local getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
		local getconstants = (debug and debug.getconstants) or getconstants or getconsts
		local getinfo = (debug and (debug.getinfo or debug.info)) or getinfo
		local original = ("\n-- // Function Dumper made by King.Kevin\n-- // Script Path: %s\n\n--[["):format(getPath(scr))
		local dump = original
		local functions, function_count, data_base = {}, 0, {}
		function functions:add_to_dump(str, indentation, new_line)
			local new_line = new_line or true
			dump = dump .. ("%s%s%s"):format(string.rep("		", indentation), tostring(str), new_line and "\n" or "")
		end
		function functions:get_function_name(func)
			local n = getinfo(func).name
			return n ~= "" and n or "Unknown Name"
		end
		function functions:dump_table(input, indent, index)
			local indent = indent < 0 and 0 or indent
			functions:add_to_dump(("%s [%s] %s"):format(tostring(index), tostring(typeof(input)), tostring(input)), indent - 1)
			local count = 0
			for index, value in pairs(input) do
				count = count + 1
				if type(value) == "function" then
					functions:add_to_dump(("%d [function] = %s"):format(count, functions:get_function_name(value)), indent)
				elseif type(value) == "table" then
					if not data_base[value] then
						data_base[value] = true
						functions:add_to_dump(("%d [table]:"):format(count), indent)
						functions:dump_table(value, indent + 1, index)
					else
						functions:add_to_dump(("%d [table] (Recursive table detected)"):format(count), indent)
					end
				else
					functions:add_to_dump(("%d [%s] = %s"):format(count, tostring(typeof(value)), tostring(value)), indent)
				end
			end
		end
		function functions:dump_function(input, indent)
			functions:add_to_dump(("\nFunction Dump: %s"):format(functions:get_function_name(input)), indent)
			functions:add_to_dump(("\nFunction Upvalues: %s"):format(functions:get_function_name(input)), indent)
			for index, upvalue in pairs(getupvalues(input)) do
				if type(upvalue) == "function" then
					functions:add_to_dump(("%d [function] = %s"):format(index, functions:get_function_name(upvalue)), indent + 1)
				elseif type(upvalue) == "table" then
					if not data_base[upvalue] then
						data_base[upvalue] = true
						functions:add_to_dump(("%d [table]:"):format(index), indent + 1)
						functions:dump_table(upvalue, indent + 2, index)
					else
						functions:add_to_dump(("%d [table] (Recursive table detected)"):format(index), indent + 1)
					end
				else
					functions:add_to_dump(("%d [%s] = %s"):format(index, tostring(typeof(upvalue)), tostring(upvalue)), indent + 1)
				end
			end
			functions:add_to_dump(("\nFunction Constants: %s"):format(functions:get_function_name(input)), indent)
			for index, constant in pairs(getconstants(input)) do
				if type(constant) == "function" then
					functions:add_to_dump(("%d [function] = %s"):format(index, functions:get_function_name(constant)), indent + 1)
				elseif type(constant) == "table" then
					if not data_base[constant] then
						data_base[constant] = true
						functions:add_to_dump(("%d [table]:"):format(index), indent + 1)
						functions:dump_table(constant, indent + 2, index)
					else
						functions:add_to_dump(("%d [table] (Recursive table detected)"):format(index), indent + 1)
					end
				else
					functions:add_to_dump(("%d [%s] = %s"):format(index, tostring(typeof(constant)), tostring(constant)), indent + 1)
				end
			end
		end
		for _, _function in pairs(env.getgc()) do
			if typeof(_function) == "function" and getfenv(_function).script and getfenv(_function).script == scr then
				functions:dump_function(_function, 0)
				functions:add_to_dump("\n" .. ("="):rep(100), 0, false)
			end
		end
		local source = codeFrame:GetText()

		if dump ~= original then source = source .. dump .. "]]" end
		codeFrame:SetText(source)
		
		window:Show()
	end

	ScriptViewer.Init = function()
		window = Lib.Window.new()
		window:SetTitle("Notepad")
		window:Resize(500,400)
		ScriptViewer.Window = window

		codeFrame = Lib.CodeFrame.new()
		codeFrame.Frame.Position = UDim2.new(0,0,0,20)
		codeFrame.Frame.Size = UDim2.new(1,0,1,-40)
		codeFrame.Frame.Parent = window.GuiElems.Content
		
		local copy = Instance.new("TextButton",window.GuiElems.Content)
		copy.BackgroundTransparency = 1
		copy.Size = UDim2.new(0.33,0,0,20)
		copy.Position = UDim2.new(0,0,0,0)
		copy.Text = "Copy to Clipboard"
		
		if env.setclipboard then
			copy.TextColor3 = Color3.new(1,1,1)
			copy.Interactable = true
		else
			copy.TextColor3 = Color3.new(0.5,0.5,0.5)
			copy.Interactable = false
		end

		copy.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			env.setclipboard(source)
		end)

		local save = Instance.new("TextButton",window.GuiElems.Content)
		save.BackgroundTransparency = 1
		save.Size = UDim2.new(0.33,0,0,20)
		save.Position = UDim2.new(0.33,0,0,0)
		save.Text = "Save to File"
		save.TextColor3 = Color3.new(1,1,1)
		
		if env.writefile then
			save.TextColor3 = Color3.new(1,1,1)
			save.Interactable = true
		else
			save.TextColor3 = Color3.new(0.5,0.5,0.5)
			--save.Interactable = false
		end

		save.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			local filename = "Place_"..game.PlaceId.."_Script_"..os.time()..".txt"

			Lib.SaveAsPrompt(filename,source)
			--env.writefile(filename,source)
		end)
		
		dumpbtn = Instance.new("TextButton",window.GuiElems.Content)
		dumpbtn.BackgroundTransparency = 1
		dumpbtn.Position = UDim2.new(0.7,0,0,0)
		dumpbtn.Size = UDim2.new(0.3,0,0,20)
		dumpbtn.Text = "Dump Functions"
		dumpbtn.TextColor3 = Color3.new(0.5,0.5,0.5)
		
		if env.getgc then
			dumpbtn.TextColor3 = Color3.new(1,1,1)
			dumpbtn.Interactable = true
		else
			dumpbtn.TextColor3 = Color3.new(0.5,0.5,0.5)
			dumpbtn.Interactable = false
		end

		dumpbtn.MouseButton1Click:Connect(function()
			if PreviousScr ~= nil then
				pcall(ScriptViewer.DumpFunctions, PreviousScr)
			end
		end)
		
		-- Buttons below the editor
		
		
		execute = Instance.new("TextButton",window.GuiElems.Content)
		execute.BackgroundTransparency = 1
		execute.Size = UDim2.new(0.5,0,0,20)
		execute.Position = UDim2.new(0,0,1,-20)
		execute.Text = "Execute"
		execute.TextColor3 = Color3.new(1,1,1)
		
		if env.loadstring then
			execute.TextColor3 = Color3.new(1,1,1)
			execute.Interactable = true
		else
			execute.TextColor3 = Color3.new(0.5,0.5,0.5)
			execute.Interactable = false
		end

		execute.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			env.loadstring(source)()
		end)

		clear = Instance.new("TextButton",window.GuiElems.Content)
		clear.BackgroundTransparency = 1
		clear.Size = UDim2.new(0.5,0,0,20)
		clear.Position = UDim2.new(0.5,0,1,-20)
		clear.Text = "Clear"
		clear.TextColor3 = Color3.new(1,1,1)

		clear.MouseButton1Click:Connect(function()
			codeFrame:SetText("")
		end)
	end
	
	ScriptViewer.ViewScript = function(scr)
		local oldtick = tick()
		local s,source = pcall(env.decompile or function() end,scr)

		if not s or not source then
			PreviousScr = nil
			dumpbtn.TextColor3 = Color3.new(0.5,0.5,0.5)
			source = "-- Unable to view source.\n"
			
			if Settings.ScriptViewer.ShowMoreInfo then
				source = source .. "-- Script Path: "..getPath(scr).."\n"
				if (scr.ClassName == "Script" and (scr.RunContext == Enum.RunContext.Legacy or scr.RunContext == Enum.RunContext.Server)) or not scr:IsA("LocalScript") then
					source = source .. "-- Reason: The script is not running on client. (attempt to decompile ServerScript or 'Script' with RunContext Server)\n"
				elseif not env.isdecompile() then
					source = source .. "-- Reason: Your executor does not support decompiler. (missing 'decompile' function and 'getscriptbytecode' function as fallback)\n"
				else
					source = source .. "-- Reason: Unknown Error.\n"
				end
				source = source .. "-- Executor: "..executorName.." ("..executorVersion..")"
			end
		else
			PreviousScr = scr
			dumpbtn.TextColor3 = Color3.new(1,1,1)

			local decompiled = source

			source = "-- Script Path: "..getPath(scr).."\n"
			
			if Settings.ScriptViewer.ShowMoreInfo then
				source = source .. "-- Took "..tostring(math.floor( (tick() - oldtick) * 100) / 100).."s to decompile.\n"
				source = source .. "-- Executor: "..executorName.." ("..executorVersion..")\n\n"
			end
			
			source = source .. decompiled

			oldtick = nil
			decompiled = nil
		end

		codeFrame:SetText(source)
		window:Show()
	end

	return ScriptViewer
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
end,
["SettingsWindow"] = function()
--[[
	Save Instance App Module
	
	Revival of the old dex's Save Instance
]] 

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, SettingsWindow, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	SettingsWindow = Apps.SettingsWindow
	Notebook = Apps.Notebook
end

local function main()
	local SettingsWindow = {}
	local window, ListFrame
	local fileName = "Place_"..game.PlaceId.."_"..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name.."_{TIMESTAMP}"
	local Saving = false
	
	local function AddCheckbox(title, default)
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)
		
		local listlayout = Instance.new("UIListLayout")
		listlayout.Parent = frame.Gui
		listlayout.FillDirection = Enum.FillDirection.Horizontal
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listlayout.Padding = UDim.new(0, 10)
		
		-- Checkbox
		local checkbox = Lib.Checkbox.new()
		
		checkbox.Gui.Parent = frame.Gui
		checkbox.Gui.Size = UDim2.new(0,15,0,15)
		
		-- Label
		local label = Lib.Label.new()
		
		label.Gui.Parent = frame.Gui
		label.Gui.Size = UDim2.new(1, 0,1, -15)
		label.Gui.Text = title
		label.TextTruncate = Enum.TextTruncate.AtEnd
		
		checkbox:SetState(default or false)
		
		return checkbox
	end
	
	local function AddTextbox(title, default, sizeX)
		default = default and tostring(default) or ""
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)

		local listlayout = Instance.new("UIListLayout")
		listlayout.Parent = frame.Gui
		listlayout.FillDirection = Enum.FillDirection.Horizontal
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listlayout.Padding = UDim.new(0, 10)

		-- Textbox
		local textbox = Instance.new("TextBox") -- replaced cuz why Moon make every inputs only work on mouse/pc users >:( 
		textbox.BackgroundColor3 = Settings.Theme.TextBox
		textbox.BorderColor3 = Settings.Theme.Outline3
		textbox.ClearTextOnFocus = false
		textbox.TextColor3 = Settings.Theme.Text
		textbox.Font = Enum.Font.SourceSans
		textbox.TextSize = 14
		textbox.ZIndex = 2

		textbox.Parent = frame.Gui
		if sizeX and type(sizeX) == "number" then
			textbox.Size = UDim2.new(0,sizeX,0,15)
		else
			textbox.Size = UDim2.new(0,45,0,15)
		end
		
		frame.Gui.AutomaticSize = Enum.AutomaticSize.X
		textbox.AutomaticSize = Enum.AutomaticSize.X

		-- Label
		local label = Lib.Label.new()

		label.Parent = frame.Gui
		label.Size = UDim2.new(1, 0,1, -15)
		label.Text = title
		label.TextTruncate = Enum.TextTruncate.AtEnd

		textbox.Text = default

		return textbox
	end
	
	local function AddDropdown(title, options, default, allowEmpty, sizeX)
		if allowEmpty == nil then allowEmpty = true end
		
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)

		local listlayout = Instance.new("UIListLayout")
		listlayout.Parent = frame.Gui
		listlayout.FillDirection = Enum.FillDirection.Horizontal
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listlayout.Padding = UDim.new(0, 10)

		-- Textbox
		local dropdown = Lib.DropDown.new()
		dropdown.CanBeEmpty = allowEmpty
		dropdown.Size = UDim2.new(0,sizeX or 75,0,15)
		dropdown:SetOptions(options)
		if default then dropdown:SetSelected(default) end
		dropdown.Gui.Parent = frame.Gui

		frame.Gui.AutomaticSize = Enum.AutomaticSize.X

		-- Label
		local label = Lib.Label.new()

		label.Parent = frame.Gui
		label.Size = UDim2.new(1, 0,1, -15)
		label.Text = title
		label.TextTruncate = Enum.TextTruncate.AtEnd
		
		return dropdown
	end
	
	local function AddSeperator(title)

		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,20)
		
		-- Label
		local label = Lib.Label.new()

		label.Parent = frame.Gui
		--label.AnchorPoint = Vector2.new(0,1)
		--label.Position = UDim2.new(0,0,0,0)
		label.Size = UDim2.new(1, 0,1, 0)
		label.Text = title
		label.TextSize = 16
		label.TextTruncate = Enum.TextTruncate.AtEnd

		return label
	end
	
	local function AddText(text)
		local frame = Lib.Frame.new()
		frame.Gui.Parent = ListFrame
		frame.Gui.Transparency = 1
		frame.Gui.Size = UDim2.new(1,0,0,15)

		-- Label
		local label = Lib.Label.new()

		label.Parent = frame.Gui
		--label.AnchorPoint = Vector2.new(0,1)
		--label.Position = UDim2.new(0,0,0,0)
		label.Size = UDim2.new(1, 0,1, 0)
		label.TextColor3 = Color3.fromRGB(185,185,185)
		label.Text = text
		label.TextSize = 14
		label.TextTruncate = Enum.TextTruncate.AtEnd

		return label
	end
	
	SettingsWindow.ReloadPrompt = function()		
		local win = ScriptViewer.ReloadPromptWindow
		if not win then
			win = Lib.Window.new()
			win.Alignable = false
			win.Resizable = false
			win:SetTitle("Apply Current Settings")
			win:SetSize(300,115)

			local reloadButton = Lib.Button.new()
			local nameLabel = Lib.Label.new()
			nameLabel.Text = "By applying current settings requires reload.\nAny unsaved progress will be lost.\nAre you sure?"
			nameLabel.Position = UDim2.new(0,30,0,20)
			nameLabel.Size = UDim2.new(0,40,0,20)
			win:Add(nameLabel)

			local cancelButton = Lib.Button.new()
			cancelButton.AnchorPoint = Vector2.new(1,1)
			cancelButton.Text = "Apply Later"
			cancelButton.Position = UDim2.new(1,-5,1,-5)
			cancelButton.Size = UDim2.new(0.5,-10,0,20)
			cancelButton.OnClick:Connect(function()
				win:Close()
			end)
			win:Add(cancelButton)

			reloadButton.Text = "Apply Now"
			reloadButton.AnchorPoint = Vector2.new(0,1)
			reloadButton.Position = UDim2.new(0,5,1,-5)
			reloadButton.Size = UDim2.new(0.5,-5,0,20)
			reloadButton.OnClick:Connect(function()
				Main.Reinit()
			end)

			win:Add(reloadButton,"reloadButton")

			SettingsWindow.ReloadPromptWindow = win
		end
		win:Show()
	end
	
	SettingsWindow.Init = function()
		window = Lib.Window.new()
		window:SetTitle("Settings")
		window:Resize(250,375)
		SettingsWindow.Window = window
		
		-- ListFrame
		
		ListFrame = Instance.new("ScrollingFrame")
		ListFrame.Parent = window.GuiElems.Content
		ListFrame.Size = UDim2.new(1, 0,1, -20)
		ListFrame.Position = UDim2.new(0, 0, 0, 0)
		ListFrame.Transparency = 1
		ListFrame.CanvasSize = UDim2.new(0,0,0,0)
		ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ListFrame.ScrollBarThickness = 16
		ListFrame.BottomImage = ""
		ListFrame.TopImage = ""
		ListFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
		ListFrame.ScrollBarImageTransparency = 0
		ListFrame.ZIndex = 2
		ListFrame.BorderSizePixel = 0
		
		local scrollbar = Lib.ScrollBar.new()
		scrollbar.Gui.Parent = window.GuiElems.Content
		scrollbar.Gui.Size = UDim2.new(1, 0,1, -40)
		scrollbar.Gui.Up.ZIndex = 3
		scrollbar.Gui.Down.ZIndex = 3
		
		ListFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
			if ListFrame.AbsoluteCanvasSize ~= ListFrame.AbsoluteWindowSize then
				scrollbar.Gui.Visible = true
			else
				scrollbar.Gui.Visible = false
			end
		end)
		
		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = ListFrame
		ListLayout.Padding = UDim.new(0, 5)
		
		local Padding = Instance.new("UIPadding")
		Padding.Parent = ListFrame
		Padding.PaddingBottom = UDim.new(0, 5)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)
		Padding.PaddingTop = UDim.new(0, 5)
		
		-- Options
		
		AddSeperator("UI")
		
		local titleonmiddle = AddCheckbox("Window Title On Middle", Settings.Window.TitleOnMiddle)
		titleonmiddle.OnInput:Connect(function()
			Settings.Window.TitleOnMiddle = titleonmiddle.Toggled
		end)
		
		local bgTransparency = AddTextbox("Background Transparency", tostring(Settings.Window.Transparency), 15)
		bgTransparency.FocusLost:Connect(function()
			Settings.Window.Transparency = tonumber(bgTransparency.Text)
		end)
		
		local classIcon = AddDropdown("Class Icons", {"Old", "NewDark", "Vanilla3"}, Settings.ClassIcon, false, 100)
		classIcon.OnSelect:Connect(function()
			Settings.ClassIcon = classIcon.Selected
		end)
		
		AddSeperator("Explorer")
		
		local clickRename = AddCheckbox("Click to Rename", Settings.Explorer.ClickToRename)
		clickRename.OnInput:Connect(function()
			Settings.Explorer.ClickToRename = clickRename.Toggled
		end)
		
		local partSelectionBox = AddCheckbox("Part Selection Box", Settings.Explorer.PartSelectionBox)
		partSelectionBox.OnInput:Connect(function()
			Settings.Explorer.PartSelectionBox = partSelectionBox.Toggled
		end)
		
		local copypathUseChildren = AddCheckbox("Use GetChildren to Copy Path", Settings.Explorer.CopyPathUseGetChildren)
		copypathUseChildren.OnInput:Connect(function()
			Settings.Explorer.CopyPathUseGetChildren = copypathUseChildren.Toggled
		end)
		
		AddSeperator("Properties")

		local showDeprecated = AddCheckbox("Show Deprecated", Settings.Properties.ShowDeprecated)
		showDeprecated.OnInput:Connect(function()
			Settings.Properties.ShowDeprecated = showDeprecated.Toggled
		end)
		
		local showHidden = AddCheckbox("Show Hidden", Settings.Properties.ShowHidden)
		showHidden.OnInput:Connect(function()
			Settings.Properties.ShowHidden = showHidden.Toggled
		end)
		
		local showAttributes = AddCheckbox("Show Attributes", Settings.Properties.ShowAttributes)
		showAttributes.OnInput:Connect(function()
			Settings.Properties.ShowAttributes = showAttributes.Toggled
		end)
		local clearOnFocus = AddCheckbox("Clear On Focus", Settings.Properties.ClearOnFocus)
		clearOnFocus.OnInput:Connect(function()
			Settings.Properties.ClearOnFocus = clearOnFocus.Toggled
		end)
		
		AddSeperator("Script Viewer")
		
		local showMoreInfo = AddCheckbox("Show Decompiled Script Info", Settings.ScriptViewer.ShowMoreInfo)
		showMoreInfo.OnInput:Connect(function()
			Settings.ScriptViewer.ShowMoreInfo = showMoreInfo.Toggled
		end)
		
		AddSeperator("Decompiler")
		AddText("If executor does not support decompile, it will use the fallback option.")
		AddText("'getbytecode' is mandatory to use fallback decompilers.")
		local decompilerOption = {"Konstant", "AdvancedDecompiler", "Shiny"}
		local decompiler = AddDropdown("Decompiler Fallback", decompilerOption, Settings.Decompiler.DecompilerFallback, false, 125)
		decompiler.OnSelect:Connect(function()
			Settings.Decompiler.DecompilerFallback = decompiler.Selected
		end)
		
		local ShinyPort = AddTextbox("Shiny Decompiler Port", tostring(Settings.Decompiler.ShinyDecompilerPort), 50)
		ShinyPort.FocusLost:Connect(function()
			local portinput = tonumber(ShinyPort.Text)
			if not portinput then
				ShinyPort.Text = Settings.Decompiler.ShinyDecompilerPort
			else
				if portinput > 0 and portinput <= 65535 then
					Settings.Decompiler.ShinyDecompilerPort = portinput
				else
					ShinyPort.Text = Settings.Decompiler.ShinyDecompilerPort
				end
			end
		end)
		
		local preferFallback = AddCheckbox("Prefer Fallback Decompiler", Settings.Decompiler.PreferDecompilerFallback)
		preferFallback.OnInput:Connect(function()
			Settings.Decompiler.PreferDecompilerFallback = preferFallback.Toggled
		end)
		
		-- Save buttons below
		local BackgroundreloadButton = Lib.Frame.new()
		BackgroundreloadButton.Gui.Parent = window.GuiElems.Content
		BackgroundreloadButton.Size = UDim2.new(1,0, 0,20)
		BackgroundreloadButton.Position = UDim2.new(0,0, 1,-20)
		
		local LabelreloadButton = Lib.Label.new()
		LabelreloadButton.Gui.Parent = window.GuiElems.Content
		LabelreloadButton.Size = UDim2.new(1,0, 0,20)
		LabelreloadButton.Position = UDim2.new(0,0, 1,-20)
		LabelreloadButton.Gui.Text = "Restart"
		LabelreloadButton.Gui.TextXAlignment = Enum.TextXAlignment.Center
		
		local reloadButton = Instance.new("TextButton")
		reloadButton.Parent = BackgroundreloadButton.Gui
		reloadButton.Size = UDim2.new(1,0, 1,0)
		reloadButton.Position = UDim2.new(0,0, 0,0)
		reloadButton.Transparency = 1
		
		reloadButton.MouseButton1Click:Connect(function()
			window:SetTitle("Settings - Saving")
			
			Main.SaveCurrentSettings()
			
			window:SetTitle("Settings - Saved")
			SettingsWindow.ReloadPrompt()
			task.wait(3)
			
			window:SetTitle("Settings")
		end)
	end

	return SettingsWindow
end

-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
end,
--[[MCPBRIDGE:BEGIN]]
["MCPBridge"] = function()
--[[
	MCP Bridge Module  (GENERATED by dexmcp/scripts/embed.js - edit dexmcp/lua/*.lua instead)

	Connects Dex++ to an MCP server (dexmcp/server) over WebSocket (or HTTP long-poll fallback)
	so an MCP client can drive this Roblox client: explorer, properties, scripts, remotes, GC, hooks...
]]

-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals

local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings

	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end

local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end

local PARTS = {}

PARTS[#PARTS + 1] = {"00_prelude", function(B)
-- 00_prelude: executor capability resolver, JSON, base64, small utilities
local Dex = B.Dex
local service = Dex.service
local C = {}
B.C = C

local root = (getgenv and getgenv()) or getfenv(0)
B.root = root

local function lookup(name)
	local cur = root
	for part in string.gmatch(name, "[^%.]+") do
		if type(cur) ~= "table" then return nil end
		local ok, v = pcall(function() return cur[part] end)
		if not ok then return nil end
		cur = v
		if cur == nil then return nil end
	end
	return cur
end
B.lookup = lookup

-- first existing alias wins
local function pick(...)
	for i = 1, select("#", ...) do
		local v = lookup((select(i, ...)))
		if v ~= nil then return v end
	end
	return nil
end
B.pick = pick

-- Executor API table. Every entry may be nil; handlers call B.need("name") to fail with a clear message.
C.getgc = pick("getgc", "get_gc_objects")
C.filtergc = pick("filtergc")
C.getinstances = pick("getinstances", "get_instances")
C.getnilinstances = pick("getnilinstances", "get_nil_instances")
C.getscripts = pick("getscripts", "get_scripts")
C.getrunningscripts = pick("getrunningscripts", "get_running_scripts")
C.getloadedmodules = pick("getloadedmodules", "get_loaded_modules")
C.getsenv = pick("getsenv", "getmenv")
C.getconnections = pick("getconnections", "get_signal_cons")
C.firesignal = pick("firesignal")
C.getrawmetatable = pick("getrawmetatable", "debug.getmetatable")
C.setrawmetatable = pick("setrawmetatable", "debug.setmetatable")
C.setreadonly = pick("setreadonly")
C.isreadonly = pick("isreadonly")
C.hookfunction = pick("hookfunction", "replaceclosure", "detour_function")
C.restorefunction = pick("restorefunction")
C.hookmetamethod = pick("hookmetamethod")
C.newcclosure = pick("newcclosure")
C.clonefunction = pick("clonefunction")
C.checkcaller = pick("checkcaller")
C.getcallingscript = pick("getcallingscript")
C.getnamecallmethod = pick("getnamecallmethod", "get_namecall_method")
C.setnamecallmethod = pick("setnamecallmethod", "set_namecall_method")
C.gethiddenproperty = pick("gethiddenproperty", "get_hidden_property")
C.sethiddenproperty = pick("sethiddenproperty", "set_hidden_property")
C.isscriptable = pick("isscriptable")
C.setscriptable = pick("setscriptable")
C.getthreadidentity = pick("getthreadidentity", "getidentity", "get_thread_identity", "syn.get_thread_identity", "syn.get_thread_context", "getthreadcontext")
C.setthreadidentity = pick("setthreadidentity", "setidentity", "set_thread_identity", "syn.set_thread_identity", "syn.set_thread_context", "setthreadcontext")
C.getfunctionhash = pick("getfunctionhash")
C.getscripthash = pick("getscripthash")
C.getscriptbytecode = pick("getscriptbytecode", "dumpstring")
C.getscriptclosure = pick("getscriptclosure", "getscriptfunction")
C.decompile = pick("decompile")
C.islclosure = pick("islclosure", "is_l_closure")
C.iscclosure = pick("iscclosure", "is_c_closure")
C.isexecutorclosure = pick("isexecutorclosure", "checkclosure", "isourclosure", "is_synapse_function", "is_executor_closure")
C.getupvalues = pick("debug.getupvalues", "getupvalues", "getupvals")
C.getupvalue = pick("debug.getupvalue", "getupvalue", "getupval")
C.setupvalue = pick("debug.setupvalue", "setupvalue", "setupval")
C.getconstants = pick("debug.getconstants", "getconstants", "getconsts")
C.getconstant = pick("debug.getconstant", "getconstant", "getconst")
C.setconstant = pick("debug.setconstant", "setconstant", "setconst")
C.getprotos = pick("debug.getprotos", "getprotos")
C.getproto = pick("debug.getproto", "getproto")
C.getstack = pick("debug.getstack", "getstack")
C.setstack = pick("debug.setstack", "setstack")
C.getinfo = pick("debug.getinfo", "getinfo")
C.debuginfo = (debug and debug.info) or nil
C.traceback = (debug and debug.traceback) or nil
C.getreg = pick("getreg", "debug.getregistry")
C.getthreads = pick("getthreads")
C.getcallbackvalue = pick("getcallbackvalue")
C.compareinstances = pick("compareinstances")
C.cloneref = pick("cloneref")
C.isnetworkowner = pick("isnetworkowner")
C.gethui = pick("gethui")
C.fireclickdetector = pick("fireclickdetector")
C.fireproximityprompt = pick("fireproximityprompt")
C.firetouchinterest = pick("firetouchinterest")
C.getcustomasset = pick("getcustomasset", "getsynasset")
C.saveinstance = pick("saveinstance", "syn.saveinstance")
C.request = pick("request", "http_request", "syn.request", "http.request", "fluxus.request")
C.identifyexecutor = pick("identifyexecutor", "getexecutorname")
C.setclipboard = pick("setclipboard", "toclipboard", "set_clipboard")
C.readfile = pick("readfile")
C.writefile = pick("writefile")
C.appendfile = pick("appendfile")
C.isfile = pick("isfile")
C.isfolder = pick("isfolder")
C.listfiles = pick("listfiles")
C.makefolder = pick("makefolder")
C.delfile = pick("delfile")
C.delfolder = pick("delfolder")
C.loadstring = pick("loadstring")
C.lz4decompress = pick("lz4decompress")
C.crypt = pick("crypt")
C.WebSocket = pick("WebSocket", "syn.websocket")
C.getfflag = pick("getfflag", "getfflagvalue")
C.firesignal = pick("firesignal")
C.getgenv = getgenv
C.getrenv = pick("getrenv")
C.getfenv = getfenv
C.setfenv = setfenv

function B.need(name)
	local f = C[name]
	if f == nil then
		error("executor does not provide '" .. name .. "'", 0)
	end
	return f
end

-- every probe name used for get_capabilities, grouped
B.CapGroups = {
	instances = { "getgc", "filtergc", "getinstances", "getnilinstances", "getscripts", "getrunningscripts", "getloadedmodules", "getsenv", "cloneref", "compareinstances", "gethui" },
	hooks = { "hookfunction", "restorefunction", "hookmetamethod", "newcclosure", "clonefunction", "checkcaller", "getcallingscript", "getnamecallmethod", "setnamecallmethod" },
	metatables = { "getrawmetatable", "setrawmetatable", "setreadonly", "isreadonly" },
	properties = { "gethiddenproperty", "sethiddenproperty", "isscriptable", "setscriptable" },
	identity = { "getthreadidentity", "setthreadidentity" },
	scripts = { "decompile", "getscriptbytecode", "getscripthash", "getscriptclosure", "getfunctionhash" },
	closures = { "islclosure", "iscclosure", "isexecutorclosure", "getupvalues", "getupvalue", "setupvalue", "getconstants", "getconstant", "setconstant", "getprotos", "getproto", "getstack", "setstack", "getinfo" },
	signals = { "getconnections", "firesignal", "getcallbackvalue" },
	interaction = { "fireclickdetector", "fireproximityprompt", "firetouchinterest", "isnetworkowner" },
	network = { "request", "WebSocket" },
	filesystem = { "readfile", "writefile", "appendfile", "isfile", "isfolder", "listfiles", "makefolder", "delfile", "delfolder", "getcustomasset" },
	misc = { "saveinstance", "setclipboard", "loadstring", "getreg", "getthreads", "crypt", "lz4decompress", "identifyexecutor", "getfflag" },
}

----------------------------------------------------------------------------------------------------
-- Small helpers
----------------------------------------------------------------------------------------------------
local NULL = setmetatable({}, { __tostring = function() return "null" end })
B.NULL = NULL

-- closures created by the bridge itself (spy/watch handlers): hidden from handler listings
B.ownFns = setmetatable({}, { __mode = "k" })

local objMarks = setmetatable({}, { __mode = "k" })
function B.obj(t) objMarks[t] = true return t end
function B.arr(t) objMarks[t] = nil return t end

function B.now()
	local ok, ms = pcall(function() return DateTime.now().UnixTimestampMillis end)
	if ok and ms then return ms / 1000 end
	return os.time()
end

local clock = os.clock
local lastYield = clock()
-- cooperative yield: call inside long loops
function B.yield(budget)
	if clock() - lastYield > (budget or 0.008) then
		task.wait()
		lastYield = clock()
		return true
	end
	return false
end

function B.pack(...)
	return { n = select("#", ...), ... }
end

function B.unpack(t, i, j)
	return unpack(t, i or 1, j or t.n or #t)
end

function B.safe(f, ...)
	local ok, a, b, c, d = pcall(f, ...)
	if ok then return a, b, c, d end
	return nil
end

function B.trunc(s, n)
	s = tostring(s)
	if #s > n then return s:sub(1, n) .. "...(+" .. (#s - n) .. ")" end
	return s
end

function B.keys(t)
	local out = {}
	for k in pairs(t) do out[#out + 1] = k end
	table.sort(out, function(a, b) return tostring(a) < tostring(b) end)
	return out
end

function B.count(t)
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end

function B.escapePattern(s)
	return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- build a string matcher: mode "plain" | "pattern" | "exact"; case-insensitive optional
function B.matcher(query, mode, ci)
	if query == nil or query == "" then return function() return true end end
	local q = query
	if ci then q = q:lower() end
	mode = mode or "plain"
	if mode == "exact" then
		return function(s)
			if ci then s = s:lower() end
			return s == q
		end
	elseif mode == "pattern" then
		return function(s)
			if ci then s = s:lower() end
			local ok, r = pcall(string.find, s, q)
			return ok and r ~= nil
		end
	else
		return function(s)
			if ci then s = s:lower() end
			return string.find(s, q, 1, true) ~= nil
		end
	end
end

----------------------------------------------------------------------------------------------------
-- base64
----------------------------------------------------------------------------------------------------
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64enc, b64dec = {}, {}
for i = 1, 64 do
	local c = b64chars:sub(i, i)
	b64enc[i - 1] = c
	b64dec[c:byte()] = i - 1
end

function B.b64encode(s)
	local out, n = {}, 0
	local len = #s
	for i = 1, len - 2, 3 do
		local a, b, c = s:byte(i, i + 2)
		local v = a * 65536 + b * 256 + c
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. b64enc[math.floor(v / 64) % 64] .. b64enc[v % 64]
	end
	local rem = len % 3
	if rem == 1 then
		local a = s:byte(len)
		local v = a * 65536
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. "=="
	elseif rem == 2 then
		local a, b = s:byte(len - 1, len)
		local v = a * 65536 + b * 256
		n = n + 1
		out[n] = b64enc[math.floor(v / 262144) % 64] .. b64enc[math.floor(v / 4096) % 64] .. b64enc[math.floor(v / 64) % 64] .. "="
	end
	return table.concat(out)
end

function B.b64decode(s)
	s = s:gsub("[^%w%+/=]", "")
	local out, n = {}, 0
	for i = 1, #s, 4 do
		local c1, c2, c3, c4 = s:byte(i, i + 3)
		local d1, d2 = b64dec[c1], b64dec[c2]
		if not d1 or not d2 then break end
		local d3 = c3 and b64dec[c3]
		local d4 = c4 and b64dec[c4]
		local v = d1 * 262144 + d2 * 4096 + (d3 or 0) * 64 + (d4 or 0)
		n = n + 1
		if d3 and d4 then
			out[n] = string.char(math.floor(v / 65536) % 256, math.floor(v / 256) % 256, v % 256)
		elseif d3 then
			out[n] = string.char(math.floor(v / 65536) % 256, math.floor(v / 256) % 256)
		else
			out[n] = string.char(math.floor(v / 65536) % 256)
		end
	end
	return table.concat(out)
end

function B.hex(s, maxLen)
	if maxLen and #s > maxLen then s = s:sub(1, maxLen) end
	return (s:gsub(".", function(c) return string.format("%02x", c:byte()) end))
end

----------------------------------------------------------------------------------------------------
-- JSON encoder (tolerates Roblox values, cycles, invalid UTF-8)
----------------------------------------------------------------------------------------------------
local J = {}
B.J = J

local ESC = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
for i = 0, 31 do
	local ch = string.char(i)
	if not ESC[ch] then ESC[ch] = string.format("\\u%04x", i) end
end
ESC["\127"] = "\\u007f"

local utf8len = utf8 and utf8.len
local function validUtf8(s)
	if not utf8len then return true end
	local ok, r = pcall(utf8len, s)
	return ok and r ~= nil
end

local function encStr(s)
	if validUtf8(s) then
		return '"' .. (s:gsub('[%c"\\]', ESC)) .. '"'
	end
	return '{"$t":"bytes","len":' .. #s .. ',"b64":"' .. B.b64encode(s) .. '"}'
end

local function encKey(k)
	k = tostring(k)
	if not validUtf8(k) then
		k = k:gsub("[\128-\255]", "?")
	end
	return '"' .. (k:gsub('[%c"\\]', ESC)) .. '"'
end

local function encNum(n)
	if n ~= n then return '{"$t":"number","v":"nan"}' end
	if n == math.huge then return '{"$t":"number","v":"inf"}' end
	if n == -math.huge then return '{"$t":"number","v":"-inf"}' end
	if n == math.floor(n) and n > -1e15 and n < 1e15 then return string.format("%d", n) end
	return string.format("%.15g", n)
end

local function isArray(t)
	local n = #t
	if n == 0 then return next(t) == nil end
	local cnt = 0
	for k in pairs(t) do
		if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then return false end
		cnt = cnt + 1
	end
	return cnt == n
end

local MAXDEPTH = 64

local function enc(v, buf, depth, seen)
	local t = type(v)
	if v == nil or v == NULL then
		buf[#buf + 1] = "null"
	elseif t == "string" then
		buf[#buf + 1] = encStr(v)
	elseif t == "number" then
		buf[#buf + 1] = encNum(v)
	elseif t == "boolean" then
		buf[#buf + 1] = v and "true" or "false"
	elseif t == "table" then
		if depth > MAXDEPTH then buf[#buf + 1] = '"<max depth>"' return end
		if seen[v] then buf[#buf + 1] = '"<cycle>"' return end
		seen[v] = true
		if not objMarks[v] and isArray(v) then
			buf[#buf + 1] = "["
			for i = 1, #v do
				if i > 1 then buf[#buf + 1] = "," end
				enc(v[i], buf, depth + 1, seen)
			end
			buf[#buf + 1] = "]"
		else
			buf[#buf + 1] = "{"
			local first = true
			local ks = {}
			for k in pairs(v) do ks[#ks + 1] = k end
			table.sort(ks, function(a, b) return tostring(a) < tostring(b) end)
			for _, k in ipairs(ks) do
				local val = v[k]
				if val ~= nil then
					if not first then buf[#buf + 1] = "," end
					first = false
					buf[#buf + 1] = encKey(k)
					buf[#buf + 1] = ":"
					enc(val, buf, depth + 1, seen)
				end
			end
			buf[#buf + 1] = "}"
		end
		seen[v] = nil
	else
		-- userdata / function / thread / roblox datatypes: serialize with refs
		if B.ser then
			local ok, tree = pcall(B.ser, v)
			if ok then enc(tree, buf, depth + 1, seen) return end
		end
		buf[#buf + 1] = encStr(tostring(v))
	end
end

function J.encode(v)
	local buf = {}
	enc(v, buf, 0, {})
	return table.concat(buf)
end

local HttpService = service.HttpService
function J.decode(s)
	return HttpService:JSONDecode(s)
end

B.json = J.encode
B.unjson = J.decode

end}

PARTS[#PARTS + 1] = {"10_serialize", function(B)
-- 10_serialize: ref registry, value serializer/deserializer, instance path building + resolution
local C = B.C
local Dex = B.Dex
local service = Dex.service
local typeof = typeof or type
local NULL = B.NULL
local gm = game

----------------------------------------------------------------------------------------------------
-- Ref registry: opaque ids for functions/tables/instances/userdata so the client can address them later
----------------------------------------------------------------------------------------------------
local refs = {}
local refIds = setmetatable({}, { __mode = "k" })
local nextRef = 1
local refCount = 0
local refQueue, qHead, qTail = {}, 1, 0
B.refs = refs

local function refable(v)
	local t = type(v)
	return t == "table" or t == "function" or t == "userdata" or t == "thread"
end

function B.ref(v)
	if not refable(v) then return nil end
	local id = refIds[v]
	if id and refs[id] == v then return id end
	id = nextRef
	nextRef = nextRef + 1
	refs[id] = v
	refIds[v] = id
	refCount = refCount + 1
	qTail = qTail + 1
	refQueue[qTail] = id
	local max = (B.cfg and B.cfg.MaxRefs) or 50000
	while refCount > max and qHead <= qTail do
		local old = refQueue[qHead]
		refQueue[qHead] = nil
		qHead = qHead + 1
		local ov = refs[old]
		if ov ~= nil then
			refs[old] = nil
			refIds[ov] = nil
			refCount = refCount - 1
		end
	end
	return id
end

function B.getref(id)
	local v = refs[id]
	if v == nil then error("ref #" .. tostring(id) .. " does not exist (released, evicted or never created)", 0) end
	return v
end

function B.unref(id)
	local v = refs[id]
	if v ~= nil then
		refs[id] = nil
		refIds[v] = nil
		refCount = refCount - 1
		return true
	end
	return false
end

function B.refStats()
	return { count = refCount, next_id = nextRef }
end

function B.clearRefs()
	local n = refCount
	for id, v in pairs(refs) do refIds[v] = nil end
	table.clear(refs)
	refCount = 0
	refQueue, qHead, qTail = {}, 1, 0
	return n
end

----------------------------------------------------------------------------------------------------
-- Function info
----------------------------------------------------------------------------------------------------
function B.funcInfo(f)
	local info = {}
	local ok, i = false, nil
	if C.getinfo then ok, i = pcall(C.getinfo, f) end
	if ok and type(i) == "table" then
		info.name = i.name ~= "" and i.name or nil
		info.source = i.source
		info.short_src = i.short_src
		info.line = i.linedefined or i.currentline
		info.nups = i.nups
		info.numparams = i.numparams
		info.is_vararg = i.is_vararg
		info.what = i.what
	elseif debug and debug.info then
		local ok2, src, line, name, nparams, vararg = pcall(debug.info, f, "slna")
		if ok2 then
			info.source = src
			info.line = line
			info.name = name ~= "" and name or nil
			info.numparams = nparams
			info.is_vararg = vararg
		end
	end
	if C.islclosure then
		local ok3, v = pcall(C.islclosure, f)
		if ok3 then info.lua_closure = v end
	elseif C.iscclosure then
		local ok3, v = pcall(C.iscclosure, f)
		if ok3 then info.lua_closure = not v end
	end
	if C.isexecutorclosure then
		local ok4, v = pcall(C.isexecutorclosure, f)
		if ok4 then info.executor_closure = v end
	end
	return info
end

----------------------------------------------------------------------------------------------------
-- Lua string quoting used in instance paths
----------------------------------------------------------------------------------------------------
local QESC = { ["\\"] = "\\\\", ['"'] = '\\"', ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
local function luaQuote(s)
	return '"' .. (s:gsub('[%c"\\]', function(c)
		return QESC[c] or string.format("\\%d", c:byte())
	end)) .. '"'
end
B.luaQuote = luaQuote

local KEYWORDS = {}
for _, k in ipairs({ "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "continue", "export", "type" }) do
	KEYWORDS[k] = true
end

function B.identOk(name)
	return name:match("^[%a_][%w_]*$") ~= nil and not KEYWORDS[name]
end

-- Lua expression that re-finds `inst` (what B.resolvePath parses)
function B.pathOf(inst)
	local chain, cur, guard = {}, inst, 0
	while cur ~= nil and cur ~= gm and guard < 400 do
		chain[#chain + 1] = cur
		cur = cur.Parent
		guard = guard + 1
	end
	local first
	if cur == gm then
		first = "game"
	else
		local top = chain[#chain]
		chain[#chain] = nil
		if not top then return "game" end
		first = "getnil(" .. luaQuote(top.ClassName) .. "," .. luaQuote(top.Name) .. ")"
	end
	local out = { first }
	for i = #chain, 1, -1 do
		local name = chain[i].Name
		if B.identOk(name) then
			out[#out + 1] = "." .. name
		else
			out[#out + 1] = "[" .. luaQuote(name) .. "]"
		end
	end
	return table.concat(out)
end

----------------------------------------------------------------------------------------------------
-- Serializer: Lua/Roblox value -> JSON-ready tree. Complex values get {"$t":<type>,...}
----------------------------------------------------------------------------------------------------
local SER = {}
B.SER = SER
B.serOpts = { depth = 2, maxItems = 40, maxStr = 4000, bytes = 256 }

local function newOpts(o)
	local d = B.serOpts
	if not o then return d end
	return {
		depth = o.depth or d.depth,
		maxItems = o.maxItems or d.maxItems,
		maxStr = o.maxStr or d.maxStr,
		bytes = o.bytes or d.bytes,
	}
end

local function tag(t, extra)
	extra = extra or {}
	extra["$t"] = t
	return extra
end

local function n(v) return v end

SER.Vector3 = function(v) return tag("Vector3", { v = { v.X, v.Y, v.Z } }) end
SER.Vector2 = function(v) return tag("Vector2", { v = { v.X, v.Y } }) end
SER.Vector3int16 = function(v) return tag("Vector3int16", { v = { v.X, v.Y, v.Z } }) end
SER.Vector2int16 = function(v) return tag("Vector2int16", { v = { v.X, v.Y } }) end
SER.CFrame = function(v) return tag("CFrame", { v = { v:GetComponents() } }) end
SER.Color3 = function(v)
	return tag("Color3", {
		v = { v.R, v.G, v.B },
		hex = string.format("#%02x%02x%02x", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)),
	})
end
SER.BrickColor = function(v) return tag("BrickColor", { name = v.Name, number = v.Number }) end
SER.UDim = function(v) return tag("UDim", { v = { v.Scale, v.Offset } }) end
SER.UDim2 = function(v) return tag("UDim2", { v = { v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset } }) end
SER.Rect = function(v) return tag("Rect", { v = { v.Min.X, v.Min.Y, v.Max.X, v.Max.Y } }) end
SER.Ray = function(v) return tag("Ray", { origin = { v.Origin.X, v.Origin.Y, v.Origin.Z }, direction = { v.Direction.X, v.Direction.Y, v.Direction.Z } }) end
SER.Region3 = function(v)
	local c, s = v.CFrame.Position, v.Size
	return tag("Region3", { center = { c.X, c.Y, c.Z }, size = { s.X, s.Y, s.Z } })
end
SER.NumberRange = function(v) return tag("NumberRange", { v = { v.Min, v.Max } }) end
SER.NumberSequence = function(v)
	local kp = {}
	for i, k in ipairs(v.Keypoints) do kp[i] = { k.Time, k.Value, k.Envelope } end
	return tag("NumberSequence", { keypoints = kp })
end
SER.ColorSequence = function(v)
	local kp = {}
	for i, k in ipairs(v.Keypoints) do kp[i] = { k.Time, k.Value.R, k.Value.G, k.Value.B } end
	return tag("ColorSequence", { keypoints = kp })
end
SER.NumberSequenceKeypoint = function(v) return tag("NumberSequenceKeypoint", { time = v.Time, value = v.Value, envelope = v.Envelope }) end
SER.ColorSequenceKeypoint = function(v) return tag("ColorSequenceKeypoint", { time = v.Time, value = { v.Value.R, v.Value.G, v.Value.B } }) end
SER.PhysicalProperties = function(v)
	return tag("PhysicalProperties", { density = v.Density, friction = v.Friction, elasticity = v.Elasticity, friction_weight = v.FrictionWeight, elasticity_weight = v.ElasticityWeight })
end
SER.Font = function(v) return tag("Font", { family = v.Family, weight = tostring(v.Weight), style = tostring(v.Style) }) end
SER.TweenInfo = function(v)
	return tag("TweenInfo", { time = v.Time, easing_style = tostring(v.EasingStyle), easing_direction = tostring(v.EasingDirection), repeat_count = v.RepeatCount, reverses = v.Reverses, delay = v.DelayTime })
end
SER.DateTime = function(v) return tag("DateTime", { unix_ms = v.UnixTimestampMillis, iso = v:ToIsoDate() }) end
SER.Random = function(v) return tag("Random") end
SER.Axes = function(v) return tag("Axes", { str = tostring(v) }) end
SER.Faces = function(v) return tag("Faces", { str = tostring(v) }) end
SER.EnumItem = function(v) return tag("EnumItem", { enum = tostring(v.EnumType), name = v.Name, value = v.Value }) end
SER.Enum = function(v) return tag("Enum", { name = tostring(v) }) end
SER.Enums = function(v) return tag("Enums") end
SER.RBXScriptSignal = function(v) return tag("Signal", { str = tostring(v), ref = B.ref(v) }) end
SER.RBXScriptConnection = function(v)
	local ok, c = pcall(function() return v.Connected end)
	return tag("Connection", { connected = ok and c or nil, ref = B.ref(v) })
end
SER.RaycastResult = function(v)
	return tag("RaycastResult", {
		instance = B.ser(v.Instance),
		position = { v.Position.X, v.Position.Y, v.Position.Z },
		normal = { v.Normal.X, v.Normal.Y, v.Normal.Z },
		material = tostring(v.Material),
		distance = v.Distance,
	})
end
SER.thread = function(v)
	return tag("thread", { status = coroutine.status(v), ref = B.ref(v) })
end
SER.buffer = function(v, o)
	local len = buffer.len(v)
	local out = tag("buffer", { len = len, ref = B.ref(v) })
	if len > 0 then
		local take = math.min(len, o.bytes)
		out.hex = B.hex(buffer.readstring(v, 0, take))
		if take < len then out.truncated = true end
	end
	return out
end

SER.Instance = function(v)
	local ok, out = pcall(function()
		return tag("Instance", {
			class = v.ClassName,
			name = v.Name,
			path = B.pathOf(v),
			ref = B.ref(v),
		})
	end)
	if ok then return out end
	return tag("Instance", { str = tostring(v), ref = B.ref(v) })
end

SER["function"] = function(f)
	local info = B.funcInfo(f)
	info["$t"] = "function"
	info.ref = B.ref(f)
	return info
end

local function keyLabel(k, o)
	local kt = typeof(k)
	if kt == "string" then return k end
	if kt == "number" or kt == "boolean" then return "[" .. tostring(k) .. "]" end
	if kt == "Instance" then
		local ok, s = pcall(function() return k.ClassName .. ":" .. k.Name end)
		return "[Instance " .. (ok and s or "?") .. " #" .. tostring(B.ref(k)) .. "]"
	end
	local id = B.ref(k)
	return "[" .. kt .. (id and (" #" .. id) or "") .. "]"
end

SER.table = function(t, o, depth, path)
	local id = B.ref(t)
	local out = tag("table", { ref = id })
	path = path or {}
	if path[t] then
		out.cycle = true
		return out
	end
	local mt
	if C.getrawmetatable then
		local ok, m = pcall(C.getrawmetatable, t)
		if ok then mt = m end
	else
		local ok, m = pcall(getmetatable, t)
		if ok then mt = m end
	end
	if type(mt) == "table" then out.has_metatable = true end

	-- classify
	local len = #t
	local total, nonSeq = 0, 0
	for k in next, t do
		total = total + 1
		if not (type(k) == "number" and k >= 1 and k <= len and k == math.floor(k)) then nonSeq = nonSeq + 1 end
		if total > 100000 then break end
	end
	out.count = total
	if total == 0 then return out end
	if depth >= o.depth then
		out.collapsed = true
		return out
	end

	path[t] = true
	if nonSeq == 0 then
		out["$t"] = "array"
		local items = {}
		for i = 1, math.min(len, o.maxItems) do
			items[i] = B.ser(t[i], o, depth + 1, path)
			if items[i] == nil then items[i] = NULL end
		end
		out.items = items
		if len > o.maxItems then out.more = len - o.maxItems end
	else
		local fields, shown = {}, 0
		for k, v in next, t do
			if shown >= o.maxItems then
				out.more = total - shown
				break
			end
			shown = shown + 1
			local sv = B.ser(v, o, depth + 1, path)
			if sv == nil then sv = NULL end
			fields[keyLabel(k, o)] = sv
		end
		out.fields = B.obj(fields)
	end
	path[t] = nil
	return out
end

SER.userdata = function(v)
	return tag("userdata", { str = tostring(v), ref = B.ref(v) })
end

function B.ser(v, o, depth, path)
	local t = typeof(v)
	if t == "nil" then return NULL end
	if t == "string" then
		local limit = (o and o.maxStr) or B.serOpts.maxStr
		if #v > limit then
			return tag("string", { len = #v, v = v:sub(1, limit), truncated = true })
		end
		return v
	end
	if t == "number" or t == "boolean" then return v end
	o = o and (o.depth and o) or B.serOpts
	local f = SER[t]
	if f then
		local ok, r = pcall(f, v, o, depth or 0, path)
		if ok then return r end
		return tag(t, { str = tostring(v), error = tostring(r) })
	end
	if type(v) == "table" then return SER.table(v, o, depth or 0, path) end
	local ok, s = pcall(tostring, v)
	return tag(t, { str = ok and s or "?", ref = refable(v) and B.ref(v) or nil })
end

-- serialize with fresh options (used by handlers: depth/maxItems/maxStr come from request params)
function B.serWith(v, p)
	return B.ser(v, newOpts(p))
end

-- serialize a pack of return values -> array
function B.serPack(pk, p)
	local o = newOpts(p)
	local out = {}
	for i = 1, pk.n do
		local s = B.ser(pk[i], o, 0)
		if s == nil then s = NULL end
		out[i] = s
	end
	return out
end

----------------------------------------------------------------------------------------------------
-- Path parsing + resolution (no loadstring)
----------------------------------------------------------------------------------------------------
local function readQuoted(s, i)
	local q = s:sub(i, i)
	local j = i + 1
	local buf = {}
	while j <= #s do
		local c = s:sub(j, j)
		if c == "\\" then
			local nx = s:sub(j + 1, j + 1)
			if nx == "n" then buf[#buf + 1] = "\n" j = j + 2
			elseif nx == "r" then buf[#buf + 1] = "\r" j = j + 2
			elseif nx == "t" then buf[#buf + 1] = "\t" j = j + 2
			elseif nx:match("%d") then
				local d = s:match("^%d%d?%d?", j + 1)
				buf[#buf + 1] = string.char(tonumber(d) % 256)
				j = j + 1 + #d
			else
				buf[#buf + 1] = nx
				j = j + 2
			end
		elseif c == q then
			return table.concat(buf), j + 1
		else
			buf[#buf + 1] = c
			j = j + 1
		end
	end
	return nil, "unterminated string in path"
end

-- parse argument list "( ... )" starting at i (the '('). returns list, nextIndex
local function readArgs(s, i)
	local args = {}
	i = i + 1
	while true do
		i = s:match("^%s*()", i)
		local c = s:sub(i, i)
		if c == ")" then return args, i + 1 end
		if c == "" then return nil, "unterminated argument list" end
		if c == '"' or c == "'" then
			local str, nx = readQuoted(s, i)
			if not str then return nil, nx end
			args[#args + 1] = str
			i = nx
		else
			local word = s:match("^[%w_%.%-]+", i)
			if not word then return nil, "bad argument at " .. i end
			if word == "true" then args[#args + 1] = true
			elseif word == "false" then args[#args + 1] = false
			elseif tonumber(word) then args[#args + 1] = tonumber(word)
			else args[#args + 1] = word end
			i = i + #word
		end
		i = s:match("^%s*()", i)
		if s:sub(i, i) == "," then i = i + 1 end
	end
end

local function childNames(inst, limit)
	local names = {}
	local ok, kids = pcall(inst.GetChildren, inst)
	if not ok then return "" end
	for i = 1, math.min(#kids, limit or 12) do names[i] = kids[i].Name end
	local s = table.concat(names, ", ")
	if #kids > (limit or 12) then s = s .. ", ... (" .. #kids .. " total)" end
	return s
end

local function getChild(cur, name)
	local ok, r = pcall(cur.FindFirstChild, cur, name)
	if ok and r then return r end
	if cur == gm then
		local ok2, svc = pcall(gm.GetService, gm, name)
		if ok2 and svc then return svc end
	end
	return nil
end

local function findNil(class, name)
	if not C.getnilinstances then return nil, "getnilinstances unavailable" end
	for _, v in ipairs(C.getnilinstances()) do
		if (class == nil or v.ClassName == class) and (name == nil or v.Name == name) then return v end
	end
	return nil, "no nil-parented " .. tostring(class) .. " named " .. tostring(name)
end

local debugIdIndex
local function findByDebugId(id)
	if not debugIdIndex then debugIdIndex = {} end
	local hit = debugIdIndex[id]
	if hit and hit.Parent ~= nil then return hit end
	local pools = {}
	if C.getinstances then pools[#pools + 1] = C.getinstances() end
	if C.getnilinstances then pools[#pools + 1] = C.getnilinstances() end
	if #pools == 0 then pools[1] = gm:GetDescendants() end
	for _, pool in ipairs(pools) do
		for i, v in ipairs(pool) do
			local ok, did = pcall(v.GetDebugId, v)
			if ok then
				debugIdIndex[did] = v
				if did == id then return v end
			end
			if i % 5000 == 0 then B.yield() end
		end
	end
	return nil, "no instance with debug id " .. tostring(id)
end
B.findByDebugId = findByDebugId

function B.resolvePath(s)
	s = s:match("^%s*(.-)%s*$")
	if s == "" then return nil, "empty path" end
	local i = 1
	local cur

	-- root forms
	local refId = s:match("^#(%d+)$") or s:match("^ref%((%d+)%)$") or s:match("^(%d+)$")
	if refId then
		local v = refs[tonumber(refId)]
		if v == nil then return nil, "ref #" .. refId .. " does not exist" end
		if typeof(v) ~= "Instance" then return nil, "ref #" .. refId .. " is a " .. typeof(v) .. ", not an Instance" end
		return v
	end
	local did = s:match("^debugid%(%s*[\"']([^\"']+)[\"']%s*%)$") or s:match("^debugid:(.+)$")
	if did then return findByDebugId(did) end

	if s:sub(1, 3) == "nil" and s:sub(4, 4) == ":" then
		-- nil:Class:Name  (also nil:Name)
		local rest = s:sub(5)
		local a, b = rest:match("^([^:]+):(.+)$")
		if a then return findNil(a, b) end
		return findNil(nil, rest)
	end

	local gn = s:match("^getnil%s*%(")
	if gn then
		local args, nx = readArgs(s, s:find("%("))
		if not args then return nil, nx end
		cur = findNil(args[1], args[2])
		if not cur then return nil, "no nil-parented instance " .. tostring(args[1]) .. "/" .. tostring(args[2]) end
		i = nx
	else
		local word = s:match("^[%w_]+")
		if word == "game" then
			cur = gm
			i = 5
		elseif word == "workspace" then
			cur = workspace
			i = 10
		elseif word == "script" then
			return nil, "'script' has no meaning here"
		else
			cur = gm
			i = 1
			-- implicit leading child name (e.g. "Workspace.Part"); allow free-form names with spaces up to next separator
			local name = s:match("^([^%.%[%]:%(%)]+)")
			if not name then return nil, "cannot parse path start: " .. s end
			local c = getChild(gm, name)
			if not c then return nil, "game has no child '" .. name .. "'" end
			cur = c
			i = #name + 1
		end
	end

	while i <= #s do
		i = s:match("^%s*()", i)
		local c = s:sub(i, i)
		if c == "" then break end
		if c == "." then
			local name = s:match("^%.([^%.%[%]:%(%)]+)", i)
			if not name then return nil, "bad path segment at " .. i .. " in " .. s end
			name = name:match("^%s*(.-)%s*$")
			if name == "Parent" then
				local par = cur.Parent
				if not par then return nil, cur:GetFullName() .. " has no Parent" end
				cur = par
			else
				local nx = getChild(cur, name)
				if not nx then
					return nil, "no child '" .. name .. "' under " .. B.pathOf(cur) .. " (children: " .. childNames(cur) .. ")"
				end
				cur = nx
			end
			i = i + 1 + #(s:match("^%.([^%.%[%]:%(%)]+)", i))
		elseif c == "[" then
			local q = s:sub(i + 1, i + 1)
			if q == '"' or q == "'" then
				local str, nx = readQuoted(s, i + 1)
				if not str then return nil, nx end
				if s:sub(nx, nx) ~= "]" then return nil, "expected ] at " .. nx end
				local child = getChild(cur, str)
				if not child then
					return nil, "no child '" .. str .. "' under " .. B.pathOf(cur) .. " (children: " .. childNames(cur) .. ")"
				end
				cur = child
				i = nx + 1
			else
				local num = s:match("^%[%s*(%d+)%s*%]", i)
				if not num then return nil, "bad index at " .. i end
				local kids = cur:GetChildren()
				local child = kids[tonumber(num)]
				if not child then return nil, "child index " .. num .. " out of range (" .. #kids .. " children)" end
				cur = child
				i = s:find("%]", i) + 1
			end
		elseif c == ":" then
			local method = s:match("^:([%a_]+)%s*%(", i)
			if not method then return nil, "bad method call at " .. i end
			local args, nx = readArgs(s, s:find("%(", i))
			if not args then return nil, nx end
			i = nx
			local lm = method:lower()
			if lm == "getservice" or lm == "service" then
				local ok, svc = pcall(gm.GetService, gm, args[1])
				if not ok or not svc then return nil, "no service " .. tostring(args[1]) end
				cur = svc
			elseif lm == "findfirstchild" or lm == "waitforchild" then
				local ok, r = pcall(cur.FindFirstChild, cur, args[1], args[2] == true)
				if not ok or not r then return nil, "FindFirstChild(" .. tostring(args[1]) .. ") found nothing under " .. B.pathOf(cur) end
				cur = r
			elseif lm == "findfirstchildofclass" then
				local r = cur:FindFirstChildOfClass(args[1])
				if not r then return nil, "no child of class " .. tostring(args[1]) end
				cur = r
			elseif lm == "findfirstchildwhichisa" then
				local r = cur:FindFirstChildWhichIsA(args[1])
				if not r then return nil, "no child which is a " .. tostring(args[1]) end
				cur = r
			elseif lm == "findfirstancestor" or lm == "findfirstancestorofclass" or lm == "findfirstancestorwhichisa" then
				local r = cur[method](cur, args[1])
				if not r then return nil, "no ancestor " .. tostring(args[1]) end
				cur = r
			elseif lm == "getchildren" or lm == "getdescendants" then
				local idx = s:match("^%s*%[%s*(%d+)%s*%]", i)
				if not idx then return nil, method .. "() must be followed by [index]" end
				local list = cur[method](cur)
				local r = list[tonumber(idx)]
				if not r then return nil, method .. "()[" .. idx .. "] out of range (" .. #list .. ")" end
				cur = r
				i = s:find("%]", i) + 1
			else
				return nil, "unsupported method in path: " .. method
			end
		else
			return nil, "unexpected character '" .. c .. "' at " .. i .. " in path: " .. s
		end
	end
	return cur
end

-- resolve any instance spec: Instance | ref number | "#12" | path string | {ref=}|{path=}|{["$t"]="Instance",...}
function B.inst(spec)
	local t = typeof(spec)
	if t == "Instance" then return spec end
	if t == "number" then
		local v = refs[spec]
		if v == nil then error("ref #" .. spec .. " does not exist", 0) end
		if typeof(v) ~= "Instance" then error("ref #" .. spec .. " is a " .. typeof(v) .. ", not an Instance", 0) end
		return v
	end
	if t == "string" then
		local r, err = B.resolvePath(spec)
		if not r then error(err or ("cannot resolve '" .. spec .. "'"), 0) end
		return r
	end
	if t == "table" then
		if spec.ref then return B.inst(tonumber(spec.ref)) end
		if spec.id then return B.inst(tonumber(spec.id)) end
		if spec.path then return B.inst(spec.path) end
		if spec.debug_id then
			local r, err = findByDebugId(spec.debug_id)
			if not r then error(err, 0) end
			return r
		end
	end
	error("invalid instance target (expected path string, ref number or {ref|path})", 0)
end

-- like B.inst but returns nil on failure instead of raising
function B.tryInst(spec)
	local ok, r = pcall(B.inst, spec)
	if ok then return r end
	return nil, r
end

-- resolve a ref to any value
function B.val(spec)
	local t = type(spec)
	if t == "number" then return B.getref(spec) end
	if t == "string" then
		local id = spec:match("^#?(%d+)$") or spec:match("^ref%((%d+)%)$")
		if id then return B.getref(tonumber(id)) end
		return B.inst(spec)
	end
	if t == "table" then
		if spec.ref then return B.getref(tonumber(spec.ref)) end
		if spec.id then return B.getref(tonumber(spec.id)) end
		return B.inst(spec)
	end
	error("invalid value target", 0)
end

-- typed function resolver: ref to a function, or a script instance -> its closure
function B.func(spec)
	local v = B.val(spec)
	if type(v) == "function" then return v end
	error("target is a " .. typeof(v) .. ", not a function", 0)
end

----------------------------------------------------------------------------------------------------
-- Deserializer: JSON-decoded tagged tree -> Lua values
----------------------------------------------------------------------------------------------------
local DE = {}
B.DE = DE

local function vec(x, k, d)
	return x.v or { x.x or x.X or d, x.y or x.Y or d, x.z or x.Z or d }
end

DE["nil"] = function() return nil end
DE.Vector3 = function(x) local v = vec(x) return Vector3.new(v[1] or 0, v[2] or 0, v[3] or 0) end
DE.Vector2 = function(x) local v = vec(x) return Vector2.new(v[1] or 0, v[2] or 0) end
DE.Vector3int16 = function(x) local v = vec(x) return Vector3int16.new(v[1] or 0, v[2] or 0, v[3] or 0) end
DE.Vector2int16 = function(x) local v = vec(x) return Vector2int16.new(v[1] or 0, v[2] or 0) end
DE.CFrame = function(x)
	local v = x.v or {}
	if #v >= 12 then return CFrame.new(unpack(v, 1, 12)) end
	if #v == 3 then return CFrame.new(v[1], v[2], v[3]) end
	if x.position then
		local p = x.position
		local cf = CFrame.new(p[1], p[2], p[3])
		if x.angles then
			local a = x.angles
			cf = cf * CFrame.Angles(math.rad(a[1]), math.rad(a[2]), math.rad(a[3]))
		end
		return cf
	end
	return CFrame.new()
end
DE.Color3 = function(x)
	if x.hex then
		local h = x.hex:gsub("#", "")
		return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
	end
	local v = x.v or {}
	if x.rgb255 or (v[1] and v[1] > 1) or (v[2] and v[2] > 1) or (v[3] and v[3] > 1) then
		return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
	end
	return Color3.new(v[1] or 0, v[2] or 0, v[3] or 0)
end
DE.BrickColor = function(x)
	if x.name then return BrickColor.new(x.name) end
	return BrickColor.new(x.number or 194)
end
DE.UDim = function(x) local v = x.v or {} return UDim.new(v[1] or 0, v[2] or 0) end
DE.UDim2 = function(x) local v = x.v or {} return UDim2.new(v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0) end
DE.Rect = function(x) local v = x.v or {} return Rect.new(v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0) end
DE.NumberRange = function(x) local v = x.v or {} return NumberRange.new(v[1] or 0, v[2] or v[1] or 0) end
DE.NumberSequence = function(x)
	local kp = {}
	for i, k in ipairs(x.keypoints or {}) do kp[i] = NumberSequenceKeypoint.new(k[1], k[2], k[3] or 0) end
	return NumberSequence.new(kp)
end
DE.ColorSequence = function(x)
	local kp = {}
	for i, k in ipairs(x.keypoints or {}) do kp[i] = ColorSequenceKeypoint.new(k[1], Color3.new(k[2], k[3], k[4])) end
	return ColorSequence.new(kp)
end
DE.Ray = function(x) local o, d = x.origin or {0,0,0}, x.direction or {0,0,0} return Ray.new(Vector3.new(unpack(o)), Vector3.new(unpack(d))) end
DE.PhysicalProperties = function(x) return PhysicalProperties.new(x.density, x.friction, x.elasticity, x.friction_weight or 1, x.elasticity_weight or 1) end
DE.EnumItem = function(x)
	local e = Enum[x.enum]
	if not e then error("unknown Enum '" .. tostring(x.enum) .. "'", 0) end
	if x.name then
		local it = e[x.name]
		if it then return it end
	end
	if x.value then
		for _, it in ipairs(e:GetEnumItems()) do if it.Value == x.value then return it end end
	end
	error("unknown enum item " .. tostring(x.enum) .. "." .. tostring(x.name or x.value), 0)
end
DE.Enum = function(x) return Enum[x.name:gsub("^Enum%.", "")] end
DE.Font = function(x)
	return Font.new(x.family or "rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight[x.weight and tostring(x.weight):gsub("^Enum%.FontWeight%.", "") or "Regular"], Enum.FontStyle[x.style and tostring(x.style):gsub("^Enum%.FontStyle%.", "") or "Normal"])
end
DE.TweenInfo = function(x)
	return TweenInfo.new(x.time or 1, Enum.EasingStyle[(x.easing_style or "Quad"):gsub("^Enum%.EasingStyle%.", "")], Enum.EasingDirection[(x.easing_direction or "Out"):gsub("^Enum%.EasingDirection%.", "")], x.repeat_count or 0, x.reverses or false, x.delay or 0)
end

DE.Instance = function(x)
	if x.ref then return B.inst(tonumber(x.ref)) end
	if x.path then return B.inst(x.path) end
	if x.debug_id then return B.inst({ debug_id = x.debug_id }) end
	error("Instance value needs ref or path", 0)
end
DE.ref = function(x) return B.getref(tonumber(x.id or x.ref)) end
DE.Ref = DE.ref

local function deTable(x, depth)
	local out = {}
	for k, v in pairs(x) do
		if k ~= "$t" then
			local nk = k
			out[nk] = B.de(v, depth + 1)
		end
	end
	return out
end

local function deRefTag(x)
	if x.ref then return true, B.getref(tonumber(x.ref)) end
	return false
end
DE["function"] = function(x) local ok, v = deRefTag(x) if ok then return v end error("function value needs ref", 0) end
DE.thread = DE["function"]
DE.userdata = DE["function"]
DE.Signal = DE["function"]
DE.Connection = DE["function"]
DE.buffer = function(x)
	if x.ref then return B.getref(tonumber(x.ref)) end
	local s = x.b64 and B.b64decode(x.b64) or (x.hex and (x.hex:gsub("%x%x", function(h) return string.char(tonumber(h, 16)) end))) or ""
	local b = buffer.create(#s)
	buffer.writestring(b, 0, s)
	return b
end
DE.bytes = function(x) return B.b64decode(x.b64 or "") end
DE.number = function(x)
	local v = x.v
	if v == "nan" then return 0 / 0 end
	if v == "inf" then return math.huge end
	if v == "-inf" then return -math.huge end
	return tonumber(v)
end
DE.string = function(x) return x.v end
DE.table = function(x, depth)
	local okr, v = deRefTag(x)
	if okr then return v end
	local out = {}
	if x.fields then
		for k, v2 in pairs(x.fields) do out[k] = B.de(v2, (depth or 0) + 1) end
	end
	return out
end
DE.array = function(x, depth)
	local okr, v = deRefTag(x)
	if okr then return v end
	local out = {}
	local items = x.items or {}
	for i = 1, #items do out[i] = B.de(items[i], (depth or 0) + 1) end
	return out
end
DE.RBXScriptSignal = DE.Signal

function B.de(x, depth)
	if type(x) ~= "table" then return x end
	depth = depth or 0
	if depth > 40 then error("value nested too deeply", 0) end
	local tg = x["$t"]
	if tg ~= nil then
		local f = DE[tg]
		if not f then error("unknown value tag '$t': '" .. tostring(tg) .. "'", 0) end
		return f(x, depth)
	end
	local out = {}
	for k, v in pairs(x) do out[k] = B.de(v, depth + 1) end
	return out
end

-- decode a JSON args list to a pack preserving nils ({"$t":"nil"} entries)
function B.deArgs(list)
	if list == nil then return { n = 0 } end
	if type(list) ~= "table" then return { n = 1, B.de(list) } end
	local maxn = 0
	for k in pairs(list) do if type(k) == "number" and k > maxn then maxn = k end end
	local pk = { n = maxn }
	for i = 1, maxn do pk[i] = B.de(list[i]) end
	return pk
end

end}

PARTS[#PARTS + 1] = {"20_events", function(B)
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

end}

PARTS[#PARTS + 1] = {"30_instances", function(B)
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

end}

PARTS[#PARTS + 1] = {"31_properties", function(B)
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

end}

PARTS[#PARTS + 1] = {"40_scripts", function(B)
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

end}

PARTS[#PARTS + 1] = {"50_luaruntime", function(B)
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

end}

PARTS[#PARTS + 1] = {"60_hooks", function(B)
-- 60_hooks: shared __namecall/__index/__newindex hook, traps, function hooks, watches, executor/http spy
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local E = B.Events
local NULL = B.NULL
local typeof = typeof or type
local gm = game

local function callerScript()
	if not C.getcallingscript then return nil end
	local ok, s = pcall(C.getcallingscript)
	if ok and typeof(s) == "Instance" then
		local ok2, p = pcall(B.pathOf, s)
		return ok2 and p or tostring(s)
	end
	return nil
end
B.callerScript = callerScript

local function trace(maxLen)
	if not C.traceback then return nil end
	local ok, t = pcall(C.traceback, "", 2)
	if ok and t then return B.trunc(t, maxLen or 1500) end
	return nil
end
B.trace = trace

local function isExecCaller()
	if not C.checkcaller then return false end
	local ok, r = pcall(C.checkcaller)
	return ok and r
end
B.isExecCaller = isExecCaller

----------------------------------------------------------------------------------------------------
-- shared __namecall hook with per-method handler chains
----------------------------------------------------------------------------------------------------
local NC = { handlers = {}, nextId = 1, composed = {}, installed = false }
B.NC = NC
local oldNamecall

local function rebuild(method)
	local list = NC.handlers[method]
	if not list or #list == 0 then
		NC.handlers[method] = nil
		NC.composed[method] = nil
		return
	end
	local snm = C.setnamecallmethod
	local nextf = function(self, ...)
		if snm then snm(method) end
		return oldNamecall(self, ...)
	end
	for i = #list, 1, -1 do
		local h, nf = list[i].fn, nextf
		nextf = function(self, ...) return h(nf, self, ...) end
	end
	NC.composed[method] = nextf
end

local function installNamecall()
	if NC.installed then return end
	local hmm = B.need("hookmetamethod")
	local gnm = B.need("getnamecallmethod")
	local nccl = C.newcclosure or function(f) return f end
	local composed = NC.composed
	oldNamecall = hmm(gm, "__namecall", nccl(function(self, ...)
		local f = composed[gnm()]
		if f then return f(self, ...) end
		return oldNamecall(self, ...)
	end))
	NC.installed = true
end

function NC.add(method, fn, owner)
	installNamecall()
	local id = NC.nextId
	NC.nextId = id + 1
	local list = NC.handlers[method]
	if not list then list = {} NC.handlers[method] = list end
	list[#list + 1] = { id = id, fn = fn, owner = owner }
	rebuild(method)
	return id
end

function NC.remove(id)
	for method, list in pairs(NC.handlers) do
		for i, h in ipairs(list) do
			if h.id == id then
				table.remove(list, i)
				rebuild(method)
				return true
			end
		end
	end
	return false
end

function NC.callOld(method, self, ...)
	if C.setnamecallmethod then C.setnamecallmethod(method) end
	return oldNamecall(self, ...)
end

----------------------------------------------------------------------------------------------------
-- __index / __newindex hooks (only installed on demand; keyed by member name for a cheap fast path)
----------------------------------------------------------------------------------------------------
local IX = { index = {}, newindex = {}, installed = {} }
local oldIndex, oldNewindex

local function installMeta(kind)
	if IX.installed[kind] then return end
	local hmm = B.need("hookmetamethod")
	local nccl = C.newcclosure or function(f) return f end
	local chk = C.checkcaller
	if kind == "index" then
		oldIndex = hmm(gm, "__index", nccl(function(self, key)
			local hs = IX.index[key]
			if hs and not (chk and chk()) then
				local result = oldIndex(self, key)
				for _, h in ipairs(hs) do
					local ok, over = pcall(h.fn, self, key, result)
					if ok and over ~= nil and over ~= NULL then return over[1] end
				end
				return result
			end
			return oldIndex(self, key)
		end))
	else
		oldNewindex = hmm(gm, "__newindex", nccl(function(self, key, value)
			local hs = IX.newindex[key]
			if hs and not (chk and chk()) then
				for _, h in ipairs(hs) do
					local ok, block = pcall(h.fn, self, key, value)
					if ok and block == true then return end
				end
			end
			return oldNewindex(self, key, value)
		end))
	end
	IX.installed[kind] = true
end

----------------------------------------------------------------------------------------------------
-- traps
----------------------------------------------------------------------------------------------------
local traps = {}
local nextTrap = 1
local busy = false

local function trapMatches(t, self)
	if typeof(self) ~= "Instance" then return false end
	if t.target and self ~= t.target then return false end
	if t.class and not self:IsA(t.class) then return false end
	if t.name_match and not t.name_match(self.Name) then return false end
	return true
end

local function trapLog(t, self, extra)
	t.count = t.count + 1
	if t.log == false then return end
	local ok, path = pcall(B.pathOf, self)
	local ev = {
		key = t.kind .. ":" .. t.member .. " " .. (ok and path or "?"),
		trap = t.id,
		kind = t.kind,
		member = t.member,
		instance = ok and path or tostring(self),
		class = self.ClassName,
	}
	for k, v in pairs(extra or {}) do ev[k] = v end
	if t.capture_script ~= false then ev.script = callerScript() end
	if t.capture_stack then ev.stack = trace(2000) end
	E.push("trap", ev)
end

H.trap_add = function(p)
	local kind = p.kind or "namecall"
	if kind ~= "namecall" and kind ~= "index" and kind ~= "newindex" then error("kind must be namecall|index|newindex", 0) end
	if not p.member then error("member is required (method name for namecall, property name for index/newindex)", 0) end
	local t = {
		id = nextTrap,
		kind = kind,
		member = p.member,
		class = p.class,
		target = p.target and B.inst(p.target) or nil,
		name_match = p.name and B.matcher(p.name, p.name_mode, true) or nil,
		action = p.action or "log",
		value = p.value,
		log = p.log,
		capture_stack = p.capture_stack,
		capture_script = p.capture_script,
		log_args = p.log_args ~= false,
		count = 0,
		include_executor = p.include_executor,
	}
	nextTrap = nextTrap + 1
	if t.action == "return" or t.action == "set" then t.valueDecoded = B.de(p.value) end
	if p.code then
		local fn, err = B.need("loadstring")(p.code, "=trap")
		if not fn then error("compile error: " .. tostring(err), 0) end
		t.fn = fn()
	end

	if kind == "namecall" then
		t.hid = NC.add(p.member, function(nextf, self, ...)
			if busy or not trapMatches(t, self) or (not t.include_executor and isExecCaller()) then return nextf(self, ...) end
			busy = true
			local args = B.pack(...)
			local extra = {}
			if t.log_args then extra.args = B.serPack(args, { depth = 2, maxItems = 20, maxStr = 400 }) end
			local okLog = pcall(trapLog, t, self, extra)
			busy = false
			if t.action == "block" then return end
			if t.action == "return" then return t.valueDecoded end
			if t.action == "lua" and t.fn then return t.fn(nextf, self, ...) end
			return nextf(self, ...)
		end, "trap" .. t.id)
	elseif kind == "index" then
		installMeta("index")
		local list = IX.index[p.member] or {}
		IX.index[p.member] = list
		t.hentry = { fn = function(self, key, result)
			if busy or not trapMatches(t, self) then return nil end
			busy = true
			pcall(trapLog, t, self, { value = B.ser(result, { depth = 1, maxItems = 8, maxStr = 200 }) })
			busy = false
			if t.action == "return" then return { t.valueDecoded } end
			return nil
		end }
		list[#list + 1] = t.hentry
	else
		installMeta("newindex")
		local list = IX.newindex[p.member] or {}
		IX.newindex[p.member] = list
		t.hentry = { fn = function(self, key, value)
			if busy or not trapMatches(t, self) then return false end
			busy = true
			pcall(trapLog, t, self, { new_value = B.ser(value, { depth = 1, maxItems = 8, maxStr = 200 }) })
			busy = false
			return t.action == "block"
		end }
		list[#list + 1] = t.hentry
	end
	traps[t.id] = t
	return { trap = t.id, kind = kind, member = t.member, action = t.action }
end

H.trap_remove = function(p)
	local t = traps[p.id]
	if not t then error("no trap #" .. tostring(p.id), 0) end
	if t.hid then NC.remove(t.hid) end
	if t.hentry then
		local list = (t.kind == "index" and IX.index or IX.newindex)[t.member]
		if list then
			for i, h in ipairs(list) do
				if h == t.hentry then table.remove(list, i) break end
			end
			if #list == 0 then (t.kind == "index" and IX.index or IX.newindex)[t.member] = nil end
		end
	end
	traps[t.id] = nil
	return { removed = t.id, hits = t.count }
end

H.trap_list = function(p)
	local out = {}
	for id, t in pairs(traps) do
		out[#out + 1] = {
			id = id, kind = t.kind, member = t.member, action = t.action, hits = t.count,
			class = t.class, target = t.target and B.instPath(t.target) or nil,
		}
	end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { traps = out }
end

----------------------------------------------------------------------------------------------------
-- function hooks
----------------------------------------------------------------------------------------------------
local hooks = {}
local nextHook = 1

local function newCaller(h)
	return {
		args = nil,
	}
end

H.hook_function = function(p)
	local f = B.func(p.ref or p.target)
	local hookfn = B.need("hookfunction")
	local mode = p.mode or "log"
	local h = { id = nextHook, target = f, mode = mode, calls = 0, name = p.label, include_executor = p.include_executor, max_log = p.max_log or 3000 }
	nextHook = nextHook + 1
	local info = B.funcInfo(f)
	h.name = h.name or info.name or "?"
	local orig
	local outOpts = { depth = 2, maxItems = 20, maxStr = 400 }
	local fixedReturn
	if mode == "return" then fixedReturn = B.deArgs(p.values or { p.value }) end
	local userFn
	if mode == "wrap" or p.code then
		local fn, err = B.need("loadstring")(p.code, "=hook" .. h.id)
		if not fn then error("compile error: " .. tostring(err), 0) end
		userFn = fn()
		if type(userFn) ~= "function" then error("code must evaluate to a function(orig, ...) ... end", 0) end
	end

	local function record(args, res, err)
		h.calls = h.calls + 1
		if h.calls > h.max_log and p.stop_after_max then return end
		local ev = {
			key = h.name,
			hook = h.id,
			name = h.name,
			args = B.serPack(args, outOpts),
		}
		if res then ev.results = B.serPack(res, outOpts) end
		if err then ev.error = tostring(err) end
		ev.script = callerScript()
		if p.capture_stack then ev.stack = trace(2000) end
		E.push("hook", ev)
	end

	local function replacement(...)
		if not h.include_executor and isExecCaller() then return orig(...) end
		if mode == "block" then
			local args = B.pack(...)
			pcall(record, args, nil, nil)
			return
		elseif mode == "return" then
			pcall(record, B.pack(...), nil, nil)
			return B.unpack(fixedReturn)
		elseif userFn then
			pcall(record, B.pack(...), nil, nil)
			return userFn(orig, ...)
		end
		local args = B.pack(...)
		local res = B.pack(pcall(orig, ...))
		local okCall = res[1]
		if okCall then
			local r = { n = res.n - 1 }
			for i = 2, res.n do r[i - 1] = res[i] end
			pcall(record, args, r, nil)
			return B.unpack(r)
		end
		pcall(record, args, nil, res[2])
		error(res[2], 0)
	end

	local repl = replacement
	if C.iscclosure then
		local ok, isC = pcall(C.iscclosure, f)
		if ok and isC and C.newcclosure then repl = C.newcclosure(replacement) end
	end
	orig = hookfn(f, repl)
	h.orig = orig
	hooks[h.id] = h
	return { hook = h.id, name = h.name, mode = mode, target = B.ser(f, { depth = 0 }) }
end

H.hook_global = function(p)
	local f = B.lookup(p.name)
	if type(f) ~= "function" then error("global '" .. tostring(p.name) .. "' is not a function", 0) end
	p.ref = B.ref(f)
	p.label = p.label or p.name
	return H.hook_function(p)
end

H.unhook_function = function(p)
	local h = hooks[p.id]
	if not h then error("no function hook #" .. tostring(p.id), 0) end
	local ok = false
	if C.restorefunction then ok = pcall(C.restorefunction, h.target) end
	if not ok then
		local hookfn = B.need("hookfunction")
		hookfn(h.target, h.orig)
	end
	hooks[h.id] = nil
	return { removed = h.id, calls = h.calls }
end

H.list_hooks = function(p)
	local out = {}
	for id, h in pairs(hooks) do
		out[#out + 1] = { id = id, name = h.name, mode = h.mode, calls = h.calls }
	end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { hooks = out, traps = H.trap_list({}).traps, namecall_installed = NC.installed }
end

----------------------------------------------------------------------------------------------------
-- watches (property / children / attribute / signal)
----------------------------------------------------------------------------------------------------
local watches = {}
local nextWatch = 1

local function addWatch(kind, desc, conns)
	local w = { id = nextWatch, kind = kind, desc = desc, conns = conns, count = 0 }
	nextWatch = nextWatch + 1
	watches[w.id] = w
	return w
end

H.watch_property = function(p)
	local inst = B.inst(p.target)
	local prop = p.property
	local path = B.pathOf(inst)
	local w
	local conn = inst:GetPropertyChangedSignal(prop):Connect(function()
		w.count = w.count + 1
		local ok, v = pcall(function() return inst[prop] end)
		E.push("watch", {
			key = path .. "." .. prop,
			watch = w.id,
			kind = "property",
			instance = path,
			property = prop,
			value = ok and B.ser(v, { depth = 1, maxItems = 10, maxStr = 300 }) or NULL,
			stack = p.capture_stack and trace(1500) or nil,
			script = p.capture_script and callerScript() or nil,
		})
	end)
	w = addWatch("property", path .. "." .. prop, { conn })
	return { watch = w.id, watching = w.desc }
end

H.watch_children = function(p)
	local inst = B.inst(p.target)
	local path = B.pathOf(inst)
	local deep = p.descendants == true
	local w
	local function push(event, child)
		w.count = w.count + 1
		local ok, cp = pcall(B.pathOf, child)
		E.push("tree", { key = event .. " " .. (ok and cp or tostring(child)), watch = w.id, event = event, parent = path, class = child.ClassName, name = child.Name, path = ok and cp or nil, ref = B.ref(child) })
	end
	local c1 = (deep and inst.DescendantAdded or inst.ChildAdded):Connect(function(ch) push("added", ch) end)
	local c2 = (deep and inst.DescendantRemoving or inst.ChildRemoved):Connect(function(ch) push("removed", ch) end)
	w = addWatch("children", path .. (deep and " (descendants)" or " (children)"), { c1, c2 })
	return { watch = w.id, watching = w.desc }
end

H.watch_attribute = function(p)
	local inst = B.inst(p.target)
	local path = B.pathOf(inst)
	local w
	local sig = p.name and inst:GetAttributeChangedSignal(p.name) or inst.AttributeChanged
	local conn = sig:Connect(function(name)
		w.count = w.count + 1
		local attr = p.name or name
		E.push("watch", { key = path .. "@" .. tostring(attr), watch = w.id, kind = "attribute", instance = path, attribute = attr, value = B.ser(inst:GetAttribute(attr), { depth = 1 }) })
	end)
	w = addWatch("attribute", path .. "@" .. (p.name or "*"), { conn })
	return { watch = w.id, watching = w.desc }
end

H.watch_signal = function(p)
	local inst = B.inst(p.target)
	local name = p.signal
	local sig = inst[name]
	if typeof(sig) ~= "RBXScriptSignal" then error(inst.ClassName .. "." .. tostring(name) .. " is not a signal", 0) end
	local path = B.pathOf(inst)
	local w
	local conn = sig:Connect(function(...)
		w.count = w.count + 1
		E.push("signal", { key = path .. "." .. name, watch = w.id, instance = path, signal = name, args = B.serPack(B.pack(...), { depth = 2, maxItems = 15, maxStr = 300 }) })
	end)
	w = addWatch("signal", path .. "." .. name, { conn })
	return { watch = w.id, watching = w.desc }
end

H.unwatch = function(p)
	local w = watches[p.id]
	if not w then error("no watch #" .. tostring(p.id), 0) end
	for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
	watches[w.id] = nil
	return { removed = w.id, events = w.count }
end

H.unwatch_all = function(p)
	local n = 0
	for id, w in pairs(watches) do
		for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
		watches[id] = nil
		n = n + 1
	end
	return { removed = n }
end

H.list_watches = function(p)
	local out = {}
	for id, w in pairs(watches) do out[#out + 1] = { id = id, kind = w.kind, desc = w.desc, events = w.count } end
	table.sort(out, function(a, b) return a.id < b.id end)
	return { watches = out }
end

----------------------------------------------------------------------------------------------------
-- network / executor spy: request, HttpGet/Post, HttpService, WebSocket.connect, loadstring
----------------------------------------------------------------------------------------------------
local spy = { active = false, hooked = {}, ncIds = {}, opts = {} }

local function shortBody(b, n)
	if type(b) ~= "string" then return b end
	return B.trunc(b, n or 4000)
end

local function spyLog(kind, data)
	data.kind = kind
	data.key = data.key or (kind .. " " .. tostring(data.url or data.chunk or ""))
	data.script = callerScript()
	if spy.opts.capture_stack then data.stack = trace(1500) end
	E.push("http", data)
end

H.http_spy_start = function(p)
	spy.opts = { capture_stack = p.capture_stack, body_limit = p.body_limit or 4000 }
	if spy.active then return { already_active = true } end
	spy.active = true
	local started = {}
	local bl = spy.opts.body_limit

	-- executor request()
	if C.request and C.hookfunction then
		local old
		local function repl(opts, ...)
			if spy.active and type(opts) == "table" then
				local res = B.pack(pcall(old, opts, ...))
				local d = {
					url = tostring(opts.Url or opts.url),
					method = tostring(opts.Method or opts.method or "GET"),
					headers = B.serWith(opts.Headers or opts.headers or {}, { depth = 1, maxItems = 20 }),
					body = shortBody(opts.Body or opts.body, bl),
				}
				if res[1] and type(res[2]) == "table" then
					d.status = res[2].StatusCode
					d.response_body = shortBody(res[2].Body, bl)
				elseif not res[1] then
					d.error = tostring(res[2])
				end
				pcall(spyLog, "request", d)
				if not res[1] then error(res[2], 0) end
				return unpack(res, 2, res.n)
			end
			return old(opts, ...)
		end
		old = C.hookfunction(C.request, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = C.request, orig = old }
		started[#started + 1] = "request"
	end

	-- loadstring (shows what code gets compiled and from where)
	if C.loadstring and C.hookfunction and p.loadstring ~= false then
		local old
		local function repl(code, chunk, ...)
			if spy.active and type(code) == "string" then
				pcall(spyLog, "loadstring", { chunk = tostring(chunk), length = #code, head = B.trunc(code, p.loadstring_head or 600), key = "loadstring " .. tostring(chunk) })
			end
			return old(code, chunk, ...)
		end
		old = C.hookfunction(C.loadstring, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = C.loadstring, orig = old }
		started[#started + 1] = "loadstring"
	end

	-- WebSocket.connect
	local ws = C.WebSocket
	if type(ws) == "table" and type(ws.connect) == "function" and C.hookfunction then
		local old
		local function repl(url, ...)
			if spy.active then pcall(spyLog, "websocket", { url = tostring(url) }) end
			return old(url, ...)
		end
		old = C.hookfunction(ws.connect, C.newcclosure and C.newcclosure(repl) or repl)
		spy.hooked[#spy.hooked + 1] = { fn = ws.connect, orig = old }
		started[#started + 1] = "WebSocket.connect"
	end

	-- namecall-based: game:HttpGet/HttpPost, HttpService:RequestAsync/GetAsync/PostAsync
	local function ncSpy(method, selfCheck)
		local id = NC.add(method, function(nextf, self, ...)
			if spy.active and not busy and selfCheck(self) then
				local a1, a2 = ...
				if type(a1) == "table" then
					pcall(spyLog, method, { url = tostring(a1.Url), method = tostring(a1.Method or "GET"), body = shortBody(a1.Body, bl), headers = B.serWith(a1.Headers or {}, { depth = 1 }) })
				else
					pcall(spyLog, method, { url = tostring(a1), body = shortBody(a2, bl) })
				end
			end
			return nextf(self, ...)
		end, "httpspy")
		spy.ncIds[#spy.ncIds + 1] = id
	end
	local isGame = function(s) return s == gm end
	local isHttp = function(s) return typeof(s) == "Instance" and s.ClassName == "HttpService" end
	for _, m in ipairs({ "HttpGet", "HttpGetAsync", "HttpPost", "HttpPostAsync" }) do ncSpy(m, isGame) end
	for _, m in ipairs({ "RequestAsync", "GetAsync", "PostAsync" }) do ncSpy(m, isHttp) end
	started[#started + 1] = "namecall:Http*"
	return { active = true, hooked = started }
end

H.http_spy_stop = function(p)
	spy.active = false
	-- leave hooks in place but inert (restoring in-place hooks can race with other scripts); try restore anyway
	for _, h in ipairs(spy.hooked) do
		if C.restorefunction then pcall(C.restorefunction, h.fn) end
	end
	spy.hooked = {}
	for _, id in ipairs(spy.ncIds) do NC.remove(id) end
	spy.ncIds = {}
	return { active = false }
end

H.http_spy_status = function(p)
	return { active = spy.active, hooks = #spy.hooked, events = E.size("http") }
end

----------------------------------------------------------------------------------------------------
-- output + error capture (always on, cheap)
----------------------------------------------------------------------------------------------------
B.startCaptures = function()
	local ok1 = pcall(function()
		service.LogService.MessageOut:Connect(function(message, mtype)
			E.push("output", { key = message, message = message, level = tostring(mtype):gsub("Enum.MessageType.", "") })
		end)
	end)
	local ok2 = pcall(function()
		service.ScriptContext.Error:Connect(function(message, stackTrace, scr)
			local sp
			if typeof(scr) == "Instance" then
				local ok, pth = pcall(B.pathOf, scr)
				sp = ok and pth or tostring(scr)
			end
			E.push("error", { key = tostring(message), message = tostring(message), stack = B.trunc(tostring(stackTrace), 2000), script = sp })
		end)
	end)
	return ok1, ok2
end

H.get_output = function(p)
	-- snapshot of Roblox's own log history merged with captured MessageOut events
	local out = {}
	local limit = p.limit or 100
	local levelM = p.level and B.matcher(p.level, "plain", true) or nil
	local m = p.match and B.matcher(p.match, p.match_mode, true) or nil
	local hist = service.LogService:GetLogHistory()
	local startI = math.max(1, #hist - (p.history or 300) + 1)
	if p.since == nil then
		for i = startI, #hist do
			local h = hist[i]
			local lvl = tostring(h.messageType):gsub("Enum.MessageType.", "")
			if (not levelM or levelM(lvl)) and (not m or m(h.message)) then
				out[#out + 1] = { message = B.trunc(h.message, 1000), level = lvl, t = h.timestamp }
			end
		end
		local n = #out
		if n > limit then
			local trimmed = {}
			for i = n - limit + 1, n do trimmed[#trimmed + 1] = out[i] end
			out = trimmed
		end
		return { messages = out, last_seq = E.seq, source = "log_history" }
	end
	local evs, matched, lastSeq = E.query("output", p.since, function(ev)
		return (not levelM or levelM(ev.level)) and (not m or m(ev.message))
	end, limit, false)
	return { messages = evs, matched = matched, last_seq = lastSeq, source = "events" }
end

H.clear_output = function(p)
	pcall(function() service.LogService:ClearOutput() end)
	E.clear("output")
	return { ok = true }
end

end}

PARTS[#PARTS + 1] = {"61_remotes", function(B)
-- 61_remotes: remote spy (outgoing FireServer/InvokeServer, incoming OnClientEvent), block/ignore, replay, handler mapping
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local E = B.Events
local NC = B.NC
local NULL = B.NULL
local typeof = typeof or type
local gm = game

local REMOTE_OUT = { RemoteEvent = "FireServer", UnreliableRemoteEvent = "FireServer", RemoteFunction = "InvokeServer" }
local BINDABLE_OUT = { BindableEvent = "Fire", BindableFunction = "Invoke" }

local RS = {
	active = false,
	opts = {},
	ncIds = {},
	fnHooks = {},
	inNC = setmetatable({}, { __mode = "k" }),
	stats = setmetatable({}, { __mode = "k" }),
	ignored = setmetatable({}, { __mode = "k" }),
	ignoreNames = {},
	blocked = setmetatable({}, { __mode = "k" }),
	pathCache = setmetatable({}, { __mode = "k" }),
	raw = {},
	rawOrder = {},
	incomingConns = {},
	total = 0,
}
B.RS = RS

local function remotePath(r)
	local p = RS.pathCache[r]
	if p then return p end
	local ok, s = pcall(B.pathOf, r)
	p = ok and s or tostring(r)
	RS.pathCache[r] = p
	return p
end

local function sigOf(pk)
	local t = {}
	for i = 1, pk.n do
		local ty = typeof(pk[i])
		if ty == "table" then
			local n = 0
			for _ in next, pk[i] do n = n + 1 if n > 50 then break end end
			ty = "table(" .. n .. ")"
		end
		t[i] = ty
	end
	return table.concat(t, ",")
end

local function isIgnored(r)
	if RS.ignored[r] then return true end
	if #RS.ignoreNames > 0 then
		local nm = r.Name
		for _, m in ipairs(RS.ignoreNames) do if m(nm) then return true end end
	end
	return false
end

local function rememberRaw(seq, entry)
	RS.raw[seq] = entry
	RS.rawOrder[#RS.rawOrder + 1] = seq
	local cap = RS.opts.raw_cap or 500
	while #RS.rawOrder > cap do
		local old = table.remove(RS.rawOrder, 1)
		RS.raw[old] = nil
	end
end

local function logCall(remote, method, dir, args, results, err, elapsed, blocked)
	RS.total = RS.total + 1
	local st = RS.stats[remote]
	if not st then
		st = { count = 0, first = B.now(), sigs = {}, class = remote.ClassName, path = remotePath(remote), logged = 0 }
		RS.stats[remote] = st
	end
	st.count = st.count + 1
	st.last = B.now()
	local sig = sigOf(args)
	st.sigs[sig] = (st.sigs[sig] or 0) + 1
	if blocked then st.blocked = (st.blocked or 0) + 1 end

	local perRemote = RS.opts.max_per_remote or 2000
	if st.logged >= perRemote then return end
	local every = RS.opts.sample_every or 1
	if every > 1 and st.count % every ~= 1 then return end
	st.logged = st.logged + 1

	local ev = {
		key = st.path .. " " .. method,
		remote = st.path,
		remote_ref = B.ref(remote),
		class = st.class,
		method = method,
		dir = dir,
		args = B.serPack(args, RS.opts.ser or { depth = 3, maxItems = 30, maxStr = 1500 }),
		arg_count = args.n,
	}
	if results then ev.results = B.serPack(results, RS.opts.ser or { depth = 3, maxItems = 30, maxStr = 1500 }) end
	if err then ev.error = tostring(err) end
	if elapsed then ev.elapsed = elapsed end
	if blocked then ev.blocked = true end
	if dir == "out" then
		if RS.opts.capture_script ~= false then ev.script = B.callerScript() end
		if RS.opts.capture_stack then ev.stack = B.trace(2500) end
		if C.checkcaller and RS.opts.include_executor then
			local ok, r = pcall(C.checkcaller)
			ev.from_executor = ok and r or nil
		end
	end
	local seq = E.push("remote", ev)
	rememberRaw(seq, { remote = remote, method = method, args = args, dir = dir })
	return seq
end

local function shouldHandle(self)
	if not RS.active then return false end
	if typeof(self) ~= "Instance" then return false end
	if isIgnored(self) then return false end
	if not RS.opts.include_executor and B.isExecCaller() then return false end
	return true
end

local function outHandler(method, classMap)
	return function(nextf, self, ...)
		local cls
		if RS.active and typeof(self) == "Instance" then cls = self.ClassName end
		if not cls or classMap[cls] ~= method or not shouldHandle(self) then return nextf(self, ...) end
		local th = coroutine.running()
		RS.inNC[th] = true
		local args = B.pack(...)
		local blk = RS.blocked[self]
		if blk then
			pcall(logCall, self, method, "out", args, nil, nil, nil, true)
			RS.inNC[th] = nil
			if blk.mode == "return" then return B.unpack(blk.values) end
			return
		end
		if method == "InvokeServer" or method == "Invoke" then
			local t0 = os.clock()
			local res = B.pack(pcall(nextf, self, ...))
			RS.inNC[th] = nil
			if res[1] then
				local r = { n = res.n - 1 }
				for i = 2, res.n do r[i - 1] = res[i] end
				pcall(logCall, self, method, "out", args, r, nil, os.clock() - t0)
				return B.unpack(r)
			end
			pcall(logCall, self, method, "out", args, nil, res[2], os.clock() - t0)
			error(res[2], 0)
		end
		pcall(logCall, self, method, "out", args)
		-- keep the dedupe flag set while the original runs: it may route through the function-level hook
		local res = B.pack(pcall(nextf, self, ...))
		RS.inNC[th] = nil
		if not res[1] then error(res[2], 0) end
		return unpack(res, 2, res.n)
	end
end

local function connectIncoming(remote)
	local cn = remote.ClassName
	if cn ~= "RemoteEvent" and cn ~= "UnreliableRemoteEvent" then return end
	if RS.incomingConns[remote] then return end
	local handler = function(...)
		if not RS.active or isIgnored(remote) then return end
		pcall(logCall, remote, "OnClientEvent", "in", B.pack(...))
	end
	B.ownFns[handler] = true
	local ok, conn = pcall(function() return remote.OnClientEvent:Connect(handler) end)
	if ok then RS.incomingConns[remote] = conn end
end

H.remote_spy_start = function(p)
	if RS.active then
		-- allow reconfiguration
		for k, v in pairs(p) do RS.opts[k] = v end
		return { active = true, reconfigured = true }
	end
	RS.opts = {
		include_executor = p.include_executor,
		capture_stack = p.capture_stack,
		capture_script = p.capture_script,
		max_per_remote = p.max_per_remote,
		sample_every = p.sample_every,
		raw_cap = p.raw_cap,
		ser = p.depth and { depth = p.depth, maxItems = p.max_items or 30, maxStr = p.max_str or 1500 } or nil,
	}
	RS.active = true
	local started = {}

	RS.ncIds[#RS.ncIds + 1] = NC.add("FireServer", outHandler("FireServer", REMOTE_OUT), "remotespy")
	RS.ncIds[#RS.ncIds + 1] = NC.add("InvokeServer", outHandler("InvokeServer", REMOTE_OUT), "remotespy")
	started[#started + 1] = "namecall:FireServer/InvokeServer"
	if p.bindables then
		RS.ncIds[#RS.ncIds + 1] = NC.add("Fire", outHandler("Fire", BINDABLE_OUT), "remotespy")
		RS.ncIds[#RS.ncIds + 1] = NC.add("Invoke", outHandler("Invoke", BINDABLE_OUT), "remotespy")
		started[#started + 1] = "namecall:Fire/Invoke(bindables)"
	end

	-- direct calls: remote.FireServer(remote, ...) bypasses __namecall
	if p.hook_functions ~= false and C.hookfunction then
		local function hookMethod(className, method)
			local ok, err = pcall(function()
				local inst = Instance.new(className)
				local fn = inst[method]
				local orig
				local function replacement(self, ...)
					if RS.active and not RS.inNC[coroutine.running()] and typeof(self) == "Instance" and REMOTE_OUT[self.ClassName] == method and shouldHandle(self) then
						local args = B.pack(...)
						local blk = RS.blocked[self]
						if blk then
							pcall(logCall, self, method, "out", args, nil, nil, nil, true)
							if blk.mode == "return" then return B.unpack(blk.values) end
							return
						end
						if method == "InvokeServer" then
							local t0 = os.clock()
							local res = B.pack(pcall(orig, self, ...))
							if res[1] then
								local r = { n = res.n - 1 }
								for i = 2, res.n do r[i - 1] = res[i] end
								pcall(logCall, self, method, "out", args, r, nil, os.clock() - t0)
								return B.unpack(r)
							end
							pcall(logCall, self, method, "out", args, nil, res[2], os.clock() - t0)
							error(res[2], 0)
						end
						pcall(logCall, self, method, "out", args)
					end
					return orig(self, ...)
				end
				orig = C.hookfunction(fn, C.newcclosure and C.newcclosure(replacement) or replacement)
				RS.fnHooks[#RS.fnHooks + 1] = { fn = fn, orig = orig }
				pcall(inst.Destroy, inst)
			end)
			if ok then started[#started + 1] = "function:" .. className .. "." .. method end
		end
		hookMethod("RemoteEvent", "FireServer")
		hookMethod("RemoteFunction", "InvokeServer")
		hookMethod("UnreliableRemoteEvent", "FireServer")
	end

	if p.incoming ~= false then
		local n = 0
		for _, d in ipairs(gm:GetDescendants()) do
			if d.ClassName == "RemoteEvent" or d.ClassName == "UnreliableRemoteEvent" then connectIncoming(d) n = n + 1 end
		end
		if C.getnilinstances then
			for _, d in ipairs(C.getnilinstances()) do
				if d.ClassName == "RemoteEvent" or d.ClassName == "UnreliableRemoteEvent" then connectIncoming(d) n = n + 1 end
			end
		end
		RS.descConn = gm.DescendantAdded:Connect(function(d)
			if RS.active then connectIncoming(d) end
		end)
		started[#started + 1] = "incoming:" .. n .. " RemoteEvents"
	end
	return { active = true, hooked = started }
end

H.remote_spy_stop = function(p)
	RS.active = false
	for _, id in ipairs(RS.ncIds) do NC.remove(id) end
	RS.ncIds = {}
	for _, h in ipairs(RS.fnHooks) do
		local ok = false
		if C.restorefunction then ok = pcall(C.restorefunction, h.fn) end
		if not ok and C.hookfunction then pcall(C.hookfunction, h.fn, h.orig) end
	end
	RS.fnHooks = {}
	for r, c in pairs(RS.incomingConns) do pcall(function() c:Disconnect() end) end
	RS.incomingConns = {}
	if RS.descConn then RS.descConn:Disconnect() RS.descConn = nil end
	return { active = false, total_calls_seen = RS.total }
end

H.remote_spy_status = function(p)
	local remotes = 0
	for _ in pairs(RS.stats) do remotes = remotes + 1 end
	return {
		active = RS.active,
		total_calls_seen = RS.total,
		distinct_remotes = remotes,
		buffered = E.size("remote"),
		ignored = B.count(RS.ignored) + #RS.ignoreNames,
		blocked = B.count(RS.blocked),
		hooks = { namecall = #RS.ncIds, functions = #RS.fnHooks },
		options = RS.opts,
	}
end

H.remote_spy_clear = function(p)
	local n = E.clear("remote")
	if p.reset_stats then
		RS.stats = setmetatable({}, { __mode = "k" })
		RS.total = 0
	end
	RS.raw, RS.rawOrder = {}, {}
	return { cleared = n }
end

H.remote_spy_get = function(p)
	local keyM = p.remote and B.matcher(p.remote, p.remote_mode, true) or nil
	local methodM = p.method and B.matcher(p.method, "exact", false) or nil
	local scriptM = p.script and B.matcher(p.script, "plain", true) or nil
	local argsM = p.args_match and B.matcher(p.args_match, "plain", true) or nil
	local pred = function(ev)
		if p.direction and ev.dir ~= p.direction then return false end
		if keyM and not keyM(ev.remote or "") then return false end
		if methodM and not methodM(ev.method or "") then return false end
		if scriptM and not scriptM(ev.script or "") then return false end
		if p.errors_only and not ev.error then return false end
		if argsM and not argsM(B.json(ev.args)) then return false end
		return true
	end
	local tailMode = p.since == nil or p.tail == true
	local evs, matched, lastSeq = E.query("remote", p.since, pred, p.limit or 50, tailMode)
	return { events = evs, returned = #evs, matched = matched, last_seq = lastSeq, active = RS.active }
end

H.remote_call_detail = function(p)
	local raw = RS.raw[p.seq]
	if not raw then error("call #" .. tostring(p.seq) .. " is no longer buffered (raw buffer holds the most recent " .. (RS.opts.raw_cap or 500) .. " calls)", 0) end
	return {
		seq = p.seq,
		remote = B.ser(raw.remote),
		method = raw.method,
		dir = raw.dir,
		args = B.serPack(raw.args, { depth = p.depth or 6, maxItems = p.max_items or 200, maxStr = p.max_str or 10000 }),
	}
end

H.remote_spy_summary = function(p)
	local rows = {}
	for r, st in pairs(RS.stats) do
		local sigs = {}
		for s, n in pairs(st.sigs) do sigs[#sigs + 1] = { signature = s, count = n } end
		table.sort(sigs, function(a, b) return a.count > b.count end)
		local top = {}
		for i = 1, math.min(#sigs, p.max_signatures or 4) do top[i] = sigs[i] end
		local span = (st.last or st.first) - st.first
		rows[#rows + 1] = {
			remote = st.path,
			ref = B.ref(r),
			class = st.class,
			calls = st.count,
			per_second = span > 0 and (st.count / span) or nil,
			blocked_calls = st.blocked,
			ignored = RS.ignored[r] or nil,
			signatures = top,
		}
	end
	table.sort(rows, function(a, b) return a.calls > b.calls end)
	local limit = p.limit or 50
	local out = {}
	for i = 1, math.min(#rows, limit) do out[i] = rows[i] end
	return { total_remotes = #rows, remotes = out, total_calls = RS.total, active = RS.active }
end

local function remotesFrom(p)
	local list = {}
	if p.remotes then
		for _, spec in ipairs(p.remotes) do list[#list + 1] = B.inst(spec) end
	elseif p.target then
		list[1] = B.inst(p.target)
	end
	return list
end

H.remote_ignore = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do RS.ignored[r] = true n = n + 1 end
	if p.name then
		RS.ignoreNames[#RS.ignoreNames + 1] = B.matcher(p.name, p.name_mode, true)
		n = n + 1
	end
	return { ignored = n }
end

H.remote_unignore = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do if RS.ignored[r] then RS.ignored[r] = nil n = n + 1 end end
	if p.all then
		RS.ignoreNames = {}
		RS.ignored = setmetatable({}, { __mode = "k" })
	end
	return { removed = n }
end

H.remote_block = function(p)
	local n = 0
	local values
	if p.return_values then values = B.deArgs(p.return_values) end
	for _, r in ipairs(remotesFrom(p)) do
		RS.blocked[r] = { mode = values and "return" or "block", values = values }
		n = n + 1
	end
	if not RS.active then
		-- blocking needs the hooks; start a quiet spy that only enforces blocks
		H.remote_spy_start({ incoming = false, max_per_remote = 0 })
	end
	return { blocked = n, spy_active = RS.active }
end

H.remote_unblock = function(p)
	local n = 0
	for _, r in ipairs(remotesFrom(p)) do if RS.blocked[r] then RS.blocked[r] = nil n = n + 1 end end
	if p.all then RS.blocked = setmetatable({}, { __mode = "k" }) end
	return { unblocked = n }
end

H.list_remotes = function(p)
	local classes = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }
	if p.bindables then classes.BindableEvent = true classes.BindableFunction = true end
	local nameM = B.matcher(p.name, p.name_mode, true)
	local root = B.inst(p.root or "game")
	local out = {}
	local function consider(d)
		if classes[d.ClassName] and nameM(d.Name) then
			local st = RS.stats[d]
			local e = {
				ref = B.ref(d),
				class = d.ClassName,
				name = d.Name,
				path = remotePath(d),
				calls = st and st.count or 0,
				blocked = RS.blocked[d] and true or nil,
				ignored = RS.ignored[d] and true or nil,
			}
			if p.with_handlers and C.getconnections and d.ClassName == "RemoteEvent" then
				local ok, conns = pcall(C.getconnections, d.OnClientEvent)
				if ok then
					local n = 0
					for _, c in ipairs(conns) do
						local okf, fn = pcall(function() return c.Function end)
						if not (okf and B.ownFns[fn]) then n = n + 1 end
					end
					e.client_handlers = n
				end
			end
			out[#out + 1] = e
		end
	end
	for i, d in ipairs(root:GetDescendants()) do
		consider(d)
		if i % 4000 == 0 then B.yield() end
	end
	if p.include_nil ~= false and C.getnilinstances then
		for _, d in ipairs(C.getnilinstances()) do consider(d) end
	end
	table.sort(out, function(a, b) return a.path < b.path end)
	local limit = p.limit or 300
	local trimmed = {}
	for i = 1, math.min(#out, limit) do trimmed[i] = out[i] end
	return { total = #out, returned = #trimmed, remotes = trimmed }
end

-- who handles this remote on the client?
H.get_remote_handlers = function(p)
	local r = B.inst(p.target)
	local out = { remote = B.ser(r), handlers = {} }
	local function addFn(fn, extra)
		local info = B.funcInfo(fn)
		local e = { ref = B.ref(fn), name = info.name, line = info.line, source = info.short_src or info.source, numparams = info.numparams, nups = info.nups }
		local ok, fe = pcall(getfenv, fn)
		if ok and type(fe) == "table" then
			local s = rawget(fe, "script")
			if typeof(s) == "Instance" then e.script = B.instPath(s) end
		end
		for k, v in pairs(extra or {}) do e[k] = v end
		out.handlers[#out.handlers + 1] = e
	end
	if r.ClassName == "RemoteEvent" or r.ClassName == "UnreliableRemoteEvent" then
		local conns = B.need("getconnections")(r.OnClientEvent)
		for i, c in ipairs(conns) do
			local ok, fn = pcall(function() return c.Function end)
			if ok and type(fn) == "function" then
				if not B.ownFns[fn] then addFn(fn, { connection = B.ref(c), index = i, enabled = c.Enabled }) end
			else out.handlers[#out.handlers + 1] = { index = i, connection = B.ref(c), note = "no Lua function (C connection)" } end
		end
	elseif r.ClassName == "RemoteFunction" then
		local fn = B.need("getcallbackvalue")(r, "OnClientInvoke")
		if type(fn) == "function" then addFn(fn, { kind = "OnClientInvoke" }) end
	elseif r.ClassName == "BindableEvent" then
		local conns = B.need("getconnections")(r.Event)
		for i, c in ipairs(conns) do
			local ok, fn = pcall(function() return c.Function end)
			if ok and type(fn) == "function" then addFn(fn, { connection = B.ref(c), index = i }) end
		end
	else
		error("not a remote/bindable: " .. r.ClassName, 0)
	end
	out.count = #out.handlers
	return out
end

local function doCall(remote, method, args, timeout)
	local fn = remote[method]
	if method == "InvokeServer" or method == "Invoke" then
		local ok, res = B.timed(function() return B.pack(fn(remote, B.unpack(args))) end, timeout or 20)
		if not ok then error("invoke failed: " .. tostring(res), 0) end
		return res
	end
	fn(remote, B.unpack(args))
	return nil
end

local METHOD_FOR = { RemoteEvent = "FireServer", UnreliableRemoteEvent = "FireServer", RemoteFunction = "InvokeServer", BindableEvent = "Fire", BindableFunction = "Invoke" }

H.fire_remote = function(p)
	local r = B.inst(p.target)
	local method = METHOD_FOR[r.ClassName]
	if not method then error(r.ClassName .. " is not a remote/bindable", 0) end
	local args = B.deArgs(p.args)
	local times = p.times or 1
	local last
	for i = 1, times do
		last = doCall(r, method, args, p.timeout)
		if p.delay and i < times then task.wait(p.delay) end
	end
	return { ok = true, method = method, times = times, results = last and B.serPack(last, p) or nil }
end
H.invoke_remote = H.fire_remote

H.remote_replay = function(p)
	local raw = RS.raw[p.seq]
	if not raw then error("call #" .. tostring(p.seq) .. " not in raw buffer", 0) end
	local args = raw.args
	if p.args then args = B.deArgs(p.args) end
	if p.modify then
		-- {index:1-based, value:...} patches on top of the captured args
		local copy = { n = args.n }
		for i = 1, args.n do copy[i] = args[i] end
		for _, m in ipairs(p.modify) do
			copy[m.index] = B.de(m.value)
			if m.index > copy.n then copy.n = m.index end
		end
		args = copy
	end
	local times = p.times or 1
	local last
	for i = 1, times do
		last = doCall(raw.remote, raw.method, args, p.timeout)
		if p.delay and i < times then task.wait(p.delay) end
	end
	return { ok = true, remote = remotePath(raw.remote), method = raw.method, times = times, results = last and B.serPack(last, p) or nil }
end

end}

PARTS[#PARTS + 1] = {"70_exec", function(B)
-- 70_exec: Lua execution (with output capture, async results), files, http, clipboard, identity
local H = B.H
local C = B.C
local Dex = B.Dex
local service = Dex.service
local NULL = B.NULL
local typeof = typeof or type
local clock = os.clock

----------------------------------------------------------------------------------------------------
-- execute
----------------------------------------------------------------------------------------------------
local execs = {}
local nextExec = 1
local MAX_KEPT = 50

local function tostr(v)
	local ok, s = pcall(tostring, v)
	return ok and s or "<unprintable>"
end

local function makeEnv(rec)
	local out = rec.output
	local function capture(level)
		return function(...)
			local n = select("#", ...)
			local parts = {}
			for i = 1, n do parts[i] = tostr((select(i, ...))) end
			out[#out + 1] = { level = level, text = table.concat(parts, "\t") }
			if #out > 2000 then table.remove(out, 1) end
		end
	end
	local env = {}
	env.print = capture("info")
	env.warn = capture("warn")
	env.ref = function(id) return B.getref(id) end
	env.R = env.ref
	env.inst = function(spec) return B.inst(spec) end
	env.ser = function(v, depth) return B.serWith(v, { depth = depth or 2 }) end
	env.dex = { bridge = B, ref = B.ref, inst = B.inst, path = B.pathOf, ser = B.ser, events = B.Events, H = B.H }
	return setmetatable(env, {
		__index = function(_, k) return B.root[k] end,
		__newindex = function(_, k, v) B.root[k] = v end,
	})
end

local function startExec(code, p, chunk)
	local compile = B.need("loadstring")
	local fn, err = compile(code, "=" .. (chunk or "dexmcp"))
	if not fn then
		return nil, err
	end
	local rec = { id = nextExec, done = false, output = {}, started = clock(), code_len = #code }
	nextExec = nextExec + 1
	execs[rec.id] = rec
	-- bound memory
	local keys = {}
	for k in pairs(execs) do keys[#keys + 1] = k end
	if #keys > MAX_KEPT then
		table.sort(keys)
		for i = 1, #keys - MAX_KEPT do execs[keys[i]] = nil end
	end
	if C.setfenv then pcall(C.setfenv, fn, makeEnv(rec)) end
	rec.thread = task.spawn(function()
		if p.identity and C.setthreadidentity then pcall(C.setthreadidentity, p.identity) end
		local res = B.pack(pcall(fn))
		rec.finished = clock()
		if res[1] then
			local r = { n = res.n - 1 }
			for i = 2, res.n do r[i - 1] = res[i] end
			rec.ok = true
			rec.results = r
		else
			rec.ok = false
			rec.error = tostring(res[2])
			if C.traceback then
				local okt, tb = pcall(C.traceback)
			end
		end
		rec.done = true
	end)
	return rec
end

local function execReport(rec, p)
	local rep = {
		id = rec.id,
		done = rec.done,
		elapsed = (rec.finished or clock()) - rec.started,
		output = rec.output,
	}
	if rec.done then
		rep.ok = rec.ok
		if rec.ok then
			rep.results = B.serPack(rec.results, p)
			rep.result_count = rec.results.n
		else
			rep.error = rec.error
		end
	else
		rep.pending = true
	end
	return rep
end

H.execute_lua = function(p)
	local rec, err = startExec(p.code, p, p.chunk_name)
	if not rec then return { ok = false, phase = "compile", error = tostring(err) } end
	local timeout = p.timeout or 15
	local t0 = clock()
	while not rec.done and clock() - t0 < timeout do task.wait() end
	local rep = execReport(rec, p)
	if rep.pending then rep.note = "still running; use get_exec_result with this id (or cancel_exec)" end
	return rep
end

H.evaluate = function(p)
	local code = "return " .. p.expression
	local compile = B.need("loadstring")
	local fn = compile(code, "=dexmcp")
	if not fn then code = p.expression end
	local rec, err = startExec(code, p, "eval")
	if not rec then return { ok = false, phase = "compile", error = tostring(err) } end
	local t0 = clock()
	while not rec.done and clock() - t0 < (p.timeout or 15) do task.wait() end
	return execReport(rec, p)
end

H.get_exec_result = function(p)
	local rec = execs[p.id]
	if not rec then error("no execution #" .. tostring(p.id), 0) end
	local t0 = clock()
	while not rec.done and p.wait and clock() - t0 < p.wait do task.wait() end
	return execReport(rec, p)
end

H.cancel_exec = function(p)
	local rec = execs[p.id]
	if not rec then error("no execution #" .. tostring(p.id), 0) end
	if rec.done then return { already_done = true } end
	pcall(task.cancel, rec.thread)
	rec.done = true
	rec.ok = false
	rec.error = "cancelled"
	return { cancelled = true }
end

H.list_execs = function(p)
	local out = {}
	for id, rec in pairs(execs) do
		out[#out + 1] = { id = id, done = rec.done, ok = rec.ok, code_len = rec.code_len, elapsed = (rec.finished or clock()) - rec.started }
	end
	table.sort(out, function(a, b) return a.id > b.id end)
	return { executions = out }
end

H.compile_check = function(p)
	local compile = B.need("loadstring")
	local fn, err = compile(p.code, "=check")
	return { ok = fn ~= nil, error = err }
end

----------------------------------------------------------------------------------------------------
-- identity
----------------------------------------------------------------------------------------------------
H.get_identity = function(p)
	local id
	if C.getthreadidentity then
		local ok, v = pcall(C.getthreadidentity)
		if ok then id = v end
	end
	return { identity = id, default_identity = B.defaultIdentity }
end

H.set_identity = function(p)
	local f = B.need("setthreadidentity")
	f(p.identity)
	B.defaultIdentity = p.identity
	return { identity = p.identity, note = "applied to this command and all later commands" }
end

----------------------------------------------------------------------------------------------------
-- filesystem (executor workspace)
----------------------------------------------------------------------------------------------------
H.read_file = function(p)
	local f = B.need("readfile")
	local data = f(p.path)
	local offset = p.offset or 0
	local maxBytes = p.max_bytes or 500000
	local chunk = data:sub(offset + 1, offset + maxBytes)
	local out = { path = p.path, size = #data, offset = offset, returned = #chunk, next_offset = (offset + #chunk < #data) and (offset + #chunk) or nil }
	if p.encoding == "base64" then out.base64 = B.b64encode(chunk) else out.content = chunk end
	return out
end

H.write_file = function(p)
	local content = p.content or ""
	if p.base64 then content = B.b64decode(p.base64) end
	if p.append then B.need("appendfile")(p.path, content) else B.need("writefile")(p.path, content) end
	return { ok = true, path = p.path, bytes = #content }
end

H.list_files = function(p)
	local f = B.need("listfiles")
	local path = p.path or ""
	local list = f(path)
	local out = {}
	for i, entry in ipairs(list) do
		if i > (p.limit or 500) then break end
		local e = { path = entry }
		if C.isfolder then
			local ok, isf = pcall(C.isfolder, entry)
			if ok then e.is_folder = isf end
		end
		out[#out + 1] = e
	end
	return { total = #list, entries = out }
end

H.file_exists = function(p)
	local out = { path = p.path }
	if C.isfile then out.is_file = C.isfile(p.path) end
	if C.isfolder then out.is_folder = C.isfolder(p.path) end
	return out
end

H.delete_file = function(p)
	B.need("delfile")(p.path)
	return { ok = true }
end

H.make_folder = function(p)
	B.need("makefolder")(p.path)
	return { ok = true }
end

H.delete_folder = function(p)
	B.need("delfolder")(p.path)
	return { ok = true }
end

----------------------------------------------------------------------------------------------------
-- network / clipboard
----------------------------------------------------------------------------------------------------
H.http_request = function(p)
	local req = B.need("request")
	local opts = { Url = p.url, Method = p.method or "GET", Headers = p.headers, Body = p.body }
	local ok, res = B.timed(function() return req(opts) end, p.timeout or 30)
	if not ok then error("request failed: " .. tostring(res), 0) end
	local body = res.Body
	local limit = p.max_body or 200000
	local truncated = false
	if type(body) == "string" and #body > limit then body = body:sub(1, limit) truncated = true end
	return {
		status = res.StatusCode,
		status_message = res.StatusMessage,
		success = res.Success,
		headers = B.obj(B.serWith(res.Headers or {}, { depth = 1, maxItems = 60 }).fields or {}),
		body = body,
		truncated = truncated,
	}
end

H.set_clipboard = function(p)
	B.need("setclipboard")(p.text)
	return { ok = true, length = #p.text }
end

end}

PARTS[#PARTS + 1] = {"80_world", function(B)
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

end}

PARTS[#PARTS + 1] = {"85_snapshots", function(B)
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

end}

PARTS[#PARTS + 1] = {"90_dex", function(B)
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

end}

PARTS[#PARTS + 1] = {"99_transport", function(B)
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

end}

local function main()
	local MCP = {}

	local Dex = {
		Main = Main, Lib = Lib, Apps = Apps, Settings = Settings,
		API = API, RMD = RMD, env = env, service = service, plr = plr,
		getSelection = function() return selection end,
		getNodes = function() return nodes end,
	}
	local B = {Dex = Dex, H = {}, cfg = Settings.MCP, partErrors = {}}
	MCP.Bridge = B

	for _, part in ipairs(PARTS) do
		local ok, err = pcall(part[2], B)
		if not ok then
			B.partErrors[#B.partErrors + 1] = part[1] .. ": " .. tostring(err)
			warn("[Dex++ MCP] part '" .. part[1] .. "' failed to load: " .. tostring(err))
		end
	end

	MCP.Init = function()
		local window = Lib.Window.new()
		window:SetTitle("MCP")
		window:Resize(290, 190)
		MCP.Window = window

		if B.startCaptures then pcall(B.startCaptures) end
		if B.buildUI then
			local ok, err = pcall(B.buildUI, window)
			if not ok then warn("[Dex++ MCP] UI failed: " .. tostring(err)) end
		end
		if B.T and Settings.MCP.AutoConnect then B.T.start() end
	end

	return MCP
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end,
--[[MCPBRIDGE:END]]
}
local oldgame = oldgame or game

cloneref = cloneref or function(ref)
	if not getreg then return ref end
	
	local InstanceList
	
	local a = Instance.new("Part")
	for _, c in pairs(getreg()) do
		if type(c) == "table" and #c then
			if rawget(c, "__mode") == "kvs" then
				for d, e in pairs(c) do
					if e == a then
						InstanceList = c
						break
					end
				end
			end
		end
	end
	local f = {}
	function f.invalidate(g)
		if not InstanceList then
			return
		end
		for b, c in pairs(InstanceList) do
			if c == g then
				InstanceList[b] = nil
				return g
			end
		end
	end
	return f.invalidate
end

local isFsSupported = readfile and writefile and isfile and isfolder and listfiles and delfile and delfolder

-- Main vars
local Main, Explorer, Properties, ScriptViewer, Console, SaveInstance, ModelViewer, SettingsWindow--[[, SecretServicePanel]], MCPBridge, DefaultSettings, Notebook, Serializer, Lib local ggv = getgenv or nil
local API, RMD

-- Default Settings
DefaultSettings = (function()
	local rgb = Color3.fromRGB	
	
	return {
		Explorer = {
			_Recurse = true,
			Sorting = true,
			TeleportToOffset = Vector3.new(0,0,0),
			ClickToRename = true,
			AutoUpdateSearch = true,
			AutoUpdateMode = 0, -- 0 Default, 1 no tree update, 2 no descendant events, 3 frozen
			PartSelectionBox = true,
			GuiSelectionBox = true,
			CopyPathUseGetChildren = true
		},
		Properties = {
			_Recurse = true,
			MaxConflictCheck = 50,
			ShowDeprecated = true,
			ShowHidden = false,
			ClearOnFocus = false,
			LoadstringInput = true,
			NumberRounding = 3,
			ShowAttributes = true,
			MaxAttributes = 50,
			ScaleType = 0 -- 0 Full Name Shown, 1 Equal Halves
		},
		Theme = {
			_Recurse = true,
			Main1 = rgb(52,52,52),
			Main2 = rgb(45,45,45),
			Outline1 = rgb(33,33,33), -- Mainly frames
			Outline2 = rgb(55,55,55), -- Mainly button
			Outline3 = rgb(30,30,30), -- Mainly textbox
			TextBox = rgb(38,38,38),
			Menu = rgb(32,32,32),
			ListSelection = rgb(11,90,175),
			Button = rgb(60,60,60),
			ButtonHover = rgb(68,68,68),
			ButtonPress = rgb(40,40,40),
			Highlight = rgb(75,75,75),
			Text = rgb(255,255,255),
			PlaceholderText = rgb(100,100,100),
			Important = rgb(255,0,0),
			ExplorerIconMap = "",
			MiscIconMap = "",
			Syntax = {
				Text = rgb(204,204,204),
				Background = rgb(36,36,36),
				Selection = rgb(255,255,255),
				SelectionBack = rgb(11,90,175),
				Operator = rgb(204,204,204),
				Number = rgb(255,198,0),
				String = rgb(173,241,149),
				Comment = rgb(102,102,102),
				Keyword = rgb(248,109,124),
				Error = rgb(255,0,0),
				FindBackground = rgb(141,118,0),
				MatchingWord = rgb(85,85,85),
				BuiltIn = rgb(132,214,247),
				CurrentLine = rgb(45,50,65),
				LocalMethod = rgb(253,251,172),
				LocalProperty = rgb(97,161,241),
				Nil = rgb(255,198,0),
				Bool = rgb(255,198,0),
				Function = rgb(248,109,124),
				Local = rgb(248,109,124),
				Self = rgb(248,109,124),
				FunctionName = rgb(253,251,172),
				Bracket = rgb(204,204,204)
			},
		},
		ScriptViewer = {
			ShowMoreInfo = true;
		},
		Window = {
			TitleOnMiddle = false,
			Transparency = .2
		},
		Decompiler = {
			DecompilerFallback = "Konstant", --Konstant, Shiny, AdvancedDecompiler
			PreferDecompilerFallback = false,
			ShinyDecompilerPort = 3000,
		},
		
		MCP = {
			_Recurse = true,
			Host = "127.0.0.1",
			Port = 18764,
			AutoConnect = true,
			Token = "", -- must match DEXMCP_TOKEN on the server when one is set
			PortScan = true, -- when Port refuses, also try Port+1..Port+9 (the server falls back to those when busy)
			Transport = "auto", -- auto | websocket | http
			Reconnect = true,
			MaxRefs = 50000,
			DebugTrace = false,
		},

		RemoteBlockWriteAttribute = false, -- writes attribute to remote instance if remote is blocked/unblocked
		ClassIcon = "NewDark",
		
		-- What available icons:
		-- > Vanilla3
		-- > Old
		-- > NewDark
	}
end)()

-- Vars
local Settings = DefaultSettings or {}
local Apps = {}
local env = {}

local service = setmetatable({},{__index = function(self,name)
	local serv = cloneref(game:GetService(name))
	self[name] = serv
	return serv
end})
local plr = service.Players.LocalPlayer or service.Players.PlayerAdded:wait()

local create = function(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

local createSimple = function(class,props)
	local inst = Instance.new(class)
	for i,v in next,props do
		inst[i] = v
	end
	return inst
end

Main = (function()
	local Main = {}

	Main.ModuleList = {"Explorer","Properties","ScriptViewer","Console","SaveInstance","ModelViewer","SettingsWindow","MCPBridge"}
	Main.Elevated = false
	Main.AllowDraggableOnMobile = true
	Main.MissingEnv = {}
	Main.Version = "3.0"
	Main.Mouse = plr:GetMouse()
	Main.AppControls = {}
	Main.Apps = Apps
	Main.MenuApps = {}
	Main.GitName = "AZYsGithub"
	Main.RepoName = "DexPlusPlus"
	Main.GitRepoName = Main.GitName.."/"..Main.RepoName

	Main.DisplayOrders = {
		SideWindow = 8,
		Window = 10,
		Menu = 100000,
		Core = 101000
	}
	
	Main.Plugins = {}
	
	--[[Main.LoadAdonisBypass = function()
		-- skidded off reddit :pensive:
		local getinfo = getinfo or debug.getinfo
		local DEBUG = false
		local Hooked = {}

		local Detected, Kill

		setthreadidentity(2)

		for i, v in getgc(true) do
			if typeof(v) == "table" then
				local DetectFunc = rawget(v, "Detected")
				local KillFunc = rawget(v, "Kill")

				if typeof(DetectFunc) == "function" and not Detected then
					Detected = DetectFunc

					local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
						if Action ~= "_" then
							if DEBUG then
								warn(`Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}`)
							end
						end

						return true
					end)

					table.insert(Hooked, Detected)
				end

				if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
					Kill = KillFunc
					local Old; Old = hookfunction(Kill, function(Info)
						if DEBUG then
							warn(`Adonis AntiCheat tried to kill (fallback): {Info}`)
						end
					end)

					table.insert(Hooked, Kill)
				end
			end
		end

		local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
			local LevelOrFunc, Info = ...

			if Detected and LevelOrFunc == Detected then
				if DEBUG then
					warn(`Adonis AntiCheat sanity check detected and broken`)
				end

				return coroutine.yield(coroutine.running())
			end

			return Old(...)
		end))
		-- setthreadidentity(9)
		setthreadidentity(7)
	end
	
	Main.LoadGCBypass = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/secretisadev/Babyhamsta_Backup/refs/heads/main/Universal/Bypasses.lua", true))()
	end]]
	
	Main.GetRandomString = function()
		local output = ""
		for i = 2, 25 do
			output = output .. string.char(math.random(1,250))
		end
		
		return output
	end
	
	Main.GetSecureContainer = function()
		return
			syn and syn.protect_gui or
			gethui and gethui() or
			service.CoreGui or
			service.Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	Main.SecureGui = function(gui)
		--warn("Secured: "..gui.Name)
		gui.Name = "_DPP_".. Main.GetRandomString()
		-- service already using cloneref
		if gethui then
			gui.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(gui)
			gui.Parent = service.CoreGui
		elseif protect_gui then
			protect_gui(gui)
			gui.Parent = service.CoreGui
		elseif protectgui then
			protectgui(gui)
			gui.Parent = service.CoreGui
		else
			if Main.Elevated then
				gui.Parent = service.CoreGui
			else
				gui.Parent = service.Players.LocalPlayer:WaitForChild("PlayerGui")
			end
		end
	end

	Main.GetInitDeps = function()
		return {
			Main = Main,
			Lib = Lib,
			Apps = Apps,
			Settings = Settings,

			API = API,
			RMD = RMD,
			env = env,
			service = service,
			plr = plr,
			create = create,
			createSimple = createSimple
		}
	end

	Main.Error = function(str)
		if rconsoleprint then
			rconsoleprint("DEX ERROR: "..tostring(str).."\n")
			wait(9e9)
		else
			error(str)
		end
	end

	Main.LoadModule = function(name)
		if Main.Elevated then -- If you don't have filesystem api then ur outta luck tbh
			local control

			if EmbeddedModules then -- Offline Modules
				control = EmbeddedModules[name]()

				-- TODO: Remove when open source
				if gethsfuncs then
					control = _G.moduleData
				end

				if not control then Main.Error("Missing Embedded Module: "..name) end
			else
				-- Get hash data
				local hashs = Main.ModuleHashData
				if not hashs then
					local s,hashDataStr = pcall(oldgame.HttpGet, game, "https://api.github.com/repos/"..Main.GitRepoName.."/ModuleHashs.dat")
					if not s then Main.Error("Failed to get module hashs") end

					local s,hashData = pcall(service.HttpService.JSONDecode,service.HttpService,hashDataStr)
					if not s then Main.Error("Failed to decode module hash JSON") end

					hashs = hashData
					Main.ModuleHashData = hashs
				end

				-- Check if local copy exists with matching hashs
				local hashfunc = (syn and syn.crypt.hash) or function() return "" end
				local filePath = "dex/ModuleCache/"..name..".lua"
				local s,moduleStr = pcall(env.readfile,filePath)

				if s and hashfunc(moduleStr) == hashs[name] then
					control = loadstring(moduleStr)()
				else
					-- Download and cache
					local s,moduleStr = pcall(oldgame.HttpGet, game, "https://api.github.com/repos/"..Main.GitRepoName.."/Modules/"..name..".lua")
					if not s then Main.Error("Failed to get external module data of "..name) end

					env.writefile(filePath,moduleStr)
					control = loadstring(moduleStr)()
				end
			end

			Main.AppControls[name] = control
			control.InitDeps(Main.GetInitDeps())

			local moduleData = control.Main()
			Apps[name] = moduleData
			return moduleData
		else
			local module = script:WaitForChild("Modules"):WaitForChild(name,2)
			if not module then Main.Error("CANNOT FIND MODULE "..name) end

			local control = require(module)
			Main.AppControls[name] = control
			control.InitDeps(Main.GetInitDeps())

			local moduleData = control.Main()
			Apps[name] = moduleData
			return moduleData
		end
	end
	
	Main.LoadPluginFile = function(pluginDir)
		if env.readfile then
			if isfile(pluginDir) then
				local preloadedPlugin = loadfile and loadfile(pluginDir) or loadstring(env.readfile(pluginDir))
				local loadedPlugin = preloadedPlugin()
				
				local control = loadedPlugin
				control.InitDeps(Main.GetInitDeps())

				local moduleData = control.Main()
				Apps[pluginDir] = moduleData
				Main.AppControls[pluginDir] = control
				
				moduleData.PluginData = control.PluginData
				
				return moduleData
			else
				Main.Error("CANNOT FIND FILE MODULE "..pluginDir)
			end
		end
	end

	Main.LoadModules = function()
		for i,v in pairs(Main.ModuleList) do
			local s,e = pcall(Main.LoadModule,v)
			if not s then
				if v == "MCPBridge" then
					-- the MCP bridge is optional: never let it take Dex++ down
					warn("[Dex++ MCP] failed to load: " .. tostring(e))
				else
					Main.Error("FAILED LOADING " .. v .. " CAUSE " .. e)
				end
			end
		end

		-- Init Major Apps and define them in modules
		Explorer = Apps.Explorer
		Properties = Apps.Properties
		ScriptViewer = Apps.ScriptViewer
		Console = Apps.Console
		SaveInstance = Apps.SaveInstance
		ModelViewer = Apps.ModelViewer
		Notebook = Apps.Notebook
		SettingsWindow = Apps.SettingsWindow
		MCPBridge = Apps.MCPBridge

		
		--SecretServicePanel = Apps.SecretServicePanel
		local appTable = {
			Explorer = Explorer,
			Properties = Properties,
			ScriptViewer = ScriptViewer,
			Console = Console,
			SaveInstance = SaveInstance,
			ModelViewer = ModelViewer,
			Notebook = Notebook,
			SettingsWindow = SettingsWindow
			--SecretServicePanel = SecretServicePanel,
		}
		
		

		Main.AppControls.Lib.InitAfterMain(appTable)
		for i,v in pairs(Main.ModuleList) do
			local control = Main.AppControls[v]
			if control then
				control.InitAfterMain(appTable)
			end
		end
	end

	Main.InitEnv = function()
		setmetatable(env,{__newindex = function(self,name,func)
			if not func then Main.MissingEnv[#Main.MissingEnv+1] = name return end
			rawset(self,name,func)
		end})

		env.isonmobile = game:GetService("UserInputService").TouchEnabled
		
		env.loadstring = (pcall(loadstring,"local a = 1") and loadstring) or (game:GetService("RunService"):IsStudio() and script.Modules:FindFirstChild("Loadstring") and require(script.Modules:FindFirstChild("Loadstring")))

		-- file
		env.isfile = isfile
		env.isfolder = isfolder
		env.readfile = readfile
		env.writefile = writefile
		env.appendfile = appendfile
		env.makefolder = makefolder
		env.listfiles = listfiles
		env.loadfile = loadfile
		env.saveinstance = saveinstance or (function()
			--warn("No built-in saveinstance exists, using SynSaveInstance and wrapper...")
			if game:GetService("RunService"):IsStudio() then return function() error("Cannot run in Roblox Studio!") end end
			local Params = {
				RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
				SSI = "saveinstance",
			}
			local synsaveinstance = loadstring(oldgame:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
		
			local function wrappedsaveinstance(obj, filepath, options)
				options["FilePath"] = filepath
				--options["ReadMe"] = false
				options["Object"] = obj
				return synsaveinstance(options)
			end
			
			getgenv().saveinstance = wrappedsaveinstance
			return wrappedsaveinstance
		end)()
		
		env.parsefile = function(name)
			return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
		end

		-- debug
		env.getupvalues = debug.getupvalues or getupvalues or getupvals
		env.getconstants = debug.getconstants or getconstants or getconsts
		env.islclosure = islclosure or is_l_closure
		env.checkcaller = checkcaller
		env.getreg = getreg
		env.getgc = getgc
		
		-- hooks
		env.hookfunction = hookfunction
		env.hookmetamethod = hookmetamethod

		-- other
		env.getscriptbytecode = getscriptbytecode
		env.setfflag = setfflag
		env.protectgui = protect_gui or (syn and syn.protect_gui)
		env.gethui = gethui
		env.setclipboard = setclipboard
		env.getnilinstances = getnilinstances or get_nil_instances
		env.getloadedmodules = getloadedmodules
		
		env.isViableDecompileScript = function(obj)
			if obj:IsA("ModuleScript") then
				return true
			elseif obj:IsA("LocalScript") and (obj.RunContext == Enum.RunContext.Client or obj.RunContext == Enum.RunContext.Legacy) then
				return true
			elseif obj:IsA("Script") and obj.RunContext == Enum.RunContext.Client then
				return true
			end
			return false
		end
		env.request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
		
		env.isdecompile = function()
			return typeof(decompile) == "function" or typeof(getscriptbytecode) == "function" or false
		end
		
		env.isdecompilefallback = function()
			return typeof(decompile) ~= "function" or typeof(getscriptbytecode) == "function" or false
		end
		
		
		-- DECOMPILERS
		
		local AdvancedDecompilerCache
		pcall(function()
			AdvancedDecompilerCache = loadstring(game:HttpGet("https://raw.githubusercontent.com/"..Main.GitName.."/Advanced-Decompiler-V3/refs/heads/main/init.lua"))()
		end)
		
		local konstant_last_call = 0
		
		local function KonstantDec(...)
			-- by lovrewe
			--warn("No built-in decompiler exists, using Konstant decompiler...")
			--assert(getscriptbytecode, "Exploit not supported.")
			local API = "http://api.plusgiant5.com"

			local request = env.request

			local function call(konstantType, scriptPath)
				local success, bytecode = pcall(env.getscriptbytecode, scriptPath)

				if (not success) then
					return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
				end

				local time_elapsed = os.clock() - konstant_last_call
				if time_elapsed <= .5 then
					task.wait(.5 - time_elapsed)
				end

				local httpResult = env.request({
					Url = API .. konstantType,
					Body = bytecode,
					Method = "POST",
					Headers = {
						["Content-Type"] = "text/plain"
					}
				})

				konstant_last_call = os.clock()

				if (httpResult.StatusCode ~= 200) then
					return `-- Error occurred while requesting Konstant API, error:\n\n--[[\n{httpResult.Body}\n--]]`
				else
					return httpResult.Body
				end
			end

			local function konstantDecompile(scriptPath)
				return call("/konstant/decompile", scriptPath)
			end

			return konstantDecompile(...)
		end
		local ADDec = AdvancedDecompilerCache or function() return "Failed to load Advanced Decompiler" end

		local function ShinyDec(script_instance)
			if typeof(crypt) ~= "table" then return "-- 'crypt' library is missing!" end
			local success, result = pcall(function()
				return game:HttpGet("http://127.0.0.1:"..tostring(Settings.Decompiler.ShinyDecompilerPort))
			end)
			if not success then return "-- Shiny decompiler is not active or port is wrong!" end

			local bytecode = getscriptbytecode(script_instance)
			local encoded = crypt.base64encode(bytecode)
			return env.request(
				{
					Url = "http://127.0.0.1:"..tostring(Settings.Decompiler.ShinyDecompilerPort).."/luau/decompile",
					Method = "POST",
					Body = encoded
				}
			).Body
		end
		env.decompile = function(...)
			if typeof(decompile) == "function" and Settings.Decompiler.PreferDecompilerFallback == false then
				return decompile(...)
			elseif typeof(getscriptbytecode) == "function" then
				local fallbackMode = Settings.Decompiler.DecompilerFallback
				
				if fallbackMode == "Konstant" then
					return KonstantDec(...)
				elseif fallbackMode == "AdvancedDecompiler" then
					return ADDec(...)
				elseif  fallbackMode == "Shiny" then
					return ShinyDec(...)
				end
			end
		end
		
		--[[if Main.Elevated then
			getgenv().decompile = env.decompile
		end]]
		

		if identifyexecutor then
			Main.Executor = identifyexecutor()
		end

		Main.GuiHolder = Main.Elevated and service.CoreGui or plr:FindFirstChildOfClass("PlayerGui")

		setmetatable(env,nil)
	end

	Main.IncompatibleTest = function()
		--[[local function incompatibleMessage(reason, tolerated)
			local msg = Instance.new("ScreenGui")
			msg.IgnoreGuiInset = true
			local t = Instance.new("TextLabel",msg)
			t.BackgroundColor3 = Color3.fromRGB(50,50,50)
			t.Position = UDim2.new(0,0,0,0)
			t.Size = UDim2.new(1,0,1,0)
			t.TextColor3 = Color3.new(1,1,1)
			t.TextWrapped = true
			t.TextScaled = true
			t.Text = "\n\n\n\n\n\n\n\nHello Skidsploit user,\nZinnia, Chillz and the Secret Service does not approve of Dex being used on your skidsploit.\nPlease consider getting something better.\n\nIncompatible Reason: "..reason.."\n\n\n\n\n\n\n\n"
			
			-- This sound wont work!!!
			local sound = Instance.new("Sound",msg)
			sound.SoundId = "rbxassetid://175964948"
			sound.Volume = 1
			sound.Looped = true
			sound.Playing = true
			
			if not tolerated then
				Lib.ShowGui(msg)
				
				if os and os.execute then pcall(os.execute,'explorer "https://weao.xyz"') end
				if pcall(game.GetService, game,"MessageBusService") and game:GetService("MessageBusService").Publish then pcall(game:GetService("MessageBusService").Publish, game:GetService("MessageBusService"), game:GetService("MessageBusService"):GetMessageId("Linking", "openURLRequest"), {url = 'explorer "https://weao.xyz"'}) end
			else
				warn(msg)
			end			
		end
		
																																													local yummy, evilList = "\105\100\101\110\116\105\102\121\101\120\101\99\117\116\111\114", { "\120\101\110\111", "\115\111\108\97\114\97", "\119\97\118\101" }
																																													if ggv and ggv()[yummy] then local wow = ggv()[yummy] if table.find(evilList, string.lower(wow)) then incompatibleMessage("\83\72\73\84\84\89\32\69\88\69\67\85\84\79\82") end end
																																													
		local t = {}
		t[1] = t
		local x = unpack(t) or incompatibleMessage("WRAPPER FAILED TO CYCLIC #1")
		if x[1] ~= t then incompatibleMessage("WRAPPER FAILED TO CYCLIC #2") end
		
		if game ~= workspace.Parent then
			incompatibleMessage("WRAPPER NO CACHE (game ≠ workspace.Parent)", true)
			game = workspace.Parent
		end
		
		if Main.Elevated and not loadstring("for i = 1,1 do continue end") then incompatibleMessage("CAN'T CONTINUE OR NO LOADSTRING")end
		
		local obj = newproxy(true)
		local mt = getmetatable(obj)
		mt.__index = function() incompatibleMessage("CAN'T NAMECALL (__index triggered instead of __namecall)") end
		mt.__namecall = function() end
		obj:No()
		
		local fEnv = setmetatable({zin = 5},{__index = getfenv()})
		local caller = function(f) f() end
		setfenv(caller,fEnv)
		caller(function() if not getfenv(2).zin then incompatibleMessage("RERU WILL BE FILING A LAWSUIT AGAINST YOU SOON") end end)
		
		local second = false
		coroutine.wrap(function() local start = tick() wait(5) if tick() - start < 0.1 or not second then incompatibleMessage("SKIDDED YIELDING") end end)()
		second = true]]
	end
	
	local function serialize(val)
		if typeof(val) == "Color3" then
			local serializedColor = {}
			serializedColor.R = val.R
			serializedColor.G = val.G
			serializedColor.B = val.B
			return serializedColor
		else
			return val
		end
	end
	
	local function deserialize(val)
		if typeof(val) == "table" then
			if val.R and val.G and val.B then
				return Color3.new(val.R, val.G, val.B)
			else
				return val
			end
		else
			return val
		end
	end
	
	Main.ExportSettings = function()
		local rawData = Settings or DefaultSettings

		local function recur(tbl)
			local newTbl = {}
			for i, v in pairs(tbl) do
				if typeof(v) == "table" then
					newTbl[i] = recur(v)
				else
					newTbl[i] = serialize(v)
				end
			end
			return newTbl
		end

		-- serialize color3 sebelum encode
		local serializedData = recur(rawData)

		local s, json = pcall(service.HttpService.JSONEncode, service.HttpService, serializedData)
		if s and json then
			return json
		end
	end


	--warn(Main.ExportSettings())

	Main.LoadSettings = function()
		local s, data = pcall(env.readfile or error, "DexPlusPlusSettings.json")
		if s and data and data ~= "" then
			
			local s, decoded = pcall(service.HttpService.JSONDecode, service.HttpService, data)
			if s and decoded then

				local function recur(tbl)
					local newTbl = {}
					for i, v in pairs(tbl) do
						if typeof(v) == "table" then
							newTbl[i] = deserialize(recur(v))
						else
							newTbl[i] = deserialize(v)
						end
					end
					return newTbl
				end

				local deserializedData = recur(decoded)
				for k, v in pairs(deserializedData) do
					Settings[k] = v
				end
			else
				warn("failed to decode settings json")
			end
		else
			Main.ResetSettings()
		end
	end

	
	

	Main.ResetSettings = function()
		local function recur(t,res)
			for set,val in pairs(t) do
				if type(val) == "table" and val._Recurse then
					if type(res[set]) ~= "table" then
						res[set] = {}
					end
					recur(val,res[set])
				else
					res[set] = val
				end
			end
			return res
		end
		recur(DefaultSettings,Settings)
	end

	Main.FetchAPI = function(callbackiflong, callbackiftoolong, XD)
		local downloaded = false
		local api,rawAPI
		if Main.Elevated then
			if Main.LocalDepsUpToDate() then
				local localAPI = Lib.ReadFile("dex/rbx_api.dat")
				if localAPI then 
					rawAPI = localAPI
				else
					Main.DepsVersionData[1] = ""
				end
			end
			task.spawn(function()
				task.wait(10)
				if not downloaded and callbackiflong then callbackiflong() end

				task.wait(20) -- 30
				if not downloaded and callbackiftoolong then callbackiftoolong() end

				task.wait(30) -- 60
				if not downloaded and XD then XD() end
			end)
			-- lmfao async makes it work to load big file
			rawAPI = rawAPI or game:HttpGet("http://setup.roblox.com/"..Main.RobloxVersion.."-API-Dump.json")
		else
			if script:FindFirstChild("API") then
				rawAPI = require(script.API)
			else
				error("NO API EXISTS")
			end
		end
		downloaded = true
		
		Main.RawAPI = rawAPI
		api = service.HttpService:JSONDecode(rawAPI)

		local classes,enums = {},{}
		local categoryOrder,seenCategories = {},{}

		local function insertAbove(t,item,aboveItem)
			local findPos = table.find(t,item)
			if not findPos then return end
			table.remove(t,findPos)

			local pos = table.find(t,aboveItem)
			if not pos then return end
			table.insert(t,pos,item)
		end

		for _,class in pairs(api.Classes) do
			local newClass = {}
			newClass.Name = class.Name
			newClass.Superclass = class.Superclass
			newClass.Properties = {}
			newClass.Functions = {}
			newClass.Events = {}
			newClass.Callbacks = {}
			newClass.Tags = {}

			if class.Tags then for c,tag in pairs(class.Tags) do newClass.Tags[tag] = true end end
			for __,member in pairs(class.Members) do
				local newMember = {}
				newMember.Name = member.Name
				newMember.Class = class.Name
				newMember.Security = member.Security
				newMember.Tags ={}
				if member.Tags then for c,tag in pairs(member.Tags) do newMember.Tags[tag] = true end end

				local mType = member.MemberType
				if mType == "Property" then
					local propCategory = member.Category or "Other"
					propCategory = propCategory:match("^%s*(.-)%s*$")
					if not seenCategories[propCategory] then
						categoryOrder[#categoryOrder+1] = propCategory
						seenCategories[propCategory] = true
					end
					newMember.ValueType = member.ValueType
					newMember.Category = propCategory
					newMember.Serialization = member.Serialization
					table.insert(newClass.Properties,newMember)
				elseif mType == "Function" then
					newMember.Parameters = {}
					newMember.ReturnType = member.ReturnType.Name
					for c,param in pairs(member.Parameters) do
						table.insert(newMember.Parameters,{Name = param.Name, Type = param.Type.Name})
					end
					table.insert(newClass.Functions,newMember)
				elseif mType == "Event" then
					newMember.Parameters = {}
					for c,param in pairs(member.Parameters) do
						table.insert(newMember.Parameters,{Name = param.Name, Type = param.Type.Name})
					end
					table.insert(newClass.Events,newMember)
				end
			end

			classes[class.Name] = newClass
		end

		for _,class in pairs(classes) do
			class.Superclass = classes[class.Superclass]
		end

		for _,enum in pairs(api.Enums) do
			local newEnum = {}
			newEnum.Name = enum.Name
			newEnum.Items = {}
			newEnum.Tags = {}

			if enum.Tags then for c,tag in pairs(enum.Tags) do newEnum.Tags[tag] = true end end
			for __,item in pairs(enum.Items) do
				local newItem = {}
				newItem.Name = item.Name
				newItem.Value = item.Value
				table.insert(newEnum.Items,newItem)
			end

			enums[enum.Name] = newEnum
		end

		local function getMember(class,member)
			if not classes[class] or not classes[class][member] then return end
			local result = {}

			local currentClass = classes[class]
			while currentClass do
				for _,entry in pairs(currentClass[member]) do
					result[#result+1] = entry
				end
				currentClass = currentClass.Superclass
			end

			table.sort(result,function(a,b) return a.Name < b.Name end)
			return result
		end

		insertAbove(categoryOrder,"Behavior","Tuning")
		insertAbove(categoryOrder,"Appearance","Data")
		insertAbove(categoryOrder,"Attachments","Axes")
		insertAbove(categoryOrder,"Cylinder","Slider")
		insertAbove(categoryOrder,"Localization","Jump Settings")
		insertAbove(categoryOrder,"Surface","Motion")
		insertAbove(categoryOrder,"Surface Inputs","Surface")
		insertAbove(categoryOrder,"Part","Surface Inputs")
		insertAbove(categoryOrder,"Assembly","Surface Inputs")
		insertAbove(categoryOrder,"Character","Controls")
		categoryOrder[#categoryOrder+1] = "Unscriptable"
		categoryOrder[#categoryOrder+1] = "Attributes"

		local categoryOrderMap = {}
		for i = 1,#categoryOrder do
			categoryOrderMap[categoryOrder[i]] = i
		end

		return {
			Classes = classes,
			Enums = enums,
			CategoryOrder = categoryOrderMap,
			GetMember = getMember
		}
	end

	Main.FetchRMD = function()
		local rawXML
		if Main.Elevated then
			if Main.LocalDepsUpToDate() then
				local localRMD = Lib.ReadFile("dex/rbx_rmd.dat")
				if localRMD then 
					rawXML = localRMD
				else
					Main.DepsVersionData[1] = ""
				end
			end
			rawXML = rawXML or game:HttpGet("https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml")
		else
			if script:FindFirstChild("RMD") then
				rawXML = require(script.RMD)
			else
				error("NO RMD EXISTS")
			end
		end
		Main.RawRMD = rawXML
		local parsed = Lib.ParseXML(rawXML)
		local classList = parsed.children[1].children[1].children
		local enumList = parsed.children[1].children[2].children
		local propertyOrders = {}

		local classes,enums = {},{}
		for _,class in pairs(classList) do
			local className = ""
			for _,child in pairs(class.children) do
				if child.tag == "Properties" then
					local data = {Properties = {}, Functions = {}}
					local props = child.children
					for _,prop in pairs(props) do
						local name = prop.attrs.name
						name = name:sub(1,1):upper()..name:sub(2)
						data[name] = prop.children[1].text
					end
					className = data.Name
					classes[className] = data
				elseif child.attrs.class == "ReflectionMetadataProperties" then
					local members = child.children
					for _,member in pairs(members) do
						if member.attrs.class == "ReflectionMetadataMember" then
							local data = {}
							if member.children[1].tag == "Properties" then
								local props = member.children[1].children
								for _,prop in pairs(props) do
									if prop.attrs then
										local name = prop.attrs.name
										name = name:sub(1,1):upper()..name:sub(2)
										data[name] = prop.children[1].text
									end
								end
								if data.PropertyOrder then
									local orders = propertyOrders[className]
									if not orders then orders = {} propertyOrders[className] = orders end
									orders[data.Name] = tonumber(data.PropertyOrder)
								end
								classes[className].Properties[data.Name] = data
							end
						end
					end
				elseif child.attrs.class == "ReflectionMetadataFunctions" then
					local members = child.children
					for _,member in pairs(members) do
						if member.attrs.class == "ReflectionMetadataMember" then
							local data = {}
							if member.children[1].tag == "Properties" then
								local props = member.children[1].children
								for _,prop in pairs(props) do
									if prop.attrs then
										local name = prop.attrs.name
										name = name:sub(1,1):upper()..name:sub(2)
										data[name] = prop.children[1].text
									end
								end
								classes[className].Functions[data.Name] = data
							end
						end
					end
				end
			end
		end

		for _,enum in pairs(enumList) do
			local enumName = ""
			for _,child in pairs(enum.children) do
				if child.tag == "Properties" then
					local data = {Items = {}}
					local props = child.children
					for _,prop in pairs(props) do
						local name = prop.attrs.name
						name = name:sub(1,1):upper()..name:sub(2)
						data[name] = prop.children[1].text
					end
					enumName = data.Name
					enums[enumName] = data
				elseif child.attrs.class == "ReflectionMetadataEnumItem" then
					local data = {}
					if child.children[1].tag == "Properties" then
						local props = child.children[1].children
						for _,prop in pairs(props) do
							local name = prop.attrs.name
							name = name:sub(1,1):upper()..name:sub(2)
							data[name] = prop.children[1].text
						end
						enums[enumName].Items[data.Name] = data
					end
				end
			end
		end

		return {Classes = classes, Enums = enums, PropertyOrders = propertyOrders}
	end

	Main.ShowGui = Main.SecureGui

	Main.CreateIntro = function(initStatus) -- TODO: Must theme and show errors
		local gui = create({
			{1,"ScreenGui",{Name="Intro",}},
			{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.5,-175,0.5,-100),Size=UDim2.new(0,350,0,200),}},
			{3,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Holder",Parent={2},Size=UDim2.new(1,0,1,0),}},
			{4,"UIGradient",{Parent={3},Rotation=30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{5,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Title",Parent={3},Position=UDim2.new(0,-190,0,15),Size=UDim2.new(0,100,0,50),Text="Dex++",TextColor3=Color3.new(1,1,1),TextSize=50,TextTransparency=1,}},
			{6,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Desc",Parent={3},Position=UDim2.new(0,-230,0,60),Size=UDim2.new(0,180,0,25),Text="Ultimate Debugging Suite",TextColor3=Color3.new(1,1,1),TextSize=18,TextTransparency=1,}},
			{7,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="StatusText",Parent={3},Position=UDim2.new(0,20,0,110),Size=UDim2.new(0,180,0,25),Text="Fetching API",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=1,}},
			{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ProgressBar",Parent={3},Position=UDim2.new(0,110,0,145),Size=UDim2.new(0,0,0,4),}},
			{9,"Frame",{BackgroundColor3=Color3.new(0.2392156869173,0.56078433990479,0.86274510622025),BorderSizePixel=0,Name="Bar",Parent={8},Size=UDim2.new(0,0,1,0),}},
			{10,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://2764171053",ImageColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),Parent={8},ScaleType=1,Size=UDim2.new(1,0,1,0),SliceCenter=Rect.new(2,2,254,254),}},
			{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Creator",Parent={2},Position=UDim2.new(1,-110,1,-20),Size=UDim2.new(0,105,0,20),Text="Developed by Chillz.",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=1,}},
			{12,"UIGradient",{Parent={11},Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{13,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Version",Parent={2},Position=UDim2.new(1,-110,1,-35),Size=UDim2.new(0,105,0,20),Text=Main.Version,TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=1,}},
			{14,"UIGradient",{Parent={13},Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{15,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1427967925",Name="Outlines",Parent={2},Position=UDim2.new(0,-5,0,-5),ScaleType=1,Size=UDim2.new(1,10,1,10),SliceCenter=Rect.new(6,6,25,25),TileSize=UDim2.new(0,20,0,20),}},
			{16,"UIGradient",{Parent={15},Rotation=-30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{17,"UIGradient",{Parent={2},Rotation=-30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{18,"UIDragDetector", {Parent={2}}}
		})
		Main.ShowGui(gui)
		local backGradient = gui.Main.UIGradient
		local outlinesGradient = gui.Main.Outlines.UIGradient
		local holderGradient = gui.Main.Holder.UIGradient
		local titleText = gui.Main.Holder.Title
		local descText = gui.Main.Holder.Desc
		local versionText = gui.Main.Version
		local versionGradient = versionText.UIGradient
		local creatorText = gui.Main.Creator
		local creatorGradient = creatorText.UIGradient
		local statusText = gui.Main.Holder.StatusText
		local progressBar = gui.Main.Holder.ProgressBar
		local tweenS = service.TweenService

		local renderStepped = service.RunService.RenderStepped
		local signalWait = renderStepped.wait
		local fastwait = function(s)
			if not s then return signalWait(renderStepped) end
			local start = tick()
			while tick() - start < s do signalWait(renderStepped) end
		end

		statusText.Text = initStatus

		local function tweenNumber(n,ti,func)
			local tweenVal = Instance.new("IntValue")
			tweenVal.Value = 0
			tweenVal.Changed:Connect(func)
			local tween = tweenS:Create(tweenVal,ti,{Value = n})
			tween:Play()
			tween.Completed:Connect(function()
				tweenVal:Destroy()
			end)
		end

		local ti = TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		tweenNumber(100,ti,function(val)
			val = val/200
			local start = NumberSequenceKeypoint.new(0,0)
			local a1 = NumberSequenceKeypoint.new(val,0)
			local a2 = NumberSequenceKeypoint.new(math.min(0.5,val+math.min(0.05,val)),1)
			if a1.Time == a2.Time then a2 = a1 end
			local b1 = NumberSequenceKeypoint.new(1-val,0)
			local b2 = NumberSequenceKeypoint.new(math.max(0.5,1-val-math.min(0.05,val)),1)
			if b1.Time == b2.Time then b2 = b1 end
			local goal = NumberSequenceKeypoint.new(1,0)
			backGradient.Transparency = NumberSequence.new({start,a1,a2,b2,b1,goal})
			outlinesGradient.Transparency = NumberSequence.new({start,a1,a2,b2,b1,goal})
		end)

		fastwait(0.4)

		tweenNumber(100,ti,function(val)
			val = val/166.66
			local start = NumberSequenceKeypoint.new(0,0)
			local a1 = NumberSequenceKeypoint.new(val,0)
			local a2 = NumberSequenceKeypoint.new(val+0.01,1)
			local goal = NumberSequenceKeypoint.new(1,1)
			holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
		end)

		tweenS:Create(titleText,ti,{Position = UDim2.new(0,60,0,15), TextTransparency = 0}):Play()
		tweenS:Create(descText,ti,{Position = UDim2.new(0,20,0,60), TextTransparency = 0}):Play()

		local function rightTextTransparency(obj)
			tweenNumber(100,ti,function(val)
				val = val/100
				local a1 = NumberSequenceKeypoint.new(1-val,0)
				local a2 = NumberSequenceKeypoint.new(math.max(0,1-val-0.01),1)
				if a1.Time == a2.Time then a2 = a1 end
				local start = NumberSequenceKeypoint.new(0,a1 == a2 and 0 or 1)
				local goal = NumberSequenceKeypoint.new(1,0)
				obj.Transparency = NumberSequence.new({start,a2,a1,goal})
			end)
		end
		rightTextTransparency(versionGradient)
		rightTextTransparency(creatorGradient)

		fastwait(0.9)

		local progressTI = TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

		tweenS:Create(statusText,progressTI,{Position = UDim2.new(0,20,0,120), TextTransparency = 0}):Play()
		tweenS:Create(progressBar,progressTI,{Position = UDim2.new(0,60,0,145), Size = UDim2.new(0,100,0,4)}):Play()

		fastwait(0.25)

		local function setProgress(text,n)
			statusText.Text = text
			tweenS:Create(progressBar.Bar,progressTI,{Size = UDim2.new(n,0,1,0)}):Play()
		end

		local function close()
			tweenS:Create(titleText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(descText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(versionText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(creatorText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(statusText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(progressBar,progressTI,{BackgroundTransparency = 1}):Play()
			tweenS:Create(progressBar.Bar,progressTI,{BackgroundTransparency = 1}):Play()
			tweenS:Create(progressBar.ImageLabel,progressTI,{ImageTransparency = 1}):Play()

			tweenNumber(100,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),function(val)
				val = val/250
				local start = NumberSequenceKeypoint.new(0,0)
				local a1 = NumberSequenceKeypoint.new(0.6+val,0)
				local a2 = NumberSequenceKeypoint.new(math.min(1,0.601+val),1)
				if a1.Time == a2.Time then a2 = a1 end
				local goal = NumberSequenceKeypoint.new(1,a1 == a2 and 0 or 1)
				holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
			end)

			fastwait(0.5)
			gui.Main.BackgroundTransparency = 1
			outlinesGradient.Rotation = 30

			tweenNumber(100,ti,function(val)
				val = val/100
				local start = NumberSequenceKeypoint.new(0,1)
				local a1 = NumberSequenceKeypoint.new(val,1)
				local a2 = NumberSequenceKeypoint.new(math.min(1,val+math.min(0.05,val)),0)
				if a1.Time == a2.Time then a2 = a1 end
				local goal = NumberSequenceKeypoint.new(1,a1 == a2 and 1 or 0)
				outlinesGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
				holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
			end)

			fastwait(0.45)
			gui:Destroy()
		end

		return {SetProgress = setProgress, Close = close, Object = gui}
	end

	Main.CreateApp = function(data)
		if Main.MenuApps[data.Name] then return end -- TODO: Handle conflict
		local control = {}

		local app = Main.AppTemplate:Clone()

		local iconIndex = data.Icon
		if data.IconMap and iconIndex then
			if type(iconIndex) == "number" then
				data.IconMap:Display(app.Main.Icon,iconIndex)
			elseif type(iconIndex) == "string" then
				data.IconMap:DisplayByKey(app.Main.Icon,iconIndex)
			end
		elseif type(iconIndex) == "string" then
			app.Main.Icon.Image = iconIndex
		else
			app.Main.Icon.Image = ""
		end

		local function updateState()
			app.Main.BackgroundTransparency = data.Open and 0 or (Lib.CheckMouseInGui(app.Main) and 0 or 1)
			app.Main.Highlight.Visible = data.Open
		end

		local function enable(silent)
			if data.Open then return end
			data.Open = true
			updateState()
			if not silent then
				if data.Window then data.Window:Show() end
				if data.OnClick then data.OnClick(data.Open) end
			end
		end

		local function disable(silent)
			if not data.Open then return end
			data.Open = false
			updateState()
			if not silent then
				if data.Window then data.Window:Hide() end
				if data.OnClick then data.OnClick(data.Open) end
			end
		end

		updateState()

		local ySize = service.TextService:GetTextSize(data.Name,14,Enum.Font.SourceSans,Vector2.new(62,999999)).Y
		app.Main.Size = UDim2.new(1,0,0,math.clamp(46+ySize,60,74))
		app.Main.AppName.Text = data.Name

		app.Main.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				app.Main.BackgroundTransparency = 0
				app.Main.BackgroundColor3 = Settings.Theme.ButtonHover
			end
		end)
		

		app.Main.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				app.Main.BackgroundTransparency = data.Open and 0 or 1
				app.Main.BackgroundColor3 = Settings.Theme.Button
			end
		end)

		app.Main.MouseButton1Click:Connect(function()
			if data.Open then disable() else enable() end
		end)

		local window = data.Window
		if window then
			window.OnActivate:Connect(function() enable(true) end)
			window.OnDeactivate:Connect(function() disable(true) end)
		end

		app.Visible = true
		app.Parent = Main.AppsContainer
		Main.AppsFrame.CanvasSize = UDim2.new(0,0,0,Main.AppsContainerGrid.AbsoluteCellCount.Y*82 + 8)

		control.Enable = enable
		control.Disable = disable
		Main.MenuApps[data.Name] = control
		return control
	end

	Main.SetMainGuiOpen = function(val)
		Main.MainGuiOpen = val

		Main.MainGui.OpenButton.Text = val and "Close" or "Dex++"
		if val then Main.MainGui.OpenButton.MainFrame.Visible = true end
		Main.MainGui.OpenButton.MainFrame:TweenSize(val and UDim2.new(0,224,0,200) or UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		--Main.MainGui.OpenButton.BackgroundTransparency = val and 0 or (Lib.CheckMouseInGui(Main.MainGui.OpenButton) and 0 or 0.2)
		service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = val and 0 or (Lib.CheckMouseInGui(Main.MainGui.OpenButton) and 0 or 0.2)}):Play()

		if Main.MainGuiMouseEvent then Main.MainGuiMouseEvent:Disconnect() end

		if not val then
			local startTime = tick()
			Main.MainGuiCloseTime = startTime
			coroutine.wrap(function()
				Lib.FastWait(0.2)
				if not Main.MainGuiOpen and startTime == Main.MainGuiCloseTime then Main.MainGui.OpenButton.MainFrame.Visible = false end
			end)()
		else
			Main.MainGuiMouseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not Lib.CheckMouseInGui(Main.MainGui.OpenButton) and not Lib.CheckMouseInGui(Main.MainGui.OpenButton.MainFrame) then

					Main.SetMainGuiOpen(false)
				end
			end)
		end
	end

	Main.CreateMainGui = function()
		local gui = create({
			{1,"ScreenGui",{IgnoreGuiInset=true,Name="MainMenu",}},
			{2,"TextButton",{AnchorPoint=Vector2.new(0.5,0),AutoButtonColor=false,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,Font=4,Name="OpenButton",Parent={1},Position=UDim2.new(0.5,0,0,2),Size=UDim2.new(0,55,0,32),Text="Dex++",TextColor3=Color3.new(1,1,1),TextSize=16,TextTransparency=0.20000000298023,}},
			{3,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
			{4,"Frame",{AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),ClipsDescendants=true,Name="MainFrame",Parent={2},Position=UDim2.new(0.5,0,1,-4),Size=UDim2.new(0,224,0,200),}},
			{5,"UICorner",{CornerRadius=UDim.new(0,4),Parent={4},}},
			{6,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),Name="BottomFrame",Parent={4},Position=UDim2.new(0,0,1,-24),Size=UDim2.new(1,0,0,24),}},
			{7,"UICorner",{CornerRadius=UDim.new(0,4),Parent={6},}},
			{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="CoverFrame",Parent={6},Size=UDim2.new(1,0,0,4),}},
			{9,"Frame",{BackgroundColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,0,-1),Size=UDim2.new(1,0,0,1),}},
			{10,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Settings",Parent={6},Position=UDim2.new(1,-48,0,0),Size=UDim2.new(0,24,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{11,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6578871732",ImageTransparency=0.20000000298023,Name="Icon",Parent={10},Position=UDim2.new(0,4,0,4),Size=UDim2.new(0,16,0,16),}},
			{12,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Information",Parent={6},Position=UDim2.new(1,-24,0,0),Size=UDim2.new(0,24,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{13,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6578933307",ImageTransparency=0.20000000298023,Name="Icon",Parent={12},Position=UDim2.new(0,4,0,4),Size=UDim2.new(0,16,0,16),}},
			{14,"ScrollingFrame",{Active=true,AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),BorderSizePixel=0,Name="AppsFrame",Parent={4},Position=UDim2.new(0.5,0,0,0),ScrollBarImageColor3=Color3.new(0,0,0),ScrollBarThickness=4,Size=UDim2.new(0,222,1,-25),}},
			{15,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Container",Parent={14},Position=UDim2.new(0,7,0,8),Size=UDim2.new(1,-14,0,2),}},
			{16,"UIGridLayout",{CellSize=UDim2.new(0,66,0,74),Parent={15},SortOrder=2,}},
			{17,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="App",Parent={1},Size=UDim2.new(0,100,0,100),Visible=false,}},
			{18,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderSizePixel=0,Font=3,Name="Main",Parent={17},Size=UDim2.new(1,0,0,60),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
			{19,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://129589545519436",ImageRectSize=Vector2.new(32,32),Name="Icon",Parent={18},Position=UDim2.new(0.5,-16,0,4),ScaleType=4,Size=UDim2.new(0,32,0,32),}},
			{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="AppName",Parent={18},Position=UDim2.new(0,2,0,38),Size=UDim2.new(1,-4,1,-40),Text="Explorer",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextWrapped=true,TextYAlignment=0,}},
			{21,"Frame",{BackgroundColor3=Color3.new(0,0.66666668653488,1),BorderSizePixel=0,Name="Highlight",Parent={18},Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),}},
		})
		Main.MainGui = gui
		Main.AppsFrame = gui.OpenButton.MainFrame.AppsFrame
		Main.AppsContainer = Main.AppsFrame.Container
		Main.AppsContainerGrid = Main.AppsContainer.UIGridLayout
		Main.AppTemplate = gui.App
		Main.MainGuiOpen = false

		local openButton = gui.OpenButton
		openButton.BackgroundTransparency = 0.2
		openButton.MainFrame.Size = UDim2.new(0,0,0,0)
		openButton.MainFrame.Visible = false
		openButton.MouseButton1Click:Connect(function()
			Main.SetMainGuiOpen(not Main.MainGuiOpen)
		end)

		openButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
			end
		end)

		openButton.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = Main.MainGuiOpen and 0 or 0.2}):Play()
			end
		end)
		
		local infoDexIntro, isInfoCD
		
		--openButton.MainFrame.BottomFrame.Settings.Visible = false
		
		openButton.MainFrame.BottomFrame.Settings.MouseButton1Click:Connect(function()
			if not SettingsWindow.Window.Closed then
				SettingsWindow.Window:Hide()
			else
				SettingsWindow.Window:Show()
			end		
		end)
		
		openButton.MainFrame.BottomFrame.Information.MouseButton1Click:Connect(function()
			local duration = 1
			local Infos = {
				"Contributors >>",
				"Toon (IY Dex and PRs)",
				"Moon (Dex)",
				"Cazan (3D Preview)",
			}
			
			if isInfoCD then return end
			isInfoCD = true
			if not infoDexIntro then
				infoDexIntro = Main.CreateIntro("Running")
				--Main.AppControls ~= {}
				coroutine.wrap(function()
					while infoDexIntro and openButton.Parent ~= nil do
						for i,text in Infos do
							if not infoDexIntro or openButton.Parent == nil then break end
							infoDexIntro.SetProgress(text,(1 / #Infos) * i)
							task.wait(duration)
						end
					end
				end)()
				
				Lib.FastWait(1.5)
				isInfoCD = false
			else
				coroutine.wrap(function()
					infoDexIntro.Close()
					infoDexIntro = nil
					
					Lib.FastWait(1.5)
					isInfoCD = false
				end)()
			end
		end)

		-- Create Main Apps
		Main.CreateApp({Name = "Explorer", IconMap = Main.LargeIcons, Icon = "Explorer", Open = true, Window = Explorer.Window})

		Main.CreateApp({Name = "Properties", IconMap = Main.LargeIcons, Icon = "Properties", Open = true, Window = Properties.Window})

		local cptsOnMouseClick = nil
		Main.CreateApp({Name = "Click part to select", IconMap = Explorer.ClassIcons, Icon = "SelectionBox", OnClick = function(callback)
			if callback then
				local mouse = Main.Mouse
				cptsOnMouseClick = mouse.Button1Down:Connect(function()
					pcall(function()
						local object = mouse.Target
						if nodes[object] then
							selection:Set(nodes[object])
							Explorer.ViewNode(nodes[object])
						end
					end)
				end)
			else if cptsOnMouseClick ~= nil then cptsOnMouseClick:Disconnect() cptsOnMouseClick = nil end end
		end})

		Main.CreateApp({Name = "Notepad", IconMap = Main.LargeIcons, Icon = "Script_Viewer", Window = ScriptViewer.Window})
		
		Main.CreateApp({Name = "Console", IconMap = Main.LargeIcons, Icon = "Executor", Window = Console.Window})
		
		Main.CreateApp({Name = "Save Instance", IconMap = Main.LargeIcons, Icon = "Book", Window = SaveInstance.Window})
		
		Main.CreateApp({Name = "3D Viewer", IconMap = Main.LargeIcons, Icon = "Object", Window = ModelViewer.Window})

		if MCPBridge and MCPBridge.Window then
			Main.CreateApp({Name = "MCP", IconMap = Main.LargeIcons, Icon = "Watcher", Window = MCPBridge.Window})
		end

		--Main.CreateApp({Name = "Secret Service Panel", IconMap = Main.LargeIcons, Icon = "Output", Window = SecretServicePanel.Window})
		
		for _, loadedplugin in pairs(Main.Plugins) do
			Main.CreateApp({Name = loadedplugin.PluginData.FriendlyName, IconMap = Explorer.ClassIcons, Icon = "Attachment", Window = loadedplugin.Window})
		end
		
		Lib.ShowGui(gui)
	end

	Main.SetupFilesystem = function()
		if not env.writefile or not env.makefolder then return end

		local writefile,makefolder = env.writefile,env.makefolder

		makefolder("dex")
		makefolder("dex/assets")
		makefolder("dex/saved")
		makefolder("dex/plugins")
		makefolder("dex/ModuleCache")
	end

	Main.SaveCurrentSettings = function()
		if writefile then
			writefile("DexPlusPlusSettings.json", Main.ExportSettings())
		end
	end

	Main.LocalDepsUpToDate = function()
		return Main.DepsVersionData and Main.ClientVersion == Main.DepsVersionData[1]
	end

	Main.Init = function()
		Main.Elevated = pcall(function() local a = game:GetService("CoreGui"):GetFullName() end)
		
		-- saves new settings if does not exist
		if isfile and not isfile("DexPlusPlusSettings.json") then
			Main.SaveCurrentSettings()
		end
		
		Main.InitEnv()
		Main.LoadSettings() -- loads the settings before init
		
		Main.SetupFilesystem()

		-- Load Lib
		local intro = Main.CreateIntro("Initializing Library")
		Lib = Main.LoadModule("Lib")
		Lib.FastWait()

		-- Init other stuff
		Main.IncompatibleTest()

		-- Init icons
		Main.MiscIcons = Lib.IconMap.new("rbxassetid://6511490623",256,256,16,16)
		Main.MiscIcons:SetDict({
			Reference = 0,             Cut = 1,                         Cut_Disabled = 2,      Copy = 3,               Copy_Disabled = 4,    Paste = 5,                Paste_Disabled = 6,
			Delete = 7,                Delete_Disabled = 8,             Group = 9,             Group_Disabled = 10,    Ungroup = 11,         Ungroup_Disabled = 12,    TeleportTo = 13,
			Rename = 14,               JumpToParent = 15,               ExploreData = 16,      Save = 17,              CallFunction = 18,    CallRemote = 19,          Undo = 20,
			Undo_Disabled = 21,        Redo = 22,                       Redo_Disabled = 23,    Expand_Over = 24,       Expand = 25,          Collapse_Over = 26,       Collapse = 27,
			SelectChildren = 28,       SelectChildren_Disabled = 29,    InsertObject = 30,     ViewScript = 31,        AddStar = 32,         RemoveStar = 33,          Script_Disabled = 34,
			LocalScript_Disabled = 35, Play = 36,                       Pause = 37,            Rename_Disabled = 38,   Empty = 1000
		})
		Main.LargeIcons = Lib.IconMap.new("rbxassetid://129589545519436",256,256,32,32)
		Main.LargeIcons:SetDict({
			Explorer = 0, Properties = 1, Script_Viewer = 2, Watcher = 3, Output = 4, ScriptEdit = 5, Book = 6, Executor = 7, Object = 8, Honey = 9
		})
		
		--[[ Loading bypasses
		intro.SetProgress("Loading Adonis Bypass",0.1)
		pcall(Main.LoadAdonisBypass)
		
		intro.SetProgress("Loading GC Bypass",0.2)
		pcall(Main.LoadGCBypass)]]

		-- Fetch version if needed
		intro.SetProgress("Fetching Roblox Version",0.3)
		if Main.Elevated then
			local fileVer = Lib.ReadFile("dex/deps_version.dat")
			Main.ClientVersion = Version()
			if fileVer then
				Main.DepsVersionData = string.split(fileVer,"\n")
				if Main.LocalDepsUpToDate() then
					Main.RobloxVersion = Main.DepsVersionData[2]
				end
			end
			
			Main.RobloxVersion = Main.RobloxVersion or oldgame:HttpGet("https://clientsettings.roblox.com/v2/client-version/WindowsStudio64/channel/LIVE"):match("(version%-[%w]+)")
		end

		-- Fetch external deps
		intro.SetProgress("Fetching API",0.35)
		API = Main.FetchAPI(
			function()
				intro.SetProgress("Fetching API, Please Wait.",0.4)
			end,
			function()
				intro.SetProgress("Fetching API, Please Wait Due To Huge API File To Download.",0.45)
			end,
			function()
				intro.SetProgress("Fetching API, LOL STILL DOWNlOADING? bad wifi xD",0.475)
			end
		)
		Lib.FastWait()
		intro.SetProgress("Fetching RMD",0.5)
		RMD = Main.FetchRMD()
		Lib.FastWait()

		-- Save external deps locally if needed
		if Main.Elevated and env.writefile and not Main.LocalDepsUpToDate() then
			env.writefile("dex/deps_version.dat",Main.ClientVersion.."\n"..Main.RobloxVersion)
			env.writefile("dex/rbx_api.dat",Main.RawAPI)
			env.writefile("dex/rbx_rmd.dat",Main.RawRMD)
		end

		-- Load other modules
		intro.SetProgress("Loading Modules",0.75)
		Main.AppControls.Lib.InitDeps(Main.GetInitDeps()) -- Missing deps now available
		Main.LoadModules()
		Lib.FastWait()

		-- Init other modules
		intro.SetProgress("Initializing Modules",0.8)
		Explorer.Init()
		Properties.Init()
		ScriptViewer.Init()
		Console.Init()
		SaveInstance.Init()
		ModelViewer.Init()
		SettingsWindow.Init()
		--SecretServicePanel.Init()
		if MCPBridge then
			local mcpOk, mcpErr = pcall(MCPBridge.Init)
			if not mcpOk then warn("[Dex++ MCP] Init failed: " .. tostring(mcpErr)) end
		end
		
		
		if env.readfile and listfiles then
			if #listfiles("dex/plugins") > 0 then
				intro.SetProgress("Loading Plugin Files",0.8)
				for _, pluginDir in pairs(listfiles("dex/plugins")) do
					local moduleData = Main.LoadPluginFile(pluginDir)
					moduleData.PluginData = moduleData.PluginData or {}

					moduleData.Init()

					local pluginFriendlyName = moduleData.PluginData.FriendlyName or moduleData.Window.GuiElems.Title.Text or "Unnamed Plugin"
					local pluginName = moduleData.PluginData.Name or moduleData.Window.GuiElems.Title.Text:gsub(" ", "") or "unnamedPlugin"

					intro.SetProgress("Initializing Plugin: ".. pluginFriendlyName,0.9)

					moduleData.PluginData.Name = pluginName
					moduleData.PluginData.FriendlyName = pluginFriendlyName

					table.insert(Main.Plugins, moduleData)
				end
			end	
		end
		
		
		Lib.FastWait()

		-- Done
		intro.SetProgress("Complete",1)
		coroutine.wrap(function()
			Lib.FastWait(1.25)
			intro.Close()
		end)()

		-- Init window system, create main menu, show explorer and properties
		Lib.Window.Init()
		Main.CreateMainGui()
		Explorer.Window:Show({Align = "right", Pos = 1, Size = 0.5, Silent = true})
		Properties.Window:Show({Align = "right", Pos = 2, Size = 0.5, Silent = true})
		
		Lib.DeferFunc(function() Lib.Window.ToggleSide("right") end)
	end
	
	Main.Uninit = function()
		Main.MenuApps = {}
		Main.AppControls = {}
		Main.Plugins = {}
		for _, gui in pairs(Main.GetSecureContainer():GetChildren()) do
			if string.sub(gui.Name,1,5) == "_DPP_" then -- DPP stands for DexPlusPlus
				gui:Destroy()
			end
		end
	end

	Main.Reinit = function()
		Main.Uninit()
		task.wait()
		Main.Init()
	end

	return Main
end)()

-- Start
Main.Init()

--for i,v in pairs(Main.MissingEnv) do print(i,v) end