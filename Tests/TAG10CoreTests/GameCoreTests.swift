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
}
