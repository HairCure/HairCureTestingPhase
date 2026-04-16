import SwiftUI
import Combine
struct ContentView: View {
    @StateObject private var service = SupabaseService()
    @State private var selectedCategory = "All"

    let categories = ["All", "Breakfast", "Lunch", "Snack", "Dinner"]

    var filtered: [Meal] {
        selectedCategory == "All" ? service.meals
            : service.meals.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) { selectedCategory = cat }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(selectedCategory == cat ? Color.accentColor : Color.gray.opacity(0.12))
                                .foregroundColor(selectedCategory == cat ? .white : .primary)
                                .cornerRadius(20)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                Divider()

                if service.isLoading {
                    Spacer()
                    ProgressView("Loading meals...")
                    Spacer()
                } else if let error = service.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundColor(.orange)
                        Text(error).font(.caption).multilineTextAlignment(.center).foregroundColor(.secondary)
                        Button("Retry") { service.fetchAll() }.buttonStyle(.borderedProminent)
                    }.padding()
                    Spacer()
                } else {
                    List(filtered) { meal in
                        NavigationLink(destination: MealDetailView(meal: meal, nutrient: service.nutrients[meal.id])) {
                            MealRowView(meal: meal)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Food Data")
            .onAppear { service.fetchAll() }
        }
    }
}

struct MealRowView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = meal.imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(10)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name).font(.headline)
                if let desc = meal.description {
                    Text(desc).font(.caption).foregroundColor(.secondary).lineLimit(1)
                }
                HStack(spacing: 6) {
                    if let cat = meal.category {
                        Text(cat).font(.caption2)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                    Image(systemName: meal.isVeg == true ? "leaf.fill" : "fork.knife")
                        .font(.caption2)
                        .foregroundColor(meal.isVeg == true ? .green : .red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
