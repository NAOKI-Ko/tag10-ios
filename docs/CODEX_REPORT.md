# CODEX REPORT — Phase 2A

## Objective

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
