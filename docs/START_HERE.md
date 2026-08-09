# START HERE — TAG10

This is the Git entry point for a fresh ChatGPT, Codex, or other AI session.
Recover state from this repository, not prior conversations or account memory.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-4-cpu-stages`
- Phase / Work Unit: **Phase 4 — CPU / Stages / HEAT**
- Status: **CLOSED / APPROVED**
- Latest Reviewed Implementation:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 Implementation:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 QA / Evidence Commit:
  `d5261099c0012f8743e58cd22f4915982d04611f`
- Phase 4 Final Review Sync: the commit containing this snapshot; resolve with
  `git log -1 --format=%H -- docs/START_HERE.md`
- Phase 4 ChatGPT Code Review: **PASS**
- Phase 4 ChatGPT Visual Review: **PASS**
- Phase 4 Simulator QA: **PASS**
- Phase 4 CPU SHOCK Visual QA: **PASS**
- Phase 4 Tests: **PASS — 63 XCTest methods, 0 failures**
- Phase 3 ChatGPT Code Review: **PASS**
- Phase 3 ChatGPT Visual Review: **PASS**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- Continuity: **READY**
- Phase 5: **NOT STARTED**
- Next Work Unit: **Phase 5 — Haptics / Sound / Game Feel**
- Phase Gate: **Do not start Phase 5 without an explicit Work Unit. Do not
  start Phase 6 or merge this branch to main automatically.**

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
3. Confirm the Latest Reviewed Implementation is
   `3486d7d720042fcacf43773ded2ac7c71a8e5a91`.
4. Preserve Phase 4's approved status and the Phase 3 Device Motion human gate.
5. Work only on an explicit task; keep state/report/review memory synchronized.

## Stop Conditions

Stop and report if Notion, Git docs, source, tests, commit history, or explicit
instructions disagree. Do not infer approval, manufacture evidence, merge to
main, or advance phases automatically.

## Phase 4 Final Verification Receipt

- Generic iOS Build: **PASS**
- Generic iOS Simulator Build: **PASS**
- iPhone 17 Pro Simulator launch: **PASS**
- Tests: **PASS — 63 XCTest methods, 0 failures**
- Consecutive match QA: **PASS — 19 matches**
- Stage cycling FLAT → BOWL → PILLAR → FLAT: **PASS**
- CPU chase / escape / wall avoidance: **PASS**
- Direct TAG / PLAYER SHOCK / CPU SHOCK: **PASS**
- BOWL / PILLAR / HEAT: **PASS**
- CPU SHOCK / STUN visual evidence: **PASS**
- ChatGPT Code Review: **PASS**
- ChatGPT Visual Review: **PASS**
- Final Decision: **APPROVE**

## Phase 3 Carry-forward Gate

- Implementation: `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- ChatGPT Code Review: **PASS**
- ChatGPT Visual Review: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- Remaining physical-device checks: neutral calibration, tilt axis/direction,
  dead-zone feel, clamp feel, latency, and tilt + tap SHOCK.
- Phase 3: **NOT CLOSED**
