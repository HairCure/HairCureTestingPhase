//
//  FoodDetailView.swift
//  HairCureTesting1
//
//  Detail screen shown when a food card is tapped.
//  Shows:
//  • Hero gradient image with back button
//  • Food name + "Nutrition information" subtitle
//  • Per serving text
//  • White card: calorie range 🔥, macro bars (protein/fat/carbs), legend
//  • Hair nutrient badges box (Biotin, Zinc, Iron, Omega-3, Vitamin A)
//

import SwiftUI


struct FoodDetailView: View {
    let food: Food
    @Environment(\.dismiss) private var dismiss

    // A deterministic hue based on food name for the hero gradient
    private var heroHue: Double {
        let hash = food.name.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        return Double(abs(hash) % 360)
    }

    private var heroGradient: LinearGradient {
        let h = heroHue / 360.0
        return LinearGradient(
            colors: [
                Color(hue: h,       saturation: 0.55, brightness: 0.85),
                Color(hue: (h + 0.05).truncatingRemainder(dividingBy: 1),
                      saturation: 0.45, brightness: 0.70)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: Hero Image Area
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(heroGradient)
                        .frame(height: 280)
                        .overlay(
                            // Food icon as decorative element
                            Image(systemName: "fork.knife")
                                .font(.system(size: 80, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.25))
                                .offset(x: 80, y: 30)
                        )

                    // Back button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 56)
                }

                // MARK: Content
                VStack(alignment: .leading, spacing: 20) {

                    // Title block
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name)
                            .font(.system(size: 26, weight: .bold))
                        Text("Nutrition information")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("Per serving (\(Int(food.servingSizeGrams))g)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .offset(y: phase.isIdentity ? 0 : 16)
                    }

                    // MARK: Nutrition Card
                    nutritionCard
                        .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                .offset(y: phase.isIdentity ? 0 : 20)
                        }

                    // MARK: Hair Nutrients Card
                    if food.isBiotinRich || food.isZincRich || food.isIronRich ||
                       food.isOmega3Rich || food.isVitaminARich {
                        hairNutrientsCard
                            .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .offset(x: phase.isIdentity ? 0 : 30)
                            }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(UIColor.systemBackground))
        .scrollBounceBehavior(.basedOnSize)
    }

    // MARK: - Nutrition Card

    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Calorie range row
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Calories :")
                    .font(.system(size: 18, weight: .bold))
                Text("\(Int(food.totalCaloriesMin)) – \(Int(food.totalCaloriesMax))")
                    .font(.system(size: 18, weight: .bold))
                Text("🔥")
                    .font(.system(size: 18))
            }

            // Macro bars + gram labels
            macroBarsSection

            // Divider + legend
            Divider()

            // Legend
            VStack(alignment: .leading, spacing: 8) {
                MacroLegendRow(color: Color(red: 0.2, green: 0.78, blue: 0.35), label: "Proteins")
                MacroLegendRow(color: Color(red: 0.98, green: 0.76, blue: 0.18), label: "Fats")
                MacroLegendRow(color: Color(red: 0.18, green: 0.80, blue: 0.88), label: "Carbohydrates")
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    // MARK: - Macro Bars

    private var macroBarsSection: some View {
        let protein = food.totalProteinsInGm
        let fat     = food.totalFatInGm
        let carbs   = food.totalCarbsInGm
        let maxMacro = max(protein, fat, carbs, 1)

        // Approximate gram ranges (±15% rounded to nearest whole number)
        func gramRange(_ value: Float) -> String {
            let lo = Int((value * 0.85).rounded())
            let hi = Int((value * 1.15).rounded())
            return "\(lo) – \(hi) g"
        }

        return VStack(spacing: 10) {
            MacroBar(
                color: Color(red: 0.2, green: 0.78, blue: 0.35),
                label: gramRange(protein),
                fraction: CGFloat(protein / maxMacro)
            )
            MacroBar(
                color: Color(red: 0.98, green: 0.76, blue: 0.18),
                label: gramRange(fat),
                fraction: CGFloat(fat / maxMacro)
            )
            MacroBar(
                color: Color(red: 0.18, green: 0.80, blue: 0.88),
                label: gramRange(carbs),
                fraction: CGFloat(carbs / maxMacro)
            )
        }
    }

    // MARK: - Hair Nutrients Card

    private var hairNutrientsCard: some View {
        VStack(spacing: 0) {
            let nutrients: [(String, Bool)] = [
                ("Biotin",     food.isBiotinRich),
                ("Zinc",       food.isZincRich),
                ("Iron",       food.isIronRich),
                ("Omega-3",    food.isOmega3Rich),
                ("Vitamin A",  food.isVitaminARich)
            ].filter { $0.1 }   // only show nutrients the food has

            ForEach(Array(nutrients.enumerated()), id: \.offset) { i, pair in
                HStack {
                    // Info icon
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text(pair.0)
                        .font(.system(size: 16))
                    Spacer()
                    // iOS 17 — checkmark appears with bounce effect, staggered by index
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.15, green: 0.76, blue: 0.37))
                        .symbolEffect(.bounce, value: i)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if i < nutrients.count - 1 {
                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - MacroBar

private struct MacroBar: View {
    let color: Color
    let label: String
    let fraction: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(height: 28)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geo.size.width * min(fraction, 1.0), height: 28)
                        .animation(.easeOut(duration: 0.5), value: fraction)
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(fraction > 0.4 ? .white : color)
                        .padding(.leading, 10)
                }
            }
            .frame(height: 28)
        }
    }
}

// MARK: - MacroLegendRow

private struct MacroLegendRow: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    FoodDetailView(food: Food(
        id: UUID(), externalFoodId: nil,
        name: "Paneer Stuffed Paratha",
        imageURL: "paneer_paratha",
        foodType: "vegetarian", isVegetarian: true, isCustom: false,
        createdByUserId: nil,
        servingSizeGrams: 200, apiSource: "mock",
        totalCaloriesMin: 300, totalCaloriesMax: 350,
        totalProteinsInGm: 12, totalCarbsInGm: 38, totalFatInGm: 12,
        totalVitaminsInMg: 4.5,
        isBiotinRich: true, isZincRich: false, isIronRich: false,
        isOmega3Rich: false, isVitaminARich: false,
        suitableMealTypes: [.breakfast, .dinner],
        createdAt: Date()
    ))
}
