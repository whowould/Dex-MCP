// A fake Dex++ client (what the Lua bridge does) used to exercise the server end to end.
import WebSocket from "ws";
import http from "node:http";

export function mockHandlers() {
	const calls = [];
	const handlers = {
		get_status: () => ({ bridge: { state: "connected" }, executor: "MockExec 1.0", game: { place_id: 1 }, dex_version: "3.0" }),
		get_children: (p) => ({ parent: { "$t": "Instance", class: "Workspace", name: "Workspace", path: "game.Workspace", ref: 1 }, total_children: 2, matched: 2, returned: 2, children: [{ ref: 2, class: "Part", name: "A", children: 0 }, { ref: 3, class: "Folder", name: "B", children: 4 }] }),
		get_tree: () => ({ tree: "Workspace [Workspace]\n  Part [Part]\n  Folder [Folder]  (+4 children)", nodes: 2, truncated: false }),
		decompile_script: (p) => ({ script: { path: "game.StarterPlayer.Foo", class: "LocalScript", ref: 9 }, cached: false, elapsed: 0.12, total_chars: 20, total_lines: 2, offset: p.offset ?? 0, returned_chars: 20, source: "print('hi')\nreturn 1\n" }),
		set_attribute: (p) => ({ ok: true, value: p.value }),
		get_events: (p) => ({
			events: [
				{ seq: 5, ch: "remote", t: 1700000000.5, key: "game.ReplicatedStorage.Hit:FireServer", remote: "game.ReplicatedStorage.Hit", remote_ref: 4, class: "RemoteEvent", method: "FireServer", dir: "out", args: ["sword", { "$t": "Vector3", v: [1, 2, 3] }, { "$t": "Instance", class: "Part", path: "game.Workspace.Dummy", ref: 7 }], script: "game.Players.Me.PlayerScripts.Combat" },
				{ seq: 6, ch: "remote", t: 1700000001, key: "game.ReplicatedStorage.Ask:InvokeServer", remote: "game.ReplicatedStorage.Ask", remote_ref: 5, class: "RemoteFunction", method: "InvokeServer", dir: "out", args: [42], results: [true, { "$t": "table", ref: 11, count: 2, fields: { a: 1, b: "x" } }] },
			],
			returned: 2, matched: 2, last_seq: 6, current_seq: 6,
		}),
		remote_spy_get: () => handlers.get_events({}),
		get_exec_result: () => ({ id: 1, done: true, ok: true, elapsed: 0.01, output: [{ level: "info", text: "hello" }], results: [{ "$t": "function", ref: 3, name: "foo", line: 10, lua_closure: true }] }),
		execute_lua: () => ({ id: 2, done: true, ok: true, elapsed: 0.02, output: [{ level: "warn", text: "careful" }], results: [42, "str"], result_count: 2 }),
		big: () => ({ blob: "x".repeat(700000) }),
		boom: () => { throw new Error("kaboom"); },
		list_scripts: (p) => ({ total: 2, returned: 2, scripts: [{ ref: 20, class: "LocalScript", name: "A", path: "game.StarterPlayer.A", full_name: "StarterPlayer.A" }, { ref: 21, class: "ModuleScript", name: "B", path: "game.StarterPlayer.B", full_name: "StarterPlayer.B" }] }),
	};
	return { handlers, calls };
}

export const SILENT = Symbol("silent");

function runHandler(handlers, calls, msg) {
	calls.push({ cmd: msg.cmd, params: msg.params });
	const h = handlers[msg.cmd];
	if (!h) return { id: msg.id, ok: false, error: `unknown command '${msg.cmd}'` };
	try {
		const result = h(msg.params ?? {});
		if (result === SILENT) return null;
		return { id: msg.id, ok: true, result, ms: 1 };
	} catch (e) {
		return { id: msg.id, ok: false, error: e.message };
	}
}

const HELLO = { type: "hello", protocol: 1, user: "Tester", user_id: 1, place_id: 123, game_id: 456, job_id: "job", executor: "MockExec 1.0", dex_version: "3.0", capabilities: ["getgc"] };

export async function connectWs(port, token) {
	const { handlers, calls } = mockHandlers();
	const ws = new WebSocket(`ws://127.0.0.1:${port}/ws`);
	await new Promise((res, rej) => { ws.on("open", res); ws.on("error", rej); });
	const welcome = new Promise((res) => {
		ws.once("message", (d) => res(JSON.parse(d.toString())));
	});
	ws.send(JSON.stringify({ ...HELLO, session: "mock-ws-" + Math.random().toString(36).slice(2), token }));
	const w = await welcome;
	ws.on("message", (d) => {
		const msg = JSON.parse(d.toString());
		if (!msg.cmd) return;
		const reply = runHandler(handlers, calls, msg);
		if (!reply) return;
		const payload = JSON.stringify(reply);
		const FRAME = 200000;
		if (payload.length <= FRAME) ws.send(payload);
		else {
			const n = Math.ceil(payload.length / FRAME);
			for (let i = 1; i <= n; i++) ws.send(JSON.stringify({ id: msg.id, chunk: i, of: n, data: payload.slice((i - 1) * FRAME, i * FRAME) }));
		}
	});
	return { ws, welcome: w, handlers, calls, close: () => ws.close() };
}

function httpReq(port, method, path, body) {
	return new Promise((resolve, reject) => {
		const req = http.request({ host: "127.0.0.1", port, method, path, headers: body ? { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(body) } : {} }, (res) => {
			const chunks = [];
			res.on("data", (c) => chunks.push(c));
			res.on("end", () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString() }));
		});
		req.on("error", reject);
		if (body) req.write(body);
		req.end();
	});
}

export async function connectHttp(port) {
	const { handlers, calls } = mockHandlers();
	const r = await httpReq(port, "POST", "/hello", JSON.stringify({ ...HELLO, session: "mock-http-" + Math.random().toString(36).slice(2) }));
	const welcome = JSON.parse(r.body);
	let running = true;
	const loop = (async () => {
		while (running) {
			const pr = await httpReq(port, "GET", `/poll?client=${welcome.client}`);
			if (pr.status !== 200) break;
			for (const msg of JSON.parse(pr.body)) {
				const reply = runHandler(handlers, calls, msg);
				if (!reply) continue;
				await httpReq(port, "POST", `/result?client=${welcome.client}&id=${msg.id}`, JSON.stringify(reply));
			}
		}
	})();
	return { welcome, handlers, calls, close: () => { running = false; } , loop };
}
