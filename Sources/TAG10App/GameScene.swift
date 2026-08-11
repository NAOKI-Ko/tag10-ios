import SpriteKit
import TAG10Core

/// SpriteKit presentation for gameplay, stages, and transient effects.
/// `GameEngine` remains the sole source of gameplay time, state, and results.
final class GameScene: SKScene {
    private enum VisualConfig {
        static let introDuration: TimeInterval = 1.1
        static let maximumFrameStep: TimeInterval = 0.033
        static let hudHeight: CGFloat = 102
        static let arenaInset: CGFloat = 12
        static let arenaBottomInset: CGFloat = 48
        static let trailMovementThreshold: CGFloat = 0.75
        static let trailEmissionInterval: TimeInterval = 0.045
    }

    /// A render-only observation of engine values used to detect visual events.
    /// It never feeds state back into `GameEngine`.
    private struct VisualSnapshot {
        let playerPosition: Vector2
        let cpuPosition: Vector2
        let playerIsIt: Bool
        let cpuIsIt: Bool
        let playerShockCooldown: TimeInterval
        let cpuShockCooldown: TimeInterval

        init(engine: GameEngine) {
            playerPosition = engine.player.position
            cpuPosition = engine.cpu.position
            playerIsIt = engine.player.isIt
            cpuIsIt = engine.cpu.isIt
            playerShockCooldown = engine.player.shockCooldownRemaining
            cpuShockCooldown = engine.cpu.shockCooldownRemaining
        }
    }

    private var engine = GameEngine.randomMatch(
        playerPosition: Vector2(x: 0.30, y: 0.28),
        cpuPosition: Vector2(x: 0.70, y: 0.75),
        stage: .flat
    )
    private var series = MatchSeriesState()
    private var progress = PlayerProgress()
    private var feedbackRouter = FeedbackEventRouter()

    private let motionInputController = MotionInputController()
    private let feedbackController = GameFeedbackController()
    private let arenaLayer = SKNode()
    private let effectsLayer = GameEffectsNode()
    private let playerNode = ActorNode(name: "PLAYER", color: .tag10Cyan)
    private let cpuNode = ActorNode(name: "CPU", color: .tag10Orange)
    private let hudNode = GameHUDNode()
    private let fightLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let introLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let countdownHalo = SKShapeNode(circleOfRadius: 72)
    private let countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let resultShade = SKShapeNode()
    private let resultAccent = SKShapeNode(rectOf: CGSize(width: 128, height: 3), cornerRadius: 1.5)
    private let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let resultDetailLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let inputStatusLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    private var previousUpdateTime: TimeInterval?
    private var introElapsed: TimeInterval = 0
    private var visualTime: TimeInterval = 0
    private var didPresentFight = false
    private var didPresentResult = false
    private var didRecordResult = false
    private var isConfigured = false
    private var previousVisualSnapshot: VisualSnapshot?
    private var previousCountdownNumber: Int?
    private var lastPlayerTrailTime: TimeInterval = -1000
    private var lastCPUtrailTime: TimeInterval = -1000

#if DEBUG
    private var debugTouchStart: CGPoint?
    private var isDebugDragging = false
#endif

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
        previousVisualSnapshot = VisualSnapshot(engine: engine)
        presentIntroEntrance()
        dispatchFeedback(feedbackRouter.startMatch())
        motionInputController.start()
    }

    override func willMove(from view: SKView) {
        motionInputController.stop()
        feedbackController.stop()
        super.willMove(from: view)
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
            if engine.phase == .playing {
                updatePlayerMovement(deltaTime: deltaTime)
                updateCPUMovement(deltaTime: deltaTime)
                attemptCPUShockIfNeeded()
                attemptDirectTagIfNeeded()
            }
        case .finished:
            presentResultIfNeeded()
        }

        // `advance` can finish the match during this frame.
        if case .finished = engine.phase {
            presentResultIfNeeded()
        }

        dispatchFeedback(
            feedbackRouter.observe(
                phase: engine.phase,
                remainingTime: engine.remainingTime,
                timerPaused: engine.isTimerPaused
            )
        )

        presentVisualStateChanges()
        renderEngineState()
        renderInputStatus()
        updateCountdownPresentation()
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

    private var movementBounds: MovementBounds {
        guard arenaFrame.width > 0, arenaFrame.height > 0 else { return .normalized }
        let horizontalInset = Double(ActorNode.visualRadius / arenaFrame.width)
        let verticalInset = Double(ActorNode.visualRadius / arenaFrame.height)
        return MovementBounds(
            minimumX: horizontalInset,
            maximumX: 1 - horizontalInset,
            minimumY: verticalInset,
            maximumY: 1 - verticalInset
        )
    }

    private var arenaSizeVector: Vector2 {
        Vector2(x: Double(arenaFrame.width), y: Double(arenaFrame.height))
    }

    private func configurePhaseLabels() {
        fightLabel.text = "FIGHT!"
        fightLabel.fontSize = 58
        fightLabel.fontColor = .white
        fightLabel.zPosition = 50
        addChild(fightLabel)

        introLabel.fontSize = 15
        introLabel.zPosition = 50
        introLabel.alpha = 0
        addChild(introLabel)

        countdownHalo.fillColor = SKColor(red: 1, green: 0.08, blue: 0.16, alpha: 0.08)
        countdownHalo.strokeColor = .tag10Red
        countdownHalo.lineWidth = 3
        countdownHalo.zPosition = 44
        countdownHalo.isHidden = true
        addChild(countdownHalo)

        countdownLabel.fontSize = 116
        countdownLabel.fontColor = .white
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.zPosition = 45
        countdownLabel.isHidden = true
        addChild(countdownLabel)

        resultShade.fillColor = SKColor(white: 0.02, alpha: 0.78)
        resultShade.strokeColor = .clear
        resultShade.zPosition = 80
        resultShade.isHidden = true
        addChild(resultShade)

        resultAccent.fillColor = .tag10Gold
        resultAccent.strokeColor = .clear
        resultAccent.zPosition = 81
        resultAccent.isHidden = true
        addChild(resultAccent)

        resultLabel.fontSize = 66
        resultLabel.zPosition = 81
        resultLabel.isHidden = true
        addChild(resultLabel)

        resultDetailLabel.fontSize = 14
        resultDetailLabel.fontColor = SKColor(white: 0.82, alpha: 1)
        resultDetailLabel.zPosition = 81
        resultDetailLabel.isHidden = true
        addChild(resultDetailLabel)

        inputStatusLabel.fontSize = 10
        inputStatusLabel.fontColor = SKColor(white: 0.58, alpha: 1)
        inputStatusLabel.zPosition = 41
        addChild(inputStatusLabel)
    }

    private func layoutScene() {
        engine.configureArena(
            size: arenaSizeVector,
            actorRadius: Double(ActorNode.visualRadius)
        )
        arenaLayer.removeAllChildren()
        drawArena(in: arenaFrame)

        hudNode.layout(width: size.width, top: size.height)
        fightLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        introLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        let countdownPosition = CGPoint(x: arenaFrame.midX, y: arenaFrame.minY + arenaFrame.height * 0.52)
        countdownHalo.position = countdownPosition
        countdownLabel.position = countdownPosition

        resultShade.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.57)
        resultAccent.position = CGPoint(x: size.width / 2, y: size.height * 0.535)
        resultDetailLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.49)
        inputStatusLabel.position = CGPoint(x: size.width / 2, y: 23)

        positionActors()
    }

    private func drawArena(in frame: CGRect) {
        let floor = SKShapeNode(rect: frame, cornerRadius: 4)
        floor.fillColor = SKColor(red: 11 / 255, green: 15 / 255, blue: 20 / 255, alpha: 1)
        floor.strokeColor = SKColor(white: 1, alpha: 0.13)
        floor.lineWidth = 1
        floor.zPosition = -20
        arenaLayer.addChild(floor)

        if engine.stage == .bowl {
            drawBowlContours(in: frame)
        } else {
            drawGrid(in: frame)
        }
        if engine.stage == .pillar {
            drawPillar(in: frame)
        }

        let stageLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        stageLabel.text = "STAGE \(series.matchIndex + 1) — \(engine.stage.rawValue)"
        stageLabel.fontSize = 11
        stageLabel.fontColor = SKColor(white: 0.48, alpha: 1)
        stageLabel.horizontalAlignmentMode = .left
        stageLabel.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 22)
        stageLabel.zPosition = -18
        arenaLayer.addChild(stageLabel)
    }

    private func drawGrid(in frame: CGRect) {
        let gridSpacing = max(38, frame.width / 9)
        var x = frame.minX + gridSpacing
        while x < frame.maxX {
            addArenaLine(from: CGPoint(x: x, y: frame.minY), to: CGPoint(x: x, y: frame.maxY))
            x += gridSpacing
        }
        var y = frame.minY + gridSpacing
        while y < frame.maxY {
            addArenaLine(from: CGPoint(x: frame.minX, y: y), to: CGPoint(x: frame.maxX, y: y))
            y += gridSpacing
        }
    }

    private func addArenaLine(from start: CGPoint, to end: CGPoint) {
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        line.path = path
        line.strokeColor = SKColor(white: 1, alpha: 0.045)
        line.lineWidth = 1
        line.zPosition = -19
        arenaLayer.addChild(line)
    }

    private func drawBowlContours(in frame: CGRect) {
        let glow = SKShapeNode(ellipseIn: CGRect(
            x: frame.midX - frame.width * 0.23,
            y: frame.midY - frame.height * 0.18,
            width: frame.width * 0.46,
            height: frame.height * 0.36
        ))
        glow.fillColor = SKColor(red: 0.02, green: 0.04, blue: 0.08, alpha: 0.62)
        glow.strokeColor = .clear
        glow.zPosition = -19
        arenaLayer.addChild(glow)

        for index in 1...6 {
            let fraction = CGFloat(index) / 6
            let contour = SKShapeNode(ellipseIn: CGRect(
                x: frame.midX - frame.width * 0.48 * fraction,
                y: frame.midY - frame.height * 0.45 * fraction,
                width: frame.width * 0.96 * fraction,
                height: frame.height * 0.90 * fraction
            ))
            contour.fillColor = .clear
            contour.strokeColor = SKColor(red: 0.47, green: 0.70, blue: 1, alpha: 0.08)
            contour.lineWidth = 1
            contour.zPosition = -18
            arenaLayer.addChild(contour)
        }
    }

    private func drawPillar(in frame: CGRect) {
        let radius = ActorNode.visualRadius * CGFloat(GameConfig.Stage.pillarRadiusActorRadii)
        let shadow = SKShapeNode(ellipseOf: CGSize(width: radius * 2.1, height: radius * 1.4))
        shadow.position = CGPoint(x: frame.midX, y: frame.midY - radius * 0.25)
        shadow.fillColor = SKColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.zPosition = -8
        arenaLayer.addChild(shadow)

        let pillar = SKShapeNode(circleOfRadius: radius)
        pillar.position = CGPoint(x: frame.midX, y: frame.midY)
        pillar.fillColor = SKColor(red: 0.17, green: 0.21, blue: 0.24, alpha: 1)
        pillar.strokeColor = SKColor(white: 1, alpha: 0.16)
        pillar.lineWidth = 2
        pillar.zPosition = 6
        arenaLayer.addChild(pillar)
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

    private func normalizedPosition(for point: CGPoint) -> Vector2 {
        guard arenaFrame.width > 0, arenaFrame.height > 0 else { return .zero }
        return Vector2(
            x: Double((point.x - arenaFrame.minX) / arenaFrame.width),
            y: Double((point.y - arenaFrame.minY) / arenaFrame.height)
        )
    }

    private func updatePlayerMovement(deltaTime: TimeInterval) {
#if DEBUG
        guard !isDebugDragging else { return }
#endif
        engine.movePlayer(
            input: motionInputController.input,
            deltaTime: deltaTime,
            bounds: movementBounds
        )
    }

    private func updateCPUMovement(deltaTime: TimeInterval) {
        let input = CPUController.input(
            cpu: engine.cpu,
            player: engine.player,
            arenaSize: arenaSizeVector,
            actorRadius: Double(ActorNode.visualRadius),
            rating: progress.rating,
            jitterSample: Vector2(
                x: Double.random(in: -1...1),
                y: Double.random(in: -1...1)
            )
        )
        engine.moveCPU(input: input, deltaTime: deltaTime, bounds: movementBounds)
    }

    private func attemptCPUShockIfNeeded() {
        guard engine.phase == .playing,
              CPUController.shouldUseShock(
                cpu: engine.cpu,
                player: engine.player,
                rating: progress.rating,
                arenaSize: arenaSizeVector,
                actorRadius: Double(ActorNode.visualRadius)
              ) else { return }

        let outcome = engine.useShock(by: .cpu, targetIsInRange: true)
        dispatchFeedback(feedbackRouter.shock(by: .cpu, outcome: outcome, phase: engine.phase))
        effectsLayer.emitStatus(
            outcome == .transferred ? "CPU SHOCK TAG!" : "CPU SHOCK",
            at: CGPoint(x: arenaFrame.midX, y: arenaFrame.minY + 34),
            color: outcome == .transferred ? .tag10Gold : .tag10Orange
        )
    }

    private func attemptDirectTagIfNeeded() {
        guard CollisionRules.isDirectTagInRange(
            playerPosition: engine.player.position,
            cpuPosition: engine.cpu.position,
            arenaSize: arenaSizeVector,
            actorRadius: Double(ActorNode.visualRadius)
        ) else { return }

        let pusher: ActorID = engine.player.isIt ? .player : .cpu
        let didTransfer = engine.attemptDirectTag(from: pusher)
        dispatchFeedback(
            feedbackRouter.directTag(
                from: pusher,
                didTransfer: didTransfer,
                phase: engine.phase
            )
        )
    }

    private func attemptPlayerShock() {
        guard engine.phase == .playing else { return }

        let targetIsInRange = CollisionRules.isShockTargetInRange(
            ownerPosition: engine.player.position,
            targetPosition: engine.cpu.position,
            arenaSize: arenaSizeVector,
            actorRadius: Double(ActorNode.visualRadius)
        )
        let outcome = engine.useShock(by: .player, targetIsInRange: targetIsInRange)
        dispatchFeedback(feedbackRouter.shock(by: .player, outcome: outcome, phase: engine.phase))

        switch outcome {
        case .unavailable:
            effectsLayer.emitStatus(
                "SHOCK NOT READY",
                at: CGPoint(x: arenaFrame.midX, y: arenaFrame.minY + 34),
                color: SKColor(white: 0.72, alpha: 1)
            )
        case .missed:
            effectsLayer.emitStatus(
                "SHOCK MISS",
                at: CGPoint(x: arenaFrame.midX, y: arenaFrame.minY + 34),
                color: .tag10Cyan
            )
        case .transferred:
            effectsLayer.emitStatus(
                "SHOCK TAG!",
                at: CGPoint(x: arenaFrame.midX, y: arenaFrame.minY + 34),
                color: .tag10Gold
            )
        }
    }

    private func renderInputStatus() {
        switch motionInputController.status {
        case .idle:
            inputStatusLabel.text = "STARTING MOTION…"
        case .calibrating:
            inputStatusLabel.text = "HOLD STEADY • CALIBRATING"
            inputStatusLabel.fontColor = .tag10Gold
        case .active:
            inputStatusLabel.text = "TILT READY • TAP TO SHOCK"
            inputStatusLabel.fontColor = .tag10Mint
        case .unavailable, .failed:
#if DEBUG
            inputStatusLabel.text = "DEBUG • DRAG TO MOVE • TAP TO SHOCK"
#else
            inputStatusLabel.text = "TILT UNAVAILABLE • TAP TO SHOCK"
#endif
            inputStatusLabel.fontColor = SKColor(white: 0.58, alpha: 1)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
#if DEBUG
        debugTouchStart = touches.first?.location(in: self)
        isDebugDragging = false
#endif
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
#if DEBUG
        guard engine.phase == .playing,
              let point = touches.first?.location(in: self),
              let start = debugTouchStart else { return }

        if distance(from: start, to: point) >= CGFloat(GameConfig.Input.debugDragActivationDistance) {
            isDebugDragging = true
        }
        guard isDebugDragging else { return }
        engine.placePlayer(at: normalizedPosition(for: point), bounds: movementBounds)
#endif
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
#if DEBUG
        defer {
            debugTouchStart = nil
            isDebugDragging = false
        }
        if isDebugDragging {
            if let point = touches.first?.location(in: self) {
                engine.placePlayer(at: normalizedPosition(for: point), bounds: movementBounds)
            }
            return
        }
#endif
        if case .finished = engine.phase {
            startNextMatch()
            return
        }
        attemptPlayerShock()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
#if DEBUG
        debugTouchStart = nil
        isDebugDragging = false
#endif
    }

    private func presentFightTransition() {
        guard !didPresentFight else { return }
        didPresentFight = true
        fightLabel.removeAllActions()
        introLabel.removeAllActions()
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
        effectsLayer.flashArena(
            in: arenaFrame,
            color: .tag10Gold,
            peakAlpha: 0.14,
            duration: 0.20
        )
        effectsLayer.emitBurst(
            at: CGPoint(x: size.width / 2, y: size.height * 0.54),
            color: .tag10Gold,
            count: 12
        )
    }

    private func presentIntroEntrance() {
        fightLabel.isHidden = false
        introLabel.isHidden = false
        fightLabel.alpha = 0
        fightLabel.setScale(0.62)
        fightLabel.run(
            .sequence([
                .group([
                    .fadeIn(withDuration: 0.13),
                    .scale(to: 1.08, duration: 0.17),
                ]),
                .scale(to: 1, duration: 0.07),
            ])
        )
        introLabel.run(
            .sequence([
                .wait(forDuration: 0.08),
                .fadeIn(withDuration: 0.15),
            ])
        )
    }

    private func presentResultIfNeeded() {
        guard !didPresentResult, case let .finished(result) = engine.phase else { return }
        didPresentResult = true
        if !didRecordResult {
            progress.record(result)
            didRecordResult = true
        }

        resultShade.isHidden = false
        resultAccent.isHidden = false
        resultLabel.isHidden = false
        resultDetailLabel.isHidden = false
        resultLabel.text = result == .win ? "WIN" : "LOSE"
        resultLabel.fontColor = result == .win ? .tag10Mint : .tag10Red
        resultDetailLabel.text = engine.player.isIt ? "YOU HELD THE BOMB AT 0" : "CPU HELD THE BOMB AT 0"

        countdownHalo.isHidden = true
        countdownLabel.isHidden = true
        resultShade.alpha = 0
        resultShade.run(.fadeAlpha(to: 1, duration: 0.16))

        let loserPosition = engine.player.isIt ? playerNode.position : cpuNode.position
        effectsLayer.emitBurst(
            at: loserPosition,
            color: result == .win ? .tag10Gold : .tag10Red,
            count: 24
        )

        resultAccent.alpha = 0
        resultAccent.xScale = 0.2
        resultAccent.run(
            .group([
                .fadeIn(withDuration: 0.18),
                .scaleX(to: 1, duration: 0.22),
            ])
        )

        resultLabel.alpha = 0
        resultLabel.setScale(0.64)
        resultLabel.run(
            .sequence([
                .group([
                    .fadeIn(withDuration: 0.12),
                    .scale(to: 1.08, duration: 0.18),
                ]),
                .scale(to: 1, duration: 0.08),
            ])
        )

        let detailPosition = resultDetailLabel.position
        resultDetailLabel.position.y -= 10
        resultDetailLabel.alpha = 0
        resultDetailLabel.run(
            .sequence([
                .wait(forDuration: 0.10),
                .group([
                    .fadeIn(withDuration: 0.18),
                    .move(to: detailPosition, duration: 0.18),
                ]),
            ])
        )

        effectsLayer.emitBurst(
            at: CGPoint(x: size.width / 2, y: size.height * 0.57),
            color: result == .win ? .tag10Mint : .tag10Red,
            count: 28
        )
    }

    private func startNextMatch() {
        series.advance()
        engine = GameEngine.randomMatch(
            playerPosition: Vector2(x: 0.30, y: 0.28),
            cpuPosition: Vector2(x: 0.70, y: 0.75),
            stage: series.currentStage
        )
        engine.configureArena(size: arenaSizeVector, actorRadius: Double(ActorNode.visualRadius))
        introElapsed = 0
        didPresentFight = false
        didPresentResult = false
        didRecordResult = false
        previousCountdownNumber = nil
        effectsLayer.removeAllChildren()
        [fightLabel, introLabel, resultShade, resultAccent, resultLabel, resultDetailLabel].forEach {
            $0.removeAllActions()
        }
        resultShade.isHidden = true
        resultAccent.isHidden = true
        resultLabel.isHidden = true
        resultDetailLabel.isHidden = true
        countdownHalo.isHidden = true
        countdownLabel.isHidden = true
        layoutScene()
        renderEngineState()
        previousVisualSnapshot = VisualSnapshot(engine: engine)
        presentIntroEntrance()
        dispatchFeedback(feedbackRouter.startMatch())
    }

    private func dispatchFeedback(_ events: [FeedbackEvent]) {
        feedbackController.handle(events)
    }

    private func presentVisualStateChanges() {
        let current = VisualSnapshot(engine: engine)
        defer { previousVisualSnapshot = current }
        guard let previous = previousVisualSnapshot else { return }

        if engine.phase == .playing {
            emitMotionTrails(previous: previous, current: current)
        }

        if didFireShock(previous: previous, current: current, actor: .player) {
            effectsLayer.emitShockWave(
                at: point(for: previous.playerPosition),
                color: .tag10Cyan,
                arenaFrame: arenaFrame
            )
        }
        if didFireShock(previous: previous, current: current, actor: .cpu) {
            effectsLayer.emitShockWave(
                at: point(for: previous.cpuPosition),
                color: .tag10Orange,
                arenaFrame: arenaFrame
            )
        }

        guard previous.playerIsIt != current.playerIsIt else { return }
        let source = previous.playerIsIt ? previous.playerPosition : previous.cpuPosition
        let destination = current.playerIsIt ? current.playerPosition : current.cpuPosition
        effectsLayer.emitTagTransfer(
            from: point(for: source),
            to: point(for: destination),
            arenaFrame: arenaFrame
        )
    }

    private func didFireShock(
        previous: VisualSnapshot,
        current: VisualSnapshot,
        actor: ActorID
    ) -> Bool {
        switch actor {
        case .player:
            return previous.playerIsIt
                && previous.playerShockCooldown == 0
                && current.playerShockCooldown > 0
        case .cpu:
            return previous.cpuIsIt
                && previous.cpuShockCooldown == 0
                && current.cpuShockCooldown > 0
        }
    }

    private func emitMotionTrails(previous: VisualSnapshot, current: VisualSnapshot) {
        let previousPlayerPoint = point(for: previous.playerPosition)
        let currentPlayerPoint = point(for: current.playerPosition)
        if distance(from: previousPlayerPoint, to: currentPlayerPoint) >= VisualConfig.trailMovementThreshold,
           visualTime - lastPlayerTrailTime >= VisualConfig.trailEmissionInterval {
            effectsLayer.emitAfterimage(at: previousPlayerPoint, color: .tag10Cyan)
            lastPlayerTrailTime = visualTime
        }

        let previousCPUPoint = point(for: previous.cpuPosition)
        let currentCPUPoint = point(for: current.cpuPosition)
        if distance(from: previousCPUPoint, to: currentCPUPoint) >= VisualConfig.trailMovementThreshold,
           visualTime - lastCPUtrailTime >= VisualConfig.trailEmissionInterval {
            effectsLayer.emitAfterimage(at: previousCPUPoint, color: .tag10Orange)
            lastCPUtrailTime = visualTime
        }
    }

    private func distance(from start: CGPoint, to end: CGPoint) -> CGFloat {
        hypot(end.x - start.x, end.y - start.y)
    }

    private func updateCountdownPresentation() {
        guard engine.phase == .playing,
              !engine.isTimerPaused,
              engine.remainingTime > 0,
              engine.remainingTime <= 3 else {
            countdownHalo.isHidden = true
            countdownLabel.isHidden = true
            previousCountdownNumber = nil
            return
        }

        let number = Int(ceil(engine.remainingTime))
        countdownHalo.isHidden = false
        countdownLabel.isHidden = false
        countdownLabel.text = String(number)

        guard number != previousCountdownNumber else { return }
        previousCountdownNumber = number

        countdownLabel.removeAllActions()
        countdownHalo.removeAllActions()
        countdownLabel.alpha = 1
        countdownLabel.setScale(0.62)
        countdownLabel.run(
            .sequence([
                .scale(to: 1.06, duration: 0.13),
                .scale(to: 1, duration: 0.07),
                .wait(forDuration: 0.48),
                .fadeAlpha(to: 0.34, duration: 0.20),
            ])
        )

        countdownHalo.alpha = 0.86
        countdownHalo.setScale(0.72)
        countdownHalo.run(
            .group([
                .scale(to: 1.16, duration: 0.32),
                .fadeAlpha(to: 0.18, duration: 0.32),
            ])
        )
        effectsLayer.emitCountdownBurst(at: countdownLabel.position, number: number)
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
