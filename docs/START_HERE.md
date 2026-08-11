# START HERE — TAG10

This is the Git entry point for a fresh ChatGPT, Codex, or other AI session.
Recover state from this repository, not prior conversations or account memory.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-5-game-feel`
- Phase / Work Unit: **Phase 5 — Haptics / Sound / Game Feel**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Phase 5 Review Target: the commit containing this snapshot; resolve with
  `git log -1 --format=%H -- docs/START_HERE.md`
- Latest Reviewed Implementation:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 5 Base / Phase 4 Final Review Sync:
  `543a8af4616af6ca64e24900523d64128f6200bb`
- Phase 4: **CLOSED / APPROVED**
- Phase 5 Generic iOS Build: **PASS**
- Phase 5 Generic iOS Simulator Build: **PASS**
- Phase 5 Tests: **PASS — 71 XCTest methods, 0 failures**
- Phase 5 Simulator install / launch: **BLOCKED — CoreSimulatorService denied
  install access in the Codex sandbox**
- Phase 5 Simulator Audio / Event QA: **BLOCKED**
- Phase 5 Evidence: **NOT CAPTURED — no current-build visual PASS claimed**
- Phase 5 Device Haptic / Sound QA: **PENDING HUMAN GATE**
- Phase 5 ChatGPT Code Review: **PENDING**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- GitHub branch push: **BLOCKED — shell DNS denied; GitHub app write returned
  `403 Resource not accessible by integration`**
- Continuity: **BLOCKED ON REMOTE SYNC / REVIEW / SIMULATOR QA**
- Next Action: **Push the local Phase 5 commit, then run Simulator Audio/Event
  QA outside the sandbox, capture the five required evidence frames, and
  request exact-SHA review.**
- Phase Gate: **Do not merge to main and do not begin Phase 6.**

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

## Phase 5 Implementation Snapshot

- Pure `FeedbackEventRouter`: **IMPLEMENTED / 8 TESTS PASS**
- One-shot match start, countdown 3/2/1, Direct TAG, SHOCK fire/transfer, and
  WIN/LOSE routing: **IMPLEMENTED**
- Presentation-only UIKit haptics: **IMPLEMENTED / DEVICE QA PENDING**
- Procedural AVAudioEngine SFX with no external assets: **IMPLEMENTED /
  SIMULATOR AND DEVICE AUDIBLE QA PENDING**
- Transfer/STUN feedback: **COMPOSITE** to avoid duplicate strong vibration
- DEBUG event trace: **IMPLEMENTED**
- GameEngine / GameConfig / GAME_RULES / CPU / stage physics: **UNCHANGED**

## Recovery Procedure

1. Confirm branch, upstream, exact HEAD, and worktree status.
2. Read `docs/PROJECT_STATE.md` before choosing work.
3. Confirm the Latest Reviewed Implementation remains
   `3486d7d720042fcacf43773ded2ac7c71a8e5a91` until ChatGPT review passes.
4. Preserve Phase 4 approval and both Phase 3 Motion and Phase 5 device gates.
5. Do not claim Simulator Audio QA or Phase 5 visual evidence from static
   Phase 4 files; use the current Phase 5 build.

## Stop Conditions

Stop and report if Notion, Git docs, source, tests, commit history, or explicit
instructions disagree. Do not infer approval, manufacture evidence, merge to
main, or advance to Phase 6.

## Phase 3 Carry-forward Gate

- Implementation: `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- ChatGPT Code Review: **PASS**
- ChatGPT Visual Review: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- Remaining checks: neutral calibration, tilt axis/direction, dead-zone feel,
  clamp feel, latency, and tilt + tap SHOCK.
- Phase 3: **NOT CLOSED**
