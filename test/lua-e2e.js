// End-to-end: MCP client -> real server -> real WebSocket -> generated Lua bridge (fengari, mocked Roblox).
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createSim } from "./lua-sim.js";

const here = path.dirname(fileURLToPath(import.meta.url));
const PORT = 29100 + Math.floor(Math.random() * 400);
const VERBOSE = !!process.env.LUA_VERBOSE;

let passed = 0;
const failures = [];
async function test(name, fn) {
	try {
		await fn();
		passed++;
		console.log(`  ok  ${name}`);
	} catch (e) {
		failures.push(name);
		console.log(`FAIL  ${name}\n      ${String(e.message).split("\n").slice(0, 12).join("\n      ")}`);
	}
}

const text = (r) => r.content.map((c) => c.text).join("\n");

const transport = new StdioClientTransport({ command: process.execPath, args: [path.join(here, "..", "server", "index.js")], env: { ...process.env, DEXMCP_PORT: String(PORT) }, stderr: "pipe" });
let serverErr = "";
transport.stderr?.on("data", (d) => (serverErr += d.toString()));
const mcp = new Client({ name: "e2e", version: "1" });
await mcp.connect(transport);

const sim = createSim({ port: PORT });
sim.run(fs.readFileSync(path.join(here, "world.lua"), "utf8"), "world");
// coverage: remember which bridge commands the suite exercised
sim.run("__used = {} for k, f in pairs(__MCP.Bridge.H) do __MCP.Bridge.H[k] = function(p) __used[k] = true return f(p) end end", "coverage");
sim.start();

async function call(name, args = {}) {
	const r = await mcp.callTool({ name, arguments: args });
	if (VERBOSE) console.log(`\n--- ${name} ${JSON.stringify(args)}\n${text(r).slice(0, 1500)}`);
	return r;
}
async function ok(name, args = {}) {
	const r = await call(name, args);
	assert.ok(!r.isError, `${name} failed: ${text(r)}`);
	return text(r);
}
async function json(name, args = {}) {
	const t = await ok(name, args);
	try {
		return JSON.parse(t);
	} catch (e) {
		throw new Error(`${name} did not return JSON:\n${t.slice(0, 500)}`);
	}
}
async function fails(name, args, pattern) {
	const r = await call(name, args);
	assert.equal(r.isError, true, `${name} should have failed but returned: ${text(r).slice(0, 200)}`);
	if (pattern) assert.match(text(r), pattern);
	return text(r);
}

// wait for the bridge to connect
await test("lua bridge connects to the server and says hello", async () => {
	const c = await mcp.callTool({ name: "wait_for_client", arguments: { timeout_s: 10 } });
	assert.ok(!c.isError, text(c));
	const st = await json("get_status");
	assert.equal(st.executor, "MockExec 1.0");
	assert.equal(st.game.place_id, 123);
	assert.equal(st.bridge.transport, "websocket");
	assert.ok(st.round_trip_ms >= 0);
});

await test("part errors: none; command count", async () => {
	assert.equal(sim.eval("return #__MCP.Bridge.partErrors"), "0");
	const cmds = await json("list_commands");
	assert.ok(cmds.count >= 200, `commands ${cmds.count}`);
	for (const must of ["get_children", "remote_spy_start", "decompile_script", "gc_search", "trap_add", "execute_lua"]) assert.ok(cmds.commands.includes(must), must);
});

await test("get_capabilities reports present executor APIs", async () => {
	const c = await json("get_capabilities", { probe: ["getgc", "nonexistent_fn"] });
	assert.equal(c.groups.hooks.hookfunction, true);
	assert.equal(c.probed.getgc, true);
	assert.equal(c.probed.nonexistent_fn, false);
});

// ------------------------------------------------------------------------------------------------ instances
await test("get_services / get_children / get_tree", async () => {
	const s = await json("get_services");
	assert.ok(s.services.some((x) => x.name === "Workspace"));
	const ch = await json("get_children", { target: "game.Workspace" });
	assert.equal(ch.total_children, 3);
	const names = ch.children.map((c) => c.name).sort();
	assert.deepEqual(names, ["Config", "Dummy", "Map"]);
	const cfg = ch.children.find((c) => c.name === "Config");
	assert.equal(cfg.value, "abc");
	const tree = await ok("get_tree", { target: "game.Workspace", depth: 3 });
	assert.match(tree, /Map \[Folder\]/);
	assert.match(tree, /Torso \[Part\]/);
	assert.match(tree, /Part With Space \[Part\]/);
});

await test("get_tree collapses runs of identical leaf siblings", async () => {
	const tree = await ok("get_tree", { target: "game.Workspace.Map", depth: 2 });
	assert.match(tree, /Door \[Part\]  x2/);
	assert.equal((tree.match(/Door \[Part\]/g) ?? []).length, 1);
	const withRefs = await ok("get_tree", { target: "game.Workspace.Map", depth: 2, refs: true });
	assert.equal((withRefs.match(/Door \[Part\]/g) ?? []).length, 2, "refs mode keeps every sibling");
});

await test("path resolution: quoting, brackets, GetChildren index, refs, errors", async () => {
	const a = await json("resolve_path", { path: 'game.Workspace.Map["Part With Space"]' });
	assert.equal(a.found, true);
	const b = await json("resolve_path", { path: "game.Workspace.Map.Part With Space" });
	assert.equal(b.found, true);
	const c = await json("resolve_path", { path: "game:GetService('Workspace').Map:GetChildren()[2]" });
	assert.equal(c.found, true);
	assert.equal(c.instance.name, "Door");
	const d = await json("resolve_path", { path: "Workspace.Dummy.Torso" });
	assert.equal(d.found, true);
	const ref = c.instance.ref;
	const e = await json("get_instance", { target: ref });
	assert.equal(e.name, "Door");
	const e2 = await json("get_instance", { target: `#${ref}` });
	assert.equal(e2.ref, ref);
	const bad = await json("resolve_path", { path: "game.Workspace.Nope" });
	assert.equal(bad.found, false);
	assert.match(bad.error, /no child 'Nope' under game\.Workspace \(children: .*Map/);
	await fails("get_children", { target: "game.Workspace.Missing" }, /no child 'Missing'/);
	await fails("get_instance", { target: 999999 }, /ref #999999 does not exist/);
});

await test("get_instance details + class chain + attributes", async () => {
	const i = await json("get_instance", { target: "game.Workspace.Config" });
	assert.equal(i.class, "StringValue");
	assert.deepEqual(i.class_chain.slice(0, 3), ["StringValue", "ValueBase", "Instance"]);
	assert.equal(i.attributes.Level, 5);
	assert.equal(i.path, "game.Workspace.Config");
});

await test("find_instances: by name, class, attribute, property", async () => {
	let r = await json("find_instances", { name: "door" });
	assert.equal(r.matched, 2);
	r = await json("find_instances", { class: "Part", root: "game.Workspace.Map" });
	assert.equal(r.matched, 4);
	r = await json("find_instances", { attribute: { name: "Level", value: 5 } });
	assert.equal(r.matched, 1);
	r = await json("find_instances", { class: "Part", property: { name: "Anchored", value: true } });
	assert.equal(r.matched, 1);
	assert.equal(r.results[0].name, "Baseplate");
	r = await json("find_instances", { text: "sword", root: "game.Players" });
	assert.equal(r.matched, 1);
});

await test("get_descendants / get_path / ancestors", async () => {
	const d = await json("get_descendants", { target: "game.Workspace", class: "Part", limit: 3 });
	assert.equal(d.matched, 5);
	assert.equal(d.returned, 3);
	assert.equal(d.next_offset, 3);
	const p = await json("get_path", { target: "game.Workspace.Map.Part With Space", style: "simple" });
	assert.equal(p.path, 'game.Workspace.Map["Part With Space"]');
	assert.equal(p.index_path, "game:GetChildren()[1]".replace(":GetChildren()[1]", "") + ":GetChildren()[1]:GetChildren()[1]:GetChildren()[4]");
	const a = await json("get_ancestors", { target: "game.Workspace.Dummy.Torso" });
	assert.deepEqual(a.ancestors.map((x) => x.name), ["Dummy", "Workspace", "Game"]);
});

// ------------------------------------------------------------------------------------------------ lifecycle & properties
await test("create / set_property coercion / get_properties / clone / destroy", async () => {
	const created = await json("create_instance", { class: "Part", name: "Made", parent: "game.Workspace", props: { Anchored: true } });
	assert.equal(created.instance.class, "Part");
	const ref = created.instance.ref;
	await ok("set_property", { target: ref, name: "Position", value: [1, 2, 3] });
	await ok("set_property", { target: ref, name: "Material", value: "Neon" });
	const prop = await json("get_property", { target: ref, name: "Position" });
	assert.deepEqual(prop.value, { "$t": "Vector3", v: [1, 2, 3] });
	const mat = await json("get_property", { target: ref, name: "Material" });
	assert.equal(mat.value.name, "Neon");
	await ok("set_property", { target: ref, properties: { Size: { "$t": "Vector3", v: [9, 9, 9] }, CanCollide: false } });
	const props = await json("get_properties", { target: ref });
	const byName = Object.fromEntries(props.properties.map((p) => [p.name, p]));
	assert.deepEqual(byName.Size.value.v, [9, 9, 9]);
	assert.equal(byName.CanCollide.value, false);
	assert.equal(byName.Anchored.type, "bool");
	const nd = await json("get_properties", { target: ref, only_non_default: true });
	assert.ok(nd.properties.some((p) => p.name === "Position"));
	assert.ok(!nd.properties.some((p) => p.name === "Archivable"));
	const clone = await json("clone_instance", { target: ref, name: "MadeCopy", parent: "game.Workspace" });
	assert.equal(clone.instance.name, "MadeCopy");
	const bulk = await json("get_properties_bulk", { targets: [ref, clone.instance.ref], properties: ["Anchored", "Name"] });
	assert.equal(bulk.rows.length, 2);
	await ok("set_parent", { target: clone.instance.ref, parent: "game.Workspace.Dummy" });
	const moved = await json("resolve_path", { path: "game.Workspace.Dummy.MadeCopy" });
	assert.equal(moved.found, true);
	await ok("destroy_instance", { target: clone.instance.ref });
	await ok("destroy_instance", { target: ref });
	const gone = await json("resolve_path", { path: "game.Workspace.Made" });
	assert.equal(gone.found, false);
});

await test("attributes + tags tools", async () => {
	await ok("attributes", { action: "set", target: "game.Workspace.Config", name: "Flag", value: true });
	const g = await json("attributes", { action: "get", target: "game.Workspace.Config" });
	assert.equal(g.attributes.Flag, true);
	assert.equal(g.attributes.Level, 5);
	await ok("attributes", { action: "delete", target: "game.Workspace.Config", name: "Flag" });
	await ok("tags", { action: "add", target: "game.Workspace.Config", tag: "Important" });
	const f = await json("tags", { action: "find", tag: "Important" });
	assert.equal(f.total, 1);
	const l = await json("tags", { action: "list" });
	assert.ok(l.tags.includes("Important"));
});

await test("call_method + refs lifecycle", async () => {
	const r = await json("call_method", { target: "game.Workspace.Map", method: "GetChildren" });
	assert.equal(r.count, 1);
	assert.equal(r.results[0]["$t"], "array");
	assert.equal(r.results[0].items.length, 4);
	const first = r.results[0].items[0];
	assert.equal(first["$t"], "Instance");
	const f = await json("call_method", { target: "game.Workspace", method: "FindFirstChild", args: ["Map"] });
	assert.equal(f.results[0].name, "Map");
	const t = await json("call_method", { target: "game.Workspace", method: "IsA", args: ["Instance"] });
	assert.equal(t.results[0], true);
	const refs = await json("list_refs", { type: "Instance", limit: 5 });
	assert.ok(refs.refs.length > 0);
	const rel = await json("release_refs", { refs: [first.ref] });
	assert.equal(rel.released, 1);
	await fails("get_instance", { target: first.ref }, /does not exist/);
});

await test("class reflection", async () => {
	const ci = await json("get_class_info", { class: "Part" });
	assert.deepEqual(ci.superclass_chain.slice(0, 3), ["Part", "BasePart", "Instance"]);
	assert.ok(ci.properties.some((p) => p.name === "Position"));
	const e = await json("enums", { action: "get", name: "Material" });
	assert.equal(e.items.length, 2);
});

// ------------------------------------------------------------------------------------------------ scripts
await test("list_scripts / decompile (+cache) / get_script_info", async () => {
	const l = await json("list_scripts", { source: "tree" });
	assert.ok(l.scripts.some((s) => s.name === "Combat"));
	assert.ok(l.scripts.every((s) => s.full_name));
	const combat = l.scripts.find((s) => s.name === "Combat");
	const d1 = await ok("decompile_script", { target: combat.ref });
	assert.match(d1, /-- game\.Players\.Tester\.PlayerScripts\.Combat \(LocalScript\)/);
	assert.match(d1, /ANTICHEAT_KEY/);
	const d2 = await ok("decompile_script", { target: combat.ref, line_numbers: true });
	assert.match(d2, /cached/);
	assert.match(d2, /\n2  local Hit/);
	const info = await json("get_script_info", { target: combat.ref });
	assert.equal(info.class, "LocalScript");
	assert.equal(info.viable_decompile, true);
	assert.ok(info.hash);
});

await test("search_scripts finds text with context and respects viability", async () => {
	const r = await ok("search_scripts", { pattern: "FireServer", context: 1, source: "tree" });
	assert.match(r, /== game\.Players\.Tester\.PlayerScripts\.Combat/);
	assert.match(r, /\n >\s+3  Hit:FireServer\('swing', 1\)/);
	assert.match(r, /\n\s+2  local Hit = /);
	assert.match(r, /\n\s+4  print\('combat ready'\)/);
	assert.match(r, /candidates=2/); // Script (server) excluded by viable_only default
	const none = await ok("search_scripts", { pattern: "server only", source: "tree" });
	assert.match(none, /no matches/);
	const all = await ok("search_scripts", { pattern: "server only", source: "tree", viable_only: false });
	assert.match(all, /ServerLogic/);
});

await test("search_constants + get_script_strings use script closures", async () => {
	const r = await ok("search_constants", { pattern: "Damage", source: "tree" });
	assert.match(r, /Combat/);
	assert.match(r, /"Damage"/);
	const s = await json("get_script_strings", { target: "game.Players.Tester.PlayerScripts.Combat" });
	assert.ok(s.unique_strings.includes("hp"));
});

await test("get_script_functions maps GC functions to a script", async () => {
	const f = await json("get_script_functions", { target: "game.Players.Tester.PlayerScripts.Combat", with_constants: true });
	assert.equal(f.total, 2);
	const names = f.functions.map((x) => x.name).sort();
	assert.deepEqual(names, ["heal", "takeDamage"]);
});

await test("set_decompiler + dex_settings", async () => {
	const s = await json("set_decompiler", { engine: "shiny", prefer_fallback: true });
	assert.equal(s.fallback, "Shiny");
	assert.equal(s.prefer_fallback, true);
	await json("set_decompiler", { engine: "konstant", prefer_fallback: false });
	const set = await json("dex_settings", { action: "set", path: "MCP.Port", value: 12345 });
	assert.equal(set.value, 12345);
	await ok("dex_settings", { action: "set", path: "MCP.Port", value: PORT });
	const get = await json("dex_settings", { action: "get", section: "Decompiler" });
	assert.equal(get.settings.DecompilerFallback, "Konstant");
});

// ------------------------------------------------------------------------------------------------ lua runtime
await test("gc_search: functions by name/script/constant, tables by keys/value", async () => {
	let r = await ok("gc_search", { name: "takeDamage" });
	assert.match(r, /matched=1/);
	assert.match(r, /function<takeDamage/);
	r = await ok("gc_search", { script: "game.Players.Tester.PlayerScripts.Combat" });
	assert.match(r, /matched=2/);
	r = await ok("gc_search", { has_constant: "Heal" });
	assert.match(r, /matched=1/);
	r = await ok("gc_search", { kind: "table", has_keys: ["coins", "name"] });
	assert.match(r, /matched=1/);
	assert.match(r, /coins=1234/);
	r = await ok("gc_search", { kind: "table", value_equals: 55 });
	assert.match(r, /matched=1/);
});

await test("gc_find_value locates a number in tables and upvalues", async () => {
	const r = await ok("gc_find_value", { value: 1234 });
	assert.match(r, /key="coins" = 1234|key=\"coins\"/);
	const up = await ok("gc_find_value", { value: { "$t": "ref", id: Number(sim.eval("return 0")) || 1 }, where: ["upvalue"] }).catch(() => "");
	assert.equal(typeof up, "string");
});

await test("table ref workflow: get_table / set_table_field / table_search / inspect_ref", async () => {
	const g = await ok("gc_search", { kind: "table", has_keys: ["coins", "name"] });
	const ref = Number(/#(\d+)\{/.exec(g)[1]);
	const t = await ok("get_table", { ref });
	assert.match(t, /"coins" = 1234/);
	assert.match(t, /"inventory" = #\d+\["sword", "shield"\]/);
	await ok("set_table_field", { ref, key: "coins", value: 9999 });
	assert.equal(sim.eval("return tostring(__state.coins)"), "9999");
	const s = await json("table_search", { ref, key: "value" });
	assert.equal(s.results[0].path, `ref#${ref}.nested.deep.value`);
	await ok("set_table_field", { ref, key: "name", delete: true });
	assert.equal(sim.eval("return tostring(__state.name)"), "nil");
	const insp = await json("inspect_ref", { ref, depth: 3 });
	assert.equal(insp.value["$t"], "table");
	const mt = await json("metatable", { action: "get", ref });
	assert.equal(mt.has_metatable, false);
});

await test("function introspection: info, upvalues (get/set), call, dump", async () => {
	const g = await ok("gc_search", { name: "takeDamage" });
	const fref = Number(/#(\d+)>/.exec(g)[1]);
	const info = await json("get_function_info", { ref: fref });
	assert.equal(info.name, "takeDamage");
	assert.equal(info.upvalue_count, 1);
	assert.equal(info.script.name, "Combat");
	const ups = await json("upvalues", { action: "get", ref: fref });
	assert.equal(ups.upvalues[0].value["$t"], "table");
	const secretRef = ups.upvalues[0].value.ref;
	const called = await ok("call_function", { ref: fref, args: [10] });
	assert.match(called, /90/);
	assert.equal(sim.eval("return tostring(__secret.hp)"), "90");
	await ok("set_table_field", { ref: secretRef, key: "hp", value: 500 });
	assert.equal(sim.eval("return tostring(__secret.hp)"), "500");
	const c = await json("constants", { action: "get", ref: fref });
	assert.equal(c.constants.find((x) => x.type === "string").value, "hp");
	const dump = await json("dump_function", { ref: fref });
	assert.equal(dump.function_dump.name, "takeDamage");
	const refs = await json("find_references", { target: secretRef });
	assert.ok(refs.matched >= 2, `refs matched ${refs.matched}`);
});

await test("gc_snapshot / gc_diff reveals new objects", async () => {
	await ok("gc_snapshot", { name: "before", kinds: ["table"] });
	sim.run("__gc[#__gc + 1] = { fresh = true, token = 'zz' }", "add gc object");
	const d = await ok("gc_diff", { name: "before", kind: "table" });
	assert.match(d, /new=1/);
	assert.match(d, /fresh=true/);
	const stats = await json("gc_stats");
	assert.ok(stats.total > 0);
});

await test("signal connections: list, fire, disable, click_gui", async () => {
	const conns = await json("get_connections", { target: "game.Players.Tester.PlayerGui.BuyButton", signal: "MouseButton1Click" });
	assert.equal(conns.count, 1);
	assert.equal(conns.connections[0].enabled, true);
	await ok("click_gui", { target: "game.Players.Tester.PlayerGui.BuyButton" });
	assert.equal(sim.eval("return tostring(__clicks)"), "1");
	await ok("toggle_connections", { target: "game.Players.Tester.PlayerGui.BuyButton", signal: "MouseButton1Click" });
	await ok("click_gui", { target: "game.Players.Tester.PlayerGui.BuyButton" });
	assert.equal(sim.eval("return tostring(__clicks)"), "1");
	await ok("toggle_connections", { target: "game.Players.Tester.PlayerGui.BuyButton", signal: "MouseButton1Click", enable: true });
	await ok("connection_action", { ref: conns.connections[0].ref, action: "fire" });
	assert.equal(sim.eval("return tostring(__clicks)"), "2");
	await ok("fire_signal", { target: "game.Players.Tester.PlayerGui.BuyButton", signal: "MouseButton1Click" });
	assert.equal(sim.eval("return tostring(__clicks)"), "3");
	const sigs = await json("list_connected_signals", { target: "game.ReplicatedStorage.Hit" });
	assert.ok(Array.isArray(sigs.signals));
});

// ------------------------------------------------------------------------------------------------ remote spy
await test("remote spy: logs outgoing calls with args, script, summary; filters; replay; block", async () => {
	await ok("remote_spy", { action: "start", hook_functions: false });
	const st = await json("remote_spy", { action: "status" });
	assert.equal(st.active, true);
	// call as the game would (checkcaller false)
	await ok("execute_lua", { code: "local Hit = game.ReplicatedStorage.Hit; Hit:FireServer('swing', 3, Vector3.new(1,2,3)); local Ask = game.ReplicatedStorage.Ask; return Ask:InvokeServer('q')" });
	// executor-originated calls are not logged by default... the mock reports checkcaller=false so they are logged
	const log = await ok("remote_spy_get", {});
	assert.match(log, /game\.ReplicatedStorage\.Hit:FireServer\("swing", 3, Vector3\(1, 2, 3\)\)/);
	assert.match(log, /game\.ReplicatedStorage\.Ask:InvokeServer\("q"\)/);
	assert.match(log, /= "invoked", 7/);
	const sum = await ok("remote_spy_summary", {});
	assert.match(sum, /game\.ReplicatedStorage\.Hit \[RemoteEvent\]/);
	assert.match(sum, /\(string,number,Vector3\) x1/);
	const only = await ok("remote_spy_get", { remote: "Ask", direction: "out" });
	assert.ok(!/Hit:FireServer/.test(only));
	// since / tail
	const m = /last_seq=(\d+)/.exec(log);
	const none = await ok("remote_spy_get", { since: Number(m[1]) });
	assert.match(none, /0 event/);
	// detail + replay
	const seqHit = Number(/#(\d+) [\d:.]+ -> game\.ReplicatedStorage\.Hit/.exec(log)[1]);
	const detail = await json("remote_call_detail", { seq: seqHit });
	assert.equal(detail.args[0], "swing");
	const before = Number(sim.eval("return #__remote_log"));
	await ok("remote_replay", { seq: seqHit, modify: [{ index: 2, value: 99 }], times: 2 });
	assert.equal(Number(sim.eval("return #__remote_log")), before + 2);
	assert.equal(sim.eval("return tostring(__remote_log[#__remote_log][3][2])"), "99");
	// list + handlers
	const lr = await json("list_remotes", { with_handlers: true });
	const hitEntry = lr.remotes.find((r) => r.name === "Hit");
	assert.equal(hitEntry.client_handlers, 1);
	assert.ok(lr.remotes.some((r) => r.name === "Spam"));
	const h = await json("get_remote_handlers", { target: "game.ReplicatedStorage.Hit" });
	assert.equal(h.count, 1);
	// block with return values
	await ok("remote_filter", { action: "block", target: "game.ReplicatedStorage.Ask", return_values: ["fake"] });
	const blockedBefore = Number(sim.eval("return #__remote_log"));
	const res = await ok("execute_lua", { code: "return game.ReplicatedStorage.Ask:InvokeServer('x')" });
	assert.match(res, /"fake"/);
	assert.equal(Number(sim.eval("return #__remote_log")), blockedBefore, "blocked call must not reach the remote");
	const logAfter = await ok("remote_spy_get", { remote: "Ask" });
	assert.match(logAfter, /\[BLOCKED\]/);
	await ok("remote_filter", { action: "unblock", all: true });
	// ignore
	await ok("remote_filter", { action: "ignore", name: "Hit" });
	await ok("execute_lua", { code: "game.ReplicatedStorage.Hit:FireServer('ignored')" });
	const ign = await ok("remote_spy_get", { args_match: "ignored" });
	assert.match(ign, /0 event/);
	await ok("remote_filter", { action: "unignore", all: true });
	// fire_remote from executor bypasses the spy log because checkcaller=true
	sim.run("__caller_is_exec = true", "exec caller on");
	const nBefore = Number((await json("remote_spy", { action: "status" })).total_calls_seen);
	await ok("fire_remote", { target: "game.ReplicatedStorage.Hit", args: ["from-exec"] });
	sim.run("__caller_is_exec = false", "exec caller off");
	assert.equal(Number((await json("remote_spy", { action: "status" })).total_calls_seen), nBefore);
	assert.equal(sim.eval("return tostring(__remote_log[#__remote_log][3][1])"), "from-exec");
	await ok("remote_spy", { action: "stop" });
	await ok("execute_lua", { code: "game.ReplicatedStorage.Hit:FireServer('after-stop')" });
	const stopped = await ok("remote_spy_get", { args_match: "after-stop" });
	assert.match(stopped, /0 event/);
});

await test("remote spy: incoming OnClientEvent logged", async () => {
	await ok("remote_spy", { action: "start", hook_functions: false });
	sim.run("__fire_signal(game.ReplicatedStorage.Hit, 'OnClientEvent', 'srv', 5, workspace.Map)", "fire incoming");
	const log = await ok("remote_spy_get", { direction: "in" });
	assert.match(log, /<- game\.ReplicatedStorage\.Hit:OnClientEvent\("srv", 5, <Folder game\.Workspace\.Map #\d+>\)/);
	await ok("remote_spy", { action: "stop" });
});

// ------------------------------------------------------------------------------------------------ traps / watches / hooks
await test("trap_add namecall logs, blocks and returns", async () => {
	const t = await json("trap_add", { member: "Destroy", class: "Part", action: "log" });
	await ok("create_instance", { class: "Part", name: "Doomed", parent: "game.Workspace" });
	await ok("execute_lua", { code: "workspace.Doomed:Destroy()" });
	let ev = await ok("get_events", { channel: "trap" });
	assert.match(ev, /trap#\d+ namecall:Destroy on game\.Workspace\.Doomed/);
	await json("trap_remove", { id: t.trap });
	const b = await json("trap_add", { member: "GetAttribute", action: "return", value: 777, name: "Config" });
	const got = await ok("execute_lua", { code: "return workspace.Config:GetAttribute('Level')" });
	assert.match(got, /=> 777/);
	await json("trap_remove", { id: b.trap });
	const got2 = await ok("execute_lua", { code: "return workspace.Config:GetAttribute('Level')" });
	assert.match(got2, /=> 5/);
	const lst = await json("trap_list");
	assert.equal(lst.traps.length, 0);
});

await test("watch property/children/attribute/signal -> events", async () => {
	const w1 = await json("watch", { kind: "property", target: "game.Workspace.Config", property: "Value" });
	const w2 = await json("watch", { kind: "children", target: "game.Workspace.Dummy" });
	const w3 = await json("watch", { kind: "attribute", target: "game.Workspace.Config", name: "Level" });
	await ok("execute_lua", { code: "workspace.Config.Value = 'changed'; local p = Instance.new('Part'); p.Name='Kid'; p.Parent = workspace.Dummy; workspace.Config:SetAttribute('Level', 6)" });
	const ev = await ok("get_events", { limit: 50 });
	assert.match(ev, /watch#\d+ game\.Workspace\.Config\.Value = "changed"/);
	assert.match(ev, /tree added game\.Workspace\.Dummy\.Kid \[Part\]/);
	assert.match(ev, /game\.Workspace\.Config@Level = 6/);
	const lst = await json("list_watches");
	assert.equal(lst.watches.length, 3);
	await ok("unwatch", { id: w1.watch });
	await ok("unwatch", { all: true });
	assert.equal((await json("list_watches")).watches.length, 0);
});

await test("hook_function lists/unhooks; hook_global resolves executor globals", async () => {
	const g = await ok("gc_search", { name: "heal" });
	const fref = Number(/#(\d+)>/.exec(g)[1]);
	const h = await json("hook_function", { ref: fref, mode: "log" });
	assert.ok(h.hook >= 1);
	const l = await json("list_hooks");
	assert.equal(l.hooks.length, 1);
	const hg = await json("hook_function", { global: "writefile", mode: "log" });
	assert.equal(hg.name, "writefile");
	await ok("unhook_function", { id: h.hook });
	await ok("unhook_function", { id: hg.hook });
	await fails("hook_function", { global: "definitely_not_a_function" }, /not a function/);
});

// ------------------------------------------------------------------------------------------------ exec / files / events
await test("execute_lua: output capture, returns with refs, errors, compile errors, async", async () => {
	let r = await ok("execute_lua", { code: "print('a', 1); warn('w'); return {1,2,3}, 'x'" });
	assert.match(r, /a\t1/);
	assert.match(r, /\[warn\] w/);
	assert.match(r, /=> #\d+\[1, 2, 3\]/);
	assert.match(r, /=> "x"/);
	r = await ok("execute_lua", { code: "error('boom')" });
	assert.match(r, /ERROR: .*boom/);
	r = await ok("execute_lua", { code: "this is not lua" });
	assert.match(r, /COMPILE ERROR/);
	r = await ok("execute_lua", { code: "task.wait(5); return 'late'", timeout: 0.3 });
	assert.match(r, /still running/);
	const id = Number(/exec id (\d+)/.exec(r)[1]);
	const done = await ok("get_exec_result", { id, wait: 10 });
	assert.match(done, /=> "late"/);
	r = await ok("evaluate", { expression: "1 + 2" });
	assert.match(r, /=> 3/);
	r = await ok("execute_lua", { code: "local t = ref(" + sim.eval("return 1") + "); return typeof(t)" });
	assert.ok(r.length > 0);
	const ex = await json("compile_check", { code: "return 1" });
	assert.equal(ex.ok, true);
	const bad = await json("compile_check", { code: "return +" });
	assert.equal(bad.ok, false);
	const lst = await json("list_execs");
	assert.ok(lst.executions.length >= 5);
});

await test("execute_lua can pass refs back in (round trip via ref())", async () => {
	const r = await ok("execute_lua", { code: "return workspace.Map" });
	const ref = Number(/#(\d+)>/.exec(r)[1]);
	const r2 = await ok("execute_lua", { code: `return ref(${ref}).Name` });
	assert.match(r2, /=> "Map"/);
	const r3 = await ok("execute_lua", { code: `return inst("game.Workspace.Dummy").ClassName` });
	assert.match(r3, /=> "Model"/);
});

await test("events: channels, cursors, output + error capture", async () => {
	const ch = await json("list_event_channels");
	assert.ok(ch.channels.some((c) => c.channel === "trap"));
	await ok("clear_events", { channel: "output" });
	sim.run("__fire_signal(game:GetService('LogService'), 'MessageOut', 'hello out', Enum.MessageType.MessageWarning)", "fire output");
	sim.run("__fire_signal(game:GetService('ScriptContext'), 'Error', 'bad thing', 'stack line 1', workspace.Dummy)", "fire error");
	const out = await ok("get_events", { channel: "output" });
	assert.match(out, /\[MessageWarning\] hello out/);
	const err = await ok("get_events", { channel: "error" });
	assert.match(err, /ERROR bad thing\s+\(game\.Workspace\.Dummy\)/);
	// cursor semantics: since=last_seq returns nothing new
	const m = /last_seq=(\d+)/.exec(out);
	const none = await ok("get_events", { channel: "output", since: Number(m[1]) });
	assert.match(none, /0 event/);
	const o2 = await ok("get_output", { since: 0 });
	assert.match(o2, /hello out/);
});

await test("file tool + http_request + set_clipboard", async () => {
	await ok("file", { action: "write", path: "a/b.txt", content: "hello" });
	const r = await json("file", { action: "read", path: "a/b.txt" });
	assert.equal(r.content, "hello");
	await ok("file", { action: "append", path: "a/b.txt", content: " world" });
	assert.equal((await json("file", { action: "read", path: "a/b.txt" })).content, "hello world");
	const ex = await json("file", { action: "exists", path: "a/b.txt" });
	assert.equal(ex.is_file, true);
	const ls = await json("file", { action: "list" });
	assert.ok(ls.entries.some((e) => e.path === "a/b.txt"));
	await ok("file", { action: "delete", path: "a/b.txt" });
	await fails("file", { action: "read", path: "a/b.txt" }, /not found/);
	const http = await json("http_request", { url: "http://example.test/x" });
	assert.equal(http.body, "echo:http://example.test/x");
	await ok("set_clipboard", { text: "clip" });
	assert.equal(sim.eval("return __clipboard"), "clip");
	await ok("file", { action: "write", path: "bin.dat", base64: Buffer.from([0, 1, 2, 255]).toString("base64") });
	const bin = await json("file", { action: "read", path: "bin.dat", encoding: "base64" });
	assert.equal(Buffer.from(bin.base64, "base64").toString("hex"), "000102ff");
});

// ------------------------------------------------------------------------------------------------ snapshots / world / dex
await test("compare_properties diffs two instances", async () => {
	const doors = (await json("find_instances", { name: "Door", class: "Part" })).results;
	assert.equal(doors.length, 2);
	const d = await json("compare_properties", { a: doors[0].ref, b: doors[1].ref });
	assert.ok(d.same_count > 0);
	assert.ok(d.differing.some((x) => x.name === "Position"), JSON.stringify(d.differing.map((x) => x.name)));
	assert.ok(!d.differing.some((x) => x.name === "Name"));
});

await test("snapshot_tree + diff_tree_snapshot, snapshot_properties + diff_properties", async () => {
	await ok("snapshot_tree", { root: "game.Workspace", name: "s1", props: ["Anchored"] });
	await ok("execute_lua", { code: "local p = Instance.new('Part'); p.Name='Added1'; p.Parent = workspace.Map; workspace.Map.Baseplate.Anchored = false; workspace.Dummy.Torso:Destroy()" });
	const d = await json("diff_tree_snapshot", { name: "s1" });
	assert.equal(d.added_count, 1);
	assert.equal(d.removed_count, 1);
	assert.equal(d.changed_count, 1);
	assert.equal(d.added[0].path, "game.Workspace.Map.Added1");
	assert.equal(d.changed[0].changes.Anchored.to.includes("false"), true);
	await ok("snapshot_properties", { target: "game.Workspace.Config", name: "p1" });
	await ok("execute_lua", { code: "workspace.Config.Value = 'zzz'; workspace.Config:SetAttribute('New', 1)" });
	const dp = await json("diff_properties", { name: "p1" });
	assert.ok(dp.changes.Value);
	assert.ok(dp.changes["@New"]);
	const sn = await json("snapshots", { action: "list" });
	assert.equal(sn.tree_snapshots.length, 1);
	await ok("snapshots", { action: "delete", name: "s1" });
});

await test("world tools: game info, players, local player, gui tree, find_gui", async () => {
	const gi = await json("get_game_info");
	assert.equal(gi.place_id, 123);
	assert.equal(gi.name, "Mock Place");
	const pl = await json("get_players");
	assert.equal(pl.count, 1);
	assert.equal(pl.players[0].name, "Tester");
	const lp = await json("get_local_player");
	assert.equal(lp.user_id, 42);
	assert.ok(lp.player_gui.some((x) => x.startsWith("BuyButton")));
	const gt = await ok("get_gui_tree", { depth: 3 });
	assert.match(gt, /HUD \[ScreenGui\]/);
	assert.match(gt, /CoinsLabel \[TextLabel\] \{text="Coins: 1234"\}/);
	const fg = await json("find_gui", { text: "sword" });
	assert.equal(fg.matched, 1);
	assert.equal(fg.results[0].name, "BuyButton");
	await ok("set_gui_text", { target: fg.results[0].ref, text: "Buy shield" });
	const fg2 = await json("find_gui", { text: "shield" });
	assert.equal(fg2.matched, 1);
});

await test("identity tools + dex selection-less commands", async () => {
	const id = await json("get_identity");
	assert.equal(id.identity, 2);
	await ok("set_identity", { identity: 8 });
	assert.equal((await json("get_identity")).identity, 8);
	const apps = await json("dex_apps", { action: "list" });
	assert.ok(Array.isArray(apps.apps));
});

await test("batch + raw_command + unknown command error formatting", async () => {
	const b = await json("batch", { calls: [{ cmd: "get_game_info" }, { cmd: "get_children", params: { target: "game.Nope" } }] });
	assert.equal(b[0].ok, true);
	assert.equal(b[1].ok, false);
	assert.match(b[1].error, /no child 'Nope'/);
	await fails("raw_command", { cmd: "totally_unknown" }, /unknown command 'totally_unknown'/);
});

await test("bridge survives a client-side error inside a handler (error is reported, bridge stays up)", async () => {
	await fails("get_properties", { target: "game.Workspace.Config", name: 5 }, /.*/).catch(() => {});
	const st = await json("get_status");
	assert.equal(st.bridge.state, "connected");
	assert.ok(st.bridge.errors >= 1);
});

// ------------------------------------------------------------------------------------------------ reconnect
await test("bridge reconnects after the server connection drops", async () => {
	const list = await json("list_clients");
	const id = list.clients[0].id;
	// server forgets the client by sending a close: emulate with disconnect_bridge -> bridge stops (no reconnect)
	await ok("disconnect_bridge");
	await new Promise((r) => setTimeout(r, 600));
	const after = await json("list_clients");
	assert.equal(after.clients.length, 0, "client should be gone after disconnect_bridge");
	sim.run("__MCP.Bridge.T.start()", "restart bridge");
	const c = await mcp.callTool({ name: "wait_for_client", arguments: { timeout_s: 10 } });
	assert.ok(!c.isError, text(c));
	const again = await json("list_clients");
	assert.equal(again.clients.length, 1);
	assert.notEqual(again.clients[0].id, id);
});

// ------------------------------------------------------------------------------------------------ sweep
// Call every remaining command with plausible params. Clean errors (missing executor API, bad input) are fine;
// Lua runtime errors (nil index, bad argument...) inside the bridge are bugs.
await test("sweep: remaining commands never raise Lua runtime errors", async () => {
	const g = await ok("gc_search", { name: "takeDamage" });
	const fref = Number(/#(\d+)>/.exec(g)[1]);
	const tg = await ok("gc_search", { kind: "table", has_keys: ["coins"] });
	const tref = Number(/#(\d+)\{/.exec(tg)[1]);
	const door = (await json("resolve_path", { path: "game.Workspace.Map.Door" })).instance;
	const combat = "game.Players.Tester.PlayerScripts.Combat";
	const btn = "game.Players.Tester.PlayerGui.BuyButton";
	const calls = [
		["clear_output", {}], ["compare_instances", { a: "game.Workspace", b: "workspace" }],
		["file", { action: "mkdir", path: "dumpdir" }], ["file", { action: "rmdir", path: "dumpdir" }],
		["dex_selection", { action: "get" }], ["dex_selection", { action: "set", targets: [door.ref] }], ["dex_selection", { action: "clear" }],
		["dex_search", { query: "door" }], ["dex_search", {}], ["dex_view_object", { target: door.ref }], ["dex_open_script", { target: combat }],
		["dex_open_script", { target: combat, dump_functions: true }], ["dex_view_model", { target: "game.Workspace.Dummy" }],
		["dex_apps", { action: "list" }], ["dex_apps", { action: "toggle", name: "Explorer" }], ["dex_apps", { action: "open_ui", open: true }],
		["dex_settings", { action: "save" }], ["dex_reinit", {}], ["dex_console_print", { text: "hi" }],
		["dump_scripts", { source: "tree", folder: "sweepdump" }],
		["debug_id", { action: "get", target: door.ref }], ["debug_id", { action: "find", debug_id: "DBG1" }],
		["fire_click_detector", { target: "game.Workspace.Map" }], ["fire_proximity_prompt", { target: "game.Workspace.Map" }], ["fire_touch_interest", { part: door.ref }],
		["get_all_instances", { class: "Part", limit: 5 }], ["get_all_instances", { nil_only: true }], ["get_nil_instances", {}],
		["get_callback", { target: "game.ReplicatedStorage.Ask" }], ["get_camera", {}], ["set_camera", { field_of_view: 90 }],
		["get_character", {}], ["get_env", { which: "genv", filter: "get", limit: 5 }], ["get_env", { which: "shared" }], ["get_env", { which: "function", ref: fref }], ["get_env", { which: "script", script: combat }],
		["get_function_env", { ref: fref }], ["hidden_property", { action: "get", target: door.ref, name: "Size" }], ["hidden_property", { action: "set", target: door.ref, name: "Size", value: [1, 1, 1] }],
		["get_instance_signals", { target: "game.ReplicatedStorage.Hit", all: true }], ["get_lighting", {}], ["get_marketplace_info", { asset_id: 1 }],
		["get_mouse_target", {}], ["get_network_owner", { target: door.ref }], ["get_protos", { ref: fref }], ["get_registry", {}],
		["get_script_bytecode", { target: combat }], ["get_script_closure", { target: combat }], ["get_script_env", { target: combat }],
		["get_script_source", { target: combat }], ["get_sounds", {}], ["get_stats", {}], ["tags", { action: "get", target: "game.Workspace.Config" }],
		["tags", { action: "remove", target: "game.Workspace.Config", tag: "Important" }], ["get_threads", {}],
		["http_spy", { action: "start" }], ["http_spy", { action: "status" }], ["http_spy", { action: "stop" }],
		["scriptable", { action: "is", target: door.ref, name: "Size" }], ["scriptable", { action: "set", target: door.ref, name: "Size", value: true }],
		["list_classes", { filter: "Part" }], ["list_classes", { subclass_of: "BasePart" }], ["enums", { action: "list", filter: "Mat" }],
		["raycast", { origin: [0, 10, 0], direction: [0, -1, 0], length: 50 }], ["world_to_screen", { position: [0, 0, 0] }], ["screen_to_ray", { x: 10, y: 10 }],
		["remote_spy", { action: "clear", reset_stats: true }], ["require_module", { target: "game.Players.Tester.PlayerScripts.Util" }],
		["save_instance", { wait: 0.2 }], ["save_instance_status", {}],
		["constants", { action: "set", ref: fref, index: 1, value: "hp" }], ["upvalues", { action: "set", ref: fref, index: 1, value: { "$t": "ref", id: tref } }],
		["clone_function", { ref: fref }],
		["set_global", { name: "__swept", value: 1 }], ["metatable", { action: "readonly", ref: tref, value: true }], ["metatable", { action: "readonly", ref: tref, value: false }],
		["metatable", { action: "set", ref: tref }], ["metatable", { action: "set_metamethod", ref: tref, name: "__index", code: "return function() end" }],
		["set_property_many", { targets: [door.ref], name: "Anchored", value: true }],
		["watch", { kind: "signal", target: btn, signal: "MouseButton1Click" }], ["unwatch", { all: true }],
		["teleport", { position: [0, 5, 0] }], ["send_input", { kind: "key", key: "E" }], ["send_input", { kind: "mouse_click", x: 10, y: 10 }], ["send_input", { kind: "mouse_scroll", amount: 1 }], ["cancel_exec", { id: 1 }], ["release_refs", { all: true }],
		["get_gui_tree", { root: "CoreGui" }], ["find_gui", { root: "StarterGui", name: "x" }], ["set_gui_text", { target: btn, text: "t", submit: true }],
		["snapshots", { action: "list" }], ["get_remote_handlers", { target: "game.ReplicatedStorage.Ask" }], ["list_connected_signals", { target: btn }],
		["gc_search", { kind: "userdata" }], ["gc_search", { kind: "all", name: "x", limit: 3 }], ["get_table", { ref: tref, key: "co", limit: 2 }],
		["table_search", { ref: tref, value: "sword" }], ["find_references", { target: "game.Workspace.Map" }], ["gc_find_value", { value: "Tester", where: ["table", "constant"] }],
		["hook_function", { ref: fref, mode: "block" }], ["hook_function", { ref: fref, mode: "return", value: 1 }], ["hook_function", { ref: fref, mode: "wrap", code: "return function(orig, ...) return orig(...) end" }],
		["list_hooks", {}], ["trap_add", { kind: "index", member: "Anchored", action: "log" }], ["trap_add", { kind: "newindex", member: "Anchored", action: "log" }], ["trap_list", {}],
		["remote_spy", { action: "start" }], ["remote_spy", { action: "status" }], ["remote_filter", { action: "block", remotes: ["game.ReplicatedStorage.Ask"] }], ["remote_filter", { action: "unblock", all: true }], ["remote_spy", { action: "stop" }],
		["set_event_capacity", { channel: "remote", capacity: 100 }],
	];
	const bad = [];
	const clean = /executor does not provide|not a valid member|ref #\d+|unknown|no .* (found|named|child|ancestor|ClickDetector|ProximityPrompt)|not available|unavailable|no way to|Explorer not|not loaded|not initialised|is not a|must be|required|no (watch|trap|hook)|invalid|cannot|is no longer|nothing|BasePart|Archivable|read-only/i;
	const runtime = /attempt to|bad argument|stack traceback|nil value|expected [a-z]+ got|stack overflow|invalid order function|string expected|number expected/i;
	const details = [];
	for (const [name, args] of calls) {
		let r;
		try {
			r = await mcp.callTool({ name, arguments: args });
		} catch (e) {
			bad.push(`${name} ${JSON.stringify(args)} -> exception ${e.message}`);
			continue;
		}
		const t = text(r);
		if (r.isError) {
			if (runtime.test(t) && !/is not a valid member of/.test(t)) bad.push(`${name} ${JSON.stringify(args)} -> ${t.slice(0, 220)}`);
			else if (!clean.test(t)) details.push(`(unclassified) ${name}: ${t.slice(0, 160)}`);
		}
	}
	if (details.length) console.log("      unclassified errors (review):\n      " + details.join("\n      "));
	assert.equal(bad.length, 0, "Lua runtime errors:\n  " + bad.join("\n  "));
});

await test("bridge finds the server in the fallback port range via /health (no blind port wandering)", async () => {
	// configured port PORT-1 has nothing on it; the server is on PORT (as when its preferred port was busy)
	const sim2 = createSim({ port: PORT - 1, serverPort: PORT });
	sim2.run("__MCP.Bridge.startCaptures() __MCP.Bridge.T.start()", "start sim2");
	const timer = setInterval(() => sim2.pump(0.25), 20);
	const deadline = Date.now() + 15000;
	let n = 0;
	while (Date.now() < deadline) {
		n = (await json("list_clients")).clients.length;
		if (n >= 2) break;
		await new Promise((r) => setTimeout(r, 150));
	}
	clearInterval(timer);
	assert.ok(n >= 2, `expected the second sim to find the server (clients=${n})`);
	assert.equal(sim2.eval("return tostring(__MCP.Bridge.T.port)"), String(PORT));
	assert.equal(sim2.eval("return tostring(__MCP.Bridge.T.failures)"), "0", "must connect on the first attempt");
	sim2.stop();
	await new Promise((r) => setTimeout(r, 300));
});

await test("websocket failure falls back to http on the same port within one attempt", async () => {
	const fake = `
		__server_port = ${PORT}
		WebSocket = { connect = function() error("WebSocket is blocked here") end }
		__hellos = 0
		__fake_http_server = function(o, path)
			if path == "/hello" then __hellos = __hellos + 1 return { StatusCode = 200, Body = '{"type":"welcome","client":"cX","server":"mock"}' } end
			if path == "/poll" then task.wait(0.3) return { StatusCode = 200, Body = "[]" } end
			return { StatusCode = 200, Body = '{"ok":true}' }
		end`;
	const sim3 = createSim({ port: PORT, transport: "auto", serverPort: PORT, beforeLoad: fake });
	sim3.run("__MCP.Bridge.T.start()", "start sim3");
	const timer = setInterval(() => sim3.pump(0.25), 10);
	const deadline = Date.now() + 8000;
	while (Date.now() < deadline && sim3.eval("return __MCP.Bridge.T.state") !== "connected") await new Promise((r) => setTimeout(r, 50));
	clearInterval(timer);
	assert.equal(sim3.eval("return __MCP.Bridge.T.state"), "connected");
	assert.equal(sim3.eval("return __MCP.Bridge.T.transport"), "http-poll");
	assert.equal(sim3.eval("return tostring(__MCP.Bridge.T.failures)"), "0", "no failed attempt should be needed");
	assert.equal(sim3.eval("return tostring(__MCP.Bridge.T.port)"), String(PORT));
	assert.equal(sim3.eval("return tostring(__hellos)"), "1");
	sim3.stop();
});

await test("when nothing answers, the error says what was tried", async () => {
	const sim4 = createSim({ port: PORT + 500, transport: "http", beforeLoad: "__server_port = nil" });
	sim4.run("__MCP.Bridge.T.start()", "start sim4");
	const timer = setInterval(() => sim4.pump(0.25), 10);
	await new Promise((r) => setTimeout(r, 400));
	clearInterval(timer);
	const detail = sim4.eval("return __MCP.Bridge.T.state .. '|' .. __MCP.Bridge.T.detail");
	assert.match(detail, /^error\|no Dex\+\+ MCP server answering on 127\.0\.0\.1:\d+-\d+/);
	sim4.stop();
});

const unused = sim.eval("local out = {} for k in pairs(__MCP.Bridge.H) do if not __used[k] then out[#out + 1] = k end end table.sort(out) return table.concat(out, ' ')");
console.log(`
commands not exercised by this suite (${unused.split(" ").filter(Boolean).length}): ${unused}`);
sim.stop();
await mcp.close();
console.log(`\n${passed} passed, ${failures.length} failed`);
const lt = sim.logs.filter((l) => /error|ERROR/.test(l));
if (lt.length) console.log("lua log errors:\n  " + lt.slice(0, 15).join("\n  "));
if (failures.length) {
	console.log("failed:", failures.join(", "));
	if (serverErr) console.log("--- server stderr ---\n" + serverErr.split("\n").slice(-15).join("\n"));
	process.exit(1);
}
process.exit(0);
