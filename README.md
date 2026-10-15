# dexpp-mcp — an MCP server for Dex++

Drive a **live Roblox client** from any MCP client (Claude Code, Claude Desktop, ...). Dex++ gets a new
`MCPBridge` module; this server is the other end of the wire. 164 tools cover the whole reversing loop:
explorer, properties, scripts (decompile / bytecode / constants / environments), remote spy, GC and
upvalue inspection, metamethod traps, function hooks, watches, GUI, snapshots and diffing, arbitrary Lua.

```
MCP client ──stdio──> dexpp-mcp (this server) <──WebSocket / HTTP long-poll── Dex++ MCPBridge ── game
```

## Quick start

1. **Server deps** (already installed here): `cd dexmcp && npm install`
2. **Register the server** with your MCP client.
   - Claude Code (installed here at user scope; run `claude mcp list` to check, `claude mcp remove dexpp -s user` to undo):
     ```bash
     claude mcp add --scope user dexpp -- node /absolute/path/to/dexmcp/server/index.js
     ```
     The server is started by the MCP client itself; do not also run `npm start` by hand, a leftover instance keeps port 18764 and Dex++ will stay attached to it.
   - Claude Desktop (`claude_desktop_config.json`):
     ```json
     { "mcpServers": { "dexpp": { "command": "node", "args": ["C:/path/to/dexmcp/server/index.js"] } } }
     ```
3. **Run the patched `dexplusplus.lua`** in your executor. A new **MCP** window appears in the Dex++ menu
   (status, host/port, connect/disconnect). It auto-connects to `127.0.0.1:18764`.
4. In the MCP client call `get_status` (or `wait_for_client` right after launching).

The patched Dex++ file is `../dexplusplus.lua` (original kept as `../dexplusplus.lua.orig`).

## Configuration

| where | name | meaning |
|---|---|---|
| server env | `DEXMCP_PORT` | bridge port, default `18764` (if busy the next 9 ports are tried) |
| server env | `DEXMCP_HOST` | bind address, default `127.0.0.1` — keep it local |
| server env | `DEXMCP_TOKEN` | optional shared secret, must equal `Settings.MCP.Token` in Dex++ |
| server env | `DEXMCP_TIMEOUT` | default per-call timeout ms (30000) |
| server env | `DEXMCP_MAX_OUTPUT` | max characters returned per tool call (120000) |
| Dex++ `Settings.MCP` | `Host` `Port` `AutoConnect` `Token` `Transport` `PortScan` `Reconnect` `MaxRefs` | editable in the MCP window / `dex_settings` tool; `Transport` = `auto` \| `websocket` \| `http` |

Connecting: Dex++ first finds the server by probing `GET /health` on `Port`..`Port+9` (the server takes the next free port
when its own is busy), then tries `WebSocket.connect`; if that fails for any reason it immediately falls back to HTTP
long-polling through the executor's `request()` on the same port. The MCP window shows the exact reason on failure
(e.g. `websocket: ... | http: hello failed (HTTP 403 ...)`). Replies over 200 KB are sent in chunks and reassembled.

## Conventions you (and the model) need

- **Targets.** Instances are addressed by Lua path (`game.Workspace.Map["Door 2"]`,
  `game:GetService("Players").LocalPlayer`, `game.X:GetChildren()[3]`), by `getnil("Class","Name")`, or by a
  **ref id**. Every instance, function, table, userdata and thread in a result carries a `ref` you can pass back
  to other tools. Refs are held until `release_refs` or eviction (`MaxRefs`).
- **Values.** Plain JSON for primitives. Roblox datatypes are tagged objects
  (`{"$t":"Vector3","v":[1,2,3]}`, `{"$t":"Instance","path":"game.Workspace.Part","ref":12}`,
  `{"$t":"EnumItem","enum":"Material","name":"Neon"}`, `{"$t":"ref","id":12}`, `{"$t":"nil"}`).
  Property writes also take plain forms using the API type: `Vector3 [1,2,3]`, `Color3 "#ff0000"`, enums by name.
- **Events.** Remote spy, hooks, traps, watches, console output and script errors buffer **inside the game**
  (`remote`, `hook`, `trap`, `watch`, `tree`, `signal`, `http`, `output`, `error` channels). Read them with
  `remote_spy_get` / `get_events` / `wait_for_events` and tail with `since=<last_seq>`.
- **Long scans** (`search_scripts`, `gc_search`, `dump_scripts`, ...) take `time_budget`, never freeze the game
  (they yield cooperatively) and return `partial` + `next_start_index`.
- **Capabilities.** Tools that need an executor API you lack fail with a clear message; `get_capabilities`
  lists what exists. `execute_lua` is the universal escape hatch, `raw_command` reaches any bridge command.

## A reversing session, in tool calls

```text
get_game_info · get_tree{depth:3} · list_remotes · list_scripts
remote_spy{action:start}                     # then play the game / click things
remote_spy_summary · remote_spy_get{remote:"Attack"} · remote_call_detail{seq}
get_remote_handlers{target:remote}           # jump to the receiving function + script
search_scripts{pattern:"Detected"} · search_constants{pattern:"kick"}
decompile_script{target, line_numbers:true} · get_script_env · upvalues · get_table
gc_find_value{value:1234}                    # find where the coin count lives
hook_function{ref, mode:"log"} · trap_add{kind:"newindex", member:"WalkSpeed", capture_stack:true}
fire_remote / remote_replay{seq, modify:[{index:2,value:99}]}
snapshot_tree → (do something) → diff_tree_snapshot
export_scripts{dir:"./game-scripts"}         # decompile everything to disk, grep it locally
disassemble_bytecode{target}                 # Luau bytecode listing when decompiling is poor
```

The complete catalogue with every parameter is in [`TOOLS.md`](TOOLS.md) (generated: `npm run docs`).

## Dex++ integration

The bridge is an ordinary Dex++ module (`["MCPBridge"]` in `EmbeddedModules`) wired into `Main.ModuleList`,
`Main.Init` and the app menu; failures inside it only print a warning and never stop Dex++. It reuses Dex's
API dump (typed properties/enums), its decompiler chain (`Settings.Decompiler`: native → Konstant / Shiny /
Advanced), selection, Explorer search, Notepad, 3D viewer and settings (`dex_*` tools), and `saveinstance`.

## Security

- The server binds to loopback only and **refuses any request that carries an `Origin` header or a non-local
  `Host`**, so a web page in your browser cannot masquerade as the game client (which would let it feed text
  into tool results) or rebind DNS to the bridge. Set `DEXMCP_TOKEN` as well if other local users share the machine.
- `execute_lua`, `hook_function`, `trap_add`, `file`, `http_request`, `set_global`, `save_instance`... run with
  the executor's full power inside the game. Treat tool results (script sources, chat text, remote arguments) as
  untrusted data: they come from the game, not from you.

## Layout

```
server/            MCP server (index.js), bridge (WebSocket + HTTP), formatting, Luau disassembler, tools/*
lua/NN_*.lua       the bridge, in parts (prelude, serialize, events, instances, properties, scripts,
                   luaruntime, hooks, remotes, exec, world, snapshots, dex, transport)
scripts/embed.js   builds the MCPBridge module and injects it into ../dexplusplus.lua (idempotent)
scripts/check-lua.js   luaparse syntax check of every part + the generated module
test/              server tests (mock client) and a Lua end-to-end suite (below)
```

Edit `lua/*.lua`, then `npm run build` (embed → syntax check → regenerate docs). The Lua is written in the Lua 5.1
subset of Luau (no `continue`, `+=`, type annotations) so it runs everywhere and can be linted here.

## Tests

`npm test` runs two suites:

- `test/run.js` — spawns the real server over stdio with an MCP client and a mock Dex++ client
  (WebSocket and HTTP long-poll, chunked replies, disconnects, Origin rejection, disassembler).
- `test/lua-e2e.js` — hosts the **generated Lua module** in [fengari](https://fengari.io) with a mocked Roblox/executor
  environment (`test/mock_env.lua`: instances, signals, namecall hooking, GC, debug library, services) wired to
  the **real server over a real WebSocket**, then drives ~100 tools through MCP and reports which of the 200+
  bridge commands the suite did not touch. This catches Lua runtime errors; it cannot prove behaviour against the
  real Roblox engine or any particular executor.

## Troubleshooting

| symptom | fix |
|---|---|
| `No Roblox client is connected` | run Dex++ in the executor; open the **MCP** window; check Host/Port; `Transport = http` if WebSockets are blocked |
| window says `error - ... WebSocket API not available` | your executor lacks `WebSocket.connect`; set `Transport = auto` (default) to use HTTP polling |
| `executor does not provide 'X'` | missing executor API — see `get_capabilities`; use `execute_lua` or another tool |
| decompile returns an error comment | non-client script, or the fallback decompiler (Konstant needs internet) failed; try `set_decompiler{engine:"advanced"}` or `get_script_strings` / `disassemble_bytecode` |
| two Claude sessions, one port | the second server takes the next port; Dex++ probes `Port..Port+9` and attaches to the first that answers |
| `hello failed (HTTP 403 ...)` | the executor's HTTP/WebSocket client sends an `Origin` header and the server refused it; set the same `DEXMCP_TOKEN` / `Settings.MCP.Token` (a token replaces the Origin check) |
| `no Dex++ MCP server answering` | the MCP server isn't running yet (it starts with your MCP client) or Host/Port is wrong; Dex++ keeps retrying |
| tools do nothing / `No Roblox client` though Dex++ says connected | a stray `node server/index.js` (e.g. from `npm start`) owns the port; stop it so the MCP client's own instance can take it |
| refs vanish after rejoin | refs are per game session; re-run the query |
