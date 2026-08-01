import SpriteKit
import TAG10Core

/// SpriteKit presentation for the Phase 2A FLAT-stage gameplay shell.
/// `GameEngine` remains the sole source of gameplay time, state, and results.
final class GameScene: SKScene {
    private enum VisualConfig {
        static let introDuration: TimeInterval = 1.1
        static let maximumFrameStep: TimeInterval = 0.033
        static let hudHeight: CGFloat = 102
        static let arenaInset: CGFloat = 12
        static let arenaBottomInset: CGFloat = 48
    }

    private var engine = GameEngine.randomMatch(
        playerPosition: Vector2(x: 0.30, y: 0.28),
        cpuPosition: Vector2(x: 0.70, y: 0.75)
    )

    private let arenaLayer = SKNode()
    private let effectsLayer = SKNode()
    private let playerNode = ActorNode(name: "PLAYER", color: .tag10Cyan)
    private let cpuNode = ActorNode(name: "CPU", color: .tag10Orange)
    private let hudNode = GameHUDNode()
    private let fightLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let introLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let resultShade = SKShapeNode()
    private let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let resultDetailLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    private var previousUpdateTime: TimeInterval?
    private var introElapsed: TimeInterval = 0
    private var visualTime: TimeInterval = 0
    private var didPresentFight = false
    private var didPresentResult = false
    private var isConfigured = false

    override func didMove(to view: SKView) {
        guard !isConfigured else { return }
        isConfigured = true

        backgroundColor = .tag10Background
        view.ignoresSiblingOrder = true

        addChild(arenaLayer)
        addChild(effectsLayer)
        addChild(playerNode)
        addChild(cpuNode)
        addChild(hudNode)
        configurePhaseLabels()
        layoutScene()
        renderEngineState()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard view != nil else { return }
        layoutScene()
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime: TimeInterval
        if let previousUpdateTime {
            deltaTime = min(currentTime - previousUpdateTime, VisualConfig.maximumFrameStep)
        } else {
            deltaTime = 0
        }
        previousUpdateTime = currentTime
        visualTime += deltaTime

        switch engine.phase {
        case .intro:
            introElapsed += deltaTime
            if introElapsed >= VisualConfig.introDuration {
                engine.beginPlay()
                presentFightTransition()
            }
        case .playing:
            engine.advance(by: deltaTime)
        case .finished:
            presentResultIfNeeded()
        }

        // `advance` can finish the match during this frame.
        if case .finished = engine.phase {
            presentResultIfNeeded()
        }

        renderEngineState()
    }

    private var arenaFrame: CGRect {
        CGRect(
            x: VisualConfig.arenaInset,
            y: VisualConfig.arenaBottomInset,
            width: max(0, size.width - VisualConfig.arenaInset * 2),
            height: max(
                0,
                size.height - VisualConfig.hudHeight - VisualConfig.arenaBottomInset
                    - VisualConfig.arenaInset
            )
        )
    }

    private func configurePhaseLabels() {
        fightLabel.text = "FIGHT!"
        fightLabel.fontSize = 58
        fightLabel.fontColor = .white
        fightLabel.zPosition = 50
        addChild(fightLabel)

        introLabel.fontSize = 15
        introLabel.zPosition = 50
        addChild(introLabel)

        resultShade.fillColor = SKColor(white: 0.02, alpha: 0.78)
        resultShade.strokeColor = .clear
        resultShade.zPosition = 80
        resultShade.isHidden = true
        addChild(resultShade)

        resultLabel.fontSize = 66
        resultLabel.zPosition = 81
        resultLabel.isHidden = true
        addChild(resultLabel)

        resultDetailLabel.fontSize = 14
        resultDetailLabel.fontColor = SKColor(white: 0.82, alpha: 1)
        resultDetailLabel.zPosition = 81
        resultDetailLabel.isHidden = true
        addChild(resultDetailLabel)
    }

    private func layoutScene() {
        arenaLayer.removeAllChildren()
        drawFlatArena(in: arenaFrame)

        hudNode.layout(width: size.width, top: size.height)
        fightLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        introLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)

        resultShade.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.57)
        resultDetailLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.49)

        positionActors()
    }

    private func drawFlatArena(in frame: CGRect) {
        let floor = SKShapeNode(rect: frame, cornerRadius: 4)
        floor.fillColor = SKColor(red: 11 / 255, green: 15 / 255, blue: 20 / 255, alpha: 1)
        floor.strokeColor = SKColor(white: 1, alpha: 0.13)
        floor.lineWidth = 1
        floor.zPosition = -20
        arenaLayer.addChild(floor)

        let gridSpacing = max(38, frame.width / 9)
        var x = frame.minX + gridSpacing
        while x < frame.maxX {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: frame.minY))
            path.addLine(to: CGPoint(x: x, y: frame.maxY))
            line.path = path
            line.strokeColor = SKColor(white: 1, alpha: 0.045)
            line.lineWidth = 1
            line.zPosition = -19
            arenaLayer.addChild(line)
            x += gridSpacing
        }

        var y = frame.minY + gridSpacing
        while y < frame.maxY {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: frame.minX, y: y))
            path.addLine(to: CGPoint(x: frame.maxX, y: y))
            line.path = path
            line.strokeColor = SKColor(white: 1, alpha: 0.045)
            line.lineWidth = 1
            line.zPosition = -19
            arenaLayer.addChild(line)
            y += gridSpacing
        }

        let stageLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        stageLabel.text = "STAGE 1 — FLAT"
        stageLabel.fontSize = 11
        stageLabel.fontColor = SKColor(white: 0.48, alpha: 1)
        stageLabel.horizontalAlignmentMode = .left
        stageLabel.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 22)
        stageLabel.zPosition = -18
        arenaLayer.addChild(stageLabel)
    }

    private func renderEngineState() {
        positionActors()
        playerNode.render(actor: engine.player, visualTime: visualTime)
        cpuNode.render(actor: engine.cpu, visualTime: visualTime)
        hudNode.render(engine: engine)

        if engine.phase == .intro {
            fightLabel.alpha = 1
            introLabel.alpha = 1
            introLabel.text = engine.player.isIt ? "YOU START AS IT" : "CPU STARTS AS IT"
            introLabel.fontColor = engine.player.isIt ? .tag10Red : .tag10Cyan
        }
    }

    private func positionActors() {
        playerNode.position = point(for: engine.player.position)
        cpuNode.position = point(for: engine.cpu.position)
    }

    private func point(for normalizedPosition: Vector2) -> CGPoint {
        CGPoint(
            x: arenaFrame.minX + arenaFrame.width * CGFloat(normalizedPosition.x),
            y: arenaFrame.minY + arenaFrame.height * CGFloat(normalizedPosition.y)
        )
    }

    private func presentFightTransition() {
        guard !didPresentFight else { return }
        didPresentFight = true
        introLabel.run(.fadeOut(withDuration: 0.15))
        fightLabel.run(
            .sequence([
                .group([
                    .scale(to: 1.28, duration: 0.14),
                    .fadeOut(withDuration: 0.18),
                ]),
                .hide(),
            ])
        )
        emitBurst(at: CGPoint(x: size.width / 2, y: size.height * 0.54), color: .tag10Gold, count: 12)
    }

    private func presentResultIfNeeded() {
        guard !didPresentResult, case let .finished(result) = engine.phase else { return }
        didPresentResult = true

        resultShade.isHidden = false
        resultLabel.isHidden = false
        resultDetailLabel.isHidden = false
        resultLabel.text = result == .win ? "WIN" : "LOSE"
        resultLabel.fontColor = result == .win ? .tag10Mint : .tag10Red
        resultDetailLabel.text = engine.player.isIt ? "YOU HELD THE BOMB AT 0" : "CPU HELD THE BOMB AT 0"

        let loserPosition = engine.player.isIt ? playerNode.position : cpuNode.position
        emitBurst(
            at: loserPosition,
            color: result == .win ? .tag10Gold : .tag10Red,
            count: 24
        )

        resultLabel.setScale(0.7)
        resultLabel.run(.scale(to: 1, duration: 0.22))
    }

    private func emitBurst(at position: CGPoint, color: SKColor, count: Int) {
        for index in 0..<count {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 70
            effectsLayer.addChild(particle)

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
}

extension SKColor {
    static let tag10Background = SKColor(red: 14 / 255, green: 18 / 255, blue: 24 / 255, alpha: 1)
    static let tag10Panel = SKColor(red: 22 / 255, green: 28 / 255, blue: 36 / 255, alpha: 0.96)
    static let tag10Cyan = SKColor(red: 34 / 255, green: 211 / 255, blue: 238 / 255, alpha: 1)
    static let tag10Orange = SKColor(red: 255 / 255, green: 122 / 255, blue: 69 / 255, alpha: 1)
    static let tag10Red = SKColor(red: 255 / 255, green: 59 / 255, blue: 82 / 255, alpha: 1)
    static let tag10Gold = SKColor(red: 255 / 255, green: 176 / 255, blue: 32 / 255, alpha: 1)
    static let tag10Mint = SKColor(red: 95 / 255, green: 227 / 255, blue: 192 / 255, alpha: 1)
}
