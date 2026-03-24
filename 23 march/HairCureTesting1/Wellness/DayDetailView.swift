////
////  DayDetailView.swift
////  HairCureTesting1
////
////  Read-only past-day meal summary.
////  Pushed from DietMateView when:
////    (a) the user taps a past-day ring in the ring calendar, or
////    (b) the user picks a date in the calendar sheet and taps "View Day".
////
//
//import SwiftUI
//
//struct DayDetailView: View {
//    @Environment(AppDataStore.self) private var store
//    let date: Date
//
//    @State private var selectedFood: Food? = nil
//
//    // Formatted nav title, e.g. "Mon, 17 Mar"
//    private var navTitle: String {
//        let f = DateFormatter()
//        f.dateFormat = "EEE, d MMM"
//        return f.string(from: date)
//    }
//
//    // Sorted meal entries for the given date
//    private var entries: [MealEntry] {
//        store.mealEntries(for: date)
//            .sorted(by: { $0.mealType.displayOrder < $1.mealType.displayOrder })
//    }
//
//    // Day-level calorie totals
//    private var totalConsumed: Float { store.totalCalories(for: date) }
//    private var totalTarget:   Float { store.totalCalorieTarget(for: date) }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 20) {
//
//                // ── Day summary card ──
//                summaryCard
//                    .padding(.horizontal, 20)
//                    .padding(.top, 4)
//
//                // ── Meal cards ──
//                if entries.isEmpty {
//                    emptyState
//                } else {
//                    VStack(spacing: 14) {
//                        ForEach(entries, id: \.id) { entry in
//                            Group {
//                                if entry.caloriesConsumed > 0 {
//                                    LoggedMealCard(
//                                        entry: entry,
//                                        isPastDay: true,
//                                        onEdit: { },          // no editing on past days
//                                        onFoodTap: { food in selectedFood = food }
//                                    )
//                                } else {
//                                    SkippedMealCard(entry: entry)
//                                }
//                            }
//                            .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
//                                content
//                                    .opacity(phase.isIdentity ? 1 : 0)
//                                    .offset(y: phase.isIdentity ? 0 : 20)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                }
//
//                Spacer(minLength: 24)
//            }
//            .padding(.top, 8)
//        }
//        .scrollBounceBehavior(.basedOnSize)
//        .navigationTitle(navTitle)
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(item: $selectedFood) { food in
//            FoodDetailView(food: food)
//        }
//    }
//
//    // MARK: - Day Summary Card
//
//    private var summaryCard: some View {
//        let pct = totalTarget > 0 ? min(Double(totalConsumed / totalTarget), 1.0) : 0.0
//
//        return VStack(spacing: 12) {
//
//            // Total kcal ring + label row
//            HStack(spacing: 16) {
//                // Mini donut ring
//                ZStack {
//                    Circle()
//                        .stroke(Color.gray.opacity(0.18), lineWidth: 8)
//                    Circle()
//                        .trim(from: 0, to: pct)
//                        .stroke(
//                            totalConsumed > totalTarget * 1.10 ? Color.orange : Color.green,
//                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
//                        )
//                        .rotationEffect(.degrees(-90))
//                        .animation(.easeInOut(duration: 0.5), value: pct)
//                    Text("\(Int(pct * 100))%")
//                        .font(.system(size: 13, weight: .bold))
//                        .foregroundColor(.primary)
//                }
//                .frame(width: 64, height: 64)
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Total Calories")
//                        .font(.system(size: 13))
//                        .foregroundColor(.secondary)
//                    HStack(alignment: .lastTextBaseline, spacing: 3) {
//                        Text("\(Int(totalConsumed))")
//                            .font(.system(size: 26, weight: .bold))
//                        Text("/ \(Int(totalTarget)) kcal")
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                    }
//                    overallBadge
//                }
//
//                Spacer()
//            }
//
//            Divider()
//
//            // Macro row
//            macroRow
//        }
//        .padding(16)
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
//    }
//
//    @ViewBuilder
//    private var overallBadge: some View {
//        if totalConsumed >= totalTarget * 0.70 && totalConsumed <= totalTarget * 1.10 {
//            Label("On track", systemImage: "checkmark.seal.fill")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.green)
//        } else if totalConsumed > totalTarget * 1.10 {
//            Label("Over target", systemImage: "exclamationmark.triangle.fill")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.orange)
//        } else {
//            Label("Under target", systemImage: "arrow.down.circle.fill")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.secondary)
//        }
//    }
//
//    private var macroRow: some View {
//        // Sum macros across all entries for this day
//        let protein = entries.reduce(Float(0)) { $0 + $1.proteinConsumed }
//        let carbs   = entries.reduce(Float(0)) { $0 + $1.carbsConsumed }
//        let fat     = entries.reduce(Float(0)) { $0 + $1.fatConsumed }
//
//        return HStack {
//            MacroCell(label: "Protein", value: protein, unit: "g",
//                      color: Color(red: 0.976, green: 0.451, blue: 0.086))
//            Spacer()
//            MacroCell(label: "Carbs",   value: carbs,   unit: "g",
//                      color: Color(red: 0.133, green: 0.773, blue: 0.369))
//            Spacer()
//            MacroCell(label: "Fat",     value: fat,     unit: "g",
//                      color: Color(red: 0.659, green: 0.333, blue: 0.969))
//        }
//    }
//
//    // MARK: - Empty State
//
//    private var emptyState: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "fork.knife.circle")
//                .font(.system(size: 48))
//                .foregroundColor(.secondary.opacity(0.4))
//            Text("No meals logged for this day")
//                .font(.system(size: 16))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 60)
//    }
//}
//
//// MARK: - Macro Cell
//
//private struct MacroCell: View {
//    let label: String
//    let value: Float
//    let unit:  String
//    let color: Color
//
//    var body: some View {
//        VStack(spacing: 2) {
//            Text(String(format: "%.1f\(unit)", value))
//                .font(.system(size: 15, weight: .bold))
//                .foregroundColor(color)
//            Text(label)
//                .font(.system(size: 12))
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//// MARK: - Skipped Meal Card (0 kcal on a past day)
//
//struct SkippedMealCard: View {
//    let entry: MealEntry
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Circle()
//                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
//                .frame(width: 10, height: 10)
//            VStack(alignment: .leading, spacing: 3) {
//                Text(entry.mealType.displayName)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.secondary)
//                Text("Not logged")
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary.opacity(0.6))
//            }
//            Spacer()
//            Image(systemName: "minus.circle")
//                .foregroundColor(.secondary.opacity(0.35))
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//        .background(Color(.systemGray6))
//        .cornerRadius(14)
//    }
//}
//
//#Preview {
//    NavigationStack {
//        DayDetailView(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
//            .environment(AppDataStore())
//    }
//}
