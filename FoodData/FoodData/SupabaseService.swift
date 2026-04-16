//
//  SupabaseService.swift
//  FoodData
//
//  Created by Chetan Kandpal on 06/04/26.
//


import Foundation
import Combine
class SupabaseService: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var nutrients: [Int: MealNutrient] = [:]  // keyed by meal_id
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchAll() {
        isLoading = true
        errorMessage = nil

        let group = DispatchGroup()

        group.enter()
        fetchMeals { group.leave() }

        group.enter()
        fetchNutrients { group.leave() }

        group.notify(queue: .main) {
            self.isLoading = false
        }
    }

    private func fetchMeals(completion: @escaping () -> Void) {
        fetch(endpoint: "meals?select=*") { (result: Result<[Meal], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): self.meals = data
                case .failure(let err): self.errorMessage = err.localizedDescription
                }
                completion()
            }
        }
    }

    private func fetchNutrients(completion: @escaping () -> Void) {
        fetch(endpoint: "meal_nutrients?select=*") { (result: Result<[MealNutrient], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    var map: [Int: MealNutrient] = [:]
                    for n in data { if let mid = n.mealId { map[mid] = n } }
                    self.nutrients = map
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
                completion()
            }
        }
    }

    private func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(Supabase.url)/rest/v1/\(endpoint)") else { return }
        var request = URLRequest(url: url)
        request.setValue(Supabase.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Supabase.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Raw: \(String(data: data, encoding: .utf8) ?? "nil")")
                completion(.failure(error))
            }
        }.resume()
    }
}
