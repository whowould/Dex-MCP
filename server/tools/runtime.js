// Lua runtime: closures, GC, tables, metatables, connections, environments, hooks, traps, watches, remote spy
import { z, target, optTarget, ref, value, nameMode, ci, limit, offset, depth, maxItems, maxStr, timeBudget, args, serOpts } from "./common.js";
import { fmtEvents, fmtVal } from "../format.js";

const modeEnum = z.enum(["plain", "pattern", "exact"]).optional();

const fnLine = (f) => fmtVal(f);

export function register({ tool }) {
	// ---------------------------------------------------------------- closures
	tool(
		"get_function_info",
		"Describe a function ref: name, source, line, params, vararg, Lua/C/executor closure, hash, counts of upvalues/constants/protos, owning script.",
		{ ref },
	);

	tool(
		"upvalues",
		"Read all upvalues of a function (action=get) or write one (action=set index+value). Upvalue tables/functions come back as refs - this is how you reach a script's private state.",
		{ action: z.enum(["get", "set"]), ref, index: z.number().int().optional(), value: value.optional(), ...serOpts },
		{ route: (a) => ({ cmd: a.action === "get" ? "get_upvalues" : "set_upvalue", params: a }), ro: false },
	);

	tool(
		"constants",
		"Read the constants of a function (action=get; strings, numbers, global names) or overwrite one (action=set index+value).",
		{ action: z.enum(["get", "set"]), ref, index: z.number().int().optional(), value: value.optional(), type: z.string().optional().describe("Only constants of this Lua type."), limit: limit(500) },
		{ route: (a) => ({ cmd: a.action === "get" ? "get_constants" : "set_constant", params: a }) },
	);

	tool("get_protos", "List the nested function prototypes of a function as refs with info.", { ref });

	tool(
		"dump_function",
		"Recursive dump of a function: info, constants, upvalues and nested protos (structured version of Dex's Dump Functions).",
		{ ref, depth: z.number().int().min(0).optional().describe("Proto recursion depth (default 3)."), max_nodes: z.number().int().optional(), max_constants: z.number().int().optional(), upvalues: z.boolean().optional() },
	);

	tool("call_function", "Call a function ref with arguments and serialize its return values (executes in the game with executor identity).", { ref, args, timeout: z.number().positive().optional(), ...serOpts });

	tool("clone_function", "clonefunction() a function ref and return the clone as a new ref.", { ref });

	tool("get_function_env", "Get a function's environment table (getfenv): its `script` global and any shadowed globals.", { ref, depth: depth(1), max_items: maxItems });

	// ---------------------------------------------------------------- GC
	tool(
		"gc_search",
		"Scan the Lua GC (getgc) for functions or tables. Function filters: name, script, constant, upvalue, param count, line. Table filters: required keys, key=value pairs, a value anywhere, key pattern, size, metatable. Results are refs.",
		{
			kind: z.enum(["function", "table", "userdata", "all"]).optional().describe("Default function."),
			name: z.string().optional().describe("Function name filter."),
			name_mode: nameMode,
			case_insensitive: ci,
			script: optTarget.describe("Functions whose environment belongs to this script."),
			has_constant: z.union([z.string(), z.number(), z.boolean()]).optional().describe("Function must contain this constant (strings use constant_mode)."),
			constant_mode: modeEnum,
			has_upvalue: z.any().optional().describe("Function must have this value as an upvalue (value format; use {\"$t\":\"ref\",\"id\":N} for objects)."),
			min_params: z.number().int().optional(),
			line: z.number().int().optional().describe("Function defined at this line."),
			has_keys: z.array(z.string()).optional().describe("Table must have all these string keys."),
			key_values: z.record(z.string(), z.any()).optional().describe("Table must have these key=value pairs (compared by value or text)."),
			value_equals: z.any().optional().describe("Table must contain this value under any key (or at_key)."),
			at_key: z.any().optional(),
			key_pattern: z.string().optional().describe("Table has a string key containing this text."),
			min_size: z.number().int().optional(),
			has_metatable: z.boolean().optional(),
			ignore_executor: z.boolean().optional().describe("Skip executor-created closures (default true)."),
			limit: limit(50),
			time_budget: timeBudget,
			depth: depth(1),
			max_items: maxItems,
		},
		{
			budget: true,
			format: (r) =>
				`-- gc_size=${r.gc_size} scanned=${r.scanned} matched=${r.matched} returned=${r.returned}${r.partial ? " PARTIAL(time budget hit)" : ""} ${r.elapsed.toFixed(1)}s\n` +
				r.results.map((x, i) => `[${i}] ${fmtVal(x)}`).join("\n"),
		},
	);

	tool(
		"gc_find_value",
		"Cheat-Engine-style value search over Lua state: find tables holding a value (e.g. your coin count), function upvalues, or constants equal to it. Narrow with key, tolerance for floats. Change the value in-game and search again to isolate it.",
		{
			value: z.any().describe("Number/string/boolean (or ref object) to look for."),
			where: z.array(z.enum(["table", "upvalue", "constant"])).optional().describe("Default [table, upvalue]."),
			key: z.string().optional().describe("For tables: key name must contain this text."),
			tolerance: z.number().optional().describe("Numeric tolerance for float comparisons."),
			limit: limit(40),
			time_budget: timeBudget,
		},
		{
			budget: true,
			format: (r) =>
				`-- matched=${r.matched} returned=${r.returned}${r.partial ? " PARTIAL" : ""} ${r.elapsed.toFixed(1)}s\n` +
				r.results
					.map((x) => (x.where === "table" ? `table ${fmtVal(x.table)} key=${fmtVal(x.key)} = ${fmtVal(x.value)}   keys: ${(x.preview_keys ?? []).join(", ")}` : `${x.where} ${fmtVal(x.function)} [${x.name ?? "?"}] #${x.index} = ${fmtVal(x.value)}`))
					.join("\n"),
		},
	);

	tool("find_references", "Find tables and function upvalues in the GC that hold a reference to the given value (who keeps this object alive / where is it stored).", { target: z.union([z.string(), z.number()]).describe("Ref or instance path of the value."), limit: limit(40), time_budget: timeBudget }, { budget: true });

	tool("gc_snapshot", "Take a named snapshot of all functions/tables currently in the GC. Pair with gc_diff to see what an action created.", { name: z.string().optional(), kinds: z.array(z.enum(["function", "table", "userdata"])).optional() });

	tool(
		"gc_diff",
		"List GC objects created since a snapshot (e.g. snapshot, open a menu in game, diff -> the new state tables and handlers).",
		{ name: z.string().optional(), kind: z.enum(["function", "table", "userdata"]).optional(), name_filter: z.string().optional(), min_size: z.number().int().optional().describe("Skip tables smaller than this."), limit: limit(40), update: z.boolean().optional().describe("Advance the snapshot after diffing.") },
		{ format: (r) => `-- new=${r.new_objects} by_type=${JSON.stringify(r.by_type)} returned=${r.returned}\n` + r.results.map((x, i) => `[${i}] ${fmtVal(x)}`).join("\n") },
	);

	tool("gc_stats", "Count GC objects by type (function/table/userdata/Instance/...).", {});

	// ---------------------------------------------------------------- tables / metatables
	tool(
		"get_table",
		"Page through a table ref: entries sorted by key, nested tables/functions as refs, plus metatable/readonly flags.",
		{ ref, key: z.string().optional().describe("Only keys containing this text."), key_mode: modeEnum, offset, limit: limit(100), ...serOpts },
		{
			format: (r) =>
				`-- table #${r.ref}: ${r.total} entries${r.matched !== r.total ? `, ${r.matched} matched` : ""}${r.has_metatable ? ", has metatable" : ""}${r.readonly ? ", READONLY" : ""}${r.next_offset ? `; next offset=${r.next_offset}` : ""}\n` +
				r.entries.map((e) => `${fmtVal(e.key)} = ${fmtVal(e.value)}`).join("\n"),
		},
	);

	tool(
		"set_table_field",
		"Write (or with delete=true remove) a field of a table ref. Raw write by default; readonly tables are unlocked first.",
		{ ref, key: z.any().describe("Key (value format)."), value: value.optional(), raw: z.boolean().optional(), delete: z.boolean().optional() },
		{ route: (a) => ({ cmd: a.delete ? "delete_table_field" : "set_table_field", params: a }) },
	);

	tool(
		"table_search",
		"Recursively search inside a table ref for keys/values matching text; returns access paths like ref#12.Inventory.Items[3].",
		{ ref, key: z.string().optional(), key_mode: modeEnum, value: z.union([z.string(), z.number(), z.boolean()]).optional(), value_mode: modeEnum, case_insensitive: ci, depth: z.number().int().positive().optional().describe("Default 5."), limit: limit(60) },
	);

	tool(
		"metatable",
		"Metatables: action=get (read metatable of a ref), set (setrawmetatable), readonly (setreadonly on a table; value=false unlocks), set_metamethod (patch one metamethod with Lua `code` that evaluates to a function, or a ref `value`).",
		{
			action: z.enum(["get", "set", "readonly", "set_metamethod"]),
			ref,
			metatable: z.union([z.number(), z.string()]).optional().describe("For set: ref of the metatable (omit to clear)."),
			value: z.any().optional(),
			name: z.string().optional().describe("Metamethod name for set_metamethod, e.g. __index."),
			code: z.string().optional().describe("Lua expression/chunk returning the replacement function (e.g. \"return function(self,k) return 1 end\")."),
		},
		{
			route: (a) => ({ cmd: { get: "get_metatable", set: "set_metatable", readonly: "set_readonly", set_metamethod: "set_metamethod" }[a.action], params: a }),
			ro: false,
		},
	);

	tool("get_registry", "Inspect the Lua registry (getreg) with an optional key/value text filter.", { filter: z.string().optional(), limit: limit(100) });

	tool("get_threads", "List live Lua threads (getthreads) with status.", { limit: limit(50) });

	// ---------------------------------------------------------------- signals
	tool(
		"get_connections",
		"List the connections on a signal (getconnections): handler function refs, owning script, enabled state. Identify exactly which script handles an event.",
		{ target: optTarget, signal: z.string().optional().describe('Event name on target, e.g. "OnClientEvent", "MouseButton1Click", "Changed".'), signal_ref: z.union([z.number(), z.string()]).optional(), limit: limit(100) },
	);

	tool(
		"connection_action",
		"Act on one connection ref from get_connections: enable, disable, fire (call its handler), defer, disconnect.",
		{ ref, action: z.enum(["enable", "disable", "fire", "defer", "disconnect"]), args },
	);

	tool("toggle_connections", "Disable (or with enable=true re-enable) every connection on a signal.", { target, signal: z.string(), enable: z.boolean().optional() }, { cmd: "disable_all_connections" });

	tool("fire_signal", "Fire a signal's connections with arguments via firesignal (e.g. trigger a button's MouseButton1Click or a RemoteEvent's OnClientEvent handlers).", { target: optTarget, signal: z.string().optional(), signal_ref: z.union([z.number(), z.string()]).optional(), args });

	tool("get_callback", "Read a callback property such as RemoteFunction.OnClientInvoke (getcallbackvalue) as a function ref.", { target, name: z.string().optional().describe("Default OnClientInvoke.") });

	tool(
		"list_connected_signals",
		"For one instance, list every event that has connections and the handler functions/scripts behind them.",
		{ target },
	);

	// ---------------------------------------------------------------- environments
	tool(
		"get_env",
		"Inspect an environment table: genv (executor globals), renv (Roblox globals), shared, _G, a script's env, or a function's env. Filter keys by text.",
		{ which: z.enum(["genv", "renv", "shared", "_G", "script", "function"]).optional(), script: optTarget, ref: z.union([z.number(), z.string()]).optional(), filter: z.string().optional(), mode: modeEnum, depth: depth(0), limit: limit(150) },
	);

	tool("set_global", "Set a global in genv (default), _G or shared.", { name: z.string(), value, which: z.enum(["genv", "_G", "shared"]).optional() });

	// ---------------------------------------------------------------- traps / hooks / watches
	tool(
		"trap_add",
		"Install a metamethod trap. kind=namecall traps instance METHOD calls (e.g. Kick, FindFirstChild, Destroy); index traps property READS; newindex traps property WRITES (e.g. WalkSpeed). Actions: log, block, return (fixed value), lua (custom code). Logged to the 'trap' event channel (see get_events).",
		{
			kind: z.enum(["namecall", "index", "newindex"]).optional().describe("Default namecall."),
			member: z.string().describe("Method name (namecall) or property name (index/newindex)."),
			class: z.string().optional().describe("Only instances that IsA this class."),
			target: optTarget.describe("Only this instance."),
			name: z.string().optional().describe("Only instances whose Name matches."),
			name_mode: nameMode,
			action: z.enum(["log", "block", "return", "lua"]).optional(),
			value: z.any().optional().describe("For action=return: value to return/serve."),
			code: z.string().optional().describe("For action=lua: Lua chunk returning function(next, self, ...) (namecall only)."),
			log: z.boolean().optional(),
			log_args: z.boolean().optional(),
			capture_stack: z.boolean().optional().describe("Attach a Lua traceback to every logged hit."),
			capture_script: z.boolean().optional(),
			include_executor: z.boolean().optional().describe("Also trap calls made by the executor itself."),
		},
		{ destructive: false },
	);

	tool("trap_remove", "Remove a trap by id.", { id: z.number().int() });
	tool("trap_list", "List active traps with hit counts.", {});

	tool(
		"hook_function",
		"Hook a Lua/C function by ref (or by executor global name with `global`, e.g. \"writefile\", \"setclipboard\"). Modes: log (record args/results/caller, default), block, return (fixed values), wrap (custom `code`: function(orig, ...) ... end). Logged to the 'hook' channel.",
		{
			ref: z.union([z.number(), z.string()]).optional(),
			global: z.string().optional().describe('Global function name instead of a ref, e.g. "request" or "debug.getinfo".'),
			mode: z.enum(["log", "block", "return", "wrap"]).optional(),
			label: z.string().optional(),
			value: z.any().optional().describe("For mode=return: single return value."),
			values: z.array(z.any()).optional().describe("For mode=return: multiple return values."),
			code: z.string().optional().describe("For mode=wrap: Lua chunk evaluating to function(orig, ...)."),
			include_executor: z.boolean().optional(),
			capture_stack: z.boolean().optional(),
			max_log: z.number().int().optional(),
			stop_after_max: z.boolean().optional(),
		},
		{ route: (a) => ({ cmd: a.global ? "hook_global" : "hook_function", params: { ...a, name: a.global } }) },
	);

	tool("unhook_function", "Remove a function hook by id (restorefunction or re-hook with the original).", { id: z.number().int() });
	tool("list_hooks", "List function hooks, traps and whether the shared __namecall hook is installed.", {});

	tool(
		"watch",
		"Log changes as events: kind=property (GetPropertyChangedSignal), children (child/descendant add/remove), attribute, or signal (any event with its arguments). Read results with get_events / wait_for_events (channels: watch, tree, signal).",
		{
			kind: z.enum(["property", "children", "attribute", "signal"]),
			target,
			property: z.string().optional().describe("kind=property."),
			name: z.string().optional().describe("kind=attribute: attribute name (omit for all)."),
			signal: z.string().optional().describe("kind=signal: event name."),
			descendants: z.boolean().optional().describe("kind=children: watch the whole subtree."),
			capture_stack: z.boolean().optional(),
			capture_script: z.boolean().optional(),
		},
		{ route: (a) => ({ cmd: { property: "watch_property", children: "watch_children", attribute: "watch_attribute", signal: "watch_signal" }[a.kind], params: a }), ro: false },
	);

	tool("unwatch", "Remove one watch by id, or all watches with all=true.", { id: z.number().int().optional(), all: z.boolean().optional() }, { route: (a) => (a.all ? { cmd: "unwatch_all", params: {} } : { cmd: "unwatch", params: { id: a.id } }) });
	tool("list_watches", "List active watches with event counts.", {});

	tool(
		"http_spy",
		"Spy on executor-side network and loader activity: request()/http_request, game:HttpGet/HttpPost, HttpService, WebSocket.connect, and loadstring (what code gets compiled). Ideal for vetting what a loaded script phones home to. Events go to the 'http' channel.",
		{ action: z.enum(["start", "stop", "status"]), capture_stack: z.boolean().optional(), body_limit: z.number().int().optional(), loadstring: z.boolean().optional().describe("Also log loadstring calls (default true)."), loadstring_head: z.number().int().optional() },
		{ route: (a) => ({ cmd: { start: "http_spy_start", stop: "http_spy_stop", status: "http_spy_status" }[a.action], params: a }), ro: false },
	);

	tool(
		"get_output",
		"Read the Roblox developer console output (LogService): recent history, or messages after a sequence number.",
		{ since: z.number().int().optional(), level: z.string().optional().describe("MessageOutput|MessageInfo|MessageWarning|MessageError"), match: z.string().optional(), match_mode: modeEnum, limit: limit(100), history: z.number().int().optional() },
		{ format: (r) => (r.messages ?? []).map((m) => `[${(m.level ?? "").replace("Message", "")}] ${m.message}`).join("\n") + `\n-- ${(r.messages ?? []).length} message(s); last_seq=${r.last_seq}` },
	);

	tool("clear_output", "Clear the developer console and the buffered output events.", {});

	// ---------------------------------------------------------------- remote spy
	tool(
		"remote_spy",
		"Control the remote spy. start: hooks FireServer/InvokeServer (namecall + direct calls) and incoming OnClientEvent, capturing args, results, calling script and optional stack. stop/status/clear. Read the log with remote_spy_get.",
		{
			action: z.enum(["start", "stop", "status", "clear"]),
			include_executor: z.boolean().optional().describe("Also log calls made by the executor itself."),
			capture_stack: z.boolean().optional().describe("Attach a traceback to each outgoing call (shows the calling function chain)."),
			capture_script: z.boolean().optional().describe("Resolve the calling script (default true)."),
			incoming: z.boolean().optional().describe("Also log OnClientEvent (server->client) traffic (default true)."),
			bindables: z.boolean().optional().describe("Also log BindableEvent/Function Fire/Invoke."),
			hook_functions: z.boolean().optional().describe("Also hook the raw C functions to catch remote.FireServer(remote, ...) (default true)."),
			max_per_remote: z.number().int().optional().describe("Log at most this many calls per remote (counts keep going). Default 2000."),
			sample_every: z.number().int().optional().describe("Log only every Nth call per remote (for 60Hz spam)."),
			raw_cap: z.number().int().optional().describe("How many recent calls keep raw args for replay (default 500)."),
			depth: z.number().int().optional(),
			max_items: z.number().int().optional(),
			max_str: z.number().int().optional(),
			reset_stats: z.boolean().optional().describe("With clear: also reset per-remote statistics."),
		},
		{ route: (a) => ({ cmd: { start: "remote_spy_start", stop: "remote_spy_stop", status: "remote_spy_status", clear: "remote_spy_clear" }[a.action], params: a }), ro: false },
	);

	tool(
		"remote_spy_get",
		"Read the remote spy log (newest last). Filters: remote name/path, method, direction, calling script, text inside arguments, errors only. Use `since` = last_seq to tail.",
		{
			since: z.number().int().optional().describe("Only calls with seq > since."),
			limit: limit(50),
			tail: z.boolean().optional().describe("With since: return the newest `limit` instead of the oldest."),
			remote: z.string().optional().describe("Substring of the remote's path."),
			remote_mode: modeEnum,
			method: z.enum(["FireServer", "InvokeServer", "OnClientEvent", "Fire", "Invoke"]).optional(),
			direction: z.enum(["out", "in"]).optional(),
			script: z.string().optional().describe("Substring of the calling script path."),
			args_match: z.string().optional().describe("Substring that must appear in the serialized arguments."),
			errors_only: z.boolean().optional(),
		},
		{ format: (r) => fmtEvents(r, r.active === false ? "  (spy is NOT active)" : "") },
	);

	tool("remote_call_detail", "Re-serialize one logged call with much deeper limits (full argument tables) using its seq id.", { seq: z.number().int(), depth: z.number().int().optional(), max_items: z.number().int().optional(), max_str: z.number().int().optional() });

	tool(
		"remote_spy_summary",
		"Per-remote traffic summary: call counts, calls/sec, distinct argument type signatures. The quickest way to see which remotes matter and what shape their arguments have.",
		{ limit: limit(50), max_signatures: z.number().int().optional() },
		{
			format: (r) =>
				`-- ${r.total_remotes} remote(s), ${r.total_calls} call(s), spy ${r.active ? "ACTIVE" : "inactive"}\n` +
				r.remotes.map((x) => `${String(x.calls).padStart(6)}  ${x.remote} [${x.class}] #${x.ref}${x.per_second ? ` ${x.per_second.toFixed(1)}/s` : ""}${x.blocked_calls ? ` blocked=${x.blocked_calls}` : ""}${x.ignored ? " ignored" : ""}\n        ${x.signatures.map((s) => `(${s.signature}) x${s.count}`).join("  ")}`).join("\n"),
		},
	);

	tool(
		"remote_filter",
		"Manage remote ignore/block lists. ignore/unignore hides remotes from the log; block drops their outgoing calls (optionally returning fixed values to the caller); unblock restores. Targets: target, remotes[], or name pattern (ignore only).",
		{
			action: z.enum(["ignore", "unignore", "block", "unblock"]),
			target: optTarget,
			remotes: z.array(z.union([z.string(), z.number()])).optional(),
			name: z.string().optional().describe("ignore: hide every remote whose name matches."),
			name_mode: nameMode,
			all: z.boolean().optional().describe("unignore/unblock: clear everything."),
			return_values: z.array(z.any()).optional().describe("block: values handed back to the caller instead of dropping silently."),
		},
		{ route: (a) => ({ cmd: { ignore: "remote_ignore", unignore: "remote_unignore", block: "remote_block", unblock: "remote_unblock" }[a.action], params: a }), ro: false },
	);

	tool(
		"list_remotes",
		"List every RemoteEvent/RemoteFunction/UnreliableRemoteEvent (optionally Bindables) in the game and nil space with call counts, blocked/ignored flags and client handler counts.",
		{ root: optTarget, name: z.string().optional(), name_mode: nameMode, bindables: z.boolean().optional(), with_handlers: z.boolean().optional(), include_nil: z.boolean().optional(), limit: limit(300) },
	);

	tool(
		"get_remote_handlers",
		"Which client code handles this remote? Lists OnClientEvent connections (or the OnClientInvoke callback) as function refs with owning script - jump straight to the receiving logic.",
		{ target },
	);

	tool(
		"fire_remote",
		"Fire a RemoteEvent / invoke a RemoteFunction / Bindable with arguments from the executor (not logged by the spy unless include_executor). Supports repeat with delay.",
		{ target, args, times: z.number().int().positive().optional(), delay: z.number().optional().describe("Seconds between repeats."), timeout: z.number().positive().optional(), ...serOpts },
		{ cmd: "fire_remote" },
	);

	tool(
		"remote_replay",
		"Replay a logged call by seq id, optionally replacing all args or patching individual arguments (modify: [{index, value}]).",
		{ seq: z.number().int(), args, modify: z.array(z.object({ index: z.number().int().positive(), value: z.any() })).optional(), times: z.number().int().positive().optional(), delay: z.number().optional(), timeout: z.number().positive().optional() },
	);
}
