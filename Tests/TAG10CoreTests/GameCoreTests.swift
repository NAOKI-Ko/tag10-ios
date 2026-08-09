import XCTest
@testable import TAG10Core

final class GameCoreTests: XCTestCase {
    func testMatchStartsWithTenSecondsRemaining() {
        let game = GameEngine(playerStartsAsIt: true)

        XCTAssertEqual(game.remainingTime, 10.0, accuracy: 0.000_001)
        XCTAssertEqual(game.phase, .intro)
    }

    func testTimerDoesNotDecreaseWhileEitherActorIsStunned() {
        var game = readyForTag(playerStartsAsIt: true)
        XCTAssertTrue(game.attemptDirectTag(from: .player))
        let timeAtTag = game.remainingTime

        game.advance(by: 0.5)

        XCTAssertEqual(game.remainingTime, timeAtTag, accuracy: 0.000_001)
    }

    func testDirectContactSwapsItState() {
        var game = readyForTag(playerStartsAsIt: true)

        XCTAssertTrue(game.attemptDirectTag(from: .player))
        XCTAssertFalse(game.player.isIt)
        XCTAssertTrue(game.cpu.isIt)
    }

    func testNewItIsStunnedForOneSecond() {
        var game = readyForTag(playerStartsAsIt: true)

        XCTAssertTrue(game.attemptDirectTag(from: .player))
        XCTAssertEqual(game.cpu.stunRemaining, 1.0, accuracy: 0.000_001)
        XCTAssertEqual(game.cpu.velocity, .zero)
    }

    func testShockIsUnavailableForTwoSecondsAfterBecomingIt() {
        var game = readyForTag(playerStartsAsIt: true)
        XCTAssertTrue(game.attemptDirectTag(from: .player))

        XCTAssertEqual(game.cpu.shockCooldownRemaining, 2.0, accuracy: 0.000_001)
        XCTAssertFalse(game.canUseShock(.cpu))

        game.advance(by: 1.999)
        XCTAssertFalse(game.canUseShock(.cpu))

        game.advance(by: 0.001)
        XCTAssertTrue(game.canUseShock(.cpu))
    }

    func testShockHasThreeSecondCooldownAfterUse() {
        var game = GameEngine(playerStartsAsIt: true)
        game.beginPlay()
        game.advance(by: GameConfig.shockArmDuration)

        XCTAssertEqual(game.useShock(by: .player, targetIsInRange: false), .missed)
        XCTAssertEqual(game.player.shockCooldownRemaining, 3.0, accuracy: 0.000_001)
        XCTAssertFalse(game.canUseShock(.player))

        game.advance(by: 3.0)
        XCTAssertTrue(game.canUseShock(.player))
    }

    func testInRangeShockTransfersItState() {
        var game = GameEngine(playerStartsAsIt: true)
        game.beginPlay()
        game.advance(by: GameConfig.shockArmDuration)

        XCTAssertEqual(game.useShock(by: .player, targetIsInRange: true), .transferred)
        XCTAssertFalse(game.player.isIt)
        XCTAssertTrue(game.cpu.isIt)
        XCTAssertEqual(game.cpu.stunRemaining, GameConfig.stunDuration, accuracy: 0.000_001)
        XCTAssertEqual(game.tagCount, 1)
    }

    func testActorWhoIsItAtZeroLoses() {
        var playerIsIt = GameEngine(playerStartsAsIt: true)
        playerIsIt.beginPlay()
        playerIsIt.advance(by: GameConfig.matchDuration)
        XCTAssertEqual(playerIsIt.phase, .finished(.loss))

        var cpuIsIt = GameEngine(playerStartsAsIt: false)
        cpuIsIt.beginPlay()
        cpuIsIt.advance(by: GameConfig.matchDuration)
        XCTAssertEqual(cpuIsIt.phase, .finished(.win))
    }

    func testRatingNeverDropsBelowZero() {
        var progress = PlayerProgress(rating: 5)

        let change = progress.record(.loss)

        XCTAssertEqual(progress.rating, 0)
        XCTAssertEqual(change.delta, -5)
    }

    func testHeatMultiplierCapsAtTwentyFourPercent() {
        XCTAssertEqual(GameConfig.heatMultiplier(tagCount: 1), 1.03, accuracy: 0.000_001)
        XCTAssertEqual(GameConfig.heatMultiplier(tagCount: 8), 1.24, accuracy: 0.000_001)
        XCTAssertEqual(GameConfig.heatMultiplier(tagCount: 100), 1.24, accuracy: 0.000_001)
    }

    func testWinIncrementsStreakAndLossResetsIt() {
        var progress = PlayerProgress()

        progress.record(.win)
        progress.record(.win)
        XCTAssertEqual(progress.rating, 1_044)
        XCTAssertEqual(progress.streak, 2)

        progress.record(.loss)
        XCTAssertEqual(progress.rating, 1_028)
        XCTAssertEqual(progress.streak, 0)
    }

    func testHeatResetsForANewMatch() {
        var game = readyForTag(playerStartsAsIt: true)
        XCTAssertTrue(game.attemptDirectTag(from: .player))
        XCTAssertEqual(game.tagCount, 1)

        let nextGame = GameEngine(playerStartsAsIt: false)
        XCTAssertEqual(nextGame.tagCount, 0)
        XCTAssertEqual(nextGame.heatMultiplier, 1.0, accuracy: 0.000_001)
    }

    func testInitialItIsAlwaysUnique() {
        for _ in 0..<100 {
            let game = GameEngine.randomMatch()
            XCTAssertNotEqual(game.player.isIt, game.cpu.isIt)
        }
    }

    func testTiltMappingAppliesDeadZone() {
        var mapper = TiltInputMapper(deadZoneRadians: 0.05, fullScaleRadians: 0.5)
        mapper.calibrate(using: MotionAttitude(roll: 0, pitch: 0))

        let input = mapper.input(for: MotionAttitude(roll: 0.03, pitch: -0.02))

        XCTAssertEqual(input, .zero)
    }

    func testTiltMappingClampsExcessInput() {
        var mapper = TiltInputMapper(deadZoneRadians: 0.05, fullScaleRadians: 0.5)
        mapper.calibrate(using: MotionAttitude(roll: 0, pitch: 0))

        let input = mapper.input(for: MotionAttitude(roll: 2, pitch: -2))

        XCTAssertEqual(hypot(input.x, input.y), 1, accuracy: 0.000_001)
    }

    func testTiltMappingUsesStoredNeutralOffset() {
        var mapper = TiltInputMapper(deadZoneRadians: 0.01, fullScaleRadians: 0.5)
        let neutral = MotionAttitude(roll: 0.4, pitch: -0.2)
        mapper.calibrate(using: neutral)

        XCTAssertEqual(mapper.neutralAttitude, neutral)
        XCTAssertEqual(mapper.input(for: neutral), .zero)

        let input = mapper.input(for: MotionAttitude(roll: 0.5, pitch: -0.3))
        XCTAssertGreaterThan(input.x, 0)
        XCTAssertGreaterThan(input.y, 0)
    }

    func testInputProducesMovementVector() {
        let actor = ActorState(position: Vector2(x: 0.5, y: 0.5))

        let moved = PlayerMovement.integrate(
            actor: actor,
            input: Vector2(x: 1, y: 0),
            deltaTime: 0.25,
            bounds: .normalized,
            arenaSize: Vector2(x: 1, y: 1),
            maximumSpeed: GameConfig.Input.maximumSpeedPerArenaWidth
        )

        XCTAssertGreaterThan(moved.position.x, actor.position.x)
        XCTAssertEqual(moved.position.y, actor.position.y, accuracy: 0.000_001)
        XCTAssertGreaterThan(moved.velocity.x, 0)
        XCTAssertEqual(moved.velocity.y, 0, accuracy: 0.000_001)
    }

    func testMovementClampsToArenaBounds() {
        let bounds = MovementBounds(
            minimumX: 0.1,
            maximumX: 0.9,
            minimumY: 0.2,
            maximumY: 0.8
        )
        let actor = ActorState(
            position: Vector2(x: 0.89, y: 0.79),
            velocity: Vector2(x: 1, y: 1)
        )

        let moved = PlayerMovement.integrate(
            actor: actor,
            input: Vector2(x: 1, y: 1),
            deltaTime: 1,
            bounds: bounds,
            arenaSize: Vector2(x: 1, y: 1),
            maximumSpeed: 1
        )

        XCTAssertEqual(moved.position, Vector2(x: 0.9, y: 0.8))
        XCTAssertEqual(moved.velocity, .zero)
    }

    func testMovementIsDeltaTimeIndependent() {
        let actor = ActorState(position: Vector2(x: 0.25, y: 0.25))
        let input = Vector2(x: 0.1, y: -0.05)
        let oneStep = PlayerMovement.integrate(
            actor: actor,
            input: input,
            deltaTime: 0.5,
            bounds: .normalized,
            arenaSize: Vector2(x: 1, y: 1),
            maximumSpeed: 1
        )

        var manySteps = actor
        for _ in 0..<30 {
            manySteps = PlayerMovement.integrate(
                actor: manySteps,
                input: input,
                deltaTime: 1.0 / 60.0,
                bounds: .normalized,
                arenaSize: Vector2(x: 1, y: 1),
                maximumSpeed: 1
            )
        }

        XCTAssertEqual(oneStep.position.x, manySteps.position.x, accuracy: 0.000_001)
        XCTAssertEqual(oneStep.position.y, manySteps.position.y, accuracy: 0.000_001)
        XCTAssertEqual(oneStep.velocity.x, manySteps.velocity.x, accuracy: 0.000_001)
        XCTAssertEqual(oneStep.velocity.y, manySteps.velocity.y, accuracy: 0.000_001)
    }

    func testRectangularArenaMovementIsIsotropicInPointSpace() {
        let arenaSize = Vector2(x: 400, y: 800)
        let actor = ActorState(position: Vector2(x: 0.5, y: 0.5))
        let horizontal = PlayerMovement.integrate(
            actor: actor,
            input: Vector2(x: 1, y: 0),
            deltaTime: 0.25,
            bounds: .normalized,
            arenaSize: arenaSize,
            maximumSpeed: 100
        )
        let vertical = PlayerMovement.integrate(
            actor: actor,
            input: Vector2(x: 0, y: 1),
            deltaTime: 0.25,
            bounds: .normalized,
            arenaSize: arenaSize,
            maximumSpeed: 100
        )

        let horizontalDistance = (horizontal.position.x - actor.position.x) * arenaSize.x
        let verticalDistance = (vertical.position.y - actor.position.y) * arenaSize.y
        XCTAssertEqual(horizontalDistance, verticalDistance, accuracy: 0.000_001)
        XCTAssertNotEqual(
            horizontal.position.x - actor.position.x,
            vertical.position.y - actor.position.y,
            accuracy: 0.000_001
        )
    }

    func testDiagonalMovementRespectsPointSpaceSpeedCap() {
        let arenaSize = Vector2(x: 400, y: 800)
        let initialPointVelocity = Vector2(x: 300, y: 300)
        let actor = ActorState(
            position: Vector2(x: 0.5, y: 0.5),
            velocity: ArenaGeometry.normalizedVector(
                fromPoints: initialPointVelocity,
                arenaSize: arenaSize
            )
        )

        let moved = PlayerMovement.integrate(
            actor: actor,
            input: Vector2(x: 1, y: 1),
            deltaTime: 1.0 / 60.0,
            bounds: .normalized,
            arenaSize: arenaSize,
            maximumSpeed: 100
        )
        let pointVelocity = ArenaGeometry.pointVector(
            fromNormalized: moved.velocity,
            arenaSize: arenaSize
        )

        XCTAssertEqual(pointVelocity.magnitude, 100, accuracy: 0.000_001)
    }

    func testRectangularArenaMovementIsDeltaTimeIndependent() {
        let arenaSize = Vector2(x: 400, y: 800)
        let actor = ActorState(position: Vector2(x: 0.25, y: 0.25))
        let input = Vector2(x: 0.1, y: -0.05)
        let oneStep = PlayerMovement.integrate(
            actor: actor,
            input: input,
            deltaTime: 0.5,
            bounds: .normalized,
            arenaSize: arenaSize,
            maximumSpeed: 100
        )

        var manySteps = actor
        for _ in 0..<30 {
            manySteps = PlayerMovement.integrate(
                actor: manySteps,
                input: input,
                deltaTime: 1.0 / 60.0,
                bounds: .normalized,
                arenaSize: arenaSize,
                maximumSpeed: 100
            )
        }

        let oneStepPointPosition = ArenaGeometry.pointVector(
            fromNormalized: oneStep.position,
            arenaSize: arenaSize
        )
        let manyStepPointPosition = ArenaGeometry.pointVector(
            fromNormalized: manySteps.position,
            arenaSize: arenaSize
        )
        let oneStepPointVelocity = ArenaGeometry.pointVector(
            fromNormalized: oneStep.velocity,
            arenaSize: arenaSize
        )
        let manyStepPointVelocity = ArenaGeometry.pointVector(
            fromNormalized: manySteps.velocity,
            arenaSize: arenaSize
        )

        XCTAssertEqual(oneStepPointPosition.x, manyStepPointPosition.x, accuracy: 0.000_001)
        XCTAssertEqual(oneStepPointPosition.y, manyStepPointPosition.y, accuracy: 0.000_001)
        XCTAssertEqual(oneStepPointVelocity.x, manyStepPointVelocity.x, accuracy: 0.000_001)
        XCTAssertEqual(oneStepPointVelocity.y, manyStepPointVelocity.y, accuracy: 0.000_001)
    }

    func testDirectTagKnockbackUsesPointSpaceDirectionAndMagnitude() {
        let arenaSize = Vector2(x: 400, y: 800)
        var game = GameEngine(
            playerStartsAsIt: true,
            playerPosition: Vector2(x: 0.75, y: 0.75),
            cpuPosition: Vector2(x: 0.25, y: 0.25),
            arenaSize: arenaSize,
            maximumMovementSpeed: 100
        )
        game.beginPlay()
        game.advance(by: GameConfig.initialTagProtectionDuration)

        XCTAssertTrue(game.attemptDirectTag(from: .player))

        assertPointSpaceKnockback(
            game.player.velocity,
            arenaSize: arenaSize,
            expectedDirection: Vector2(x: 200, y: 400).normalized,
            expectedMagnitude: 100 * GameConfig.directTagKnockbackMultiplier
        )
    }

    func testShockKnockbackUsesPointSpaceDirectionAndMagnitude() {
        let arenaSize = Vector2(x: 400, y: 800)
        var game = GameEngine(
            playerStartsAsIt: true,
            playerPosition: Vector2(x: 0.75, y: 0.75),
            cpuPosition: Vector2(x: 0.25, y: 0.25),
            arenaSize: arenaSize,
            maximumMovementSpeed: 100
        )
        game.beginPlay()
        game.advance(by: GameConfig.shockArmDuration)

        XCTAssertEqual(game.useShock(by: .player, targetIsInRange: true), .transferred)

        assertPointSpaceKnockback(
            game.player.velocity,
            arenaSize: arenaSize,
            expectedDirection: Vector2(x: 200, y: 400).normalized,
            expectedMagnitude: 100 * GameConfig.shockTagKnockbackMultiplier
        )
    }

    func testShockRangeUsesArenaGeometry() {
        let owner = Vector2(x: 0.5, y: 0.5)
        let arenaSize = Vector2(x: 100, y: 200)

        XCTAssertTrue(CollisionRules.isShockTargetInRange(
            ownerPosition: owner,
            targetPosition: Vector2(x: 0.89, y: 0.5),
            arenaSize: arenaSize,
            actorRadius: 10
        ))
        XCTAssertFalse(CollisionRules.isShockTargetInRange(
            ownerPosition: owner,
            targetPosition: Vector2(x: 0.91, y: 0.5),
            arenaSize: arenaSize,
            actorRadius: 10
        ))
    }

    func testUnavailableShockDoesNotCorruptState() {
        var game = GameEngine(playerStartsAsIt: true)
        game.beginPlay()
        let beforeAttempt = game

        XCTAssertEqual(game.useShock(by: .player, targetIsInRange: true), .unavailable)
        XCTAssertEqual(game, beforeAttempt)
    }

    func testMissedShockPreservesItAndStartsCooldown() {
        var game = GameEngine(playerStartsAsIt: true)
        game.beginPlay()
        game.advance(by: GameConfig.shockArmDuration)
        let playerPosition = game.player.position
        let cpuPosition = game.cpu.position

        XCTAssertEqual(game.useShock(by: .player, targetIsInRange: false), .missed)
        XCTAssertTrue(game.player.isIt)
        XCTAssertFalse(game.cpu.isIt)
        XCTAssertEqual(game.tagCount, 0)
        XCTAssertEqual(game.player.position, playerPosition)
        XCTAssertEqual(game.cpu.position, cpuPosition)
        XCTAssertEqual(
            game.player.shockCooldownRemaining,
            GameConfig.shockCooldownDuration,
            accuracy: 0.000_001
        )
    }

    private func readyForTag(playerStartsAsIt: Bool) -> GameEngine {
        var game = GameEngine(
            playerStartsAsIt: playerStartsAsIt,
            playerPosition: Vector2(x: 10, y: 0),
            cpuPosition: .zero,
            maximumMovementSpeed: 100
        )
        game.beginPlay()
        game.advance(by: GameConfig.initialTagProtectionDuration)
        return game
    }

    private func assertPointSpaceKnockback(
        _ normalizedVelocity: Vector2,
        arenaSize: Vector2,
        expectedDirection: Vector2,
        expectedMagnitude: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let pointVelocity = ArenaGeometry.pointVector(
            fromNormalized: normalizedVelocity,
            arenaSize: arenaSize
        )
        XCTAssertEqual(
            pointVelocity.magnitude,
            expectedMagnitude,
            accuracy: 0.000_001,
            file: file,
            line: line
        )
        XCTAssertEqual(
            pointVelocity.normalized.x,
            expectedDirection.x,
            accuracy: 0.000_001,
            file: file,
            line: line
        )
        XCTAssertEqual(
            pointVelocity.normalized.y,
            expectedDirection.y,
            accuracy: 0.000_001,
            file: file,
            line: line
        )
    }
}
