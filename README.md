# TAG10 iOS

Native iOS port of the TAG10 10-second tag game.

This repository is currently frozen at **Phase 0 / Phase 1**. It contains the
Xcode bootstrap, a minimal SwiftUI + SpriteKit launch surface, and the
rendering-independent game core with unit tests. Phase 2 gameplay rendering has
not started.

## Source of truth

Game rules and balance values are defined in
[`docs/GAME_RULES.md`](docs/GAME_RULES.md). The working HTML reference is
[`prototype/tag10-heat.html`](prototype/tag10-heat.html).

Read these files before making implementation changes:

1. [`AGENTS.md`](AGENTS.md)
2. [`docs/PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md)
3. [`docs/GAME_RULES.md`](docs/GAME_RULES.md)
4. [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md)
5. [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md)
6. [`prototype/tag10-heat.html`](prototype/tag10-heat.html)

## Architecture

- `TAG10`: native iOS app target using SwiftUI and SpriteKit
- `TAG10Core`: rendering-independent game rules framework
- `TAG10CoreTests`: hostless unit-test target for deterministic core rules

Balance constants are centralized in
[`Sources/TAG10Core/GameConfig.swift`](Sources/TAG10Core/GameConfig.swift).

## Build

```sh
xcodebuild \
  -project TAG10.xcodeproj \
  -scheme TAG10 \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Tests

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

The current XCTest suite contains 13 tests. See
[`docs/CODEX_REPORT.md`](docs/CODEX_REPORT.md) for the verified results and
environment notes.

## Phase boundary

Implemented: Phase 0 and Phase 1 only.

Not implemented: SpriteKit gameplay rendering, input, CPU AI, stages, haptics,
audio, and other Phase 2+ work.
