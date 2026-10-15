#!/usr/bin/env node
// Syntax-checks every lua/*.lua part plus the generated module with luaparse (Lua 5.1 grammar).
// The bridge deliberately sticks to the Lua 5.1 subset of Luau (no `continue`, `+=`, type annotations,
// backtick strings) so it can be validated here and still run in every executor.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import luaparse from "luaparse";
import { buildModule } from "./embed.js";

const here = path.dirname(fileURLToPath(import.meta.url));
const luaDir = path.join(here, "..", "lua");
let bad = 0;

function check(name, src) {
	try {
		luaparse.parse(src, { luaVersion: "5.1", comments: false, locations: true });
		console.log(`ok    ${name}`);
	} catch (e) {
		bad++;
		console.log(`FAIL  ${name}: ${e.message}`);
	}
}

for (const f of fs.readdirSync(luaDir).filter((x) => x.endsWith(".lua")).sort()) {
	check(f, fs.readFileSync(path.join(luaDir, f), "utf8"));
}

// the generated module is a table-constructor entry; wrap it so it parses standalone
const mod = buildModule();
check("generated MCPBridge module", `local EmbeddedModules = {\n${mod}\n}`);

if (process.argv[2]) {
	check(process.argv[2], fs.readFileSync(process.argv[2], "utf8"));
}

process.exit(bad ? 1 : 0);
