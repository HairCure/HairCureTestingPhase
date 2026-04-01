//
//  DataModels.swift
//  HairCureMainApp
//
//  Core data models used throughout the app.
//  Plain structs (no SwiftData) — ready for backend migration.
//

import Foundation

// MARK: - Auth

enum AuthProvider: String, Codable {
    case apple
    case google
    case guest
}

// MARK: - User

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phoneNumber: String?
    let authProvider: AuthProvider
    let createdAt: Date
}

// MARK: - UserProfile

struct UserProfile: Identifiable {
    let id: UUID
    var userId: UUID
    var username: String
    var displayName: String
    var dateOfBirth: Date
    var gender: String
    var heightCm: Float
    var weightKg: Float
    var hairType: String
    var scalpType: String
    var isVegetarian: Bool
    var profileImageURL: String?
    var isProfileComplete: Bool
    var joinedAt: Date
}

// MARK: - Assessment

struct Assessment: Identifiable {
    let id: UUID
    var userId: UUID
    var completionPercent: Float
    var completedAt: Date?
}

// MARK: - Question / Option / ScoreMap

enum QuestionType: String, Codable {
    case singleChoice
    case multiChoice
    case imageChoice
    case freeText
    case picker
}

enum KeyboardType: String, Codable {
    case text
    case decimal
    case number
}

enum OptionType: String, Codable {
    case text
    case image
}

struct Question: Identifiable {
    let id: UUID
    let questionType: QuestionType
    var questionText: String
    var questionOrderIndex: Int
    var scoreDimension: ScoreDimension
    var pickerMin: Float?
    var pickerMax: Float?
    var pickerStep: Float?
    var pickerUnit: String?
    var keyboardType: KeyboardType?
}

struct QuestionOption: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionOrderIndex: Int
    var optionText: String
    var imageURL: String?
    var optionType: OptionType
}

enum ScoreDimension: String, Codable {
    case diet
    case stress
    case sleep
    case hairCare
    case hydration
    case none
}

struct QuestionScoreMap: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionId: UUID
    var scoreDimension: ScoreDimension
    var scoreValue: Float
}

// MARK: - UserAnswer

struct UserAnswer: Identifiable {
    let id: UUID
    let answeredAt: Date
    var questionId: UUID
    var assessmentId: UUID
    var selectedOptionId: UUID?
    var selectedOptionIds: [UUID]
    var answerText: String?
    var pickerValue: Float?
    var scoreValue: Float?
    var scoreDimension: ScoreDimension?
}

// MARK: - Scalp Scan / Report

enum ScanType: String, Codable {
    case initial
    case weekly
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
}

enum HairFallStage: String, Codable {
    case stage1
    case stage2
    case stage3
    case stage4

    var intValue: Int {
        switch self {
        case .stage1: return 1
        case .stage2: return 2
        case .stage3: return 3
        case .stage4: return 4
        }
    }

    var displayName: String {
        switch self {
        case .stage1: return "Stage 1"
        case .stage2: return "Stage 2"
        case .stage3: return "Stage 3"
        case .stage4: return "Stage 4"
        }
    }
}

enum ScalpCondition: String, Codable {
    case dry
    case dandruff
    case oily
    case inflamed
    case normal
}

enum HairDensityLevel: String, Codable {
    case high
    case medium
    case low
    case veryLow
}

enum AnalysisSource: String, Codable {
    case aiModel
    case selfAssessed
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
    var planId: String
    var lifestyleScore: Float
    var dietScore: Float
    var stressScore: Float
    var sleepScore: Float
    var hairCareScore: Float
    var recommendedPlan: String
}

// MARK: - Lifestyle Profile

enum LifestyleProfile: String, Codable {
    case poor
    case moderate
    case good

    static func from(score: Float) -> LifestyleProfile {
        switch score {
        case 0..<5:   return .poor
        case 5..<8:   return .moderate
        default:      return .good
        }
    }
}

// MARK: - Activity Level

enum ActivityLevel: String, Codable {
    case sedentary
    case light
    case moderate
    case veryActive

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light:     return 1.375
        case .moderate:  return 1.55
        case .veryActive: return 1.725
        }
    }
}

// MARK: - UserPlan

struct UserPlan: Identifiable {
    let id: UUID
    var userId: UUID
    var scanReportId: UUID
    var planId: String
    var stage: Int
    var lifestyleProfile: LifestyleProfile
    var scalpModifier: ScalpCondition
    var meditationMinutesPerDay: Int
    var yogaMinutesPerDay: Int
    var soundMinutesPerDay: Int
    var sessionFrequencyPerWeek: Int
    var isActive: Bool
    var assignedAt: Date
    var expiresAt: Date
}

// MARK: - UserNutritionProfile

struct UserNutritionProfile: Identifiable {
    let id: UUID
    var userId: UUID
    var activityLevel: ActivityLevel
    var bmr: Float
    var tdee: Float
    var breakfastCalTarget: Float
    var lunchCalTarget: Float
    var snackCalTarget: Float
    var dinnerCalTarget: Float
    var proteinTargetGm: Float
    var carbTargetGm: Float
    var fatTargetGm: Float
    var waterTargetML: Float
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - AppPreferences

struct AppPreferences: Identifiable {
    let id: UUID
    var userId: UUID
    var preferMetricUnits: Bool
    var vegFilterDefault: Bool
    var defaultMealType: MealType
    var dailyCalorieGoal: Float
    var dailyMindfulMinutesGoal: Int
    var dailyWaterGoalML: Float
}

// MARK: - NotificationSettings

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
