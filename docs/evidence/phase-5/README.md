# Phase 5 Evidence Gate

The Phase 5 app and test targets build, and all 71 XCTest methods pass. The
Codex sandbox denied CoreSimulatorService access during install, so the current
Phase 5 build could not be launched for audio/event QA or screenshot capture.

No earlier-phase image is relabeled as Phase 5 evidence. The following files
must be captured from the current Phase 5 build before Visual QA can pass:

- `fight.png`
- `direct-tag.png`
- `shock-tag.png`
- `countdown.png`
- `result.png`

Audio and haptics cannot be proven by PNG. Verify DEBUG `[TAG10 Feedback]`
event traces, audible procedural SFX, duplicate suppression, and physical-
device haptics separately.
