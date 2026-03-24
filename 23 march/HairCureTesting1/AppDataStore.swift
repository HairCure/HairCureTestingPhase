//
//  AppDataStore.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
//  AppDataStore.swift
//  HairCure
//
//  Mock data store — Arjun, 22 years old, Stage 2, Poor lifestyle → Plan 2A.
//  Assessment answers and scalp scan data are NOT pre-populated here.
//  They are created live when the user taps through the assessment flow.
//  The engine then reads those live answers and writes the plan.
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

    // MARK: - DietMate
    var foods: [Food] = []
    var mealEntries: [MealEntry] = []
    var mealFoods: [MealFood] = []

    // MARK: - MindEase
    var mindEaseCategories: [MindEaseCategory] = []
    var mindEaseCategoryContents: [MindEaseCategoryContent] = []
    var mindfulSessions: [MindfulSession] = []
    var todaysPlans: [TodaysPlan] = []

    // MARK: - Trackers
    var sleepRecords: [SleepRecord] = []
    var waterIntakeLogs: [WaterIntakeLog] = []

    // MARK: - Content
    var hairInsights: [HairInsight] = []
    var careTips: [CareTip] = []
    var homeRemedies: [HomeRemedy] = []
    var dailyTips: [DailyTip] = []
    var userFavorites: [UserFavorite] = []

    // MARK: - Settings
    var appPreferences: [AppPreferences] = []
    var notificationSettings: [NotificationSettings] = []
    // MARK: - Session Tracking
    var sessionStartTimes: [UUID: Date] = [:]

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
        seedFoods()
        seedMindEaseContent()
        seedEngineOutput(userId: userId)
        seedTodaysMealEntries(userId: userId)
        seedHistoricalMealData(userId: userId)
        seedTodaysPlan(userId: userId)
        seedHistoricalMindfulData(userId: userId)
        seedSleepAndWater(userId: userId)
        seedHairInsights()
        seedCareTips()
        seedHomeRemedies()
        seedDailyTips()
        seedSettings(userId: userId)
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
            ("Rarely",     Float(10.0)),
            ("Occasionally",       Float(7.0)),
            ("Most days",          Float(4.0)),
            ("Always  burnout",   Float(1.0))
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
            ("Often junk  food",       Float(3.0)),
            ("Very poor ",   Float(1.0))
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
            ("Daily",                 Float(4.0)),
            ("Every 2–3 days",        Float(10.0)),
            ("Every 4–5 days",        Float(7.0)),
            ("Once a week or less",   Float(3.0))
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
    //           Stage 2 × Poor lifestyle × Dry scalp
    //           BMR 1699 · TDEE 2038 (sedentary)
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
        // Arjun's scores: sleep 2, stress 4, diet 3, hairCare 4
        // hydration 4 → diet adjusted to (3+4)/2 = 3.5 → composite = (3.5+4+2+4)/4 = 3.37 → Poor
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

        // BMR = (10×70) + (6.25×175) − (5×22) + 5 = 1698.75 ≈ 1699
        // TDEE = 1699 × 1.2 = 2038.8 ≈ 2038
        let tdee: Float = 2038
        userNutritionProfiles.append(UserNutritionProfile(
            id: UUID(), userId: userId,
            activityLevel: .sedentary,
            bmr: 1699, tdee: tdee,
            breakfastCalTarget: tdee * 0.25,  // 510
            lunchCalTarget:     tdee * 0.35,  // 713
            snackCalTarget:     tdee * 0.15,  // 306
            dinnerCalTarget:    tdee * 0.25,  // 510
            proteinTargetGm: 70,
            carbTargetGm: 255,
            fatTargetGm: 57,
            waterTargetML: 70 * 35,           // 2450ml
            createdAt: Date(), updatedAt: Date()
        ))
    }

    // ─────────────────────────────────────────────
    // MARK: 4 — Foods (Indian foods, matching prototype UI)
    // ─────────────────────────────────────────────

    private func seedFoods() {
        struct FoodSeed {
            let name: String
            let img: String
            let isVeg: Bool
            let calMin: Float; let calMax: Float
            let protein: Float; let carbs: Float; let fat: Float; let vitamins: Float
            let serving: Float
            let biotin: Bool; let zinc: Bool; let iron: Bool; let omega3: Bool; let vitA: Bool
            let meals: [MealType]
        }
        let seeds: [FoodSeed] = [
            FoodSeed(name:"Paneer Stuffed Paratha",     img:"paneer_paratha",    isVeg:true,  calMin:300,calMax:330,protein:12,carbs:38,fat:12,vitamins:4.5,serving:200, biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.breakfast,.dinner]),
            FoodSeed(name:"Vegetable Oats Upma",        img:"veg_oats_upma",     isVeg:true,  calMin:260,calMax:290,protein:9, carbs:42,fat:6, vitamins:6.2,serving:180, biotin:true, zinc:true, iron:true, omega3:false,vitA:false, meals:[.breakfast]),
            FoodSeed(name:"Curd with Flaxseeds & Fruits",img:"curd_flaxseeds",  isVeg:true,  calMin:280,calMax:310,protein:10,carbs:35,fat:9, vitamins:5.8,serving:200, biotin:true, zinc:true, iron:false,omega3:true, vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Methi Thepla",               img:"methi_thepla",      isVeg:true,  calMin:250,calMax:270,protein:7, carbs:36,fat:8, vitamins:9.2,serving:150, biotin:false,zinc:false,iron:true, omega3:false,vitA:true,  meals:[.breakfast,.lunch]),
            FoodSeed(name:"Moong Dal Chilla",           img:"moong_chilla",      isVeg:true,  calMin:220,calMax:250,protein:12,carbs:30,fat:5, vitamins:7.4,serving:150, biotin:true, zinc:true, iron:true, omega3:false,vitA:false, meals:[.breakfast,.lunch]),
            FoodSeed(name:"Spinach Dal (Palak Dal)",    img:"palak_dal",         isVeg:true,  calMin:280,calMax:310,protein:14,carbs:38,fat:5, vitamins:12.0,serving:250,biotin:false,zinc:true, iron:true, omega3:false,vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Brown Rice & Lentils",       img:"brown_rice_lentils",isVeg:true,  calMin:320,calMax:360,protein:14,carbs:58,fat:3, vitamins:8.5,serving:280, biotin:false,zinc:true, iron:true, omega3:false,vitA:false, meals:[.lunch,.dinner]),
            FoodSeed(name:"Egg Bhurji",                 img:"egg_bhurji",        isVeg:false, calMin:280,calMax:310,protein:18,carbs:6, fat:18,vitamins:5.2,serving:150, biotin:true, zinc:true, iron:true, omega3:true, vitA:true,  meals:[.breakfast,.lunch]),
            FoodSeed(name:"Grilled Chicken Salad",      img:"chicken_salad",     isVeg:false, calMin:290,calMax:320,protein:28,carbs:12,fat:10,vitamins:4.8,serving:200, biotin:false,zinc:true, iron:true, omega3:true, vitA:false, meals:[.lunch,.dinner]),
            FoodSeed(name:"Walnut & Banana Smoothie",   img:"walnut_smoothie",   isVeg:true,  calMin:300,calMax:330,protein:8, carbs:42,fat:14,vitamins:3.5,serving:300, biotin:true, zinc:false,iron:false,omega3:true, vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Pumpkin Seeds & Fruit Bowl", img:"pumpkin_fruit",     isVeg:true,  calMin:220,calMax:250,protein:8, carbs:30,fat:10,vitamins:6.0,serving:100, biotin:true, zinc:true, iron:false,omega3:true, vitA:true,  meals:[.snack]),
            FoodSeed(name:"Almonds & Dates",            img:"almonds_dates",     isVeg:true,  calMin:200,calMax:230,protein:6, carbs:22,fat:12,vitamins:4.2,serving:60,  biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.snack]),
            FoodSeed(name:"Whole Wheat Roti + Sabzi",   img:"roti_sabzi",        isVeg:true,  calMin:350,calMax:390,protein:12,carbs:55,fat:8, vitamins:10.5,serving:250,biotin:false,zinc:false,iron:true, omega3:false,vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Paneer Tikka",               img:"paneer_tikka",      isVeg:true,  calMin:320,calMax:360,protein:20,carbs:12,fat:20,vitamins:3.8,serving:200, biotin:false,zinc:true, iron:false,omega3:false,vitA:true,  meals:[.dinner]),
            FoodSeed(name:"Fish Curry (Rohu)",          img:"fish_curry",        isVeg:false, calMin:300,calMax:340,protein:26,carbs:14,fat:12,vitamins:5.6,serving:250, biotin:true, zinc:true, iron:true, omega3:true, vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Oatmeal with Almonds",       img:"oatmeal_almonds",   isVeg:true,  calMin:280,calMax:310,protein:10,carbs:44,fat:9, vitamins:4.0,serving:200, biotin:true, zinc:false,iron:true, omega3:false,vitA:false, meals:[.breakfast]),
            FoodSeed(name:"Greek Yogurt",               img:"greek_yogurt",      isVeg:true,  calMin:150,calMax:180,protein:15,carbs:12,fat:4, vitamins:2.5,serving:150, biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Chicken Soup",               img:"chicken_soup",      isVeg:false, calMin:200,calMax:240,protein:22,carbs:10,fat:7, vitamins:3.2,serving:350, biotin:false,zinc:true, iron:true, omega3:false,vitA:false, meals:[.lunch,.dinner]),
        ]
        foods = seeds.map { s in
            Food(id:UUID(), externalFoodId:nil, name:s.name, imageURL:s.img,
                 foodType: s.isVeg ? "vegetarian" : "non-vegetarian",
                 isVegetarian:s.isVeg, isCustom:false, createdByUserId:nil,
                 servingSizeGrams:s.serving, apiSource:"mock",
                 totalCaloriesMin:s.calMin, totalCaloriesMax:s.calMax,
                 totalProteinsInGm:s.protein, totalCarbsInGm:s.carbs,
                 totalFatInGm:s.fat, totalVitaminsInMg:s.vitamins,
                 isBiotinRich:s.biotin, isZincRich:s.zinc,
                 isIronRich:s.iron, isOmega3Rich:s.omega3, isVitaminARich:s.vitA,
                 suitableMealTypes:s.meals, createdAt:Date())
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 5 — Today's empty meal entries (user fills them)
    // ─────────────────────────────────────────────

    private func seedTodaysMealEntries(userId: UUID) {
        guard let np = userNutritionProfiles.first(where: { $0.userId == userId }) else { return }
        for (mealType, budget) in [(MealType.breakfast, np.breakfastCalTarget),
                                   (.lunch, np.lunchCalTarget),
                                   (.snack, np.snackCalTarget),
                                   (.dinner, np.dinnerCalTarget)] {
            mealEntries.append(MealEntry(
                id: UUID(), userId: userId, mealType: mealType,
                date: Date(), isLogged: false, loggedAt: nil,
                calorieTarget: budget, caloriesConsumed: 0,
                proteinConsumed: 0, carbsConsumed: 0, fatConsumed: 0,
                goalStatus: .under
            ))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 5b — Historical meal data (past 6 days)
    //            Provides real data for the week ring calendar
    //            and is the source for the Profile meal log later.
    // ─────────────────────────────────────────────

    private func seedHistoricalMealData(userId: UUID) {
        guard let np = userNutritionProfiles.first(where: { $0.userId == userId }) else { return }
        let cal = Calendar.current

        // (daysAgo, breakfastPct, lunchPct, snackPct, dinnerPct)
        // Percentages represent how much of the slot target was consumed (0.0–1.3)
        let dayProfiles: [(Int, Float, Float, Float, Float)] = [
            (1, 0.95, 1.00, 0.90, 1.05),   // yesterday — full day
            (2, 0.80, 0.95, 0.75, 0.85),   // 2 days ago
            (3, 1.10, 0.90, 1.00, 0.95),   // 3 days ago — slightly over breakfast
            (4, 0.60, 1.00, 0.85, 0.90),   // 4 days ago — light breakfast
            (5, 0.90, 0.80, 0.70, 0.95),   // 5 days ago
            (6, 0.85, 1.05, 0.90, 0.80),   // 6 days ago
        ]

        let slots: [(MealType, Float)] = [
            (.breakfast, np.breakfastCalTarget),
            (.lunch,     np.lunchCalTarget),
            (.snack,     np.snackCalTarget),
            (.dinner,    np.dinnerCalTarget)
        ]

        for (daysAgo, bPct, lPct, sPct, dPct) in dayProfiles {
            guard let pastDate = cal.date(byAdding: .day, value: -daysAgo, to: Date()) else { continue }
            let dayStart = cal.startOfDay(for: pastDate)

            let pcts: [Float] = [bPct, lPct, sPct, dPct]
            for (idx, (mealType, target)) in slots.enumerated() {
                let consumed = (target * pcts[idx]).rounded()
                let loggedTime = cal.date(byAdding: .hour, value: [8, 13, 16, 20][idx], to: dayStart) ?? dayStart
                let status: MealGoalStatus = consumed < target * 0.70 ? .under
                                           : consumed <= target * 1.10 ? .met : .exceeded
                mealEntries.append(MealEntry(
                    id: UUID(), userId: userId, mealType: mealType,
                    date: dayStart, isLogged: true, loggedAt: loggedTime,
                    calorieTarget: target, caloriesConsumed: consumed,
                    proteinConsumed: consumed * 0.15 / 4,
                    carbsConsumed:   consumed * 0.50 / 4,
                    fatConsumed:     consumed * 0.30 / 9,
                    goalStatus: status
                ))
            }
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 6 — MindEase categories & sessions
    // ─────────────────────────────────────────────

    private func seedMindEaseContent() {
        let yoga = MindEaseCategory(id: UUID(), title: "Yoga",
            categoryDescription: "Gentle poses to strengthen body and reduce hair fall",
            bannerImageURL: "yoga_banner", cardImageUrl: "yoga_card",
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
        [("Balayam Yoga",         "Nail rubbing — stimulates hair follicles directly",  600,  "beginner"),
         ("Adho Mukha Svanasana", "Downward dog — increases blood flow to scalp",       900,  "beginner"),
         ("Sarvangasana",         "Shoulder stand — improves circulation to head",      1200, "intermediate"),
         ("Uttanasana",           "Forward bend — relieves stress and refreshes scalp", 600,  "beginner"),
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
        [("Bhramari Pranayama",  "Humming bee breath  reduces stress hormones rapidly", 600,  "beginner"),
         ("Anulom Vilom",        "Alternate nostril breathing  balances nervous system", 900,  "beginner"),
         ("Body Scan Meditation","Full body relaxation  releases physical tension",      1200, "beginner"),
         ("Guided Visualisation","Positive imagery  reduces cortisol",                  900,  "intermediate"),
         ("Kapalbhati",          "Cleansing breath  detoxifies and energises",          600,  "intermediate")
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
         ("Mountain Stream",   "Flowing stream  clears mental fog",                 900),
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
    // MARK: 7 — Today's plan (first Meditation session)
    // ─────────────────────────────────────────────

    private func seedTodaysPlan(userId: UUID) {
            guard let plan = userPlans.first(where: { $0.userId == userId }) else { return }
            let today = Date()

            // ── Meditation ──
            // 1 — Bhramari Pranayama
            if let cat = mindEaseCategories.first(where: { $0.title == "Meditation" }),
               let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: session.id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: plan.meditationMinutesPerDay,
                    minutesCompleted: 0, orderIndex: 1, isCompleted: false))
            }

            // 2 — Anulom Vilom (second meditation session)
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
            // 3 — Balayam Yoga
            if let cat = mindEaseCategories.first(where: { $0.title == "Yoga" }),
               let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: session.id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: plan.yogaMinutesPerDay,
                    minutesCompleted: 0, orderIndex: 3, isCompleted: false))
            }

            // 4 — Adho Mukha Svanasana (second yoga session)
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

            // 5 — Uttanasana (third yoga session)
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
            // 6 — Forest Rain
            if let cat = mindEaseCategories.first(where: { $0.title == "Relaxing Sounds" }),
               let session = mindEaseCategoryContents.first(where: { $0.categoryId == cat.id }) {
                todaysPlans.append(TodaysPlan(
                    id: UUID(), userId: userId, planDate: today,
                    contentId: session.id, categoryId: cat.id, planId: plan.planId,
                    minutesTarget: plan.soundMinutesPerDay,
                    minutesCompleted: 0, orderIndex: 6, isCompleted: false))
            }

            // 7 — Ocean Waves (second sound session)
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
    // MARK: 7b — Historical mindful sessions (past 6 days)
    //            Powers the purple week ring calendar in MindEaseView
    // ─────────────────────────────────────────────

    private func seedHistoricalMindfulData(userId: UUID) {
        guard let firstContent = mindEaseCategoryContents.first else { return }
        let cal = Calendar.current
        let raw    = Double(dailyMindfulTarget)
        let target = min(60.0, max(15.0, raw))

        // daysAgo → fractional completion (0 = skipped)
        let dayData: [(Int, Double)] = [
            (1, 1.00),   // yesterday — full
            (2, 0.80),   // 2 days ago
            (3, 0.95),   // 3 days ago
            (4, 0.00),   // 4 days ago — rest day (no ring fill)
            (5, 0.70),   // 5 days ago
            (6, 0.90)    // 6 days ago
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
    // MARK: 8 — Sleep history & water log
    // ─────────────────────────────────────────────

    private func seedSleepAndWater(userId: UUID) {
            let cal = Calendar.current

            // ── Sleep Records — 14 days ──
            // (daysAgo, bedHour, bedMin, wakeHour, wakeMin, hoursSlept)
            let sleepData: [(Int, Int, Int, Int, Int, Float)] = [
                (0,  23, 0,  0,  0,  0.0),   // today — not yet asleep (0h)
                (1,  23, 15, 6,  30, 7.25),  // yesterday — good
                (2,  0,  0,  5,  30, 5.5),   // 2 days ago — short
                (3,  22, 45, 6,  45, 8.0),   // 3 days ago — great
                (4,  1,  0,  6,  0,  5.0),   // 4 days ago — poor
                (5,  23, 30, 7,  0,  7.5),   // 5 days ago — good
                (6,  22, 0,  6,  30, 8.5),   // 6 days ago — excellent
                (7,  0,  30, 6,  0,  5.5),   // 7 days ago — short
                (8,  23, 0,  7,  0,  8.0),   // 8 days ago — great
                (9,  23, 45, 6,  15, 6.5),   // 9 days ago — fair
                (10, 22, 30, 6,  30, 8.0),   // 10 days ago — great
                (11, 1,  15, 5,  45, 4.5),   // 11 days ago — poor
                (12, 23, 0,  7,  30, 8.5),   // 12 days ago — excellent
                (13, 0,  0,  6,  0,  6.0),   // 13 days ago — fair
            ]

            for (daysAgo, bedH, bedM, wakeH, wakeM, hrs) in sleepData {
                guard let base   = cal.date(byAdding: .day, value: -daysAgo, to: Date()),
                      let bed    = cal.date(bySettingHour: bedH,  minute: bedM,  second: 0, of: base),
                      let wake   = cal.date(bySettingHour: wakeH, minute: wakeM, second: 0, of: base)
                else { continue }
                sleepRecords.append(SleepRecord(
                    id: UUID(), userId: userId, date: cal.startOfDay(for: base),
                    bedTime: bed, wakeTime: wake, alarmEnabled: true,
                    alarmTime: wake, hoursSlept: hrs
                ))
            }

            // ── Water Intake Logs — 13 days history (yesterday → 13 days ago) ──
            // Today (daysAgo: 0) intentionally omitted — tracker starts at 0 ml.
            // Cup sizes: small=150ml, medium=250ml, large=400ml
            struct CupSeed { let size: String; let ml: Float; let hour: Int; let min: Int }

            let waterDays: [(Int, [CupSeed])] = [
                // daysAgo: 0  ← deliberately removed so today starts at 0 ml
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
        }    // ─────────────────────────────────────────────
    // MARK: 9 — Hair Insights (Stage 2 / dry scalp)
    // ─────────────────────────────────────────────

    private func seedHairInsights() {
        [("How zinc deficiency causes hair thinning",
          "Zinc is essential for hair follicle function. Low levels cause the follicle to shrink, leading to visible thinning at the crown.",
          "all", [2,3]),
         ("Why dry scalp increases breakage",
          "A dry scalp lacks natural oils to protect the hair shaft, increasing brittleness and making hair fall appear worse.",
          "dry", [1,2,3]),
         ("The link between cortisol and hair loss",
          "Chronic stress raises cortisol, pushing follicles into the resting phase. Diffuse shedding follows 2–3 months later.",
          "all", [1,2,3]),
         ("Best foods to increase biotin naturally",
          "Eggs, almonds, and sweet potatoes are among the richest natural sources of biotin — directly linked to keratin production.",
          "all", [1,2]),
         ("Oiling routine for dry scalp relief",
          "Warm coconut or almond oil twice a week hydrates the scalp, reduces itching, and creates an environment where hair grows stronger.",
          "dry", [1,2,3]),
         ("How sleep deprivation affects your hair",
          "Hair cells are among the fastest dividing in the body. Under 6 hrs consistently disrupts the repair cycle.",
          "all", [1,2,3]),
         ("Why daily washing may be hurting you",
          "Daily washing strips natural sebum, causing glands to overcompensate — worsening dryness and irritation.",
          "dry", [1,2])
        ].forEach { title, desc, scalp, stages in
            hairInsights.append(HairInsight(id: UUID(),
                title: title, insightDescription: desc,
                category: "hair_health", mediaURL: nil,
                targetHairTypes: ["all"],
                targetScalpConditions: [scalp],
                targetPlanStages: stages,
                difficultyLevel: nil, isActive: true))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 10 — Care Tips
    // ─────────────────────────────────────────────

    private func seedCareTips() {
        [("Wash hair every 2–3 days",
          "Over-washing strips the scalp. Washing every 2–3 days maintains natural oil balance.", "washing", 1),
         ("Use lukewarm water, not hot",
          "Hot water opens the cuticle too aggressively and dries the scalp.", "washing", 2),
         ("Oil your scalp twice a week",
          "Warm coconut or almond oil left for 30 min nourishes follicles and reduces dryness.", "oiling", 1),
         ("Avoid tight hairstyles",
          "Tight ponytails put traction on follicles at the hairline — over time causing traction alopecia.", "styling", 3),
         ("Pat dry — don't rub",
          "Rubbing wet hair causes breakage. Pat gently with a soft cotton towel.", "drying", 2),
         ("Use a wide-tooth comb on wet hair",
          "Wet hair stretches easily. Work from ends upward to prevent snapping.", "combing", 2)
        ].forEach { title, desc, cat, priority in
            careTips.append(CareTip(id: UUID(), title: title,
                tipDescription: desc, mediaURL: nil, category: cat,
                benefits: "Reduces breakage and supports hair growth",
                actionSteps: nil, priority: priority))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 11 — Home Remedies
    // ─────────────────────────────────────────────

    private func seedHomeRemedies() {
        [("Onion Juice Scalp Treatment",
          "Sulphur in onion juice boosts collagen and improves circulation to follicles.",
          "Reduces hair fall and promotes regrowth",
          "Blend 1 onion, strain juice, apply to scalp 30 min, wash with mild shampoo. Twice a week."),
         ("Aloe Vera Scalp Mask",
          "Proteolytic enzymes repair dead skin cells on the scalp and condition hair.",
          "Soothes dry scalp, reduces dandruff, strengthens hair",
          "Apply fresh aloe gel to scalp and hair. Leave 45 min. Rinse with cool water."),
         ("Fenugreek Seed Hair Mask",
          "Fenugreek contains lecithin and proteins that strengthen hair shafts.",
          "Reduces hair fall and adds shine",
          "Soak 2 tbsp seeds overnight, grind to paste, mix with yogurt. Apply 30 min, wash off."),
         ("Egg & Olive Oil Mask",
          "Egg yolk provides biotin; olive oil adds moisture and shine.",
          "Deep conditioning, reduces dryness",
          "Mix 1 egg yolk with 2 tbsp olive oil. Apply 20 min. Rinse with cool water.")
        ].forEach { title, desc, benefits, instructions in
            homeRemedies.append(HomeRemedy(id: UUID(), title: title,
                remedyDescription: desc, mediaURL: nil,
                benefits: benefits, instructions: instructions))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 12 — Daily Tips
    // ─────────────────────────────────────────────

    private func seedDailyTips() {
        ["Drink a glass of water first thing in the morning to kickstart metabolism.",
         "Pumpkin seeds are rich in zinc — add a handful to your snack today.",
         "A 10-min walk after meals improves nutrient absorption and reduces stress.",
         "Comb gently from ends to roots to prevent breakage and stimulate the scalp.",
         "One egg at breakfast gives you biotin directly linked to keratin production.",
         "7–8 hrs of sleep allows hair cells to repair — aim for a consistent bedtime.",
         "5-minute scalp massage daily improves blood circulation to follicles."
        ].enumerated().forEach { i, tip in
            dailyTips.append(DailyTip(id: UUID(), tipText: tip,
                category: "hair_health",
                displayDate: Calendar.current.date(byAdding: .day, value: i, to: Date())))
        }
    }

    // ─────────────────────────────────────────────
    // MARK: 13 — Settings
    // ─────────────────────────────────────────────

    private func seedSettings(userId: UUID) {
        let tdee = userNutritionProfiles.first(where: { $0.userId == userId })?.tdee ?? 2038
        appPreferences.append(AppPreferences(id: UUID(), userId: userId,
            preferMetricUnits: true, vegFilterDefault: false,
            defaultMealType: .breakfast,
            dailyCalorieGoal: tdee,
            dailyMindfulMinutesGoal: 80,  // Plan 2A: 20+45+15
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

//    var latestScanReport: ScanReport? {
//        scanReports
//            .filter { r in scalpScans.contains(where: { $0.id == r.scalpScanId && $0.userId == currentUserId }) }
//            .sorted(by: { $0.createdAt > $1.createdAt })
//            .first
//    }
    var latestScanReport: ScanReport? {
        // Always follow the active plan's scanReportId first —
        // this guarantees the report matches what the engine just wrote,
        // even when timestamps are identical (e.g. seed + live run same launch).
        if let plan = activePlan,
           let linked = scanReports.first(where: { $0.id == plan.scanReportId }) {
            return linked
        }
        // Fallback: sort by date if no active plan exists yet
        return scanReports
            .filter { r in scalpScans.contains(where: { $0.id == r.scalpScanId && $0.userId == currentUserId }) }
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
    }

    func todaysMealEntries() -> [MealEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == today
        }.sorted(by: { $0.mealType.caloriePercent > $1.mealType.caloriePercent })
    }

    /// Returns all meal entries for a given date — used by calendar rings and Profile meal log.
    func mealEntries(for date: Date) -> [MealEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == dayStart
        }.sorted(by: { $0.mealType.displayOrder < $1.mealType.displayOrder })
    }

    /// Total logged calories for a given date
    func totalCalories(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.caloriesConsumed }
    }

    /// Total calorie target for a given date
    func totalCalorieTarget(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.calorieTarget }
    }

    /// 7-day calorie totals (Sun→Sat of current week) for the bar chart.
    func weeklyCalorieTotals() -> [(day: String, consumed: Float, target: Float)] {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        let today = Date()
        let weekday = cal.component(.weekday, from: today) // 1 = Sun
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: today))!

        return (0..<7).map { offset in
            let date = cal.date(byAdding: .day, value: offset, to: startOfWeek)!
            return (day: fmt.string(from: date),
                    consumed: totalCalories(for: date),
                    target: totalCalorieTarget(for: date))
        }
    }

    // MARK: - MindEase helpers

    /// Mindful minutes completed on a given date
    func mindfulMinutes(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindfulSessions
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    /// Daily mindful target from the user's active plan (yoga + meditation + sounds minutes)
    var dailyMindfulTarget: Int {
        guard let plan = userPlans.first(where: { $0.userId == currentUserId }) else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    func foods(for mealType: MealType, vegetarianOnly: Bool = false) -> [Food] {
        foods
            .filter { $0.suitableMealTypes.contains(mealType) && (!vegetarianOnly || $0.isVegetarian) }
            .sorted(by: {
                // Plan 2A priority: biotin + zinc + iron ranked higher
                let aScore = ($0.isBiotinRich ? 1 : 0) + ($0.isZincRich ? 1 : 0) + ($0.isIronRich ? 1 : 0)
                let bScore = ($1.isBiotinRich ? 1 : 0) + ($1.isZincRich ? 1 : 0) + ($1.isIronRich ? 1 : 0)
                return aScore > bScore
            })
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

    // ─────────────────────────────────────────────
    // MARK: - DietMate Logic
    // ─────────────────────────────────────────────

    /// Recalculate meal totals whenever a food is added/removed
    func updateMealEntryTotals(mealEntryId: UUID) {
        guard let idx = mealEntries.firstIndex(where: { $0.id == mealEntryId }) else { return }
        let linked = mealFoods.filter { $0.mealEntryId == mealEntryId }

        var cal: Float = 0; var pro: Float = 0; var carb: Float = 0; var fat: Float = 0
        for mf in linked {
            if let food = foods.first(where: { $0.id == mf.foodId }) {
                let avg = (food.totalCaloriesMin + food.totalCaloriesMax) / 2
                cal  += avg * mf.quantity
                pro  += food.totalProteinsInGm * mf.quantity
                carb += food.totalCarbsInGm    * mf.quantity
                fat  += food.totalFatInGm      * mf.quantity
            }
        }

        mealEntries[idx].caloriesConsumed = cal
        mealEntries[idx].proteinConsumed  = pro
        mealEntries[idx].carbsConsumed    = carb
        mealEntries[idx].fatConsumed      = fat

        let target  = mealEntries[idx].calorieTarget
        let minSafe = target * 0.70            // below 70% = under (blocked)

        mealEntries[idx].goalStatus = cal < minSafe  ? .under
                                    : cal <= target * 1.10 ? .met
                                    : .exceeded
    }

    func addFood(_ food: Food, to mealEntryId: UUID, quantity: Float = 1.0) {
        mealFoods.append(MealFood(id: UUID(), mealEntryId: mealEntryId,
                                  foodId: food.id, quantity: quantity))
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    func removeFood(mealFoodId: UUID, from mealEntryId: UUID) {
        mealFoods.removeAll(where: { $0.id == mealFoodId })
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    func incrementFood(mealFoodId: UUID, mealEntryId: UUID) {
        guard let idx = mealFoods.firstIndex(where: { $0.id == mealFoodId }) else { return }
        mealFoods[idx].quantity += 1
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    /// Decrements quantity by 1; removes the MealFood entirely when quantity would drop to 0.
    func decrementOrRemoveFood(mealFoodId: UUID, mealEntryId: UUID) {
        guard let idx = mealFoods.firstIndex(where: { $0.id == mealFoodId }) else { return }
        if mealFoods[idx].quantity > 1 {
            mealFoods[idx].quantity -= 1
            updateMealEntryTotals(mealEntryId: mealEntryId)
        } else {
            removeFood(mealFoodId: mealFoodId, from: mealEntryId)
        }
    }

    /// If the food is already in the meal, increments quantity; otherwise adds a new MealFood.
    func addOrIncrementFood(_ food: Food, to mealEntryId: UUID) {
        if let existing = mealFoods.first(where: { $0.mealEntryId == mealEntryId && $0.foodId == food.id }) {
            incrementFood(mealFoodId: existing.id, mealEntryId: mealEntryId)
        } else {
            addFood(food, to: mealEntryId)
        }
    }

    func mealGoalMessage(for entry: MealEntry) -> String {
        switch entry.goalStatus {
        case .met:
            return "Goal met! Great choices for your hair health."
        case .exceeded:
            let over = Int(entry.caloriesConsumed - entry.calorieTarget)
            return "\(over) kcal over target — logged anyway."
        case .under:
            let remaining = Int(entry.calorieTarget * 0.70 - entry.caloriesConsumed)
            return "Add \(remaining) more kcal before logging."
        }
    }

    // ─────────────────────────────────────────────
    // MARK: - MindEase Session Tracking
    // ─────────────────────────────────────────────

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

    func todaysTotalMacros() -> (protein: Double, carbs: Double, fat: Double) {
        let entries = todaysMealEntries()
        return (
            protein: Double(entries.reduce(0) { $0 + $1.proteinConsumed }),
            carbs:   Double(entries.reduce(0) { $0 + $1.carbsConsumed }),
            fat:     Double(entries.reduce(0) { $0 + $1.fatConsumed })
        )
    }

    // ─────────────────────────────────────────────
    // MARK: - Water Intake Helpers
    // ─────────────────────────────────────────────

    /// All water log entries for a given calendar day, sorted by time
    func waterIntakeLogs(for date: Date) -> [WaterIntakeLog] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return waterIntakeLogs
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.date) == dayStart
            }
            .sorted { $0.loggedAt < $1.loggedAt }
    }

    /// Total water consumed (ml) on a given day
    func totalWaterML(for date: Date) -> Float {
        waterIntakeLogs(for: date).reduce(0) { $0 + $1.cupSizeAmountInML }
    }

    /// Daily water goal from AppPreferences (default 2450 ml)
    var dailyWaterGoalML: Float {
        appPreferences.first(where: { $0.userId == currentUserId })?.dailyWaterGoalML ?? 2450
    }

    // ─────────────────────────────────────────────
    // MARK: - Sleep Record Helpers
    // ─────────────────────────────────────────────

    /// Sleep record for a given calendar day (nil if none)
    func sleepRecord(for date: Date) -> SleepRecord? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return sleepRecords.first {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == dayStart
        }
    }

    /// Dates that have sleep records, sorted newest first (up to 14 days)
    var sleepHistoryDates: [Date] {
        let cal = Calendar.current
        let unique = Set(
            sleepRecords
                .filter { $0.userId == currentUserId }
                .map { cal.startOfDay(for: $0.date) }
        )
        return unique.sorted(by: >)
    }

    /// Dates that have water intake logs, sorted newest first (up to 14 days)
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
