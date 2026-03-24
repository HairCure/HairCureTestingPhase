

import Foundation
// MARK: - DietMate

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case snack
    case dinner

    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .snack:     return "Snacks"
        case .dinner:    return "Dinner"
        }
    }

    var caloriePercent: Float {
        switch self {
        case .breakfast: return 0.25
        case .lunch:     return 0.35
        case .snack:     return 0.15
        case .dinner:    return 0.25
        }
    }

    var recommendedPortionText: String {
        switch self {
        case .breakfast: return "Recommended portion : 25% of daily consumption"
        case .lunch:     return "Recommended portion : 35% of daily consumption"
        case .snack:     return "Recommended portion : 20% of daily consumption"
        case .dinner:    return "Recommended portion : 20% of daily consumption"
        }
    }
}

enum MealGoalStatus: String, Codable {
    case under      // below minimum safe calories — block logging
    case met        // within ±10% of target — show success
    case exceeded   // over target — warn but allow
}

struct MealEntry: Identifiable {
    let id: UUID
    var userId: UUID
    var mealType: MealType
    var date: Date
    var isLogged: Bool
    var loggedAt: Date?
    // Calorie tracking
    var calorieTarget: Float        // from UserNutritionProfile slot budget
    var caloriesConsumed: Float     // running sum as user adds foods
    var proteinConsumed: Float
    var carbsConsumed: Float
    var fatConsumed: Float
    var goalStatus: MealGoalStatus
//  @Relationship(deleteRule: .cascade) var foods: [MealFood] = []
}

struct MealFood: Identifiable {
    let id: UUID
    var mealEntryId: UUID
    var foodId: UUID
    var quantity: Float             // multiplier on serving size (1.0 = 1 serving)
}

struct Food: Identifiable {
    let id: UUID
    var externalFoodId: String?
    var name: String
    var imageURL: String?
    var foodType: String            // "vegetarian" | "non-vegetarian" | "vegan"
    var isVegetarian: Bool
    var isCustom: Bool
    var createdByUserId: UUID?
    var servingSizeGrams: Float
    var apiSource: String?
    // Macros per serving
    var totalCaloriesMin: Float
    var totalCaloriesMax: Float
    var totalProteinsInGm: Float
    var totalCarbsInGm: Float
    var totalFatInGm: Float
    var totalVitaminsInMg: Float
    // Hair-specific nutrient flags
    var isBiotinRich: Bool
    var isZincRich: Bool
    var isIronRich: Bool
    var isOmega3Rich: Bool
    var isVitaminARich: Bool
    // Which meal slots this food suits
    var suitableMealTypes: [MealType]
    var createdAt: Date
}
// MARK: - Sleep & Water

struct SleepRecord: Identifiable {
    let id: UUID
    var userId: UUID
    var date: Date
    var bedTime: Date
    var wakeTime: Date
    var alarmEnabled: Bool
    var alarmTime: Date?
    var hoursSlept: Float
}

struct WaterIntakeLog: Identifiable {
    let id: UUID
    var userId: UUID
    var date: Date
    var cupSize: String             // "small" | "medium" | "large"
    var cupSizeAmountInML: Float
    var loggedAt: Date
}

