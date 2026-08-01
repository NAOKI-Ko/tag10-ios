# CODEX REPORT — Phase 0 / Phase 1

## Objective

Create the native iOS foundation for TAG10 and implement the testable game core
defined by Phase 0 and Phase 1 of `IMPLEMENTATION_PLAN.md`, without proceeding
to Phase 2.

## Implementation

- Created the `TAG10.xcodeproj` Xcode project and shared schemes.
- Added a native iOS `TAG10` app target using SwiftUI and SpriteKit.
- Added the cross-platform `TAG10Core` framework so game rules are independent
  of SpriteKit rendering and can be unit tested.
- Centralized authoritative gameplay constants in `GameConfig.swift`.
- Implemented match phase/state, actor state, random initial IT selection,
  timer, direct tag, stun, timer pause, tag protection, Shock arm/cooldown and
  transfer, result determination, rating, rank, streak, and HEAT calculation.
- Added a hostless `TAG10CoreTests` XCTest target.
- Preserved the supplied source-of-truth documents and HTML prototype without
  gameplay or balance changes.

## Changed Files

- `.gitignore`
- `AGENTS.md`
- `README.md`
- `TAG10.xcodeproj/project.pbxproj`
- `TAG10.xcodeproj/xcshareddata/xcschemes/TAG10.xcscheme`
- `TAG10.xcodeproj/xcshareddata/xcschemes/TAG10CoreTests.xcscheme`
- `Sources/TAG10App/TAG10App.swift`
- `Sources/TAG10App/ContentView.swift`
- `Sources/TAG10App/GameScene.swift`
- `Sources/TAG10Core/GameConfig.swift`
- `Sources/TAG10Core/GameModels.swift`
- `Sources/TAG10Core/GameEngine.swift`
- `Sources/TAG10Core/PlayerProgress.swift`
- `Tests/TAG10CoreTests/GameCoreTests.swift`
- `docs/PRODUCT_SPEC.md`
- `docs/GAME_RULES.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/QA_CHECKLIST.md`
- `docs/PHASE_0_1_NOTES.md`
- `docs/CODEX_REPORT.md`
- `prototype/tag10-heat.html`

## Build Command and Result

Command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath work/GitVerificationDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Result: **PASS — BUILD SUCCEEDED** using Xcode 26.6. `TAG10Core.framework`
was verified inside the generated app bundle.

## Test Commands and Results

The source contains **13 XCTest methods**. The prior chat report incorrectly
listed 14 descriptive items while stating 13 tests; 13 is the verified XCTest
count.

Test build command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath work/FinalTestDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing
```

Result: **PASS — TEST BUILD SUCCEEDED**.

Standard test command:

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10CoreTests \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath work/FinalTestDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Result in the Codex execution environment: **INFRASTRUCTURE FAIL** before test
execution because the sandbox denied access to
`com.apple.testmanagerd.control`.

The exact generated XCTest bundle was then executed directly:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  work/FinalTestDerivedData/Build/Products/Debug/TAG10CoreTests.xctest
```

Result: **PASS — 13 tests executed, 0 failures**.

Verified tests:

1. Match starts with 10 seconds remaining.
2. Timer does not decrease while an actor is stunned.
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

No simulator screenshot is attached. The Codex sandbox could not connect to
CoreSimulatorService. The native iOS device-SDK build succeeded, and the Phase
0/1 launch surface is intentionally limited to the SpriteKit placeholder
`TAG10 / GAME CORE READY • 10s`; gameplay visuals belong to Phase 2.

## Deviations

- No gameplay rule or balance values were changed.
- The mandatory rules are tested in a hostless macOS XCTest bundle because the
  core is rendering-independent. The app target remains native iOS.
- `xcodebuild test` could not launch the test runner inside the Codex sandbox;
  the same compiled XCTest bundle passed all 13 tests when invoked directly.
- iOS 17.0 is a provisional deployment target pending a product decision.

## Unresolved

- Simulator and physical-device launch verification.
- Standard `xcodebuild test` verification outside the restricted Codex sandbox.
- Rating and high-streak persistence.
- Bundle identifier, signing team, and release configuration.

## Decisions Needed

- Minimum supported iOS version.
- Persistence method for rating and high streak.
- Production bundle identifier and Apple development team.
- Whether BGM is in product scope.

## Next Suggested Step

Review this Phase 0 / Phase 1 snapshot in GitHub. After explicit approval of the
phase boundary and outstanding decisions, prepare a separate work unit for
Phase 2. Do not begin Phase 2 implicitly.
