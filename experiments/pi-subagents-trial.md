# pi-subagents trial — Nico Bailon, v0.79.1 (2026-10-19)

Candidate: `github.com/nicobailon/pi-subagents` v0.79.1 (cloned
2026-10-19 to Temp for inspection; deps installed in the clone only).
Pi 1.3.0, Windows, PowerShell. Nothing installed globally during trials;
all runs used `pi --no-extensions -e <clone>/index.ts --no-session -p`.

## Inventory (installed / enabled / loaded)

- Installed (settings `packages`): pi-mcp-adapter@3.2.0, PiToRuleThemAll,
  matthew-way-studio@633f4be, rabbit-pi-compactor#feature/rabbit-0.3.0,
  Speedy-Keeper@v0.2.1. `pi-subagents`: NOT installed at trial time.
- Enabled: all of the above (no per-package disables found).
- Loaded in a normal session: Speedy Keeper tools, MCP adapter servers
  (basic-memory cloud oauth, lantern local), pi-qa, rabbit compactor.
  Studio live dir holds only `index.ts.disabled` — Studio does NOT load.
- MCP: `pi mcp list` shows no servers (no `mcp.json` anywhere); MCP tools
  arrive via the pi-mcp-adapter extension (`mcp-adapter.json`).
- Auth (no secrets printed): meta ready, qwen-token-plan ready (quota
  exhausted till 2026-10-27, observed 429), deepseek ready (balance
  exhausted, observed 402), xiaomi-token-plan-ams ready (works).

## Compatibility findings (code-read + docs)

- Tools registered: `subagent`, `bg_wait`, `subagent_supervisor`,
  `subagents_enable` loader, `contact_supervisor`. No collision with
  `memory_search`/`memory_save`, Studio, or pi-qa names.
- Events: session_start/tree/shutdown, context, before_agent_start
  (advertised-agent prompt section only), agent_end, session_before_compact
  (run state across compaction — coexists with rabbit compactor, no shared
  files found), tool_result. Additive observers; no handler collisions seen.
- Children: foreground load NO ambient extensions; background start
  `--no-extensions` + bootstrap. Studio/Speedy Keeper/rabbit/MCP do not
  leak into children unless explicitly admitted (`defaultExtensions` /
  frontmatter `mcp:`). `PI_SUBAGENT_CHILD=1` disables the extension itself
  in children. Nested delegation requires explicit
  `allowNestedSubagents: true` (default off).
- Models: child default = parent model; overridable via
  `subagents.defaultModel` → role override → frontmatter → per-run.
- Roles: `reviewer` read-only tools + `acceptanceRole: read-only`;
  `scout` read/grep/find/ls/bash/write (write = `context.md` artifact);
  `worker`/`delegate` add edit. `cwd` + `worktree` isolation supported.
- Windows: explicit win32 handling (process keys via powershell.exe,
  platform guards). Version needs Pi ≥ 0.86.1 for tool activation; 1.3.0 OK.
- One-only decision: `tintinweb/pi-subagents` exists (npm
  `@tintinweb/pi-subagents`) with an open MCP-inheritance bug (#370) —
  NOT installed, per instruction. Nico's kept: same author as the
  installed pi-mcp-adapter, cleaner child boundary, active (0.79.1 released
  2026-10-17).

## Isolated trials (all `--no-extensions -e <clone> --no-session`)

| # | Task | Result |
|---|---|---|
| T1 | Load probe | Tools `default.subagent`, `default.subagent_supervisor` visible, 14 s, no errors |
| T2 | Explicit scout (xiaomi flash), workshop map | Accurate 10-line map, 69 s, no writes |
| T3 | Review prompt (reviewer allowed) | Parent chose direct review, 26 s, found 7 real script bugs (fixed in `scripts/verify-baseline.ps1` via Threadmoth, 6 certificates) |
| T4/T5 | No-mention Q&A / recon | Direct answers, 33 s / 238 s |
| T6 | Scout on deepseek flash | Clean bounded failure: 402 insufficient balance; parent stopped per policy, evidence reported, no fallback |
| T7 | Scout on qwen flash | 429 quota exhausted till 2026-10-27 |
| T8 | Broad async scout of speedy trials | Overran 600 s tool timeout; child wrote 1.4 MB events / 161 KB output; status stuck `running` after parent died; orphan run dir left in Temp (disposable) |
| T9 | Narrow foreground scout, bench.mjs | Correct 5-line answer, 102 s, run id `74a1c093…` reported |

## Conclusions

- Mechanics verified: explicit delegation works, returns findings, parent
  continues; failure handling is bounded and honest; no project writes in
  any trial (both repos `git status` clean throughout).
- Automatic triggering NOT observed: the muse-spark parent chose direct
  execution 3/3 times when it had direct file access. Automaticity =
  model-decided via the loader; project policy (AGENTS.md) grants standing
  permission with when-to-delegate criteria. `toolActivation` left at
  default `auto` (lean requests until first delegation).
- Economy: per-call token usage not instrumented in `-p` text mode —
  reported honestly as unmeasured; latency direct 26–238 s vs delegated
  69–102 s (task-dependent, not head-to-head). Value = context offload,
  not speed. Cheap route now: xiaomi flash; qwen flash after 10-27.
- Caveat: broad recon on a cheap flash child can run very long (T8) —
  keep scopes narrow with explicit timeouts.

## Rollback

- `C:\Users\Matmus\.pi\agent\settings.json.bak-subagent-trial-20261019`
  (pre-trial copy). Global admission = `pi install` (adds one package) +
  delete = `pi remove pi-subagents` + restore backup.
- No sessions touched; Temp inspection clone + run dirs are disposable.
