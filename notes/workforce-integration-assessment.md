# Pi workforce integration assessment

**Date:** 2026-10-26  
**Question:** Can the proposed agent workforce be built from Pi components that already exist?

## Recommendation

Yes. Do not build a second agent runner or a bespoke message board. Use **Pi Messenger Crew + Team** for task planning, shared coordination, and worker execution; retain **Matthew Way Studio** as the outer mission record and evidence gate. Add only the governance rules that are specific to this workforce.

For the first version, do not run Pi Messenger Crew and `pi-subagents` as competing task schedulers on the same mission. `pi-subagents` remains a useful alternative for bounded child workflows, typed gates, and explicit time or tool budgets, but Crew already owns a planner, task graph, worker waves, automatic review, and Team context. Using both to schedule the same work would create two sources of truth.

## Confirmed existing capability

### Pi Messenger 0.15.2

The inspected upstream package already provides:

- A shared room, direct and broadcast messages, agent discovery, presence, and an activity feed.
- File and directory reservations, with release on worker exit.
- Crew planning from a PRD, dependency-aware task waves, parallel workers, and review/rework outcomes.
- An optional Team layer with a charter, named roles, durable decisions/interfaces/risks/handoffs, risk labels, and approval gates.
- Project-local Crew state under `.pi/messenger/crew/` and file-backed shared coordination, without a separate daemon.
- A Windows-specific `pi.cmd` launch path in `crew/agents.ts`.

The README badge still says macOS/Linux. The code contains a Windows launch path, so the badge is incomplete evidence rather than proof of Windows support. A real Windows smoke test is still required before treating the package as supported on Matthew's machine.

### Pi Subagents 0.79.1

The workshop's prior isolated trial found that `pi-subagents` works on Pi 1.3.0 and Windows. Its current documented surface includes role-limited children, background runs, workflow scripts, staged lanes, run deadlines and tool budgets, typed outputs/gates, and child-to-parent `contact_supervisor` messages. It does not itself provide the shared peer chat/task room that Matthew described. Pi Messenger fills that gap.

### Matthew Way Studio

Studio already provides the outer packet and mission contract, durable mission state, bounded continuation, checkpoints, review/evidence handling, and a completion gate requiring machine evidence and a verified remote SHA. Its current project instructions explicitly say not to create a second agent harness or dashboard. This supports keeping Studio's role narrow: preserve the mission and its acceptance truth; do not make Studio a second task scheduler.

## Proposed boundary

| Concern | Owner | Rule |
|---|---|---|
| User intent, packet, authority, acceptance, mission continuity | Matthew Way Studio | One mission identity; preserve the original packet and checkpoints. |
| Task decomposition, shared board/chat, reservations, worker assignment, review rounds | Pi Messenger Crew + Team | One task graph and one scheduler for a mission. |
| Child execution only when a bounded workflow is needed | `pi-subagents` (later/optional) | Do not let it independently schedule tasks already owned by Crew. |
| Agent-facing presentation | Pi Messenger overlay | Reuse the existing overlay for v1; defer a Hamesh surface. |
| Private team evaluation | Small separate collector, later slice | Store derived metrics separately from agent-visible messages and prompts. |

The handoff from Studio to Crew should carry the mission ID, exact packet, acceptance conditions, authority/constraints, current milestone, and the next task boundary. Crew results return as structured task outcomes plus artifact paths. Studio decides whether the milestone has evidence sufficient for its checkpoint; agent prose alone cannot complete the mission.

## Governance rules still to add

Pi Messenger supplies most mechanics, but its generic team model does not establish all of Matthew's rules. Treat these as an explicit adapter/charter contract and verify which can be enforced deterministically:

1. **Rotating coordinator:** elect one captain per milestone from eligible active agents. Record the choice and reason. Rotate on the next milestone; the captain cannot assign itself every implementation task.
2. **Work distribution:** tasks belong to named agents, but roles are capabilities rather than permanent identities. No agent owns the same role for every milestone. Respect file reservations and do not issue overlapping write scopes.
3. **Review markers:** collect 4–6 independent review markers at a milestone. A worker cannot review or vote on its own work. Record each marker against the diff/evidence it reviewed; do not count ungrounded agreement as acceptance.
4. **Milestone return:** workers report changed paths, checks run, evidence, unresolved risks, and next dependency. The captain reconvenes the group only when a dependency or a material disagreement requires it; otherwise the deterministic board state is enough.
5. **Human authority:** agents may propose, challenge, and recommend. The user retains project intent and any decision reserved in the packet. Approval gates should be tied to consequence, not routine inconvenience.

A “captain election” should not be a model vote over agent personalities. Make it a deterministic rotation over eligible participants with load and conflict exclusions; use discussion to challenge the plan, not to change who has authority.

## Private metrics: useful and bounded

The proposed pre-compaction collector is plausible, but the timing and data source are not yet proved. Pi Messenger and Pi Subagents already emit activity/status artifacts; first check whether those provide the fields needed. Avoid scraping transcripts if structured events suffice.

Start with task-level measures that can improve the workflow: completion and rework rate, time to first useful artifact, stalled/blocked time, review findings accepted, and reservation conflicts. Compare only like work and record model/role/task type as context. Do not rank agents from raw speed, token count, or review volume; those reward easy tasks and verbosity. Keep detailed scores outside agent prompts and board messages, and expose a short human-only aggregate with its measurement limits.

Do not couple collection to an assumed event order around Rabbit compaction. First prove when Pi's `session_before_compact` hook fires relative to the installed compactor and whether the needed event data is still available. If ordering cannot be guaranteed, record metrics continuously from structured events and use pre-compaction only as a final flush.

## Three-slice implementation contract

### Slice 1 — Use the existing board

- Pin and smoke-test Pi Messenger 0.15.2 on the actual Windows Pi setup.
- Create a project Team profile/charter for the workforce: rotating captain, non-self-review, scoped tasks, reconvene-on-dependency, and the review-marker rule.
- Exercise a disposable repository with one planning pass, two independent tasks, one dependency, and one review/rework cycle.
- Keep the run in Pi Messenger Crew; do not connect Studio yet.

**Accept when:** board state, assignments, messages, file claims, completion/rework, and milestone evidence can be recovered after a Pi restart; Windows child launch and exit cleanup work; no task is counted complete solely from a worker's claim.

### Slice 2 — Bridge Studio mission truth

- Add a narrow adapter that passes Studio's packet and mission ID to Crew and returns task outcomes/artifacts to a Studio checkpoint.
- Keep Crew's task graph as the only decomposition/scheduling state. Keep Studio's ledger as the only mission/acceptance state.
- Prove that pause, resume, and a replaced/foreign Studio mission cannot mutate the wrong Crew board.

**Accept when:** one mission ID joins the packet, board, and returned evidence; interrupted work resumes without duplicating completed tasks; Studio still refuses completion without its existing evidence and remote-SHA gate.

### Slice 3 — Private metrics

- Derive the smallest aggregate from verified structured events.
- Prove collector timing on Matthew's Pi installation, including Rabbit compaction and restart cases.
- Keep the report human-only; do not make hidden scores an agent instruction or reward signal.

**Accept when:** repeated collection is idempotent, missing events are marked missing rather than inferred, and the report can be traced back to task/run evidence without storing unnecessary prompt or transcript content.

## Risks and decisions

- **Windows support:** the package includes a Windows launch branch, but the README's platform claim excludes Windows. Slice 1 must resolve this empirically.
- **Double orchestration:** Crew plus Pi Subagents can each own execution state. Select one scheduler per mission.
- **Review quality:** 4–6 votes can become ritual. Markers need distinct review questions and cited evidence, with the no-self-review rule checked in code.
- **Captain bias:** a fixed captain can become a bottleneck. Rotation is deterministic, conflict-aware, and visible in the board.
- **Metric distortion:** raw counts are not quality. Keep task context and uncertainty with every aggregate.
- **Compaction order:** do not rely on a race between independent Pi extensions for the only copy of metrics.
- **Hamesh scope:** a custom visual workforce panel adds little before board semantics are proven. Revisit after Slice 1; reuse the existing Pi Messenger overlay for the first version.

## Evidence and sources

- [Pi Messenger repository](https://github.com/nicobailon/pi-messenger) — inspected `main`, package version 0.15.2, README and worker spawn path on 2026-10-26. License declared MIT in `package.json` and README badge.
- [Pi Subagents v0.79.1](https://github.com/nicobailon/pi-subagents/tree/v0.79.1) — inspected README and workflow/extension documentation; the workshop's Windows trial is in [`experiments/pi-subagents-trial.md`](../experiments/pi-subagents-trial.md).
- [Matthew Way Studio](https://github.com/matthewjameswatkins1978-cyber/matthew-way-studio) — inspected current `AGENTS.md`, `README.md`, mission and packet modules on 2026-10-26.
- Inference: the proposed boundary minimizes duplicated state because Studio already owns mission continuity while Pi Messenger Crew already owns task decomposition and worker scheduling. This is an architectural recommendation, not yet a live integration proof.
