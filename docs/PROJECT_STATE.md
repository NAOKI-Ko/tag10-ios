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
- Phase 4 Review Target Implementation Commit:
  `3486d7d720042fcacf43773ded2ac7c71a8e5a91`
- Phase 4 Recovery Base:
  `f1912a965232cb1b9af920f5071ca8fd5f6cb602`
- Phase 4 QA / State Snapshot: the commit containing this file; resolve with
  `git log -1 --format=%H -- docs/PROJECT_STATE.md`
- Phase 4 Codex Code Review: **PASS**
- Phase 4 Simulator QA: **PARTIAL PASS / BLOCKED ONLY ON CPU SHOCK VISUAL**
- Phase 4 Codex Visual QA: **PARTIAL PASS** — all requested Simulator paths
  except CPU SHOCK were exercised; CPU SHOCK is rating-gated at 1120 and no
  gameplay/debug override was authorized.
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

- Generic iOS Build: **PASS — BUILD SUCCEEDED**
- Generic iOS Simulator Build: **PASS — BUILD SUCCEEDED**
- Unit Tests: **PASS — 63 XCTest methods, 0 failures**
- Simulator install / launch: **PASS** — dedicated iPhone 17 Pro / iOS 26.5,
  portrait, UDID `D400D5D1-F7D8-470A-B5B5-DEE63384995D`.
- FLAT CPU chase, CPU runner escape, Direct TAG, PLAYER SHOCK transfer, BOWL,
  PILLAR, HEAT, timer/STUN, and state reset QA: **PASS**.
- CPU SHOCK visual trigger: **BLOCKED** — current in-memory rating is below the
  documented 1120 eligibility threshold. Eligibility/transfer logic passes
  XCTest; no balance or QA-only source override was introduced.
- Consecutive match QA: **PASS — 19 matches**, with intact
  FLAT → BOWL → PILLAR cycling, no crash/state corruption, and HEAT reset to
  zero at each new match.
- Phase 4 evidence: **CAPTURED** under `docs/evidence/phase-4/`.
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**

## Next Action

Push the Phase 4 QA/state snapshot, then request ChatGPT exact-SHA code/state
and visual review. The review receipt must explicitly retain the CPU SHOCK
visual limitation unless a separate authorized rating-eligible run is supplied.

Do not merge to `main`. Do not begin Phase 5.

## State Conflict Rule

Before choosing work, read `docs/START_HERE.md` and this file. If Notion, Git
docs, source, tests, commit history, or the explicit task contradict this state,
stop without implementation and report the conflict for review.
