#!/usr/bin/env node
// dexpp-mcp: MCP server that drives a live Roblox client through the Dex++ bridge.
//
//   MCP client  <--stdio-->  this process  <--WebSocket / HTTP-->  Dex++ (MCPBridge module) in the game
//
// Environment:
//   DEXMCP_PORT   bridge port (default 18764; the next 9 ports are tried when busy)
//   DEXMCP_HOST   bind address (default 127.0.0.1 - keep it local)
//   DEXMCP_TOKEN  optional shared secret; must equal Settings.MCP.Token in Dex++
//   DEXMCP_TIMEOUT default per-call timeout in ms (default 30000)
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { Bridge, LuaError, NoClientError, SERVER_NAME, SERVER_VERSION } from "./bridge.js";
import { buildTools } from "./tools/index.js";
import { fmtJson, truncate } from "./format.js";
import { isReadOnly } from "./tools/common.js";

const log = (msg) => process.stderr.write(`[${SERVER_NAME}] ${msg}\n`);

const bridge = new Bridge({
	host: process.env.DEXMCP_HOST ?? "127.0.0.1",
	port: Number(process.env.DEXMCP_PORT ?? 18764),
	token: process.env.DEXMCP_TOKEN ?? "",
	log,
});
const DEFAULT_TIMEOUT = Number(process.env.DEXMCP_TIMEOUT ?? 30000);

const INSTRUCTIONS = `
Dex++ bridge: tools operate on a live Roblox client running Dex++ with the MCP bridge. Call get_status first; if no client is connected, ask the user to run the patched Dex++ (its "MCP" window shows the connection) or use wait_for_client.

Conventions
- Instances are addressed by Lua-style path ("game.Workspace.Map.Door", game:GetService("Players").LocalPlayer) or by a numeric ref id returned in earlier results. Functions, tables and userdata also get refs; pass them to the function/table/gc tools. Refs live until released/evicted and are per game session.
- Roblox datatypes in results are tagged objects: {"$t":"Vector3","v":[x,y,z]}, {"$t":"Instance","path":...,"ref":N}, etc. The same tags are accepted as input values.
- Event streams (remote spy, hooks, traps, watches, output, errors) buffer inside the game; read them with remote_spy_get / get_events / wait_for_events and tail with since=last_seq.
- Long scans (search_scripts, gc_search, dump_scripts...) take time_budget and return partial results with next_start_index.

Typical reverse-engineering workflow
1. get_tree / list_remotes / list_scripts to map the game; get_game_info for context.
2. remote_spy {action:start}, let the user (or fire_remote / click_gui) trigger behaviour, then remote_spy_summary / remote_spy_get to see traffic; get_remote_handlers jumps to the receiving code.
3. search_scripts / search_constants to find code by string; decompile_script to read it; get_script_env + upvalues + get_table to read live state; gc_find_value to locate values; hook_function / trap_add to observe or alter behaviour.
4. execute_lua for anything not covered by a dedicated tool.
`.trim();

const server = new McpServer({ name: SERVER_NAME, version: SERVER_VERSION }, { instructions: INSTRUCTIONS });

function hintFor(message) {
	if (/does not provide '(\w+)'/.test(message)) return "\nHint: this executor lacks that API; see get_capabilities. Try a different tool or execute_lua with an alternative.";
	if (/ref #\d+ does not exist/.test(message)) return "\nHint: refs are per session and may have been evicted/released; re-run the query that produced it.";
	if (/no child '.*' under/.test(message)) return "\nHint: use get_children/get_tree to see the real names, or find_instances to search.";
	return "";
}

const ctxBase = {
	bridge,
	toolCount: () => defs.length,
};

// per-call helper handed to custom `run` tools
function makeCall(client) {
	return (cmd, params = {}, timeoutMs = DEFAULT_TIMEOUT) => bridge.call(cmd, params, { client, timeoutMs });
}

function stripUndefined(obj) {
	const out = {};
	for (const [k, v] of Object.entries(obj ?? {})) if (v !== undefined) out[k] = v;
	return out;
}

function timeoutFor(def, params) {
	let ms = def.timeout ?? DEFAULT_TIMEOUT;
	if (def.budget) {
		const secs = params.time_budget ?? params.timeout ?? params.wait ?? 25;
		ms = Math.max(ms, (Number(secs) + 20) * 1000);
	}
	return ms;
}

async function execute(def, rawArgs) {
	const { client, ...args } = rawArgs ?? {};
	if (def.run) {
		return def.run(args, { call: makeCall(client), client });
	}
	let cmd = def.cmd ?? def.name;
	let params = args;
	if (def.route) {
		const r = def.route(args);
		cmd = r.cmd;
		params = r.params;
	}
	params = stripUndefined({ ...(def.defaults ?? {}), ...params });
	const { result } = await bridge.call(cmd, params, { client, timeoutMs: timeoutFor(def, params) });
	return def.format ? def.format(result, args) : fmtJson(result);
}

const defs = buildTools(ctxBase);
const clientParam = z.string().optional().describe("Target a specific connected game client (id like c2, username or place id); default is the selected/most recent one.");

for (const def of defs) {
	const readOnly = def.ro ?? isReadOnly(def.name);
	server.registerTool(
		def.name,
		{
			description: def.description,
			inputSchema: { ...def.shape, client: clientParam },
			annotations: {
				readOnlyHint: readOnly,
				destructiveHint: def.destructive ?? false,
				openWorldHint: false,
			},
		},
		async (args) => {
			try {
				const text = await execute(def, args);
				return { content: [{ type: "text", text: truncate(String(text)) }] };
			} catch (e) {
				let msg = e?.message ?? String(e);
				if (e instanceof NoClientError) msg = e.message;
				else if (e instanceof LuaError) msg = `${def.name} failed: ${msg}${hintFor(msg)}`;
				else msg = `${def.name} failed: ${msg}`;
				return { isError: true, content: [{ type: "text", text: msg }] };
			}
		},
	);
}

async function main() {
	const port = await bridge.start();
	log(`bridge listening on ${bridge.host}:${port}${port !== bridge.basePort ? ` (requested ${bridge.basePort} was busy)` : ""}; ${defs.length} tools`);
	setInterval(() => bridge.sweep(), 10000).unref();

	const transport = new StdioServerTransport();
	await server.connect(transport);
	log("MCP stdio transport ready");

	const shutdown = async () => {
		await bridge.stop().catch(() => {});
		process.exit(0);
	};
	process.stdin.on("end", shutdown);
	process.on("SIGINT", shutdown);
	process.on("SIGTERM", shutdown);
}

main().catch((e) => {
	log(`fatal: ${e.stack ?? e.message}`);
	process.exit(1);
});
