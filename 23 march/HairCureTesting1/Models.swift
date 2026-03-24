//
//  Model.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
//  Models.swift
//  HairCure
//
//  All data models — mock phase (no SwiftData / backend).
//  SwiftData decorators are commented out for easy swap-in later.
//

import Foundation

// MARK: - User & Auth

enum AuthProvider: String, Codable {
    case apple
    case google
    case guest
}

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phoneNumber: String?
    let authProvider: AuthProvider
    let createdAt: Date
}

struct UserProfile: Identifiable {
    let id: UUID
    var userId: UUID
    var username: String
    var displayName: String
    var dateOfBirth: Date
    var gender: String              // "male" only for this app
    var heightCm: Float
    var weightKg: Float
    var hairType: String            // "straight" | "wavy" | "curly"
    var scalpType: String           // static profile preference
    var isVegetarian: Bool
    var profileImageURL: String?
    var isProfileComplete: Bool
    var joinedAt: Date
}

// MARK: - Assessment & Questions

struct Assessment: Identifiable {
    let id: UUID
    var userId: UUID
    var completionPercent: Float
    var completedAt: Date?
//  @Relationship(deleteRule: .cascade) var answers: [UserAnswer] = []
}

enum QuestionType: String, Codable {
    case singleChoice   // one option pill selected
    case multiChoice    // multiple options
    case imageChoice    // visual image cards (stage picker)
    case freeText       // typed answer
    case picker         // scroll wheel — age/height/weight
}

enum KeyboardType: String, Codable {
    case text
    case decimal
    case number
}

enum ScoreDimension: String, Codable {
    case diet
    case stress
    case sleep
    case hairCare
    case hydration  // folded into diet score
    case none       // hair context / BMR Qs — no lifestyle score
}

struct Question: Identifiable {
    let id: UUID
    var questionType: QuestionType
    var questionText: String
    var questionOrderIndex: Int
    var scoreDimension: ScoreDimension
    var pickerMin: Float?
    var pickerMax: Float?
    var pickerStep: Float?
    var pickerUnit: String?
    var keyboardType: KeyboardType?
//  @Relationship(deleteRule: .cascade) var options: [QuestionOption] = []
}

enum OptionType: String, Codable {
    case text
    case image
}

struct QuestionOption: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionOrderIndex: Int
    var optionText: String
    var imageURL: String?
    var optionType: OptionType
}

// Maps each answer option → score value (engine reads this table)
struct QuestionScoreMap: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionId: UUID
    var scoreDimension: ScoreDimension
    var scoreValue: Float           // 0.0 – 10.0
}

struct UserAnswer: Identifiable {
    let id: UUID
    let answeredAt: Date
    var questionId: UUID
    var assessmentId: UUID
    var selectedOptionId: UUID?
    var selectedOptionIds: [UUID]
    var answerText: String?
    var pickerValue: Float?
    // Written after lookup in QuestionScoreMap
    var scoreValue: Float?
    var scoreDimension: ScoreDimension?
}

// MARK: - Scalp Scan & Report

enum ScanType: String, Codable {
    case initial
    case weekly
}

enum AnalysisSource: String, Codable {
    case aiModel        // 4 photos submitted → AI result
    case selfAssessed   // user picked stage/scalp/density manually
}

struct ScalpScan: Identifiable {
    let id: UUID
    var userId: UUID
    let scanDate: Date
    var frontImageURL: String
    var leftImageURL: String
    var rightImageURL: String
    var backImageURL: String
    var topImageURL: String
    let scanType: ScanType
//  @Relationship(deleteRule: .cascade) var report: ScanReport?
}

enum HairFallStage: String, Codable, CaseIterable {
    case stage1
    case stage2
    case stage3
    case stage4  // refer to doctor

    var displayName: String {
        switch self {
        case .stage1: return "Stage 1 — Early thinning"
        case .stage2: return "Stage 2 — Noticeable thinning"
        case .stage3: return "Stage 3 — Crown patch forming"
        case .stage4: return "Stage 4 — Advanced hair loss"
        }
    }

    var intValue: Int {
        switch self {
        case .stage1: return 1
        case .stage2: return 2
        case .stage3: return 3
        case .stage4: return 4
        }
    }
}

enum ScalpCondition: String, Codable {
    case dandruff
    case dry
    case oily
    case inflamed
    case normal

    var displayName: String { rawValue.capitalized }
}

enum HairDensityLevel: String, Codable {
    case high
    case medium
    case low
    case veryLow

    var displayName: String {
        switch self {
        case .high:    return "Thick & full"
        case .medium:  return "Medium"
        case .low:     return "Thin"
        case .veryLow: return "Very thin"
        }
    }
}

struct ScanReport: Identifiable {
    let id: UUID
    let createdAt: Date
    var scalpScanId: UUID
    var hairDensityPercent: Float
    var hairDensityLevel: HairDensityLevel
    var hairFallStage: HairFallStage
    var scalpCondition: ScalpCondition
    var analysisSource: AnalysisSource
    // Engine output — written once scores are calculated
    var planId: String              // "1A"–"3C" or "refer_doctor"
    var lifestyleScore: Float       // composite 0–10
    var dietScore: Float
    var stressScore: Float
    var sleepScore: Float
    var hairCareScore: Float
    var recommendedPlan: String     // human-readable summary
}

// MARK: - Recommendation Engine Output

enum LifestyleProfile: String, Codable {
    case poor       // composite 0–4
    case moderate   // composite 5–7
    case good       // composite 8–10

    static func from(score: Float) -> LifestyleProfile {
        switch score {
        case 0..<5: return .poor
        case 5..<8: return .moderate
        default:    return .good
        }
    }
}

struct UserPlan: Identifiable {
    let id: UUID
    var userId: UUID
    var scanReportId: UUID
    var planId: String              // "1A"|"1B"|"1C"|"2A"|"2B"|"2C"|"3A"|"3B"|"3C"|"refer_doctor"
    var stage: Int                  // 1, 2, 3, 4
    var lifestyleProfile: LifestyleProfile
    var scalpModifier: ScalpCondition
    // MindEase session assignments from plan matrix
    var meditationMinutesPerDay: Int
    var yogaMinutesPerDay: Int
    var soundMinutesPerDay: Int
    var sessionFrequencyPerWeek: Int
    var isActive: Bool
    var assignedAt: Date
    var expiresAt: Date             // triggers weekly re-assessment nudge
}

// MARK: - Nutrition Profile (BMR Engine Output)

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary   // × 1.2
    case light       // × 1.375
    case moderate    // × 1.55
    case veryActive  // × 1.725

    var multiplier: Double {
        switch self {
        case .sedentary:  return 1.2
        case .light:      return 1.375
        case .moderate:   return 1.55
        case .veryActive: return 1.725
        }
    }

    var displayName: String {
        switch self {
        case .sedentary:  return "Sedentary (desk job, little exercise)"
        case .light:      return "Light (1–3 days/week exercise)"
        case .moderate:   return "Moderate (3–5 days/week)"
        case .veryActive: return "Very Active (intense daily exercise)"
        }
    }
}

struct UserNutritionProfile: Identifiable {
    let id: UUID
    var userId: UUID
    var activityLevel: ActivityLevel
    var bmr: Float
    var tdee: Float
    // Per-slot calorie budgets
    var breakfastCalTarget: Float   // tdee × 0.25
    var lunchCalTarget: Float       // tdee × 0.35
    var snackCalTarget: Float       // tdee × 0.15
    var dinnerCalTarget: Float      // tdee × 0.25
    // Daily macro targets
    var proteinTargetGm: Float
    var carbTargetGm: Float
    var fatTargetGm: Float
    var waterTargetML: Float        // 35ml × weightKg
    var createdAt: Date
    var updatedAt: Date
}

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
    case met        // within ±10% of target — show success ✅
    case exceeded   // over target — warn but allow ⚠️
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

// MARK: - MindEase

struct MindEaseCategory: Identifiable {
    let id: UUID
    var title: String               // "Yoga" | "Meditation" | "Relaxing Sounds"
    var categoryDescription: String
    var bannerImageURL: String
    var cardImageUrl: String
    var cardIconName: String
    var bannerTagline: String
}

struct MindEaseCategoryContent: Identifiable {
    let id: UUID
    var categoryId: UUID
    var title: String
    var contentDescription: String
    var mediaURL: String
    var mediaType: String           // "video" | "audio"
    var durationSeconds: Int        // used for session tracking
    var difficultyLevel: String     // "beginner" | "intermediate" | "advanced"
    var thumbnailImageURL: String
    var caption: String
    var orderIndex: Int
    var lastPlaybackSeconds: Int

    var durationMinutes: Int { durationSeconds / 60 }
}

struct MindfulSession: Identifiable {
    let id: UUID
    var userId: UUID
    var contentId: UUID             // FK → MindEaseCategoryContent
    var sessionDate: Date
    var minutesCompleted: Int
    var startTime: Date
    var endTime: Date
}

struct TodaysPlan: Identifiable {
    let id: UUID
    var userId: UUID
    var planDate: Date
    var contentId: UUID             // which session is assigned today
    var categoryId: UUID
    var planId: String              // active plan "1A"–"3C"
    var minutesTarget: Int
    var minutesCompleted: Int
    var orderIndex: Int
    var isCompleted: Bool
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

// MARK: - App Settings

struct AppPreferences: Identifiable {
    let id: UUID
    var userId: UUID
    var preferMetricUnits: Bool
    var vegFilterDefault: Bool
    var defaultMealType: MealType
    var dailyCalorieGoal: Float     // written by BMR engine
    var dailyMindfulMinutesGoal: Int
    var dailyWaterGoalML: Float
}

struct NotificationSettings: Identifiable {
    let id: UUID
    var userId: UUID
    var pushEnabled: Bool
    var mealReminderEnabled: Bool
    var mealReminderTimes: [String]
    var mindfulReminderEnabled: Bool
    var mindfulReminderTime: String
    var waterReminderEnabled: Bool
    var waterReminderIntervalHours: Int
    var bedtimeReminderEnabled: Bool
    var bedtimeReminderMinutesBefore: Int
    var dailyTipEnabled: Bool
    var dailyTipTime: String
    var weeklyScanReminderEnabled: Bool
    var weeklyScanReminderDay: String
    var weeklyScanReminderTime: String
}
