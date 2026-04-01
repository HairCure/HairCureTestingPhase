import SwiftUI

// MARK: - HairInsightsView

struct HairInsightsView: View {
    
    @Environment(AppDataStore.self) private var store
    
    //   API for tracking which item a scroll view is currently positioned at.
    //    idType: Int.self
    //    — This tells ScrollPosition what type the IDs of your scrollable items are. In this view, the cards are identified by their index  ForEach(routineCards.indices, id: \.self) — which are Ints (0, 1, 2...). So you pass Int.self to match that.
    @State private var routineScrollPosition = ScrollPosition(idType: Int.self)
    
    
    // computed property
    private var insightStore: HairInsightsDataStore { store.hairInsightsStore }
    private var userPlan: UserPlan? { store.activePlan }
    
    private var routine: RecommendationEngine.HairCareRoutine? {
        guard let plan = userPlan else { return nil }
        
        // Calls a  function buildHairCareRoutine on RecommendationEngine
        return RecommendationEngine.buildHairCareRoutine(for: plan)
    }
    
    private var routineCards: [RoutineCard] {
        guard let routine else { return [] }
        return [
            RoutineCard(
                iconName: "shower",
                title: "Wash Frequency",
                subtitle: routine.washFrequency
                    .components(separatedBy: "—").first?
                    .trimmingCharacters(in: .whitespaces) ?? routine.washFrequency,
                description: "Maintains scalp hydration; avoids barrier damage."
            ),
            RoutineCard(
                iconName: "drop.fill",
                title: "Oiling Schedule",
                subtitle: routine.oilingSchedule
                    .components(separatedBy: "—").first?
                    .trimmingCharacters(in: .whitespaces) ?? routine.oilingSchedule,
                description: routine.recommendedOils.prefix(2).joined(separator: ", ")
                + " — reduces protein loss in hair."
            ),
        ]
    }
    
    private var allFavourites: [AnyFavouriteItem] {
        insightStore.allFavourites()
    }
    
    private var routineIndex: Int {
        routineScrollPosition.viewID(type: Int.self) ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    routineSection
                    favouritesSection
                    careTipsSection
                    homeRemediesSection
                    Spacer(minLength: 20)
                }
            }
            .background(Color.hcCream.ignoresSafeArea())
            .navigationTitle("Hair Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Routine Section
    
    private var routineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recommended")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                Text("Hair Care Routine")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.55))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            GeometryReader { geo in
                let cardWidth = geo.size.width - 56
                let spacing: CGFloat = 12
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(routineCards.indices, id: \.self) { i in
                            RoutineCardView(card: routineCards[i])
                                .frame(width: cardWidth)
                                .id(i)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.trailing, 48)
                    .scrollTargetLayout()
                }
                // limitBehavior(.always) — prevents over-scrolling past first/last card
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                 //ScrollPosition binding
                .scrollPosition($routineScrollPosition)
            }
            .frame(height: 120)
            //// the dots that are below the cards
            HStack(spacing: 6) {
                ForEach(routineCards.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == routineIndex ? Color.black : Color.black.opacity(0.18))
                        .frame(width: i == routineIndex ? 18 : 7, height: 7)
                        .animation(.spring(duration: 0.35), value: routineIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Favourites Section
    
    private var favouritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            NavigationLink {
                FavouritesListView(insightStore: insightStore, userPlan: userPlan)
            } label: {
                HStack {
                    Text("Your Favourites")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            if allFavourites.isEmpty {
                EmptyFavouritesView()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allFavourites) { item in
                            NavigationLink {
                                destinationView(for: item)
                            } label: {
                                FavouriteCardView(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Care Tips Section
    
    private var careTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
           
            NavigationLink {
                CareTipsListView(insightStore: insightStore)
            } label: {
                HStack {
                    Text("Care Tips")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightStore.careTips.filter(\.isActive)) { tip in
                        NavigationLink {
                            
                            CareTipDetailView(tip: tip, insightStore: insightStore)
                        } label: {
                            InsightMediaCardView(
                                title: tip.title,
                                mediaURL: tip.mediaURL
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Home Remedies Section
    
    private var homeRemediesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            NavigationLink {
                HomeRemediesListView(insightStore: insightStore)
            } label: {
                HStack {
                    Text("Home Remedies")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightStore.homeRemedies.filter(\.isActive)) { remedy in
                        NavigationLink {
                            // userId removed
                            HomeRemedyDetailView(remedy: remedy, insightStore: insightStore)
                        } label: {
                            InsightMediaCardView(
                                title: remedy.title,
                                mediaURL: remedy.mediaURL
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Destination Router
    /// rolee of  this func  : Figure out what type of item this is, and send the user to the right screen."
    @ViewBuilder // allow a func to return different views here it will choose bw care tips and homeRemedies
    
    private func destinationView(for item: AnyFavouriteItem) -> some View {
        switch item {
        case .careTip(let t):
            CareTipDetailView(tip: t, insightStore: insightStore)
        case .remedy(let r):
            HomeRemedyDetailView(remedy: r, insightStore: insightStore)
        }
    }
}

// MARK: - RoutineCardView

struct RoutineCardView: View {
    let card: RoutineCard
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hcBrown.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: card.iconName)
                    .font(.title3)
                    .foregroundStyle(Color.hcBrown)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(card.title)
                        .font(.headline)
                        .foregroundStyle(.black)
                    Spacer()
                    Text(card.subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.black.opacity(0.5))
                }
                Text(card.description)
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.55))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.hcBrown.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hcBrown.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - InsightMediaCardView

struct InsightMediaCardView: View {
    let title: String
    let mediaURL: String?
    
    private let cardWidth: CGFloat = 160
    private let imageHeight: CGFloat = 140
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color(.systemGray5)
                if let imageName = mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .frame(width: cardWidth, height: imageHeight)
            .clipped()
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 36)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - FavouriteCardView

struct FavouriteCardView: View {
    let item: AnyFavouriteItem
    
    private let cardWidth: CGFloat = 140
    private let imageHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color(.systemGray5)
                if let imageName = item.mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                } else {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .frame(width: cardWidth, height: imageHeight)
            .clipped()
            
            Text(item.title)
                .font(.caption.bold())
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 30)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - EmptyFavouritesView

struct EmptyFavouritesView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.title2)
                .foregroundStyle(Color(.systemGray3))
            Text("Tap ♡ on any tip or remedy to save it here.")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
// MARK: - Preview

#Preview {
    let store = AppDataStore()   
    return HairInsightsView()
        .environment(store)
}
