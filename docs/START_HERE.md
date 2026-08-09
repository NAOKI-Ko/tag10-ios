# START HERE — TAG10

This is the single Git entry point for a fresh ChatGPT, Codex, or other AI
session. Restore the project from this repository instead of relying on prior
ChatGPT/Codex conversations, account memory, or an earlier handoff message.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-3-input`
- Phase: **Phase 3 — Input**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Work Unit: **Phase 3 — Input**
- Latest Reviewed Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 3 Branch Baseline:
  `292c31d581e5cddcf2270db1feb35cb8c0caf7b9`
- Phase 3 Review Target Implementation Commit: the commit containing this
  snapshot; resolve with `git log -1 --format=%H -- docs/START_HERE.md`
- Previous Phase 3 Implementation Commit:
  `e5825496083b9559784da174ce8406c093930fff`
- ChatGPT Code Review: **FIX IMPLEMENTED / RE-REVIEW PENDING**
- Original Review Decision: **CHANGES REQUESTED**
- Codex Code Review: **PASS**
- Simulator Visual QA: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- ChatGPT Final Review: **PENDING**
- Continuity: **BLOCKED ON REVIEW**
- Next Action: **ChatGPT exact-SHA Review Fix re-review and Visual Evidence
  review.**
- Phase Gate: **Phase 4 is PROHIBITED.**

Phase 3 input implementation is complete on its dedicated branch but is not
approved or closed. Do not merge to `main` and do not begin Phase 4 until an
explicit review receipt or Work Unit authorizes the transition.

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

1. Confirm the checked-out branch, its upstream, and a clean worktree.
2. Read `docs/PROJECT_STATE.md` before deciding what to do.
3. Confirm the Latest Reviewed implementation, branch baseline, and Phase 3
   Review Target exist in Git.
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

## Phase 3 Verification Receipt

- Scope: CoreMotion tilt, neutral calibration, player-only movement,
  tap-to-SHOCK, DEBUG drag fallback, and motion-trail validation
- Generic iOS Build: **PASS — BUILD SUCCEEDED**
- Simulator Build / Launch: **PASS — iPhone 17 Pro / iOS 26.5 / portrait**
- Review Fix: **point-space isotropic movement and Direct TAG / SHOCK
  knockback geometry implemented; intro/finished SHOCK presentation blocked**
- Tests: **PASS — 27 XCTest methods, 0 failures**
- Simulator Visual QA: **PASS**
- Evidence:
  - `docs/evidence/phase-3/idle.png`
  - `docs/evidence/phase-3/drag-movement.png`
  - `docs/evidence/phase-3/shock.png`
- Device Motion QA: **PENDING HUMAN GATE**
- Explicitly not implemented: CPU AI/movement/SHOCK, BOWL, PILLAR, stage
  cycling, HEAT speed application, haptics, sound, persistence, and Phase 4+

## Phase 2B Reviewed Baseline

- Status: **CLOSED / APPROVED**
- Approved Implementation / Latest Reviewed Implementation:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- ChatGPT Final Visual Review: **PASS**

The Phase 2B baseline remains the Latest Reviewed Implementation until ChatGPT
approves the exact Phase 3 Review Target.
