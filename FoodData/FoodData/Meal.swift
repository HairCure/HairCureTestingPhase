//
//  Meal.swift
//  FoodData
//
//  Created by Chetan Kandpal on 06/04/26.
//


import Foundation

struct Meal: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    let category: String?
    let isVeg: Bool?
    let hairBenefit: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case isVeg = "is_veg"
        case hairBenefit = "hair_benefit"
        case imageUrl = "image_url"
    }
}

struct MealNutrient: Identifiable, Codable {
    let id: Int
    let mealId: Int?
    let proteinG: Float?
    let ironMg: Float?
    let vitaminDIu: Float?
    let vitaminCMg: Float?
    let zincMg: Float?
    let omega3G: Float?
    let vitaminB12Mcg: Float?
    let biotinMcg: Float?
    let vitaminEMg: Float?
    let seleniumMcg: Float?
    let niacinMg: Float?

    enum CodingKeys: String, CodingKey {
        case id
        case mealId = "meal_id"
        case proteinG = "protein_g"
        case ironMg = "iron_mg"
        case vitaminDIu = "vitamin_d_iu"
        case vitaminCMg = "vitamin_c_mg"
        case zincMg = "zinc_mg"
        case omega3G = "omega3_g"
        case vitaminB12Mcg = "vitamin_b12_mcg"
        case biotinMcg = "biotin_mcg"
        case vitaminEMg = "vitamin_e_mg"
        case seleniumMcg = "selenium_mcg"
        case niacinMg = "niacin_mg"
    }
}