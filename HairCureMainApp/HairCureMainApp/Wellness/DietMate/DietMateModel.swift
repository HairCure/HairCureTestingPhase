import Foundation
import SwiftUI

// MARK: - MealType

enum MealType: String, Codable, CaseIterable {
    case breakfast, lunch, snack, dinner

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

    /// Replaces the hardcoded switch block inside AddMealView.portionSection.
    var calorieRangeText: String {
        switch self {
        case .breakfast: return "300 – 510 kcal"
        case .lunch:     return "500 – 713 kcal"
        case .snack:     return "200 – 306 kcal"
        case .dinner:    return "400 – 510 kcal"
        }
    }

    var accentColor: Color {
        switch self {
        case .breakfast: return Color(red: 0.976, green: 0.451, blue: 0.086)
        case .lunch:     return Color(red: 0.937, green: 0.420, blue: 0.420)
        case .snack:     return Color(red: 0.133, green: 0.773, blue: 0.369)
        case .dinner:    return Color(red: 0.659, green: 0.333, blue: 0.969)
        }
    }

    var displayOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch:     return 1
        case .snack:     return 2
        case .dinner:    return 3
        }
    }
}

// MARK: - MealGoalStatus

enum MealGoalStatus: String, Codable {
    case under      // below minimum safe calories — block logging
    case met        // within ±10 % of target — show success
    case exceeded   // over target — warn but allow
}

// MARK: - GoalStatusStyle
// Single source of truth for colour + icon tied to MealGoalStatus.
// Used in AddMealView, DietMateView (LoggedMealCard) — never duplicate the switch.

struct GoalStatusStyle {
    let color: Color
    let icon: String
    let backgroundColor: Color

    static func of(_ status: MealGoalStatus) -> GoalStatusStyle {
        switch status {
        case .under:
            return GoalStatusStyle(
                color: .red,
                icon: "exclamationmark.triangle.fill",
                backgroundColor: Color.red.opacity(0.10)
            )
        case .met:
            return GoalStatusStyle(
                color: .green,
                icon: "checkmark.circle.fill",
                backgroundColor: Color.green.opacity(0.10)
            )
        case .exceeded:
            return GoalStatusStyle(
                color: .orange,
                icon: "exclamationmark.circle.fill",
                backgroundColor: Color.orange.opacity(0.12)
            )
        }
    }
}

// MARK: - MealEntry

struct MealEntry: Identifiable {
    let id: UUID
    var userId: UUID
    var mealType: MealType
    var date: Date
    var isLogged: Bool
    var loggedAt: Date?
    var calorieTarget: Float
    var caloriesConsumed: Float
    var proteinConsumed: Float
    var carbsConsumed: Float
    var fatConsumed: Float
    var goalStatus: MealGoalStatus
}

// MARK: - MealFood

struct MealFood: Identifiable {
    let id: UUID
    var mealEntryId: UUID
    var foodId: UUID
    var quantity: Float     // multiplier on serving size (1.0 = 1 serving)
}

// MARK: - Food

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

    // MARK: Computed helpers — used across AddMealView, DietMateView, FoodDetailView

    /// Mid-point calorie value. Replaces repeated `(min + max) / 2` across all views.
    var averageCalories: Float {
        (totalCaloriesMin + totalCaloriesMax) / 2
    }

    /// Ordered list of hair-nutrient labels this food provides.
    /// Replaces the five-boolean filter inline in FoodDetailView.
    var hairNutrients: [String] {
        var list: [String] = []
        if isBiotinRich   { list.append("Biotin") }
        if isZincRich     { list.append("Zinc") }
        if isIronRich     { list.append("Iron") }
        if isOmega3Rich   { list.append("Omega-3") }
        if isVitaminARich { list.append("Vitamin A") }
        return list
    }
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
