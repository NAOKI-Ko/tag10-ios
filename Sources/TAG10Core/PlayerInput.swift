import Foundation

/// Rendering-independent attitude sample used by the CoreMotion adapter.
public struct MotionAttitude: Equatable, Sendable {
    public var roll: Double
    public var pitch: Double

    public init(roll: Double, pitch: Double) {
        self.roll = roll
        self.pitch = pitch
    }
}

/// Maps attitude samples to a normalized two-dimensional input vector.
/// The first accepted sample is explicitly stored as the neutral orientation.
public struct TiltInputMapper: Equatable, Sendable {
    public let deadZoneRadians: Double
    public let fullScaleRadians: Double
    public private(set) var neutralAttitude: MotionAttitude?

    public init(
        deadZoneRadians: Double = GameConfig.Input.tiltDeadZoneRadians,
        fullScaleRadians: Double = GameConfig.Input.tiltFullScaleRadians
    ) {
        precondition(deadZoneRadians >= 0)
        precondition(fullScaleRadians > deadZoneRadians)
        self.deadZoneRadians = deadZoneRadians
        self.fullScaleRadians = fullScaleRadians
    }

    public mutating func calibrate(using attitude: MotionAttitude) {
        neutralAttitude = attitude
    }

    public mutating func resetCalibration() {
        neutralAttitude = nil
    }

    public func input(for attitude: MotionAttitude) -> Vector2 {
        guard let neutralAttitude else { return .zero }

        let delta = Vector2(
            x: wrappedAngle(attitude.roll - neutralAttitude.roll),
            y: -wrappedAngle(attitude.pitch - neutralAttitude.pitch)
        )
        let magnitude = delta.magnitude
        guard magnitude > deadZoneRadians else { return .zero }

        let direction = delta.normalized
        let normalizedMagnitude = min(
            1,
            (magnitude - deadZoneRadians) / (fullScaleRadians - deadZoneRadians)
        )
        return direction * normalizedMagnitude
    }

    private func wrappedAngle(_ angle: Double) -> Double {
        atan2(sin(angle), cos(angle))
    }
}

public struct MovementBounds: Equatable, Sendable {
    public let minimumX: Double
    public let maximumX: Double
    public let minimumY: Double
    public let maximumY: Double

    public init(minimumX: Double, maximumX: Double, minimumY: Double, maximumY: Double) {
        precondition(minimumX <= maximumX)
        precondition(minimumY <= maximumY)
        self.minimumX = minimumX
        self.maximumX = maximumX
        self.minimumY = minimumY
        self.maximumY = maximumY
    }

    public static let normalized = MovementBounds(
        minimumX: 0,
        maximumX: 1,
        minimumY: 0,
        maximumY: 1
    )

    public func clamped(_ position: Vector2) -> Vector2 {
        Vector2(
            x: min(maximumX, max(minimumX, position.x)),
            y: min(maximumY, max(minimumY, position.y))
        )
    }
}

/// Pure movement integration shared by gameplay orchestration and unit tests.
public enum PlayerMovement {
    public static func integrate(
        actor: ActorState,
        input: Vector2,
        deltaTime: TimeInterval,
        bounds: MovementBounds,
        maximumSpeed: Double
    ) -> ActorState {
        guard deltaTime > 0, !actor.isStunned else { return actor }

        let clampedInput = input.magnitude > 1 ? input.normalized : input
        let speedLimit = maximumSpeed * (actor.isIt ? GameConfig.itSpeedMultiplier : 1)
        let acceleration = maximumSpeed * GameConfig.Input.accelerationMultiplier
        let dampingRate = -60 * log(GameConfig.Input.dampingPerSixtiethSecond)
        let decay = exp(-dampingRate * deltaTime)

        let initialVelocity = actor.velocity
        var velocity = Vector2(
            x: initialVelocity.x * decay
                + clampedInput.x * acceleration * (1 - decay) / dampingRate,
            y: initialVelocity.y * decay
                + clampedInput.y * acceleration * (1 - decay) / dampingRate
        )
        if velocity.magnitude > speedLimit {
            velocity = velocity.normalized * speedLimit
        }

        let accelerationPositionFactor = deltaTime / dampingRate
            - (1 - decay) / (dampingRate * dampingRate)
        var position = Vector2(
            x: actor.position.x
                + initialVelocity.x * (1 - decay) / dampingRate
                + clampedInput.x * acceleration * accelerationPositionFactor,
            y: actor.position.y
                + initialVelocity.y * (1 - decay) / dampingRate
                + clampedInput.y * acceleration * accelerationPositionFactor
        )
        let unclampedPosition = position
        position = bounds.clamped(position)
        if position.x != unclampedPosition.x { velocity.x = 0 }
        if position.y != unclampedPosition.y { velocity.y = 0 }

        var updatedActor = actor
        updatedActor.position = position
        updatedActor.velocity = velocity
        return updatedActor
    }
}

/// Range checks use normalized authoritative positions plus arena geometry.
public enum CollisionRules {
    public static func distanceInPoints(
        from source: Vector2,
        to target: Vector2,
        arenaSize: Vector2
    ) -> Double {
        hypot(
            (target.x - source.x) * arenaSize.x,
            (target.y - source.y) * arenaSize.y
        )
    }

    public static func isDirectTagInRange(
        playerPosition: Vector2,
        cpuPosition: Vector2,
        arenaSize: Vector2,
        actorRadius: Double
    ) -> Bool {
        distanceInPoints(from: playerPosition, to: cpuPosition, arenaSize: arenaSize)
            < actorRadius * GameConfig.Range.directTagActorRadii
    }

    public static func isShockTargetInRange(
        ownerPosition: Vector2,
        targetPosition: Vector2,
        arenaSize: Vector2,
        actorRadius: Double
    ) -> Bool {
        distanceInPoints(from: ownerPosition, to: targetPosition, arenaSize: arenaSize)
            < actorRadius * GameConfig.Range.shockActorRadii
    }
}
