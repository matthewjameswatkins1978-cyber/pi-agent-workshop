# AGENTS.md — pi-agent-workshop

Muse (this session) may delegate bounded work to `pi-subagents` children
without a separate user request when a task genuinely benefits from
independent research, scouting, parallel work, or review.

## Standing permission

- Delegate when the win is real: parallelisable recon, an independent
  second read (reviewer), or scouting a large unfamiliar tree.
- Do the work directly when it is small enough to hold in one context —
  delegation has latency (observed 60–100 s per scout) and model cost.

## Boundaries (hard)

- Studio owns mission orchestration, checkpoints, recovery, human gates.
  Children never load ambient extensions (verified: foreground children
  load none; background children start `--no-extensions` + bootstrap),
  so Studio cannot duplicate inside a child — keep it that way.
- At most one or two concurrent children. No nested delegation
  (`allowNestedSubagents` stays unset everywhere).
- Cheap models for children: project default
  `xiaomi-token-plan-ams/mimo-v2.6-flash` (see `.pi/settings.json`).
  `qwen-token-plan/qwen3.8-flash` is the preferred cheap route once its
  quota resets (2026-10-27); until then it 429s — do not default to it.
  Pin stronger models per-run for genuinely hard roles (oracle, writer).
- Prefer read-only roles first: `reviewer` (read-only tools,
  `acceptanceRole: read-only`), `scout` (write only for its `context.md`
  artifact). `worker`/`delegate` have edit+write — assign file scope
  narrowly and keep one-writer discipline per worktree.
- Worktree isolation: default shared-cwd scouting is fine for reads;
  use `worktree` isolation for any child that writes.
- Speedy Keeper: children do not inherit it. A host that needs child
  memory access must pass `ctx.cwd` of the parent project explicitly —
  missing `ctx.cwd` falls back to the child's `process.cwd()` and opens
  the wrong DB (or fails `memory-unavailable` outside git).
- Basic Memory stays the shared durable project knowledge; PiToRuleThemAll
  stays responsible for formal independent QA (not ad-hoc child reviews).
- One subagent extension only: `nicobailon/pi-subagents`. Do not install
  `tintinweb/pi-subagents` alongside it.

## Proof

See `experiments/pi-subagents-trial.md` for the isolated-trial evidence
this policy rests on.
