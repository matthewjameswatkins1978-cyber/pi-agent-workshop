# Baseline — 2026-10-19 (UTC)

Workspace `D:\Projects\pi-agent-workshop` was empty at start.
All checks below are read-only toward live state except new files in
this workspace and one disposable temp SQLite file (removed after use).

## Observed

- Pi 1.3.0, Node v24.19.0, Windows PowerShell 7.
- `D:\Projects\speedy-keeper`: branch `feat/b4-recall-experiment`,
  `e72481e` (phase 4–8 results), working tree clean at inspection.
  `dist/` prebuilt; `keeper help` + temp-DB save/search/export roundtrip pass.
- `D:\Projects\mattsPI`: branch `feature/durable-work-receipts`, clean at
  inspection, remote `github.com/matthewjameswatkins1978-cyber/mattsPI.git`.
- `D:\Projects\PiToRuleThemAll`: personal Pi layer, exposes
  `./extensions/pi-qa/index.ts` (`pi.pi.extensions` in package.json).
- Installed packages (`pi list`): `pi-mcp-adapter@3.2.0`,
  `D:\Projects\PiToRuleThemAll`, `matthew-way-studio@633f4be`,
  `rabbit-pi-compactor#feature/rabbit-0.3.0-smart-friendly`,
  `Speedy-Keeper@v0.2.1`.
  Note: installed Speedy-Keeper is v0.2.1 while dev repo is on a B4
  experiment branch — divergence to keep in mind, not to "fix" here.
- Live Studio extension dir contains only `index.ts.disabled` +
  `index.ts.bak-20260929-ci-economy` — no active `index.ts`.
  Studio interop work must account for disabled state, not assume it loads.
- No `subagent` matches in `mattsPI/packages` or `PiToRuleThemAll/src`
  at baseline (grep, limit 20). Automatic-subagent trial therefore starts
  from the Speedy Keeper adapter contract (`ToolContext { cwd? }`),
  not from an existing subagent implementation found here.
- Speedy Keeper DB routing: `src/paths.ts` → git common dir, so worktrees
  share one memory; `src/pi/adapter.ts` uses `ctx?.cwd ?? process.cwd()`
  and honours `SPEEDY_KEEPER_DB` / `SPEEDY_KEEPER_DISABLED` /
  `SPEEDY_KEEPER_HINT`. Hosts spawning subagents must propagate cwd + env.

## Commands actually run

- `pi --version`, `pi --help`, `pi list`
- `git -C <repo> status --short --branch`, `log --oneline -5` (speedy, mattsPI)
- `node speedy-keeper/dist/src/cli.js help`
- Disposable roundtrip: `keeper --db $TEMP\keeper-usability-test.sqlite
  save/search/export`, then temp file removed.
- Greps for `subagent` (mattsPI/packages, PiToRuleThemAll/src) and
  `cwd|ToolContext|...` (speedy-keeper/src) — see notes.

## Next

- `notes/speedy-keeper-usability.md` — usability findings.
- `experiments/subagent-compat-trial.md` — compat trial, bounded.
- `scripts/verify-baseline.ps1` — re-run the read-only baseline.
