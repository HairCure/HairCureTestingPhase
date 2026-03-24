//
//  AddMealView.swift
//  HairCureTesting1
//
//  Meal detail / food-picker screen.
//  Opened as a .sheet from DietMateView.
//
//  Features:
//  • Back button + centred meal title
//  • Search bar (filters suggested meal grid)
//  • Recommended portion + calorie progress bar
//  • Added foods list with ⊖ qty ⊕ stepper (removes at 0)
//  • Suggested meals 2-column grid with + button
//

import SwiftUI

struct AddMealView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let mealEntryId: UUID

    @State private var searchText: String = ""
    @State private var selectedFood: Food? = nil

    private var entry: MealEntry? {
        store.mealEntries.first(where: { $0.id == mealEntryId })
    }

    // Foods already added to this meal (with quantities)
    private var addedFoods: [(mealFood: MealFood, food: Food)] {
        store.mealFoods
            .filter { $0.mealEntryId == mealEntryId }
            .compactMap { mf -> (MealFood, Food)? in
                guard let food = store.foods.first(where: { $0.id == mf.foodId }) else { return nil }
                return (mf, food)
            }
    }

    // Foods available for this meal type (search-filtered)
    private var suggestedFoods: [Food] {
        guard let e = entry else { return [] }
        let all = store.foods(for: e.mealType)
        if searchText.isEmpty { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // Colour for this meal
    private var mealColor: Color { entry?.mealType.accentColor ?? Color.hcBrown }

    var body: some View {
        VStack(spacing: 0) {
            // ── Nav bar ──
            navBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Search ──
                    searchBar

                    // ── Portion info + progress ──
                    portionSection

                    // ── Calorie warning banner ──
                    if let e = entry, e.caloriesConsumed > 0 {
                        calorieWarningBanner(for: e)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // ── Added foods ──
                    if !addedFoods.isEmpty {
                        addedFoodsSection
                    }

                    // ── Suggested meals ──
                    suggestedSection

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(item: $selectedFood) { food in
            FoodDetailView(food: food)
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        ZStack {
            Text(entry?.mealType.displayName ?? "Meal")
                .font(.system(size: 20, weight: .semibold))

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.hcCream)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search for a meal", text: $searchText)
                .font(.system(size: 16))
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "mic.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Portion + Progress

    private var portionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let e = entry {
                let range: String = {
                    switch e.mealType {
                    case .breakfast: return "300 – 510 kcal"
                    case .lunch:     return "500 – 713 kcal"
                    case .snack:     return "200 – 306 kcal"
                    case .dinner:    return "400 – 510 kcal"
                    }
                }()

                Text("Recommended portion : \(range)")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)

                // Bold calorie counter
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(e.caloriesConsumed))")
                        .font(.system(size: 28, weight: .bold))
                    Text("/\(Int(e.calorieTarget)) kcal")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                // Progress bar
                GeometryReader { geo in
                    let fraction = min(CGFloat(e.caloriesConsumed / e.calorieTarget), 1.0)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(mealColor)
                            .frame(width: geo.size.width * fraction, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: fraction)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    // MARK: - Calorie Warning Banner

    @ViewBuilder
    private func calorieWarningBanner(for entry: MealEntry) -> some View {
        let result = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed,
            target: entry.calorieTarget
        )

        let (bgColor, iconName): (Color, String) = {
            switch result.goalStatus {
            case .under:    return (Color.red.opacity(0.10),    "exclamationmark.triangle.fill")
            case .met:      return (Color.green.opacity(0.10),  "checkmark.circle.fill")
            case .exceeded: return (Color.orange.opacity(0.12), "exclamationmark.circle.fill")
            }
        }()

        let iconColor: Color = {
            switch result.goalStatus {
            case .under:    return .red
            case .met:      return .green
            case .exceeded: return .orange
            }
        }()

        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(iconColor)
                // iOS 17 — symbol swaps with replace effect when status changes
                .contentTransition(.symbolEffect(.replace))
            Text(result.message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(iconColor.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(iconColor.opacity(0.25), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: entry.caloriesConsumed)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Added Foods

    private var addedFoodsSection: some View {
        VStack(spacing: 10) {
            ForEach(addedFoods, id: \.mealFood.id) { pair in
                AddedFoodRow(
                    mealFood: pair.mealFood,
                    food: pair.food,
                    mealColor: mealColor,
                    onIncrement: { incrementFood(pair.mealFood) },
                    onDecrement: { decrementFood(pair.mealFood) }
                )
            }
        }
    }

    // MARK: - Suggested Meals Grid

    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if searchText.isEmpty {
                Text("Suggested Meals")
                    .font(.system(size: 20, weight: .bold))
            }

            if suggestedFoods.isEmpty {
                Text("No meals found")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(suggestedFoods) { food in
                        SuggestedFoodCard(food: food, mealColor: mealColor) {
                            addFood(food)
                        } onTapCard: {
                            selectedFood = food
                        }
                        // iOS 17 — each grid card fades/scales in as it scrolls into view
                        .scrollTransition(.animated.threshold(.visible(0.05))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.88)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func addFood(_ food: Food) {
        store.addOrIncrementFood(food, to: mealEntryId)
    }

    private func incrementFood(_ mealFood: MealFood) {
        store.incrementFood(mealFoodId: mealFood.id, mealEntryId: mealEntryId)
    }

    private func decrementFood(_ mealFood: MealFood) {
        store.decrementOrRemoveFood(mealFoodId: mealFood.id, mealEntryId: mealEntryId)
    }
}

// MARK: - Added Food Row

private struct AddedFoodRow: View {
    let mealFood: MealFood
    let food: Food
    let mealColor: Color
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Food image placeholder (using SF symbol since there are no real images)
            RoundedRectangle(cornerRadius: 10)
                .fill(mealColor.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundColor(mealColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(2)
                let avg = (food.totalCaloriesMin + food.totalCaloriesMax) / 2
                Text("\(Int(avg * mealFood.quantity)) kcal")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // ⊖ qty ⊕
            HStack(spacing: 12) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
                Text("\(Int(mealFood.quantity))")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(minWidth: 20)
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 22))
                        .foregroundColor(mealColor)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(mealColor.opacity(0.06))
        )
    }
}

// MARK: - Suggested Food Card

private struct SuggestedFoodCard: View {
    let food: Food
    let mealColor: Color
    let onAdd: () -> Void
    let onTapCard: () -> Void

    private let avgCalories: Int

    init(food: Food, mealColor: Color, onAdd: @escaping () -> Void, onTapCard: @escaping () -> Void) {
        self.food = food
        self.mealColor = mealColor
        self.onAdd = onAdd
        self.onTapCard = onTapCard
        self.avgCalories = Int((food.totalCaloriesMin + food.totalCaloriesMax) / 2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image area — all overlaid buttons clipped within the rounded rect
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [mealColor.opacity(0.25), mealColor.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(height: 110)
                .overlay(
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mealColor.opacity(0.4))
                )
                // + button — top-right
                .overlay(alignment: .topTrailing) {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .padding(6)
                }
                // 🔥 calorie badge — bottom-left
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 3) {
                        Text("🔥")
                            .font(.system(size: 11))
                        Text("\(avgCalories)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(8)
                    .padding(6)
                    .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
                .onTapGesture { onTapCard() }

            // Food name — also tappable for detail
            Button(action: onTapCard) {
                Text(food.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 2)
            }
        }
    }
}

#Preview {
    let store = AppDataStore()
    return AddMealView(mealEntryId: store.mealEntries.first!.id)
        .environment(store)
}
