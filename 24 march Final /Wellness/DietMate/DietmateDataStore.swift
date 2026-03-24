//
//  DietmateDataStore.swift
//  HairCureTesting1
//
//  Separated DietMate data store — owns foods, mealEntries, mealFoods,
//  all seed data, helper functions, and user actions for DietMate.
//

import Foundation
import Observation

@Observable
class DietmateDataStore {

    // MARK: - Properties

    var foods: [Food] = []
    var mealEntries: [MealEntry] = []
    var mealFoods: [MealFood] = []

    // Shared references from AppDataStore (set during init)
    var currentUserId: UUID

    // Reference back to parent for nutrition profile & plan access
    weak var parentStore: AppDataStore?

    // MARK: - Init

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
    }

    func seedAll(userId: UUID, nutritionProfile: UserNutritionProfile?) {
        seedFoods()
        seedTodaysMealEntries(userId: userId, nutritionProfile: nutritionProfile)
        seedHistoricalMealData(userId: userId, nutritionProfile: nutritionProfile)
    }

    // ─────────────────────────────────────────────
    // MARK: - Seed Foods
    // ─────────────────────────────────────────────

    func seedFoods() {
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
            FoodSeed(name:"Paneer Stuffed Paratha",      img:"pannerParantha",    isVeg:true,  calMin:300,calMax:330,protein:12,carbs:38,fat:12,vitamins:4.5,serving:200, biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.breakfast,.dinner]),
            FoodSeed(name:"Vegetable Oats Upma",         img:"paneerParantha",     isVeg:true,  calMin:260,calMax:290,protein:9, carbs:42,fat:6, vitamins:6.2,serving:180, biotin:true, zinc:true, iron:true, omega3:false,vitA:false, meals:[.breakfast]),
            FoodSeed(name:"Curd with Flaxseeds & Fruits",img:"chaat",   isVeg:true,  calMin:280,calMax:310,protein:10,carbs:35,fat:9, vitamins:5.8,serving:200, biotin:true, zinc:true, iron:false,omega3:true, vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Methi Thepla",                img:"paneerParantha",      isVeg:true,  calMin:250,calMax:270,protein:7, carbs:36,fat:8, vitamins:9.2,serving:150, biotin:false,zinc:false,iron:true, omega3:false,vitA:true,  meals:[.breakfast,.lunch]),
            FoodSeed(name:"Moong Dal Chilla",            img:"paneerParantha",      isVeg:true,  calMin:220,calMax:250,protein:12,carbs:30,fat:5, vitamins:7.4,serving:150, biotin:true, zinc:true, iron:true, omega3:false,vitA:false, meals:[.breakfast,.lunch]),
            FoodSeed(name:"Spinach Dal (Palak Dal)",     img:"paneerParantha",         isVeg:true,  calMin:280,calMax:310,protein:14,carbs:38,fat:5, vitamins:12.0,serving:250,biotin:false,zinc:true, iron:true, omega3:false,vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Brown Rice & Lentils",        img:"brown_rice_lentils",isVeg:true,  calMin:320,calMax:360,protein:14,carbs:58,fat:3, vitamins:8.5,serving:280, biotin:false,zinc:true, iron:true, omega3:false,vitA:false, meals:[.lunch,.dinner]),
            FoodSeed(name:"Egg Bhurji",                  img:"paneerParantha",        isVeg:false, calMin:280,calMax:310,protein:18,carbs:6, fat:18,vitamins:5.2,serving:150, biotin:true, zinc:true, iron:true, omega3:true, vitA:true,  meals:[.breakfast,.lunch]),
            FoodSeed(name:"Grilled Chicken Salad",       img:"chicken_salad",     isVeg:false, calMin:290,calMax:320,protein:28,carbs:12,fat:10,vitamins:4.8,serving:200, biotin:false,zinc:true, iron:true, omega3:true, vitA:false, meals:[.lunch,.dinner]),
            FoodSeed(name:"Walnut & Banana Smoothie",    img:"walnut_smoothie",   isVeg:true,  calMin:300,calMax:330,protein:8, carbs:42,fat:14,vitamins:3.5,serving:300, biotin:true, zinc:false,iron:false,omega3:true, vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Pumpkin Seeds & Fruit Bowl",  img:"pumpkin_fruit",     isVeg:true,  calMin:220,calMax:250,protein:8, carbs:30,fat:10,vitamins:6.0,serving:100, biotin:true, zinc:true, iron:false,omega3:true, vitA:true,  meals:[.snack]),
            FoodSeed(name:"Almonds & Dates",             img:"almonds_dates",     isVeg:true,  calMin:200,calMax:230,protein:6, carbs:22,fat:12,vitamins:4.2,serving:60,  biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.snack]),
            FoodSeed(name:"Whole Wheat Roti + Sabzi",    img:"roti_sabzi",        isVeg:true,  calMin:350,calMax:390,protein:12,carbs:55,fat:8, vitamins:10.5,serving:250,biotin:false,zinc:false,iron:true, omega3:false,vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Paneer Tikka",                img:"paneer_tikka",      isVeg:true,  calMin:320,calMax:360,protein:20,carbs:12,fat:20,vitamins:3.8,serving:200, biotin:false,zinc:true, iron:false,omega3:false,vitA:true,  meals:[.dinner]),
            FoodSeed(name:"Fish Curry (Rohu)",           img:"fish_curry",        isVeg:false, calMin:300,calMax:340,protein:26,carbs:14,fat:12,vitamins:5.6,serving:250, biotin:true, zinc:true, iron:true, omega3:true, vitA:true,  meals:[.lunch,.dinner]),
            FoodSeed(name:"Oatmeal with Almonds",        img:"oats",   isVeg:true,  calMin:280,calMax:310,protein:10,carbs:44,fat:9, vitamins:4.0,serving:200, biotin:true, zinc:false,iron:true, omega3:false,vitA:false, meals:[.breakfast]),
            FoodSeed(name:"Greek Yogurt",                img:"greek_yogurt",      isVeg:true,  calMin:150,calMax:180,protein:15,carbs:12,fat:4, vitamins:2.5,serving:150, biotin:true, zinc:false,iron:false,omega3:false,vitA:false, meals:[.breakfast,.snack]),
            FoodSeed(name:"Chicken Soup",                img:"chicken_soup",      isVeg:false, calMin:200,calMax:240,protein:22,carbs:10,fat:7, vitamins:3.2,serving:350, biotin:false,zinc:true, iron:true, omega3:false,vitA:false, meals:[.lunch,.dinner]),
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
    // MARK: - Seed Today's Meal Entries
    // ─────────────────────────────────────────────

    func seedTodaysMealEntries(userId: UUID, nutritionProfile: UserNutritionProfile?) {
        guard let np = nutritionProfile else { return }
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
    // MARK: - Seed Historical Meal Data
    // ─────────────────────────────────────────────

    func seedHistoricalMealData(userId: UUID, nutritionProfile: UserNutritionProfile?) {
        guard let np = nutritionProfile else { return }
        let cal = Calendar.current

        let dayProfiles: [(Int, Float, Float, Float, Float)] = [
            (1, 0.95, 1.00, 0.90, 1.05),
            (2, 0.80, 0.95, 0.75, 0.85),
            (3, 1.10, 0.90, 1.00, 0.95),
            (4, 0.60, 1.00, 0.85, 0.90),
            (5, 0.90, 0.80, 0.70, 0.95),
            (6, 0.85, 1.05, 0.90, 0.80),
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
    // MARK: - Convenience Helpers (used by Views)
    // ─────────────────────────────────────────────

    func todaysMealEntries() -> [MealEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == today
        }.sorted(by: { $0.mealType.caloriePercent > $1.mealType.caloriePercent })
    }

    func mealEntries(for date: Date) -> [MealEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == dayStart
        }.sorted(by: { $0.mealType.displayOrder < $1.mealType.displayOrder })
    }

    func totalCalories(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.caloriesConsumed }
    }

    func totalCalorieTarget(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.calorieTarget }
    }

    func weeklyCalorieTotals() -> [(day: String, consumed: Float, target: Float)] {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: today))!
        return (0..<7).map { offset in
            let date = cal.date(byAdding: .day, value: offset, to: startOfWeek)!
            return (day: fmt.string(from: date),
                    consumed: totalCalories(for: date),
                    target: totalCalorieTarget(for: date))
        }
    }

    func foods(for mealType: MealType, vegetarianOnly: Bool = false) -> [Food] {
        foods
            .filter { $0.suitableMealTypes.contains(mealType) && (!vegetarianOnly || $0.isVegetarian) }
            .sorted(by: {
                let aScore = ($0.isBiotinRich ? 1 : 0) + ($0.isZincRich ? 1 : 0) + ($0.isIronRich ? 1 : 0)
                let bScore = ($1.isBiotinRich ? 1 : 0) + ($1.isZincRich ? 1 : 0) + ($1.isIronRich ? 1 : 0)
                return aScore > bScore
            })
    }

    // MARK: - DietMate Logic

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
        let minSafe = target * 0.70

        mealEntries[idx].goalStatus = cal < minSafe        ? .under
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

    func decrementOrRemoveFood(mealFoodId: UUID, mealEntryId: UUID) {
        guard let idx = mealFoods.firstIndex(where: { $0.id == mealFoodId }) else { return }
        if mealFoods[idx].quantity > 1 {
            mealFoods[idx].quantity -= 1
            updateMealEntryTotals(mealEntryId: mealEntryId)
        } else {
            removeFood(mealFoodId: mealFoodId, from: mealEntryId)
        }
    }

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

    func todaysTotalMacros() -> (protein: Double, carbs: Double, fat: Double) {
        let entries = todaysMealEntries()
        return (
            protein: Double(entries.reduce(0) { $0 + $1.proteinConsumed }),
            carbs:   Double(entries.reduce(0) { $0 + $1.carbsConsumed }),
            fat:     Double(entries.reduce(0) { $0 + $1.fatConsumed })
        )
    }

    func todaysTotalCalories() -> Float {
        todaysMealEntries().reduce(0) { $0 + $1.caloriesConsumed }
    }

    func todaysLoggedMealCount() -> Int {
        todaysMealEntries().filter { $0.isLogged }.count
    }

    // ─────────────────────────────────────────────
    // MARK: - User Actions (moved from UserActions.swift)
    // ─────────────────────────────────────────────

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

        if entry.isLogged {
            return .blocked(reason: "\(mealType.displayName) is already logged. Tap edit to make changes.")
        }

        mealFoods.append(MealFood(
            id: UUID(), mealEntryId: entry.id,
            foodId: food.id, quantity: quantity
        ))
        updateMealEntryTotals(mealEntryId: entry.id)

        guard let updated = mealEntries.first(where: { $0.id == entry.id }) else {
            return .success(message: "\(food.name) added.")
        }

        let check = RecommendationEngine.checkCalorieGoal(
            consumed: updated.caloriesConsumed,
            target: updated.calorieTarget
        )

        switch check.goalStatus {
        case .met:
            return .success(message: "\(food.name) added! \(mealType.displayName) goal met.")
        case .exceeded:
            let over = Int(updated.caloriesConsumed - updated.calorieTarget)
            return .warning(message: "\(food.name) added. You're \(over) kcal over your \(mealType.displayName) target.")
        case .under:
            let remaining = Int(updated.calorieTarget - updated.caloriesConsumed)
            return .success(message: "\(food.name) added. \(remaining) kcal remaining for \(mealType.displayName).")
        }
    }

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

        if !check.canLog {
            return .blocked(reason: check.message)
        }

        mealEntries[idx].isLogged  = true
        mealEntries[idx].loggedAt  = Date()
        mealEntries[idx].goalStatus = check.goalStatus

        if check.goalStatus == .exceeded {
            return .warning(message: check.message)
        }
        return .success(message: check.message)
    }

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

    func mealCalorieSummary(mealType: MealType) -> (consumed: Float, target: Float, status: MealGoalStatus) {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return (0, 0, .under) }
        return (entry.caloriesConsumed, entry.calorieTarget, entry.goalStatus)
    }

    // ─────────────────────────────────────────────
    // MARK: - Calorie Bar Helper (DietMate UI)
    // ─────────────────────────────────────────────

    struct MealSlotSummary {
        let mealType: MealType
        let calorieTarget: Float
        let caloriesConsumed: Float
        let progress: Float
        let overAmount: Float
        let goalStatus: MealGoalStatus
        let isLogged: Bool
        let canLog: Bool
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

        let check    = RecommendationEngine.checkCalorieGoal(
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

    func rankedFoods(for mealType: MealType, plan: UserPlan?, vegetarianOnly: Bool = false) -> [Food] {
        guard let plan = plan else {
            return foods(for: mealType, vegetarianOnly: vegetarianOnly)
        }
        return RecommendationEngine.rankedFoods(
            from: foods, for: mealType, plan: plan,
            vegetarianOnly: vegetarianOnly
        )
    }
}
