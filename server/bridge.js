// Bridge: accepts Dex++ clients (WebSocket, or HTTP long-poll fallback) and lets the MCP layer send them commands.
import http from "node:http";
import { WebSocketServer } from "ws";

export const PROTOCOL = 1;
export const SERVER_NAME = "dexpp-mcp";
export const SERVER_VERSION = "1.0.0";

export class NoClientError extends Error {}
export class LuaError extends Error {
	constructor(message, cmd) {
		super(message);
		this.cmd = cmd;
	}
}

class Client {
	constructor(id, info, transport) {
		this.id = id;
		this.info = info;
		this.transport = transport; // "websocket" | "http-poll"
		this.connectedAt = Date.now();
		this.lastSeen = Date.now();
		this.pending = new Map();
		this.chunks = new Map();
		this.ws = null;
		this.queue = []; // http: commands waiting for the next poll
		this.poller = null; // http: held poll response
		this.closed = false;
	}

	label() {
		const i = this.info;
		return `${this.id} (${i.user ?? "?"} @ place ${i.place_id ?? "?"}, ${i.executor ?? "?"}, ${this.transport})`;
	}

	describe() {
		const i = this.info;
		return {
			id: this.id,
			user: i.user,
			user_id: i.user_id,
			place_id: i.place_id,
			game_id: i.game_id,
			job_id: i.job_id,
			executor: i.executor,
			dex_version: i.dex_version,
			identity: i.identity,
			transport: this.transport,
			connected_for_s: Math.round((Date.now() - this.connectedAt) / 1000),
			last_seen_s_ago: Math.round((Date.now() - this.lastSeen) / 1000),
			pending_requests: this.pending.size,
			capabilities: i.capabilities,
		};
	}

	send(msg) {
		if (this.closed) throw new NoClientError(`client ${this.id} is disconnected`);
		if (this.transport === "websocket") {
			this.ws.send(JSON.stringify(msg));
		} else if (this.poller) {
			const res = this.poller;
			this.poller = null;
			clearTimeout(res.timer);
			respondJson(res.res, [msg]);
		} else {
			this.queue.push(msg);
		}
	}

	failAll(reason) {
		for (const [, p] of this.pending) {
			clearTimeout(p.timer);
			p.reject(new NoClientError(reason));
		}
		this.pending.clear();
	}
}

function respondJson(res, body, status = 200) {
	const data = JSON.stringify(body);
	res.writeHead(status, { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) });
	res.end(data);
}

function readBody(req, limit = 64 * 1024 * 1024) {
	return new Promise((resolve, reject) => {
		const chunks = [];
		let size = 0;
		req.on("data", (c) => {
			size += c.length;
			if (size > limit) {
				reject(new Error("body too large"));
				req.destroy();
				return;
			}
			chunks.push(c);
		});
		req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
		req.on("error", reject);
	});
}

export class Bridge {
	constructor({ host = "127.0.0.1", port = 18764, token = "", log = () => {} } = {}) {
		this.host = host;
		this.basePort = port;
		this.port = port;
		this.token = token;
		this.log = log;
		this.clients = new Map();
		this.selected = null;
		this.nextClient = 1;
		this.nextReq = 1;
		this.startedAt = Date.now();
		this.waiters = [];
		this.stats = { commands: 0, errors: 0, timeouts: 0 };
	}

	// Only non-browser local clients (the Roblox executor) may talk to the bridge. Browsers always attach an
	// Origin header, and DNS-rebinding attacks present a foreign Host - both would let a web page forge client
	// replies (and so inject text into the model's tool results), so they are refused outright.
	isLocalRequest(req) {
		if (this.token) return true; // a shared secret authenticates the client instead
		if (req.headers.origin) return false;
		const host = String(req.headers.host ?? "").replace(/:\d+$/, "").toLowerCase();
		return host === "127.0.0.1" || host === "localhost" || host === "[::1]" || host === this.host.toLowerCase();
	}

	async start(maxTries = 10) {
		this.http = http.createServer((req, res) => {
			if (!this.isLocalRequest(req)) {
				this.log(`refused HTTP request (origin=${req.headers.origin ?? "-"}, host=${req.headers.host ?? "-"})`);
				return respondJson(res, { error: "forbidden: browser Origin or non-local Host refused (set DEXMCP_TOKEN to authenticate instead)" }, 403);
			}
			this.onHttp(req, res).catch((e) => {
				this.log(`http error: ${e.message}`);
				try { respondJson(res, { error: String(e.message) }, 500); } catch {}
			});
		});
		this.wss = new WebSocketServer({ noServer: true, maxPayload: 256 * 1024 * 1024 });
		this.http.on("upgrade", (req, socket, head) => {
			const url = new URL(req.url, "http://x");
			if (url.pathname !== "/ws" || !this.isLocalRequest(req)) {
				if (url.pathname === "/ws") this.log(`refused WebSocket upgrade (origin=${req.headers.origin ?? "-"}, host=${req.headers.host ?? "-"})`);
				socket.destroy();
				return;
			}
			this.wss.handleUpgrade(req, socket, head, (ws) => this.onWs(ws));
		});

		let lastErr;
		for (let i = 0; i < maxTries; i++) {
			const port = this.basePort + i;
			try {
				await new Promise((resolve, reject) => {
					const onErr = (e) => reject(e);
					this.http.once("error", onErr);
					this.http.listen(port, this.host, () => {
						this.http.off("error", onErr);
						resolve();
					});
				});
				this.port = port;
				this.http.on("error", (e) => this.log(`server error: ${e.message}`));
				return port;
			} catch (e) {
				lastErr = e;
				if (e.code !== "EADDRINUSE") throw e;
				this.log(`port ${port} in use, trying ${port + 1}`);
			}
		}
		throw lastErr;
	}

	async stop() {
		for (const c of this.clients.values()) this.dropClient(c, "server shutting down");
		this.wss?.close();
		await new Promise((r) => this.http?.close(() => r()));
	}

	// ----- client registry -----
	registerClient(info, transport) {
		// same session reconnecting replaces the stale entry
		for (const c of this.clients.values()) {
			if (info.session && c.info.session === info.session) this.dropClient(c, "replaced by a new connection from the same session");
		}
		const id = `c${this.nextClient++}`;
		const client = new Client(id, info, transport);
		this.clients.set(id, client);
		this.log(`client connected: ${client.label()}`);
		const w = this.waiters.splice(0);
		for (const fn of w) fn(client);
		return client;
	}

	dropClient(client, reason = "disconnected") {
		if (client.closed) return;
		client.closed = true;
		this.clients.delete(client.id);
		client.failAll(`Roblox client ${client.id} ${reason}. Calls in flight were lost; the bridge will reconnect automatically if Dex++ is still running.`);
		if (client.poller) {
			clearTimeout(client.poller.timer);
			try { respondJson(client.poller.res, []); } catch {}
		}
		if (client.ws && client.ws.readyState <= 1) {
			try { client.ws.close(); } catch {}
		}
		if (this.selected === client.id) this.selected = null;
		this.log(`client dropped: ${client.id} (${reason})`);
	}

	list() {
		return [...this.clients.values()].map((c) => ({ ...c.describe(), selected: c.id === this.selected }));
	}

	select(spec) {
		const c = this.find(spec);
		this.selected = c.id;
		return c;
	}

	find(spec) {
		if (spec == null) {
			const sel = this.selected ? this.clients.get(this.selected) : null;
			if (sel) return sel;
			if (this.clients.size === 0) throw new NoClientError(this.noClientMessage());
			return [...this.clients.values()].at(-1);
		}
		const s = String(spec).toLowerCase();
		for (const c of this.clients.values()) {
			if (c.id.toLowerCase() === s) return c;
		}
		for (const c of this.clients.values()) {
			if (String(c.info.user ?? "").toLowerCase() === s || String(c.info.session ?? "").toLowerCase().startsWith(s) || String(c.info.place_id) === s) return c;
		}
		throw new NoClientError(`no connected client matches '${spec}'. Connected: ${[...this.clients.values()].map((c) => c.label()).join("; ") || "none"}`);
	}

	noClientMessage() {
		return (
			`No Roblox client is connected to the Dex++ bridge (listening on ${this.host}:${this.port}). ` +
			`Run the patched dexplusplus.lua in your executor; the "MCP" window in Dex++ shows the connection status. ` +
			`If the bridge is on a different port, set it in that window (Host/Port) or restart with DEXMCP_PORT.`
		);
	}

	waitForClient(timeoutMs) {
		if (this.clients.size > 0) return Promise.resolve(this.find(null));
		return new Promise((resolve, reject) => {
			const timer = setTimeout(() => {
				const i = this.waiters.indexOf(fn);
				if (i >= 0) this.waiters.splice(i, 1);
				reject(new NoClientError(this.noClientMessage()));
			}, timeoutMs);
			const fn = (c) => {
				clearTimeout(timer);
				resolve(c);
			};
			this.waiters.push(fn);
		});
	}

	// ----- commands -----
	call(cmd, params = {}, { client, timeoutMs = 30000 } = {}) {
		const c = this.find(client);
		const id = this.nextReq++;
		this.stats.commands++;
		return new Promise((resolve, reject) => {
			const timer = setTimeout(() => {
				c.pending.delete(id);
				this.stats.timeouts++;
				reject(new LuaError(`'${cmd}' timed out after ${timeoutMs}ms on ${c.id}. The command may still be running in the game; long operations accept a time_budget/timeout parameter.`, cmd));
			}, timeoutMs);
			c.pending.set(id, { resolve, reject, timer, cmd });
			try {
				c.send({ id, cmd, params });
			} catch (e) {
				clearTimeout(timer);
				c.pending.delete(id);
				reject(e);
			}
		});
	}

	onReply(client, msg) {
		client.lastSeen = Date.now();
		const p = client.pending.get(msg.id);
		if (!p) return;
		client.pending.delete(msg.id);
		clearTimeout(p.timer);
		if (msg.ok) {
			p.resolve({ result: msg.result, ms: msg.ms });
		} else {
			this.stats.errors++;
			p.reject(new LuaError(String(msg.error ?? "unknown error"), p.cmd));
		}
	}

	handleClientMessage(client, text) {
		let msg;
		try {
			msg = JSON.parse(text);
		} catch (e) {
			this.log(`bad JSON from ${client.id}: ${e.message}`);
			return;
		}
		if (msg.chunk !== undefined) {
			let entry = client.chunks.get(msg.id);
			if (!entry) {
				entry = { parts: new Array(msg.of), got: 0 };
				client.chunks.set(msg.id, entry);
			}
			if (entry.parts[msg.chunk - 1] === undefined) {
				entry.parts[msg.chunk - 1] = msg.data;
				entry.got++;
			}
			if (entry.got === msg.of) {
				client.chunks.delete(msg.id);
				this.handleClientMessage(client, entry.parts.join(""));
			}
			return;
		}
		if (msg.type === "pong") {
			client.lastSeen = Date.now();
			return;
		}
		if (msg.id !== undefined) this.onReply(client, msg);
	}

	// ----- websocket -----
	onWs(ws) {
		let client = null;
		const helloTimer = setTimeout(() => {
			if (!client) {
				try { ws.send(JSON.stringify({ type: "error", error: "hello expected within 10s" })); } catch {}
				ws.close();
			}
		}, 10000);
		ws.on("message", (data) => {
			const text = data.toString("utf8");
			if (!client) {
				let hello;
				try {
					hello = JSON.parse(text);
				} catch {
					ws.close();
					return;
				}
				if (hello.type !== "hello") {
					ws.close();
					return;
				}
				if (this.token && hello.token !== this.token) {
					ws.send(JSON.stringify({ type: "error", error: "bad token (set Settings.MCP.Token to match DEXMCP_TOKEN)" }));
					this.log("rejected client: bad token");
					ws.close();
					return;
				}
				clearTimeout(helloTimer);
				client = this.registerClient(hello, "websocket");
				client.ws = ws;
				ws.send(JSON.stringify({ type: "welcome", client: client.id, server: `${SERVER_NAME} ${SERVER_VERSION}`, protocol: PROTOCOL }));
				return;
			}
			this.handleClientMessage(client, text);
		});
		ws.on("close", () => {
			clearTimeout(helloTimer);
			if (client) this.dropClient(client, "disconnected (socket closed)");
		});
		ws.on("error", (e) => this.log(`ws error: ${e.message}`));
	}

	// ----- http long-poll fallback -----
	async onHttp(req, res) {
		const url = new URL(req.url, "http://x");
		const route = `${req.method} ${url.pathname}`;

		if (route === "GET /" || route === "GET /health") {
			return respondJson(res, { server: SERVER_NAME, version: SERVER_VERSION, protocol: PROTOCOL, clients: this.list(), uptime_s: Math.round((Date.now() - this.startedAt) / 1000), stats: this.stats });
		}

		if (route === "POST /hello") {
			this.log(`http hello from ${req.socket.remoteAddress}`);
			const hello = JSON.parse(await readBody(req));
			if (this.token && hello.token !== this.token) return respondJson(res, { type: "error", error: "bad token" }, 200);
			const client = this.registerClient(hello, "http-poll");
			return respondJson(res, { type: "welcome", client: client.id, server: `${SERVER_NAME} ${SERVER_VERSION}`, protocol: PROTOCOL });
		}

		const clientId = url.searchParams.get("client");
		const client = clientId ? this.clients.get(clientId) : null;
		if (!client) return respondJson(res, { error: "unknown client, send /hello first" }, 404);
		client.lastSeen = Date.now();

		if (route === "GET /poll") {
			if (client.queue.length) {
				const batch = client.queue.splice(0);
				return respondJson(res, batch);
			}
			if (client.poller) {
				// a second poll replaces the first
				clearTimeout(client.poller.timer);
				respondJson(client.poller.res, []);
			}
			const timer = setTimeout(() => {
				if (client.poller && client.poller.res === res) client.poller = null;
				respondJson(res, []);
			}, 8000); // short enough for executors whose request() times out around 10s
			client.poller = { res, timer };
			req.on("close", () => {
				if (client.poller && client.poller.res === res) {
					clearTimeout(timer);
					client.poller = null;
				}
			});
			// if the client stops polling for a while it is considered gone
			clearTimeout(client.idleTimer);
			return;
		}

		if (route === "POST /result") {
			const body = await readBody(req);
			this.handleClientMessage(client, body);
			return respondJson(res, { ok: true });
		}

		respondJson(res, { error: "not found" }, 404);
	}

	// http clients that stop polling are dropped
	sweep() {
		const now = Date.now();
		for (const c of [...this.clients.values()]) {
			if (c.transport === "http-poll" && now - c.lastSeen > 45000) this.dropClient(c, "stopped polling");
		}
	}
}
