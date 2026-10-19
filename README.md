# pi-agent-workshop

Shared Pi ecosystem integration workspace. Experiments, notes and
reproducible tests only — no source duplication.

## Rules

- Each project's own repository stays the working directory for its code
  and project-scoped memory. Nothing is copied here.
- No duplicated source trees, extension installations, memory databases
  or mission controllers.
- Project memory resolves via Git common dir (`<common-dir>/speedy-keeper/`);
  worktrees of one repo share one memory. Disposable test DBs use
  `SPEEDY_KEEPER_DB` + OS temp, never a project DB.
- Preserve live Pi sessions (`C:\Users\Matmus\.pi\agent\sessions`),
  credentials (`auth.json`) and active branches. This workspace is
  read-only toward those paths.

## Canonical locations (see PROJECT_MAP.md)

| Project | Path |
|---|---|
| Speedy Keeper (dev) | `D:\Projects\speedy-keeper` |
| Speedy Keeper (installed) | git `Speedy-Keeper@v0.2.1` via `pi list` |
| mattsPI fork | `D:\Projects\mattsPI` (`feature/durable-work-receipts`) |
| Personal Pi layer | `D:\Projects\PiToRuleThemAll` |
| Studio extension (live) | `C:\Users\Matmus\.pi\agent\extensions\matthew-way-studio` (currently disabled) |
| Pi settings | `C:\Users\Matmus\.pi\agent\settings.json` |

## Layout

- `BASELINE.md` — observed state, commands run, no claims beyond evidence.
- `PROJECT_MAP.md` — canonical paths, branches, status at baseline.
- `notes/` — usability + interoperability findings.
- `experiments/` — bounded trial plans with acceptance + evidence.
- `scripts/verify-baseline.ps1` — reproducible read-only checks
  (project DBs untouched; CLI roundtrip uses a temp `--db`).
