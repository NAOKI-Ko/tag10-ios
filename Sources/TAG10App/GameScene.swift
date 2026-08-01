import SpriteKit
import TAG10Core

/// Phase 0/1 launch surface only. Gameplay rendering starts in Phase 2.
final class GameScene: SKScene {
    private let bootstrapMatch = GameEngine.randomMatch()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 14 / 255, green: 18 / 255, blue: 24 / 255, alpha: 1)

        guard childNode(withName: "phaseLabel") == nil else { return }

        let title = SKLabelNode(text: "TAG10")
        title.name = "phaseLabel"
        title.fontName = "Menlo-Bold"
        title.fontSize = 38
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 16)
        addChild(title)

        let status = SKLabelNode(text: "GAME CORE READY • \(Int(bootstrapMatch.remainingTime))s")
        status.fontName = "Menlo-Regular"
        status.fontSize = 12
        status.fontColor = SKColor(white: 0.65, alpha: 1)
        status.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        addChild(status)
    }
}
