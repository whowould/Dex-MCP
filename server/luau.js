// Luau bytecode parser + disassembler (bytecode versions 3-14, type versions 1-3).
// Opcode numbering and serialization layout follow luau-lang/luau Common/include/Luau/Bytecode.h and VM/src/lvmload.cpp.
// Roblox client bytecode stores opcodes multiplied by 227 (mod 256); this is auto-detected and undone.

export const OPS = [
	"NOP", "BREAK", "LOADNIL", "LOADB", "LOADN", "LOADK", "MOVE", "GETGLOBAL", "SETGLOBAL", "GETUPVAL", "SETUPVAL", "CLOSEUPVALS",
	"GETIMPORT", "GETTABLE", "SETTABLE", "GETTABLEKS", "SETTABLEKS", "GETTABLEN", "SETTABLEN", "NEWCLOSURE", "NAMECALL", "CALL", "RETURN",
	"JUMP", "JUMPBACK", "JUMPIF", "JUMPIFNOT", "JUMPIFEQ", "JUMPIFLE", "JUMPIFLT", "JUMPIFNOTEQ", "JUMPIFNOTLE", "JUMPIFNOTLT",
	"ADD", "SUB", "MUL", "DIV", "MOD", "POW", "ADDK", "SUBK", "MULK", "DIVK", "MODK", "POWK", "AND", "OR", "ANDK", "ORK", "CONCAT",
	"NOT", "MINUS", "LENGTH", "NEWTABLE", "DUPTABLE", "SETLIST", "FORNPREP", "FORNLOOP", "FORGLOOP", "FORGPREP_INEXT", "FASTCALL3",
	"FORGPREP_NEXT", "NATIVECALL", "GETVARARGS", "DUPCLOSURE", "PREPVARARGS", "LOADKX", "JUMPX", "FASTCALL", "COVERAGE", "CAPTURE",
	"SUBRK", "DIVRK", "FASTCALL1", "FASTCALL2", "FASTCALL2K", "FORGPREP", "JUMPXEQKNIL", "JUMPXEQKB", "JUMPXEQKN", "JUMPXEQKS",
	"IDIV", "IDIVK", "GETUDATAKS", "SETUDATAKS", "NAMECALLUDATA", "NEWCLASSMEMBER", "CALLFB", "CMPPROTO", "FASTPCALL", "NEWCLASS",
	"CONSTRUCT", "FINCONSTRUCT",
];
const OP = Object.fromEntries(OPS.map((n, i) => [n, i]));

// instructions followed by an AUX word
const HAS_AUX = new Set(
	["GETGLOBAL", "SETGLOBAL", "GETIMPORT", "GETTABLEKS", "SETTABLEKS", "NAMECALL", "JUMPIFEQ", "JUMPIFLE", "JUMPIFLT", "JUMPIFNOTEQ", "JUMPIFNOTLE", "JUMPIFNOTLT",
		"NEWTABLE", "SETLIST", "FORGLOOP", "LOADKX", "FASTCALL2", "FASTCALL2K", "FASTCALL3", "JUMPXEQKNIL", "JUMPXEQKB", "JUMPXEQKN", "JUMPXEQKS",
		"GETUDATAKS", "SETUDATAKS", "NAMECALLUDATA", "NEWCLASSMEMBER", "CALLFB", "CMPPROTO", "NEWCLASS", "CONSTRUCT"].map((n) => OP[n]),
);

const BUILTINS = [
	"none", "assert", "math.abs", "math.acos", "math.asin", "math.atan2", "math.atan", "math.ceil", "math.cosh", "math.cos", "math.deg", "math.exp",
	"math.floor", "math.fmod", "math.frexp", "math.ldexp", "math.log10", "math.log", "math.max", "math.min", "math.modf", "math.pow", "math.rad",
	"math.sinh", "math.sin", "math.sqrt", "math.tanh", "math.tan", "bit32.arshift", "bit32.band", "bit32.bnot", "bit32.bor", "bit32.bxor", "bit32.btest",
	"bit32.extract", "bit32.lrotate", "bit32.lshift", "bit32.replace", "bit32.rrotate", "bit32.rshift", "type", "string.byte", "string.char", "string.len",
	"typeof", "string.sub", "math.clamp", "math.sign", "math.round", "rawset", "rawget", "rawequal", "table.insert", "table.unpack", "Vector3.new",
	"bit32.countlz", "bit32.countrz", "select(_, ...)", "rawlen", "bit32.extract(k,k)", "getmetatable", "setmetatable", "tonumber", "tostring",
	"bit32.byteswap", "buffer.readi8", "buffer.readu8", "buffer.writeu8", "buffer.readi16", "buffer.readu16", "buffer.writeu16", "buffer.readi32",
	"buffer.readu32", "buffer.writeu32", "buffer.readf32", "buffer.writef32", "buffer.readf64", "buffer.writef64", "vector.magnitude", "vector.normalize",
	"vector.cross", "vector.dot", "vector.floor", "vector.ceil", "vector.abs", "vector.sign", "vector.clamp", "vector.min", "vector.max", "math.lerp",
	"vector.lerp", "math.isnan", "math.isinf", "math.isfinite",
];

const K = { NIL: 0, BOOLEAN: 1, NUMBER: 2, STRING: 3, IMPORT: 4, TABLE: 5, CLOSURE: 6, VECTOR: 7, TABLE_WITH_CONSTANTS: 8, INTEGER: 9, CLASS_SHAPE: 10, VECTORD: 11 };

class Reader {
	constructor(buf) {
		this.b = buf;
		this.o = 0;
	}
	u8() {
		if (this.o >= this.b.length) throw new Error("unexpected end of bytecode");
		return this.b[this.o++];
	}
	u32() {
		const v = this.b.readUInt32LE(this.o);
		this.o += 4;
		return v;
	}
	i32() {
		const v = this.b.readInt32LE(this.o);
		this.o += 4;
		return v;
	}
	f32() {
		const v = this.b.readFloatLE(this.o);
		this.o += 4;
		return v;
	}
	f64() {
		const v = this.b.readDoubleLE(this.o);
		this.o += 8;
		return v;
	}
	varint() {
		let result = 0;
		let shift = 0;
		for (;;) {
			const byte = this.u8();
			result += (byte & 127) * 2 ** shift;
			if (!(byte & 128)) break;
			shift += 7;
			if (shift > 35) throw new Error("bad varint");
		}
		return result;
	}
	varint64() {
		let result = 0n;
		let shift = 0n;
		for (;;) {
			const byte = this.u8();
			result |= BigInt(byte & 127) << shift;
			if (!(byte & 128)) break;
			shift += 7n;
		}
		return result;
	}
	bytes(n) {
		const s = this.b.subarray(this.o, this.o + n);
		this.o += n;
		return s;
	}
}

function opAt(word, decode) {
	return decode((word & 0xff) >>> 0);
}

// walk the code array; returns false if the instruction stream is malformed under this decoding
function validWalk(code, decode) {
	let pc = 0;
	while (pc < code.length) {
		const op = opAt(code[pc], decode);
		if (op >= OPS.length) return false;
		pc += HAS_AUX.has(op) ? 2 : 1;
	}
	return pc === code.length;
}

export function disassemble(buf, { encoding = "auto" } = {}) {
	const r = new Reader(buf);
	const version = r.u8();
	if (version === 0) {
		throw new Error("bytecode is an error message: " + buf.subarray(1).toString("utf8"));
	}
	if (version < 3 || version > 14) throw new Error(`unsupported bytecode version ${version} (supported 3-14)`);
	let typesVersion = 0;
	if (version >= 4) typesVersion = r.u8();

	const nstr = r.varint();
	const strs = [];
	for (let i = 0; i < nstr; i++) {
		const len = r.varint();
		strs.push(r.bytes(len).toString("utf8"));
	}
	const str = (idx) => (idx === 0 ? null : strs[idx - 1]);

	if (typesVersion === 3) {
		for (let index = r.u8(); index !== 0; index = r.u8()) r.varint(); // userdata type name
	}

	const nproto = r.varint();
	const protos = [];
	const decoders = {
		plain: (x) => x,
		roblox: (x) => (x * 203) & 0xff,
	};
	for (let i = 0; i < nproto; i++) {
		const p = { index: i };
		// version 12+ prefixes every proto with its byte size so readers can skip unknown trailing data
		let protoEnd = null;
		if (version >= 12) {
			const protoSize = r.varint();
			protoEnd = r.o + protoSize;
		}
		p.maxstack = r.u8();
		p.numparams = r.u8();
		p.nups = r.u8();
		p.vararg = r.u8() !== 0;
		if (version >= 4) {
			p.flags = r.u8();
			const tsize = r.varint();
			p.typeinfo = tsize ? Buffer.from(r.bytes(tsize)) : null;
		}
		const sizecode = r.varint();
		p.code = new Array(sizecode);
		for (let j = 0; j < sizecode; j++) p.code[j] = r.u32();

		const sizek = r.varint();
		p.k = new Array(sizek);
		for (let j = 0; j < sizek; j++) {
			const t = r.u8();
			switch (t) {
				case K.NIL: p.k[j] = { t: "nil" }; break;
				case K.BOOLEAN: p.k[j] = { t: "boolean", v: r.u8() !== 0 }; break;
				case K.NUMBER: p.k[j] = { t: "number", v: r.f64() }; break;
				case K.STRING: p.k[j] = { t: "string", v: str(r.varint()) }; break;
				case K.IMPORT: p.k[j] = { t: "import", id: r.u32() }; break;
				case K.TABLE: {
					const n = r.varint();
					const keys = [];
					for (let q = 0; q < n; q++) keys.push(r.varint());
					p.k[j] = { t: "table", keys };
					break;
				}
				case K.TABLE_WITH_CONSTANTS: {
					const n = r.varint();
					const keys = [];
					for (let q = 0; q < n; q++) {
						const key = r.varint();
						r.i32(); // constant index of the pre-filled value (not needed for listing)
						keys.push(key);
					}
					p.k[j] = { t: "table", keys, withConstants: true };
					break;
				}
				case K.CLOSURE: p.k[j] = { t: "closure", proto: r.varint() }; break;
				case K.VECTOR: p.k[j] = { t: "vector", v: [r.f32(), r.f32(), r.f32(), r.f32()] }; break;
				case K.VECTORD: p.k[j] = { t: "vector", v: [r.f64(), r.f64(), r.f64(), r.f64()] }; break;
				case K.INTEGER: {
					const neg = r.u8() !== 0;
					const mag = r.varint64();
					p.k[j] = { t: "integer", v: neg ? -mag : mag };
					break;
				}
				case K.CLASS_SHAPE: {
					r.varint(); // class name constant
					const nprops = r.varint();
					const nmethods = r.varint();
					for (let q = 0; q < nprops + nmethods; q++) r.varint();
					p.k[j] = { t: "class_shape" };
					break;
				}
				default:
					throw new Error(`unsupported constant kind ${t} in proto ${i}`);
			}
		}
		const sizep = r.varint();
		p.children = [];
		for (let j = 0; j < sizep; j++) p.children.push(r.varint());
		p.linedefined = r.varint();
		p.debugname = str(r.varint());

		if (r.u8()) {
			const gaplog2 = r.u8();
			const intervals = ((sizecode - 1) >> gaplog2) + 1;
			const deltas = new Array(sizecode);
			let last = 0;
			for (let j = 0; j < sizecode; j++) {
				last = (last + r.u8()) & 0xff;
				deltas[j] = last;
			}
			const abs = new Array(intervals);
			let lastLine = 0;
			for (let j = 0; j < intervals; j++) {
				lastLine += r.i32();
				abs[j] = lastLine;
			}
			p.line = (pc) => abs[pc >> gaplog2] + deltas[pc];
		}
		if (r.u8()) {
			const nloc = r.varint();
			p.locvars = [];
			for (let j = 0; j < nloc; j++) {
				p.locvars.push({ name: str(r.varint()), startpc: r.varint(), endpc: r.varint(), reg: r.u8() });
			}
			const nup = r.varint();
			p.upnames = [];
			for (let j = 0; j < nup; j++) p.upnames.push(str(r.varint()));
		}
		if (version >= 11) {
			// feedback vector slots (call-target / construct profiling) - not needed for a listing
			const nfeedback = r.varint();
			for (let j = 0; j < nfeedback; j++) {
				const kind = r.u8();
				r.varint(); // pc (call target) or shape id (construct)
				if (kind > 1) throw new Error(`unknown feedback slot kind ${kind}`);
			}
		}
		if (version >= 12 && (p.flags & 8) !== 0) r.varint64(); // inline cost of LPF_INLINABLE protos
		if (protoEnd !== null) r.o = protoEnd;
		protos.push(p);
	}
	const main = r.varint();

	// pick opcode decoding using the first proto that has code
	let chosen = encoding === "plain" ? "plain" : encoding === "roblox" ? "roblox" : null;
	if (!chosen) {
		const withCode = protos.filter((p) => p.code.length > 0);
		const plainOk = withCode.every((p) => validWalk(p.code, decoders.plain));
		const robloxOk = withCode.every((p) => validWalk(p.code, decoders.roblox));
		chosen = plainOk && !robloxOk ? "plain" : robloxOk && !plainOk ? "roblox" : plainOk ? "plain" : "roblox";
	}
	const decode = decoders[chosen];

	for (const p of protos) {
		p.insns = [];
		let pc = 0;
		while (pc < p.code.length) {
			const word = p.code[pc];
			const op = opAt(word, decode);
			const name = OPS[op] ?? `OP_${op}`;
			const ins = { pc, op, name, word, a: (word >>> 8) & 0xff, b: (word >>> 16) & 0xff, c: (word >>> 24) & 0xff, d: word >> 16, e: word >> 8 };
			if (HAS_AUX.has(op)) {
				ins.aux = p.code[pc + 1] >>> 0;
				ins.len = 2;
			} else ins.len = 1;
			p.insns.push(ins);
			pc += ins.len;
		}
	}
	return { version, typesVersion, strings: strs, protos, main, encoding: chosen };
}

const fmtNum = (n) => (Number.isInteger(n) ? String(n) : String(+n.toPrecision(15)));

function kText(prog, p, idx) {
	const k = p.k[idx];
	if (!k) return `K${idx}<?>`;
	switch (k.t) {
		case "nil": return "nil";
		case "boolean": return String(k.v);
		case "number": return fmtNum(k.v);
		case "string": return JSON.stringify(k.v);
		case "integer": return `${k.v}i`;
		case "vector": return `vector(${k.v.map(fmtNum).join(", ")})`;
		case "import": return `import ${importText(prog, p, k.id)}`;
		case "table": return `table{${k.keys.map((x) => kText(prog, p, x)).join(", ")}}`;
		case "closure": return `closure<proto ${k.proto}>`;
		default: return k.t;
	}
}

function importText(prog, p, id) {
	const count = id >>> 30;
	const ids = [(id >>> 20) & 1023, (id >>> 10) & 1023, id & 1023].slice(0, count);
	return ids.map((i) => (p.k[i]?.t === "string" ? p.k[i].v : `K${i}`)).join(".");
}

function rr(n) { return `R${n}`; }

function operands(prog, p, ins) {
	const { a, b, c, d, e, aux } = ins;
	const target = (off) => `-> ${String(ins.pc + 1 + off).padStart(4, "0")}`;
	const K_ = (i) => `K${i}`;
	switch (ins.name) {
		case "NOP": case "BREAK": case "NATIVECALL": return ["", ""];
		case "LOADNIL": return [rr(a), "nil"];
		case "LOADB": return [`${rr(a)} ${b}`, `${b ? "true" : "false"}${c ? ` ${target(c)}` : ""}`];
		case "LOADN": return [`${rr(a)} ${d}`, ""];
		case "LOADK": return [`${rr(a)} ${K_(d)}`, kText(prog, p, d)];
		case "LOADKX": return [`${rr(a)} ${K_(aux)}`, kText(prog, p, aux)];
		case "MOVE": return [`${rr(a)} ${rr(b)}`, ""];
		case "GETGLOBAL": case "SETGLOBAL": return [`${rr(a)} ${K_(aux)}`, `_G.${p.k[aux]?.v ?? "?"}`];
		case "GETUPVAL": case "SETUPVAL": return [`${rr(a)} U${b}`, ""];
		case "CLOSEUPVALS": return [rr(a), ""];
		case "GETIMPORT": return [`${rr(a)} ${K_(d)}`, importText(prog, p, aux)];
		case "GETTABLE": case "SETTABLE": return [`${rr(a)} ${rr(b)} ${rr(c)}`, ""];
		case "GETTABLEKS": case "SETTABLEKS": return [`${rr(a)} ${rr(b)} ${K_(aux)}`, `.${p.k[aux]?.v ?? "?"}`];
		case "GETUDATAKS": case "SETUDATAKS": return [`${rr(a)} ${rr(b)} ${K_(aux & 0xffff)}`, `.${p.k[aux & 0xffff]?.v ?? "?"}`];
		case "GETTABLEN": case "SETTABLEN": return [`${rr(a)} ${rr(b)} ${c + 1}`, ""];
		case "NEWCLOSURE": return [`${rr(a)} P${d}`, `proto ${p.children[d]}${prog.protos[p.children[d]]?.debugname ? ` "${prog.protos[p.children[d]].debugname}"` : ""}`];
		case "DUPCLOSURE": return [`${rr(a)} ${K_(d)}`, kText(prog, p, d)];
		case "NAMECALL": return [`${rr(a)} ${rr(b)} ${K_(aux)}`, `:${p.k[aux]?.v ?? "?"}`];
		case "NAMECALLUDATA": return [`${rr(a)} ${rr(b)} ${K_(aux & 0xffff)}`, `:${p.k[aux & 0xffff]?.v ?? "?"}`];
		case "CALL": return [`${rr(a)} ${b} ${c}`, `${b ? b - 1 : "*"} arg(s), ${c ? c - 1 : "*"} result(s)`];
		case "RETURN": return [`${rr(a)} ${b}`, b ? `${b - 1} value(s)` : "all"];
		case "JUMP": case "JUMPBACK": return [target(d), ""];
		case "JUMPX": return [target(e), ""];
		case "JUMPIF": case "JUMPIFNOT": return [`${rr(a)} ${target(d)}`, ""];
		case "JUMPIFEQ": case "JUMPIFLE": case "JUMPIFLT": case "JUMPIFNOTEQ": case "JUMPIFNOTLE": case "JUMPIFNOTLT":
			return [`${rr(a)} ${rr(aux)} ${target(d)}`, ""];
		case "JUMPXEQKNIL": return [`${rr(a)} ${target(d)}`, `${aux >>> 31 ? "~=" : "=="} nil`];
		case "JUMPXEQKB": return [`${rr(a)} ${target(d)}`, `${aux >>> 31 ? "~=" : "=="} ${(aux & 1) ? "true" : "false"}`];
		case "JUMPXEQKN": case "JUMPXEQKS": return [`${rr(a)} ${K_(aux & 0xffffff)} ${target(d)}`, `${aux >>> 31 ? "~=" : "=="} ${kText(prog, p, aux & 0xffffff)}`];
		case "ADD": case "SUB": case "MUL": case "DIV": case "MOD": case "POW": case "IDIV": case "AND": case "OR":
			return [`${rr(a)} ${rr(b)} ${rr(c)}`, ""];
		case "ADDK": case "SUBK": case "MULK": case "DIVK": case "MODK": case "POWK": case "IDIVK": case "ANDK": case "ORK":
			return [`${rr(a)} ${rr(b)} ${K_(c)}`, kText(prog, p, c)];
		case "SUBRK": case "DIVRK": return [`${rr(a)} ${K_(b)} ${rr(c)}`, kText(prog, p, b)];
		case "CONCAT": return [`${rr(a)} ${rr(b)} ${rr(c)}`, `R${b}..R${c}`];
		case "NOT": case "MINUS": case "LENGTH": return [`${rr(a)} ${rr(b)}`, ""];
		case "NEWTABLE": return [`${rr(a)} ${b} ${aux}`, `hash ${b ? 2 ** (b - 1) : 0}, array ${aux}`];
		case "DUPTABLE": return [`${rr(a)} ${K_(d)}`, kText(prog, p, d)];
		case "SETLIST": return [`${rr(a)} ${rr(b)} ${c} ${aux}`, `${c ? c - 1 : "*"} value(s) from index ${aux}`];
		case "FORNPREP": case "FORNLOOP": case "FORGPREP": case "FORGPREP_INEXT": case "FORGPREP_NEXT": return [`${rr(a)} ${target(d)}`, ""];
		case "FORGLOOP": return [`${rr(a)} ${target(d)} ${aux & 0xff}`, `${aux & 0xff} variable(s)${aux >>> 31 ? ", ipairs-style" : ""}`];
		case "GETVARARGS": return [`${rr(a)} ${b}`, b ? `${b - 1} value(s)` : "all"];
		case "PREPVARARGS": return [`${a}`, `${a} fixed param(s)`];
		case "COVERAGE": return [`${e}`, ""];
		case "CAPTURE": return [`${["VAL", "REF", "UPVAL"][a] ?? a} ${a === 2 ? `U${b}` : rr(b)}`, ""];
		case "FASTCALL": return [`${a} ${target(c)}`, BUILTINS[a] ?? `builtin ${a}`];
		case "FASTCALL1": return [`${a} ${rr(b)} ${target(c)}`, BUILTINS[a] ?? `builtin ${a}`];
		case "FASTCALL2": return [`${a} ${rr(b)} ${rr(aux & 0xff)} ${target(c)}`, BUILTINS[a] ?? `builtin ${a}`];
		case "FASTCALL2K": return [`${a} ${rr(b)} ${K_(aux)} ${target(c)}`, `${BUILTINS[a] ?? `builtin ${a}`}(.., ${kText(prog, p, aux)})`];
		case "FASTCALL3": return [`${a} ${rr(b)} ${rr(aux & 0xff)} ${rr((aux >> 8) & 0xff)} ${target(c)}`, BUILTINS[a] ?? `builtin ${a}`];
		case "FASTPCALL": return [`${a} ${b} ${target(c)}`, a === 0 ? "pcall" : "xpcall"];
		default:
			return [`${a} ${b} ${c}${aux !== undefined ? ` aux=${aux}` : ""}`, ""];
	}
}

export function formatProto(prog, p) {
	const lines = [];
	const nm = p.debugname ? `"${p.debugname}"` : "<anonymous>";
	lines.push(`proto ${p.index} ${nm}${p.index === prog.main ? " (main)" : ""}: params=${p.numparams}${p.vararg ? "+vararg" : ""} upvalues=${p.nups} stack=${p.maxstack} line=${p.linedefined}${p.children.length ? ` children=[${p.children.join(",")}]` : ""}`);
	if (p.upnames?.length) lines.push(`  upvalue names: ${p.upnames.map((n, i) => `U${i}=${n}`).join(", ")}`);
	if (p.locvars?.length) {
		lines.push("  locals: " + p.locvars.map((l) => `${l.name}@R${l.reg}[${l.startpc}-${l.endpc}]`).join(" "));
	}
	if (p.k.length) {
		lines.push("  constants:");
		p.k.forEach((_, i) => lines.push(`    K${i} = ${kText(prog, p, i)}`));
	}
	lines.push("  code:");
	let lastLine = null;
	for (const ins of p.insns) {
		const [ops, comment] = operands(prog, p, ins);
		const ln = p.line ? p.line(ins.pc) : null;
		const lcol = ln !== null && ln !== lastLine ? `L${String(ln).padEnd(5)}` : "      ";
		lastLine = ln ?? lastLine;
		lines.push(`    ${String(ins.pc).padStart(4, "0")} ${lcol} ${ins.name.padEnd(14)} ${ops}${comment ? `  ; ${comment}` : ""}`);
	}
	return lines.join("\n");
}

export function formatListing(prog, { proto, maxLines = 3000 } = {}) {
	const head = `-- luau bytecode v${prog.version} (types v${prog.typesVersion}), ${prog.protos.length} proto(s), ${prog.strings.length} string(s), opcode encoding: ${prog.encoding}`;
	const chosen = proto !== undefined ? prog.protos.filter((p) => p.index === proto) : prog.protos;
	let out = [head, ...chosen.map((p) => formatProto(prog, p))].join("\n\n").split("\n");
	if (out.length > maxLines) {
		const cut = out.length - maxLines;
		out = out.slice(0, maxLines);
		out.push(`... [${cut} more lines; pass proto=N to view one function]`);
	}
	return out.join("\n");
}
