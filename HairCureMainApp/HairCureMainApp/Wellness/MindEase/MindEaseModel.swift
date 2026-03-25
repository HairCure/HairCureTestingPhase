//
//  MindEaseModel.swift
//

import Foundation

// MARK: - Category

struct MindEaseCategory: Identifiable, Hashable {
    let id: UUID
    var title: String                   // "Yoga" | "Meditation" | "Relaxing Sounds"
    var categoryDescription: String     // Subtitle shown on the home card
    var cardImageUrl: String            // Asset name → home category card background
    var cardIconName: String            // SF Symbol — fallback & breakdown icons
    var tagline: String                 // Bold hero text at the top of the list view
                                        // e.g. "Inner Peace, Outer Shine"
}

// MARK: - Category Content

struct MindEaseCategoryContent: Identifiable, Hashable {
    let id: UUID
    var categoryId: UUID

    var title: String                   // "Uttanasana", "Bhramari", "Ocean Waves" …
    var contentDescription: String      // One-line description shown in list rows
    var caption: String                 // Sub-caption e.g. "Forward Fold", "Humming Bee Breath"

    var mediaURL: String                // Filename / URL of the actual media asset
    var mediaType: String               // "video" | "audio"
    var durationSeconds: Int

    var difficultyLevel: String      
    var imageurl: String

    var orderIndex: Int
    var lastPlaybackSeconds: Int

    var durationMinutes: Int { durationSeconds / 60 }
}

// MARK: - Mindful Session

struct MindfulSession: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var contentId: UUID             // FK → MindEaseCategoryContent
    var sessionDate: Date
    var minutesCompleted: Int
    var startTime: Date
    var endTime: Date
}

// MARK: - Today's Plan

struct TodaysPlan: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var planDate: Date
    var contentId: UUID             // FK → MindEaseCategoryContent
    var categoryId: UUID
    var planId: String              // Active plan identifier e.g. "1A"–"3C"
    var minutesTarget: Int
    var minutesCompleted: Int
    var orderIndex: Int
    var isCompleted: Bool
}
