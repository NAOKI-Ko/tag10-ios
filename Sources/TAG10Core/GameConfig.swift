import Foundation

/// The authoritative gameplay values from `docs/GAME_RULES.md`.
///
/// Rendering code should consume these values instead of duplicating balance
/// numbers in a scene or view.
public enum GameConfig {
    public static let matchDuration: TimeInterval = 10.0
    public static let stunDuration: TimeInterval = 1.0
    public static let shockArmDuration: TimeInterval = 2.0
    public static let shockCooldownDuration: TimeInterval = 3.0

    public static let itSpeedMultiplier = 1.13
    public static let heatSpeedPerTag = 0.03
    public static let maximumHeatSpeedBonus = 0.24

    public static let initialTagProtectionDuration: TimeInterval = 0.6
    public static let postSwapTagProtectionBuffer: TimeInterval = 0.3

    /// Phase 3 input values. Movement values preserve the HTML prototype's
    /// FLAT-stage relationship (`MAXSPD = width * 0.98`, `ACCEL = MAXSPD * 7`)
    /// without applying the deferred HEAT speed bonus.
    public enum Input {
        public static let motionUpdateInterval: TimeInterval = 1.0 / 60.0
        public static let tiltDeadZoneRadians = 0.05
        public static let tiltFullScaleRadians = 32.0 * .pi / 180.0
        public static let maximumSpeedPerArenaWidth = 0.98
        public static let accelerationMultiplier = 7.0
        public static let dampingPerSixtiethSecond = 0.86
        public static let debugDragActivationDistance: Double = 8.0
    }

    /// Range relationships from the HTML reference implementation, expressed
    /// relative to the rendered actor radius so they remain arena-size aware.
    public enum Range {
        public static let directTagActorRadii = 2.0
        public static let shockActorRadii = 4.0
    }

    /// Multipliers used by the HTML reference implementation. The native
    /// movement system will provide the arena-relative maximum speed later.
    public static let directTagKnockbackMultiplier = 2.2
    public static let shockTagKnockbackMultiplier = 0.85

    public enum Rating {
        public static let initial = 1_000
        public static let winDelta = 22
        public static let lossDelta = -16
        public static let floor = 0
    }

    public enum RankThreshold {
        public static let diamond = 1_600
        public static let platinum = 1_400
        public static let gold = 1_200
        public static let silver = 1_000
        public static let bronze = 0
    }

    public static var postSwapTagProtectionDuration: TimeInterval {
        stunDuration + postSwapTagProtectionBuffer
    }

    public static func heatMultiplier(tagCount: Int) -> Double {
        let safeTagCount = max(0, tagCount)
        let bonus = min(Double(safeTagCount) * heatSpeedPerTag, maximumHeatSpeedBonus)
        return 1.0 + bonus
    }
}
