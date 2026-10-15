// Scripts: discovery, decompile, bytecode, strings, environments, function mapping, dumping
import { z, target, optTarget, nameMode, ci, limit, offset, timeBudget, startIndex, serOpts } from "./common.js";
import { withLineNumbers, fmtVal } from "../format.js";

const scriptSelectors = {
	root: optTarget.describe("Only scripts under this instance."),
	source: z.enum(["tree", "getscripts", "running", "modules", "nil"]).optional().describe("Where to collect scripts from: tree (walk the hierarchy), getscripts (every script the executor knows, incl. nil-parented; default when available), running, modules (loaded ModuleScripts), nil."),
	class: z.string().optional().describe('Class filter, e.g. "LocalScript" or "ModuleScript".'),
	name: z.string().optional(),
	name_mode: nameMode,
	case_insensitive: ci,
	include_core: z.boolean().optional().describe("Include CoreGui/CorePackages (Roblox internal) scripts; default false."),
	viable_only: z.boolean().optional().describe("Only scripts that can run/decompile on the client (default true here)."),
};

const searchDefaults = { viable_only: true };

const decompFmt = (r, a) => {
	const s = r.script;
	const head = `-- ${s.path} (${s.class}) ref #${s.ref}\n-- ${r.total_lines} lines, ${r.total_chars} chars${r.cached ? ", cached" : `, decompiled in ${r.elapsed.toFixed(2)}s`}${r.offset ? `, from char ${r.offset}` : ""}${r.next_offset ? `; truncated -> call again with offset=${r.next_offset}` : ""}\n`;
	let body = r.source;
	if (a.line_numbers && !r.offset) body = withLineNumbers(body);
	return head + body;
};

const searchFmt = (r) => {
	const out = [];
	for (const e of r.results) {
		out.push(`== ${e.script.path} (${e.script.class}) #${e.script.ref}${e.lines !== undefined ? `  [${e.lines} lines]` : ""}`);
		for (const h of e.hits ?? []) {
			if (h.before?.length) for (const [i, l] of h.before.entries()) out.push(`   ${String(h.line - h.before.length + i).padStart(5)}  ${l}`);
			if (h.constant !== undefined) out.push(`   in ${h.fn ?? "<main chunk>"}${h.line ? ` (line ${h.line})` : ""}: ${JSON.stringify(h.constant)}`);
			else out.push(` > ${String(h.line).padStart(5)}  ${h.text}`);
			if (h.after?.length) for (const [i, l] of h.after.entries()) out.push(`   ${String(h.line + 1 + i).padStart(5)}  ${l}`);
		}
	}
	const meta = [`candidates=${r.candidates}`, `scanned=${r.scanned}`, r.total_hits !== undefined ? `hits=${r.total_hits}` : null, `elapsed=${(r.elapsed ?? 0).toFixed(1)}s`].filter(Boolean).join(" ");
	const more = r.partial ? `\n-- PARTIAL: continue with start_index=${r.next_start_index}` : "";
	const failed = r.failed_count ? `\n-- ${r.failed_count} script(s) failed to decompile, e.g. ${(r.failed_sample ?? []).slice(0, 3).map((f) => `${f.path}: ${f.error}`).join(" | ")}` : "";
	return (out.length ? out.join("\n") + "\n" : "-- no matches\n") + `-- ${meta}${more}${failed}`;
};

export function register({ tool }) {
	tool(
		"list_scripts",
		"List scripts (LocalScript/ModuleScript/Script) with paths and refs. Default source is getscripts, which includes nil-parented and hidden scripts.",
		{ ...scriptSelectors, with_hash: z.boolean().optional().describe("Include bytecode hashes (fast duplicate detection)."), offset, limit: limit(200) },
	);

	tool(
		"decompile_script",
		"Decompile a script to Luau source using Dex++'s decompiler chain (native decompile, else Konstant/Shiny/Advanced via getscriptbytecode). Large scripts are paged with offset/max_chars.",
		{
			target,
			engine: z.enum(["dex", "builtin", "konstant", "shiny", "advanced"]).optional().describe("dex = Dex++ settings (default), builtin = executor decompile(), others force a fallback decompiler."),
			offset: z.number().int().min(0).optional().describe("Character offset for paging."),
			max_chars: z.number().int().positive().optional().describe("Characters per page (default 60000)."),
			line_numbers: z.boolean().optional(),
			timeout: z.number().positive().optional().describe("Seconds before giving up (default 45)."),
			use_cache: z.boolean().optional(),
		},
		{ format: decompFmt, budget: true },
	);

	tool("get_script_source", "Return a script's Source if readable (plugin/studio-level), otherwise its decompiled source.", { target, engine: z.enum(["dex", "builtin", "konstant", "shiny", "advanced"]).optional() }, {
		format: (r) => `-- via ${r.via}\n${r.source}`,
	});

	tool(
		"set_decompiler",
		"Configure Dex++'s decompiler: fallback engine (konstant|shiny|advanced), whether to prefer it over the executor's native decompile, and the Shiny port. Call with no args to read current settings.",
		{ engine: z.enum(["konstant", "shiny", "advanced"]).optional(), prefer_fallback: z.boolean().optional(), shiny_port: z.number().int().optional(), save: z.boolean().optional() },
	);

	tool(
		"get_script_bytecode",
		"Raw Luau bytecode of a script (base64 or hex) with hash and size. Feed it to disassemble_bytecode for a listing.",
		{ target, format: z.enum(["base64", "hex"]).optional(), offset: z.number().int().min(0).optional(), max_bytes: z.number().int().positive().optional() },
	);

	tool("get_script_info", "Script metadata: class, RunContext, disabled, hash, bytecode size, whether it is loaded/running, whether it can be decompiled, closure info.", { target });

	tool(
		"search_scripts",
		"Grep every candidate script's DECOMPILED source (cached after first decompile). Returns matching lines with optional context. Long scans return partial=true with next_start_index; repeat to continue.",
		{
			pattern: z.string().describe("Text or Lua pattern to find."),
			mode: z.enum(["plain", "pattern", "exact"]).optional(),
			case_insensitive: ci,
			...scriptSelectors,
			context: z.number().int().min(0).max(8).optional().describe("Lines of context around each hit."),
			max_results: z.number().int().positive().optional().describe("Stop after this many scripts with hits (default 50)."),
			max_hits_per_script: z.number().int().positive().optional(),
			time_budget: timeBudget,
			start_index: startIndex,
			engine: z.enum(["dex", "builtin", "konstant", "shiny", "advanced"]).optional(),
			decompile_timeout: z.number().positive().optional().describe("Seconds per script (default 20)."),
		},
		{ defaults: searchDefaults, format: searchFmt, budget: true },
	);

	tool(
		"search_constants",
		"Search string constants inside compiled script closures (no decompiler needed - fast, works when decompilation fails). Finds e.g. remote names, anticheat strings, URLs.",
		{
			pattern: z.string(),
			mode: z.enum(["plain", "pattern", "exact"]).optional(),
			case_insensitive: ci,
			...scriptSelectors,
			max_results: z.number().int().positive().optional(),
			max_hits_per_script: z.number().int().positive().optional(),
			time_budget: timeBudget,
			start_index: startIndex,
		},
		{ defaults: searchDefaults, format: searchFmt, budget: true },
	);

	tool(
		"get_script_strings",
		"All string constants of one script, grouped by function prototype (name, line, params). Good first look at an obfuscated script.",
		{ target, pattern: z.string().optional(), mode: z.enum(["plain", "pattern", "exact"]).optional(), case_insensitive: ci, min_length: z.number().int().optional(), include_numbers: z.boolean().optional(), include_empty: z.boolean().optional(), max_depth: z.number().int().optional() },
	);

	tool(
		"get_script_env",
		"Read a running script's environment (getsenv): its globals and functions as refs. The fastest way to find a script's state tables and callable functions.",
		{ target, filter: z.string().optional().describe("Filter keys by substring."), mode: z.enum(["plain", "pattern", "exact"]).optional(), depth: z.number().int().min(0).optional(), max_items: z.number().int().positive().optional() },
	);

	tool("get_script_closure", "Get the main closure of a script (getscriptclosure) as a function ref for further inspection.", { target });

	tool(
		"require_module",
		"require() a ModuleScript from the executor and serialize what it returns (tables/functions come back as refs).",
		{ target, timeout: z.number().positive().optional(), ...serOpts },
	);

	tool(
		"get_script_functions",
		"Find all live functions belonging to a script via the GC (matching function environment). Returns refs with name, line, params, upvalue count and optional string constants.",
		{ target, name: z.string().optional(), name_mode: nameMode, with_constants: z.boolean().optional(), limit: limit(100) },
	);

	tool(
		"dump_scripts",
		"Decompile many scripts and write them to the EXECUTOR's workspace folder (one .lua per script, mirroring the hierarchy). Use export_scripts to write to this computer instead.",
		{ ...scriptSelectors, folder: z.string().optional(), time_budget: timeBudget, start_index: startIndex, engine: z.enum(["dex", "builtin", "konstant", "shiny", "advanced"]).optional(), decompile_timeout: z.number().positive().optional() },
		{ defaults: searchDefaults, budget: true },
	);
}
