import Foundation

public enum ActorID: CaseIterable, Equatable, Sendable {
    case player
    case cpu

    public var opponent: ActorID {
        self == .player ? .cpu : .player
    }
}

public struct Vector2: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    public static let zero = Vector2()

    public var magnitude: Double {
        hypot(x, y)
    }

    public var normalized: Vector2 {
        let length = magnitude
        guard length > 0 else { return .zero }
        return Vector2(x: x / length, y: y / length)
    }

    public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    public func dot(_ other: Vector2) -> Double {
        x * other.x + y * other.y
    }
}

public enum GameStage: String, CaseIterable, Equatable, Sendable {
    case flat = "FLAT"
    case bowl = "BOWL"
    case pillar = "PILLAR"

    public var next: GameStage {
        switch self {
        case .flat: return .bowl
        case .bowl: return .pillar
        case .pillar: return .flat
        }
    }

    public static func stage(forMatchIndex index: Int) -> GameStage {
        let stages = allCases
        return stages[max(0, index) % stages.count]
    }
}

public struct MatchSeriesState: Equatable, Sendable {
    public private(set) var matchIndex: Int

    public init(matchIndex: Int = 0) {
        self.matchIndex = max(0, matchIndex)
    }

    public var currentStage: GameStage {
        GameStage.stage(forMatchIndex: matchIndex)
    }

    public mutating func advance() {
        matchIndex += 1
    }
}

public struct ActorState: Equatable, Sendable {
    public var position: Vector2
    public var velocity: Vector2
    public var isIt: Bool
    public var stunRemaining: TimeInterval
    public var shockCooldownRemaining: TimeInterval

    public init(
        position: Vector2 = .zero,
        velocity: Vector2 = .zero,
        isIt: Bool = false,
        stunRemaining: TimeInterval = 0,
        shockCooldownRemaining: TimeInterval = 0
    ) {
        self.position = position
        self.velocity = velocity
        self.isIt = isIt
        self.stunRemaining = stunRemaining
        self.shockCooldownRemaining = shockCooldownRemaining
    }

    public var isStunned: Bool {
        stunRemaining > 0
    }
}

public enum MatchResult: Equatable, Sendable {
    case win
    case loss
}

public enum MatchPhase: Equatable, Sendable {
    case intro
    case playing
    case finished(MatchResult)
}

public enum TransferKind: Equatable, Sendable {
    case direct
    case shock
}

public enum ShockOutcome: Equatable, Sendable {
    case unavailable
    case missed
    case transferred
}

public enum Rank: String, Equatable, Sendable {
    case bronze = "BRONZE"
    case silver = "SILVER"
    case gold = "GOLD"
    case platinum = "PLATINUM"
    case diamond = "DIAMOND"
}

/// Rendering-independent presentation events. These values never mutate
/// gameplay state; platform feedback services consume them downstream.
public enum FeedbackEvent: Equatable, Sendable {
    case matchStart
    case countdown(Int)
    case directTag(pusher: ActorID, receiver: ActorID)
    case shockFire(owner: ActorID)
    case shockTransfer(owner: ActorID, receiver: ActorID)
    case result(MatchResult)
}

/// Pure edge detector for presentation feedback. GameEngine outcomes remain
/// authoritative, while this router guarantees one event per observed edge.
public struct FeedbackEventRouter: Sendable {
    private var previousRemainingTime: TimeInterval?
    private var emittedCountdownNumbers: Set<Int> = []
    private var didEmitResult = false

    public init() {}

    public mutating func startMatch() -> [FeedbackEvent] {
        previousRemainingTime = GameConfig.matchDuration
        emittedCountdownNumbers.removeAll()
        didEmitResult = false
        return [.matchStart]
    }

    public mutating func observe(
        phase: MatchPhase,
        remainingTime: TimeInterval,
        timerPaused: Bool
    ) -> [FeedbackEvent] {
        switch phase {
        case .intro:
            previousRemainingTime = remainingTime
            return []
        case .playing:
            let previous = previousRemainingTime ?? remainingTime
            previousRemainingTime = remainingTime
            guard !timerPaused else { return [] }

            var events: [FeedbackEvent] = []
            for number in [3, 2, 1] where
                previous > Double(number)
                && remainingTime <= Double(number)
                && emittedCountdownNumbers.insert(number).inserted {
                events.append(.countdown(number))
            }
            return events
        case let .finished(result):
            previousRemainingTime = remainingTime
            guard !didEmitResult else { return [] }
            didEmitResult = true
            return [.result(result)]
        }
    }

    public func directTag(
        from pusher: ActorID,
        didTransfer: Bool,
        phase: MatchPhase
    ) -> [FeedbackEvent] {
        guard phase == .playing, didTransfer else { return [] }
        return [.directTag(pusher: pusher, receiver: pusher.opponent)]
    }

    public func shock(
        by owner: ActorID,
        outcome: ShockOutcome,
        phase: MatchPhase
    ) -> [FeedbackEvent] {
        guard phase == .playing else { return [] }
        switch outcome {
        case .unavailable:
            return []
        case .missed:
            return [.shockFire(owner: owner)]
        case .transferred:
            return [
                .shockFire(owner: owner),
                .shockTransfer(owner: owner, receiver: owner.opponent),
            ]
        }
    }
}
