import Foundation

struct CareTip: Identifiable {
    let id: UUID
    var title: String
    var tipDescription: String
    var mediaURL: String?               // this will be used for both thumbnail and article/video link
    var isActive: Bool
}

// user fav
struct UserFavorite: Identifiable {
    let id: UUID
    var contentId: UUID // fk for care tip and home remedy
    var savedAt: Date
}


// MARK: - HomeRemedy
// Global static content — same for every user.
// Shown in the "Home Remedies" section.
// Has extra video-specific fields (duration, benefits, instructions).

struct HomeRemedy: Identifiable {
    let id: UUID
    var title: String
    var remedyDescription: String       // Short subtitle e.g. "How to apply egg white mask ?"
    var mediaURL: String?               // Used for both thumbnail and video playback
    var videoDurationSeconds: Int?      // e.g. 120 → "2:00" in player
    var benefits: String
    var instructions: String
    var isActive: Bool // used to hide the content from the user's screen by simply doing false 
}


// MARK: - UserFavourite

// MARK: - RoutineCard
// Derived from RecommendationEngine.buildHairCareRoutine(for:) for carousel display.

struct RoutineCard: Identifiable {
    let id = UUID()  /// display only struct that's why initialised here , it is never stored and never fetched
    var iconName: String
    var title: String
    var subtitle: String
    var description: String
}



