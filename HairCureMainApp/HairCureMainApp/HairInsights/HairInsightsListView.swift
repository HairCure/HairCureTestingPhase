import SwiftUI

// MARK: - HomeRemediesListView

struct HomeRemediesListView: View {
    let insightStore: HairInsightsDataStore

    var body: some View {
        List {
            ForEach(insightStore.homeRemedies.filter(\.isActive)) { remedy in
                NavigationLink {
                    HomeRemedyDetailView(remedy: remedy, insightStore: insightStore)
                } label: {
                    HomeRemedyRowView(remedy: remedy)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)//hides default List bg
        .background(Color.hcCream)
        .navigationTitle("Home Remedies")
        
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

// MARK: - HomeRemedyRowView

struct HomeRemedyRowView: View {
    let remedy: HomeRemedy

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 80)

                if let imageName = remedy.mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "play.circle")
                        .font(.title)
                        .foregroundStyle(Color(.systemGray3))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(remedy.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(remedy.remedyDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let seconds = remedy.videoDurationSeconds {
                    Label(formatDuration(seconds), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - CareTipsListView

struct CareTipsListView: View {
    let insightStore: HairInsightsDataStore
    var body: some View {
        List {
            ForEach(insightStore.careTips.filter(\.isActive)) { tip in
                NavigationLink {
                    CareTipDetailView(tip: tip, insightStore: insightStore)
                } label: {
                    CareTipRowView(
                        tip: tip,
                        isFav: insightStore.isFavorite(contentId: tip.id),
                        onFavTap: {
                            insightStore.toggleFavorite(contentId: tip.id)
                        }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)//hides default List bg
        .background(Color.hcCream)
        .navigationTitle("Care Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - CareTipRowView

struct CareTipRowView: View {
    let tip: CareTip
    let isFav: Bool
    let onFavTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 72, height: 72)

                if let imageName = tip.mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "leaf")
                        .font(.title)
                        .foregroundStyle(Color(.systemGray3))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(tip.tipDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onFavTap) {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .foregroundStyle(isFav ? .red : Color(.systemGray3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - FavouritesListView

struct FavouritesListView: View {
    let insightStore: HairInsightsDataStore  // let, not var
    let userPlan: UserPlan?

    private var allFavs: [AnyFavouriteItem] {
        insightStore.allFavourites()
    }

    var body: some View {
        Group {
            if allFavs.isEmpty {
              
                ContentUnavailableView(
                    "No Favourites Yet",
                    systemImage: "heart",
                    description: Text("Tap ♡ on any tip or remedy to save it here.")
                    
                )
               
                .background(Color.hcCream)
            } else {
                List {
                    ForEach(allFavs) { item in
                        NavigationLink {
                            detailView(for: item)
                        } label: {
                            FavouriteItemRowView(item: item, onRemove: {
                                insightStore.toggleFavorite(contentId: item.id)
                            })
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                .scrollContentBackground(.hidden) //hides default List bg
                .background(Color.hcCream)
            }
        }
        .navigationTitle("Your Favourites")
        .navigationBarTitleDisplayMode(.inline)
    }

   
    @ViewBuilder
    private func detailView(for item: AnyFavouriteItem) -> some View {
        switch item {
        case .careTip(let t):
            CareTipDetailView(tip: t, insightStore: insightStore)
        case .remedy(let r):
            HomeRemedyDetailView(remedy: r, insightStore: insightStore)
        }
    }
}

// MARK: - FavouriteItemRowView

struct FavouriteItemRowView: View {
    let item: AnyFavouriteItem
    let onRemove: () -> Void

    private var typeLabel: String {
        switch item {
        case .careTip:  return "Care Tip"
        case .remedy:   return "Home Remedy"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)

                if let imageName = item.mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(typeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}
#Preview {
    NavigationStack {
        HomeRemediesListView(insightStore: .mock())
    }
}
#Preview {
    NavigationStack {
        CareTipsListView(insightStore: .mock())
    }
}
#Preview {
    NavigationStack {
        FavouritesListView(insightStore: .mock(), userPlan: nil)
    }
}
