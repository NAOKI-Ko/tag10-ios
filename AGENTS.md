# AGENTS.md

## Project
TAG10 is a native iOS adaptation of the existing HTML prototype `prototype/tag10-heat.html`.

## Continuity and cold start
- A fresh AI session must begin with `docs/START_HERE.md`.
- Do not depend on prior ChatGPT/Codex conversations, account memory, or an
  earlier chat handoff to recover project state.
- Read `docs/PROJECT_STATE.md` before selecting work or deciding which phase to
  implement.
- If Notion, Git docs, source, tests, commit history, or the explicit task
  contradict each other, stop without implementation and report the conflict.
- Keep `docs/PROJECT_STATE.md`, `docs/CODEX_REPORT.md`, and
  `docs/REVIEW_LOG.md` current when state, implementation, verification, review,
  or next action changes.
- Do not advance to a later phase until `docs/PROJECT_STATE.md` or an explicit
  user task authorizes it.
- `docs/REVIEW_LOG.md` is append-only. Record corrections in a new entry rather
  than rewriting prior review history.

## Source of truth
For a fresh session, follow the complete order in `docs/START_HERE.md` first.
Then read these implementation sources before implementation:

1. `docs/PRODUCT_SPEC.md`
2. `docs/GAME_RULES.md`
3. `docs/IMPLEMENTATION_PLAN.md`
4. `docs/QA_CHECKLIST.md`
5. `prototype/tag10-heat.html`

For game balance and behavior, `docs/GAME_RULES.md` is authoritative.
The HTML prototype is the reference implementation for feel, rendering ideas, CPU behavior, and existing flow.

## Proposed tech stack
- Swift
- SwiftUI for app/menu/result/settings UI
- SpriteKit for gameplay rendering and frame updates
- CoreMotion for tilt controls
- CoreHaptics or UIKit feedback generators for haptics
- AVFoundation for sound effects

Do not add third-party dependencies unless explicitly approved.

## Architecture rules
- Keep game rules/testable state transitions separate from SpriteKit rendering.
- Put gameplay balance constants in `GameConfig.swift`.
- Do not scatter magic numbers through scene/view code.
- Keep `GameScene` focused on rendering/input/orchestration rather than owning every rule.
- Prefer small types with clear responsibilities over one very large scene file.

## Gameplay change policy
Do not change these without explicit approval and a matching update to `docs/GAME_RULES.md`:
- 10-second match duration
- 1-second stun
- timer pause while either actor is stunned
- 2-second shock arm time
- 3-second shock cooldown
- IT speed multiplier
- HEAT progression
- rating deltas
- stage behavior
- CPU shock eligibility threshold

If a rule is ambiguous, preserve prototype behavior where possible and report the ambiguity.

## Development loop
For each requested phase:
1. Read the relevant docs.
2. Implement only the requested phase.
3. Run build.
4. Run tests.
5. Report changed files, build result, test result, unfinished work, and product decisions that need review.

Do not silently continue into later phases.

## Testing
At minimum, tests should cover:
- timer starts at 10 seconds
- timer pauses during stun
- tag swaps IT state
- receiver gets 1-second stun
- shock is unavailable for 2 seconds after becoming IT
- shock cooldown is 3 seconds after use
- winner/loser is determined by IT state at timeout
- rating cannot go below zero
- HEAT caps at +24%

## UI review
When a phase changes visible UI, leave simulator screenshots or otherwise provide visual evidence for review.

## Scope guardrails
MVP excludes:
- online multiplayer
- Game Center
- ads
- purchases
- accounts
- skins/gacha
- long-term meta progression

Do not introduce these during the native port.
