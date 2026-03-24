
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
