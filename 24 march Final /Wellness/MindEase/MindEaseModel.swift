
import Foundation

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
