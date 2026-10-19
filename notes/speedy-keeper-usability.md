# Speedy Keeper usability — investigation notes

Source of truth: `D:\Projects\speedy-keeper` (README, `src/paths.ts`,
`src/pi/adapter.ts`, `pi-extension/keeper-memory.ts`). Verified 2026-10-19
against branch `feat/b4-recall-experiment`.

## What works (evidenced)

- `node dist/src/cli.js help` prints usage; `--db` override documented.
- Disposable roundtrip with `--db $TEMP\*.sqlite`:
  `save → search → export` all returned `{"ok":true,…}`, temp removed.
  Project DBs untouched.
- Errors are JSON envelopes with exit codes (2 validation/not-found,
  3 busy) per README; adapter maps expected failures to data, throws only
  on unexpected internals (`src/pi/adapter.ts`).
- Secrets rejected, provisional-until-evidenced saves, WAL concurrency —
  claimed in README; test files present (`secrets`, `concurrency`,
  `multiprocess`, `rollback` tests) but not re-run in this pass.

## Usability friction (observed, not yet fixed)

1. `memory_search` from a non-git cwd fails with `memory-unavailable`
   (`not-a-git-project … pass --db <path> instead`). Correct behaviour,
   but the Pi tool instantly failed here in the workshop (which is not a
   git repo) — first-run UX depends on cwd being a git project or
   `SPEEDY_KEEPER_DB` being set. Worth a one-line hint, not a redesign.
2. Installed (`v0.2.1`) vs dev (`feat/b4-*`) divergence: B4 conditions
   (promptSnippet hint, preflight preview, shadow retrieval) live on the
   experiment branch; `pi-extension/keeper-memory.ts` header warns
   "NEVER install globally, NEVER merge auto-injection on this branch".
   Usability conclusions from B4 must stay labelled as experiment-branch.
3. B2 adapter registers exactly two tools, no event handlers or injection
   (`pi-extension/keeper-memory.ts`). Discoverability is the known cost —
   B4 condition C/D trials exist precisely to measure it.

## Subagent-relevant contract (for compat trial)

- `ToolContext { cwd?: string }`; execute uses `ctx?.cwd ?? process.cwd()`.
- DB resolves via `resolveDbPath(cwd, deps.dbPath || SPEEDY_KEEPER_DB || git-common-dir)`.
- Worktrees share one DB (git common dir) — subagents in worktrees stay coherent.
- Env that must propagate to subagents: `SPEEDY_KEEPER_DB`,
  `SPEEDY_KEEPER_DISABLED`, `SPEEDY_KEEPER_HINT`.
- Missing `ctx.cwd` silently falls back to host `process.cwd()` — the
  sharp edge the compat trial must pin down.
