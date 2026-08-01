import Foundation

public struct RatingChange: Equatable, Sendable {
    public let oldRating: Int
    public let newRating: Int

    public var delta: Int {
        newRating - oldRating
    }
}

public struct PlayerProgress: Equatable, Sendable {
    public private(set) var rating: Int
    public private(set) var streak: Int

    public init(rating: Int = GameConfig.Rating.initial, streak: Int = 0) {
        self.rating = max(GameConfig.Rating.floor, rating)
        self.streak = max(0, streak)
    }

    @discardableResult
    public mutating func record(_ result: MatchResult) -> RatingChange {
        let oldRating = rating

        switch result {
        case .win:
            rating += GameConfig.Rating.winDelta
            streak += 1
        case .loss:
            rating = max(GameConfig.Rating.floor, rating + GameConfig.Rating.lossDelta)
            streak = 0
        }

        return RatingChange(oldRating: oldRating, newRating: rating)
    }

    public var rank: Rank {
        switch rating {
        case GameConfig.RankThreshold.diamond...:
            return .diamond
        case GameConfig.RankThreshold.platinum...:
            return .platinum
        case GameConfig.RankThreshold.gold...:
            return .gold
        case GameConfig.RankThreshold.silver...:
            return .silver
        default:
            return .bronze
        }
    }
}
