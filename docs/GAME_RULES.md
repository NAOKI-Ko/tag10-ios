# GAME_RULES — TAG10

## Constants
- MATCH_TIME = 10.0 seconds
- STUN = 1.0 seconds
- SHOCK_ARM = 2.0 seconds
- SHOCK_COOLDOWN = 3.0 seconds
- IT_SPEED_MULTIPLIER = 1.13
- HEAT_SPEED_PER_TAG = 0.03
- HEAT_SPEED_MAX = 0.24
- Initial tag protection = 0.6 seconds
- Post-swap tag protection = STUN + 0.3 seconds

## Match start
1. Place player and CPU at their starting positions.
2. Select IT randomly with 50/50 probability.
3. IT starts with Shock Wave unavailable for 2 seconds.
4. Set match timer to 10 seconds.
5. Run the intro/FIGHT phase, then begin play.

## Direct tag
When the actors overlap within the prototype's direct-tag threshold and protection/stun conditions allow:
- Transfer IT from pusher to receiver.
- Receiver is stunned for 1 second.
- Receiver velocity becomes zero during stun.
- Receiver's Shock Wave becomes available after 2 seconds.
- Former IT is knocked strongly away from the receiver.
- Increment tagCount by 1.
- Apply post-swap tag protection.

## Shock Wave
- IT only.
- Unavailable for 2 seconds after becoming IT.
- 3-second cooldown after use.
- If the target is in range and not stunned and tag protection has expired, transfer IT.
- Shock transfer uses a smaller knockback than direct contact.

## Timer
- Normally counts down.
- Pauses if player OR CPU is stunned.
- At zero, the actor currently IT loses.

## HEAT
`heatMultiplier = 1 + min(tagCount * 0.03, 0.24)`
- Applied to both actors.
- IT additionally gets `1.13x`.
- Resets each match.

## Stages
### FLAT
- Flat arena.
- Outer boundary only.

### BOWL
- Adds acceleration toward arena center.
- Prototype allows a larger speed cap while in this stage.

### PILLAR
- Circular obstacle at arena center.
- Actors must be pushed out if they enter the pillar radius.

## CPU behavior
Use the HTML prototype as the behavior reference:
- If CPU is IT, chase a slightly predicted future player position.
- If CPU is escaping, move away while biasing away from walls and slightly toward safer arena space.
- Higher player rating increases CPU prediction and reduces random jitter.
- CPU Shock Wave is used only when its conditions are satisfied, including the prototype rating threshold.

## Result and rating
- Player IT at timeout: LOSE, rating -16.
- Player not IT at timeout: WIN, rating +22.
- Rating floor: 0.
- Win increments streak.
- Loss resets streak to 0.

## Rank bands
- DIAMOND: 1600+
- PLATINUM: 1400+
- GOLD: 1200+
- SILVER: 1000+
- BRONZE: 0+

## Change policy
Any gameplay balance change must update this file in the same change.
Codex must not independently tune these values.
