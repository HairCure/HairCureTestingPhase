import Foundation
import Observation
import SwiftUI

// MARK: - MindEaseDataStore

@Observable
final class MindEaseDataStore {

    // MARK: - Stable IDs
    private let yogaID       = UUID()
    private let meditationID = UUID()
    private let soundsID     = UUID()

    private let uttanasanaID  = UUID()
    private let mukhaID       = UUID()
    private let shirshasanaID = UUID()
    private let balayamID     = UUID()
    private let vajrasanaID   = UUID()

    private let bhramariID   = UUID()
    private let anulomID     = UUID()
    private let kapalbhatiID = UUID()
    private let bodyScanID   = UUID()
    private let guidedVisID  = UUID()

    private let oceanWavesID   = UUID()
    private let forestBreezeID = UUID()
    private let birdSongsID    = UUID()
    private let deepSleepID    = UUID()
    private let eveningWindID  = UUID()

    // MARK: - State
    var mindEaseCategories:       [MindEaseCategory]        = []
    var mindEaseCategoryContents: [MindEaseCategoryContent] = []
    var mindfulSessions:           [MindfulSession]          = []
    var todaysPlans:               [TodaysPlan]              = []
    var sessionStartTimes:         [UUID: Date]              = [:]

    var currentUserId: UUID
    weak var parentStore: AppDataStore?

    // MARK: - Init
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        seedCategories()
        seedContent()
    }

    // MARK: - Seed Categories
    private func seedCategories() {
        mindEaseCategories = [
            MindEaseCategory(
                id: yogaID,
                title: "Yoga",
                categoryDescription: "Gentle poses to strengthen body and reduce hair fall",
                cardImageUrl: "yoga",
                cardIconName: "figure.yoga",
                tagline: "Inner Peace, Outer Shine"
            ),
            MindEaseCategory(
                id: meditationID,
                title: "Meditation",
                categoryDescription: "Mindful practices to reduce cortisol and support hair health",
                cardImageUrl: "meditation",
                cardIconName: "brain.head.profile",
                tagline: "Take A Deep Breathe"
            ),
            MindEaseCategory(
                id: soundsID,
                title: "Relaxing Sounds",
                categoryDescription: "Soothing sounds to help you relax and unwind",
                cardImageUrl: "sounds",
                cardIconName: "waveform",
                tagline: "Close Your Eyes And Unwind"
            ),
        ]
    }

    // MARK: - Seed Content
    private func seedContent() {
        mindEaseCategoryContents = [
            // Yoga
            MindEaseCategoryContent(
                id: uttanasanaID, categoryId: yogaID,
                title: "Uttanasana",
                contentDescription: "Forward bend — relieves stress and refreshes scalp",
                caption: "Forward Fold",
                mediaURL: "yoga_1.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "uttanasana", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: mukhaID, categoryId: yogaID,
                title: "Mukha Svanasana",
                contentDescription: "Downward dog — increases blood flow to scalp",
                caption: "Downward Facing Dog",
                mediaURL: "yoga_2.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "ardh", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: shirshasanaID, categoryId: yogaID,
                title: "Shirshasana",
                contentDescription: "Headstand — boosts circulation to hair follicles",
                caption: "Headstand",
                mediaURL: "yoga_3.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "intermediate",
                imageurl: "shirshasana", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: balayamID, categoryId: yogaID,
                title: "Balayam",
                contentDescription: "Nail rubbing — stimulates hair follicles directly",
                caption: "Downward Fold",
                mediaURL: "yoga_4.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "beginner",
                imageurl: "uttanasana", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: vajrasanaID, categoryId: yogaID,
                title: "Vajrasana",
                contentDescription: "Diamond pose — aids digestion and nutrient absorption",
                caption: "Diamond Pose",
                mediaURL: "yoga_5.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana", lastPlaybackSeconds: 0
            ),

            //  Meditation
            MindEaseCategoryContent(
                id: bhramariID, categoryId: meditationID,
                title: "Bhramari",
                contentDescription: "Humming bee breath — reduces stress hormones rapidly",
                caption: "Humming Bee Breath",
                mediaURL: "meditation_1.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "beginner",
                imageurl: "yoga", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: anulomID, categoryId: meditationID,
                title: "Anulom Vilom",
                contentDescription: "Alternate nostril breathing — balances the nervous system",
                caption: "Alternate Nostril Breathing",
                mediaURL: "meditation_2.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: kapalbhatiID, categoryId: meditationID,
                title: "Kapalbhati",
                contentDescription: "Cleansing breath — detoxifies and energises",
                caption: "Skull Shining Breath",
                mediaURL: "meditation_3.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "intermediate",
                imageurl: "shirshasana", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: bodyScanID, categoryId: meditationID,
                title: "Body Scan Meditation",
                contentDescription: "Full body relaxation — releases physical tension",
                caption: "Full Body Relaxation",
                mediaURL: "meditation_4.mp4", mediaType: "video",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "body_scan_list", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: guidedVisID, categoryId: meditationID,
                title: "Guided Visualisation",
                contentDescription: "Positive imagery — reduces cortisol levels",
                caption: "Positive Imagery",
                mediaURL: "meditation_5.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "intermediate",
                imageurl: "guided_vis_list", lastPlaybackSeconds: 0
            ),

            // ── Relaxing Sounds 
            MindEaseCategoryContent(
                id: oceanWavesID, categoryId: soundsID,
                title: "Ocean Waves",
                contentDescription: "Rhythmic waves — deeply calming and sleep-inducing",
                caption: "Rhythmic ocean waves for deep calm",
                mediaURL: "sound_1.mp3", mediaType: "audio",
                durationSeconds: 3600, difficultyLevel: "beginner",
                imageurl: "ocean_waves_list", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: forestBreezeID, categoryId: soundsID,
                title: "Forest Breeze",
                contentDescription: "Rustling leaves — reduces anxiety naturally",
                caption: "Leaves and wind to ease anxiety",
                mediaURL: "sound_2.mp3", mediaType: "audio",
                durationSeconds: 1800, difficultyLevel: "beginner",
                imageurl: "forest_breeze_list", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: birdSongsID, categoryId: soundsID,
                title: "Bird Songs",
                contentDescription: "Morning birds — uplifts mood and reduces stress",
                caption: "Birdsong to lift mood and ease stress",
                mediaURL: "sound_3.mp3", mediaType: "audio",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "bird_songs_list", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: deepSleepID, categoryId: soundsID,
                title: "Deep Sleep Music",
                contentDescription: "432 Hz binaural tones — improves sleep quality",
                caption: "432 Hz binaural tones for better sleep",
                mediaURL: "sound_4.mp3", mediaType: "audio",
                durationSeconds: 3600, difficultyLevel: "beginner",
                imageurl: "deep_sleep_list", lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: eveningWindID, categoryId: soundsID,
                title: "Evening Wind Down",
                contentDescription: "Soft wind chimes — perfect for winding down",
                caption: "Soft wind chimes ideal before sleep",
                mediaURL: "sound_5.mp3", mediaType: "audio",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "evening_wind_list", lastPlaybackSeconds: 0
            ),
        ]
    }

    // MARK: - Seed All (called after AppDataStore is ready)
    func seedAll(userId: UUID, userPlans: [UserPlan]) {
        seedTodaysPlan(userId: userId, userPlans: userPlans)
        // Historical mindful data removed — starts empty, user creates entries
    }

    // MARK: - Today's Plan
    private func seedTodaysPlan(userId: UUID, userPlans: [UserPlan]) {
        guard let plan = userPlans.first(where: { $0.userId == userId }) else { return }
        let today = Date()

        let entries: [(UUID, UUID, Int)] = [
            (bhramariID,     meditationID, plan.meditationMinutesPerDay),
            (anulomID,       meditationID, 15),
            (uttanasanaID,   yogaID,       plan.yogaMinutesPerDay),
            (mukhaID,        yogaID,       15),
            (balayamID,      yogaID,       10),
            (oceanWavesID,   soundsID,     plan.soundMinutesPerDay),
            (forestBreezeID, soundsID,     10),
        ]

        todaysPlans = entries.map { contentId, categoryId, target in
            TodaysPlan(
                id: UUID(), userId: userId, planDate: today,
                contentId: contentId, categoryId: categoryId,
                planId: plan.planId,
                minutesTarget: target, minutesCompleted: 0,
                isCompleted: false
            )
        }
    }

    // MARK: - Historical Data
    private func seedHistoricalMindfulData(userId: UUID, userPlans: [UserPlan]) {
        let cal    = Calendar.current
        let raw    = Double(dailyMindfulTarget)
        let target = min(60.0, max(15.0, raw))

        let dayData: [(Int, Double)] = [
            (1, 1.00), (2, 0.80), (3, 0.95),
            (4, 0.00), (5, 0.70), (6, 0.90),
        ]

        for (daysAgo, fraction) in dayData {
            guard fraction > 0,
                  let pastDate = cal.date(byAdding: .day, value: -daysAgo, to: .now)
            else { continue }

            let dayStart  = cal.startOfDay(for: pastDate)
            let startTime = cal.date(byAdding: .hour, value: 7, to: dayStart) ?? dayStart
            let minutes   = Int((target * fraction).rounded())
            let endTime   = cal.date(byAdding: .minute, value: minutes, to: startTime) ?? startTime

            mindfulSessions.append(MindfulSession(
                id: UUID(), userId: userId,
                contentId: bhramariID,
                sessionDate: dayStart, minutesCompleted: minutes,
                startTime: startTime, endTime: endTime
            ))
        }
    }

    // MARK: - Computed Daily Target
    var dailyMindfulTarget: Int {
        guard
            let store = parentStore,
            let plan  = store.userPlans.first(where: { $0.userId == currentUserId })
        else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    // MARK: - Query Helpers
    func sessions(for date: Date) -> [MindfulSession] {
        return mindfulSessions.filter {
            $0.userId == currentUserId &&
            Calendar.current.isDate($0.sessionDate, inSameDayAs: date)
        }
    }

    func mindfulMinutes(for date: Date) -> Int {
        sessions(for: date).reduce(0) { $0 + $1.minutesCompleted }
    }

    func todaysMindfulMinutes() -> Int { mindfulMinutes(for: .now) }

    func weeklyMindfulMinutes() -> [Int] {
        let cal = Calendar.current
        return (0..<7).map { daysAgo -> Int in
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: .now) else { return 0 }
            return mindfulMinutes(for: day)
        }.reversed()
    }

    func getContentItems(for categoryId: UUID) -> [MindEaseCategoryContent] {
        mindEaseCategoryContents.filter { $0.categoryId == categoryId }
    }

    // OPTIMIZED LOOKUPS: One private helper to find the model once
    private func contentForSession(_ session: MindfulSession) -> MindEaseCategoryContent? {
        mindEaseCategoryContents.first { $0.id == session.contentId }
    }

    func sessionIcon(for session: MindfulSession) -> String {
        guard let content = contentForSession(session),
              let category = mindEaseCategories.first(where: { $0.id == content.categoryId })
        else { return "brain.head.profile" }
        return category.cardIconName
    }

    func contentTitle(for session: MindfulSession) -> String {
        contentForSession(session)?.title ?? "Session"
    }

    func categoryName(for session: MindfulSession) -> String {
        guard let content = contentForSession(session),
              let category = mindEaseCategories.first(where: { $0.id == content.categoryId })
        else { return "MindEase" }
        return category.title
    }

    // MARK: - Private Plan Update Helper
    private func updatePlanAndPlayback(contentId: UUID, minutesCompleted: Int) {
        if let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) {
            todaysPlans[idx].minutesCompleted = minutesCompleted
            todaysPlans[idx].isCompleted       = minutesCompleted >= todaysPlans[idx].minutesTarget
        }

        if let idx = mindEaseCategoryContents.firstIndex(where: { $0.id == contentId }) {
            mindEaseCategoryContents[idx].lastPlaybackSeconds = minutesCompleted * 60
        }
    }

    // MARK: - User Actions
    func startSession(contentId: UUID) {
        sessionStartTimes[contentId] = .now
    }

    func completeSession(contentId: UUID, minutesCompleted: Int) -> ActionResult {
        guard minutesCompleted > 0 else {
            return .blocked(reason: "Session too short to log (< 1 minute).")
        }

        let now       = Date.now
        let startTime = sessionStartTimes[contentId] ?? Calendar.current.date(
            byAdding: .minute, value: -minutesCompleted, to: now)!
        sessionStartTimes.removeValue(forKey: contentId)

        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId,
            contentId: contentId, sessionDate: now,
            minutesCompleted: minutesCompleted,
            startTime: startTime, endTime: now
        ))

        updatePlanAndPlayback(contentId: contentId, minutesCompleted: minutesCompleted)

        let target = todaysPlans.first(where: {
            $0.userId == currentUserId && $0.contentId == contentId
        })?.minutesTarget ?? minutesCompleted

        return minutesCompleted >= target
            ? .success(message: "Session complete! \(minutesCompleted) min logged.")
            : .warning(message: "Session logged — \(minutesCompleted)/\(target) min completed.")
    }

    func logMindfulSession(contentId: UUID, minutesCompleted: Int) {
        guard minutesCompleted > 0 else { return }
        let now = Date.now
        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId, contentId: contentId,
            sessionDate: now, minutesCompleted: minutesCompleted,
            startTime: Calendar.current.date(byAdding: .minute, value: -minutesCompleted, to: now)!,
            endTime: now
        ))
        updatePlanAndPlayback(contentId: contentId, minutesCompleted: minutesCompleted)
    }
}

// MARK: - Shared Colours
extension Color {
    static let mindEasePurple = Color(red: 0.40, green: 0.30, blue: 0.85)
}

// MARK: - Shared Time Helpers
extension Date {
    func mindEaseFormatted(_ format: String) -> String {
        return self.formatted(.dateTime.hour().minute())
    }
}

// MARK: - ViewModifiers
struct MindEaseCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 18
    var shadowRadius: CGFloat = 10
    var shadowY: CGFloat = 4

    func body(content: Content) -> some View {
        content
            .background(.background) // Modern: Use system background directly
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: shadowRadius, x: 0, y: shadowY)
    }
}

extension View {
    func mindEaseCard(cornerRadius: CGFloat = 18,
                      shadowRadius: CGFloat = 10,
                      shadowY: CGFloat = 4) -> some View {
        modifier(MindEaseCardStyle(cornerRadius: cornerRadius,
                                   shadowRadius: shadowRadius,
                                   shadowY: shadowY))
    }
}

extension MindEaseCategoryContent {
    var mediaIcon: String { mediaType == "audio" ? "waveform" : "play.fill" }

    var titleHue: Double {
        let hash = title.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        return Double(abs(hash) % 360) / 360.0
    }

    var heroGradientColors: [Color] {
        [
            Color(hue: titleHue, saturation: 0.65, brightness: 0.72),
            Color(hue: (titleHue + 0.14).truncatingRemainder(dividingBy: 1),
                  saturation: 0.50, brightness: 0.48),
        ]
    }

    var rowGradientColors: [Color] {
        [
            Color(hue: titleHue, saturation: 0.50, brightness: 0.65),
            Color(hue: (titleHue + 0.07).truncatingRemainder(dividingBy: 1),
                  saturation: 0.40, brightness: 0.50),
        ]
    }
}

struct MindEaseSectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .bold))
            .padding(.horizontal, 20)
            .scrollTransition(.animated) { c, p in
                c.opacity(p.isIdentity ? 1 : 0)
                 .offset(x: p.isIdentity ? 0 : -20)
            }
    }
}

extension View {
    func mindEaseSectionHeader() -> some View {
        modifier(MindEaseSectionHeaderStyle())
    }
}

struct MindEaseStatValue: ViewModifier {
    var size: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .bold))
            .foregroundColor(.mindEasePurple)
    }
}

extension View {
    func mindEaseStatValue(size: CGFloat = 28) -> some View {
        modifier(MindEaseStatValue(size: size))
    }
}

struct MindEasePageBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.hcCream.ignoresSafeArea())
    }
}

extension View {
    func mindEasePageBackground() -> some View {
        modifier(MindEasePageBackground())
    }
}
