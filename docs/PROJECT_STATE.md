# PROJECT STATE — TAG10

Last synchronized: 2026-08-10 (Asia/Tokyo)

## Identity

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-4-cpu-stages`
- Phase: **Phase 4**
- Status: **CLOSED / APPROVED**
- Work Unit: **CPU / Stages / HEAT**
- Continuity: **READY**

## Review State

- Latest Reviewed Implementation Commit:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 Implementation Commit:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 QA / Evidence Commit:
  `d5261099c0012f8743e58cd22f4915982d04611f`
- Phase 4 Final Review Sync: the commit containing this file; resolve with
  `git log -1 --format=%H -- docs/PROJECT_STATE.md`
- Phase 4 ChatGPT Code Review: **PASS**
- Phase 4 ChatGPT Visual Review: **PASS**
- Phase 4 Simulator QA: **PASS**
- Phase 4 CPU SHOCK Simulator Visual QA: **PASS**
- Phase 4 Tests: **PASS — 63 XCTest methods, 0 failures**
- Final Decision: **APPROVE**

## Phase 4 Approved Snapshot

- Shared PLAYER / CPU point-space movement primitive: **APPROVED**
- CPU chase, prediction, escape, wall avoidance, and rating-based jitter:
  **APPROVED**
- CPU SHOCK eligibility and authoritative `GameEngine.useShock` flow:
  **APPROVED**
- HEAT speed multiplier for PLAYER and CPU, composed with IT/stage caps:
  **APPROVED**
- FLAT / BOWL / PILLAR stage behavior and cycling: **APPROVED**
- Direct TAG / PLAYER SHOCK / CPU SHOCK visual effects: **APPROVED**
- Game rule or balance deviations: **NONE**

## Verification Snapshot

- Generic iOS Build: **PASS — previously approved**
- Generic iOS Simulator Build: **PASS — previously approved**
- iPhone 17 Pro Simulator install / launch: **PASS**
- Unit Tests: **PASS — 63 XCTest methods, 0 failures**
- Consecutive match QA: **PASS — 19 matches**
- Stage cycling FLAT → BOWL → PILLAR → FLAT: **PASS**
- CPU chase / escape / wall avoidance: **PASS**
- Direct TAG / PLAYER SHOCK / CPU SHOCK: **PASS**
- BOWL / PILLAR / HEAT: **PASS**
- CPU SHOCK / STUN, transfer, new-IT STUN, and paused timer visuals: **PASS**
- ChatGPT final code and visual reviews: **PASS**

This docs-only Final Review Sync did not rerun build or tests. It records the
previously approved results above.

## Phase 3 Carry-forward State

- Phase 3 implementation: `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- Phase 3 ChatGPT Code Review: **PASS**
- Phase 3 ChatGPT Visual Review: **PASS**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- Remaining physical-device checks: neutral calibration, tilt axis/direction,
  dead-zone feel, clamp feel, latency, and tilt + tap SHOCK.

## Next Action

- Phase 5: **NOT STARTED**
- Next Work Unit: **Phase 5 — Haptics / Sound / Game Feel**
- Begin Phase 5 only under an explicit Work Unit.
- Do not merge `phase-4-cpu-stages` to `main` automatically.
- Do not begin Phase 6.

## State Conflict Rule

Before choosing work, read `docs/START_HERE.md` and this file. If Notion, Git
docs, source, tests, commit history, or explicit instructions disagree, stop
without implementation and report the conflict for review.
