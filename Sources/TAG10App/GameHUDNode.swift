import Foundation
import SpriteKit
import TAG10Core

/// Read-only HUD projection of `GameEngine` state.
final class GameHUDNode: SKNode {
    private let background = SKShapeNode()
    private let timerLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let heatLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let stateLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let playerShockLabel = SKLabelNode(fontNamed: "Menlo-Regular")
    private let cpuShockLabel = SKLabelNode(fontNamed: "Menlo-Regular")
    private let pauseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    override init() {
        super.init()

        zPosition = 40
        background.fillColor = .tag10Panel
        background.strokeColor = SKColor(white: 1, alpha: 0.09)
        background.lineWidth = 1
        addChild(background)

        timerLabel.fontSize = 27
        addChild(timerLabel)

        heatLabel.fontSize = 11
        heatLabel.fontColor = .tag10Orange
        addChild(heatLabel)

        stateLabel.fontSize = 19
        addChild(stateLabel)

        for label in [playerShockLabel, cpuShockLabel] {
            label.fontSize = 9
            label.fontColor = SKColor(white: 0.62, alpha: 1)
            addChild(label)
        }

        pauseLabel.fontSize = 11
        pauseLabel.fontColor = SKColor(white: 0.76, alpha: 1)
        addChild(pauseLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(width: CGFloat, top: CGFloat) {
        background.path = CGPath(
            rect: CGRect(x: 0, y: top - 102, width: width, height: 102),
            transform: nil
        )

        timerLabel.position = CGPoint(x: width / 2, y: top - 31)
        heatLabel.position = CGPoint(x: width / 2, y: top - 51)
        stateLabel.position = CGPoint(x: width / 2, y: top - 78)
        playerShockLabel.position = CGPoint(x: 12, y: top - 49)
        playerShockLabel.horizontalAlignmentMode = .left
        cpuShockLabel.position = CGPoint(x: width - 12, y: top - 49)
        cpuShockLabel.horizontalAlignmentMode = .right
        pauseLabel.position = CGPoint(x: width / 2, y: top - 96)
    }

    func render(engine: GameEngine) {
        timerLabel.text = timerText(engine.remainingTime)
        timerLabel.fontColor = engine.remainingTime <= 3 ? .tag10Red : .white

        let bonusPercent = Int(round((engine.heatMultiplier - 1) * 100))
        heatLabel.text = "HEAT ×\(engine.tagCount)  +\(bonusPercent)%"

        if engine.player.isIt {
            stateLabel.text = engine.player.isStunned ? "YOU ARE IT — STUN" : "YOU ARE IT — TAG CPU"
            stateLabel.fontColor = .tag10Red
        } else {
            stateLabel.text = engine.cpu.isStunned ? "CPU IS IT — STUN" : "ESCAPE — CPU IS IT"
            stateLabel.fontColor = .tag10Cyan
        }

        playerShockLabel.text = shockText(name: "P1", actor: engine.player)
        cpuShockLabel.text = shockText(name: "CPU", actor: engine.cpu)
        pauseLabel.text = engine.isTimerPaused ? "TIMER PAUSED • STUN" : phaseText(engine.phase)
        pauseLabel.alpha = engine.isTimerPaused ? 1 : 0.62
    }

    private func timerText(_ remainingTime: TimeInterval) -> String {
        if remainingTime > 3 {
            return String(format: "%.1f", remainingTime)
        }
        return String(Int(ceil(remainingTime)))
    }

    private func shockText(name: String, actor: ActorState) -> String {
        guard actor.isIt else { return "\(name) SHOCK —" }
        if actor.isStunned { return "\(name) SHOCK • STUN" }
        if actor.shockCooldownRemaining > 0 {
            return String(format: "%@ ARM / COOLDOWN %.1fs", name, actor.shockCooldownRemaining)
        }
        return "\(name) SHOCK READY"
    }

    private func phaseText(_ phase: MatchPhase) -> String {
        switch phase {
        case .intro:
            return "FIGHT"
        case .playing:
            return "PLAYING • FLAT"
        case .finished:
            return "MATCH COMPLETE"
        }
    }
}
