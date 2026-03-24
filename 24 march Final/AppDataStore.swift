//
//  AppDataStore.swift
//  HairCure
//
//  Mock data store — Arjun, 22 years old, Stage 2, Poor lifestyle → Plan 2A.
//  Assessment answers and scalp scan data are NOT pre-populated here.
//  They are created live when the user taps through the assessment flow.
//  The engine then reads those live answers and writes the plan.
//
//  Hair-Insights data (HairInsight, CareTip, HomeRemedy, DailyTip, UserFavorite)
//  has been moved to HairInsightsDataStore.swift.
//  Access it via store.hairInsightsStore or inject it separately into the environment.
//
//  DietMate data (foods, mealEntries, mealFoods) has been moved to DietmateDataStore.swift.
//  Access it via store.dietMateStore or inject it separately into the environment.
//
//  MindEase data (mindEaseCategories, mindEaseCategoryContents, mindfulSessions, todaysPlans)
//  has been moved to MindEaseDataStore.swift.
//  Access it via store.mindEaseStore or inject it separately into the environment.
//
//  To swap to backend later: replace @Observable arrays with API calls,
//  keep all engine logic in RecommendationEngine.swift untouched.
//

import Foundation
import Observation

@Observable
class AppDataStore {

    // MARK: - Core User
    var users: [User] = []
    var userProfiles: [UserProfile] = []
    var currentUserId: UUID = UUID()

    // MARK: - Assessment (answers created live in app, not pre-populated)
    var assessments: [Assessment] = []
    var questions: [Question] = []
    var questionOptions: [QuestionOption] = []
    var questionScoreMaps: [QuestionScoreMap] = []
    var userAnswers: [UserAnswer] = []

    // MARK: - Scalp Scan (done in app, not pre-populated)
    var scalpScans: [ScalpScan] = []
    var scanReports: [ScanReport] = []

    // MARK: - Engine Output (pre-populated for Arjun mock)
    var userPlans: [UserPlan] = []
    var userNutritionProfiles: [UserNutritionProfile] = []

    // MARK: - Trackers
    var sleepRecords: [SleepRecord] = []
    var waterIntakeLogs: [WaterIntakeLog] = []

    // MARK: - Hair Insights (delegated to HairInsightsDataStore)
    private(set) var hairInsightsStore: HairInsightsDataStore = HairInsightsDataStore(currentUserId: UUID())

    // MARK: - DietMate (delegated to DietmateDataStore)
    private(set) var dietMateStore: DietmateDataStore = DietmateDataStore(currentUserId: UUID())

    // MARK: - MindEase (delegated to MindEaseDataStore)
    private(set) var mindEaseStore: MindEaseDataStore = MindEaseDataStore(currentUserId: UUID())

    // MARK: - Settings
    var appPreferences: [AppPreferences] = []
    var notificationSettings: [NotificationSettings] = []

    // MARK: - Init

    init() {
        setupArjunMockData()
    }

    private func setupArjunMockData() {
        let userId = UUID()
        currentUserId = userId
        seedUser(userId: userId)
        seedUserProfile(userId: userId)
        seedQuestions()
        seedEngineOutput(userId: userId)
        seedSleepAndWater(userId: userId)
        seedSettings(userId: userId)

        // Hair-Insights data lives in its own store
        hairInsightsStore = HairInsightsDataStore(currentUserId: userId)

        // DietMate data lives in its own store
        dietMateStore = DietmateDataStore(currentUserId: userId)
        dietMateStore.parentStore = self
        let np = userNutritionProfiles.first(where: { $0.userId == userId })
        dietMateStore.seedAll(userId: userId, nutritionProfile: np)

        // MindEase data lives in its own store
        mindEaseStore = MindEaseDataStore(currentUserId: userId)
        mindEaseStore.parentStore = self
        mindEaseStore.seedAll(userId: userId, userPlans: userPlans)
    }

    // ─────────────────────────────────────────────
    // MARK: 1 — User & Profile
    // ─────────────────────────────────────────────

    private func seedUser(userId: UUID) {
        users.append(User(
            id: userId,
            name: "User",
            email: "user123@gmail.com",
            phoneNumber: "9999999999",
            authProvider: .google,
            createdAt: Date()
        ))
    }

    private func seedUserProfile(userId: UUID) {
        let dob = Calendar.current.date(byAdding: .year, value: -22, to: Date())!
        userProfiles.append(UserProfile(
            id: UUID(),
            userId: userId,
            username: "user22",
            displayName: "User",
            dateOfBirth: dob,
            gender: "male",
            heightCm: 175,
            weightKg: 70,
            hairType: "straight",
            scalpType: "dry",
            isVegetarian: false,
            profileImageURL: nil,
            isProfileComplete: true,
            joinedAt: Date()
        ))
    }

    // ─────────────────────────────────────────────
    // MARK: 2 — Questions (all 11 + 3 fallback)
    //           Answers NOT seeded — created live in app
    // ─────────────────────────────────────────────

    private func seedQuestions() {

        // Q1 — Hair fall duration
        let q1 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How long have you been experiencing hair fall?",
            questionOrderIndex: 1, scoreDimension: .none)
        questions.append(q1)
        let q1Opts = ["Just started", "1–3 months", "3–6 months", "More than 6 months"]
        q1Opts.enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q1.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // Q2 — Daily hair fall amount
        let q2 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How much hair fall do you see daily?",
            questionOrderIndex: 2, scoreDimension: .none)
        questions.append(q2)
        ["Mild", "Moderate", "Heavy", "Not sure"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q2.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // Q3 — Scalp symptoms (multi-choice)
        let q3 = Question(id: UUID(), questionType: .multiChoice,
            questionText: "Do you have any scalp symptoms?",
            questionOrderIndex: 3, scoreDimension: .none)
        questions.append(q3)
        ["Itching", "Dryness", "Burning or inflammation", "Oily scalp", "None"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q3.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // Q4 — Sleep hours  (SCORED)
        let q4 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How many hours of sleep do you get each night?",
            questionOrderIndex: 4, scoreDimension: .sleep)
        questions.append(q4)
        let q4opts = [
            ("Less than 6 hours", Float(2.0)),
            ("6–7 hours",         Float(5.0)),
            ("7–8 hours",         Float(10.0)),
            ("More than 8 hours", Float(7.0))
        ]
        q4opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q4.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q4.id,
                optionId: opt.id, scoreDimension: .sleep, scoreValue: pair.1))
        }

        // Q5 — Stress level  (SCORED)
        let q5 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How stressed do you feel on most days?",
            questionOrderIndex: 5, scoreDimension: .stress)
        questions.append(q5)
        let q5opts = [
            ("Rarely",             Float(10.0)),
            ("Occasionally",       Float(7.0)),
            ("Most days",          Float(4.0)),
            ("Always  burnout",    Float(1.0))
        ]
        q5opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q5.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q5.id,
                optionId: opt.id, scoreDimension: .stress, scoreValue: pair.1))
        }

        // Q6 — Diet quality  (SCORED)
        let q6 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How would you describe your typical daily diet?",
            questionOrderIndex: 6, scoreDimension: .diet)
        questions.append(q6)
        let q6opts = [
            ("Very healthy, balanced meals", Float(10.0)),
            ("Fairly balanced",              Float(7.0)),
            ("Often junk  food",             Float(3.0)),
            ("Very poor ",                   Float(1.0))
        ]
        q6opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q6.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q6.id,
                optionId: opt.id, scoreDimension: .diet, scoreValue: pair.1))
        }

        // Q7 — Water intake  (SCORED — hydration)
        let q7 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How many glasses of water do you drink daily?",
            questionOrderIndex: 7, scoreDimension: .hydration)
        questions.append(q7)
        let q7opts = [
            ("Less than 3 glasses", Float(1.0)),
            ("3–5 glasses",         Float(4.0)),
            ("6–8 glasses",         Float(7.0)),
            ("More than 8 glasses", Float(10.0))
        ]
        q7opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q7.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q7.id,
                optionId: opt.id, scoreDimension: .hydration, scoreValue: pair.1))
        }

        // Q8 — Hair washing  (SCORED)
        let q8 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How often do you wash your hair?",
            questionOrderIndex: 8, scoreDimension: .hairCare)
        questions.append(q8)
        let q8opts = [
            ("Daily",               Float(4.0)),
            ("Every 2–3 days",      Float(10.0)),
            ("Every 4–5 days",      Float(7.0)),
            ("Once a week or less", Float(3.0))
        ]
        q8opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q8.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q8.id,
                optionId: opt.id, scoreDimension: .hairCare, scoreValue: pair.1))
        }

        // Q9 — Age (picker)
        questions.append(Question(id: UUID(), questionType: .picker,
            questionText: "What is your age?",
            questionOrderIndex: 9, scoreDimension: .none,
            pickerMin: 15, pickerMax: 35, pickerStep: 1, pickerUnit: "yrs",
            keyboardType: .number))

        // Q10 — Height (picker)
        questions.append(Question(id: UUID(), questionType: .picker,
            questionText: "What is your height?",
            questionOrderIndex: 10, scoreDimension: .none,
            pickerMin: 140, pickerMax: 220, pickerStep: 1, pickerUnit: "cm",
            keyboardType: .number))

        // Q11 — Weight (picker)
        questions.append(Question(id: UUID(), questionType: .picker,
            questionText: "What is your weight?",
            questionOrderIndex: 11, scoreDimension: .none,
            pickerMin: 40, pickerMax: 150, pickerStep: 0.5, pickerUnit: "kg",
            keyboardType: .decimal))

        // Q12 — Activity level (for TDEE)
        let q12 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How active are you on most days?",
            questionOrderIndex: 12, scoreDimension: .none)
        questions.append(q12)
        ["Sedentary (desk job, little movement)",
         "Light (walk or light exercise 1–3×/week)",
         "Moderate (exercise 3–5×/week)",
         "Very active (intense daily exercise)"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q12.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // FB1 — Fallback: self-select stage (imageChoice)
        let fb1 = Question(id: UUID(), questionType: .imageChoice,
            questionText: "Select your current hair fall stage",
            questionOrderIndex: 13, scoreDimension: .none)
        questions.append(fb1)
        let stageOpts = [
            ("Stage 1 — Slight thinning, hairline normal", "stage1_illustration"),
            ("Stage 2 — Noticeable thinning on top",       "stage2_illustration"),
            ("Stage 3 — Clear bald patch forming",          "stage3_illustration"),
            ("Stage 4 — Large bald area",                   "stage4_illustration")
        ]
        stageOpts.enumerated().forEach { i, pair in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb1.id,
                optionOrderIndex: i+1, optionText: pair.0,
                imageURL: pair.1, optionType: .image))
        }

        // FB2 — Fallback: scalp condition
        let fb2 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How does your scalp feel most of the time?",
            questionOrderIndex: 14, scoreDimension: .none)
        questions.append(fb2)
        ["Flaky / white flakes : Dandruff",
         "Tight, itchy, rough feel : Dry scalp",
         "Greasy by midday : Oily scalp",
         "Red or sore spots : Inflammation",
         "Feels normal : No issues"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb2.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // FB3 — Fallback: hair density
        let fb3 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How would you describe your hair thickness?",
            questionOrderIndex: 15, scoreDimension: .none)
        questions.append(fb3)
        ["Thick and full : no visible scalp",
         "Medium : slight scalp visible in light",
         "Thin : scalp clearly visible on top",
         "Very thin : significant scalp showing"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb3.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 3 — Engine Output (Plan 2A + Nutrition Profile)
    // ─────────────────────────────────────────────

    private func seedEngineOutput(userId: UUID) {
        let scanId = UUID()
        scalpScans.append(ScalpScan(
            id: scanId, userId: userId, scanDate: Date(),
            frontImageURL: "arjun_front.jpg", leftImageURL: "arjun_left.jpg",
            rightImageURL: "arjun_right.jpg", backImageURL: "arjun_back.jpg",
            topImageURL: "arjun_top.jpg", scanType: .initial
        ))

        let reportId = UUID()
        scanReports.append(ScanReport(
            id: reportId, createdAt: Date(),
            scalpScanId: scanId,
            hairDensityPercent: 52,
            hairDensityLevel: .low,
            hairFallStage: .stage2,
            scalpCondition: .dry,
            analysisSource: .aiModel,
            planId: "2A",
            lifestyleScore: 3.25,
            dietScore: 3.0,
            stressScore: 4.0,
            sleepScore: 2.0,
            hairCareScore: 4.0,
            recommendedPlan: "Aggressive nutrient plan + daily MindEase + structured hair care + weekly tracking"
        ))

        userPlans.append(UserPlan(
            id: UUID(), userId: userId, scanReportId: reportId,
            planId: "2A", stage: 2,
            lifestyleProfile: .poor,
            scalpModifier: .dry,
            meditationMinutesPerDay: 20,
            yogaMinutesPerDay: 45,
            soundMinutesPerDay: 15,
            sessionFrequencyPerWeek: 7,
            isActive: true,
            assignedAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        ))

        let tdee: Float = 2038
        userNutritionProfiles.append(UserNutritionProfile(
            id: UUID(), userId: userId,
            activityLevel: .sedentary,
            bmr: 1699, tdee: tdee,
            breakfastCalTarget: tdee * 0.25,
            lunchCalTarget:     tdee * 0.35,
            snackCalTarget:     tdee * 0.15,
            dinnerCalTarget:    tdee * 0.25,
            proteinTargetGm: 70,
            carbTargetGm: 255,
            fatTargetGm: 57,
            waterTargetML: 70 * 35,
            createdAt: Date(), updatedAt: Date()
        ))
    }

    // ─────────────────────────────────────────────
    // MARK: 8 — Sleep history & water log
    // ─────────────────────────────────────────────

    private func seedSleepAndWater(userId: UUID) {
        let cal = Calendar.current

        // ── Sleep Records — 14 days ──
        let sleepData: [(Int, Int, Int, Int, Int, Float)] = [
            (0,  23, 0,  0,  0,  0.0),
            (1,  23, 15, 6,  30, 7.25),
            (2,  0,  0,  5,  30, 5.5),
            (3,  22, 45, 6,  45, 8.0),
            (4,  1,  0,  6,  0,  5.0),
            (5,  23, 30, 7,  0,  7.5),
            (6,  22, 0,  6,  30, 8.5),
            (7,  0,  30, 6,  0,  5.5),
            (8,  23, 0,  7,  0,  8.0),
            (9,  23, 45, 6,  15, 6.5),
            (10, 22, 30, 6,  30, 8.0),
            (11, 1,  15, 5,  45, 4.5),
            (12, 23, 0,  7,  30, 8.5),
            (13, 0,  0,  6,  0,  6.0),
        ]

        for (daysAgo, bedH, bedM, wakeH, wakeM, hrs) in sleepData {
            guard let base  = cal.date(byAdding: .day, value: -daysAgo, to: Date()),
                  let bed   = cal.date(bySettingHour: bedH,  minute: bedM,  second: 0, of: base),
                  let wake  = cal.date(bySettingHour: wakeH, minute: wakeM, second: 0, of: base)
            else { continue }
            sleepRecords.append(SleepRecord(
                id: UUID(), userId: userId, date: cal.startOfDay(for: base),
                bedTime: bed, wakeTime: wake, alarmEnabled: true,
                alarmTime: wake, hoursSlept: hrs
            ))
        }

        // ── Water Intake Logs — 13 days history ──
        struct CupSeed { let size: String; let ml: Float; let hour: Int; let min: Int }

        let waterDays: [(Int, [CupSeed])] = [
            (1, [CupSeed(size:"large", ml:400,hour:7, min:30),
                 CupSeed(size:"medium",ml:250,hour:10,min:0),
                 CupSeed(size:"large", ml:400,hour:13,min:30),
                 CupSeed(size:"medium",ml:250,hour:15,min:0),
                 CupSeed(size:"medium",ml:250,hour:18,min:0),
                 CupSeed(size:"small", ml:150,hour:21,min:0)]),
            (2, [CupSeed(size:"medium",ml:250,hour:8, min:0),
                 CupSeed(size:"medium",ml:250,hour:12,min:0),
                 CupSeed(size:"small", ml:150,hour:17,min:0)]),
            (3, [CupSeed(size:"large", ml:400,hour:6, min:30),
                 CupSeed(size:"large", ml:400,hour:10,min:0),
                 CupSeed(size:"medium",ml:250,hour:13,min:0),
                 CupSeed(size:"large", ml:400,hour:16,min:30),
                 CupSeed(size:"medium",ml:250,hour:19,min:0),
                 CupSeed(size:"medium",ml:250,hour:21,min:30)]),
            (4, [CupSeed(size:"small", ml:150,hour:9, min:0),
                 CupSeed(size:"medium",ml:250,hour:14,min:0),
                 CupSeed(size:"small", ml:150,hour:18,min:0)]),
            (5, [CupSeed(size:"medium",ml:250,hour:7, min:0),
                 CupSeed(size:"large", ml:400,hour:11,min:0),
                 CupSeed(size:"medium",ml:250,hour:14,min:0),
                 CupSeed(size:"medium",ml:250,hour:17,min:30),
                 CupSeed(size:"large", ml:400,hour:20,min:0)]),
            (6, [CupSeed(size:"medium",ml:250,hour:8, min:0),
                 CupSeed(size:"medium",ml:250,hour:11,min:30),
                 CupSeed(size:"large", ml:400,hour:15,min:0),
                 CupSeed(size:"medium",ml:250,hour:19,min:0)]),
            (7, [CupSeed(size:"small", ml:150,hour:9, min:0),
                 CupSeed(size:"small", ml:150,hour:13,min:0),
                 CupSeed(size:"medium",ml:250,hour:20,min:0)]),
            (8, [CupSeed(size:"large", ml:400,hour:7, min:30),
                 CupSeed(size:"medium",ml:250,hour:10,min:30),
                 CupSeed(size:"large", ml:400,hour:14,min:0),
                 CupSeed(size:"medium",ml:250,hour:17,min:0),
                 CupSeed(size:"medium",ml:250,hour:20,min:30)]),
            (9, [CupSeed(size:"medium",ml:250,hour:8, min:30),
                 CupSeed(size:"medium",ml:250,hour:12,min:0),
                 CupSeed(size:"large", ml:400,hour:16,min:0),
                 CupSeed(size:"small", ml:150,hour:20,min:0)]),
            (10,[CupSeed(size:"large", ml:400,hour:6, min:0),
                 CupSeed(size:"large", ml:400,hour:10,min:0),
                 CupSeed(size:"medium",ml:250,hour:13,min:30),
                 CupSeed(size:"large", ml:400,hour:17,min:0),
                 CupSeed(size:"medium",ml:250,hour:20,min:0),
                 CupSeed(size:"medium",ml:250,hour:22,min:0)]),
            (11,[CupSeed(size:"small", ml:150,hour:10,min:0),
                 CupSeed(size:"medium",ml:250,hour:15,min:0)]),
            (12,[CupSeed(size:"medium",ml:250,hour:7, min:0),
                 CupSeed(size:"large", ml:400,hour:11,min:0),
                 CupSeed(size:"medium",ml:250,hour:15,min:0),
                 CupSeed(size:"medium",ml:250,hour:19,min:30)]),
            (13,[CupSeed(size:"medium",ml:250,hour:8, min:0),
                 CupSeed(size:"medium",ml:250,hour:12,min:30),
                 CupSeed(size:"large", ml:400,hour:17,min:0),
                 CupSeed(size:"small", ml:150,hour:21,min:0)]),
        ]

        for (daysAgo, cups) in waterDays {
            guard let base = cal.date(byAdding: .day, value: -daysAgo, to: Date()) else { continue }
            let dayStart = cal.startOfDay(for: base)
            for cup in cups {
                guard let logged = cal.date(bySettingHour: cup.hour, minute: cup.min, second: 0, of: dayStart)
                else { continue }
                waterIntakeLogs.append(WaterIntakeLog(
                    id: UUID(), userId: userId,
                    date: dayStart,
                    cupSize: cup.size,
                    cupSizeAmountInML: cup.ml,
                    loggedAt: logged
                ))
            }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 9 — Settings
    // ─────────────────────────────────────────────

    private func seedSettings(userId: UUID) {
        let tdee = userNutritionProfiles.first(where: { $0.userId == userId })?.tdee ?? 2038
        appPreferences.append(AppPreferences(id: UUID(), userId: userId,
            preferMetricUnits: true, vegFilterDefault: false,
            defaultMealType: .breakfast,
            dailyCalorieGoal: tdee,
            dailyMindfulMinutesGoal: 80,
            dailyWaterGoalML: 2450))

        notificationSettings.append(NotificationSettings(id: UUID(), userId: userId,
            pushEnabled: true,
            mealReminderEnabled: true,
            mealReminderTimes: ["08:00", "13:00", "20:00"],
            mindfulReminderEnabled: true, mindfulReminderTime: "07:00",
            waterReminderEnabled: true, waterReminderIntervalHours: 2,
            bedtimeReminderEnabled: true, bedtimeReminderMinutesBefore: 30,
            dailyTipEnabled: true, dailyTipTime: "09:00",
            weeklyScanReminderEnabled: true,
            weeklyScanReminderDay: "monday", weeklyScanReminderTime: "10:00"))
    }

    // ─────────────────────────────────────────────
    // MARK: - Convenience Helpers (used by Views)
    // ─────────────────────────────────────────────

    var currentUser: User? {
        users.first(where: { $0.id == currentUserId })
    }

    var currentProfile: UserProfile? {
        userProfiles.first(where: { $0.userId == currentUserId })
    }

    var activePlan: UserPlan? {
        userPlans.first(where: { $0.userId == currentUserId && $0.isActive })
    }

    var activeNutritionProfile: UserNutritionProfile? {
        userNutritionProfiles.first(where: { $0.userId == currentUserId })
    }

    var latestScanReport: ScanReport? {
        if let plan = activePlan,
           let linked = scanReports.first(where: { $0.id == plan.scanReportId }) {
            return linked
        }
        return scanReports
            .filter { r in scalpScans.contains(where: { $0.id == r.scalpScanId && $0.userId == currentUserId }) }
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
    }

    func options(for questionId: UUID) -> [QuestionOption] {
        questionOptions
            .filter { $0.questionId == questionId }
            .sorted(by: { $0.optionOrderIndex < $1.optionOrderIndex })
    }

    func scoreMap(for optionId: UUID) -> QuestionScoreMap? {
        questionScoreMaps.first(where: { $0.optionId == optionId })
    }

    func assessmentQuestions() -> [Question] {
        questions
            .filter { $0.questionOrderIndex <= 12 }
            .sorted(by: { $0.questionOrderIndex < $1.questionOrderIndex })
    }

    func fallbackQuestions() -> [Question] {
        questions
            .filter { $0.questionOrderIndex > 12 }
            .sorted(by: { $0.questionOrderIndex < $1.questionOrderIndex })
    }
    
    // MARK: - DietMate Convenience Helpers (forwarded from dietMateStore)

    func todaysTotalCalories() -> Float {
        dietMateStore.todaysTotalCalories()
    }

    func todaysMealEntries() -> [MealEntry] {
        dietMateStore.todaysMealEntries()
    }

    func logWaterIntake(cupSize: String, amountML: Float) {
        let log = WaterIntakeLog(
            id: UUID(),
            userId: currentUserId,
            date: Calendar.current.startOfDay(for: Date()),
            cupSize: cupSize,
            cupSizeAmountInML: amountML,
            loggedAt: Date()
        )
        waterIntakeLogs.append(log)
    }

//    func todaysTotalWaterML() -> Float {
//        totalWaterML(for: Date())
//    }

    var dailyMindfulTarget: Int {
        appPreferences.first(where: { $0.userId == currentUserId })?.dailyMindfulMinutesGoal ?? 20
    }

    func todaysMindfulMinutes() -> Int {
        mindEaseStore.todaysMindfulMinutes()
    }

    // MARK: - Water Intake Helpers

    func waterIntakeLogs(for date: Date) -> [WaterIntakeLog] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return waterIntakeLogs
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.date) == dayStart
            }
            .sorted { $0.loggedAt < $1.loggedAt }
    }

    func totalWaterML(for date: Date) -> Float {
        waterIntakeLogs(for: date).reduce(0) { $0 + $1.cupSizeAmountInML }
    }

    var dailyWaterGoalML: Float {
        appPreferences.first(where: { $0.userId == currentUserId })?.dailyWaterGoalML ?? 2450
    }

    // MARK: - Sleep Record Helpers

    func sleepRecord(for date: Date) -> SleepRecord? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return sleepRecords.first {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == dayStart
        }
    }

    var sleepHistoryDates: [Date] {
        let cal = Calendar.current
        let unique = Set(
            sleepRecords
                .filter { $0.userId == currentUserId }
                .map { cal.startOfDay(for: $0.date) }
        )
        return unique.sorted(by: >)
    }

    var waterHistoryDates: [Date] {
        let cal = Calendar.current
        let unique = Set(
            waterIntakeLogs
                .filter { $0.userId == currentUserId }
                .map { cal.startOfDay(for: $0.date) }
        )
        return unique.sorted(by: >)
    }
}
