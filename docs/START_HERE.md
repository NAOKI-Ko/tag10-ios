# START HERE — TAG10

This is the Git entry point for a fresh ChatGPT, Codex, or other AI session.
Recover state from this repository, not prior conversations or account memory.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-4-cpu-stages`
- Phase / Work Unit: **Phase 4 — CPU / Stages / HEAT**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Latest Reviewed Implementation:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 4 Base / Phase 3 implementation:
  `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- Phase 4 Review Target Implementation:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 QA / State Snapshot: the commit containing this snapshot; resolve
  with `git log -1 --format=%H -- docs/START_HERE.md`
- Phase 3 ChatGPT Code Review: **PASS**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- Phase 4 Codex Code Review: **PASS**
- Phase 4 Simulator QA: **PARTIAL PASS / BLOCKED ONLY ON CPU SHOCK VISUAL**
- Phase 4 Evidence: **CAPTURED — `docs/evidence/phase-4/`**
- Phase 4 ChatGPT Review: **PENDING**
- Continuity: **BLOCKED ON REVIEW**
- Next Action: **Push this QA/state snapshot, then request exact-SHA code/state
  and visual review. Retain the documented CPU SHOCK visual limitation.**
- Phase Gate: **Do not merge to main and do not begin Phase 5.**

## Cold Start Reading Order

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

`docs/GAME_RULES.md` is authoritative for gameplay balance and behavior. The
HTML prototype is the reference for feel, CPU behavior, stages, and flow.

## Recovery Procedure

1. Confirm branch, upstream, exact HEAD, and a clean worktree.
2. Read `docs/PROJECT_STATE.md` before choosing work.
3. Confirm the Phase 4 Review Target is `3486d7d720042fcacf43773ded2ac7c71a8e5a91`.
4. Confirm 63 XCTest methods pass and inspect Simulator/evidence status,
   including the CPU SHOCK visual limitation.
5. Preserve the Phase 3 Device Motion human gate and Phase 3 not-closed state.
6. Work only on an explicit task; keep state/report/review memory synchronized.

## Stop Conditions

Stop and report if Notion, Git docs, source, tests, commit history, or explicit
instructions disagree. Do not infer approval, manufacture visual evidence, or
advance to Phase 5.

## Phase 4 Verification Receipt

- Generic iOS Build: **PASS**
- Generic iOS Simulator Build: **PASS**
- Tests: **PASS — 63 XCTest methods, 0 failures**
- CPU / HEAT / BOWL / PILLAR / cycling: **UNIT TESTED**
- Simulator install / launch: **PASS — dedicated iPhone 17 Pro / iOS 26.5**
- Consecutive match QA: **PASS — 19 matches**, including repeated
  FLAT → BOWL → PILLAR cycling and per-match HEAT reset.
- FLAT chase/escape, Direct TAG, PLAYER SHOCK transfer, BOWL, PILLAR, and HEAT:
  **PASS by Simulator observation plus XCTest**.
- CPU SHOCK visual trigger: **BLOCKED** by the documented rating 1120 gate;
  its deterministic logic tests pass and no override was added.
- Phase 4 evidence: **CAPTURED — six PNG files under
  `docs/evidence/phase-4/`**
- ChatGPT Review: **PENDING**

## Phase 3 Carry-forward Gate

- Implementation: `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- ChatGPT Code Review: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- Phase 3: **NOT CLOSED**
