# Pi Agent Workshop

**An integration laboratory for the Pi coding-agent ecosystem.**

This repository is an engineering notebook for understanding how independent tools work together. It contains **reproducible baselines, compatibility notes, small experiments, and read-only checks**, rather than another agent runtime or copies of other projects' source code.

## What is being tested?

- [Speedy Keeper](https://github.com/matthewjameswatkins1978-cyber/Speedy-Keeper): project-scoped coding memory.
- [mattsPI](https://github.com/matthewjameswatkins1978-cyber/mattsPI): a fork of the Pi GUI.
- [Pi To Rule Them All](https://github.com/matthewjameswatkins1978-cyber/PiToRuleThemAll): personal Pi QA and integration.
- [Matthew Way Studio](https://github.com/matthewjameswatkins1978-cyber/matthew-way-studio): durable packet-driven work.

Each project owns its own source and behaviour. This workspace records what happens at their boundaries, especially the cases in which an integration is less useful than it first appears.

## Read the evidence

| File or folder | Purpose |
| --- | --- |
| [`BASELINE.md`](BASELINE.md) | Dated observed toolchain and integration state |
| [`PROJECT_MAP.md`](PROJECT_MAP.md) | Original local checkout map |
| [`notes/`](notes/) | Usability and interoperability findings, including the [workforce integration assessment](notes/workforce-integration-assessment.md) |
| [`experiments/`](experiments/) | Bounded trials and acceptance criteria |
| [`scripts/verify-baseline.ps1`](scripts/verify-baseline.ps1) | Re-runnable, read-only checks |

The recorded baseline was taken **19 October 2026**. It is a snapshot, not a guarantee that those versions, branches or installed extensions still exist today.

## Reproduce with care

The provided verification script was written for the original Windows/PowerShell workshop layout and expects sibling checkouts in specific places. Review [the project map](PROJECT_MAP.md) and adapt paths for your own machine before running:

```powershell
pwsh -File scripts/verify-baseline.ps1
```

Do not point experiments at live Pi sessions, credentials, production memory, or someone else's checkout. Test databases use a temporary path via `SPEEDY_KEEPER_DB`; project memory remains tied to the Git common directory so worktrees agree on identity.

**Not a product to install:** the useful result here is a reproducible finding, a compatibility proof, or a well-documented reason *not* to connect two systems.
