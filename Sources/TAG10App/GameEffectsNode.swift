import SpriteKit

/// Owns short-lived Phase 2B presentation nodes. Every emitted child removes
/// itself after its action completes.
final class GameEffectsNode: SKNode {
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
