// Live smoke test: starts the server over stdio like an MCP client would and exercises READ-ONLY tools against
// whatever Dex++ client connects. Run with the game + Dex++ open:  node test/live.js
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import path from "node:path";
import os from "node:os";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const transport = new StdioClientTransport({ command: process.execPath, args: [path.join(here, "..", "server", "index.js")], env: { ...process.env }, stderr: "pipe" });
let serverErr = "";
transport.stderr?.on("data", (d) => (serverErr += d.toString()));
const mcp = new Client({ name: "live", version: "1" });
await mcp.connect(transport);

const text = (r) => r.content.map((c) => c.text).join("\n");
const results = [];
async function run(label, name, args = {}, { show = 300, expectError = false } = {}) {
	const t0 = Date.now();
	let r;
	try {
		r = await mcp.callTool({ name, arguments: args });
	} catch (e) {
		results.push({ label, ok: false, ms: Date.now() - t0, note: `exception ${e.message}` });
		console.log(`FAIL ${label} (${name}) exception: ${e.message}`);
		return null;
	}
	const t = text(r);
	const ok = !r.isError || expectError;
	results.push({ label, ok, ms: Date.now() - t0, note: r.isError ? t.slice(0, 200) : "" });
	console.log(`${ok ? " ok " : "FAIL"} ${label} (${Date.now() - t0}ms)${r.isError ? "  ERROR: " + t.slice(0, 260).replace(/\n/g, " ") : ""}`);
	if (show && !r.isError) console.log("      " + t.slice(0, show).replace(/\n/g, "\n      "));
	return r.isError ? null : t;
}

console.log("waiting for a Dex++ client to connect (up to 90s)...");
const w = await mcp.callTool({ name: "wait_for_client", arguments: { timeout_s: 90 } });
console.log(text(w));
if (w.isError) {
	console.log(serverErr);
	process.exit(2);
}

const j = (t) => { try { return JSON.parse(t); } catch { return null; } };

const status = j(await run("status", "get_status", {}, { show: 0 }));
if (status) console.log(`      executor=${status.executor} identity=${status.identity} missing=${status.capabilities_missing?.length} rtt=${status.round_trip_ms}ms`);
await run("capabilities", "get_capabilities", {}, { show: 0 });
await run("game info", "get_game_info");
await run("local player", "get_local_player", {}, { show: 500 });
await run("players", "get_players", {}, { show: 200 });
await run("services", "get_services", {}, { show: 400 });
await run("tree depth 1", "get_tree", { target: "game", depth: 1 }, { show: 700 });
await run("workspace children", "get_children", { target: "game.Workspace", limit: 8 }, { show: 500 });
await run("find RemoteEvents", "find_instances", { class: "RemoteEvent", limit: 5 }, { show: 600 });
await run("list_remotes", "list_remotes", { limit: 15, with_handlers: true }, { show: 900 });
const scripts = j(await run("list_scripts", "list_scripts", { limit: 60 }, { show: 500 }));
await run("nil instances", "get_nil_instances", { limit: 5 }, { show: 400 });
await run("workspace properties", "get_properties", { target: "game.Workspace", max_items: 5 }, { show: 500 });
await run("class info", "get_class_info", { class: "Part", members: false }, { show: 200 });

// prefer a real game script (not Dex++'s own nil-parented ones) that actually has bytecode
let local = null;
for (const s of scripts?.scripts ?? []) {
	if (!s.path.startsWith("game.") || s.path.includes("PlayerModule") || s.path.includes("RbxCharacterSounds")) continue;
	const info = j(text(await mcp.callTool({ name: "get_script_info", arguments: { target: s.ref } })));
	if (info?.bytecode_size > 200) { local = s; break; }
}
local ??= scripts?.scripts?.find((s) => s.path.startsWith("game."));
if (local) {
	console.log(`\nusing script ${local.path} (${local.class})`);
	await run("script info", "get_script_info", { target: local.ref }, { show: 500 });
	await run("decompile", "decompile_script", { target: local.ref, max_chars: 700 }, { show: 900 });
	await run("script strings", "get_script_strings", { target: local.ref, min_length: 4 }, { show: 500 });
	await run("script closure functions", "get_script_functions", { target: local.ref, limit: 5 }, { show: 500 });
	await run("script env", "get_script_env", { target: local.ref, max_items: 10 }, { show: 600 });
	await run("bytecode disassembly", "disassemble_bytecode", { target: local.ref, max_lines: 60 }, { show: 1800 });
	const dir = path.join(os.tmpdir(), "dexmcp-live-export");
	await run("export_scripts (3)", "export_scripts", { dir, max_scripts: 3, overwrite: true }, { show: 400 });
	if (fs.existsSync(dir)) console.log("      exported files:", fs.readdirSync(dir, { recursive: true }).slice(0, 6).join(", "));
}
await run("search_constants", "search_constants", { pattern: "Remote", max_results: 3, time_budget: 10 }, { show: 900 });
await run("search_scripts", "search_scripts", { pattern: "FireServer", max_results: 3, time_budget: 12, context: 1 }, { show: 1200 });
await run("gc_stats", "gc_stats");
await run("gc_search functions", "gc_search", { name: "Fire", limit: 4, time_budget: 10 }, { show: 700 });
await run("gui tree", "get_gui_tree", { depth: 2, max_nodes: 30 }, { show: 900 });
await run("stats", "get_stats", {}, { show: 300 });
await run("camera", "get_camera", {}, { show: 300 });
await run("output", "get_output", { limit: 6 }, { show: 500 });
await run("execute_lua", "execute_lua", { code: "return game.PlaceId, #game:GetService('Players'):GetPlayers(), identifyexecutor()" }, { show: 300 });
await run("evaluate", "evaluate", { expression: "workspace.Gravity" }, { show: 100 });
await run("event channels", "list_event_channels", {}, { show: 400 });
await run("batch", "batch", { calls: [{ cmd: "get_game_info" }, { cmd: "get_services" }], parallel: true }, { show: 0 });
await run("raw list_commands", "list_commands", {}, { show: 0 });

const bad = results.filter((r) => !r.ok);
console.log(`\n${results.length - bad.length}/${results.length} calls ok${bad.length ? "; failures: " + bad.map((b) => b.label).join(", ") : ""}`);
await mcp.close();
process.exit(bad.length ? 1 : 0);
