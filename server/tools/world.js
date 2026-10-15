// Execution, files, network, game world, GUI, snapshots, Dex++ integration
import { z, target, optTarget, value, nameMode, ci, limit, offset, depth, maxItems, maxStr, serOpts } from "./common.js";
import { fmtVal, fmtJson } from "../format.js";

const vec3 = z.array(z.number()).length(3).describe("[x, y, z]");

const execFmt = (r) => {
	const out = [];
	if (r.phase === "compile") return `COMPILE ERROR: ${r.error}`;
	if (r.output?.length) out.push(...r.output.map((o) => (o.level === "warn" ? `[warn] ${o.text}` : o.text)));
	if (r.pending) out.push(`-- still running after ${r.elapsed.toFixed(1)}s (exec id ${r.id}). Use get_exec_result {id:${r.id}, wait:10} or cancel_exec.`);
	else if (r.ok === false) out.push(`ERROR: ${r.error}`);
	else if (r.results?.length) out.push(...r.results.map((v, i) => `=> ${fmtVal(v)}`));
	else out.push("-- ok (no return values)");
	out.push(`-- exec #${r.id}, ${r.elapsed.toFixed(2)}s`);
	return out.join("\n");
};

export function register({ tool }) {
	// ---------------------------------------------------------------- execution
	tool(
		"execute_lua",
		"Run Lua in the game via loadstring. print/warn are captured and returned; returned values are serialized (tables/functions/instances come back as refs usable by other tools; inside the code call ref(12) to get them back, inst('game.Workspace') for instances). Long-running code returns an exec id to poll.",
		{
			code: z.string().describe("Lua/Luau chunk. Use `return` to send values back."),
			timeout: z.number().positive().optional().describe("Seconds to wait for completion (default 15). Slower code keeps running; poll with get_exec_result."),
			identity: z.number().int().optional().describe("Thread identity to run under (e.g. 2, 7, 8)."),
			chunk_name: z.string().optional(),
			...serOpts,
		},
		{ format: execFmt, budget: true },
	);

	tool("evaluate", "Evaluate a single Lua expression and return its value (shorthand for execute_lua with `return <expr>`).", { expression: z.string(), timeout: z.number().positive().optional(), ...serOpts }, { format: execFmt, budget: true });

	tool("get_exec_result", "Fetch the result of an execute_lua run (optionally waiting up to `wait` seconds for it to finish).", { id: z.number().int(), wait: z.number().optional(), ...serOpts }, { format: execFmt });
	tool("cancel_exec", "Cancel a still-running execute_lua thread.", { id: z.number().int() });
	tool("list_execs", "List recent execute_lua runs.", {});
	tool("compile_check", "Check whether Lua code compiles (loadstring) without running it.", { code: z.string() });

	tool("get_identity", "Current thread identity level and the default applied to bridge commands.", {});
	tool("set_identity", "Set the thread identity used for all subsequent bridge commands (needs setthreadidentity), e.g. 7 or 8 for privileged APIs.", { identity: z.number().int() });

	// ---------------------------------------------------------------- files / network
	tool(
		"file",
		"Executor workspace filesystem: read, write, append, list, exists, delete, mkdir, rmdir. (Files live on the machine running the game.)",
		{
			action: z.enum(["read", "write", "append", "list", "exists", "delete", "mkdir", "rmdir"]),
			path: z.string().optional(),
			content: z.string().optional().describe("Text for write/append."),
			base64: z.string().optional().describe("Binary data for write/append (base64)."),
			encoding: z.enum(["text", "base64"]).optional().describe("read: return text (default) or base64."),
			offset: z.number().int().min(0).optional(),
			max_bytes: z.number().int().positive().optional(),
			limit: limit(500),
		},
		{
			route: (a) => {
				const map = { read: "read_file", write: "write_file", append: "write_file", list: "list_files", exists: "file_exists", delete: "delete_file", mkdir: "make_folder", rmdir: "delete_folder" };
				return { cmd: map[a.action], params: { ...a, append: a.action === "append" } };
			},
			ro: false,
		},
	);

	tool(
		"http_request",
		"Make an HTTP request from the game client's executor (request()). Useful for probing endpoints a script talks to from the same machine/IP.",
		{ url: z.string(), method: z.string().optional(), headers: z.record(z.string(), z.string()).optional(), body: z.string().optional(), timeout: z.number().positive().optional(), max_body: z.number().int().optional() },
		{ budget: true },
	);

	tool("set_clipboard", "Put text on the clipboard of the machine running the game.", { text: z.string() });

	// ---------------------------------------------------------------- game / players
	tool("get_game_info", "Place/game/job ids, creator, name, version, player counts, streaming, gravity, executor.", {});
	tool("get_players", "All players with team, character, health, position.", {});
	tool("get_character", "A player's character: humanoid stats/state and child parts with positions.", { player: z.union([z.string(), z.number()]).optional().describe('Name, display name, user id or "local" (default).') });
	tool("get_local_player", "Local player summary: character/humanoid, tools, backpack, leaderstats, attributes, PlayerGui screens.", {});
	tool("teleport", "Teleport the local character to a position or to an instance (BasePart/Model/Attachment).", { position: vec3.optional(), target: optTarget, offset: vec3.optional() });

	tool("get_camera", "Current camera CFrame, FOV, type, subject, viewport size.", {});
	tool("set_camera", "Change the camera: field_of_view, camera_type (e.g. Scriptable), subject, or position+look_at / cframe.", { field_of_view: z.number().optional(), camera_type: z.string().optional(), subject: optTarget, position: vec3.optional(), look_at: vec3.optional(), cframe: z.any().optional() });

	tool(
		"raycast",
		"workspace:Raycast from origin along direction (or length-scaled), with optional ignore/include lists. Returns the hit instance, position, normal, material.",
		{ origin: vec3, direction: vec3, length: z.number().optional().describe("Scale direction to this length."), ignore: z.array(z.union([z.string(), z.number()])).optional(), include: z.array(z.union([z.string(), z.number()])).optional(), ignore_water: z.boolean().optional() },
	);
	tool("world_to_screen", "Project world positions to screen coordinates with the current camera.", { positions: z.array(vec3).optional(), position: vec3.optional() });
	tool("screen_to_ray", "Cast a ray through a screen pixel; returns the ray and (by default) the first hit.", { x: z.number(), y: z.number(), length: z.number().optional(), cast: z.boolean().optional() });
	tool("get_mouse_target", "What the mouse is pointing at: target instance, hit position, surface.", {});

	tool("get_network_owner", "Network ownership of a part (isnetworkowner / NetworkOwnerV3) and Anchored state.", { target });
	tool("get_stats", "Client performance counters: ping, FPS, memory, instance/primitive counts, throughput.", {});
	tool("get_marketplace_info", "MarketplaceService:GetProductInfo for an asset/product id.", { asset_id: z.number().int(), info_type: z.enum(["Asset", "Product", "GamePass", "Subscription", "Bundle"]).optional() });
	tool("get_sounds", "List Sound instances (optionally only playing) with ids, volume, position.", { playing_only: z.boolean().optional(), limit: limit(100) });
	tool("get_lighting", "Lighting service summary and its effects.", {});

	// ---------------------------------------------------------------- GUI + interaction
	tool(
		"get_gui_tree",
		"Indented tree of a GUI root with hidden flags, text and (optionally) geometry. Roots: PlayerGui (default), CoreGui, gethui, StarterGui, or any instance.",
		{ root: z.union([z.string(), z.number()]).optional().describe("PlayerGui | CoreGui | gethui | StarterGui | instance path/ref."), depth: z.number().int().optional(), max_nodes: z.number().int().optional(), only_visible: z.boolean().optional(), text: z.string().optional().describe("Only branches containing this text."), geometry: z.boolean().optional(), refs: z.boolean().optional() },
		{ format: (r) => `${r.tree}\n-- ${r.nodes} node(s)${r.truncated ? " (truncated)" : ""}` },
	);

	tool(
		"find_gui",
		"Find GuiObjects by visible text, name or class with effective visibility and on-screen geometry.",
		{ root: z.union([z.string(), z.number()]).optional(), text: z.string().optional(), text_mode: nameMode, name: z.string().optional(), name_mode: nameMode, class: z.string().optional(), case_insensitive: ci, visible_only: z.boolean().optional(), limit: limit(50) },
	);

	tool("click_gui", "Click a GuiButton by firing its connected MouseButton1Down/Click/Up/Activated handlers.", { target, signals: z.array(z.string()).optional() });
	tool("set_gui_text", "Set a TextBox/TextLabel Text; with submit=true also fires FocusLost handlers (like pressing Enter).", { target, text: z.string(), submit: z.boolean().optional() });
	tool(
		"send_input",
		"Simulate keyboard/mouse input via VirtualInputManager: key (tap/down/up a KeyCode like E, Space, LeftShift), text (type letters), mouse_click/down/up at screen x,y, mouse_move, mouse_scroll. Drive game UI and keybinds without touching the machine.",
		{
			kind: z.enum(["key", "text", "mouse_click", "mouse_down", "mouse_up", "mouse_move", "mouse_scroll"]),
			key: z.string().optional().describe("Enum.KeyCode name for kind=key."),
			action: z.enum(["tap", "down", "up"]).optional().describe("kind=key: default tap."),
			text: z.string().optional().describe("kind=text."),
			x: z.number().optional(),
			y: z.number().optional(),
			button: z.number().int().min(1).max(3).optional().describe("1 left, 2 right, 3 middle."),
			amount: z.number().optional().describe("mouse_scroll: positive = up."),
			hold: z.number().optional().describe("Seconds between down and up for taps/clicks (default 0.05)."),
			delay: z.number().optional().describe("kind=text: seconds between characters."),
		},
	);
	tool("fire_click_detector","fireclickdetector on a ClickDetector (or the first one under the target).", { target, distance: z.number().optional(), event: z.string().optional() });
	tool("fire_proximity_prompt", "fireproximityprompt on a ProximityPrompt (or the first one under the target).", { target, hold: z.number().optional() });
	tool("fire_touch_interest", "firetouchinterest between your character (or `target`) and a part: simulates touching it.", { part: target, target: optTarget, hold: z.number().optional() });

	// ---------------------------------------------------------------- snapshots
	tool(
		"snapshot_tree",
		"Record the instance hierarchy (and chosen properties) under a root as a named snapshot. Later diff_tree_snapshot shows what was added/removed/changed.",
		{ root: optTarget, name: z.string().optional(), max_depth: z.number().int().optional(), props: z.array(z.string()).optional().describe("Property names to track on every instance."), limit: z.number().int().optional() },
	);
	tool(
		"diff_tree_snapshot",
		"Compare the current hierarchy (or another snapshot with `against`) to a snapshot: added, removed, changed instances.",
		{ name: z.string().optional(), against: z.string().optional(), update: z.boolean().optional().describe("Re-baseline the snapshot after diffing."), limit: limit(100) },
	);
	tool("snapshot_properties", "Record every property and attribute of one instance as a named snapshot.", { target, name: z.string().optional(), include_hidden: z.boolean().optional() });
	tool("diff_properties", "Show which properties/attributes of the snapshotted instance changed since the snapshot (from/to values).", { name: z.string().optional(), update: z.boolean().optional() });
	tool("snapshots", "List (action=list) or delete (action=delete, name) snapshots.", { action: z.enum(["list", "delete"]), name: z.string().optional() }, { route: (a) => (a.action === "list" ? { cmd: "list_snapshots", params: {} } : { cmd: "delete_snapshot", params: { name: a.name } }) });

	// ---------------------------------------------------------------- Dex++
	tool(
		"dex_selection",
		"Dex++ Explorer selection: action=get (what the user has selected right now), set (select targets and scroll to them), clear.",
		{ action: z.enum(["get", "set", "clear"]), targets: z.array(z.union([z.string(), z.number()])).optional(), view: z.boolean().optional() },
		{ route: (a) => ({ cmd: { get: "dex_get_selection", set: "dex_set_selection", clear: "dex_clear_selection" }[a.action], params: a }) },
	);
	tool("dex_view_object", "Scroll the Dex++ Explorer to an instance (expanding parents).", { target });
	tool("dex_search", "Run a search in the Dex++ Explorer (supports Dex search syntax); empty query clears.", { query: z.string().optional() }, { route: (a) => (a.query ? { cmd: "dex_search", params: a } : { cmd: "dex_clear_search", params: {} }) });
	tool("dex_open_script", "Open a script in Dex++'s Notepad (decompiled); with dump_functions also appends a function dump.", { target, dump_functions: z.boolean().optional() }, { route: (a) => ({ cmd: a.dump_functions ? "dex_dump_functions" : "dex_open_script", params: a }) });
	tool("dex_view_model", "Open a Model/BasePart in Dex++'s 3D viewer.", { target });
	tool(
		"dex_apps",
		"Dex++ windows: action=list, toggle (name + open), or open_ui (show/hide the main Dex++ menu).",
		{ action: z.enum(["list", "toggle", "open_ui"]), name: z.string().optional().describe("App name, e.g. Explorer, Properties, Notepad, Console, Save Instance, 3D Viewer, MCP."), open: z.boolean().optional() },
		{ route: (a) => ({ cmd: { list: "dex_list_apps", toggle: "dex_toggle_app", open_ui: "dex_open_ui" }[a.action], params: a }) },
	);
	tool(
		"dex_settings",
		"Dex++ settings: action=get (optionally one section), set (dotted path like Explorer.Sorting or Decompiler.DecompilerFallback, optional save), save.",
		{ action: z.enum(["get", "set", "save"]), section: z.string().optional(), path: z.string().optional(), value: value.optional(), save: z.boolean().optional() },
		{ route: (a) => ({ cmd: { get: "dex_get_settings", set: "dex_set_setting", save: "dex_save_settings" }[a.action], params: a }) },
	);
	tool("dex_reinit", "Restart Dex++ (rebuilds all windows). The bridge reconnects afterwards.", {});
	tool(
		"save_instance",
		"Save the place or a subtree to an .rbxl/.rbxm in the executor workspace via saveinstance (Decompile on by default). Long saves continue in the background; poll save_instance_status.",
		{ target: optTarget, filename: z.string().optional(), options: z.record(z.string(), z.any()).optional().describe("saveinstance options, e.g. {Decompile:true, NilInstances:true, RemovePlayerCharacters:true}."), wait: z.number().optional().describe("Seconds to wait before returning (default 5).") },
		{ budget: true },
	);
	tool("save_instance_status", "Progress of the last save_instance call.", {});
	tool("dex_console_print", "Print text into the Dex++ Console window (or the output if unavailable).", { text: z.string() });
}
