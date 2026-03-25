////
////  CaloriesDetailView.swift
////  HairCureTesting1
////
//
//import SwiftUI
//import Charts
//
//struct CaloriesDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Environment(AppDataStore.self) private var store
//    @Environment(DietmateDataStore.self) private var dietMateStore
//
//    @State private var meals: [MealData] = []
//    
//    struct MealData: Identifiable {
//        let id = UUID()
//        let name: String
//        let calories: Double
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Today")
//                .font(.system(size: 28, weight: .bold))
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//            
//            if !meals.isEmpty {
//                Chart {
//                    ForEach(meals) { meal in
//                        BarMark(
//                            x: .value("Meal", meal.name),
//                            y: .value("Calories", meal.calories)
//                        )
//                        .foregroundStyle(Color.orange)
//                        .cornerRadius(4)
//                    }
//                }
//                .chartYAxis {
//                    AxisMarks(values: [0, 250, 400]) { value in
//                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
//                        AxisValueLabel()
//                    }
//                }
//                .frame(height: 180)
//                .padding(.horizontal, 20)
//            } else {
//                Text("No meals logged today yet.")
//                    .font(.system(size: 15))
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .frame(height: 180)
//            }
//            
//            // Macros Card
//            let macros = dietMateStore.todaysTotalMacros()
//            let tdee = Double(store.activeNutritionProfile?.tdee ?? 1500)
//            let targetProtein = (tdee * 0.25) / 4
//            let targetCarbs = (tdee * 0.50) / 4
//            let targetFats = (tdee * 0.25) / 9
//            
//            VStack(spacing: 24) {
//                HStack(spacing: 40) {
//                    macroBar(title: "Proteins", color: .green, current: macros.protein, target: targetProtein)
//                    macroBar(title: "Carbs", color: .blue, current: macros.carbs, target: targetCarbs)
//                }
//                
//                HStack(spacing: 40) {
//                    macroBar(title: "Fats", color: .yellow, current: macros.fat, target: targetFats)
//                    Spacer()
//                }
//            }
//            .padding(24)
//            .background(Color.white)
//            .cornerRadius(18)
//            .padding(.horizontal, 20)
//            .padding(.top, 10)
//            
//            Spacer()
//        }
//        .background(Color.hcCream.ignoresSafeArea())
//        .navigationTitle("Calories Intake")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button { dismiss() } label: {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.black)
//                        .padding(8)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                }
//            }
//        }
//        .onAppear {
//            let entries = dietMateStore.todaysMealEntries().filter { $0.isLogged }
//            meals = entries.map { MealData(name: $0.mealType.rawValue.capitalized, calories: Double($0.caloriesConsumed)) }
//        }
//    }
//    
//    private func macroBar(title: String, color: Color, current: Double, target: Double) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.system(size: 14, weight: .medium))
//            
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule().fill(color.opacity(0.15))
//                    let progress = min(1.0, current / max(1, target))
//                    Capsule().fill(color)
//                        .frame(width: geo.size.width * CGFloat(progress))
//                }
//            }
//            .frame(height: 6)
//            
//            Text("\(Int(current))/\(Int(target)) g")
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.black)
//        }
//    }
//}
