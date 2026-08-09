# CODEX REPORT — TAG10

## Phase 3 Review Fix — 2026-08-09

- Branch: `phase-3-input`
- Previous Implementation:
  `e5825496083b9559784da174ce8406c093930fff`
- Review Fix Target: the commit containing this report section
- Status: **IMPLEMENTED / REVIEW PENDING**
- Original ChatGPT Code Review: **CHANGES REQUESTED**
- ChatGPT Code Review: **FIX IMPLEMENTED / RE-REVIEW PENDING**
- Codex Code Review: **PASS**
- Simulator Visual QA: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- ChatGPT Final Review: **PENDING**

### Objective

Correct the Phase 3 portrait-arena geometry review blockers without changing
game balance: make movement and knockback isotropic in arena point-space, and
prevent presentation-layer SHOCK attempts outside `.playing`.

### Implementation

- Added rendering-independent `ArenaGeometry` conversions between normalized
  authoritative vectors and arena point-space vectors.
- `PlayerMovement` now converts position and velocity to point-space before
  applying the existing acceleration, damping, IT speed multiplier, and speed
  cap, then converts the result back to normalized state and preserves the
  existing normalized arena bounds.
- `GameEngine.configureArena` accepts a pure `Vector2` arena size and derives
  the existing HTML relationship `MAXSPD = arena width * 0.98` without a
  SpriteKit dependency.
- Direct TAG and SHOCK transfer knockback now normalizes direction and applies
  the unchanged `2.2` / `0.85` magnitude multipliers in point-space before
  converting velocity back to normalized state.
- `GameScene` supplies arena geometry to GameEngine and ignores player SHOCK
  presentation attempts unless the authoritative phase is `.playing`.
- HEAT movement speed remains unimplemented. No Phase 0/1 gameplay value,
  damping value, multiplier, or game rule changed.

### Changed Files

- `Sources/TAG10Core/GameConfig.swift`
- `Sources/TAG10Core/GameEngine.swift`
- `Sources/TAG10Core/PlayerInput.swift`
- `Sources/TAG10App/GameScene.swift`
- `Tests/TAG10CoreTests/GameCoreTests.swift`
- `docs/START_HERE.md`
- `docs/PROJECT_STATE.md`
- `docs/REVIEW_LOG.md`
- `docs/CODEX_REPORT.md`
- `docs/evidence/phase-3/idle.png`
- `docs/evidence/phase-3/drag-movement.png`

`docs/evidence/phase-3/shock.png` was inspected against the repaired build and
retained unchanged because the geometry fix does not alter its presentation
and the existing frame most clearly shows the effect and cooldown.

### Build

Generic iOS:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/tag10-phase3-review-fix-generic \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED**.

iPhone 17 Pro Simulator:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=9D870918-AC43-4F0C-9C63-49B824D22C5B' \
  -derivedDataPath /tmp/tag10-phase3-review-fix-simulator \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED**.

### Tests

Standard `xcodebuild test` built the exact test bundle but the sandbox denied
`com.apple.testmanagerd.control` communication before XCTest execution:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/tag10-phase3-review-fix-tests \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Alternative execution of that exact generated bundle:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  /tmp/tag10-phase3-review-fix-tests/Build/Products/Debug/TAG10CoreTests.xctest
```

Result: **PASS — 27 tests executed, 0 failures**. The existing 22 tests remain
passing. Added coverage verifies rectangular-arena isotropic point movement,
diagonal point-speed cap, rectangular-arena delta-time independence, and Direct
TAG / SHOCK point-space knockback direction and magnitude.

### Simulator Launch and Visual QA

- Device: **iPhone 17 Pro**
- Runtime: **iOS 26.5**
- Orientation: **portrait**
- UDID: `9D870918-AC43-4F0C-9C63-49B824D22C5B`
- Install / launch: **PASS — `com.tag10.app` launched successfully**
- DEBUG drag: **PASS** — horizontal, vertical, diagonal, and arena edge paths
  completed without clipping or state corruption.
- Direct TAG contact: **ATTEMPTED with DEBUG drag** — injected-pointer timing
  was not treated as conclusive geometry evidence; the exact point-space
  transfer direction and magnitude passed XCTest.
- SHOCK state/effect: **PASS**
- Motion trail: **PASS — direction remained natural and the trail remained
  bounded / self-removing after the geometry repair**
- Intro/finished SHOCK guard: **PASS by code inspection** — presentation does
  not emit an attempt outside `.playing`; GameEngine guard is unchanged.

Evidence:

- `docs/evidence/phase-3/idle.png`
- `docs/evidence/phase-3/drag-movement.png`
- `docs/evidence/phase-3/shock.png`

### Deviations / Blockers

- Standard `xcodebuild test` execution is blocked only by the Codex sandbox;
  direct execution passed the exact compiled bundle.
- CoreGraphics pointer injection did not yield a deterministic Direct TAG
  capture, so the attempted contact was not used as proof of aspect-correct
  knockback. The rendering-independent Direct TAG test passed exactly.
- Physical-device CoreMotion and simultaneous tilt/tap QA remain
  **PENDING HUMAN GATE**.
- No gameplay/balance deviation. Phase 3 is not approved or closed, the branch
  was not merged to `main`, and Phase 4 was not started.

### Next Suggested Step

ChatGPT exact-SHA code/state re-review of this Review Fix, followed by the
physical-device Motion Human Gate. Do not advance to Phase 4 automatically.

## Phase 3 Input Implementation — 2026-08-09

- Branch: `phase-3-input`
- Branch Baseline:
  `292c31d581e5cddcf2270db1feb35cb8c0caf7b9`
- Latest Reviewed Implementation:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 3 Review Target: the commit containing this report section
- Status: **IMPLEMENTED / REVIEW PENDING**
- Codex Code Review: **PASS**
- Simulator Visual QA: **PASS**
- Device Motion QA: **PENDING HUMAN GATE**
- ChatGPT Final Review: **PENDING**
- Continuity: **BLOCKED ON REVIEW**

### Objective

Add only native player input to the approved Phase 2B Visual Gameplay Shell:
CoreMotion tilt movement, neutral-angle calibration, tap-to-SHOCK, DEBUG drag
fallback, and validation of the deferred motion trail.

### Implementation

- Added a pure `TiltInputMapper` that stores the first valid attitude as
  neutral, wraps angular differences, applies a radial dead zone, and clamps
  output magnitude to one.
- Added `MotionInputController` as the only CoreMotion owner. It uses
  `deviceMotion` with `xArbitraryZVertical`, samples at 60 Hz, and safely maps
  unavailable/error states to zero input without crashing.
- Added a pure exponential-damping movement integrator that produces consistent
  results across delta-time subdivision, applies the existing IT speed
  multiplier, does not apply HEAT, and clamps actor center/velocity at arena
  bounds.
- Added GameEngine APIs for authoritative player movement and DEBUG placement;
  SpriteKit actor nodes remain read-only render projections.
- Added arena-geometry range checks using the prototype's direct-tag two-radius
  and Shock four-radius relationships.
- Connected player movement and direct-contact checks to the SpriteKit update
  loop. CPU position remains fixed and no CPU decision-making was added.
- Connected a game-screen tap to the existing `GameEngine.useShock` API and
  explicitly handles `unavailable`, `missed`, and `transferred` outcomes.
- Added DEBUG-only drag/tap disambiguation. Drag writes through GameEngine,
  respects actor-radius arena bounds, and is absent from Release gameplay.
- Added minimal input status and Shock outcome text. No menu/settings expansion,
  haptics, or sound was added.
- Added `NSMotionUsageDescription` to generated app Info.plist settings.

Input constants are centralized under `GameConfig.Input`. Movement speed,
acceleration, damping, and 32-degree full-scale tilt follow the HTML reference;
the required 0.05-radian dead zone is a Phase 3 input-tuning value pending
physical-device feel validation.

### Changed Files

- `Sources/TAG10Core/GameConfig.swift`
- `Sources/TAG10Core/GameEngine.swift`
- `Sources/TAG10Core/PlayerInput.swift` (new)
- `Sources/TAG10App/GameScene.swift`
- `Sources/TAG10App/MotionInputController.swift` (new)
- `Sources/TAG10App/ActorNode.swift`
- `Sources/TAG10App/GameEffectsNode.swift`
- `Tests/TAG10CoreTests/GameCoreTests.swift`
- `TAG10.xcodeproj/project.pbxproj`
- `docs/START_HERE.md`
- `docs/PROJECT_STATE.md`
- `docs/REVIEW_LOG.md`
- `docs/CODEX_REPORT.md`
- `docs/evidence/phase-3/idle.png` (new)
- `docs/evidence/phase-3/drag-movement.png` (new)
- `docs/evidence/phase-3/shock.png` (new)

### Build

Generic iOS command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath work/Phase3Build \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED**.

The exact iPhone 17 Pro Simulator build also passed with
`work/Phase3Simulator` DerivedData.

### Tests

Standard command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath work/Phase3Tests \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Result: **INFRASTRUCTURE FAIL** after the test bundle built because the sandbox
denied `com.apple.testmanagerd.control` communication.

Direct execution of that exact compiled bundle:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  work/Phase3Tests/Build/Products/Debug/TAG10CoreTests.xctest
```

Result: **PASS — 22 tests executed, 0 failures**.

The original 13 tests remain. Nine Phase 3 tests cover dead-zone mapping, tilt
clamping, neutral offset, input-to-movement direction, arena clamping,
delta-time independence, arena-aware Shock range, unavailable Shock state
integrity, and missed Shock state/cooldown. The existing transferred-Shock test
also remains passing.

### Simulator Launch and Visual QA

- Result: **PASS**
- Device: **iPhone 17 Pro**
- Runtime: **iOS 26.5**
- Orientation: portrait
- Simulator UDID: `9D870918-AC43-4F0C-9C63-49B824D22C5B`
- Install / launch: **PASS — `com.tag10.app` launched successfully**
- CoreMotion availability fallback: **PASS** — Simulator reported unavailable,
  input stayed zero, no crash occurred, and DEBUG drag guidance appeared.
- Idle: no afterimages were emitted while PLAYER remained stationary.
- Drag movement: PLAYER moved through GameEngine, remained within the arena,
  and a short afterimage chain clearly showed movement direction without
  obscuring the actor.
- Motion trail lifecycle: emission is movement-threshold and cadence gated;
  every afterimage runs `removeFromParent()` after 0.24 seconds. No visible
  accumulation or frame-rate degradation occurred during QA.
- Tap-to-SHOCK: an actual tap after the two-second arm window produced
  `ShockOutcome.missed`, the Phase 2B ring, `SHOCK MISS`, and an authoritative
  cooldown reading of 2.9 seconds. Transfer and unavailable behavior remain
  covered by rendering-independent tests.

Evidence:

- `docs/evidence/phase-3/idle.png`
- `docs/evidence/phase-3/drag-movement.png`
- `docs/evidence/phase-3/shock.png`

### Device-only QA / Unresolved

- Physical-device CoreMotion availability and any system permission/error path.
- Neutral-angle comfort at match start and explicit recalibration behavior.
- Tilt axis direction, dead-zone feel, maximum tilt clamp, and perceived input
  latency on a physical iPhone.
- Tilt plus tap-to-SHOCK interaction on a physical iPhone.
- Standard `xcodebuild test` runner remains blocked only by the Codex sandbox;
  direct XCTest execution passed the exact generated bundle.

### Deviations / Exclusions

- No documented gameplay balance value was changed.
- The required dead zone was not numerically specified; 0.05 radians was added
  as an isolated, reviewable input value pending device tuning.
- CPU AI/movement/SHOCK, BOWL, PILLAR, stage cycling, HEAT speed application,
  haptics, sound, persistence, and all Phase 4+ work were not implemented.
- The feature branch was not merged to `main`. **Phase 4 was not started.**

### Next Suggested Step

ChatGPT exact-SHA code/state and Visual Evidence review, plus the physical-device
Motion Human Gate. Do not approve/close Phase 3 or begin Phase 4 automatically.

The sections below are historical records from earlier phases.

## Phase 2B Final Review Sync — 2026-08-09

- Decision: **APPROVE**
- Phase status: **Phase 2B CLOSED / APPROVED**
- Approved Implementation / Latest Reviewed Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Reviewed Phase 2B State Snapshot:
  `59b75cbc3af84148721bc58e5870d4c6ba9f8fed`
- Phase 2B Handoff Sync:
  `54bd99d750ffcd47f2a26a2af9ade678591312c6`
- Code / State Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Final Visual Review: **PASS**
- Evidence reviewed:
  - `docs/evidence/phase-2b/intro.png`
  - `docs/evidence/phase-2b/countdown.png`
  - `docs/evidence/phase-2b/result.png`
- Visual findings: safe-area and Dynamic Island clearance, timer/FIGHT/start-state
  readability, PLAYER / CPU / non-color IT identification, central final-count
  emphasis, unclipped HUD/arena, and immediate LOSE/detail readability all
  passed final review.
- Implementation code changed: **No**
- Build/Test rerun: **Not required — docs-only Final Review Sync**
- Approved Phase 2B Build: **PASS — BUILD SUCCEEDED**
- Approved Phase 2B Tests: **PASS — 13 XCTest methods, 0 failures**
- Deferred Visual Validation retained:
  - motion trail → Phase 3
  - tag effect → relevant gameplay phase
  - shock effect → relevant gameplay phase
- Continuity: **READY**
- Phase 3 started: **No**
- Next Action: **Await explicit Phase 3 Work Unit from ChatGPT / Notion.**

The sections below are historical implementation and handoff records. Their
pre-review statuses are preserved as the state at the time they were recorded;
the Final Review Sync above is the current authoritative receipt.

## Phase 2B Handoff Sync — 2026-08-09

- Current Phase: **Phase 2B**
- Work Unit: **Visual Polish**
- Status: **IMPLEMENTATION_AUTHORIZED_AFTER_HANDOFF_SYNC**
- Latest Reviewed Implementation:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Baseline Review Sync:
  `eba4f8e8b39aa03616ebeb5fe9334701cab0c23e`
- Handoff Sync Commit:
  `54bd99d750ffcd47f2a26a2af9ade678591312c6`
- Phase 2B Review Target: **Not created**
- Implementation code changed by this Handoff Sync: **No**
- Build/Test rerun: **Not required — docs-only Handoff Sync**
- Next Action: implement only Phase 2B visual presentation after this commit is
  pushed and its state is verified.
- Phase Gate: **Phase 3 is PROHIBITED.**

## Phase 2B Visual Polish Implementation — 2026-08-09

- Implementation Commit / Review Target:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Review status: **AWAITING_CHATGPT_REVIEW**

### Objective

Improve the readability, immediacy, and presentation quality of the approved
Phase 2A ten-second gameplay shell without changing gameplay rules, input, CPU
behavior, or the Phase 2A safe-area layout.

### Implementation

- Added short, self-removing actor afterimages that are emitted only when the
  observed engine position has actually changed beyond a small visual
  threshold. No artificial movement was introduced.
- Added primary and secondary expanding Shock rings, a compact origin flash,
  and a short arena flash. Shock presentation is triggered only by observing a
  cooldown transition from ready to active on the actor who was IT.
- Added an IT-transfer beam, `TAG!` label, destination ring, burst, and short
  arena flash. Transfer presentation is triggered only by observing the
  authoritative IT-state difference.
- Added a large central 3 / 2 / 1 countdown with a ring, scale pulse, fade, and
  short radial dashes while retaining the readable HUD timer.
- Added a quick FIGHT entrance/exit and arena flash without extending the
  existing 1.1-second intro.
- Added result shade fade, title pop, accent line, detail-text entrance, and
  bounded particles. `YOU HELD THE BOMB AT 0` / `CPU HELD THE BOMB AT 0`
  remains unobstructed and readable.
- Added subtle actor aura/highlight and fuse pulse while preserving non-color
  IT identification through the `IT` text, bomb marker, and ring.
- Added an urgent HUD timer plate and clearer ready/cooldown colors without
  introducing a second timer or gameplay state.
- Every temporary effect node ends with `removeFromParent()`.

### Changed Files

- `Sources/TAG10App/GameScene.swift`
- `Sources/TAG10App/ActorNode.swift`
- `Sources/TAG10App/GameHUDNode.swift`
- `Sources/TAG10App/GameEffectsNode.swift`
- `TAG10.xcodeproj/project.pbxproj`
- `docs/CODEX_REPORT.md`
- `docs/evidence/phase-2b/intro.png`
- `docs/evidence/phase-2b/countdown.png`
- `docs/evidence/phase-2b/result.png`

TAG10Core, `GameEngine`, `GameConfig`, tests, `docs/GAME_RULES.md`, gameplay
balance, input, CPU AI, and the SwiftUI safe-area layout were not changed.

### Build

Command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath work/Phase2BBuild \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED**.

The iPhone 17 Pro Simulator build also passed using the exact device UDID and
`work/Phase2BVisualQADerivedData`.

### Tests

Standard command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath work/Phase2BTestDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Result: **INFRASTRUCTURE FAIL** after building the test bundle because the
sandbox denied `com.apple.testmanagerd.control` communication.

Direct execution of the exact compiled bundle:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  work/Phase2BTestDerivedData/Build/Products/Debug/TAG10CoreTests.xctest
```

Result: **PASS — 13 tests executed, 0 failures**.

### Simulator Visual QA

- Result: **PASS**
- Device: **iPhone 17 Pro**
- Runtime: **iOS 26.5**
- Orientation: portrait
- Simulator UDID: `9D870918-AC43-4F0C-9C63-49B824D22C5B`
- Verified normal transition: **FIGHT → PLAYING → LOSE**
- FIGHT and its start-state explanation are immediately readable.
- The HUD, arena, timer plate, and actors stay clear of the Dynamic Island,
  status bar, home indicator, and screen edges.
- The final countdown is large and centered within the arena; the HUD timer
  remains visible and does not clip.
- LOSE is immediately recognizable and `YOU HELD THE BOMB AT 0` remains clear
  over the result shade.
- PLAYER / CPU remain visually distinct, and IT remains identifiable through
  text, bomb, and ring rather than color alone.

Evidence:

- `docs/evidence/phase-2b/intro.png`
- `docs/evidence/phase-2b/countdown.png`
- `docs/evidence/phase-2b/result.png`

### Deferred Visual Validation

- Motion trail → **Phase 3**, when real actor movement exists.
- Tag effect → **relevant gameplay phase**, when a normal tag can occur.
- Shock effect → **relevant gameplay phase**, when a normal Shock can fire.

The Phase 2B shell contains transition-based presentation for these events, but
no movement, input, or AI was added solely to manufacture evidence.

### Deviations / Unresolved

- The first Simulator recording was obscured by a pre-existing system Apple
  Account sign-in dialog from another app. The dialog was dismissed and a clean
  TAG10 run was recorded; this was not a TAG10 defect.
- Standard `xcodebuild test` remains blocked by the execution sandbox; direct
  `xctest` passed the exact built bundle.
- Physical-device Visual QA remains unresolved.
- No gameplay, balance, or Phase 3 deviation was made. **Phase 3 was not
  started.**

## Phase 2A Objective

Implement only **Phase 2A — Visual gameplay shell** for the native TAG10 iOS
app. Connect SpriteKit presentation to the existing rendering-independent
`GameEngine` without changing Phase 0/1 game rules or balance values.

## Final Review Receipt / Review Sync — 2026-08-09

- Decision: **APPROVE**
- Phase status: **Phase 2A CLOSED / APPROVED**
- Approved Implementation / Latest Reviewed Implementation Commit:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Reviewed State Snapshot:
  `6bfc6529b42259d1dc9cf845f55f3396c6e04ffa`
- Code / State Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Final Visual Review: **PASS**
- Evidence reviewed:
  - `docs/evidence/phase-2a/intro.png`
  - `docs/evidence/phase-2a/playing.png`
  - `docs/evidence/phase-2a/result.png`
- Implementation code changed by this Review Sync: **No**
- Build/Test rerun: **Not required — docs-only Review Sync**
- Continuity: **READY**
- Phase 2B started: **No**
- Next Action: **Await explicit Phase 2B Work Unit from ChatGPT / Notion.**

## Historical Review Sync + Continuity Bootstrap — 2026-08-09

This section records the pre-approval state that was superseded by the Final
Review Receipt above.

- Formal Work Unit:
  `Phase 2A Review Sync + Continuity Bootstrap — Work Unit 2026-08-09`
- Phase: **Phase 2A**
- Review Target Implementation Commit:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Latest Reviewed Implementation Commit:
  `c5d79715acaa30f1a70dbf128e3267bbb11223ad`
- Code Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Visual Review: **PENDING**
- Implementation code changed in this Work Unit: **No**
- Created `docs/START_HERE.md`, `docs/PROJECT_STATE.md`, and the append-only
  `docs/REVIEW_LOG.md`.
- Updated `AGENTS.md` with the Cold Start, no-chat-dependency, state-conflict,
  review-sync, and phase-gate contract.
- Verified all three existing Phase 2A evidence files are present, readable, and
  consistent with the recorded Codex Visual QA result.
- Existing Build/Test results below were reviewed and retained. They were not
  rerun because this Work Unit changes documentation/state only.
- Next Action: **State Snapshot push → ChatGPT exact SHA / Visual Evidence
  review**
- Phase Gate: **Do not start Phase 2B or Phase 3.**

### Continuity Acceptance Test

**PASS.** A fresh AI reading only `docs/START_HERE.md` and its ordered Git
references can recover:

- Project: TAG10
- Current Phase / Work Unit: Phase 2A / Review Sync + Continuity Bootstrap
- Latest Reviewed Implementation: `c5d79715...`
- Review Target Implementation: `26dfdb29...`
- Code Review: PASS
- Codex Visual QA: PASS
- ChatGPT Visual Review: PENDING
- Next Action: State Snapshot push → exact SHA / Visual Evidence review
- Phase 2B remains prohibited
- Source-of-truth reading order and the state-conflict stop rule

## Implementation

- Connected `GameScene` to one authoritative `GameEngine` match.
- Added a FLAT-only grid arena and fixed player/CPU starting positions based on
  the HTML reference implementation.
- Added player and CPU actor nodes. IT is identified by an explicit `IT` label,
  bomb marker, and pulsing ring, so the distinction does not rely on color.
- Added the 1.1-second FIGHT presentation and transition into `.playing`.
- Advanced the existing engine timer from the SpriteKit `update` loop. No HUD
  timer or duplicate gameplay state was introduced.
- Added a read-only HUD projection for remaining time, HEAT count/bonus, both
  actors' Shock arm/cooldown state, current match state, and timer pause.
- Added actor and HUD STUN presentation.
- Added WIN / LOSE presentation driven by `MatchPhase.finished` and the engine's
  result.
- Added only minimal pulse-ring and particle-burst feedback.
- Split the implementation plan into Phase 2A and Phase 2B.

## Changed Files

- `Sources/TAG10App/GameScene.swift`
- `Sources/TAG10App/ActorNode.swift`
- `Sources/TAG10App/GameHUDNode.swift`
- `Sources/TAG10App/ContentView.swift` (Visual QA safe-area fix)
- `TAG10.xcodeproj/project.pbxproj`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/CODEX_REPORT.md`
- `docs/evidence/phase-2a/intro.png`
- `docs/evidence/phase-2a/playing.png`
- `docs/evidence/phase-2a/result.png`

The Phase 0/1 core source, `docs/GAME_RULES.md`, `docs/PRODUCT_SPEC.md`,
`docs/QA_CHECKLIST.md`, and `prototype/tag10-heat.html` were not changed.

## Build Command and Result

Command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath work/Phase2AFinalBuild \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED**.

An earlier compile verification also passed with `-sdk iphonesimulator` despite
the environment being unable to connect to a running CoreSimulator service.

## Test Commands and Results

The existing suite still contains exactly **13 XCTest methods**.

Standard command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath work/TestDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Result in the Codex environment: **INFRASTRUCTURE FAIL** after successfully
building the test bundle. The sandbox denied communication with
`com.apple.testmanagerd.control` before XCTest execution.

The same Xcode-generated bundle was executed directly:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  work/TestDerivedData/Build/Products/Debug/TAG10CoreTests.xctest
```

Result: **PASS — 13 tests executed, 0 failures**.

Verified tests:

1. Match starts with 10 seconds remaining.
2. Timer does not decrease while either actor is stunned.
3. Direct contact swaps IT state.
4. New IT is stunned for one second and velocity is cleared.
5. Shock is unavailable for two seconds after becoming IT.
6. Shock starts a three-second cooldown after use.
7. An in-range Shock transfers IT state.
8. The actor who is IT at zero loses.
9. Rating never drops below zero.
10. HEAT caps at +24%.
11. Wins increment streak/rating and loss resets streak with the documented
    rating delta.
12. HEAT resets for a new match.
13. Random match initialization always produces exactly one IT actor.

## Visual Evidence

- `docs/evidence/phase-2a/intro.png`
- `docs/evidence/phase-2a/playing.png`
- `docs/evidence/phase-2a/result.png`

## Visual QA

### Simulator Used

- Device: **iPhone 17 Pro**
- Runtime: **iOS 26.5**
- Orientation: portrait
- Simulator UDID: `9D870918-AC43-4F0C-9C63-49B824D22C5B`
- Build: Debug, iOS Simulator, `CODE_SIGNING_ALLOWED=NO`

### Verification Result

Result after the safe-area correction: **PASS**.

- HUD remains within the app content area and clear of the Dynamic Island,
  status bar, home indicator, and screen edges.
- PLAYER and CPU are clearly distinguished by labels, fixed positions, and
  separate cyan/orange actor bodies.
- IT is independently identifiable through the `IT` text, bomb/fuse marker,
  and pulsing ring in addition to color.
- Recorded execution transitioned normally from FIGHT to PLAYING to LOSE.
- The 10.0-second timer is centered, unobstructed, and readable.
- During the final three seconds, the timer switches to a large red integer and
  remains unobstructed.
- The LOSE result is immediately recognizable through a large red result title
  and the explanatory `YOU HELD THE BOMB AT 0` text. The WIN presentation uses
  the same verified layout path with the engine-selected result styling.
- No portrait layout overlap or clipping remains on the tested iPhone size.

### Issues Found

Initial run: the SpriteKit view ignored all safe areas, placing the HUD timer
under the Dynamic Island and status bar. This made the 10-second timer and final
three-second countdown partially invisible.

### Fix Required

**Yes — fixed and re-verified.** `ContentView` now keeps `SpriteView` inside the
safe area while the dark background alone extends edge-to-edge. No gameplay
logic, balance value, visual effect, or Phase 2B feature was changed. No further
Visual QA blocker was found after the second run.

## Deviations

- No gameplay rule or balance constant was changed.
- The standard `xcodebuild test` runner is blocked by the execution sandbox; the
  exact compiled XCTest bundle passed all 13 tests with direct `xctest`.

## Unresolved

- Physical-device visual verification.
- Standard `xcodebuild test` execution outside the restricted Codex sandbox.
- Phase 2B visual polish.
- Player controls, CPU AI, additional stages, movement speed application,
  haptics, sound, and persistence remain outside Phase 2A.

## Decisions Needed

- Minimum supported iOS version.
- Persistence method for rating and high streak.
- Production bundle identifier and Apple development team.
- Whether BGM is in product scope.

No new Phase 2A product decision was made beyond the supplied requirements and
the HTML visual reference.

## Next Suggested Step

Review the Phase 2A Visual QA evidence and safe-area correction. Begin Phase 2B
only after explicit approval; do not proceed to Phase 2B or Phase 3 implicitly.

## Phase 4 — CPU / Stages / HEAT (2026-08-10)

### Objective

Port the HTML prototype's CPU gameplay, HEAT movement, BOWL/PILLAR stage
physics, and per-match stage cycling without starting Phase 5 or merging main.

### Implementation

- Generalized Phase 3 movement into one pure point-space primitive used by
  PLAYER and CPU; normalized `GameEngine` state remains authoritative.
- Added deterministic CPU chase/prediction, runner escape, wall avoidance,
  center bias, rating-based lead/jitter, and magnitude clamping.
- Added CPU SHOCK eligibility at rating 1120 and `SHOCK_R × 0.9`; transfer
  remains exclusively owned by `GameEngine.useShock`.
- Applied HEAT to both actors as base × IT × HEAT × stage speed cap.
- Added explicit FLAT/BOWL/PILLAR models, point-space BOWL force (3.2), BOWL
  cap (1.25), and pure PILLAR collision (2.6 actor radii plus actor radius).
- Added FLAT → BOWL → PILLAR cycling and minimal result-tap replay.
- Connected actual Direct TAG and PLAYER/CPU SHOCK changes to existing effects.

### Changed Files

- `Sources/TAG10Core/GameModels.swift`
- `Sources/TAG10Core/GameConfig.swift`
- `Sources/TAG10Core/PlayerInput.swift`
- `Sources/TAG10Core/GameEngine.swift`
- `Sources/TAG10App/GameScene.swift`
- `Sources/TAG10App/GameHUDNode.swift`
- `Tests/TAG10CoreTests/GameCoreTests.swift`
- `docs/PROJECT_STATE.md`
- `docs/START_HERE.md`
- `docs/REVIEW_LOG.md`
- `docs/CODEX_REPORT.md`

### Build / Tests

- Generic iOS Simulator build: **PASS — BUILD SUCCEEDED**
- XCTest bundle build (macOS host): **PASS — TEST BUILD SUCCEEDED**
- Direct XCTest execution: **PASS — 63 tests, 0 failures**
- Standard Simulator runner: **BLOCKED** because this sandbox refused
  CoreSimulatorService access; direct execution used the generated test bundle.

### Visual Evidence / Simulator QA

- `xcrun simctl list devices available` found the booted iPhone 17 Pro / iOS
  26.5.
- Install/launch failed before app execution because CoreSimulatorService was
  denied by the execution sandbox.
- Required `docs/evidence/phase-4/*.png` files were therefore **not captured**.
- FLAT/BOWL/PILLAR, real TAG/SHOCK visuals, HEAT observation, and 5–10-match
  continuity are **NOT VISUAL PASS** and remain blocked pending an unrestricted
  Simulator run.

### Review / Continuity

- Phase 3 ChatGPT Code Review: **PASS**
- Phase 3 Device Motion QA: **PENDING HUMAN GATE**
- Phase 3 status: **NOT CLOSED**
- Phase 4 Codex Code Review: **PASS**
- Phase 4 status: **IMPLEMENTED / REVIEW PENDING**
- Phase 4 ChatGPT Review: **PENDING**
- Phase 5 started: **No**
- Main merged: **No**

### Deviations / Unresolved / Decisions Needed

- No gameplay/balance constant or documented rule was changed.
- At the exact PILLAR center, where the HTML direction is mathematically
  undefined, collision uses a deterministic outward normal so the explicit
  requirement that actors cannot remain inside is upheld.
- No new product decision was made.
- Unresolved: external Simulator visual QA/evidence and Phase 3 physical-device
  Motion QA.

### Next Suggested Step

Run the Phase 4 Simulator checklist outside the restricted sandbox, capture the
required evidence, and request exact-SHA ChatGPT review. Do not merge main or
begin Phase 5.
