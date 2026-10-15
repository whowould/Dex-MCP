// Session/meta tools: clients, status, events, refs, raw commands, batch, export
import fs from "node:fs";
import path from "node:path";
import { z, target, optTarget, ref, limit, nameMode, timeBudget } from "./common.js";
import { fmtEvents, fmtJson, truncate } from "../format.js";
import { SERVER_NAME, SERVER_VERSION, PROTOCOL } from "../bridge.js";
import { disassemble, formatListing } from "../luau.js";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function safeSeg(s) {
	return String(s).replace(/[<>:"/\\|?*\x00-\x1f]/g, "_").replace(/^\.+$/, "_").slice(0, 100) || "_";
}

export function register({ tool }, ctx) {
	const { bridge } = ctx;

	// ---------------------------------------------------------------- clients
	tool("list_clients", "List Roblox clients connected to the bridge (user, place, executor, transport). Most tools act on the selected/most recent client; pass `client` to target another.", {}, {
		run: async () => fmtJson({ clients: bridge.list(), listening: `${bridge.host}:${bridge.port}`, token_required: Boolean(bridge.token) }),
		ro: true,
	});

	tool("select_client", "Choose which connected client later tool calls default to (by id like c2, username or place id).", { client: z.string() }, {
		run: async ({ client }) => {
			const c = bridge.select(client);
			return `Selected ${c.label()}`;
		},
	});

	tool("wait_for_client", "Wait until a Roblox client connects to the bridge (e.g. right after launching the executor script).", { timeout_s: z.number().positive().optional().describe("Default 60.") }, {
		run: async ({ timeout_s }) => {
			const c = await bridge.waitForClient((timeout_s ?? 60) * 1000);
			return `Connected: ${c.label()}`;
		},
		ro: true,
	});

	tool("server_info", "Bridge/server details: listening address, protocol, clients, call statistics, tool count.", {}, {
		run: async () =>
			fmtJson({
				server: `${SERVER_NAME} ${SERVER_VERSION}`,
				protocol: PROTOCOL,
				listening: `${bridge.host}:${bridge.port}`,
				uptime_s: Math.round((Date.now() - bridge.startedAt) / 1000),
				token_required: Boolean(bridge.token),
				stats: bridge.stats,
				clients: bridge.list(),
				tools: ctx.toolCount(),
			}),
		ro: true,
	});

	tool("get_status", "Status of the connected game client: place/job/user, executor, Dex++ version, thread identity, missing executor capabilities, bridge counters. Also reports round-trip latency.", {}, {
		run: async (_a, { call }) => {
			const t0 = Date.now();
			const { result } = await call("get_status", {});
			result.round_trip_ms = Date.now() - t0;
			result.server = `${SERVER_NAME} ${SERVER_VERSION}`;
			return fmtJson(result);
		},
		ro: true,
	});

	tool("get_capabilities", "Which executor APIs exist (grouped: hooks, debug library, filesystem, network...). Tools that need a missing function return a clear error; use this to plan. `probe` checks extra global names.", { probe: z.array(z.string()).optional() });

	tool("list_commands", "List every command name the Dex++ bridge implements (use with raw_command).", {});

	tool(
		"raw_command",
		"Escape hatch: send any bridge command by name with a params object. Every dedicated tool maps onto one of these; useful for commands added to the Lua side later.",
		{ cmd: z.string(), params: z.record(z.string(), z.any()).optional(), timeout_s: z.number().positive().optional() },
		{
			run: async ({ cmd, params, timeout_s }, { call }) => {
				const { result } = await call(cmd, params ?? {}, (timeout_s ?? 30) * 1000);
				return fmtJson(result);
			},
		},
	);

	tool(
		"batch",
		"Run several bridge commands in one round trip (sequentially, or in parallel with parallel=true). Each item: {cmd, params}. Returns one result per item; one failing item does not stop the others.",
		{ calls: z.array(z.object({ cmd: z.string(), params: z.record(z.string(), z.any()).optional() })).min(1).max(40), parallel: z.boolean().optional(), timeout_s: z.number().positive().optional() },
		{
			run: async ({ calls, parallel, timeout_s }, { call }) => {
				const one = async (c) => {
					try {
						const { result } = await call(c.cmd, c.params ?? {}, (timeout_s ?? 30) * 1000);
						return { cmd: c.cmd, ok: true, result };
					} catch (e) {
						return { cmd: c.cmd, ok: false, error: e.message };
					}
				};
				const out = parallel ? await Promise.all(calls.map(one)) : [];
				if (!parallel) for (const c of calls) out.push(await one(c));
				return fmtJson(out);
			},
		},
	);

	tool("disconnect_bridge", "Tell the game client to drop its bridge connection (it will not reconnect until restarted from the MCP window).", {});

	// ---------------------------------------------------------------- events
	tool(
		"get_events",
		"Read buffered events from the game: channels remote, hook, trap, watch, tree, signal, http, output, error. Each event has a seq; pass the last seq as `since` to tail. (remote_spy_get / get_output are filtered views.)",
		{ channel: z.enum(["remote", "hook", "trap", "watch", "tree", "signal", "http", "output", "error"]).optional().describe("Omit for all channels merged by seq."), since: z.number().int().optional(), limit: limit(100), tail: z.boolean().optional(), match: z.string().optional().describe("Substring of the event key (remote path, instance path, message...)."), match_mode: nameMode },
		{ format: (r) => fmtEvents(r) },
	);

	tool("clear_events", "Drop buffered events (one channel or all).", { channel: z.string().optional() });
	tool("list_event_channels", "Buffer sizes, totals and drop counts per event channel.", {});
	tool("set_event_capacity", "Resize an event channel's ring buffer in the game (default 2000; remote 5000). Raise it for busy remote spying so old calls are not dropped.", { channel: z.string(), capacity: z.number().int().positive() });

	tool(
		"wait_for_events",
		"Block until new events arrive on a channel (or timeout). Use after triggering something in the game: e.g. start remote_spy, ask the user to click, then wait_for_events{channel:'remote'}.",
		{ channel: z.enum(["remote", "hook", "trap", "watch", "tree", "signal", "http", "output", "error"]).optional(), since: z.number().int().optional().describe("Wait for events newer than this seq (default: now)."), match: z.string().optional(), timeout_s: z.number().positive().max(120).optional().describe("Default 20."), settle_ms: z.number().int().optional().describe("After the first event, wait this long to collect more (default 300).") , limit: limit(100) },
		{
			run: async (a, { call }) => {
				const deadline = Date.now() + (a.timeout_s ?? 20) * 1000;
				let since = a.since;
				if (since === undefined) {
					const { result } = await call("get_events", { channel: a.channel, limit: 1 });
					since = result.current_seq ?? 0;
				}
				while (Date.now() < deadline) {
					const { result } = await call("get_events", { channel: a.channel, since, match: a.match, limit: a.limit ?? 100, tail: false });
					if (result.events.length) {
						await sleep(a.settle_ms ?? 300);
						const { result: more } = await call("get_events", { channel: a.channel, since, match: a.match, limit: a.limit ?? 100, tail: false });
						return fmtEvents(more);
					}
					await sleep(400);
				}
				return `-- no events within ${a.timeout_s ?? 20}s (since seq ${since})`;
			},
			ro: true,
		},
	);

	// ---------------------------------------------------------------- refs
	tool("inspect_ref", "Re-serialize any ref (function/table/userdata/instance) with deeper limits.", { ref, depth: z.number().int().optional(), max_items: z.number().int().optional(), max_str: z.number().int().optional() });
	tool("list_refs", "List currently held refs (newest first), optionally by type.", { type: z.string().optional().describe("Instance | function | table | userdata | thread ..."), limit: limit(100) });
	tool("release_refs", "Release refs so they can be garbage collected: specific ids, or all with all=true.", { refs: z.array(z.union([z.number(), z.string()])).optional(), all: z.boolean().optional() }, {
		route: (a) => (a.all ? { cmd: "clear_refs", params: {} } : { cmd: "release_ref", params: { refs: a.refs ?? [] } }),
	});

	// ---------------------------------------------------------------- local-disk tools
	tool(
		"export_scripts",
		"Decompile many scripts and write them to a folder ON THIS COMPUTER (mirrors the game hierarchy), then grep/open them with normal file tools. Resumable: existing files are skipped.",
		{
			dir: z.string().describe("Output directory on the machine running this MCP server."),
			root: optTarget.describe("Only scripts under this instance."),
			source: z.enum(["tree", "getscripts", "running", "modules", "nil"]).optional(),
			class: z.string().optional(),
			name: z.string().optional(),
			name_mode: nameMode,
			include_core: z.boolean().optional(),
			engine: z.enum(["dex", "builtin", "konstant", "shiny", "advanced"]).optional(),
			concurrency: z.number().int().min(1).max(6).optional().describe("Parallel decompiles (default 2)."),
			max_scripts: z.number().int().positive().optional(),
			overwrite: z.boolean().optional(),
		},
		{
			run: async (a, { call }) => {
				const dir = path.resolve(a.dir);
				fs.mkdirSync(dir, { recursive: true });
				const filter = { root: a.root, source: a.source, class: a.class, name: a.name, name_mode: a.name_mode, include_core: a.include_core, viable_only: true };
				const scripts = [];
				let off = 0;
				for (;;) {
					const { result } = await call("list_scripts", { ...filter, offset: off, limit: 500 });
					scripts.push(...result.scripts);
					if (result.next_offset == null || (a.max_scripts && scripts.length >= a.max_scripts)) break;
					off = result.next_offset;
				}
				if (a.max_scripts) scripts.length = Math.min(scripts.length, a.max_scripts);
				const used = new Map();
				const jobs = scripts.map((s) => {
					const segs = String(s.full_name ?? s.name).split(".").map(safeSeg);
					let file = path.join(dir, ...segs.slice(0, -1), `${segs.at(-1)}.${s.class}.lua`);
					const n = used.get(file) ?? 0;
					used.set(file, n + 1);
					if (n) file = file.replace(/\.lua$/, `_${s.ref}.lua`);
					return { s, file };
				});
				let written = 0, skipped = 0;
				const failed = [];
				let cursor = 0;
				const worker = async () => {
					while (cursor < jobs.length) {
						const { s, file } = jobs[cursor++];
						if (!a.overwrite && fs.existsSync(file)) { skipped++; continue; }
						try {
							let src = "";
							let offset = 0;
							for (;;) {
								const { result } = await call("decompile_script", { target: s.ref, engine: a.engine, offset, max_chars: 400000 }, 90000);
								src += result.source;
								if (result.next_offset == null) break;
								offset = result.next_offset;
							}
							fs.mkdirSync(path.dirname(file), { recursive: true });
							fs.writeFileSync(file, `-- ${s.path}\n${src}`);
							written++;
						} catch (e) {
							failed.push({ path: s.path, error: e.message.slice(0, 160) });
						}
					}
				};
				await Promise.all(Array.from({ length: a.concurrency ?? 2 }, worker));
				return fmtJson({ dir, candidates: jobs.length, written, skipped_existing: skipped, failed: failed.length, failed_sample: failed.slice(0, 10) });
			},
			timeout: 3_600_000,
		},
	);

	tool(
		"disassemble_bytecode",
		"Disassemble Luau bytecode into a readable listing (protos, constants, instructions with resolved operands, line info). Give a script target (bytecode is fetched from the game) or raw base64/hex.",
		{
			target: optTarget,
			base64: z.string().optional(),
			hex: z.string().optional(),
			proto: z.number().int().optional().describe("Only this proto index."),
			max_lines: z.number().int().positive().optional().describe("Cap output lines (default 3000)."),
		},
		{
			run: async (a, { call }) => {
				let buf;
				let header = "";
				if (a.base64) buf = Buffer.from(a.base64, "base64");
				else if (a.hex) buf = Buffer.from(a.hex.replace(/\s+/g, ""), "hex");
				else if (a.target !== undefined) {
					const parts = [];
					let offset = 0;
					for (;;) {
						const { result } = await call("get_script_bytecode", { target: a.target, offset, max_bytes: 800000 });
						parts.push(Buffer.from(result.base64, "base64"));
						if (offset === 0) header = `-- ${result.script.path} (${result.script.class}) size=${result.size} hash=${result.hash ?? "?"}\n`;
						if (result.next_offset == null) break;
						offset = result.next_offset;
					}
					buf = Buffer.concat(parts);
				} else throw new Error("provide target, base64 or hex");
				const prog = disassemble(buf);
				return truncate(header + formatListing(prog, { proto: a.proto, maxLines: a.max_lines ?? 3000 }));
			},
		},
	);
}
