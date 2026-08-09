# PROJECT STATE — TAG10

Last synchronized: 2026-08-10 (Asia/Tokyo)

## Identity

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-4-cpu-stages`
- Phase: **Phase 4**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Work Unit: **CPU / Stages / HEAT**
- Continuity: **BLOCKED ON REVIEW**

## Review State

- Latest Reviewed Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 3 implementation baseline / Phase 4 branch base:
  `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- Phase 3 ChatGPT Code Review: **PASS**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- Phase 4 Review Target Implementation Commit: the commit containing this
  file; resolve with `git log -1 --format=%H -- docs/PROJECT_STATE.md`
- Phase 4 Codex Code Review: **PASS**
- Phase 4 Simulator QA: **BLOCKED — sandbox denied CoreSimulatorService**
- Phase 4 ChatGPT Review: **PENDING**
- Final Decision: **PENDING**

## Phase 4 Implementation Snapshot

- Shared PLAYER / CPU point-space movement primitive: **IMPLEMENTED**
- CPU chase, prediction, escape, wall avoidance, and rating-based jitter:
  **IMPLEMENTED / UNIT TESTED**
- CPU SHOCK eligibility and authoritative `GameEngine.useShock` flow:
  **IMPLEMENTED / UNIT TESTED**
- HEAT speed multiplier for PLAYER and CPU, composed with IT/stage caps:
  **IMPLEMENTED / UNIT TESTED**
- Explicit FLAT / BOWL / PILLAR stage model: **IMPLEMENTED / UNIT TESTED**
- BOWL center force and 1.25 speed cap: **IMPLEMENTED / UNIT TESTED**
- PILLAR point-space collision and rendering: **IMPLEMENTED / UNIT TESTED**
- FLAT → BOWL → PILLAR match cycling: **IMPLEMENTED / UNIT TESTED**
- Minimal result-tap replay flow: **IMPLEMENTED**
- Direct TAG / PLAYER SHOCK / CPU SHOCK visual effects: **CONNECTED**

## Verification Snapshot

- Generic iOS Simulator Build: **PASS — BUILD SUCCEEDED**
- Unit Tests: **PASS — 63 XCTest methods, 0 failures**
- Simulator install / launch / visual QA: **BLOCKED** because the restricted
  execution environment refused CoreSimulatorService connections. Device
  discovery alone succeeded and found the booted iPhone 17 Pro / iOS 26.5.
- Phase 4 evidence: **NOT CAPTURED — do not treat as Visual PASS**
- Consecutive 5–10 match QA: **NOT RUN — same Simulator blocker**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**

## Next Action

Run Phase 4 Simulator QA outside the restricted sandbox, capture the required
evidence under `docs/evidence/phase-4/`, then request ChatGPT exact-SHA code and
visual review.

Do not merge to `main`. Do not begin Phase 5.

## State Conflict Rule

Before choosing work, read `docs/START_HERE.md` and this file. If Notion, Git
docs, source, tests, commit history, or the explicit task contradict this state,
stop without implementation and report the conflict for review.
