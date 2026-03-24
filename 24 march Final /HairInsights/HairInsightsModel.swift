
import Foundation
// MARK: - Hair Insights, Care Tips, Remedies, Tips

struct HairInsight: Identifiable {
    let id: UUID
    var title: String
    var insightDescription: String
    var category: String
    var mediaURL: String?
    var targetHairTypes: [String]          // ["all"] or ["straight","wavy"]
    var targetScalpConditions: [String]    // ["all"] or ["dry","dandruff"]
    var targetPlanStages: [Int]            // [1,2,3] — which stages
    var difficultyLevel: String?
    var isActive: Bool
}

struct CareTip: Identifiable {
    let id: UUID
    var title: String
    var tipDescription: String
    var mediaURL: String?
    var category: String
    var benefits: String
    var actionSteps: String?
    var priority: Int
}

struct HomeRemedy: Identifiable {
    let id: UUID
    var title: String
    var remedyDescription: String
    var mediaURL: String?
    var benefits: String
    var instructions: String
}

struct DailyTip: Identifiable {
    let id: UUID
    var tipText: String
    var category: String
    var displayDate: Date?
}

struct UserFavorite: Identifiable {
    let id: UUID
    var userId: UUID
    var contentType: String         // "hairInsight" | "careTip" | "homeRemedy"
    var contentId: UUID
    var savedAt: Date
}
