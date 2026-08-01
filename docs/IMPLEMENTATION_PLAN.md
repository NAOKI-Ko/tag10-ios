# IMPLEMENTATION_PLAN — TAG10

## Phase 0 — Repository/bootstrap
- Create the Xcode project.
- Keep `prototype/tag10-heat.html` as the reference implementation.
- Place `AGENTS.md` and `docs/` in the repository.
- Establish a minimal app that builds successfully.

## Phase 1 — Game core
Create testable logic for:
- GameConfig
- Match phase/state
- Actor state: position, velocity, isIt, stun, shockCooldown
- 10-second timer
- Direct tag
- Stun + paused timer
- Shock arm/cooldown
- Result determination
- Rating and streak

### Acceptance criteria
- Direct tag can be tested without depending on visual rendering.
- Timer does not decrease while either actor is stunned.
- Timeout result is uniquely determined by IT state.

## Phase 2 — SpriteKit gameplay scene
- FLAT arena
- Player/CPU visuals
- IT indicator
- Motion trail
- HUD
- FIGHT / WIN / LOSE presentation
- Shock ring
- Particles

## Phase 3 — Input
- CoreMotion tilt movement
- Tap-to-shock
- Neutral-angle calibration
- A debug drag-control fallback is acceptable for development.

## Phase 4 — CPU and stages
- Port CPU behavior from the HTML reference.
- Add BOWL.
- Add PILLAR.
- Add stage cycling.
- Add HEAT.

## Phase 5 — iOS feedback
- Haptic on tag
- Haptic on shock
- Haptic for final countdown
- Win/loss feedback
- Native sound effects inspired by the prototype

## Phase 6 — QA
- Unit tests for game rules
- State transition tests
- Simulator verification
- Device verification for tilt
- 50 consecutive matches without crash/state corruption

## Codex work-unit rule
Do not implement all phases at once.
For each requested phase:
1. Implement.
2. Build.
3. Test.
4. Report changed files.
5. Report spec deviations and unfinished items.
