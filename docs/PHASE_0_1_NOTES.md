# Phase 0 / Phase 1 Notes

## Implemented boundary

- Phase 0 repository/bootstrap
- Phase 1 rendering-independent game core and unit tests
- Minimal SwiftUI + SpriteKit launch surface only

Gameplay rendering, input, CPU AI, stage simulation, audio, and haptics remain
outside this work unit and have not been implemented.

## TODO — product decisions

- Confirm the minimum supported iOS version. The project currently uses iOS
  17.0 as a provisional build setting only; this is not a gameplay decision.
- Choose persistence for rating and high streak before persistence work begins.
- Decide whether BGM is part of the product.

## Test portability

`TAG10Core` supports iOS and macOS because it contains only deterministic game
rules. `TAG10CoreTests` is a hostless macOS unit-test bundle so core tests can run
without a booted iOS Simulator. The app target remains native iOS.
