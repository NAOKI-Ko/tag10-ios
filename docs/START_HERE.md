# START HERE — TAG10

This is the Git entry point for a fresh ChatGPT, Codex, or other AI session.
Recover state from this repository, not prior conversations or account memory.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-5-game-feel`
- Phase / Work Unit: **Phase 5 — Recovery / Simulator QA**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Phase 5 Implementation:
  `1f8f96de82add416ea8e170b8e7bd7441b6a7f6b`
- Phase 5 QA / docs snapshot: the commit containing this file
- Latest Reviewed Implementation:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 5 Base / Phase 4 Final Review Sync:
  `543a8af4616af6ca64e24900523d64128f6200bb`
- GitHub implementation sync: **PASS — exact local / remote SHA match**
- Builds: **PASS — Generic iOS, Generic iOS Simulator, iPhone 17 Pro
  Simulator**
- Tests: **PASS — 71 XCTest methods, 0 failures** via direct execution of the
  exact generated bundle; standard testmanager execution remains sandbox
  infrastructure-blocked
- Simulator launch / gameplay event QA: **PASS**
- Consecutive matches: **PASS — 22**
- Evidence: **CAPTURED — five current-build PNGs plus QA README**
- Simulator audio event path: **PASS**
- Audible sound quality and physical haptics: **PENDING HUMAN GATE**
- Phase 5 ChatGPT Code Review: **PENDING**
- Phase 5 ChatGPT Visual Review: **PENDING**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3: **NOT CLOSED**
- Continuity: **READY FOR EXACT-SHA REVIEW**
- Next Action: **ChatGPT exact-SHA code/state/visual review.**
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

## Phase 5 Review Package

- Implementation: `1f8f96de82add416ea8e170b8e7bd7441b6a7f6b`
- QA / evidence snapshot: current branch HEAD
- Evidence:
  - `docs/evidence/phase-5/fight.png`
  - `docs/evidence/phase-5/countdown.png`
  - `docs/evidence/phase-5/direct-tag.png`
  - `docs/evidence/phase-5/shock-tag.png`
  - `docs/evidence/phase-5/result.png`
  - `docs/evidence/phase-5/README.md`
- Latest Reviewed must remain `3486d7d...` until ChatGPT approval.

## Recovery Notes

- The existing Phase 5 commit was recovered from
  `/private/tmp/tag10-phase5-1f8f96d.bundle`; it was not regenerated.
- Its parent is exactly `543a8af...` and it is one implementation commit ahead.
- Work continued in an isolated clone so the original workspace's uncommitted
  signing-only `project.pbxproj` change remained untouched.

## Open Human Gates

- Phase 3 Motion: neutral calibration, axes/direction, dead-zone feel, clamp
  feel, latency, and tilt + tap SHOCK.
- Phase 5 device feedback: haptic feel, excessive vibration, speaker volume /
  clipping / clarity, PLAYER/CPU pitch distinction, and synchronization.

## Stop Conditions

Stop and report if Notion, Git docs, source, tests, commit history, or explicit
instructions disagree. Do not infer approval, merge to `main`, or advance to
Phase 6.
