import SpriteKit
import TAG10Core

/// Visual adapter for one engine actor. It owns no gameplay state.
final class ActorNode: SKNode {
    static let visualRadius: CGFloat = 18

    private let actorName: String
    private let actorColor: SKColor
    private let aura = SKShapeNode(circleOfRadius: 24)
    private let pulseRing = SKShapeNode(circleOfRadius: 31)
    private let body = SKShapeNode(circleOfRadius: visualRadius)
    private let bodyHighlight = SKShapeNode(circleOfRadius: 6)
    private let nameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let itLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let bombBody = SKShapeNode(circleOfRadius: 7)
    private let fuse = SKShapeNode()
    private let fuseSpark = SKShapeNode(circleOfRadius: 2.5)
    private let stunRing = SKShapeNode(circleOfRadius: 25)
    private let stunLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    init(name: String, color: SKColor) {
        actorName = name
        actorColor = color
        super.init()

        zPosition = 10

        aura.fillColor = color.withAlphaComponent(0.12)
        aura.strokeColor = .clear
        aura.zPosition = -3
        addChild(aura)

        pulseRing.fillColor = .clear
        pulseRing.strokeColor = .tag10Red
        pulseRing.lineWidth = 4
        pulseRing.zPosition = -2
        addChild(pulseRing)

        body.fillColor = color
        body.strokeColor = .white
        body.lineWidth = 2
        addChild(body)

        bodyHighlight.fillColor = SKColor(white: 1, alpha: 0.42)
        bodyHighlight.strokeColor = .clear
        bodyHighlight.position = CGPoint(x: -6, y: 7)
        bodyHighlight.zPosition = 1
        addChild(bodyHighlight)

        nameLabel.text = name
        nameLabel.fontSize = 10
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -39)
        addChild(nameLabel)

        bombBody.fillColor = SKColor(red: 21 / 255, green: 24 / 255, blue: 28 / 255, alpha: 1)
        bombBody.strokeColor = .tag10Red
        bombBody.lineWidth = 2
        bombBody.position = CGPoint(x: 0, y: 39)
        addChild(bombBody)

        let fusePath = CGMutablePath()
        fusePath.move(to: CGPoint(x: 4, y: 45))
        fusePath.addLine(to: CGPoint(x: 9, y: 51))
        fuse.path = fusePath
        fuse.strokeColor = .tag10Gold
        fuse.lineWidth = 2
        fuse.lineCap = .round
        addChild(fuse)

        fuseSpark.fillColor = .tag10Gold
        fuseSpark.strokeColor = .clear
        fuseSpark.position = CGPoint(x: 10, y: 52)
        addChild(fuseSpark)

        itLabel.text = "IT"
        itLabel.fontSize = 12
        itLabel.fontColor = .tag10Red
        itLabel.position = CGPoint(x: 0, y: 53)
        addChild(itLabel)

        stunRing.fillColor = .clear
        stunRing.strokeColor = SKColor(white: 0.9, alpha: 0.7)
        stunRing.lineWidth = 2
        stunRing.zPosition = 2
        addChild(stunRing)

        stunLabel.fontSize = 11
        stunLabel.fontColor = .white
        stunLabel.position = CGPoint(x: 0, y: 27)
        stunLabel.zPosition = 3
        addChild(stunLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(actor: ActorState, visualTime: TimeInterval) {
        let isIt = actor.isIt
        pulseRing.isHidden = !isIt
        bombBody.isHidden = !isIt
        fuse.isHidden = !isIt
        fuseSpark.isHidden = !isIt
        itLabel.isHidden = !isIt

        if isIt {
            let pulse = CGFloat(0.5 + 0.5 * sin(visualTime * 9))
            pulseRing.alpha = 0.55 + pulse * 0.4
            pulseRing.setScale(0.92 + pulse * 0.14)
            aura.fillColor = .tag10Red.withAlphaComponent(0.13 + pulse * 0.09)
            aura.setScale(1 + pulse * 0.12)
            bombBody.setScale(0.94 + pulse * 0.12)
            fuseSpark.alpha = 0.45 + pulse * 0.55
            fuseSpark.setScale(0.8 + pulse * 0.55)
        } else {
            aura.fillColor = actorColor.withAlphaComponent(0.12)
            aura.setScale(1)
            bombBody.setScale(1)
        }

        let isStunned = actor.isStunned
        body.alpha = isStunned ? 0.35 : 1
        bodyHighlight.alpha = isStunned ? 0.16 : 1
        aura.alpha = isStunned ? 0.34 : 1
        nameLabel.alpha = isStunned ? 0.45 : 1
        stunRing.isHidden = !isStunned
        stunLabel.isHidden = !isStunned
        stunLabel.text = String(format: "STUN %.1fs", actor.stunRemaining)

        body.fillColor = actorColor
        accessibilityLabel = "\(actorName), \(isIt ? "IT" : "runner")\(isStunned ? ", stunned" : "")"
    }
}
