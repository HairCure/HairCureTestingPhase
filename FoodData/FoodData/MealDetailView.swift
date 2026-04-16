//
//  MealDetailView.swift
//  FoodData
//
//  Created by Chetan Kandpal on 06/04/26.
//


import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    let nutrient: MealNutrient?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                if let urlStr = meal.imageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(meal.category ?? "")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(categoryColor(meal.category).opacity(0.15))
                            .foregroundColor(categoryColor(meal.category))
                            .cornerRadius(8)

                        Spacer()

                        Label(meal.isVeg == true ? "Veg" : "Non-Veg",
                              systemImage: meal.isVeg == true ? "leaf.fill" : "fork.knife")
                            .font(.caption)
                            .foregroundColor(meal.isVeg == true ? .green : .red)
                    }

                    Text(meal.name)
                        .font(.title2).bold()

                    if let desc = meal.description {
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    if let benefit = meal.hairBenefit {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            Text("Hair benefit: \(benefit)")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.08))
                        .cornerRadius(10)
                    }
                }

                // Nutrients
                if let n = nutrient {
                    Text("Nutrients")
                        .font(.headline)
                        .padding(.top, 4)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        NutrientCard(label: "Protein", value: n.proteinG, unit: "g", icon: "bolt.fill", color: .blue)
                        NutrientCard(label: "Iron", value: n.ironMg, unit: "mg", icon: "drop.fill", color: .red)
                        NutrientCard(label: "Vitamin D", value: n.vitaminDIu, unit: "IU", icon: "sun.max.fill", color: .yellow)
                        NutrientCard(label: "Vitamin C", value: n.vitaminCMg, unit: "mg", icon: "leaf.fill", color: .orange)
                        NutrientCard(label: "Zinc", value: n.zincMg, unit: "mg", icon: "shield.fill", color: .teal)
                        NutrientCard(label: "Omega-3", value: n.omega3G, unit: "g", icon: "waveform.path", color: .indigo)
                        NutrientCard(label: "Vitamin B12", value: n.vitaminB12Mcg, unit: "mcg", icon: "brain.fill", color: .pink)
                        NutrientCard(label: "Biotin", value: n.biotinMcg, unit: "mcg", icon: "heart.fill", color: .purple)
                        NutrientCard(label: "Vitamin E", value: n.vitaminEMg, unit: "mg", icon: "staroflife.fill", color: .green)
                        NutrientCard(label: "Selenium", value: n.seleniumMcg, unit: "mcg", icon: "atom", color: .cyan)
                        NutrientCard(label: "Niacin", value: n.niacinMg, unit: "mg", icon: "flame.fill", color: .orange)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    func categoryColor(_ cat: String?) -> Color {
        switch cat {
        case "Breakfast": return .orange
        case "Lunch": return .green
        case "Dinner": return .indigo
        case "Snack": return .pink
        default: return .gray
        }
    }
}

struct NutrientCard: View {
    let label: String
    let value: Float?
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let v = value {
                    Text(String(format: "%.1f %@", v, unit))
                        .font(.subheadline).bold()
                } else {
                    Text("—")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}