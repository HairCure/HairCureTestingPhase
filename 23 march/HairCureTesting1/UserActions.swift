//
//  UserAction.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
//  UserActions.swift
//  HairCure
//
//  All user-triggered actions — every tap, log, and entry the user performs.
//  Written as an extension on AppDataStore so views call store.action() directly.
//
//  Each method:
//    1. Validates the input
//    2. Writes to the correct array(s)
//    3. Returns an ActionResult so the view knows what to show
//
//  No SwiftData / backend calls here.
//  When moving to backend, replace array mutations with API calls
//  and keep the same method signatures.
//

import Foundation
import Observation

// MARK: - Action Result
//
//  Every user action returns ActionResult.
//  Views use this to show success banners, error alerts, or redirect screens.

enum ActionResult {
    case success(message: String)
    case blocked(reason: String)        // action prevented (e.g. calorie deficit)
    case warning(message: String)       // action allowed but user should know something
    case planUpdated(newPlanId: String, reason: String, highlights: [String])
    case referDoctor(message: String)
    case noChange
}

// MARK: - AppDataStore User Actions Extension

extension AppDataStore {

    // ─────────────────────────────────────────────
    // MARK: 1 — Assessment Flow
    // ─────────────────────────────────────────────

    /// User taps a single-choice option.
    /// Looks up score from QuestionScoreMap and stores it with the answer.
    @discardableResult
    func saveAnswer(questionId: UUID, selectedOptionId: UUID) -> ActionResult {

        // Remove any previous answer for this question in the current assessment
        let currentAssessmentId = assessments.last(where: { $0.userId == currentUserId })?.id
        userAnswers.removeAll(where: {
            $0.questionId == questionId &&
            $0.assessmentId == (currentAssessmentId ?? UUID())
        })

        guard let assessment = assessments.last(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "No active assessment found.")
        }

        // Look up score for this option
        let scoreMap   = questionScoreMaps.first(where: { $0.optionId == selectedOptionId })
        let scoreValue = scoreMap?.scoreValue
        let scoreDim   = scoreMap?.scoreDimension

        let answer = UserAnswer(
            id: UUID(),
            answeredAt: Date(),
            questionId: questionId,
            assessmentId: assessment.id,
            selectedOptionId: selectedOptionId,
            selectedOptionIds: [],
            answerText: nil,
            pickerValue: nil,
            scoreValue: scoreValue,
            scoreDimension: scoreDim
        )
        userAnswers.append(answer)

        // Update completion percent
        updateAssessmentProgress()

        return .success(message: "Answer saved.")
    }

    /// User selects multiple options (e.g. scalp symptoms Q3).
    @discardableResult
    func saveMultiAnswer(questionId: UUID, selectedOptionIds: [UUID]) -> ActionResult {

        guard let assessment = assessments.last(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "No active assessment found.")
        }

        userAnswers.removeAll(where: {
            $0.questionId == questionId && $0.assessmentId == assessment.id
        })

        let answer = UserAnswer(
            id: UUID(),
            answeredAt: Date(),
            questionId: questionId,
            assessmentId: assessment.id,
            selectedOptionId: nil,
            selectedOptionIds: selectedOptionIds,
            answerText: nil,
            pickerValue: nil,
            scoreValue: nil,
            scoreDimension: Optional.none
        )
        userAnswers.append(answer)
        updateAssessmentProgress()

        return .success(message: "Answer saved.")
    }

    /// User scrolls height / weight / age picker.
    @discardableResult
    func savePickerAnswer(questionId: UUID, pickerValue: Float) -> ActionResult {

        guard let assessment = assessments.last(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "No active assessment found.")
        }

        userAnswers.removeAll(where: {
            $0.questionId == questionId && $0.assessmentId == assessment.id
        })

        let answer = UserAnswer(
            id: UUID(),
            answeredAt: Date(),
            questionId: questionId,
            assessmentId: assessment.id,
            selectedOptionId: nil,
            selectedOptionIds: [],
            answerText: nil,
            pickerValue: pickerValue,
            scoreValue: nil,
            scoreDimension: Optional.none
        )
        userAnswers.append(answer)
        updateAssessmentProgress()

        return .success(message: "Value saved.")
    }

    /// User taps Continue on the last assessment question.
    /// Marks assessment complete — ready for hair analysis step.
    @discardableResult
    func completeAssessment() -> ActionResult {
        guard let idx = assessments.lastIndex(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "No active assessment found.")
        }
        assessments[idx].completionPercent = 100
        assessments[idx].completedAt = Date()
        return .success(message: "Assessment complete.")
    }

    /// Creates a fresh assessment when the user starts onboarding.
    func startAssessment() {
        // Remove any incomplete assessment
        assessments.removeAll(where: { $0.userId == currentUserId && $0.completedAt == nil })

        let assessment = Assessment(
            id: UUID(),
            userId: currentUserId,
            completionPercent: 0,
            completedAt: nil
        )
        assessments.append(assessment)

        // Clear any previous answers for this user
        userAnswers.removeAll(where: { answer in
            assessments.contains(where: { $0.id == answer.assessmentId && $0.userId == currentUserId })
        })
    }

    private func updateAssessmentProgress() {
        guard let idx = assessments.lastIndex(where: { $0.userId == currentUserId }) else { return }
        let assessmentId = assessments[idx].id
        let answered = userAnswers.filter { $0.assessmentId == assessmentId }.count
        let total    = questions.filter { $0.questionOrderIndex <= 12 }.count  // 12 main Qs
        let percent  = total > 0 ? Float(answered) / Float(total) * 100 : 0
        assessments[idx].completionPercent = min(percent, 99)  // 100 only on completeAssessment()
    }

    // ─────────────────────────────────────────────
    // MARK: 2 — Hair Analysis & Engine Trigger
    // ─────────────────────────────────────────────

    /// User submits 4 scalp photos (AI path).
    /// In mock mode we simulate AI returning stage/scalp/density.
    /// In production, replace the mock AI result with a real API call.
    @discardableResult
    func submitScanImages(
        frontURL: String, leftURL: String,
        rightURL: String, backURL: String, topURL: String,
        scanType: ScanType = .initial
    ) -> ActionResult {

        guard let profile    = currentProfile,
              let assessment = assessments.last(where: { $0.userId == currentUserId }),
              assessment.completedAt != nil
        else {
            return .blocked(reason: "Please complete the assessment before scanning.")
        }

        let scanId = UUID()
        let scan = ScalpScan(
            id: scanId, userId: currentUserId, scanDate: Date(),
            frontImageURL: frontURL, leftImageURL: leftURL,
            rightImageURL: rightURL, backImageURL: backURL,
            topImageURL: topURL, scanType: scanType
        )
        scalpScans.append(scan)

        // ── Mock AI result ──
        // In production: call AI model API here and await its response.
        // The mock returns Stage 2 + dry scalp + low density for Arjun.
        let mockStage:   HairFallStage   = .stage2
        let mockScalp:   ScalpCondition  = .dry
        let mockDensity: HairDensityLevel = .low
        let mockDensityPercent: Float    = 52.0

        return runEngineAndApply(
            scanId: scanId,
            stage: mockStage, scalp: mockScalp,
            density: mockDensity, densityPercent: mockDensityPercent,
            source: .aiModel,
            profile: profile, assessment: assessment
        )
    }

    /// User picks stage, scalp, density manually (fallback path).
    @discardableResult
    func submitSelfAssessedStage(
        stage: HairFallStage,
        scalp: ScalpCondition,
        density: HairDensityLevel,
        scanType: ScanType = .initial
    ) -> ActionResult {

        guard let profile    = currentProfile,
              let assessment = assessments.last(where: { $0.userId == currentUserId }),
              assessment.completedAt != nil
        else {
            return .blocked(reason: "Please complete the assessment first.")
        }

        // Stage 4 → immediate doctor redirect, skip engine
        if stage == .stage4 {
            return .referDoctor(message: RecommendationEngine.buildPlanDescription(
                planId: "refer_doctor",
                scalpCondition: scalp,
                scores: RecommendationEngine.LifestyleScores(
                    diet: 5, stress: 5, sleep: 5, hairCare: 5, hydration: 5, composite: 5)
            ).doctorReferralMessage ?? "")
        }

        let scanId = UUID()
        scalpScans.append(ScalpScan(
            id: scanId, userId: currentUserId, scanDate: Date(),
            frontImageURL: "self_assessed_front", leftImageURL: "self_assessed_left",
            rightImageURL: "self_assessed_right", backImageURL: "self_assessed_back",
            topImageURL: "self_assessed_top", scanType: scanType
        ))

        let densityPercent: Float
        switch density {
        case .high:    densityPercent = 85
        case .medium:  densityPercent = 65
        case .low:     densityPercent = 45
        case .veryLow: densityPercent = 25
        }

        return runEngineAndApply(
            scanId: scanId,
            stage: stage, scalp: scalp,
            density: density, densityPercent: densityPercent,
            source: .selfAssessed,
            profile: profile, assessment: assessment
        )
    }

    /// Core helper: builds EngineInput from answers + scan data and runs the engine.
    private func runEngineAndApply(
        scanId: UUID,
        stage: HairFallStage,
        scalp: ScalpCondition,
        density: HairDensityLevel,
        densityPercent: Float,
        source: AnalysisSource,
        profile: UserProfile,
        assessment: Assessment
    ) -> ActionResult {

        // Extract physical values from picker answers
        let age      = pickerValue(for: "age",    assessment: assessment, default: Float(ageFromProfile(profile)))
        let heightCm = pickerValue(for: "height", assessment: assessment, default: profile.heightCm)
        let weightKg = pickerValue(for: "weight", assessment: assessment, default: profile.weightKg)
        let activity = resolvedActivityLevel(from: assessment)

        let input = EngineInput(
            userId: currentUserId,
            assessmentId: assessment.id,
            answers: userAnswers.filter { $0.assessmentId == assessment.id },
            hairFallStage: stage,
            scalpCondition: scalp,
            hairDensityLevel: density,
            hairDensityPercent: densityPercent,
            analysisSource: source,
            scalpScanId: scanId,
            age: Int(age),
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activity
        )

        let output = RecommendationEngine.run(input: input, store: self)
        RecommendationEngine.applyToStore(output, store: self)

        if output.userPlan.planId == "refer_doctor" {
            return .referDoctor(message: output.planDescription.doctorReferralMessage ?? "")
        }

        return .success(message: "Plan \(output.userPlan.planId) assigned.")
    }

    // ─────────────────────────────────────────────
    // MARK: 3 — DietMate — Meal Logging
    // ─────────────────────────────────────────────

    /// User taps + on a food card in the food grid.
    /// Adds food to the meal slot and recalculates calorie totals.
    @discardableResult
    func addFoodToMeal(
        food: Food,
        mealType: MealType,
        quantity: Float = 1.0
    ) -> ActionResult {

        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return .blocked(reason: "No meal slot found for \(mealType.displayName) today.")
        }

        // Prevent adding to an already-logged slot
        if entry.isLogged {
            return .blocked(reason: "\(mealType.displayName) is already logged. Tap edit to make changes.")
        }

        // Add food
        mealFoods.append(MealFood(
            id: UUID(), mealEntryId: entry.id,
            foodId: food.id, quantity: quantity
        ))
        updateMealEntryTotals(mealEntryId: entry.id)

        // Re-fetch updated entry
        guard let updated = mealEntries.first(where: { $0.id == entry.id }) else {
            return .success(message: "\(food.name) added.")
        }

        let check = RecommendationEngine.checkCalorieGoal(
            consumed: updated.caloriesConsumed,
            target: updated.calorieTarget
        )

        switch check.goalStatus {
        case .met:
            return .success(message: "✅ \(food.name) added! \(mealType.displayName) goal met.")
        case .exceeded:
            let over = Int(updated.caloriesConsumed - updated.calorieTarget)
            return .warning(message: "⚠️ \(food.name) added. You're \(over) kcal over your \(mealType.displayName) target.")
        case .under:
            let remaining = Int(updated.calorieTarget - updated.caloriesConsumed)
            return .success(message: "\(food.name) added. \(remaining) kcal remaining for \(mealType.displayName).")
        }
    }

    /// User removes a food from a meal slot.
    @discardableResult
    func removeFoodFromMeal(mealFoodId: UUID, mealType: MealType) -> ActionResult {

        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return .noChange }

        if entry.isLogged {
            return .blocked(reason: "Unlog \(mealType.displayName) first to edit foods.")
        }

        guard mealFoods.contains(where: { $0.id == mealFoodId }) else {
            return .blocked(reason: "Food not found.")
        }

        mealFoods.removeAll(where: { $0.id == mealFoodId })
        updateMealEntryTotals(mealEntryId: entry.id)

        return .success(message: "Food removed from \(mealType.displayName).")
    }

    /// User types in a custom food (something not in the backend food list).
    @discardableResult
    func addCustomFood(
        name: String,
        calories: Float,
        proteinGm: Float,
        carbsGm: Float,
        fatGm: Float,
        mealType: MealType
    ) -> ActionResult {

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .blocked(reason: "Please enter a food name.")
        }
        guard calories > 0 else {
            return .blocked(reason: "Calories must be greater than 0.")
        }

        // Create a custom Food record
        let customFood = Food(
            id: UUID(), externalFoodId: nil,
            name: name, imageURL: nil,
            foodType: "custom", isVegetarian: false,
            isCustom: true, createdByUserId: currentUserId,
            servingSizeGrams: 100, apiSource: nil,
            totalCaloriesMin: calories, totalCaloriesMax: calories,
            totalProteinsInGm: proteinGm, totalCarbsInGm: carbsGm,
            totalFatInGm: fatGm, totalVitaminsInMg: 0,
            isBiotinRich: false, isZincRich: false,
            isIronRich: false, isOmega3Rich: false, isVitaminARich: false,
            suitableMealTypes: MealType.allCases,
            createdAt: Date()
        )
        foods.append(customFood)

        return addFoodToMeal(food: customFood, mealType: mealType, quantity: 1.0)
    }

    /// User taps the checkmark to log a meal slot.
    /// Validates calorie goal — blocks if under 70% of target.
    @discardableResult
    func logMealEntry(mealType: MealType) -> ActionResult {

        guard let idx = mealEntries.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return .blocked(reason: "No \(mealType.displayName) entry found for today.")
        }

        let entry = mealEntries[idx]

        if entry.isLogged {
            return .warning(message: "\(mealType.displayName) is already logged.")
        }

        let check = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed,
            target: entry.calorieTarget
        )

        // Under threshold — block logging
        if !check.canLog {
            return .blocked(reason: check.message)
        }

        mealEntries[idx].isLogged = true
        mealEntries[idx].loggedAt = Date()
        mealEntries[idx].goalStatus = check.goalStatus

        if check.goalStatus == .exceeded {
            return .warning(message: check.message)
        }
        return .success(message: check.message)
    }

    /// User taps edit on a logged meal — unlogs so they can modify foods.
    @discardableResult
    func unlogMealEntry(mealType: MealType) -> ActionResult {

        guard let idx = mealEntries.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return .noChange }

        mealEntries[idx].isLogged = false
        mealEntries[idx].loggedAt = nil

        return .success(message: "\(mealType.displayName) unlocked for editing.")
    }

    /// Returns all foods currently added to a meal slot today (for display in slot card).
    func foodsInMealEntry(mealType: MealType) -> [(mealFood: MealFood, food: Food)] {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return [] }

        return mealFoods
            .filter { $0.mealEntryId == entry.id }
            .compactMap { mf in
                guard let food = foods.first(where: { $0.id == mf.foodId }) else { return nil }
                return (mealFood: mf, food: food)
            }
    }

    /// Calorie summary for a meal slot — used by the goal progress bar.
    func mealCalorieSummary(mealType: MealType) -> (consumed: Float, target: Float, status: MealGoalStatus) {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return (0, 0, .under) }

        return (entry.caloriesConsumed, entry.calorieTarget, entry.goalStatus)
    }

    // ─────────────────────────────────────────────
    // MARK: 4 — MindEase — Session Tracking
    // ─────────────────────────────────────────────

    // In-memory session start times (not persisted — reset on app restart, fine for mock)
//    private var _sessionStartTimes: [UUID: Date] = [:]
//
//    var sessionStartTimes: [UUID: Date] {
//        get { _sessionStartTimes }
//        set { _sessionStartTimes = newValue }
//    }

    /// User taps Start on a session card — records when they began.
    func startSession(contentId: UUID) {
        sessionStartTimes[contentId] = Date()
    }

    /// User finishes or exits a session — logs the minutes completed.
    /// minutesCompleted = actual time spent (may be less than target if they exit early).
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

        // Mark today's plan complete if this is the assigned session
        if let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) {
            todaysPlans[idx].minutesCompleted = minutesCompleted
            todaysPlans[idx].isCompleted = minutesCompleted >= todaysPlans[idx].minutesTarget
        }

        // Update lastPlaybackSeconds on content record
        if let idx = mindEaseCategoryContents.firstIndex(where: { $0.id == contentId }) {
            mindEaseCategoryContents[idx].lastPlaybackSeconds = minutesCompleted * 60
        }

        let target = todaysPlans.first(where: {
            $0.userId == currentUserId && $0.contentId == contentId
        })?.minutesTarget ?? minutesCompleted

        if minutesCompleted >= target {
            return .success(message: "✅ Session complete! \(minutesCompleted) min logged.")
        } else {
            return .warning(message: "Session logged — \(minutesCompleted)/\(target) min completed.")
        }
    }

    /// Total mindful minutes completed today across all sessions.
    func todaysMindfulMinutes() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return mindfulSessions
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == today
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    /// Weekly mindful minutes — array of 7 values (Sun→Sat) for bar chart on home.
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

    // ─────────────────────────────────────────────
    // MARK: 5 — Water Intake
    // ─────────────────────────────────────────────

    /// User taps "Add" after selecting cup size.
    @discardableResult
    func logWaterIntake(cupSize: String, amountML: Float) -> ActionResult {

        guard amountML > 0 else {
            return .blocked(reason: "Invalid water amount.")
        }

        waterIntakeLogs.append(WaterIntakeLog(
            id: UUID(), userId: currentUserId,
            date: Date(), cupSize: cupSize,
            cupSizeAmountInML: amountML, loggedAt: Date()
        ))

        let totalToday = todaysTotalWaterML()
        let target     = activeNutritionProfile?.waterTargetML ?? 2500
        let remaining  = max(0, target - totalToday)

        if totalToday >= target {
            return .success(message: "💧 Daily water goal reached! Great job.")
        }
        return .success(message: "💧 +\(Int(amountML)) ml logged. \(Int(remaining)) ml remaining today.")
    }

    /// User removes a water log entry.
    @discardableResult
    func removeWaterEntry(id: UUID) -> ActionResult {
        guard waterIntakeLogs.contains(where: { $0.id == id && $0.userId == currentUserId }) else {
            return .blocked(reason: "Water entry not found.")
        }
        waterIntakeLogs.removeAll(where: { $0.id == id })
        return .success(message: "Water entry removed.")
    }

    /// Total water logged today in ML.
    func todaysTotalWaterML() -> Float {
        let today = Calendar.current.startOfDay(for: Date())
        return waterIntakeLogs
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.loggedAt) == today
            }
            .reduce(0) { $0 + $1.cupSizeAmountInML }
    }

    /// Today's water log entries for the list display.
    func todaysWaterLogs() -> [WaterIntakeLog] {
        let today = Calendar.current.startOfDay(for: Date())
        return waterIntakeLogs
            .filter {
                $0.userId == currentUserId &&
                Calendar.current.startOfDay(for: $0.loggedAt) == today
            }
            .sorted(by: { $0.loggedAt > $1.loggedAt })
    }

    /// 7-day water totals (ML) for the weekly bar chart.
    func weeklyWaterTotals() -> [(day: String, totalML: Float)] {
        let cal   = Calendar.current
        let fmt   = DateFormatter()
        fmt.dateFormat = "EEE"
        return (0..<7).map { daysAgo in
            let date  = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
            let start = cal.startOfDay(for: date)
            let total = waterIntakeLogs
                .filter { $0.userId == currentUserId && cal.startOfDay(for: $0.loggedAt) == start }
                .reduce(0) { $0 + $1.cupSizeAmountInML }
            return (day: fmt.string(from: date), totalML: total)
        }.reversed()
    }

    // ─────────────────────────────────────────────
    // MARK: 6 — Sleep Tracking
    // ─────────────────────────────────────────────

    /// User sets bed + wake times. Overwrites today's record if one exists.
    @discardableResult
    func saveSleepRecord(
        bedTime: Date,
        wakeTime: Date,
        alarmEnabled: Bool,
        alarmTime: Date? = nil
    ) -> ActionResult {

        // Calculate hours slept — handle crossing midnight
        var diff = wakeTime.timeIntervalSince(bedTime)
        if diff < 0 { diff += 86400 }    // add 24 hrs if wake is "next day"
        let hours = Float(diff / 3600)

        let record = SleepRecord(
            id: UUID(), userId: currentUserId, date: Date(),
            bedTime: bedTime, wakeTime: wakeTime,
            alarmEnabled: alarmEnabled,
            alarmTime: alarmEnabled ? (alarmTime ?? wakeTime) : nil,
            hoursSlept: (hours * 10).rounded() / 10   // 1 decimal place
        )

        // Replace today's record if exists
        let today = Calendar.current.startOfDay(for: Date())
        sleepRecords.removeAll(where: {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == today
        })
        sleepRecords.append(record)

        let quality: String
        switch hours {
        case 7...: quality = "✅ Great sleep target!"
        case 6..<7: quality = "⚠️ Slightly under target — aim for 7+ hours."
        default:    quality = "⚠️ Poor sleep detected — this affects hair health."
        }

        return .success(message: "\(String(format: "%.1f", hours)) hours logged. \(quality)")
    }

    /// User flips the alarm toggle on the sleep screen.
    @discardableResult
    func toggleAlarm(enabled: Bool, alarmTime: Date? = nil) -> ActionResult {
        let today = Calendar.current.startOfDay(for: Date())

        guard let idx = sleepRecords.lastIndex(where: {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == today
        }) else {
            return .blocked(reason: "Set your sleep schedule first.")
        }

        sleepRecords[idx].alarmEnabled = enabled
        if let time = alarmTime {
            sleepRecords[idx].alarmTime = time
        }

        return .success(message: enabled ? "Alarm set." : "Alarm turned off.")
    }

    /// Last night's sleep record.
    var lastNightSleep: SleepRecord? {
        sleepRecords
            .filter { $0.userId == currentUserId }
            .sorted(by: { $0.date > $1.date })
            .first
    }

    /// 7-day sleep history for the bar chart.
    func weeklySleepData() -> [(day: String, hours: Float)] {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return (0..<7).map { daysAgo in
            let date  = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
            let start = cal.startOfDay(for: date)
            let hrs   = sleepRecords.first(where: {
                $0.userId == currentUserId &&
                cal.startOfDay(for: $0.date) == start
            })?.hoursSlept ?? 0
            return (day: fmt.string(from: date), hours: hrs)
        }.reversed()
    }

    // ─────────────────────────────────────────────
    // MARK: 7 — Hair Insights & Favourites
    // ─────────────────────────────────────────────

    /// User taps the heart icon on an insight, care tip, or remedy.
    @discardableResult
    func toggleFavorite(contentId: UUID, contentType: String) -> ActionResult {

        if let idx = userFavorites.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            $0.contentType == contentType
        }) {
            userFavorites.remove(at: idx)
            return .success(message: "Removed from favourites.")
        } else {
            userFavorites.append(UserFavorite(
                id: UUID(), userId: currentUserId,
                contentType: contentType, contentId: contentId,
                savedAt: Date()
            ))
            return .success(message: "Saved to favourites. ❤️")
        }
    }

    /// Whether a content item is currently favourited — used by view to set heart state.
    func isFavorited(contentId: UUID, contentType: String) -> Bool {
        userFavorites.contains(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            $0.contentType == contentType
        })
    }

    /// All favourited insights for the "Your Favourites" section.
    var favouriteInsights: [HairInsight] {
        let ids = userFavorites
            .filter { $0.userId == currentUserId && $0.contentType == "hairInsight" }
            .map { $0.contentId }
        return hairInsights.filter { ids.contains($0.id) }
    }

    var favouriteCareTips: [CareTip] {
        let ids = userFavorites
            .filter { $0.userId == currentUserId && $0.contentType == "careTip" }
            .map { $0.contentId }
        return careTips.filter { ids.contains($0.id) }
    }

    var favouriteRemedies: [HomeRemedy] {
        let ids = userFavorites
            .filter { $0.userId == currentUserId && $0.contentType == "homeRemedy" }
            .map { $0.contentId }
        return homeRemedies.filter { ids.contains($0.id) }
    }

    /// Insights filtered for the current plan's stage + scalp condition.
    var recommendedInsights: [HairInsight] {
        guard let plan = activePlan else { return hairInsights }
        return RecommendationEngine.filteredInsights(from: hairInsights, plan: plan)
    }

    /// Today's daily tip.
    var todaysDailyTip: DailyTip? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyTips.first(where: { tip in
            guard let d = tip.displayDate else { return false }
            return Calendar.current.startOfDay(for: d) == today
        }) ?? dailyTips.first
    }

    // ─────────────────────────────────────────────
    // MARK: 8 — Weekly Re-scan
    // ─────────────────────────────────────────────

    /// User submits a weekly scan (images or self-assessed).
    /// Runs the engine and checks if the plan should change.
    @discardableResult
    func submitWeeklyScan(
        stage: HairFallStage,
        scalp: ScalpCondition,
        density: HairDensityLevel,
        isAIModel: Bool = false
    ) -> ActionResult {

        guard let profile    = currentProfile,
              let assessment = assessments.last(where: { $0.userId == currentUserId })
        else { return .blocked(reason: "No assessment found.") }

        // Build new scores from the same assessment answers
        let newScores = RecommendationEngine.calculateLifestyleScores(
            answers: userAnswers.filter { $0.assessmentId == assessment.id },
            store: self
        )

        // Check if plan needs to change
        if let currentPlan = activePlan {
            let update = RecommendationEngine.evaluatePlanUpdate(
                currentPlan: currentPlan,
                newStage: stage,
                newScores: newScores
            )

            if update.shouldUpdate {
                // Re-run engine with new data
                let result = submitSelfAssessedStage(
                    stage: stage, scalp: scalp,
                    density: density, scanType: .weekly
                )
                if case .success = result {
                    return .planUpdated(
                        newPlanId: update.newPlanId,
                        reason: update.reason,
                        highlights: update.highlights
                    )
                }
                return result
            } else {
                // Save scan record but keep plan unchanged
                let scanId = UUID()
                scalpScans.append(ScalpScan(
                    id: scanId, userId: currentUserId, scanDate: Date(),
                    frontImageURL: "weekly_front", leftImageURL: "weekly_left",
                    rightImageURL: "weekly_right", backImageURL: "weekly_back",
                    topImageURL: "weekly_top", scanType: .weekly
                ))

                let densityPct: Float
                switch density {
                case .high: densityPct = 85; case .medium: densityPct = 65
                case .low:  densityPct = 45; case .veryLow: densityPct = 25
                }

                scanReports.append(ScanReport(
                    id: UUID(), createdAt: Date(), scalpScanId: scanId,
                    hairDensityPercent: densityPct, hairDensityLevel: density,
                    hairFallStage: stage, scalpCondition: scalp,
                    analysisSource: isAIModel ? .aiModel : .selfAssessed,
                    planId: currentPlan.planId,
                    lifestyleScore: newScores.composite,
                    dietScore: newScores.diet, stressScore: newScores.stress,
                    sleepScore: newScores.sleep, hairCareScore: newScores.hairCare,
                    recommendedPlan: RecommendationEngine.planSummaryText(for: currentPlan.planId)
                ))

                return .success(message: "Weekly scan saved. Your plan \(currentPlan.planId) remains unchanged. \(update.reason)")
            }
        }

        // No active plan — treat as initial scan
        return submitSelfAssessedStage(stage: stage, scalp: scalp, density: density, scanType: .weekly)
    }

    // ─────────────────────────────────────────────
    // MARK: 9 — Profile & Settings Updates
    // ─────────────────────────────────────────────

    /// User updates physical data in their profile — triggers BMR recalculation.
    @discardableResult
    func updatePhysicalProfile(
        heightCm: Float? = nil,
        weightKg: Float? = nil,
        activityLevel: ActivityLevel? = nil
    ) -> ActionResult {

        guard let idx = userProfiles.firstIndex(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "Profile not found.")
        }

        if let h = heightCm { userProfiles[idx].heightCm = h }
        if let w = weightKg { userProfiles[idx].weightKg = w }

        let profile  = userProfiles[idx]
        let dob      = profile.dateOfBirth
        let age      = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 22
        let activity = activityLevel ?? activeNutritionProfile?.activityLevel ?? .sedentary

        // Recalculate nutrition
        let newNutrition = RecommendationEngine.calculateNutrition(
            userId: currentUserId,
            age: age, heightCm: profile.heightCm,
            weightKg: profile.weightKg, activityLevel: activity
        )

        userNutritionProfiles.removeAll(where: { $0.userId == currentUserId })
        userNutritionProfiles.append(newNutrition)

        // Rebuild today's meal entries with new budgets
        mealEntries.removeAll(where: {
            $0.userId == currentUserId && Calendar.current.isDateInToday($0.date) && !$0.isLogged
        })
        for (type, budget) in [(MealType.breakfast, newNutrition.breakfastCalTarget),
                               (.lunch, newNutrition.lunchCalTarget),
                               (.snack, newNutrition.snackCalTarget),
                               (.dinner, newNutrition.dinnerCalTarget)] {
            // Only recreate unlogged slots
            if !mealEntries.contains(where: {
                $0.userId == currentUserId &&
                $0.mealType == type &&
                Calendar.current.isDateInToday($0.date)
            }) {
                mealEntries.append(MealEntry(
                    id: UUID(), userId: currentUserId, mealType: type,
                    date: Date(), isLogged: false, loggedAt: nil,
                    calorieTarget: budget, caloriesConsumed: 0,
                    proteinConsumed: 0, carbsConsumed: 0, fatConsumed: 0,
                    goalStatus: .under
                ))
            }
        }

        // Sync app preferences
        if let prefIdx = appPreferences.firstIndex(where: { $0.userId == currentUserId }) {
            appPreferences[prefIdx].dailyCalorieGoal = newNutrition.tdee
            appPreferences[prefIdx].dailyWaterGoalML = newNutrition.waterTargetML
        }

        return .success(message: "Profile updated. Daily target: \(Int(newNutrition.tdee)) kcal.")
    }

    /// User changes notification preferences.
    @discardableResult
    func updateNotificationSettings(
        mealReminderEnabled: Bool? = nil,
        mindfulReminderEnabled: Bool? = nil,
        waterReminderEnabled: Bool? = nil,
        bedtimeReminderEnabled: Bool? = nil,
        weeklyScanReminderEnabled: Bool? = nil
    ) -> ActionResult {

        guard let idx = notificationSettings.firstIndex(where: { $0.userId == currentUserId }) else {
            return .blocked(reason: "Settings not found.")
        }

        if let v = mealReminderEnabled    { notificationSettings[idx].mealReminderEnabled    = v }
        if let v = mindfulReminderEnabled { notificationSettings[idx].mindfulReminderEnabled = v }
        if let v = waterReminderEnabled   { notificationSettings[idx].waterReminderEnabled   = v }
        if let v = bedtimeReminderEnabled { notificationSettings[idx].bedtimeReminderEnabled = v }
        if let v = weeklyScanReminderEnabled { notificationSettings[idx].weeklyScanReminderEnabled = v }

        return .success(message: "Notification settings updated.")
    }

    // ─────────────────────────────────────────────
    // MARK: 10 — Home Screen Computed Data
    // ─────────────────────────────────────────────

    /// Full daily progress summary — called by the home screen cards.
    var dailyProgress: RecommendationEngine.DailyProgressSummary {
        RecommendationEngine.buildDailyProgressSummary(store: self)
    }

    /// Hair care routine for the current plan and scalp condition.
    var currentHairCareRoutine: RecommendationEngine.HairCareRoutine? {
        guard let plan = activePlan else { return nil }
        return RecommendationEngine.buildHairCareRoutine(for: plan)
    }

    /// Ranked food list for a meal type — used by food grid in DietMate.
    func rankedFoods(for mealType: MealType, vegetarianOnly: Bool = false) -> [Food] {
        guard let plan = activePlan else {
            return foods(for: mealType, vegetarianOnly: vegetarianOnly)
        }
        return RecommendationEngine.rankedFoods(
            from: foods, for: mealType, plan: plan,
            vegetarianOnly: vegetarianOnly
        )
    }

    /// Total calories consumed today — for home tracker card.
    func todaysTotalCalories() -> Float {
        todaysMealEntries().reduce(0) { $0 + $1.caloriesConsumed }
    }

    /// How many meals have been logged today (out of 4).
    func todaysLoggedMealCount() -> Int {
        todaysMealEntries().filter { $0.isLogged }.count
    }

    // ─────────────────────────────────────────────
    // MARK: 11 — Calorie Bar Helper (DietMate UI)
    // ─────────────────────────────────────────────

    /// Data package for the calorie goal bar in each meal slot card.
    struct MealSlotSummary {
        let mealType: MealType
        let calorieTarget: Float
        let caloriesConsumed: Float
        let progress: Float              // 0.0 – 1.0 (clamped, for bar width)
        let overAmount: Float            // > 0 if exceeded
        let goalStatus: MealGoalStatus
        let isLogged: Bool
        let canLog: Bool                 // false if under 70% of target
        let statusMessage: String
        let foods: [(mealFood: MealFood, food: Food)]
    }

    func mealSlotSummary(for mealType: MealType) -> MealSlotSummary {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return MealSlotSummary(
                mealType: mealType, calorieTarget: 0, caloriesConsumed: 0,
                progress: 0, overAmount: 0, goalStatus: .under, isLogged: false,
                canLog: false, statusMessage: "No data",
                foods: []
            )
        }

        let check = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed, target: entry.calorieTarget
        )
        let progress = min(entry.caloriesConsumed / max(entry.calorieTarget, 1), 1.0)
        let over     = max(0, entry.caloriesConsumed - entry.calorieTarget)

        return MealSlotSummary(
            mealType: mealType,
            calorieTarget: entry.calorieTarget,
            caloriesConsumed: entry.caloriesConsumed,
            progress: progress,
            overAmount: over,
            goalStatus: check.goalStatus,
            isLogged: entry.isLogged,
            canLog: check.canLog,
            statusMessage: check.message,
            foods: foodsInMealEntry(mealType: mealType)
        )
    }

    // ─────────────────────────────────────────────
    // MARK: Private Helpers
    // ─────────────────────────────────────────────

    /// Reads a Float picker answer from the assessment by matching question order index.
    private func pickerValue(
        for key: String,
        assessment: Assessment,
        default fallback: Float
    ) -> Float {
        let orderIndex: Int
        switch key {
        case "age":    orderIndex = 9
        case "height": orderIndex = 10
        case "weight": orderIndex = 11
        default:       return fallback
        }
        guard let question = questions.first(where: { $0.questionOrderIndex == orderIndex }),
              let answer   = userAnswers.first(where: {
                  $0.questionId == question.id && $0.assessmentId == assessment.id
              })
        else { return fallback }

        return answer.pickerValue ?? fallback
    }

    /// Maps the Q12 "activity level" answer to an ActivityLevel enum value.
    private func resolvedActivityLevel(from assessment: Assessment) -> ActivityLevel {
        guard let q12 = questions.first(where: { $0.questionOrderIndex == 12 }),
              let answer = userAnswers.first(where: {
                  $0.questionId == q12.id && $0.assessmentId == assessment.id
              }),
              let optionId = answer.selectedOptionId,
              let option = questionOptions.first(where: { $0.id == optionId })
        else { return .sedentary }

        let text = option.optionText.lowercased()
        if text.contains("very active") { return .veryActive }
        if text.contains("moderate")   { return .moderate }
        if text.contains("light")      { return .light }
        return .sedentary
    }

    /// Calculates user's age from their profile date of birth.
    private func ageFromProfile(_ profile: UserProfile) -> Int {
        Calendar.current.dateComponents([.year], from: profile.dateOfBirth, to: Date()).year ?? 22
    }
}
