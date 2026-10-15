// Shared schema fragments + the tiny DSL used by every tool file.
import { z } from "zod";

export { z };

export const TARGET_DOC =
	'Instance reference. Accepts: a Lua path ("game.Workspace.Model.Part", game:GetService("Players").LocalPlayer, game.Workspace["My Part"], ' +
	'game.X:GetChildren()[3]), a ref id from an earlier result (number or "#12"), getnil("Class","Name") for nil-parented instances, or "debugid:<id>". ' +
	"Every instance in a result carries both its path and its ref - prefer ref ids for repeated access.";

export const VALUE_DOC =
	'JSON value mapped to a Lua value. Roblox datatypes use tagged objects: {"$t":"Vector3","v":[x,y,z]}, {"$t":"CFrame","v":[x,y,z]} or 12 components, ' +
	'{"$t":"Color3","v":[r,g,b]} (0-1) or {"$t":"Color3","hex":"#ff0000"}, {"$t":"UDim2","v":[xs,xo,ys,yo]}, {"$t":"EnumItem","enum":"Material","name":"Neon"}, ' +
	'{"$t":"Instance","path":"game.Workspace.Part"}, {"$t":"ref","id":12} (any earlier ref: function/table/instance), {"$t":"nil"}. ' +
	"Property writes also accept plain forms using the API type: Vector3 [1,2,3], Color3 \"#ff0000\", enums by name \"Neon\", Instances by path.";

export const REF_DOC = 'Ref id of a function/table/userdata/instance returned by an earlier call (number or "#12").';

export const target = z.union([z.string(), z.number()]).describe(TARGET_DOC);
export const optTarget = target.optional();
export const ref = z.union([z.number(), z.string()]).describe(REF_DOC);
export const value = z.any().describe(VALUE_DOC);
export const nameMode = z.enum(["plain", "pattern", "exact"]).optional().describe('How "name"/pattern text is matched: plain substring (default), Lua pattern, or exact.');
export const ci = z.boolean().optional().describe("Case-insensitive matching (default true).");

export const int = (desc) => z.number().int().optional().describe(desc);
export const limit = (def) => z.number().int().positive().optional().describe(`Maximum results to return (default ${def}).`);
export const offset = z.number().int().min(0).optional().describe("Skip this many results (use next_offset from the previous page).");
export const depth = (def = 2) => z.number().int().min(0).optional().describe(`Serialization depth for nested tables (default ${def}).`);
export const maxItems = z.number().int().positive().optional().describe("Max entries shown per table/array in serialized values.");
export const maxStr = z.number().int().positive().optional().describe("Max characters kept per string in serialized values.");
export const timeBudget = z.number().positive().optional().describe("Seconds the game may spend before returning a partial result (use next_start_index to continue).");
export const startIndex = z.number().int().positive().optional().describe("Resume index from a previous partial result (next_start_index).");
export const args = z.array(z.any()).optional().describe("Call arguments as a JSON array; elements use the value format above. Use {\"$t\":\"nil\"} for nil.");

// serialization knobs shared by many tools
export const serOpts = { depth: depth(), max_items: maxItems, max_str: maxStr };

const RO_PREFIXES = ["get_", "list_", "find_", "search_", "inspect_", "decompile_", "resolve_", "compare_", "is_", "dump_function", "remote_spy_get", "remote_spy_summary", "remote_call_detail", "gc_stats", "table_search", "gc_search", "world_to_screen", "screen_to_ray", "raycast", "compile_check", "diff_", "wait_for_", "require_module"];

export function isReadOnly(name) {
	return RO_PREFIXES.some((p) => name.startsWith(p));
}

/**
 * tool(name, description, shape, opts)
 *   opts.cmd        Lua command (default: name)
 *   opts.route      (args) => ({cmd, params, timeoutMs?})   for action-multiplexed tools
 *   opts.defaults   params merged under the caller's args
 *   opts.timeout    ms (default 30000); opts.budget: derive timeout from args.time_budget/args.timeout (+15s)
 *   opts.format     (result, args) => string
 *   opts.ro / opts.destructive   MCP annotations
 *   opts.run        (args, ctx) => string   fully custom (server-side tools)
 */
export function makeRegistry() {
	const defs = [];
	function tool(name, description, shape, opts = {}) {
		if (defs.some((d) => d.name === name)) throw new Error(`duplicate tool ${name}`);
		defs.push({ name, description, shape: shape ?? {}, ...opts });
	}
	return { defs, tool };
}
