# Phase 5 Simulator QA Evidence

Captured on 2026-08-12 from implementation
`1f8f96de82add416ea8e170b8e7bd7441b6a7f6b`.

## Environment

- Simulator: `TAG10 Phase 4 QA` (iPhone 17 Pro)
- Runtime: iOS 26.5
- Orientation: portrait
- Build: Debug, current Phase 5 implementation
- Consecutive match observation: 22 matches

## Visual Evidence

- `fight.png` — 10.0 timer, FIGHT, starting IT identity
- `countdown.png` — central final countdown and emphasized timer
- `direct-tag.png` — Direct TAG transfer, HEAT +3%, new-IT STUN, paused timer
- `shock-tag.png` — PLAYER SHOCK ring, transfer, CPU STUN, paused timer
- `result.png` — LOSE overlay and result detail

These are newly captured Phase 5 frames; no Phase 4 PNG was reused.

## Feedback Event Trace

Observed one-shot DEBUG events included:

- `matchStart`
- `countdown(3)`, `countdown(2)`, `countdown(1)`
- `directTag(cpu → player)` and `directTag(player → cpu)`
- PLAYER miss: `shockFire(player)` only
- PLAYER transfer: `shockFire(player)` + `shockTransfer(player → cpu)`
- CPU transfer at runtime rating 1120: `shockFire(cpu)` +
  `shockTransfer(cpu → player)`
- `result(loss)`
- `result(win)`

The rating 1120 CPU gate and WIN route were exercised only through temporary
Simulator runtime QA state. No source, rule, balance constant, or committed
data was changed.

## Sound Event QA

- AVAudioEngine started and remained stable through 22 matches.
- FIGHT, countdown, Direct TAG, PLAYER/CPU SHOCK, WIN, and LOSE event paths
  were routed without engine errors.
- Codex cannot make a reliable auditory judgment of clipping, loudness, tone,
  or PLAYER/CPU pitch distinction from the Simulator output. Those remain a
  physical-device Human Gate.

## Duplicate Suppression QA

- FIGHT emitted once per match.
- Countdown 3/2/1 emitted once each.
- Direct TAG emitted once per transfer; the resulting STUN did not create a
  second strong feedback event.
- SHOCK transfer emitted one fire + transfer pair and used the composite
  transfer/STUN path.
- Result did not replay every frame.
- Tapping result reset routing; the next match emitted a fresh FIGHT and fresh
  countdown sequence.

## Simulator Haptic Limitation

Simulator event routing is verified, but physical haptic strength, excessive
vibration, and haptic/sound synchronization cannot be evaluated in Simulator.

## Physical-device Human Gate

- Phase 5: haptic feel, vibration intensity, actual speaker volume/clipping /
  clarity, PLAYER/CPU pitch distinction, and synchronization.
- Phase 3: neutral calibration, tilt axes/direction, dead-zone and clamp feel,
  latency, and tilt + tap SHOCK.
