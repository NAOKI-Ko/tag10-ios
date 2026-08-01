# PRODUCT_SPEC — TAG10

## Goal
Reimplement TAG10 as a native iPhone game while preserving the rules and fast pacing of the current HTML prototype.

## Product core
- One match lasts 10 seconds.
- The actor holding the bomb is “IT”.
- IT transfers the bomb by direct collision or a shock wave.
- Whoever is IT when the timer reaches zero loses.
- Repeated transfers increase HEAT and speed up both actors.
- Results should flow quickly into another match.

## Confirmed behavior from the HTML prototype
- Initial IT is random.
- A direct tag stuns the new IT for 1 second.
- The match timer pauses while either actor is stunned.
- Direct tagging strongly knocks the former IT away.
- IT unlocks Shock Wave 2 seconds after becoming IT.
- Shock Wave cooldown is 3 seconds.
- HEAT increases speed by 3% per tag, capped at +24%.
- IT has an additional 1.13x speed multiplier.
- Stages cycle through FLAT / BOWL / PILLAR.
- Win: rating +22.
- Loss: rating -16.
- Rating has a floor of zero.
- Rank bands: BRONZE / SILVER / GOLD / PLATINUM / DIAMOND.

## Native iOS implementation direction
This section is an implementation proposal, not behavior extracted from the HTML prototype:
- SwiftUI: app-level UI such as menu/result/settings.
- SpriteKit: gameplay, frame loop, collision/orchestration, visual effects.
- CoreMotion: tilt movement.
- Haptics: tag, shock, countdown, result feedback.
- AVFoundation: sound effects.
- No networked multiplayer in MVP.

## MVP success criteria
1. A complete 10-second match loop works on device.
2. Direct tag, stun, paused timer, shock wave, HEAT, and all three stages match the documented rules.
3. Tilt movement + tap-to-shock is playable.
4. Target smooth gameplay with no obvious input lag.
5. Consecutive matches update rating and streak correctly within the running session.

## Out of scope for MVP
- Online multiplayer
- Game Center
- Purchases
- Ads
- Accounts
- Skins/gacha
- Long-term meta progression

## Open product decisions
- Minimum iOS version
- Persistence method for rating/high streak
- Whether to add BGM
- Whether to add Game Center later
- Monetization model
