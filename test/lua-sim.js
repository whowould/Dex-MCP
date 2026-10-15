// Hosts the generated MCPBridge Lua module inside fengari (Lua 5.3 in JS) with a mocked Roblox environment,
// connecting it to the real MCP server over a real WebSocket.
import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import WebSocket from "ws";
import { buildModule } from "../scripts/embed.js";

const require = createRequire(import.meta.url);
const fengari = require("fengari");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = fengari;
const here = path.dirname(fileURLToPath(import.meta.url));

function pushJs(L, v) {
	if (v === null || v === undefined) lua.lua_pushnil(L);
	else if (typeof v === "string") lua.lua_pushstring(L, to_luastring(v));
	else if (typeof v === "number") (Number.isInteger(v) ? lua.lua_pushinteger(L, v) : lua.lua_pushnumber(L, v));
	else if (typeof v === "boolean") lua.lua_pushboolean(L, v);
	else if (Array.isArray(v)) {
		lua.lua_createtable(L, v.length, 0);
		v.forEach((x, i) => {
			if (x === null) return;
			pushJs(L, x);
			lua.lua_rawseti(L, -2, i + 1);
		});
	} else {
		lua.lua_createtable(L, 0, 0);
		for (const [k, x] of Object.entries(v)) {
			if (x === null) continue;
			pushJs(L, x);
			lua.lua_setfield(L, -2, to_luastring(k));
		}
	}
}

export function createSim({ port, token = "", transport = "websocket", serverPort = null, beforeLoad = "" }) {
	const L = lauxlib.luaL_newstate();
	lualib.luaL_openlibs(L);
	const logs = [];
	const sockets = new Map();
	let nextSock = 1;

	function check(status, what) {
		if (status !== 0) {
			const msg = to_jsstring(lua.lua_tostring(L, -1));
			lua.lua_pop(L, 1);
			throw new Error(`${what}: ${msg}`);
		}
	}

	function callLua(name, ...args) {
		lua.lua_getglobal(L, to_luastring(name));
		for (const a of args) pushJs(L, a);
		const st = lua.lua_pcall(L, args.length, 0, 0);
		if (st !== 0) {
			const msg = to_jsstring(lua.lua_tostring(L, -1));
			lua.lua_pop(L, 1);
			logs.push(`callLua(${name}) error: ${msg}`);
			console.log(`[lua] callLua(${name}) error: ${msg}`);
		}
	}

	const def = (name, fn) => {
		lua.lua_pushjsfunction(L, fn);
		lua.lua_setglobal(L, to_luastring(name));
	};

	def("__js_log", (L) => {
		const s = to_jsstring(lauxlib.luaL_checklstring(L, 1));
		logs.push(s);
		if (process.env.LUA_VERBOSE) console.log("[lua]", s);
		return 0;
	});
	def("__js_jsondecode", (L) => {
		const s = to_jsstring(lauxlib.luaL_checklstring(L, 1));
		pushJs(L, JSON.parse(s));
		return 1;
	});
	def("__js_ws_connect", (L) => {
		const url = to_jsstring(lauxlib.luaL_checklstring(L, 1));
		const id = nextSock++;
		const ws = new WebSocket(url);
		const rec = { ws, queue: [], open: false };
		sockets.set(id, rec);
		ws.on("open", () => {
			rec.open = true;
			for (const q of rec.queue) ws.send(q);
			rec.queue = [];
		});
		ws.on("message", (d) => callLua("__ws_event", id, "message", d.toString()));
		ws.on("close", () => callLua("__ws_event", id, "close", ""));
		ws.on("error", () => {});
		lua.lua_pushinteger(L, id);
		return 1;
	});
	def("__js_ws_send", (L) => {
		const id = lua.lua_tointeger(L, 1);
		const data = to_jsstring(lauxlib.luaL_checklstring(L, 2));
		const rec = sockets.get(id);
		if (!rec) return 0;
		if (rec.open) rec.ws.send(data);
		else rec.queue.push(data);
		return 0;
	});
	def("__js_ws_close", (L) => {
		const rec = sockets.get(lua.lua_tointeger(L, 1));
		rec?.ws.close();
		return 0;
	});

	function run(code, name) {
		check(lauxlib.luaL_loadstring(L, to_luastring(code)), `load ${name}`);
		check(lua.lua_pcall(L, 0, 0, 0), `run ${name}`);
	}

	run(fs.readFileSync(path.join(here, "mock_env.lua"), "utf8"), "mock_env");

	if (serverPort) run(`__server_port = ${serverPort}`, "server port");
	if (beforeLoad) run(beforeLoad, "beforeLoad");
	const moduleText = buildModule();
	const loader = `
local selection, nodes = nil, {}
local EmbeddedModules = {
${moduleText}
}
local API = __make_api()
local Settings = {
	MCP = { Host = "127.0.0.1", Port = ${port}, AutoConnect = true, Token = ${JSON.stringify(token)}, Transport = "${transport}", Reconnect = true, MaxRefs = 50000, DebugTrace = false },
	Decompiler = { DecompilerFallback = "Konstant", PreferDecompilerFallback = false, ShinyDecompilerPort = 3000 },
	Theme = {},
}
local Main = { Version = "3.0", Elevated = true, SaveCurrentSettings = function() end, MenuApps = {}, Reinit = function() end, SetMainGuiOpen = function() end }
local service = setmetatable({}, { __index = function(t, k) local s = game:GetService(k) t[k] = s return s end })
local env = {
	decompile = function(s) return decompile(s) end,
	isViableDecompileScript = function(s) return s.ClassName ~= "Script" end,
	saveinstance = saveinstance,
}
local control = EmbeddedModules.MCPBridge()
control.InitDeps({ Main = Main, Lib = {}, Apps = {}, Settings = Settings, API = API, RMD = {}, env = env, service = service, plr = game:GetService("Players").LocalPlayer, create = function() end, createSimple = function() end })
__MCP = control.Main()
__MCP_SETTINGS = Settings
`;
	run(loader, "bridge loader");

	return {
		L,
		logs,
		run,
		callLua,
		pump: (dt = 0.05) => callLua("__pump", dt),
		start() {
			run("__MCP.Bridge.startCaptures() __MCP.Bridge.T.start()", "start");
			this.timer = setInterval(() => this.pump(0.05), 20);
		},
		stop() {
			clearInterval(this.timer);
			for (const { ws } of sockets.values()) ws.terminate();
		},
		// run lua and return a string result
		eval(code) {
			run(`__eval_result = (function() ${code} end)()`, "eval");
			lua.lua_getglobal(L, to_luastring("__eval_result"));
			const v = to_jsstring(lua.lua_tostring(L, -1) ?? to_luastring(""));
			lua.lua_pop(L, 1);
			return v;
		},
	};
}
