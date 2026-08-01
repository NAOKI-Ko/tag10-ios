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

    var magnitude: Double {
        hypot(x, y)
    }

    var normalized: Vector2 {
        let length = magnitude
        guard length > 0 else { return .zero }
        return Vector2(x: x / length, y: y / length)
    }

    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
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
