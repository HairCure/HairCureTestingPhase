//  FoodDetailView.swift
//  HairCureTesting1

import SwiftUI

struct FoodDetailView: View {
    let food: Food
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                // MARK: Hero Image
                ZStack(alignment: .topLeading) {
                    if let imageName = food.imageURL, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        ZStack {
                            Rectangle()
                            Image(systemName: "fork.knife")
                                .font(.system(size: 100, weight: .light))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                    }

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
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

                    nutritionCard
                        .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                .offset(y: phase.isIdentity ? 0 : 20)
                        }

                    // food.hairNutrients replaces the five-boolean inline filter
                    if !food.hairNutrients.isEmpty {
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

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Calories :")
                    .font(.system(size: 18, weight: .bold))
                Text("\(Int(food.totalCaloriesMin)) – \(Int(food.totalCaloriesMax))")
                    .font(.system(size: 18, weight: .bold))
                Text("🔥")
                    .font(.system(size: 18))
            }

            macroBarsSection

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                MacroLegendRow(color: MacroColors.protein, label: "Proteins")
                MacroLegendRow(color: MacroColors.fat,     label: "Fats")
                MacroLegendRow(color: MacroColors.carbs,   label: "Carbohydrates")
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    // MARK: - Macro Bars

    private var macroBarsSection: some View {
        let protein  = food.totalProteinsInGm
        let fat      = food.totalFatInGm
        let carbs    = food.totalCarbsInGm
        let maxMacro = max(protein, fat, carbs, 1)

        func gramRange(_ value: Float) -> String {
            "\(Int((value * 0.85).rounded())) – \(Int((value * 1.15).rounded())) g"
        }

        return VStack(spacing: 10) {
            MacroBar(color: MacroColors.protein, label: gramRange(protein), fraction: CGFloat(protein / maxMacro))
            MacroBar(color: MacroColors.fat,     label: gramRange(fat),     fraction: CGFloat(fat     / maxMacro))
            MacroBar(color: MacroColors.carbs,   label: gramRange(carbs),   fraction: CGFloat(carbs   / maxMacro))
        }
    }

    // MARK: - Hair Nutrients Card
    // food.hairNutrients (from Food model) replaces the inline five-boolean filter.

    private var hairNutrientsCard: some View {
        let nutrients = food.hairNutrients

        return VStack(spacing: 0) {
            ForEach(Array(nutrients.enumerated()), id: \.offset) { i, name in
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text(name)
                        .font(.system(size: 16))
                    Spacer()
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

// MARK: - Macro Colours
// Single definition reused by both MacroBar and MacroLegendRow.

private enum MacroColors {
    static let protein = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let fat     = Color(red: 0.98, green: 0.76, blue: 0.18)
    static let carbs   = Color(red: 0.18, green: 0.80, blue: 0.88)
}

// MARK: - MacroBar

struct MacroBar: View {
    let color: Color
    let label: String
    let fraction: CGFloat

    var body: some View {
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

// MARK: - MacroLegendRow

struct MacroLegendRow: View {
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
