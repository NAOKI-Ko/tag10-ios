import AVFoundation
import SpriteKit
import TAG10Core
import UIKit

/// Owns short-lived Phase 2B presentation nodes. Every emitted child removes
/// itself after its action completes.
final class GameEffectsNode: SKNode {
    func emitStatus(_ text: String, at position: CGPoint, color: SKColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 13
        label.fontColor = color
        label.position = position
        label.zPosition = 72
        addChild(label)
        label.run(
            .sequence([
                .group([
                    .moveBy(x: 0, y: 10, duration: 0.38),
                    .fadeOut(withDuration: 0.38),
                ]),
                .removeFromParent(),
            ])
        )
    }

    func emitBurst(at position: CGPoint, color: SKColor, count: Int) {
        for index in 0..<count {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 70
            addChild(particle)

            let angle = CGFloat(index) / CGFloat(count) * .pi * 2
            let distance = CGFloat.random(in: 34...88)
            let destination = CGVector(dx: cos(angle) * distance, dy: sin(angle) * distance)
            particle.run(
                .sequence([
                    .group([
                        .move(by: destination, duration: 0.46),
                        .fadeOut(withDuration: 0.46),
                        .scale(to: 0.25, duration: 0.46),
                    ]),
                    .removeFromParent(),
                ])
            )
        }
    }

    func emitAfterimage(at position: CGPoint, color: SKColor) {
        let afterimage = SKShapeNode(circleOfRadius: 16)
        afterimage.fillColor = color.withAlphaComponent(0.24)
        afterimage.strokeColor = color.withAlphaComponent(0.38)
        afterimage.lineWidth = 2
        afterimage.position = position
        afterimage.zPosition = 5
        addChild(afterimage)
        afterimage.run(
            .sequence([
                .group([
                    .fadeOut(withDuration: 0.24),
                    .scale(to: 0.58, duration: 0.24),
                ]),
                .removeFromParent(),
            ])
        )
    }

    func emitShockWave(at position: CGPoint, color: SKColor, arenaFrame: CGRect) {
        let flash = SKShapeNode(circleOfRadius: 18)
        flash.fillColor = color.withAlphaComponent(0.28)
        flash.strokeColor = .white
        flash.lineWidth = 2
        flash.position = position
        flash.zPosition = 62
        addChild(flash)
        flash.run(
            .sequence([
                .group([
                    .scale(to: 2.1, duration: 0.16),
                    .fadeOut(withDuration: 0.16),
                ]),
                .removeFromParent(),
            ])
        )

        emitExpandingRing(
            at: position,
            color: color,
            radius: 102,
            delay: 0,
            duration: 0.34,
            lineWidth: 7
        )
        emitExpandingRing(
            at: position,
            color: .white,
            radius: 78,
            delay: 0.055,
            duration: 0.30,
            lineWidth: 3
        )
        flashArena(in: arenaFrame, color: color, peakAlpha: 0.11, duration: 0.22)
    }

    func emitTagTransfer(from source: CGPoint, to destination: CGPoint, arenaFrame: CGRect) {
        let beam = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: source)
        path.addLine(to: destination)
        beam.path = path
        beam.strokeColor = .tag10Gold
        beam.lineWidth = 7
        beam.lineCap = .round
        beam.zPosition = 64
        addChild(beam)
        beam.run(
            .sequence([
                .group([
                    .fadeOut(withDuration: 0.18),
                    .scaleX(to: 0.86, duration: 0.18),
                ]),
                .removeFromParent(),
            ])
        )

        let tagLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        tagLabel.text = "TAG!"
        tagLabel.fontSize = 24
        tagLabel.fontColor = .tag10Gold
        tagLabel.position = CGPoint(
            x: (source.x + destination.x) / 2,
            y: (source.y + destination.y) / 2 + 18
        )
        tagLabel.zPosition = 65
        addChild(tagLabel)
        tagLabel.run(
            .sequence([
                .group([
                    .moveBy(x: 0, y: 18, duration: 0.28),
                    .fadeOut(withDuration: 0.28),
                    .scale(to: 1.18, duration: 0.28),
                ]),
                .removeFromParent(),
            ])
        )

        emitExpandingRing(
            at: destination,
            color: .tag10Gold,
            radius: 56,
            delay: 0,
            duration: 0.28,
            lineWidth: 5
        )
        emitBurst(at: destination, color: .tag10Gold, count: 18)
        flashArena(in: arenaFrame, color: .tag10Gold, peakAlpha: 0.16, duration: 0.18)
    }

    func flashArena(
        in arenaFrame: CGRect,
        color: SKColor,
        peakAlpha: CGFloat,
        duration: TimeInterval
    ) {
        let flash = SKShapeNode(rect: arenaFrame)
        flash.fillColor = color
        flash.strokeColor = .clear
        flash.alpha = 0
        flash.zPosition = 58
        addChild(flash)
        flash.run(
            .sequence([
                .fadeAlpha(to: peakAlpha, duration: duration * 0.35),
                .fadeOut(withDuration: duration * 0.65),
                .removeFromParent(),
            ])
        )
    }

    func emitCountdownBurst(at center: CGPoint, number: Int) {
        let count = 8
        for index in 0..<count {
            let dash = SKShapeNode(rectOf: CGSize(width: 3, height: 12), cornerRadius: 1.5)
            dash.fillColor = number == 1 ? .white : .tag10Red
            dash.strokeColor = .clear
            dash.position = center
            dash.zRotation = CGFloat(index) / CGFloat(count) * .pi * 2
            dash.zPosition = 43
            addChild(dash)
            let angle = dash.zRotation + .pi / 2
            let destination = CGVector(dx: cos(angle) * 86, dy: sin(angle) * 86)
            dash.run(
                .sequence([
                    .group([
                        .move(by: destination, duration: 0.26),
                        .fadeOut(withDuration: 0.26),
                    ]),
                    .removeFromParent(),
                ])
            )
        }
    }

    private func emitExpandingRing(
        at position: CGPoint,
        color: SKColor,
        radius: CGFloat,
        delay: TimeInterval,
        duration: TimeInterval,
        lineWidth: CGFloat
    ) {
        let ring = SKShapeNode(circleOfRadius: 14)
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = lineWidth
        ring.position = position
        ring.zPosition = 61
        ring.alpha = 0
        addChild(ring)
        ring.run(
            .sequence([
                .wait(forDuration: delay),
                .group([
                    .fadeAlpha(to: 0.9, duration: 0.035),
                    .scale(to: radius / 14, duration: duration),
                ]),
                .fadeOut(withDuration: 0.09),
                .removeFromParent(),
            ])
        )
    }
}

/// Presentation-only fan-out for native feedback. Transfer feedback is
/// composite so TAG/SHOCK plus the resulting STUN does not vibrate twice.
final class GameFeedbackController {
    private let haptics = HapticFeedbackController()
    private let sound = SoundEffectController()

    func handle(_ events: [FeedbackEvent]) {
        guard !events.isEmpty else { return }

#if DEBUG
        for event in events {
            print("[TAG10 Feedback] \(event)")
        }
#endif

        if let transfer = events.compactMap(shockTransfer).first {
            haptics.play(.shockTransfer(receiver: transfer.receiver))
            sound.play(.shockTransfer(owner: transfer.owner))
            return
        }

        for event in events {
            switch event {
            case .matchStart:
                haptics.play(.matchStart)
                sound.play(.matchStart)
            case let .countdown(number):
                haptics.play(.countdown(number))
                sound.play(.countdown(number))
            case let .directTag(pusher, receiver):
                haptics.play(.directTag(receiver: receiver))
                sound.play(.directTag(pusher: pusher))
            case let .shockFire(owner):
                haptics.play(.shockFire(owner: owner))
                sound.play(.shockFire(owner: owner))
            case .shockTransfer:
                break
            case let .result(result):
                haptics.play(.result(result))
                sound.play(.result(result))
            }
        }
    }

    func stop() {
        sound.stop()
    }

    private func shockTransfer(_ event: FeedbackEvent) -> (owner: ActorID, receiver: ActorID)? {
        guard case let .shockTransfer(owner, receiver) = event else { return nil }
        return (owner, receiver)
    }
}

private final class HapticFeedbackController {
    enum Cue {
        case matchStart
        case countdown(Int)
        case directTag(receiver: ActorID)
        case shockFire(owner: ActorID)
        case shockTransfer(receiver: ActorID)
        case result(MatchResult)
    }

    func play(_ cue: Cue) {
        switch cue {
        case .matchStart:
            impact(.medium, intensity: 0.72)
        case let .countdown(number):
            impact(number == 1 ? .medium : .light, intensity: number == 1 ? 0.78 : 0.52)
        case let .directTag(receiver):
            impact(receiver == .player ? .heavy : .medium, intensity: 0.92)
        case let .shockFire(owner):
            impact(.rigid, intensity: owner == .player ? 0.62 : 0.48)
        case let .shockTransfer(receiver):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(receiver == .player ? .error : .success)
        case let .result(result):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(result == .win ? .success : .error)
        }
    }

    private func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}

private final class SoundEffectController {
    enum Cue {
        case matchStart
        case countdown(Int)
        case directTag(pusher: ActorID)
        case shockFire(owner: ActorID)
        case shockTransfer(owner: ActorID)
        case result(MatchResult)
    }

    private struct Tone {
        let start: TimeInterval
        let duration: TimeInterval
        let startFrequency: Double
        let endFrequency: Double
        let amplitude: Float
        let squareMix: Float
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate = 44_100.0
    private var isConfigured = false

    func play(_ cue: Cue) {
        guard configureIfNeeded(), let buffer = buffer(for: cue) else { return }
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        player.play()
    }

    func stop() {
        player.stop()
        engine.stop()
    }

    private func configureIfNeeded() -> Bool {
        if !isConfigured {
            guard let format = AVAudioFormat(
                standardFormatWithSampleRate: sampleRate,
                channels: 1
            ) else { return false }
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            engine.mainMixerNode.outputVolume = 0.62
            isConfigured = true
        }
        guard !engine.isRunning else { return true }
        do {
            try engine.start()
            return true
        } catch {
#if DEBUG
            print("[TAG10 Feedback] audio unavailable: \(error)")
#endif
            return false
        }
    }

    private func buffer(for cue: Cue) -> AVAudioPCMBuffer? {
        synthesize(tones(for: cue))
    }

    private func tones(for cue: Cue) -> [Tone] {
        switch cue {
        case .matchStart:
            return [tone(220, 330, at: 0, duration: 0.09, amplitude: 0.16),
                    tone(440, 520, at: 0.07, duration: 0.11, amplitude: 0.13)]
        case let .countdown(number):
            let frequency = number == 1 ? 170.0 : 120.0 + Double(3 - number) * 14
            return [tone(frequency, frequency * 0.92, duration: 0.12, amplitude: 0.13)]
        case let .directTag(pusher):
            let scale = pusher == .player ? 1.0 : 0.82
            return [tone(190 * scale, 135 * scale, duration: 0.13, amplitude: 0.20, square: 0.34),
                    tone(560 * scale, 420 * scale, at: 0.025, duration: 0.10, amplitude: 0.11)]
        case let .shockFire(owner):
            let scale = owner == .player ? 1.0 : 0.80
            return [tone(95 * scale, 310 * scale, duration: 0.17, amplitude: 0.17, square: 0.18)]
        case let .shockTransfer(owner):
            let scale = owner == .player ? 1.0 : 0.80
            return [tone(90 * scale, 300 * scale, duration: 0.12, amplitude: 0.15, square: 0.16),
                    tone(520 * scale, 360 * scale, at: 0.09, duration: 0.13, amplitude: 0.18, square: 0.24),
                    tone(125, 90, at: 0.10, duration: 0.15, amplitude: 0.13)]
        case let .result(result):
            let frequencies: [Double] = result == .win
                ? [523, 659, 784, 1_047]
                : [392, 330, 262, 196]
            return frequencies.enumerated().map { index, frequency in
                tone(
                    frequency,
                    result == .win ? frequency * 1.04 : frequency * 0.92,
                    at: Double(index) * 0.065,
                    duration: 0.13,
                    amplitude: 0.12,
                    square: result == .win ? 0.04 : 0.18
                )
            }
        }
    }

    private func tone(
        _ startFrequency: Double,
        _ endFrequency: Double,
        at start: TimeInterval = 0,
        duration: TimeInterval,
        amplitude: Float,
        square: Float = 0
    ) -> Tone {
        Tone(
            start: start,
            duration: duration,
            startFrequency: startFrequency,
            endFrequency: endFrequency,
            amplitude: amplitude,
            squareMix: square
        )
    }

    private func synthesize(_ tones: [Tone]) -> AVAudioPCMBuffer? {
        guard let end = tones.map({ $0.start + $0.duration }).max(),
              let format = AVAudioFormat(
                standardFormatWithSampleRate: sampleRate,
                channels: 1
              ) else { return nil }
        let frameCapacity = AVAudioFrameCount(ceil((end + 0.02) * sampleRate))
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCapacity
        ), let channel = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = frameCapacity

        for tone in tones {
            let startFrame = Int(tone.start * sampleRate)
            let frameCount = max(1, Int(tone.duration * sampleRate))
            var phase = 0.0
            for offset in 0..<frameCount where startFrame + offset < Int(frameCapacity) {
                let progress = Double(offset) / Double(frameCount)
                let frequency = tone.startFrequency
                    + (tone.endFrequency - tone.startFrequency) * progress
                phase += 2 * Double.pi * frequency / sampleRate
                let sine = sin(phase)
                let square: Double = sine >= 0 ? 1 : -1
                let attack = min(1, progress / 0.08)
                let release = min(1, (1 - progress) / 0.24)
                let envelope = Float(max(0, min(attack, release)))
                let wave = Float(sine) * (1 - tone.squareMix) + Float(square) * tone.squareMix
                channel[startFrame + offset] += wave * tone.amplitude * envelope
            }
        }
        return buffer
    }
}
