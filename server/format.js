// Result formatting: compact, LLM-friendly renderings of Dex++ serialized values and event logs.

const MAX_OUTPUT = Number(process.env.DEXMCP_MAX_OUTPUT ?? 120000);

export function truncate(text, max = MAX_OUTPUT) {
	if (text.length <= max) return text;
	return text.slice(0, max) + `\n... [output truncated: ${text.length - max} more characters; narrow the query or page with offset/limit]`;
}

const num = (n) => (Number.isInteger(n) ? String(n) : String(Math.round(n * 1e4) / 1e4));
const nums = (a) => (a ?? []).map(num).join(", ");

function q(s, max = 300) {
	s = String(s);
	const cut = s.length > max ? s.slice(0, max) + `…(+${s.length - max})` : s;
	return JSON.stringify(cut);
}

// Render a serialized value (see serialize.lua) on one line.
export function fmtVal(v, depth = 0) {
	if (v === null || v === undefined) return "nil";
	if (typeof v === "string") return q(v);
	if (typeof v === "number" || typeof v === "boolean") return String(v);
	if (Array.isArray(v)) {
		if (depth > 4) return `[…${v.length}]`;
		return "[" + v.map((x) => fmtVal(x, depth + 1)).join(", ") + "]";
	}
	if (typeof v !== "object") return String(v);
	const t = v["$t"];
	if (!t) {
		if (depth > 4) return "{…}";
		return "{" + Object.entries(v).map(([k, x]) => `${k}=${fmtVal(x, depth + 1)}`).join(", ") + "}";
	}
	switch (t) {
		case "Instance":
			return `<${v.class} ${v.path ?? v.str}${v.ref ? ` #${v.ref}` : ""}>`;
		case "Vector3": return `Vector3(${nums(v.v)})`;
		case "Vector2": return `Vector2(${nums(v.v)})`;
		case "Vector3int16": return `Vector3int16(${nums(v.v)})`;
		case "Vector2int16": return `Vector2int16(${nums(v.v)})`;
		case "CFrame": {
			const c = v.v ?? [];
			const identity = [1, 0, 0, 0, 1, 0, 0, 0, 1].every((x, i) => Math.abs((c[3 + i] ?? 0) - x) < 1e-4);
			return identity ? `CFrame(${nums(c.slice(0, 3))})` : `CFrame(pos ${nums(c.slice(0, 3))}, rot ${nums(c.slice(3))})`;
		}
		case "Color3": return `Color3(${v.hex})`;
		case "BrickColor": return `BrickColor(${v.name})`;
		case "UDim2": return `UDim2(${nums(v.v)})`;
		case "UDim": return `UDim(${nums(v.v)})`;
		case "Rect": return `Rect(${nums(v.v)})`;
		case "NumberRange": return `NumberRange(${nums(v.v)})`;
		case "EnumItem": return `Enum.${v.enum}.${v.name}`;
		case "Enum": return String(v.name);
		case "string": return q(v.v) + (v.truncated ? `(len ${v.len})` : "");
		case "bytes": return `bytes(${v.len})`;
		case "number": return String(v.v);
		case "function": {
			const where = v.short_src ?? v.source ?? "";
			return `function<${v.name ?? "anon"}${v.line ? `:${v.line}` : ""}${where ? ` ${where}` : ""}${v.lua_closure === false ? " C" : ""} #${v.ref}>`;
		}
		case "table":
		case "array": {
			const head = `#${v.ref}`;
			if (v.cycle) return `table${head}<cycle>`;
			if (v.items) {
				const more = v.more ? `, …+${v.more}` : "";
				return `${head}[` + (depth > 4 ? `…${v.count}` : v.items.map((x) => fmtVal(x, depth + 1)).join(", ")) + more + "]";
			}
			if (v.fields) {
				const more = v.more ? `, …+${v.more}` : "";
				return `${head}{` + (depth > 4 ? `…${v.count}` : Object.entries(v.fields).map(([k, x]) => `${k}=${fmtVal(x, depth + 1)}`).join(", ")) + more + "}";
			}
			return `table${head}(${v.count ?? 0}${v.collapsed ? " entries" : ""}${v.has_metatable ? ", mt" : ""})`;
		}
		case "Signal": return `Signal<${v.str} #${v.ref}>`;
		case "Connection": return `Connection#${v.ref}`;
		case "RaycastResult": return `RaycastResult(${fmtVal(v.instance)} at (${nums(v.position)}) dist ${num(v.distance)})`;
		case "buffer": return `buffer(${v.len})`;
		default:
			return `<${t}${v.str ? " " + v.str : ""}${v.ref ? ` #${v.ref}` : ""}>`;
	}
}

const args = (list) => (list ?? []).map((a) => fmtVal(a)).join(", ");

function when(t) {
	if (!t) return "";
	return new Date(t * 1000).toISOString().slice(11, 23);
}

// Render one event from the Dex++ event buffers.
export function fmtEvent(ev) {
	const head = `#${ev.seq} ${when(ev.t)}`;
	switch (ev.ch) {
		case "remote": {
			const dir = ev.dir === "in" ? "<-" : "->";
			const blocked = ev.blocked ? " [BLOCKED]" : "";
			let line = `${head} ${dir} ${ev.remote}:${ev.method}(${args(ev.args)})${blocked}`;
			if (ev.results) line += `\n      = ${args(ev.results)}`;
			if (ev.error) line += `\n      ERROR ${ev.error}`;
			if (ev.script) line += `\n      from ${ev.script}`;
			if (ev.stack) line += `\n      ${String(ev.stack).trim().replace(/\n/g, "\n      ")}`;
			return line + (ev.elapsed ? `  (${Math.round(ev.elapsed * 1000)}ms)` : "") + `  [remote #${ev.remote_ref}]`;
		}
		case "hook": {
			let line = `${head} hook#${ev.hook} ${ev.name}(${args(ev.args)})`;
			if (ev.results) line += ` = ${args(ev.results)}`;
			if (ev.error) line += ` ERROR ${ev.error}`;
			if (ev.script) line += `  from ${ev.script}`;
			if (ev.stack) line += `\n      ${String(ev.stack).trim().replace(/\n/g, "\n      ")}`;
			return line;
		}
		case "trap": {
			let line = `${head} trap#${ev.trap} ${ev.kind}:${ev.member} on ${ev.instance}`;
			if (ev.args) line += `(${args(ev.args)})`;
			if (ev.value !== undefined) line += ` -> ${fmtVal(ev.value)}`;
			if (ev.new_value !== undefined) line += ` = ${fmtVal(ev.new_value)}`;
			if (ev.script) line += `  from ${ev.script}`;
			if (ev.stack) line += `\n      ${String(ev.stack).trim().replace(/\n/g, "\n      ")}`;
			return line;
		}
		case "watch": {
			const what = ev.kind === "attribute" ? `${ev.instance}@${ev.attribute}` : `${ev.instance}.${ev.property}`;
			return `${head} watch#${ev.watch} ${what} = ${fmtVal(ev.value)}${ev.script ? `  from ${ev.script}` : ""}${ev.stack ? `\n      ${String(ev.stack).trim().replace(/\n/g, "\n      ")}` : ""}`;
		}
		case "tree":
			return `${head} tree ${ev.event} ${ev.path ?? ev.name} [${ev.class}] (under ${ev.parent}) #${ev.ref}`;
		case "signal":
			return `${head} signal#${ev.watch} ${ev.instance}.${ev.signal}(${args(ev.args)})`;
		case "http": {
			let line = `${head} ${ev.kind}`;
			if (ev.method) line += ` ${ev.method}`;
			if (ev.url) line += ` ${ev.url}`;
			if (ev.chunk) line += ` chunk=${ev.chunk} len=${ev.length}`;
			if (ev.status !== undefined) line += ` -> ${ev.status}`;
			if (ev.body) line += `\n      body: ${truncate(String(ev.body), 400)}`;
			if (ev.response_body) line += `\n      response: ${truncate(String(ev.response_body), 400)}`;
			if (ev.head) line += `\n      code: ${truncate(String(ev.head), 400)}`;
			if (ev.error) line += `\n      ERROR ${ev.error}`;
			if (ev.script) line += `\n      from ${ev.script}`;
			return line;
		}
		case "output":
			return `${head} [${ev.level}] ${ev.message}`;
		case "error":
			return `${head} ERROR ${ev.message}${ev.script ? `  (${ev.script})` : ""}${ev.stack ? `\n      ${String(ev.stack).trim().replace(/\n/g, "\n      ")}` : ""}`;
		default:
			return `${head} ${JSON.stringify(ev)}`;
	}
}

export function fmtEvents(res, extra = "") {
	const evs = res.events ?? res.messages ?? [];
	const lines = evs.map(fmtEvent);
	const meta = `-- ${evs.length} event(s)${res.matched !== undefined ? ` of ${res.matched} matched` : ""}; last_seq=${res.last_seq}${res.current_seq !== undefined ? ` current_seq=${res.current_seq}` : ""}${extra}`;
	return (lines.length ? lines.join("\n") + "\n" : "") + meta;
}

// default JSON rendering: pretty when small, compact when large
export function fmtJson(value) {
	const compact = JSON.stringify(value);
	if (compact === undefined) return "null";
	if (compact.length < 3000) return JSON.stringify(value, null, 2);
	return compact;
}

export function withLineNumbers(src, startLine = 1) {
	const lines = src.split("\n");
	const width = String(startLine + lines.length).length;
	return lines.map((l, i) => `${String(startLine + i).padStart(width)}  ${l}`).join("\n");
}
