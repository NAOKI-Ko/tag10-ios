import Foundation

/// Rendering-independent state and transitions for one TAG10 match.
public struct GameEngine: Equatable, Sendable {
    public private(set) var phase: MatchPhase
    public private(set) var remainingTime: TimeInterval
    public private(set) var player: ActorState
    public private(set) var cpu: ActorState
    public private(set) var tagProtectionRemaining: TimeInterval
    public private(set) var tagCount: Int

    /// The arena-relative maximum movement speed is supplied by the renderer.
    /// Keeping it here lets knockback remain deterministic and testable.
    public var maximumMovementSpeed: Double

    public init(
        playerStartsAsIt: Bool,
        playerPosition: Vector2 = .zero,
        cpuPosition: Vector2 = .zero,
        maximumMovementSpeed: Double = 1.0
    ) {
        phase = .intro
        remainingTime = GameConfig.matchDuration
        player = ActorState(
            position: playerPosition,
            isIt: playerStartsAsIt,
            shockCooldownRemaining: playerStartsAsIt ? GameConfig.shockArmDuration : 0
        )
        cpu = ActorState(
            position: cpuPosition,
            isIt: !playerStartsAsIt,
            shockCooldownRemaining: playerStartsAsIt ? 0 : GameConfig.shockArmDuration
        )
        tagProtectionRemaining = GameConfig.initialTagProtectionDuration
        tagCount = 0
        self.maximumMovementSpeed = maximumMovementSpeed
    }

    public static func randomMatch(
        playerPosition: Vector2 = .zero,
        cpuPosition: Vector2 = .zero,
        maximumMovementSpeed: Double = 1.0
    ) -> GameEngine {
        GameEngine(
            playerStartsAsIt: Bool.random(),
            playerPosition: playerPosition,
            cpuPosition: cpuPosition,
            maximumMovementSpeed: maximumMovementSpeed
        )
    }

    public var isTimerPaused: Bool {
        player.isStunned || cpu.isStunned
    }

    public var heatMultiplier: Double {
        GameConfig.heatMultiplier(tagCount: tagCount)
    }

    public mutating func beginPlay() {
        guard phase == .intro else { return }
        phase = .playing
    }

    /// Advances gameplay clocks. Match time is paused only for the portion of
    /// the update during which at least one actor is stunned. Shock cooldowns
    /// and protection windows continue to elapse, matching the HTML prototype.
    public mutating func advance(by deltaTime: TimeInterval) {
        guard deltaTime > 0, phase == .playing else { return }

        let pausedDuration = min(deltaTime, max(player.stunRemaining, cpu.stunRemaining))

        player.stunRemaining = decremented(player.stunRemaining, by: deltaTime)
        cpu.stunRemaining = decremented(cpu.stunRemaining, by: deltaTime)
        player.shockCooldownRemaining = decremented(player.shockCooldownRemaining, by: deltaTime)
        cpu.shockCooldownRemaining = decremented(cpu.shockCooldownRemaining, by: deltaTime)
        tagProtectionRemaining = decremented(tagProtectionRemaining, by: deltaTime)

        let runningDuration = deltaTime - pausedDuration
        remainingTime = decremented(remainingTime, by: runningDuration)

        if remainingTime == 0 {
            phase = .finished(player.isIt ? .loss : .win)
        }
    }

    @discardableResult
    public mutating func attemptDirectTag(from pusher: ActorID) -> Bool {
        guard phase == .playing,
              tagProtectionRemaining == 0,
              !player.isStunned,
              !cpu.isStunned,
              actor(pusher).isIt,
              !actor(pusher.opponent).isIt else {
            return false
        }

        transfer(from: pusher, kind: .direct)
        return true
    }

    public func canUseShock(_ actorID: ActorID) -> Bool {
        phase == .playing
            && actor(actorID).isIt
            && !actor(actorID).isStunned
            && actor(actorID).shockCooldownRemaining == 0
    }

    /// A valid use always starts cooldown, even when it misses. Transfer also
    /// requires range, an unstunned receiver, and expired tag protection.
    @discardableResult
    public mutating func useShock(by owner: ActorID, targetIsInRange: Bool) -> ShockOutcome {
        guard canUseShock(owner) else { return .unavailable }

        setShockCooldown(GameConfig.shockCooldownDuration, for: owner)
        let receiver = owner.opponent

        guard targetIsInRange,
              !actor(receiver).isStunned,
              tagProtectionRemaining == 0 else {
            return .missed
        }

        transfer(from: owner, kind: .shock)
        return .transferred
    }

    public func actor(_ actorID: ActorID) -> ActorState {
        actorID == .player ? player : cpu
    }

    private mutating func transfer(from pusherID: ActorID, kind: TransferKind) {
        let receiverID = pusherID.opponent
        var pusher = actor(pusherID)
        var receiver = actor(receiverID)

        pusher.isIt = false
        receiver.isIt = true
        receiver.stunRemaining = GameConfig.stunDuration
        receiver.velocity = .zero
        receiver.shockCooldownRemaining = GameConfig.shockArmDuration

        let direction = (pusher.position - receiver.position).normalized
        let multiplier = kind == .direct
            ? GameConfig.directTagKnockbackMultiplier
            : GameConfig.shockTagKnockbackMultiplier
        pusher.velocity = direction * (maximumMovementSpeed * multiplier)

        setActor(pusher, for: pusherID)
        setActor(receiver, for: receiverID)
        tagProtectionRemaining = GameConfig.postSwapTagProtectionDuration
        tagCount += 1
    }

    private func decremented(_ value: TimeInterval, by deltaTime: TimeInterval) -> TimeInterval {
        max(0, value - deltaTime)
    }

    private mutating func setShockCooldown(_ value: TimeInterval, for actorID: ActorID) {
        var updatedActor = actor(actorID)
        updatedActor.shockCooldownRemaining = value
        setActor(updatedActor, for: actorID)
    }

    private mutating func setActor(_ actor: ActorState, for actorID: ActorID) {
        switch actorID {
        case .player:
            player = actor
        case .cpu:
            cpu = actor
        }
    }
}
