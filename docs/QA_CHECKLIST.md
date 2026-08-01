# QA_CHECKLIST — TAG10

## Core rules
- [ ] Initial IT is random.
- [ ] Match starts from 10 seconds.
- [ ] Direct contact transfers IT.
- [ ] New IT is stunned for 1 second.
- [ ] Timer pauses during stun.
- [ ] Former IT receives strong direct-tag knockback.
- [ ] Shock is unavailable for 2 seconds after becoming IT.
- [ ] Shock cooldown is 3 seconds.
- [ ] IT at 0 seconds loses.

## HEAT
- [ ] Each tag adds 3% speed.
- [ ] HEAT caps at +24%.
- [ ] IT gets the additional 1.13 multiplier.
- [ ] HEAT resets next match.

## Stages
- [ ] FLAT works.
- [ ] BOWL center force works.
- [ ] PILLAR collision/exclusion works.
- [ ] Stages cycle correctly.

## CPU
- [ ] Chases while IT.
- [ ] Escapes while not IT.
- [ ] Avoids getting stuck at walls.
- [ ] Becomes stronger as rating rises.
- [ ] Uses Shock Wave only under intended conditions.

## UI
- [ ] IT/escape state is understandable beyond color alone.
- [ ] Final 3 seconds are clearly communicated.
- [ ] Shock READY/cooldown is clear.
- [ ] WIN/LOSE is shown.
- [ ] Rating delta is shown.
- [ ] Rank is shown.
- [ ] Streak is shown.

## Device
- [ ] Tilt neutral angle feels natural.
- [ ] Portrait play works.
- [ ] Tap and tilt do not conflict.
- [ ] HUD respects safe areas.
- [ ] Unsupported rotation is not accidentally enabled.
- [ ] No obvious input lag.

## Regression
- [ ] 50 consecutive matches.
- [ ] No immediate re-tag through protection window.
- [ ] Stunned actor cannot use Shock Wave.
- [ ] Timer never becomes meaningfully negative.
- [ ] Rating never drops below zero.
