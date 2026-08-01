# CODEX REPORT — Phase 2A

## Objective

Implement only **Phase 2A — Visual gameplay shell** for the native TAG10 iOS
app. Connect SpriteKit presentation to the existing rendering-independent
`GameEngine` without changing Phase 0/1 game rules or balance values.

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
- `TAG10.xcodeproj/project.pbxproj`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/CODEX_REPORT.md`

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

No simulator screenshots were captured. `xcrun simctl list devices available`
failed because this Codex sandbox cannot connect to CoreSimulatorService
(`NSPOSIXErrorDomain Code=61`, connection refused). The iOS app compiled
successfully, but intro / playing / result could not be launched for screenshots
in this environment.

## Deviations

- No gameplay rule or balance constant was changed.
- The standard `xcodebuild test` runner is blocked by the execution sandbox; the
  exact compiled XCTest bundle passed all 13 tests with direct `xctest`.
- Simulator screenshots are omitted because CoreSimulatorService is unavailable.

## Unresolved

- Simulator or physical-device visual verification of intro, playing, and
  result presentation.
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

Review the Phase 2A commit and visually verify intro / playing / result on an
iOS Simulator or device. Begin Phase 2B only after explicit approval; do not
proceed to Phase 2B or Phase 3 implicitly.
