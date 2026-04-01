import SwiftUI

// MARK: - Main View

struct DietMateView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(DietmateDataStore.self) private var dietMateStore

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showCalendarSheet: Bool = false
    @State private var pushMealId: UUID?   = nil
    @State private var selectedFood: Food? = nil

    private var weekDates: [Date] {
        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let start   = -(weekday - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: start + $0, to: today) }
    }

    private var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                dateHeader
                    .scrollTransition(.animated.threshold(.visible(0.3))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .offset(y: phase.isIdentity ? 0 : -12)
                    }

                ringCalendar
                    .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.3)
                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                    }

                HStack {
                    Text(isSelectedDateToday ? "Daily Meals" : sectionTitle(for: selectedDate))
                        .font(.system(size: 22, weight: .bold))
                        .animation(.easeInOut(duration: 0.2), value: selectedDate)

                    Spacer()

                    if !isSelectedDateToday {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedDate = Calendar.current.startOfDay(for: Date())
                            }
                        } label: {
                            Label("Today", systemImage: "arrow.uturn.left")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.hcBrown)
                                .clipShape(Capsule())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .scrollTransition(.animated) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .offset(x: phase.isIdentity ? 0 : -20)
                }

                mealCards
                Spacer(minLength: 24)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sheet(isPresented: $showCalendarSheet) { calendarSheet }
        .navigationDestination(item: $pushMealId) { AddMealView(mealEntryId: $0) }
        .sheet(item: $selectedFood) { FoodDetailView(food: $0) }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack(spacing: 8) {
            Text(formattedHeaderDate(selectedDate))
                .font(.system(size: 20, weight: .bold))
                .animation(.easeInOut(duration: 0.2), value: selectedDate)

            Spacer()

            Button { showCalendarSheet = true } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.hcBrown)
                    .padding(8)
                    .background(Color.hcBrown.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 20)
    }

    private func formattedHeaderDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateString = date.formatted(.dateTime.day().month().year())
        if calendar.isDateInToday(date)      { return "Today, \(dateString)" }
        if calendar.isDateInYesterday(date)  { return "Yesterday, \(dateString)" }
        return date.formatted(.dateTime.weekday(.wide).day().month().year())
    }

    private func sectionTitle(for date: Date) -> String {
        "\(date.formatted(.dateTime.day().month())) (Meals)"
    }

    // MARK: - Calendar Sheet

    private var calendarSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { selectedDate },
                        set: { newDate in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedDate = Calendar.current.startOfDay(for: newDate)
                            }
                            showCalendarSheet = false
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                Spacer()
            }
            .navigationTitle("Pick a Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button{
                        showCalendarSheet = false
                    } label:{
                        Image(systemName: "xmark")
                        
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Today") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedDate = Calendar.current.startOfDay(for: Date())
                        }
                        showCalendarSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Ring Calendar

    private var ringCalendar: some View {
        let cal        = Calendar.current
        let today      = cal.startOfDay(for: Date())
        let selectedDay = cal.startOfDay(for: selectedDate)
        let dayLetters  = ["S", "M", "T", "W", "T", "F", "S"]

        func fillProgress(for date: Date) -> Double {
            let target = dietMateStore.totalCalorieTarget(for: date)
            guard target > 0 else { return 0 }
            return min(Double(dietMateStore.totalCalories(for: date) / target), 1.0)
        }

        func ringColor(for date: Date) -> Color {
            let target = dietMateStore.totalCalorieTarget(for: date)
            guard target > 0 else { return .green }
            return dietMateStore.totalCalories(for: date) > target * 1.10 ? .orange : .green
        }

        return HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { _, date in
                let dayStart   = cal.startOfDay(for: date)
                let isToday    = dayStart == today
                let isSelected = dayStart == selectedDay
                let dayIdx     = cal.component(.weekday, from: date) - 1
                let progress   = fillProgress(for: date)
                let color      = ringColor(for: date)
                let isFuture   = dayStart > today

                VStack(spacing: 6) {
                    ZStack {
                        if isToday {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 28, height: 28)
                        }
                        Text(dayLetters[dayIdx])
                            .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                            .foregroundColor(isToday ? .white : .secondary)
                    }
                    .frame(width: 28, height: 28)

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.18), lineWidth: 4)
                            .frame(width: 32, height: 32)

                        if progress > 0 {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    isFuture ? Color.gray.opacity(0.3) : color,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 32, height: 32)
                                .animation(.easeInOut(duration: 0.4), value: progress)
                        }
                    }
                    .frame(width: 36, height: 36)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !isFuture else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDate = dayStart
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Meal Cards

    private var mealCards: some View {
        let entries = dietMateStore.mealEntries(for: selectedDate)
        let isPast  = !Calendar.current.isDateInToday(selectedDate)

        return VStack(spacing: 14) {
            if entries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No meal data for this day")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(entries) { entry in
                    Group {
                        if entry.caloriesConsumed > 0 {
                            LoggedMealCard(
                                entry: entry,
                                isPastDay: isPast,
                                onEdit: { if !isPast { pushMealId = entry.id } },
                                onFoodTap: { selectedFood = $0 }
                            )
                        } else if isPast {
                            SkippedMealCard(entry: entry)
                        } else {
                            EmptyMealCard(entry: entry) { pushMealId = entry.id }
                        }
                    }
                    .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.96)
                            .offset(y: phase.isIdentity ? 0 : 24)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .id(selectedDate)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Empty Meal Card

private struct EmptyMealCard: View {
    let entry: MealEntry
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.mealType.displayName)
                .font(.system(size: 20, weight: .bold))
            Text(entry.mealType.recommendedPortionText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Button(action: onTap) {
                Text("Add \(entry.mealType.displayName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.hcBrown)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Skipped Meal Card

private struct SkippedMealCard: View {
    let entry: MealEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mealType.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.secondary)
                Text("Not logged")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            Spacer()
            Image(systemName: "minus.circle")
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.07))
        .cornerRadius(16)
    }
}

// MARK: - Logged Meal Card

private struct LoggedMealCard: View {
    @Environment(AppDataStore.self) private var store
    @Environment(DietmateDataStore.self) private var dietMateStore
    let entry: MealEntry
    let isPastDay: Bool
    let onEdit: () -> Void
    let onFoodTap: (Food) -> Void

    private var foods: [(food: Food, mealFood: MealFood)] {
        dietMateStore.mealFoods
            .filter { $0.mealEntryId == entry.id }
            .compactMap { mf in
                guard let food = dietMateStore.foods.first(where: { $0.id == mf.foodId }) else { return nil }
                return (food, mf)
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(entry.mealType.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(entry.mealType.accentColor)
                Spacer()

                if !isPastDay {
                    Button(action: onEdit) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18))
                            .foregroundColor(entry.mealType.accentColor)
                    }
                } else {
                    Text("History")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(entry.mealType.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(entry.mealType.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(entry.caloriesConsumed))")
                    .font(.system(size: 22, weight: .bold))
                Text("/\(Int(entry.calorieTarget)) kcal")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Spacer()

                // GoalStatusStyle replaces the duplicated color/icon switch block
                let style = GoalStatusStyle.of(entry.goalStatus)
                let goalLabel: String = {
                    switch entry.goalStatus {
                    case .met:      return "Goal met"
                    case .exceeded: return "Exceeded"
                    case .under:    return "Under"
                    }
                }()
                Label(goalLabel, systemImage: style.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(style.color)
            }

            GeometryReader { geo in
                let progress = min(CGFloat(entry.caloriesConsumed / entry.calorieTarget), 1.0)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(entry.mealType.accentColor)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.easeOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 5)

            if !foods.isEmpty {
                Divider()

                VStack(spacing: 8) {
                    ForEach(foods, id: \.mealFood.id) { pair in
                        Button(action: { onFoodTap(pair.food) }) {
                            HStack {
                                Circle()
                                    .fill(entry.mealType.accentColor)
                                    .frame(width: 8, height: 8)
                                Text(pair.food.name)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                if pair.mealFood.quantity > 1 {
                                    Text("×\(Int(pair.mealFood.quantity))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    // food.averageCalories replaces the inline (min+max)/2
                                    Text("\(Int(pair.food.averageCalories * pair.mealFood.quantity)) kcal")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entry.mealType.accentColor, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    let previewUserId = UUID()
    let appStore      = AppDataStore()
    let dietMateStore = DietmateDataStore(currentUserId: previewUserId)
    NavigationStack {
        DietMateView()
            .environment(appStore)
            .environment(dietMateStore)
    }
}
