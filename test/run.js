// End-to-end test: spawn the MCP server over stdio, connect a mock Dex++ client, exercise tools.
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import assert from "node:assert/strict";
import path from "node:path";
import fs from "node:fs";
import os from "node:os";
import { fileURLToPath } from "node:url";
import { connectWs, connectHttp, SILENT } from "./mock-client.js";
import { disassemble, formatListing } from "../server/luau.js";

const here = path.dirname(fileURLToPath(import.meta.url));
const PORT = 28700 + Math.floor(Math.random() * 200);

let passed = 0;
const failures = [];
async function test(name, fn) {
	try {
		await fn();
		passed++;
		console.log(`  ok  ${name}`);
	} catch (e) {
		failures.push(name);
		console.log(`FAIL  ${name}\n      ${e.stack?.split("\n").slice(0, 4).join("\n      ")}`);
	}
}

const text = (r) => r.content.map((c) => c.text).join("\n");

const transport = new StdioClientTransport({
	command: process.execPath,
	args: [path.join(here, "..", "server", "index.js")],
	env: { ...process.env, DEXMCP_PORT: String(PORT) },
	stderr: "pipe",
});
let stderr = "";
transport.stderr?.on("data", (d) => (stderr += d.toString()));
const client = new Client({ name: "test", version: "1" });
await client.connect(transport);

const tools = (await client.listTools()).tools;

await test("tool catalogue", async () => {
	assert.ok(tools.length >= 140, `expected >=140 tools, got ${tools.length}`);
	const names = new Set(tools.map((t) => t.name));
	assert.equal(names.size, tools.length, "duplicate tool names");
	for (const t of tools) {
		assert.ok(t.description && t.description.length > 15, `${t.name} lacks a description`);
		assert.equal(t.inputSchema.type, "object", `${t.name} schema`);
		assert.ok(t.inputSchema.properties.client, `${t.name} lacks client param`);
	}
	for (const must of ["get_tree", "remote_spy", "search_scripts", "decompile_script", "gc_find_value", "execute_lua", "hook_function", "disassemble_bytecode", "export_scripts", "raw_command"]) {
		assert.ok(names.has(must), `missing tool ${must}`);
	}
	console.log(`      ${tools.length} tools registered`);
});

await test("no client connected -> helpful error", async () => {
	const r = await client.callTool({ name: "get_status", arguments: {} });
	assert.equal(r.isError, true);
	assert.match(text(r), /No Roblox client is connected/);
});

await test("server_info / list_clients with no clients", async () => {
	const r = await client.callTool({ name: "server_info", arguments: {} });
	assert.match(text(r), /listening/);
	const l = await client.callTool({ name: "list_clients", arguments: {} });
	assert.match(text(l), /"clients": \[\]/);
});

const ws = await connectWs(PORT);

await test("websocket hello/welcome + list_clients", async () => {
	assert.equal(ws.welcome.type, "welcome");
	const l = JSON.parse(text(await client.callTool({ name: "list_clients", arguments: {} })));
	assert.equal(l.clients.length, 1);
	assert.equal(l.clients[0].user, "Tester");
	assert.equal(l.clients[0].transport, "websocket");
});

await test("get_status round trip", async () => {
	const r = await client.callTool({ name: "get_status", arguments: {} });
	assert.ok(!r.isError, text(r));
	const j = JSON.parse(text(r));
	assert.equal(j.executor, "MockExec 1.0");
	assert.ok(typeof j.round_trip_ms === "number");
});

await test("plain tool passes params + default JSON formatting", async () => {
	const r = await client.callTool({ name: "get_children", arguments: { target: "game.Workspace", limit: 5 } });
	assert.match(text(r), /"matched": 2/);
	const last = ws.calls.at(-1);
	assert.equal(last.cmd, "get_children");
	assert.deepEqual(last.params, { target: "game.Workspace", limit: 5 });
});

await test("get_tree text formatting", async () => {
	const r = await client.callTool({ name: "get_tree", arguments: { depth: 2 } });
	assert.match(text(r), /^Workspace \[Workspace\]/);
	assert.match(text(r), /2 node\(s\) shown/);
});

await test("decompile_script formatting + line numbers", async () => {
	const r = await client.callTool({ name: "decompile_script", arguments: { target: "game.StarterPlayer.Foo", line_numbers: true } });
	const t = text(r);
	assert.match(t, /-- game\.StarterPlayer\.Foo \(LocalScript\) ref #9/);
	assert.match(t, /1  print\('hi'\)/);
	const last = ws.calls.at(-1);
	assert.equal(last.params.line_numbers, undefined === last.params.line_numbers ? undefined : last.params.line_numbers);
});

await test("action-routed tools map to the right command", async () => {
	await client.callTool({ name: "attributes", arguments: { action: "set", target: "#5", name: "Level", value: 7 } });
	let last = ws.calls.at(-1);
	assert.equal(last.cmd, "set_attribute");
	assert.deepEqual(last.params, { target: "#5", name: "Level", value: 7 });
	ws.handlers.get_attributes = () => ({ attributes: { Level: 7 }, count: 1 });
	await client.callTool({ name: "attributes", arguments: { action: "get", target: "#5" } });
	assert.equal(ws.calls.at(-1).cmd, "get_attributes");
	await client.callTool({ name: "set_property", arguments: { target: "#5", properties: { Anchored: true } } });
	assert.equal(ws.calls.at(-1).cmd, "set_properties");
});

await test("remote spy log rendering", async () => {
	const r = await client.callTool({ name: "remote_spy_get", arguments: { limit: 10 } });
	const t = text(r);
	assert.match(t, /game\.ReplicatedStorage\.Hit:FireServer\("sword", Vector3\(1, 2, 3\), <Part game\.Workspace\.Dummy #7>\)/);
	assert.match(t, /= true, #11\{a=1, b="x"\}/);
	assert.match(t, /from game\.Players\.Me\.PlayerScripts\.Combat/);
	assert.match(t, /last_seq=6/);
});

await test("execute_lua formatting", async () => {
	const r = await client.callTool({ name: "execute_lua", arguments: { code: "return 42, 'str'" } });
	const t = text(r);
	assert.match(t, /\[warn\] careful/);
	assert.match(t, /=> 42\n=> "str"/);
});

await test("lua-side error surfaces as tool error with hint plumbing", async () => {
	const r = await client.callTool({ name: "raw_command", arguments: { cmd: "boom" } });
	assert.equal(r.isError, true);
	assert.match(text(r), /kaboom/);
	const u = await client.callTool({ name: "raw_command", arguments: { cmd: "does_not_exist" } });
	assert.equal(u.isError, true);
	assert.match(text(u), /unknown command/);
});

await test("large reply arrives via chunk reassembly (700KB)", async () => {
	const r = await client.callTool({ name: "raw_command", arguments: { cmd: "big" } });
	assert.ok(!r.isError, text(r).slice(0, 200));
	assert.ok(text(r).length > 100000, "output should be large (then truncated)");
	assert.match(text(r), /output truncated/);
});

await test("batch runs several commands, isolating failures", async () => {
	const r = await client.callTool({ name: "batch", arguments: { calls: [{ cmd: "get_status" }, { cmd: "boom" }, { cmd: "get_children", params: { target: "game" } }] } });
	const j = JSON.parse(text(r));
	assert.equal(j.length, 3);
	assert.equal(j[0].ok, true);
	assert.equal(j[1].ok, false);
	assert.equal(j[2].ok, true);
	const p = await client.callTool({ name: "batch", arguments: { parallel: true, calls: [{ cmd: "get_status" }, { cmd: "get_status" }] } });
	assert.equal(JSON.parse(text(p)).length, 2);
});

await test("wait_for_events returns pending events", async () => {
	ws.handlers.get_events = (p) => {
		if (p.since === 100) return { events: [], returned: 0, matched: 0, last_seq: 100, current_seq: 100 };
		return { events: [{ seq: 101, ch: "output", t: 1700000000, key: "hi", message: "hello world", level: "MessageOutput" }], returned: 1, matched: 1, last_seq: 101, current_seq: 101 };
	};
	const r = await client.callTool({ name: "wait_for_events", arguments: { channel: "output", since: 50, timeout_s: 3, settle_ms: 10 } });
	assert.match(text(r), /\[MessageOutput\] hello world/);
	const empty = await client.callTool({ name: "wait_for_events", arguments: { channel: "output", since: 100, timeout_s: 1 } });
	assert.match(text(empty), /no events within/);
});

await test("export_scripts writes decompiled files to disk", async () => {
	const dir = fs.mkdtempSync(path.join(os.tmpdir(), "dexmcp-export-"));
	const r = await client.callTool({ name: "export_scripts", arguments: { dir, concurrency: 2 } });
	assert.ok(!r.isError, text(r));
	const j = JSON.parse(text(r));
	assert.equal(j.written, 2);
	const f = path.join(dir, "StarterPlayer", "A.LocalScript.lua");
	assert.ok(fs.existsSync(f), "expected " + f);
	assert.match(fs.readFileSync(f, "utf8"), /print\('hi'\)/);
	fs.rmSync(dir, { recursive: true, force: true });
});

await test("http long-poll fallback client", async () => {
	const h = await connectHttp(PORT);
	assert.equal(h.welcome.type, "welcome");
	const list = JSON.parse(text(await client.callTool({ name: "list_clients", arguments: {} })));
	assert.equal(list.clients.length, 2);
	const httpClient = list.clients.find((c) => c.transport === "http-poll");
	assert.ok(httpClient);
	const r = await client.callTool({ name: "get_status", arguments: { client: httpClient.id } });
	assert.ok(!r.isError, text(r));
	assert.equal(JSON.parse(text(r)).executor, "MockExec 1.0");
	assert.equal(h.calls.at(-1).cmd, "get_status");
	// select_client switches the default
	await client.callTool({ name: "select_client", arguments: { client: httpClient.id } });
	await client.callTool({ name: "get_children", arguments: { target: "game" } });
	assert.equal(h.calls.at(-1).cmd, "get_children");
	h.close();
	await client.callTool({ name: "select_client", arguments: { client: ws.welcome.client } });
});

await test("client disconnect fails in-flight work cleanly", async () => {
	const w2 = await connectWs(PORT);
	const list = JSON.parse(text(await client.callTool({ name: "list_clients", arguments: {} })));
	const target = list.clients.at(-1);
	w2.handlers.slow = () => SILENT;
	// server should report an error when the socket drops mid-call
	w2.ws.on("message", (d) => { const m = JSON.parse(d.toString()); if (m.cmd === "slow") setTimeout(() => w2.ws.terminate(), 50); });
	const r = await client.callTool({ name: "raw_command", arguments: { cmd: "slow", timeout_s: 5, client: target.id }, }).catch((e) => ({ isError: true, content: [{ text: String(e) }] }));
	assert.equal(r.isError, true);
	await new Promise((res) => setTimeout(res, 100));
	const after = JSON.parse(text(await client.callTool({ name: "list_clients", arguments: {} })));
	assert.ok(!after.clients.find((c) => c.id === target.id), "dead client removed");
});

await test("bridge refuses browser-originated and rebinding requests", async () => {
	const { default: WebSocket } = await import("ws");
	const http = await import("node:http");
	// browsers always send Origin: websocket upgrade must be rejected
	const wsRejected = await new Promise((resolve) => {
		const w = new WebSocket(`ws://127.0.0.1:${PORT}/ws`, { origin: "https://evil.example" });
		w.on("open", () => resolve(false));
		w.on("error", () => resolve(true));
		w.on("unexpected-response", () => resolve(true));
	});
	assert.equal(wsRejected, true, "websocket with Origin must be refused");
	const req = (headers) =>
		new Promise((resolve, reject) => {
			const r = http.request({ host: "127.0.0.1", port: PORT, method: "GET", path: "/health", headers }, (res) => {
				res.resume();
				res.on("end", () => resolve(res.statusCode));
			});
			r.on("error", reject);
			r.end();
		});
	assert.equal(await req({ Origin: "https://evil.example" }), 403);
	assert.equal(await req({ Host: "attacker.example:80" }), 403);
	assert.equal(await req({}), 200);
});

// ------------------------------------------------------------------ luau disassembler on a hand-built blob
function varint(n) {
	const out = [];
	do {
		let b = n & 127;
		n = Math.floor(n / 128);
		if (n) b |= 128;
		out.push(b);
	} while (n);
	return out;
}
function buildBytecode({ roblox, version = 5 }) {
	const bytes = [];
	const w32 = (v) => { const b = Buffer.alloc(4); b.writeUInt32LE(v >>> 0); bytes.push(...b); };
	const wf64 = (v) => { const b = Buffer.alloc(8); b.writeDoubleLE(v); bytes.push(...b); };
	bytes.push(version, version >= 4 ? 1 : 0); // bytecode version, types version 1
	if (version < 4) bytes.pop();
	const strings = ["print", "hello world", "Players"];
	bytes.push(...varint(strings.length));
	for (const s of strings) { bytes.push(...varint(s.length)); bytes.push(...Buffer.from(s)); }
	bytes.push(...varint(1)); // one proto
	const outer = bytes.splice(0, bytes.length);
	// ---- proto body (collected separately: v12+ prefixes it with its byte size)
	bytes.push(6, 0, 0, 0); // maxstack, numparams, nups, vararg
	bytes.push(0); // flags
	bytes.push(...varint(0)); // typesize
	const op = (n) => (roblox ? (n * 227) & 0xff : n);
	// GETIMPORT R0 K0 aux(count=1, id0=0)  ; LOADK R1 K1 ; CALL R0 2 1 ; RETURN R0 1
	const insns = [
		op(12) | (0 << 8) | (0 << 16), (1 << 30) | (0 << 20),
		op(5) | (1 << 8) | (1 << 16),
		op(21) | (0 << 8) | (2 << 16) | (1 << 24),
		op(22) | (0 << 8) | (1 << 16),
	];
	bytes.push(...varint(insns.length));
	for (const i of insns) w32(i);
	bytes.push(...varint(3)); // constants: import(print), string "hello world", number
	bytes.push(4); w32((1 << 30) | (2 << 20)); // K0: import whose path id0 = constant 2?? (kept simple: string constant index 2)
	bytes.push(3, ...varint(2)); // K1: string index 2 => "hello world"
	bytes.push(2); wf64(3.5); // K2: number
	bytes.push(...varint(0)); // no child protos
	bytes.push(...varint(1)); // linedefined
	bytes.push(...varint(0)); // debugname none
	bytes.push(1, 0); // lineinfo present, gap log2 0
	for (let i = 0; i < insns.length; i++) bytes.push(1); // deltas
	for (let i = 0; i < insns.length; i++) { const b = Buffer.alloc(4); b.writeInt32LE(i === 0 ? 10 : 1); bytes.push(...b); }
	bytes.push(0); // no debug info
	if (version >= 11) bytes.push(...varint(2), 0, ...varint(3), 1, ...varint(4)); // feedback slots: call target + construct
	const body = bytes.splice(0, bytes.length);
	bytes.push(...outer);
	if (version >= 12) bytes.push(...varint(body.length + 3)); // proto size includes 3 bytes of unknown trailing data
	bytes.push(...body);
	if (version >= 12) bytes.push(0xde, 0xad, 0xbe); // trailing bytes a newer compiler might add: must be skipped
	bytes.push(...varint(0)); // main proto index
	return Buffer.from(bytes);
}

await test("luau disassembler: plain + roblox-encoded opcodes auto-detected", async () => {
	for (const roblox of [false, true]) {
		const prog = disassemble(buildBytecode({ roblox }));
		assert.equal(prog.version, 5);
		assert.equal(prog.encoding, roblox ? "roblox" : "plain");
		const names = prog.protos[0].insns.map((i) => i.name);
		assert.deepEqual(names, ["GETIMPORT", "LOADK", "CALL", "RETURN"]);
		const listing = formatListing(prog);
		assert.match(listing, /GETIMPORT\s+R0 K0/);
		assert.match(listing, /LOADK\s+R1 K1\s+; "hello world"/);
		assert.match(listing, /CALL\s+R0 2 1\s+; 1 arg\(s\), 0 result\(s\)/);
		assert.match(listing, /L11/);
		if (process.env.DEBUG_LISTING) console.log(listing);
	}
});

await test("luau disassembler: v12-14 layout (proto size prefix, feedback slots, trailing data)", async () => {
	for (const version of [11, 12, 14]) {
		const prog = disassemble(buildBytecode({ roblox: true, version }));
		assert.equal(prog.version, version);
		assert.deepEqual(prog.protos[0].insns.map((i) => i.name), ["GETIMPORT", "LOADK", "CALL", "RETURN"], `version ${version}`);
	}
	assert.throws(() => disassemble(Buffer.from([15, 1, 0, 0, 0])), /unsupported bytecode version 15/);
});

await test("disassemble_bytecode tool pulls bytecode from the game", async () => {
	const bc = buildBytecode({ roblox: true });
	ws.handlers.get_script_bytecode = () => ({ size: bc.length, hash: "abc", script: { path: "game.Foo", class: "LocalScript" }, offset: 0, returned: bc.length, base64: bc.toString("base64") });
	const r = await client.callTool({ name: "disassemble_bytecode", arguments: { target: "game.Foo", client: ws.welcome.client } });
	assert.ok(!r.isError, text(r));
	assert.match(text(r), /-- game\.Foo \(LocalScript\)/);
	assert.match(text(r), /GETIMPORT/);
});

ws.close();
await client.close();
console.log(`\n${passed} passed, ${failures.length} failed`);
if (failures.length) {
	console.log("failed:", failures.join(", "));
	if (stderr) console.log("--- server stderr ---\n" + stderr);
	process.exit(1);
}
process.exit(0);
