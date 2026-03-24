//
//  MindEaseDataStore.swift
//  HairCureTesting1
//
//  Separated MindEase data store — owns mindEaseCategories, mindEaseCategoryContents,
//  mindfulSessions, todaysPlans, sessionStartTimes, all seed data, helpers, and user actions.
//

import Foundation
import Observation

@Observable
class MindEaseDataStore {

    // MARK: - Properties

    var mindEaseCategories: [MindEaseCategory] = []
    var mindEaseCategoryContents: [MindEaseCategoryContent] = []
    var mindfulSessions: [MindfulSession] = []
    var todaysPlans: [TodaysPlan] = []
    var sessionStartTimes: [UUID: Date] = [:]

    // Shared references
    var currentUserId: UUID

    // Reference back to parent for plan access
    weak var parentStore: AppDataStore?

    // MARK: - Init

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
    }

    func seedAll(userId: UUID, userPlans: [UserPlan]) {
        seedMindEaseContent()
        seedTodaysPlan(userId: userId, userPlans: userPlans)
        seedHistoricalMindfulData(userId: userId, userPlans: userPlans)
    }

    // ─────────────────────────────────────────────
    // MARK: - Seed MindEase Content
    // ─────────────────────────────────────────────

    func seedMindEaseContent() {
        let yoga = MindEaseCategory(id: UUID(), title: "Yoga",
            categoryDescription: "Gentle poses to strengthen body and reduce hair fall",
            bannerImageURL: "yoga_banner", cardImageUrl: "yoga",
            cardIconName: "figure.yoga",
            bannerTagline: "Move. Breathe. Restore.")

        let meditation = MindEaseCategory(id: UUID(), title: "Meditation",
            categoryDescription: "Mindful practices to reduce cortisol and support hair health",
            bannerImageURL: "meditation_banner", cardImageUrl: "meditation_card",
            cardIconName: "brain.head.profile",
            bannerTagline: "Calm your mind. Grow your hair.")

        let sounds = MindEaseCategory(id: UUID(), title: "Relaxing Sounds",
            categoryDescription: "Soothing sounds to help you relax and unwind",
            bannerImageURL: "sounds_banner", cardImageUrl: "sounds_card",
            cardIconName: "waveform",
            bannerTagline: "Sound heals.")

        mindEaseCategories = [yoga, meditation, sounds]

        // Yoga sessions
        [("Balayam Yoga",         "Nail rubbing — stimulates hair follicles directly",    600,  "beginner"),
         ("Adho Mukha Svanasana", "Downward dog — increases blood flow to scalp",         900,  "beginner"),
         ("Sarvangasana",         "Shoulder stand — improves circulation to head",        1200, "intermediate"),
         ("Uttanasana",           "Forward bend — relieves stress and refreshes scalp",   600,  "beginner"),
         ("Vajrasana",            "Diamond pose — aids digestion and nutrient absorption", 900, "beginner")
        ].enumerated().forEach { i, s in
            mindEaseCategoryContents.append(MindEaseCategoryContent(
                id: UUID(), categoryId: yoga.id,
                title: s.0, contentDescription: s.1,
                mediaURL: "yoga_\(i+1).mp4", mediaType: "video",
                durationSeconds: s.2, difficultyLevel: s.3,
                thumbnailImageURL: "yoga_thumb_\(i+1)",
                caption: "\(s.2/60) min · \(s.3.capitalized)",
                orderIndex: i+1, lastPlaybackSeconds: 0))
        }

        // Meditation sessions
        [("Bhramari Pranayama",  "Humming bee breath  reduces stress hormones rapidly",   600,  "beginner"),
         ("Anulom Vilom",        "Alternate nostril breathing  balances nervous system",   900,  "beginner"),
         ("Body Scan Meditation","Full body relaxation  releases physical tension",        1200, "beginner"),
         ("Guided Visualisation","Positive imagery  reduces cortisol",                    900,  "intermediate"),
         ("Kapalbhati",          "Cleansing breath  detoxifies and energises",            600,  "intermediate")
        ].enumerated().forEach { i, s in
            mindEaseCategoryContents.append(MindEaseCategoryContent(
                id: UUID(), categoryId: meditation.id,
                title: s.0, contentDescription: s.1,
                mediaURL: "meditation_\(i+1).mp4", mediaType: "video",
                durationSeconds: s.2, difficultyLevel: s.3,
                thumbnailImageURL: "meditation_thumb_\(i+1)",
                caption: "\(s.2/60) min · \(s.3.capitalized)",
                orderIndex: i+1, lastPlaybackSeconds: 0))
        }

        // Relaxation sounds
        [("Forest Rain",       "Gentle forest rainfall  promotes deep relaxation",  1200),
         ("Ocean Waves",       "Rhythmic ocean waves  calms the nervous system",    1800),
         ("Mountain Stream",   "Flowing stream  clears mental fog",                  900),
         ("Deep Sleep Music",  "432Hz binaural tones  improves sleep quality",      3600),
         ("Evening Wind Down", "Soft wind chimes  ideal before sleep",              1200)
        ].enumerated().forEach { i, s in
            mindEaseCategoryContents.append(MindEaseCategoryContent(
                id: UUID(), categoryId: sounds.id,
                title: s.0, contentDescription: s.1,
                mediaURL: "sound_\(i+1).mp3", mediaType: "audio",
                durationSeconds: s.2, difficultyLevel: "beginner",
                thumbnailImageURL: "sound_thumb_\(i+1)",
                caption: "\(s.2/60) min · Relaxation",
                orderIndex: i+1, lastPlaybackSeconds: 0))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: - Seed Today's Plan
    // ─────────────────────────────────────────────

    func seedTodaysPlan(userId: UUID, userPlans: [UserPlan]) {
        guard let plan = userPlans.first(where: { $0.userId == userId }) else { return }
        let today = Date()

        // ── Meditation ──
        if let cat = mindEaseCategories.first(where: { $0.title == "Meditation" }),
           let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
            todaysPlans.append(TodaysPlan(
                id: UUID(), userId: userId, planDate: today,
                contentId: session.id, categoryId: cat.id, planId: plan.planId,
                minutesTarget: plan.meditationMinutesPerDay,
                minutesCompleted: 0, orderIndex: 1, isCompleted: false))
        }

        if let cat = mindEaseCategories.first(where: { $0.title == "Meditation" }) {
            let sessions = mindEaseCategoryContents.filter { $0.categoryId == cat.id }
            if sessions.count >= 2 {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: sessions[1].id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: 15,
                    minutesCompleted: 0, orderIndex: 2, isCompleted: false))
            }
        }

        // ── Yoga ──
        if let cat = mindEaseCategories.first(where: { $0.title == "Yoga" }),
           let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
            todaysPlans.append(TodaysPlan(
                id: UUID(), userId: userId, planDate: today,
                contentId: session.id, categoryId: cat.id, planId: plan.planId,
                minutesTarget: plan.yogaMinutesPerDay,
                minutesCompleted: 0, orderIndex: 3, isCompleted: false))
        }

        if let cat = mindEaseCategories.first(where: { $0.title == "Yoga" }) {
            let sessions = mindEaseCategoryContents.filter { $0.categoryId == cat.id }
            if sessions.count >= 2 {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: sessions[1].id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: 15,
                    minutesCompleted: 0, orderIndex: 4, isCompleted: false))
            }
        }

        if let cat = mindEaseCategories.first(where: { $0.title == "Yoga" }) {
            let sessions = mindEaseCategoryContents.filter { $0.categoryId == cat.id }
            if sessions.count >= 4 {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: sessions[3].id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: 10,
                    minutesCompleted: 0, orderIndex: 5, isCompleted: false))
            }
        }

        // ── Relaxing Sounds ──
        if let cat = mindEaseCategories.first(where: { $0.title == "Relaxing Sounds" }),
           let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
            todaysPlans.append(TodaysPlan(
                id: UUID(), userId: userId, planDate: today,
                contentId: session.id, categoryId: cat.id, planId: plan.planId,
                minutesTarget: plan.soundMinutesPerDay,
                minutesCompleted: 0, orderIndex: 6, isCompleted: false))
        }

        if let cat = mindEaseCategories.first(where: { $0.title == "Relaxing Sounds" }) {
            let sessions = mindEaseCategoryContents.filter { $0.categoryId == cat.id }
            if sessions.count >= 2 {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: sessions[1].id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: 10,
                    minutesCompleted: 0, orderIndex: 7, isCompleted: false))
            }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: - Seed Historical Mindful Data
    // ─────────────────────────────────────────────

    func seedHistoricalMindfulData(userId: UUID, userPlans: [UserPlan]) {
        guard let firstContent = mindEaseCategoryContents.first else { return }
        let cal    = Calendar.current
        let raw    = Double(dailyMindfulTarget(userPlans: userPlans))
        let target = min(60.0, max(15.0, raw))

        let dayData: [(Int, Double)] = [
            (1, 1.00),
            (2, 0.80),
            (3, 0.95),
            (4, 0.00),
            (5, 0.70),
            (6, 0.90)
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
                id: UUID(), userId: userId, contentId: firstContent.id,
                sessionDate: dayStart, minutesCompleted: minutes,
                startTime: startTime, endTime: endTime
            ))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: - Convenience Helpers
    // ─────────────────────────────────────────────

    func mindfulMinutes(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindfulSessions
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    /// Computed daily target using parent store's userPlans
    var dailyMindfulTarget: Int {
        guard let store = parentStore,
              let plan = store.userPlans.first(where: { $0.userId == currentUserId }) else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    /// Overload for seed functions that don't have parent store yet
    func dailyMindfulTarget(userPlans: [UserPlan]) -> Int {
        guard let plan = userPlans.first(where: { $0.userId == currentUserId }) else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    func logMindfulSession(contentId: UUID, minutesCompleted: Int) {
        let now = Date()
        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId, contentId: contentId,
            sessionDate: now, minutesCompleted: minutesCompleted,
            startTime: Calendar.current.date(byAdding: .minute,
                value: -minutesCompleted, to: now)!,
            endTime: now
        ))
        if let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId && $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) {
            todaysPlans[idx].minutesCompleted = minutesCompleted
            todaysPlans[idx].isCompleted = minutesCompleted >= todaysPlans[idx].minutesTarget
        }
    }

    // ─────────────────────────────────────────────
    // MARK: - User Actions
    // ─────────────────────────────────────────────

    func startSession(contentId: UUID) {
        sessionStartTimes[contentId] = Date()
    }

    @discardableResult
    func completeSession(contentId: UUID, minutesCompleted: Int) -> ActionResult {

        guard minutesCompleted > 0 else {
            return .blocked(reason: "Session too short to log (< 1 minute).")
        }

        let startTime = sessionStartTimes[contentId] ?? Calendar.current.date(
            byAdding: .minute, value: -minutesCompleted, to: Date()
        )!
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

        if minutesCompleted >= target {
            return .success(message: " Session complete! \(minutesCompleted) min logged.")
        } else {
            return .warning(message: "Session logged — \(minutesCompleted)/\(target) min completed.")
        }
    }

    func todaysMindfulMinutes() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return mindfulSessions
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == today
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    func weeklyMindfulMinutes() -> [Int] {
        let cal = Calendar.current
        return (0..<7).map { daysAgo in
            let day = cal.startOfDay(for: cal.date(byAdding: .day, value: -daysAgo, to: Date())!)
            return mindfulSessions
                .filter {
                    $0.userId == currentUserId &&
                    cal.startOfDay(for: $0.sessionDate) == day
                }
                .reduce(0) { $0 + $1.minutesCompleted }
        }.reversed()
    }
}
