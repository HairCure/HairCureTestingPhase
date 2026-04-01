//
//  AppDataStore.swift
//  HairCure
//
//  Dynamic data store — user data is created through the auth → profile → assessment flow.
//  Assessment answers and scalp scan data are created live when the user taps through.
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
    private(set) var hairInsightsStore: HairInsightsDataStore = HairInsightsDataStore()

    // MARK: - DietMate (delegated to DietmateDataStore)
    private(set) var dietMateStore: DietmateDataStore = DietmateDataStore(currentUserId: UUID())

    // MARK: - MindEase (delegated to MindEaseDataStore)
    private(set) var mindEaseStore: MindEaseDataStore = MindEaseDataStore(currentUserId: UUID())

    // MARK: - Settings
    var appPreferences: [AppPreferences] = []
    var notificationSettings: [NotificationSettings] = []

    // MARK: - Init

    init() {
        // Only seed the question bank and content library — no user data
        seedQuestions()
        hairInsightsStore = HairInsightsDataStore()
    }

    // ─────────────────────────────────────────────
    // MARK: 1 — Create User (called from auth flow)
    // ─────────────────────────────────────────────

   
    func createUser(
        name: String,
        email: String,
        phone: String? = nil,
        authProvider: AuthProvider = .guest
    ) {
        let userId = UUID()
        currentUserId = userId

        users.append(User(
            id: userId,
            name: name,
            email: email,
            phoneNumber: phone,
            authProvider: authProvider,
            createdAt: Date()
        ))

        // Create an empty profile — ProfileSetupView will fill in age/height/weight
        let dob = Calendar.current.date(byAdding: .year, value: -22, to: Date())!
        userProfiles.append(UserProfile(
            id: UUID(),
            userId: userId,
            username: name.lowercased().replacingOccurrences(of: " ", with: ""),
            displayName: name,
            dateOfBirth: dob,
            gender: "male",
            heightCm: 170,
            weightKg: 70,
            hairType: "straight",
            scalpType: "normal",
            isVegetarian: false,
            profileImageURL: nil,
            isProfileComplete: false,
            joinedAt: Date()
        ))

        // Wire up sub-stores with the new user ID
        dietMateStore = DietmateDataStore(currentUserId: userId)
        dietMateStore.parentStore = self
        dietMateStore.foodItems()  // load food database (content, not user data)

        mindEaseStore = MindEaseDataStore(currentUserId: userId)
        mindEaseStore.parentStore = self

        // Create default settings
        seedSettings(userId: userId)
    }

    /// Called from `applyToStore` after engine runs — seeds sub-stores with plan data
    func seedSubStoresAfterEngineRun(userId: UUID) {
        let np = userNutritionProfiles.first(where: { $0.userId == userId })
        dietMateStore.seedTodaysMealEntries(userId: userId, nutritionProfile: np)
        mindEaseStore.seedAll(userId: userId, userPlans: userPlans)
    }

    // ─────────────────────────────────────────────
    // MARK: 2 — Questions (all 11 + 3 fallback)
    //           Answers NOT seeded — created live in app
    // ─────────────────────────────────────────────

//    private func seedQuestions() {
//
//        // Q1 — Hair fall duration
//        let q1 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How long have you been experiencing hair fall?",
//            questionOrderIndex: 1, scoreDimension: .none)
//        questions.append(q1)
//        let q1Opts = ["Just started", "1–3 months", "3–6 months", "More than 6 months"]
//        q1Opts.enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: q1.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//
//        // Q2 — Daily hair fall amount
//        let q2 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How much hair fall do you see daily?",
//            questionOrderIndex: 2, scoreDimension: .none)
//        questions.append(q2)
//        ["Mild", "Moderate", "Heavy", "Not sure"].enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: q2.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//
//        // Q3 — Scalp symptoms (multi-choice)
//        let q3 = Question(id: UUID(), questionType: .multiChoice,
//            questionText: "Do you have any scalp symptoms?",
//            questionOrderIndex: 3, scoreDimension: .none)
//        questions.append(q3)
//        ["Itching", "Dryness", "Burning or inflammation", "Oily scalp", "None"].enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: q3.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//
//        // Q4 — Sleep hours  (SCORED)
//        let q4 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How many hours of sleep do you get each night?",
//            questionOrderIndex: 4, scoreDimension: .sleep)
//        questions.append(q4)
//        let q4opts = [
//            ("Less than 6 hours", Float(2.0)),
//            ("6–7 hours",         Float(5.0)),
//            ("7–8 hours",         Float(10.0)),
//            ("More than 8 hours", Float(7.0))
//        ]
//        q4opts.enumerated().forEach { i, pair in
//            let opt = QuestionOption(id: UUID(), questionId: q4.id,
//                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
//            questionOptions.append(opt)
//            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q4.id,
//                optionId: opt.id, scoreDimension: .sleep, scoreValue: pair.1))
//        }
//
//        // Q5 — Stress level  (SCORED)
//        let q5 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How stressed do you feel on most days?",
//            questionOrderIndex: 5, scoreDimension: .stress)
//        questions.append(q5)
//        let q5opts = [
//            ("Rarely",             Float(10.0)),
//            ("Occasionally",       Float(7.0)),
//            ("Most days",          Float(4.0)),
//            ("Always  burnout",    Float(1.0))
//        ]
//        q5opts.enumerated().forEach { i, pair in
//            let opt = QuestionOption(id: UUID(), questionId: q5.id,
//                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
//            questionOptions.append(opt)
//            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q5.id,
//                optionId: opt.id, scoreDimension: .stress, scoreValue: pair.1))
//        }
//
//        // Q6 — Diet quality  (SCORED)
//        let q6 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How would you describe your typical daily diet?",
//            questionOrderIndex: 6, scoreDimension: .diet)
//        questions.append(q6)
//        let q6opts = [
//            ("Very healthy, balanced meals", Float(10.0)),
//            ("Fairly balanced",              Float(7.0)),
//            ("Often junk  food",             Float(3.0)),
//            ("Very poor ",                   Float(1.0))
//        ]
//        q6opts.enumerated().forEach { i, pair in
//            let opt = QuestionOption(id: UUID(), questionId: q6.id,
//                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
//            questionOptions.append(opt)
//            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q6.id,
//                optionId: opt.id, scoreDimension: .diet, scoreValue: pair.1))
//        }
//
//        // Q7 — Water intake  (SCORED — hydration)
//        let q7 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How many glasses of water do you drink daily?",
//            questionOrderIndex: 7, scoreDimension: .hydration)
//        questions.append(q7)
//        let q7opts = [
//            ("Less than 3 glasses", Float(1.0)),
//            ("3–5 glasses",         Float(4.0)),
//            ("6–8 glasses",         Float(7.0)),
//            ("More than 8 glasses", Float(10.0))
//        ]
//        q7opts.enumerated().forEach { i, pair in
//            let opt = QuestionOption(id: UUID(), questionId: q7.id,
//                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
//            questionOptions.append(opt)
//            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q7.id,
//                optionId: opt.id, scoreDimension: .hydration, scoreValue: pair.1))
//        }
//
//        // Q8 — Hair washing  (SCORED)
//        let q8 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How often do you wash your hair?",
//            questionOrderIndex: 8, scoreDimension: .hairCare)
//        questions.append(q8)
//        let q8opts = [
//            ("Daily",               Float(4.0)),
//            ("Every 2–3 days",      Float(10.0)),
//            ("Every 4–5 days",      Float(7.0)),
//            ("Once a week or less", Float(3.0))
//        ]
//        q8opts.enumerated().forEach { i, pair in
//            let opt = QuestionOption(id: UUID(), questionId: q8.id,
//                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
//            questionOptions.append(opt)
//            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q8.id,
//                optionId: opt.id, scoreDimension: .hairCare, scoreValue: pair.1))
//        }
//
//        // Q9 — Age (picker)
//        questions.append(Question(id: UUID(), questionType: .picker,
//            questionText: "What is your age?",
//            questionOrderIndex: 9, scoreDimension: .none,
//            pickerMin: 15, pickerMax: 35, pickerStep: 1, pickerUnit: "yrs",
//            keyboardType: .number))
//
//        // Q10 — Height (picker)
//        questions.append(Question(id: UUID(), questionType: .picker,
//            questionText: "What is your height?",
//            questionOrderIndex: 10, scoreDimension: .none,
//            pickerMin: 140, pickerMax: 220, pickerStep: 1, pickerUnit: "cm",
//            keyboardType: .number))
//
//        // Q11 — Weight (picker)
//        questions.append(Question(id: UUID(), questionType: .picker,
//            questionText: "What is your weight?",
//            questionOrderIndex: 11, scoreDimension: .none,
//            pickerMin: 40, pickerMax: 150, pickerStep: 0.5, pickerUnit: "kg",
//            keyboardType: .decimal))
//
//        // Q12 — Activity level (for TDEE)
//        let q12 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How active are you on most days?",
//            questionOrderIndex: 12, scoreDimension: .none)
//        questions.append(q12)
//        ["Sedentary (desk job, little movement)",
//         "Light (walk or light exercise 1–3×/week)",
//         "Moderate (exercise 3–5×/week)",
//         "Very active (intense daily exercise)"].enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: q12.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//
//        // FB1 — Fallback: self-select stage (imageChoice)
//        let fb1 = Question(id: UUID(), questionType: .imageChoice,
//            questionText: "Select your current hair fall stage",
//            questionOrderIndex: 13, scoreDimension: .none)
//        questions.append(fb1)
//        let stageOpts = [
//            ("Stage 1 — Slight thinning, hairline normal", "stage1_illustration"),
//            ("Stage 2 — Noticeable thinning on top",       "stage2_illustration"),
//            ("Stage 3 — Clear bald patch forming",          "stage3_illustration"),
//            ("Stage 4 — Large bald area",                   "stage4_illustration")
//        ]
//        stageOpts.enumerated().forEach { i, pair in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: fb1.id,
//                optionOrderIndex: i+1, optionText: pair.0,
//                imageURL: pair.1, optionType: .image))
//        }
//
//        // FB2 — Fallback: scalp condition
//        let fb2 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How does your scalp feel most of the time?",
//            questionOrderIndex: 14, scoreDimension: .none)
//        questions.append(fb2)
//        ["Flaky / white flakes : Dandruff",
//         "Tight, itchy, rough feel : Dry scalp",
//         "Greasy by midday : Oily scalp",
//         "Red or sore spots : Inflammation",
//         "Feels normal : No issues"].enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: fb2.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//
//        // FB3 — Fallback: hair density
//        let fb3 = Question(id: UUID(), questionType: .singleChoice,
//            questionText: "How would you describe your hair thickness?",
//            questionOrderIndex: 15, scoreDimension: .none)
//        questions.append(fb3)
//        ["Thick and full : no visible scalp",
//         "Medium : slight scalp visible in light",
//         "Thin : scalp clearly visible on top",
//         "Very thin : significant scalp showing"].enumerated().forEach { i, text in
//            questionOptions.append(QuestionOption(id: UUID(), questionId: fb3.id,
//                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
//        }
//    }

    // ─────────────────────────────────────────────
    // MARK: seedQuestions — REPLACE this entire function
    //       in AppDataStore.swift
    //
    //  7 assessment questions (down from 12):
    //   Q1  Hair fall duration   — context only (.none)
    //   Q2  Sleep hours          — sleepScore    (PSQI + Trüeb 2015)
    //   Q3  Stress level         — stressScore   (PSS-4, Peters 2006)
    //   Q4  Diet quality         — dietScore     (Almohanna 2019, Rushton 2002)
    //   Q5  Water intake         — hydration     (EFSA 2010)
    //   Q6  Hair washing         — hairCareScore (Ranganathan 2010)
    //   Q7  Activity level       — TDEE only, no score
    //
    //  Removed: Q2 (hair fall amount), Q3 (scalp symptoms),
    //           Q9 (age), Q10 (height), Q11 (weight)
    //  Age / height / weight now read from UserProfile (set in ProfileSetupView)
    //
    //  3 fallback questions unchanged (orderIndex 8, 9, 10)
    // ─────────────────────────────────────────────

    private func seedQuestions() {

        // ── Q1 — Hair fall duration (context only, not scored) ──
        let q1 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How long have you been experiencing hair fall?",
            questionOrderIndex: 1, scoreDimension: .none)
        questions.append(q1)
        ["Just started (less than 1 month)",
         "1–3 months",
         "3–6 months",
         "More than 6 months"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q1.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // ── Q2 — Sleep hours (SCORED) ──
        // Research: PSQI scale (Buysse 1989) + Trüeb 2015 cortisol-hair link
        //   <6 hrs  → PSQI severe → cortisol spike → telogen effluvium  → 1.5
        //   6–7 hrs → PSQI moderate impairment                           → 4.5
        //   7–8 hrs → WHO/NHS optimal range                              → 10.0
        //   >8 hrs  → elevated cortisol link (Motivala 2008)             → 6.5
        let q2 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How many hours of sleep do you get each night?",
            questionOrderIndex: 2, scoreDimension: .sleep)
        questions.append(q2)
        let q2opts: [(String, Float)] = [
            ("Less than 6 hours", 1.5),
            ("6–7 hours",         4.5),
            ("7–8 hours",         10.0),
            ("More than 8 hours", 6.5)
        ]
        q2opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q2.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q2.id,
                optionId: opt.id, scoreDimension: .sleep, scoreValue: pair.1))
        }

        // ── Q3 — Stress level (SCORED) ──
        // Research: PSS-4 scale (Cohen 1983) + Peters et al. 2006
        //   Rarely     → PSS low 0–6   → minimal cortisol elevation     → 10.0
        //   Occasionally → PSS moderate 7–13                            → 6.5
        //   Most days  → PSS high 14–18 → telogen effluvium threshold   → 3.0
        //   Always     → PSS severe 19–27 → acute TE confirmed          → 1.0
        let q3 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How stressed do you feel on most days?",
            questionOrderIndex: 3, scoreDimension: .stress)
        questions.append(q3)
        let q3opts: [(String, Float)] = [
            ("Rarely or never",    10.0),
            ("Occasionally",        6.5),
            ("Most days",           3.0),
            ("Always / burnout",    1.0)
        ]
        q3opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q3.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q3.id,
                optionId: opt.id, scoreDimension: .stress, scoreValue: pair.1))
        }

        // ── Q4 — Diet quality (SCORED) ──
        // Research: Almohanna et al. 2019 (Dermatol Ther) + Rushton 2002 (Clin Exp Dermatol)
        //   Very healthy  → all key nutrients likely met                  → 10.0
        //   Fairly balanced → partial zinc/iron gaps probable             → 6.5
        //   Often junk    → iron/zinc/biotin deficiency high probability  → 2.5
        //   Very poor     → severe multi-nutrient deficiency — TE trigger → 1.0
        let q4 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How would you describe your typical daily diet?",
            questionOrderIndex: 4, scoreDimension: .diet)
        questions.append(q4)
        let q4opts: [(String, Float)] = [
            ("Very healthy, balanced meals", 10.0),
            ("Fairly balanced",               6.5),
            ("Often junk or fast food",        2.5),
            ("Very poor or skipping meals",    1.0)
        ]
        q4opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q4.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q4.id,
                optionId: opt.id, scoreDimension: .diet, scoreValue: pair.1))
        }

        // ── Q5 — Water intake (SCORED) ──
        // Research: EFSA 2010 — 2.5L/day adult male recommendation
        //   <3 glasses (~600ml)  → severe deficit vs 2.5L target         → 1.5
        //   3–5 glasses (~1000ml) → significant deficit                  → 4.0
        //   6–8 glasses (~1800ml) → near adequate                        → 7.5
        //   >8 glasses (>2000ml) → meets/exceeds EFSA target             → 10.0
        let q5 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How many glasses of water do you drink daily?",
            questionOrderIndex: 5, scoreDimension: .hydration)
        questions.append(q5)
        let q5opts: [(String, Float)] = [
            ("Less than 3 glasses",  1.5),
            ("3–5 glasses",          4.0),
            ("6–8 glasses",          7.5),
            ("More than 8 glasses", 10.0)
        ]
        q5opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q5.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q5.id,
                optionId: opt.id, scoreDimension: .hydration, scoreValue: pair.1))
        }

        // ── Q6 — Hair washing frequency (SCORED) ──
        // Research: Ranganathan & Mukhopadhyay 2010 (Indian J Dermatol)
        //           + Trüeb scalp hygiene guidelines
        //   Daily          → strips sebum, disrupts microbiome             → 3.5
        //   Every 2–3 days → optimal sebum balance — trichology consensus  → 10.0
        //   Every 4–5 days → suboptimal but acceptable                     → 6.5
        //   Once a week    → product buildup + follicle blockage risk       → 2.5
        let q6 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How often do you wash your hair?",
            questionOrderIndex: 6, scoreDimension: .hairCare)
        questions.append(q6)
        let q6opts: [(String, Float)] = [
            ("Daily",                 3.5),
            ("Every 2–3 days",       10.0),
            ("Every 4–5 days",        6.5),
            ("Once a week or less",   2.5)
        ]
        q6opts.enumerated().forEach { i, pair in
            let opt = QuestionOption(id: UUID(), questionId: q6.id,
                optionOrderIndex: i+1, optionText: pair.0, imageURL: nil, optionType: .text)
            questionOptions.append(opt)
            questionScoreMaps.append(QuestionScoreMap(id: UUID(), questionId: q6.id,
                optionId: opt.id, scoreDimension: .hairCare, scoreValue: pair.1))
        }

        // ── Q7 — Activity level (TDEE only, not lifestyle-scored) ──
        let q7 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How active are you on most days?",
            questionOrderIndex: 7, scoreDimension: .none)
        questions.append(q7)
        ["Sedentary (desk job, little movement)",
         "Light (walk or light exercise 1–3×/week)",
         "Moderate (exercise 3–5×/week)",
         "Very active (intense daily exercise)"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: q7.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // ── FB1 — Fallback: self-select stage (imageChoice) ──
        let fb1 = Question(id: UUID(), questionType: .imageChoice,
            questionText: "Select your current hair fall stage",
            questionOrderIndex: 8, scoreDimension: .none)
        questions.append(fb1)
        [("Stage 1 — Slight thinning, hairline normal", "stage1_illustration"),
         ("Stage 2 — Noticeable thinning on top",       "stage2_illustration"),
         ("Stage 3 — Clear bald patch forming",         "stage3_illustration"),
         ("Stage 4 — Large bald area",                  "stage4_illustration")
        ].enumerated().forEach { i, pair in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb1.id,
                optionOrderIndex: i+1, optionText: pair.0,
                imageURL: pair.1, optionType: .image))
        }

        // ── FB2 — Fallback: scalp condition ──
        let fb2 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How does your scalp feel most of the time?",
            questionOrderIndex: 9, scoreDimension: .none)
        questions.append(fb2)
        ["Flaky or white flakes — Dandruff",
         "Tight, itchy, rough feel — Dry scalp",
         "Greasy by midday — Oily scalp",
         "Red or sore spots — Inflammation",
         "Feels normal — No issues"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb2.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }

        // ── FB3 — Fallback: hair density ──
        let fb3 = Question(id: UUID(), questionType: .singleChoice,
            questionText: "How would you describe your hair thickness?",
            questionOrderIndex: 10, scoreDimension: .none)
        questions.append(fb3)
        ["Thick and full — no visible scalp",
         "Medium — slight scalp visible in light",
         "Thin — scalp clearly visible on top",
         "Very thin — significant scalp showing"].enumerated().forEach { i, text in
            questionOptions.append(QuestionOption(id: UUID(), questionId: fb3.id,
                optionOrderIndex: i+1, optionText: text, imageURL: nil, optionType: .text))
        }
    }
    // ─────────────────────────────────────────────
    // MARK: 3 — Engine Output
    //   (no longer pre-seeded — computed dynamically by
    //    RecommendationEngine.run() after assessment + hair analysis)
    // ─────────────────────────────────────────────

    // ─────────────────────────────────────────────
    // MARK: 9 — Settings
    // ─────────────────────────────────────────────

    private func seedSettings(userId: UUID) {
        // Derive initial goals from UserProfile using the same formulas as RecommendationEngine
        let profile  = userProfiles.first(where: { $0.userId == userId })
        let heightCm = profile?.heightCm ?? 170
        let weightKg = profile?.weightKg ?? 70
        let age      = profile.map {
            Calendar.current.dateComponents([.year], from: $0.dateOfBirth, to: Date()).year ?? 22
        } ?? 22

        // Mifflin–St Jeor (male): BMR = (10 × kg) + (6.25 × cm) − (5 × age) + 5
        // Default activity = sedentary (×1.2) — engine will recalculate with actual level later
        let bmr  = (10 * weightKg) + (6.25 * heightCm) - (5 * Float(age)) + 5
        let tdee = userNutritionProfiles.first(where: { $0.userId == userId })?.tdee
                   ?? (bmr * 1.2).rounded()

        // Water: 35 mL × body weight (EFSA 2010)
        let waterGoal = userNutritionProfiles.first(where: { $0.userId == userId })?.waterTargetML
                        ?? (weightKg * 35).rounded()

        // Mindful minutes: 0 until the engine assigns a plan with session schedule
        let mindfulGoal = userPlans.first(where: { $0.userId == userId }).map {
            $0.meditationMinutesPerDay + $0.yogaMinutesPerDay + $0.soundMinutesPerDay
        } ?? 0

        appPreferences.append(AppPreferences(id: UUID(), userId: userId,
            preferMetricUnits: true, vegFilterDefault: false,
            defaultMealType: .breakfast,
            dailyCalorieGoal: tdee,
            dailyMindfulMinutesGoal: mindfulGoal,
            dailyWaterGoalML: waterGoal))

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
            .filter { $0.questionOrderIndex <= 7 }
            .sorted(by: { $0.questionOrderIndex < $1.questionOrderIndex })
    }

    func fallbackQuestions() -> [Question] {
        questions
            .filter { $0.questionOrderIndex > 7 }
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
        // Read from preferences (set by engine via applyToStore), fall back to active plan, then 0
        if let pref = appPreferences.first(where: { $0.userId == currentUserId }),
           pref.dailyMindfulMinutesGoal > 0 {
            return pref.dailyMindfulMinutesGoal
        }
        if let plan = activePlan {
            return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
        }
        return 0
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
        // Read from preferences (set by engine), fall back to profile-based calculation
        if let pref = appPreferences.first(where: { $0.userId == currentUserId }),
           pref.dailyWaterGoalML > 0 {
            return pref.dailyWaterGoalML
        }
        // Fallback: 35 mL × body weight (EFSA 2010)
        let weight = currentProfile?.weightKg ?? 70
        return (weight * 35).rounded()
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
