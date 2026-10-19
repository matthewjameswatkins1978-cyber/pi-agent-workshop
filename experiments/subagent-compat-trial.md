# Subagent compatibility trial (bounded)

Goal: determine what an automatic-subagent host must guarantee for Speedy
Keeper tools to resolve the right project memory — without changing
Speedy Keeper, Pi, or Studio code in this workspace.

## Scope / non-goals

- No subagent implementation found in `mattsPI/packages` or
  `PiToRuleThemAll/src` at baseline; trial is contract-first, not a build.
- No changes to extension installations, memory DBs, sessions, or credentials.

## Compatibility criteria

1. Subagent `cwd` reaches the tool as `ToolContext.cwd` (not host cwd).
2. `SPEEDY_KEEPER_DB` / `SPEEDY_KEEPER_DISABLED` / `SPEEDY_KEEPER_HINT`
   propagate to the subagent environment when set.
3. Worktree subagents resolve the shared git-common-dir DB.
4. Non-git cwd produces the structured `memory-unavailable` envelope
   (graceful), never a crash or a wrong-project DB.
5. Concurrent host + subagent access stays within WAL/busy-timeout behaviour.

## Evidence so far (2026-10-19)

- Code-read: `src/pi/adapter.ts` `ctx?.cwd ?? process.cwd()` + `open(cwd)`
  via `resolveDbPath`; `src/paths.ts` git-common-dir sharing. Criteria 1–4
  follow from this contract; criterion 5 is covered by existing
  `concurrency` / `multiprocess` / `pi-adapter` tests (not re-run here).
- Live probe: temp-DB `save/search/export` roundtrip passes; project DBs
  untouched.

## Next steps (small, reversible)

- [ ] Run existing suite in place: `npm run typecheck` + `npm test` inside
      `D:\Projects\speedy-keeper` (its own repo, its own DB handling).
- [ ] Targeted check: invoke `createMemoryTools` with explicit
      `{ dbPath: <temp> }` vs `ctx.cwd` variants to pin fallback behaviour.
- [ ] Studio interop: account for live ext dir being disabled
      (`index.ts.disabled`); do not assume Studio loads until re-enabled
      through its own repo flow.
