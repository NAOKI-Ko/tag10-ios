# PROJECT STATE — TAG10

Last synchronized: 2026-08-09 (Asia/Tokyo)

## Identity

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `phase-3-input`
- Phase: **Phase 3**
- Status: **IMPLEMENTED / REVIEW PENDING**
- Work Unit: **Input**
- Continuity: **BLOCKED ON REVIEW**

## Review State

- Latest Reviewed Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 3 Branch Baseline:
  `292c31d581e5cddcf2270db1feb35cb8c0caf7b9`
- Phase 3 Review Target Implementation Commit: the commit containing this file;
  resolve with `git log -1 --format=%H -- docs/PROJECT_STATE.md`
- Codex Code Review: **PASS**
- Simulator Visual QA: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- ChatGPT Final Review: **PENDING**
- Final Decision: **PENDING**

## Implementation Snapshot

- CoreMotion `deviceMotion` adapter: **IMPLEMENTED**
- Neutral-angle calibration: **IMPLEMENTED — first valid attitude sample**
- Dead-zone and clamped tilt mapping: **IMPLEMENTED / UNIT TESTED**
- Player-only delta-time-independent movement: **IMPLEMENTED / UNIT TESTED**
- Authoritative GameEngine position and arena bounds: **IMPLEMENTED / UNIT TESTED**
- DEBUG drag fallback: **IMPLEMENTED / SIMULATOR PASS**
- Tap-to-SHOCK using GameEngine: **IMPLEMENTED / SIMULATOR PASS**
- Shock outcomes (`unavailable`, `missed`, `transferred`): **UNIT TESTED**
- Motion trail on real player movement: **SIMULATOR VISUAL PASS**
- CPU movement / AI / Shock AI: **NOT IMPLEMENTED — OUT OF SCOPE**
- HEAT movement-speed application: **NOT IMPLEMENTED — OUT OF SCOPE**

## Verification Snapshot

- Generic iOS Build: **PASS — BUILD SUCCEEDED**
- Simulator Build: **PASS — BUILD SUCCEEDED**
- Tests: **PASS — 22 XCTest methods, 0 failures**
- Simulator Launch: **PASS — iPhone 17 Pro / iOS 26.5 / portrait**
- Simulator motion availability fallback: **PASS — no crash, DEBUG drag enabled**
- Evidence:
  - `docs/evidence/phase-3/idle.png`
  - `docs/evidence/phase-3/drag-movement.png`
  - `docs/evidence/phase-3/shock.png`
- Device-only QA:
  - physical-device CoreMotion availability and permission/error path
  - neutral hold comfort and recalibration behavior
  - tilt axis direction, dead-zone feel, clamp feel, and input latency
  - simultaneous tilt plus tap-to-SHOCK

## Next Action

**ChatGPT exact-SHA code/state and Visual Evidence review, followed by
physical-device Motion QA.**

Do not advance Latest Reviewed Implementation until the Phase 3 Review Target
is approved. Do not merge to `main`. **Phase 4 is PROHIBITED.**

## State Conflict Rule

Before choosing work, read `docs/START_HERE.md` and this file. If Notion, Git
docs, source, tests, commit history, or the explicit task contradict this state,
stop without making implementation changes and report the conflict for review.
