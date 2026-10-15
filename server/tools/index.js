import { makeRegistry } from "./common.js";
import { register as instances } from "./instances.js";
import { register as scripts } from "./scripts.js";
import { register as runtime } from "./runtime.js";
import { register as world } from "./world.js";
import { register as session } from "./session.js";

const GROUPS = [
	["Session, events and utilities", session],
	["Instances, properties and reflection", instances],
	["Scripts", scripts],
	["Lua runtime, hooks and remote spy", runtime],
	["Execution, game world, GUI, snapshots and Dex++", world],
];

export function buildTools(ctx) {
	const reg = makeRegistry();
	for (const [group, register] of GROUPS) {
		const before = reg.defs.length;
		register(reg, ctx);
		for (const d of reg.defs.slice(before)) d.group = group;
	}
	return reg.defs;
}

export { GROUPS };
