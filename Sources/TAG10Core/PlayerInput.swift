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

/// Pure conversion between authoritative normalized state and arena points.
public enum ArenaGeometry {
    public static func pointVector(fromNormalized vector: Vector2, arenaSize: Vector2) -> Vector2 {
        Vector2(x: vector.x * arenaSize.x, y: vector.y * arenaSize.y)
    }

    public static func normalizedVector(fromPoints vector: Vector2, arenaSize: Vector2) -> Vector2 {
        guard arenaSize.x > 0, arenaSize.y > 0 else { return .zero }
        return Vector2(x: vector.x / arenaSize.x, y: vector.y / arenaSize.y)
    }
}

/// Pure point-space movement integration shared by both actors.
public enum ActorMovement {
    public static func integrate(
        actor: ActorState,
        input: Vector2,
        deltaTime: TimeInterval,
        bounds: MovementBounds,
        arenaSize: Vector2,
        maximumSpeed: Double,
        heatMultiplier: Double = 1,
        stage: GameStage = .flat,
        actorRadius: Double = 0
    ) -> ActorState {
        guard deltaTime > 0,
              !actor.isStunned,
              arenaSize.x > 0,
              arenaSize.y > 0 else { return actor }

        let clampedInput = input.magnitude > 1 ? input.normalized : input
        let stageCap = stage == .bowl ? GameConfig.Stage.bowlSpeedCapMultiplier : 1
        let speedLimit = maximumSpeed
            * (actor.isIt ? GameConfig.itSpeedMultiplier : 1)
            * heatMultiplier
            * stageCap
        let acceleration = maximumSpeed * GameConfig.Input.accelerationMultiplier
        let dampingRate = -60 * log(GameConfig.Input.dampingPerSixtiethSecond)
        let decay = exp(-dampingRate * deltaTime)

        let initialPointVelocity = ArenaGeometry.pointVector(
            fromNormalized: actor.velocity,
            arenaSize: arenaSize
        )
        let initialPointPosition = ArenaGeometry.pointVector(
            fromNormalized: actor.position,
            arenaSize: arenaSize
        )
        var pointAcceleration = clampedInput * acceleration
        if stage == .bowl {
            let center = Vector2(x: arenaSize.x / 2, y: arenaSize.y / 2)
            pointAcceleration = pointAcceleration
                + (center - initialPointPosition) * GameConfig.Stage.bowlCenterAcceleration
        }
        var pointVelocity = Vector2(
            x: initialPointVelocity.x * decay
                + pointAcceleration.x * (1 - decay) / dampingRate,
            y: initialPointVelocity.y * decay
                + pointAcceleration.y * (1 - decay) / dampingRate
        )
        let didReachSpeedCap = pointVelocity.magnitude > speedLimit
        if didReachSpeedCap {
            pointVelocity = pointVelocity.normalized * speedLimit
        }

        let accelerationPositionFactor = deltaTime / dampingRate
            - (1 - decay) / (dampingRate * dampingRate)
        let pointPosition: Vector2
        if didReachSpeedCap {
            // Prototype order caps velocity before advancing position.
            pointPosition = initialPointPosition + pointVelocity * deltaTime
        } else {
            pointPosition = Vector2(
                x: initialPointPosition.x
                    + initialPointVelocity.x * (1 - decay) / dampingRate
                    + pointAcceleration.x * accelerationPositionFactor,
                y: initialPointPosition.y
                    + initialPointVelocity.y * (1 - decay) / dampingRate
                    + pointAcceleration.y * accelerationPositionFactor
            )
        }
        var position = ArenaGeometry.normalizedVector(fromPoints: pointPosition, arenaSize: arenaSize)
        let unclampedPosition = position
        position = bounds.clamped(position)
        if position.x != unclampedPosition.x { pointVelocity.x = 0 }
        if position.y != unclampedPosition.y { pointVelocity.y = 0 }

        if stage == .pillar {
            let resolved = PillarCollision.resolve(
                position: position,
                pointVelocity: pointVelocity,
                arenaSize: arenaSize,
                minimumDistance: actorRadius * (GameConfig.Stage.pillarRadiusActorRadii + 1)
            )
            position = bounds.clamped(resolved.position)
            pointVelocity = resolved.pointVelocity
        }

        var updatedActor = actor
        updatedActor.position = position
        updatedActor.velocity = ArenaGeometry.normalizedVector(
            fromPoints: pointVelocity,
            arenaSize: arenaSize
        )
        return updatedActor
    }
}

/// Compatibility name retained for Phase 3 callers and regression tests.
public typealias PlayerMovement = ActorMovement

public enum PillarCollision {
    public static func resolve(
        position: Vector2,
        pointVelocity: Vector2,
        arenaSize: Vector2,
        minimumDistance: Double
    ) -> (position: Vector2, pointVelocity: Vector2) {
        guard arenaSize.x > 0, arenaSize.y > 0, minimumDistance > 0 else {
            return (position, pointVelocity)
        }
        let center = Vector2(x: arenaSize.x / 2, y: arenaSize.y / 2)
        let pointPosition = ArenaGeometry.pointVector(fromNormalized: position, arenaSize: arenaSize)
        let displacement = pointPosition - center
        guard displacement.magnitude < minimumDistance else {
            return (position, pointVelocity)
        }

        let normal = displacement.magnitude > 0.001
            ? displacement.normalized
            : (pointVelocity.magnitude > 0.001 ? (pointVelocity * -1).normalized : Vector2(x: 1, y: 0))
        let correctedPointPosition = center + normal * minimumDistance
        var correctedVelocity = pointVelocity
        let inwardVelocity = correctedVelocity.dot(normal)
        if inwardVelocity < 0 {
            correctedVelocity = correctedVelocity - normal * inwardVelocity
        }
        return (
            ArenaGeometry.normalizedVector(fromPoints: correctedPointPosition, arenaSize: arenaSize),
            correctedVelocity
        )
    }
}

public struct CPUDifficulty: Equatable, Sendable {
    public let lead: Double
    public let jitter: Double

    public init(rating: Int) {
        let difference = Double(rating - GameConfig.CPU.baselineRating)
        lead = min(
            GameConfig.CPU.maximumLead,
            max(GameConfig.CPU.minimumLead, GameConfig.CPU.leadBase + difference * GameConfig.CPU.leadPerRatingDelta)
        )
        jitter = min(
            GameConfig.CPU.maximumJitter,
            max(GameConfig.CPU.minimumJitter, GameConfig.CPU.jitterBase - difference * GameConfig.CPU.jitterPerRatingDelta)
        )
    }
}

public enum CPUController {
    /// `jitterSample` is injected in [-1, 1] so tests can be deterministic.
    public static func input(
        cpu: ActorState,
        player: ActorState,
        arenaSize: Vector2,
        actorRadius: Double,
        rating: Int,
        jitterSample: Vector2
    ) -> Vector2 {
        guard arenaSize.x > 0, arenaSize.y > 0 else { return .zero }
        let difficulty = CPUDifficulty(rating: rating)
        let cpuPoint = ArenaGeometry.pointVector(fromNormalized: cpu.position, arenaSize: arenaSize)
        let playerPoint = ArenaGeometry.pointVector(fromNormalized: player.position, arenaSize: arenaSize)
        let playerVelocity = ArenaGeometry.pointVector(fromNormalized: player.velocity, arenaSize: arenaSize)
        var direction: Vector2

        if cpu.isIt {
            direction = playerPoint + playerVelocity * difficulty.lead - cpuPoint
        } else {
            direction = (cpuPoint - playerPoint).normalized
            let margin = actorRadius * GameConfig.CPU.wallMarginActorRadii
            var wall = Vector2.zero
            if cpuPoint.x < margin { wall.x += 1 }
            else if cpuPoint.x > arenaSize.x - margin { wall.x -= 1 }
            if cpuPoint.y < margin { wall.y += 1 }
            else if cpuPoint.y > arenaSize.y - margin { wall.y -= 1 }
            let centerBias = Vector2(
                x: (arenaSize.x / 2 - cpuPoint.x) / arenaSize.x,
                y: (arenaSize.y / 2 - cpuPoint.y) / arenaSize.y
            ) * GameConfig.CPU.centerBiasWeight
            direction = direction + wall * GameConfig.CPU.wallAvoidanceWeight + centerBias
        }

        direction = direction.normalized
        direction = direction + Vector2(
            x: jitterSample.x * difficulty.jitter,
            y: jitterSample.y * difficulty.jitter
        )
        return direction.normalized
    }

    public static func shouldUseShock(
        cpu: ActorState,
        player: ActorState,
        rating: Int,
        arenaSize: Vector2,
        actorRadius: Double
    ) -> Bool {
        guard cpu.isIt,
              !cpu.isStunned,
              cpu.shockCooldownRemaining == 0,
              rating >= GameConfig.CPU.shockRatingThreshold else { return false }
        let distance = CollisionRules.distanceInPoints(
            from: cpu.position,
            to: player.position,
            arenaSize: arenaSize
        )
        return distance < actorRadius
            * GameConfig.Range.shockActorRadii
            * GameConfig.CPU.shockRangeMultiplier
    }
}

/// Range checks use normalized authoritative positions plus arena geometry.
public enum CollisionRules {
    public static func distanceInPoints(
        from source: Vector2,
        to target: Vector2,
        arenaSize: Vector2
    ) -> Double {
        ArenaGeometry.pointVector(
            fromNormalized: target - source,
            arenaSize: arenaSize
        ).magnitude
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
