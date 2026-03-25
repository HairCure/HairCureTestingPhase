//
//  MindEaseDataStore.swift
//
//  Modelled after RestaurantStore — UUIDs declared once at the top,
//  seed data assigned in init(), helper methods match what every view calls.


import Foundation
import Observation

// ── Stable category UUIDs (declared once, referenced everywhere) ─────────────
private let yogaID:       UUID = UUID()
private let meditationID: UUID = UUID()
private let soundsID:     UUID = UUID()

// ── Stable content UUIDs — Yoga ──────────────────────────────────────────────
private let uttanasanaID:    UUID = UUID()
private let mukhaID:         UUID = UUID()
private let shirshasanaID:   UUID = UUID()
private let balayamID:       UUID = UUID()
private let vajrasanaID:     UUID = UUID()

// ── Stable content UUIDs — Meditation ────────────────────────────────────────
private let bhramariID:      UUID = UUID()
private let anulomID:        UUID = UUID()
private let kapalbhatiID:    UUID = UUID()
private let bodyScanID:      UUID = UUID()
private let guidedVisID:     UUID = UUID()

// ── Stable content UUIDs — Relaxing Sounds ───────────────────────────────────
private let oceanWavesID:    UUID = UUID()
private let forestBreezeID:  UUID = UUID()
private let birdSongsID:     UUID = UUID()
private let deepSleepID:     UUID = UUID()
private let eveningWindID:   UUID = UUID()

// MARK: - MindEaseDataStore

@Observable
class MindEaseDataStore {

    // MARK: State

    var mindEaseCategories:       [MindEaseCategory]        = []
    var mindEaseCategoryContents: [MindEaseCategoryContent] = []
    var mindfulSessions:          [MindfulSession]          = []
    var todaysPlans:              [TodaysPlan]              = []
    var sessionStartTimes:        [UUID: Date]              = [:]

    // MARK: Shared

    var currentUserId: UUID
    weak var parentStore: AppDataStore?

    // MARK: Init  ← same pattern as RestaurantStore

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId

        // ── Categories ───────────────────────────────────────────────────────
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

        // ── Content items ────────────────────────────────────────────────────
        mindEaseCategoryContents = [

            // ── Yoga ─────────────────────────────────────────────────────────
            MindEaseCategoryContent(
                id: uttanasanaID, categoryId: yogaID,
                title: "Uttanasana", contentDescription: "Forward bend — relieves stress and refreshes scalp",
                caption: "Forward Fold",
                mediaURL: "yoga_1.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "uttanasana",
                orderIndex: 1, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: mukhaID, categoryId: yogaID,
                title: "Mukha Svanasana", contentDescription: "Downward dog — increases blood flow to scalp",
                caption: "Downward Facing Dog",
                mediaURL: "yoga_2.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "ardh",
                orderIndex: 2, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: shirshasanaID, categoryId: yogaID,
                title: "Shirshasana", contentDescription: "Headstand — boosts circulation to hair follicles",
                caption: "Headstand",
                mediaURL: "yoga_3.mp4", mediaType: "video",
                durationSeconds: 90, difficultyLevel: "intermediate",
                imageurl: "shirshasana",
                orderIndex: 3, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: balayamID, categoryId: yogaID,
                title: "Uttanasana", contentDescription: "Downward Fold — stimulates hair follicles directly",
                caption: "Downward Fold",
                mediaURL: "yoga_4.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "beginner",
                imageurl: "uttanasana",
                orderIndex: 4, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: vajrasanaID, categoryId: yogaID,
                title: "Vajrasana", contentDescription: "Diamond pose — aids digestion and nutrient absorption",
                caption: "Diamond Pose",
                mediaURL: "yoga_5.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana",
                orderIndex: 5, lastPlaybackSeconds: 0
            ),

            // ── Meditation ────────────────────────────────────────────────────
            MindEaseCategoryContent(
                id: bhramariID, categoryId: meditationID,
                title: "Bhramari", contentDescription: "Humming bee breath — reduces stress hormones rapidly",
                caption: "Humming Bee Breath",
                mediaURL: "meditation_1.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "beginner",
                imageurl: "yoga",
                orderIndex: 1, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: anulomID, categoryId: meditationID,
                title: "Anulom Vilom", contentDescription: "Alternate nostril breathing — balances the nervous system",
                caption: "Alternate Nostril Breathing",
                mediaURL: "meditation_2.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana",
                orderIndex: 2, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: kapalbhatiID, categoryId: meditationID,
                title: "Kapalbhati", contentDescription: "Cleansing breath — detoxifies and energises",
                caption: "Skull Shining Breath",
                mediaURL: "meditation_3.mp4", mediaType: "video",
                durationSeconds: 600, difficultyLevel: "intermediate",
                imageurl: "shirshasana",
                orderIndex: 3, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: bodyScanID, categoryId: meditationID,
                title: "Body Scan Meditation", contentDescription: "Full body relaxation — releases physical tension",
                caption: "Full Body Relaxation",
                mediaURL: "meditation_4.mp4", mediaType: "video",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "body_scan_list",
                orderIndex: 4, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: guidedVisID, categoryId: meditationID,
                title: "Guided Visualisation", contentDescription: "Positive imagery — reduces cortisol levels",
                caption: "Positive Imagery",
                mediaURL: "meditation_5.mp4", mediaType: "video",
                durationSeconds: 900, difficultyLevel: "intermediate",
                imageurl: "guided_vis_list",
                orderIndex: 5, lastPlaybackSeconds: 0
            ),

            // ── Relaxing Sounds ───────────────────────────────────────────────
            MindEaseCategoryContent(
                id: oceanWavesID, categoryId: soundsID,
                title: "Ocean Waves", contentDescription: "Rhythmic ocean waves — calms the nervous system",
                caption: "Soft ocean rhythms for deep calm",
                mediaURL: "sound_1.mp3", mediaType: "audio",
                durationSeconds: 1800, difficultyLevel: "beginner",
                imageurl: "ocean",
                orderIndex: 1, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: forestBreezeID, categoryId: soundsID,
                title: "Forest Breeze", contentDescription: "Gentle forest breeze — promotes deep relaxation",
                caption: "Feel the calm of nature in every breath",
                mediaURL: "sound_2.mp3", mediaType: "audio",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "forest",
                orderIndex: 2, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: birdSongsID, categoryId: soundsID,
                title: "Bird Songs", contentDescription: "Morning birdsong — clears mental fog",
                caption: "Wake your senses with soothing bird sounds",
                mediaURL: "sound_3.mp3", mediaType: "audio",
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "bird",
                orderIndex: 3, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: deepSleepID, categoryId: soundsID,
                title: "Deep Sleep Music", contentDescription: "432 Hz binaural tones — improves sleep quality",
                caption: "432 Hz binaural tones for better sleep",
                mediaURL: "sound_4.mp3", mediaType: "audio",
                durationSeconds: 3600, difficultyLevel: "beginner",
                imageurl: "deep_sleep_list",
                orderIndex: 4, lastPlaybackSeconds: 0
            ),
            MindEaseCategoryContent(
                id: eveningWindID, categoryId: soundsID,
                title: "Evening Wind Down", contentDescription: "Soft wind chimes — perfect for winding down",
                caption: "Soft wind chimes ideal before sleep",
                mediaURL: "sound_5.mp3", mediaType: "audio",
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "evening_wind_list",
                orderIndex: 5, lastPlaybackSeconds: 0
            ),
        ]
    }

    // MARK: - Seed (called after AppDataStore is ready)

    func seedAll(userId: UUID, userPlans: [UserPlan]) {
        seedTodaysPlan(userId: userId, userPlans: userPlans)
        seedHistoricalMindfulData(userId: userId, userPlans: userPlans)
    }

    // ── Today's Plan ──────────────────────────────────────────────────────────

    private func seedTodaysPlan(userId: UUID, userPlans: [UserPlan]) {
        guard let plan = userPlans.first(where: { $0.userId == userId }) else { return }
        let today = Date()

        // (contentId, categoryId, minutesTarget, orderIndex)
        let entries: [(UUID, UUID, Int, Int)] = [
            (bhramariID,    meditationID, plan.meditationMinutesPerDay, 1),
            (anulomID,      meditationID, 15,                           2),
            (uttanasanaID,  yogaID,       plan.yogaMinutesPerDay,       3),
            (mukhaID,       yogaID,       15,                           4),
            (balayamID,     yogaID,       10,                           5),
            (oceanWavesID,  soundsID,     plan.soundMinutesPerDay,      6),
            (forestBreezeID,soundsID,     10,                           7),
        ]

        todaysPlans = entries.map { (contentId, categoryId, target, order) in
            TodaysPlan(
                id: UUID(), userId: userId, planDate: today,
                contentId: contentId, categoryId: categoryId,
                planId: plan.planId,
                minutesTarget: target, minutesCompleted: 0,
                orderIndex: order, isCompleted: false
            )
        }
    }

    // ── Historical data (ring calendar fill) ─────────────────────────────────

    private func seedHistoricalMindfulData(userId: UUID, userPlans: [UserPlan]) {
        let cal    = Calendar.current
        let raw    = Double(dailyMindfulTarget(userPlans: userPlans))
        let target = min(60.0, max(15.0, raw))

        // (daysAgo, fractionOfDailyTarget)
        let dayData: [(Int, Double)] = [
            (1, 1.00), (2, 0.80), (3, 0.95),
            (4, 0.00), (5, 0.70), (6, 0.90),
        ]

        for (daysAgo, fraction) in dayData {
            guard fraction > 0,
                  let pastDate = cal.date(byAdding: .day, value: -daysAgo, to: Date())
            else { continue }

            let dayStart  = cal.startOfDay(for: pastDate)
            let startTime = cal.date(byAdding: .hour, value: 7, to: dayStart) ?? dayStart
            let minutes   = Int((target * fraction).rounded())
            let endTime   = cal.date(byAdding: .minute, value: minutes, to: startTime) ?? startTime

            mindfulSessions.append(MindfulSession(
                id: UUID(), userId: userId,
                contentId: bhramariID,          // any stable contentId is fine here
                sessionDate: dayStart, minutesCompleted: minutes,
                startTime: startTime, endTime: endTime
            ))
        }
    }

    // MARK: - Computed Daily Target

    /// Live target — reads from parent store (used by views)
    var dailyMindfulTarget: Int {
        guard
            let store = parentStore,
            let plan  = store.userPlans.first(where: { $0.userId == currentUserId })
        else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    /// Overload used during seeding (parent not yet wired up)
    func dailyMindfulTarget(userPlans: [UserPlan]) -> Int {
        guard let plan = userPlans.first(where: { $0.userId == currentUserId }) else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    // MARK: - Helpers  (same signatures all views depend on)

    func mindfulMinutes(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindfulSessions
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    func getContentItems(for categoryId: UUID) -> [MindEaseCategoryContent] {
        mindEaseCategoryContents
            .filter { $0.categoryId == categoryId }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    func todaysMindfulMinutes() -> Int { mindfulMinutes(for: Date()) }

    func weeklyMindfulMinutes() -> [Int] {
        let cal = Calendar.current
        return (0..<7).map { daysAgo -> Int in
            let day = cal.startOfDay(for: cal.date(byAdding: .day, value: -daysAgo, to: Date())!)
            return mindfulSessions
                .filter {
                    $0.userId == currentUserId &&
                    cal.startOfDay(for: $0.sessionDate) == day
                }
                .reduce(0) { $0 + $1.minutesCompleted }
        }.reversed()
    }

    // MARK: - User Actions

    func startSession(contentId: UUID) {
        sessionStartTimes[contentId] = Date()
    }

    @discardableResult
    func completeSession(contentId: UUID, minutesCompleted: Int) -> ActionResult {
        guard minutesCompleted > 0 else {
            return .blocked(reason: "Session too short to log (< 1 minute).")
        }

        let startTime = sessionStartTimes[contentId] ?? Calendar.current.date(
            byAdding: .minute, value: -minutesCompleted, to: Date())!
        sessionStartTimes.removeValue(forKey: contentId)

        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId,
            contentId: contentId, sessionDate: Date(),
            minutesCompleted: minutesCompleted,
            startTime: startTime, endTime: Date()
        ))

        if let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) {
            todaysPlans[idx].minutesCompleted = minutesCompleted
            todaysPlans[idx].isCompleted = minutesCompleted >= todaysPlans[idx].minutesTarget
        }

        if let idx = mindEaseCategoryContents.firstIndex(where: { $0.id == contentId }) {
            mindEaseCategoryContents[idx].lastPlaybackSeconds = minutesCompleted * 60
        }

        let target = todaysPlans.first(where: {
            $0.userId == currentUserId && $0.contentId == contentId
        })?.minutesTarget ?? minutesCompleted

        return minutesCompleted >= target
            ? .success(message: "Session complete! \(minutesCompleted) min logged.")
            : .warning(message: "Session logged — \(minutesCompleted)/\(target) min completed.")
    }

    func logMindfulSession(contentId: UUID, minutesCompleted: Int) {
        let now = Date()
        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId, contentId: contentId,
            sessionDate: now, minutesCompleted: minutesCompleted,
            startTime: Calendar.current.date(byAdding: .minute, value: -minutesCompleted, to: now)!,
            endTime: now
        ))
        if let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) {
            todaysPlans[idx].minutesCompleted = minutesCompleted
            todaysPlans[idx].isCompleted = minutesCompleted >= todaysPlans[idx].minutesTarget
        }
    }
}
