# START HERE — TAG10

This is the single Git entry point for a fresh ChatGPT, Codex, or other AI
session. Restore the project from this repository instead of relying on prior
ChatGPT/Codex conversations, account memory, or an earlier handoff message.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `main`
- Phase: **Phase 2B — Visual Polish**
- Status: **IMPLEMENTATION_AUTHORIZED_AFTER_HANDOFF_SYNC**
- Work Unit: **Visual Polish**
- Latest Reviewed Implementation Commit:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Baseline Review Sync:
  `eba4f8e8b39aa03616ebeb5fe9334701cab0c23e`
- Phase 2B Review Target: **Not created**
- Phase 2B Code Review: **PENDING**
- Phase 2B Codex Visual QA: **PENDING**
- Phase 2B ChatGPT Visual Review: **PENDING**
- Continuity: **READY**
- Handoff Sync: **completed by this commit**
- Next Action: **Implement only Phase 2B Visual Polish.**
- Phase Gate: **Phase 3 is PROHIBITED.**

The Phase 2A implementation at exact SHA `26dfdb29...` remains the latest
reviewed baseline. The explicit Phase 2B Work Unit authorizes visual polish only
after this Handoff Sync is committed, pushed, and verified.

## Cold Start Reading Order

Read in this order before selecting or changing work:

1. `docs/START_HERE.md`
2. `docs/PROJECT_STATE.md`
3. `AGENTS.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/GAME_RULES.md`
6. `docs/IMPLEMENTATION_PLAN.md`
7. `docs/QA_CHECKLIST.md`
8. `prototype/tag10-heat.html`
9. `docs/CODEX_REPORT.md`
10. `docs/REVIEW_LOG.md`
11. Relevant source and tests for the explicitly authorized task

For gameplay balance and behavior, `docs/GAME_RULES.md` is authoritative. The
HTML prototype is the reference for feel, rendering ideas, CPU behavior, and
existing flow. `docs/PROJECT_STATE.md` is authoritative for choosing the next
work unit and applying the current phase gate.

## Recovery Procedure

1. Confirm local `main`, `origin/main`, and a clean worktree.
2. Read `docs/PROJECT_STATE.md` before deciding what to do.
3. Confirm the Latest Reviewed implementation and Baseline Review Sync exist in
   Git.
4. Confirm the evidence paths and review statuses recorded in PROJECT_STATE.
5. Work only on the explicit task authorized by PROJECT_STATE or the user.
6. Keep `PROJECT_STATE.md`, `CODEX_REPORT.md`, and `REVIEW_LOG.md` synchronized
   when implementation, verification, review, or the next action changes.

## Stop Conditions

Stop without implementation and report the conflict if any of the following
disagree:

- Notion's active Work Unit
- `docs/PROJECT_STATE.md`
- Git specifications and source-of-truth documents
- Source code and tests
- Review Target / Latest Reviewed commit history
- Explicit user instructions

Do not resolve a state or product contradiction by guessing. Do not advance to
a later phase until `docs/PROJECT_STATE.md` or an explicit task authorizes it.

## Phase 2B Authorization

- Current Phase: **Phase 2B**
- Work Unit: **Visual Polish**
- Status: **IMPLEMENTATION_AUTHORIZED_AFTER_HANDOFF_SYNC**
- Latest Reviewed Implementation:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Baseline Review Sync:
  `eba4f8e8b39aa03616ebeb5fe9334701cab0c23e`
- Phase 2B Review Target: **Not created**
- Allowed implementation: visual presentation layer only
- Forbidden: gameplay/input/CPU changes and **all Phase 3 work**

## Phase 2A Baseline Receipt

- Decision: **APPROVE**
- Approved Implementation:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Reviewed State Snapshot:
  `6bfc6529b42259d1dc9cf845f55f3396c6e04ffa`
- Code / State Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Final Visual Review: **PASS**
- Evidence:
  - `docs/evidence/phase-2a/intro.png`
  - `docs/evidence/phase-2a/playing.png`
  - `docs/evidence/phase-2a/result.png`

This Phase 2A receipt remains the approved baseline and does not authorize any
gameplay-rule change during Phase 2B.
