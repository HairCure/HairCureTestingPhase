////////
////////  HairInsightsView.swift
////////  HairCureTesting1
////////
////////  Hair Insights main dashboard:
////////  • Large navigation title "Hair Insights" (collapses on scroll — iOS 17)
////////  • Recommended Hair Care Routine carousel (auto-advance, page dots)
////////  • Your Favourites horizontal scroll
////////  • Care Tips 2-column grid  → tapping "Care Tips >" pushes list view
////////  • Home Remedies horizontal scroll → tapping "Home Remedies >" pushes list view
////////  • All sections use iOS 17 scrollTransition
//////
//////
////import SwiftUI
////
////// MARK: - Section destination wrappers
////
////struct HairInsightSectionDest: Hashable {
////    enum Section: String { case favourites, careTips, homeRemedies, insights }
////    let section: Section
////}
////struct HairInsightItemDest: Hashable  { let id: UUID; let type: String }
////
////// MARK: - Local routine card model (for the Recommended carousel)
////
////private struct RoutineCard: Identifiable {
////    let id = UUID()
////    let icon: String
////    let title: String
////    let frequency: String
////    let description: String
////}
////
////// MARK: - Main View
////
////struct HairInsightsView: View {
////    @Environment(AppDataStore.self) private var store
////
////    // Navigation state
////    @State private var sectionDest: HairInsightSectionDest? = nil
////    @State private var itemDest:    HairInsightItemDest?    = nil
////
////    // Carousel state
////    @State private var carouselIndex: Int = 0
////
////    // Routine cards (based on user's active plan)
////    private let routineCards: [RoutineCard] = [
////        RoutineCard(icon: "shower.fill",           title: "Wash Frequency",    frequency: "2 – 3x per week",  description: "Maintains scalp hydration; avoids barrier damage."),
////        RoutineCard(icon: "drop.fill",             title: "Oiling Schedule",   frequency: "1 – 2x per week",  description: "Coconut oil reduces protein loss in hair."),
////        RoutineCard(icon: "comb.fill",             title: "Gentle Combing",    frequency: "Daily",             description: "Wide-tooth comb on damp hair prevents breakage."),
////        RoutineCard(icon: "bed.double.fill",       title: "Sleep Routine",     frequency: "7 – 8 hrs / night", description: "Hair cells repair during sleep — maintain a schedule.")
////    ]
////
////    var body: some View {
////        NavigationStack {
////            ScrollView(showsIndicators: false) {
////                VStack(alignment: .leading, spacing: 28) {
////
////                    // ── Recommended Carousel ──
////                    recommendedSection
////                        .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
////                        }
////
////                    // ── Your Favourites ──
////                    favouritesSection
////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
////                        }
////
////                    // ── Care Tips ──
////                    careTipsSection
////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
////                        }
////
////                    // ── Home Remedies ──
////                    homeRemediesSection
////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
////                        }
////
////                    Spacer(minLength: 32)
////                }
////                .padding(.top, 8)
////            }
////            .scrollBounceBehavior(.basedOnSize)
////            .frame(maxWidth: .infinity, maxHeight: .infinity)
////
////
////            // Native large title — collapses on scroll
////            .navigationTitle("Hair Insights")
////            .navigationBarTitleDisplayMode(.large)
////
////
////            // Section list push
////            .navigationDestination(item: $sectionDest) { dest in
////                HairInsightsListView(section: dest.section)
////            }
////            // Item detail push
////            .navigationDestination(item: $itemDest) { dest in
////                HairInsightDetailView(itemId: dest.id, type: dest.type)
////            }
////
////            // Auto-advance carousel every 4 s
////            .task {
////                while !Task.isCancelled {
////                    try? await Task.sleep(for: .seconds(4))
////                    withAnimation(.easeInOut(duration: 0.5)) {
////                        carouselIndex = (carouselIndex + 1) % routineCards.count
////                    }
////                }
////            }
////        }
////    }
////
////    // MARK: - Recommended Carousel
////
////    private var recommendedSection: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            VStack(alignment: .leading, spacing: 2) {
////                Text("Recommended")
////                    .font(.system(size: 24, weight: .bold))
////                Text("Hair Care Routine")
////                    .font(.system(size: 15))
////                    .foregroundColor(.secondary)
////            }
////            .padding(.horizontal, 20)
////
////            // Swipeable card
////            TabView(selection: $carouselIndex) {
////                ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
////                    RoutineCardView(card: card)
////                        .tag(i)
////                        .padding(.horizontal, 20)
////                }
////            }
////            .tabViewStyle(.page(indexDisplayMode: .never))
////            .frame(height: 110)
////
////            // Page dots
////            HStack(spacing: 8) {
////                ForEach(0..<routineCards.count, id: \.self) { i in
////                    Circle()
////                        .fill(i == carouselIndex ? Color.primary : Color.secondary.opacity(0.3))
////                        .frame(width: 7, height: 7)
////                        .animation(.easeInOut(duration: 0.2), value: carouselIndex)
////                }
////            }
////            .frame(maxWidth: .infinity)
////        }
////    }
////
////    // MARK: - Your Favourites
////
////    // Unified model so cards can come from any content type
////    private struct FavItem: Identifiable {
////        let id: UUID
////        let title: String
////        let imageUrl: String?
////        let type: String        // "homeRemedy" | "careTip" | "hairInsight"
////    }
////
////    private var favouriteItems: [FavItem] {
////        store.userFavorites
////            .filter { $0.userId == store.currentUserId }
////            .compactMap { fav -> FavItem? in
////                switch fav.contentType {
////                case "homeRemedy":
////                    if let r = store.homeRemedies.first(where: { $0.id == fav.contentId }) {
////                        return FavItem(id: r.id, title: r.title, imageUrl: r.mediaURL, type: "homeRemedy")
////                    }
////                case "careTip":
////                    if let t = store.careTips.first(where: { $0.id == fav.contentId }) {
////                        return FavItem(id: t.id, title: t.title, imageUrl: t.mediaURL, type: "careTip")
////                    }
////                case "hairInsight":
////                    if let h = store.hairInsights.first(where: { $0.id == fav.contentId }) {
////                        return FavItem(id: h.id, title: h.title, imageUrl: h.mediaURL, type: "hairInsight")
////                    }
////                default: break
////                }
////                return nil
////            }
////    }
////
////    private var favouritesSection: some View {
////        let items = favouriteItems
////
////        return VStack(alignment: .leading, spacing: 12) {
////            SectionHeader(title: "Your Favourites", chevron: items.isEmpty ? false : true) {
////                sectionDest = HairInsightSectionDest(section: .favourites)
////            }
////            .padding(.horizontal, 20)
////
////            if items.isEmpty {
////                VStack(spacing: 10) {
////                    Image(systemName: "heart.slash")
////                        .font(.system(size: 36))
////                        .foregroundColor(.secondary.opacity(0.5))
////                    Text("No favourites yet")
////                        .font(.system(size: 15, weight: .semibold))
////                        .foregroundColor(.secondary)
////                    Text("Tap the ♥ on any item to save it here.")
////                        .font(.system(size: 13))
////                        .foregroundColor(.secondary.opacity(0.7))
////                        .multilineTextAlignment(.center)
////                }
////                .frame(maxWidth: .infinity)
////                .padding(.vertical, 36)
////            } else {
////                ScrollView(.horizontal, showsIndicators: false) {
////                    HStack(spacing: 12) {
////                        ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { i, item in
////                            FavouriteThumbCard(
////                                label: item.title,
////                                imageUrl: item.imageUrl,
////                                gradientSeed: i
////                            ) {
////                                itemDest = HairInsightItemDest(id: item.id, type: item.type)
////                            }
////                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////                                c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
////                            }
////                        }
////                    }
////                    .padding(.horizontal, 20)
////                    .padding(.bottom, 4)
////                }
////            }
////        }
////    }
////
////    // MARK: - Care Tips
////
////    private var careTipsSection: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            SectionHeader(title: "Care Tips", chevron: true) {
////                sectionDest = HairInsightSectionDest(section: .careTips)
////            }
////            .padding(.horizontal, 20)
////
////            ScrollView(.horizontal, showsIndicators: false) {
////                HStack(spacing: 12) {
////                    ForEach(Array(store.careTips.prefix(4).enumerated()), id: \.element.id) { i, tip in
////                        CareTipCard(tip: tip, gradientSeed: i) {
////                            itemDest = HairInsightItemDest(id: tip.id, type: "careTip")
////                        }
////                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
////                        }
////                    }
////                }
////                .padding(.horizontal, 20)
////                .padding(.bottom, 4)
////            }
////        }
////    }
////
////    // MARK: - Home Remedies
////
////    private var homeRemediesSection: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            SectionHeader(title: "Home Remedies", chevron: true) {
////                sectionDest = HairInsightSectionDest(section: .homeRemedies)
////            }
////            .padding(.horizontal, 20)
////
////            ScrollView(.horizontal, showsIndicators: false) {
////                HStack(spacing: 12) {
////                    ForEach(Array(store.homeRemedies.enumerated()), id: \.element.id) { i, remedy in
////                        RemedyCard(remedy: remedy, gradientSeed: i) {
////                            itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy")
////                        }
////                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
////                        }
////                    }
////                }
////                .padding(.horizontal, 20)
////                .padding(.bottom, 4)
////            }
////        }
////    }
////}
////
////// MARK: - Section Header
////
////private struct SectionHeader: View {
////    let title: String
////    let chevron: Bool
////    let onTap: () -> Void
////
////    var body: some View {
////        Button(action: onTap) {
////            HStack(spacing: 4) {
////                Text(title)
////                    .font(.system(size: 22, weight: .bold))
////                    .foregroundColor(.primary)
////                if chevron {
////                    Image(systemName: "chevron.right")
////                        .font(.system(size: 16, weight: .semibold))
////                        .foregroundColor(.primary)
////                }
////            }
////        }
////        .buttonStyle(.plain)
////    }
////}
////
////// MARK: - Routine Card
////
////private struct RoutineCardView: View {
////    let card: RoutineCard
////
////    var body: some View {
////        HStack(spacing: 14) {
////            Image(systemName: card.icon)
////                .font(.system(size: 24))
////                .foregroundColor(.primary.opacity(0.7))
////                .frame(width: 42, height: 42)
////                .background(Color.secondary.opacity(0.12))
////                .clipShape(Circle())
////
////            VStack(alignment: .leading, spacing: 4) {
////                HStack(alignment: .firstTextBaseline) {
////                    Text(card.title)
////                        .font(.system(size: 16, weight: .semibold))
////                    Spacer()
////                    Text(card.frequency)
////                        .font(.system(size: 12, weight: .medium))
////                        .foregroundColor(.secondary)
////                }
////                Text(card.description)
////                    .font(.system(size: 13))
////                    .foregroundColor(.secondary)
////                    .lineLimit(2)
////            }
////        }
////        .padding(.horizontal, 18)
////        .padding(.vertical, 16)
////        .background(
////            RoundedRectangle(cornerRadius: 16)
////                .fill(Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.6))
////        )
////        .overlay(
////            RoundedRectangle(cornerRadius: 16)
////                .stroke(Color(red: 0.55, green: 0.40, blue: 0.30).opacity(0.25), lineWidth: 1)
////        )
////    }
////}
////
////// MARK: - Favourite Thumbnail Card  (App Store style)
////
////private struct FavouriteThumbCard: View {
////    let label: String
////    let imageUrl: String?
////    let gradientSeed: Int
////    let onTap: () -> Void
////
////    private static let palettes: [[Color]] = [
////        [Color(hue: 0.58, saturation: 0.55, brightness: 0.55), Color(hue: 0.62, saturation: 0.45, brightness: 0.35)],
////        [Color(hue: 0.08, saturation: 0.60, brightness: 0.55), Color(hue: 0.04, saturation: 0.55, brightness: 0.35)],
////        [Color(hue: 0.38, saturation: 0.50, brightness: 0.48), Color(hue: 0.35, saturation: 0.45, brightness: 0.30)],
////        [Color(hue: 0.78, saturation: 0.45, brightness: 0.50), Color(hue: 0.75, saturation: 0.40, brightness: 0.32)],
////        [Color(hue: 0.12, saturation: 0.55, brightness: 0.52), Color(hue: 0.09, saturation: 0.50, brightness: 0.34)]
////    ]
////
////    private var bgGradient: LinearGradient {
////        let c = Self.palettes[gradientSeed % Self.palettes.count]
////        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
////    }
////
////    var body: some View {
////        Button(action: onTap) {
////            ZStack(alignment: .bottom) {
////                // Background fill
////                RoundedRectangle(cornerRadius: 20)
////                    .fill(bgGradient)
////                    .frame(width: 150, height: 170)
////
////                // Full-bleed photo
////                if let url = imageUrl, let img = UIImage(named: url) {
////                    Image(uiImage: img)
////                        .resizable().scaledToFill()
////                        .frame(width: 150, height: 170)
////                        .clipped()
////                }
////
////                // Deep bottom gradient vignette (App Store style)
////                LinearGradient(
////                    stops: [
////                        .init(color: .clear,              location: 0.0),
////                        .init(color: .black.opacity(0.15), location: 0.45),
////                        .init(color: .black.opacity(0.72), location: 1.0)
////                    ],
////                    startPoint: .top, endPoint: .bottom
////                )
////
////                // Title at bottom
////                VStack(alignment: .leading, spacing: 2) {
////                    Text(label)
////                        .font(.system(size: 14, weight: .bold))
////                        .foregroundColor(.white)
////                        .lineLimit(2)
////                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
////                }
////                .frame(maxWidth: .infinity, alignment: .leading)
////                .padding(.horizontal, 12)
////                .padding(.bottom, 14)
////            }
////            .frame(width: 150, height: 170)
////            .clipShape(RoundedRectangle(cornerRadius: 20))
////            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
////        }
////        .buttonStyle(.plain)
////    }
////}
////
////// MARK: - Care Tip Card  (App Store style)
////
////private struct CareTipCard: View {
////    let tip: CareTip
////    let gradientSeed: Int
////    let onTap: () -> Void
////
////    private static let categories = ["Scalp Care", "Cleansing", "Styling", "Recovery", "Sleep", "Nutrition"]
////    private static let palettes: [[Color]] = [
////        [Color(hue: 0.60, saturation: 0.60, brightness: 0.52), Color(hue: 0.65, saturation: 0.50, brightness: 0.30)],
////        [Color(hue: 0.06, saturation: 0.65, brightness: 0.55), Color(hue: 0.03, saturation: 0.60, brightness: 0.32)],
////        [Color(hue: 0.36, saturation: 0.55, brightness: 0.48), Color(hue: 0.34, saturation: 0.50, brightness: 0.28)],
////        [Color(hue: 0.80, saturation: 0.50, brightness: 0.50), Color(hue: 0.77, saturation: 0.45, brightness: 0.30)]
////    ]
////
////    private var bgGradient: LinearGradient {
////        let c = Self.palettes[gradientSeed % Self.palettes.count]
////        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
////    }
////
////    private var category: String { Self.categories[gradientSeed % Self.categories.count] }
////
////    var body: some View {
////        Button(action: onTap) {
////            ZStack(alignment: .bottom) {
////                // Background
////                RoundedRectangle(cornerRadius: 20)
////                    .fill(bgGradient)
////                    .frame(width: 175, height: 200)
////
////                // Full-bleed photo
////                if let url = tip.mediaURL, let img = UIImage(named: url) {
////                    Image(uiImage: img)
////                        .resizable().scaledToFill()
////                        .frame(width: 175, height: 200)
////                        .clipped()
////                }
////
////                // Gradient vignette
////                LinearGradient(
////                    stops: [
////                        .init(color: .clear,               location: 0.0),
////                        .init(color: .black.opacity(0.10),  location: 0.40),
////                        .init(color: .black.opacity(0.78),  location: 1.0)
////                    ],
////                    startPoint: .top, endPoint: .bottom
////                )
////
////                // Text stack
////                VStack(alignment: .leading, spacing: 4) {
////                    // Eyebrow / category pill
////                    Text(category.uppercased())
////                        .font(.system(size: 10, weight: .bold))
////                        .foregroundColor(.white.opacity(0.75))
////                        .kerning(0.8)
////
////                    Text(tip.title)
////                        .font(.system(size: 15, weight: .bold))
////                        .foregroundColor(.white)
////                        .lineLimit(2)
////                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
////                }
////                .frame(maxWidth: .infinity, alignment: .leading)
////                .padding(.horizontal, 14)
////                .padding(.bottom, 16)
////            }
////            .frame(width: 175, height: 200)
////            .clipShape(RoundedRectangle(cornerRadius: 20))
////            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
////        }
////        .buttonStyle(.plain)
////    }
////}
////
////// MARK: - Remedy Card  (App Store style)
////
////private struct RemedyCard: View {
////    let remedy: HomeRemedy
////    let gradientSeed: Int
////    let onTap: () -> Void
////
////    private static let categories = ["Home Remedy", "Hair Mask", "Scalp Treat", "Oil Therapy"]
////    private static let palettes: [[Color]] = [
////        [Color(hue: 0.38, saturation: 0.58, brightness: 0.46), Color(hue: 0.35, saturation: 0.52, brightness: 0.26)],
////        [Color(hue: 0.07, saturation: 0.65, brightness: 0.54), Color(hue: 0.04, saturation: 0.58, brightness: 0.32)],
////        [Color(hue: 0.72, saturation: 0.48, brightness: 0.50), Color(hue: 0.70, saturation: 0.42, brightness: 0.30)],
////        [Color(hue: 0.14, saturation: 0.60, brightness: 0.52), Color(hue: 0.11, saturation: 0.55, brightness: 0.30)]
////    ]
////
////    private var bgGradient: LinearGradient {
////        let c = Self.palettes[gradientSeed % Self.palettes.count]
////        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
////    }
////
////    private var category: String { Self.categories[gradientSeed % Self.categories.count] }
////
////    var body: some View {
////        Button(action: onTap) {
////            ZStack(alignment: .bottom) {
////                // Background
////                RoundedRectangle(cornerRadius: 20)
////                    .fill(bgGradient)
////                    .frame(width: 175, height: 200)
////
////                // Full-bleed photo
////                if let url = remedy.mediaURL, let img = UIImage(named: url) {
////                    Image(uiImage: img)
////                        .resizable().scaledToFill()
////                        .frame(width: 175, height: 200)
////                        .clipped()
////                }
////
////                // Gradient vignette
////                LinearGradient(
////                    stops: [
////                        .init(color: .clear,               location: 0.0),
////                        .init(color: .black.opacity(0.12),  location: 0.40),
////                        .init(color: .black.opacity(0.80),  location: 1.0)
////                    ],
////                    startPoint: .top, endPoint: .bottom
////                )
////
////                // Text stack
////                VStack(alignment: .leading, spacing: 4) {
////                    Text(category.uppercased())
////                        .font(.system(size: 10, weight: .bold))
////                        .foregroundColor(.white.opacity(0.75))
////                        .kerning(0.8)
////
////                    Text(remedy.title)
////                        .font(.system(size: 15, weight: .bold))
////                        .foregroundColor(.white)
////                        .lineLimit(2)
////                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
////                }
////                .frame(maxWidth: .infinity, alignment: .leading)
////                .padding(.horizontal, 14)
////                .padding(.bottom, 16)
////            }
////            .frame(width: 175, height: 200)
////            .clipShape(RoundedRectangle(cornerRadius: 20))
////            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
////        }
////        .buttonStyle(.plain)
////    }
////}
////
//////// MARK: - Safe array subscript helper (kept for potential future use)
//////private extension Array {
//////    subscript(safe index: Int) -> Element? {
//////        guard index >= 0, index < count else { return nil }
//////        return self[index]
//////    }
//////}
//////
//////#Preview {
//////    HairInsightsView()
//////        .environment(AppDataStore())
//////}
//////
//////  HairInsightsView.swift
//////  HairCure
//////
//////  Hair Insights dashboard — iOS 18+ native redesign
//////  Image strategy:
//////  • Models use `mediaURL: String?`
//////  • `InsightImage` view handles: remote https:// URLs (AsyncImage),
//////    local asset names (Image()), and a branded gradient placeholder.
//////  • When you're ready to add images, just set mediaURL on any
//////    HairInsight / CareTip / HomeRemedy to either:
//////      - A remote URL string: "https://cdn.example.com/onion-juice.jpg"
//////      - A local asset name:  "remedy_onion"   (added to Assets.xcassets)
//////
////
//////import SwiftUI
//////
//////// MARK: - Image source helper ─────────────────────────────────────────────────
//////
///////// Resolves a nullable mediaURL string into the right rendering strategy.
//////enum InsightImageSource {
//////    case remote(URL)
//////    case local(String)
//////    case none
//////
//////    init(_ raw: String?) {
//////        guard let raw, !raw.isEmpty else { self = .none; return }
//////        if raw.hasPrefix("http"), let url = URL(string: raw) {
//////            self = .remote(url)
//////        } else {
//////            self = .local(raw)
//////        }
//////    }
//////}
//////
/////////// Drop-in image component for any insight card.
/////////// Fills its container; shows a gradient placeholder until real image is set.
////////struct InsightImage: View {
////////    let source: InsightImageSource
////////    let gradientSeed: Int
////////
////////    // Branded warm palette — shown as placeholder
////////    private static let palettes: [[Color]] = [
////////        [Color(red: 0.38, green: 0.18, blue: 0.10), Color(red: 0.60, green: 0.32, blue: 0.18)],
////////        [Color(red: 0.20, green: 0.38, blue: 0.28), Color(red: 0.10, green: 0.24, blue: 0.18)],
////////        [Color(red: 0.28, green: 0.22, blue: 0.52), Color(red: 0.15, green: 0.10, blue: 0.35)],
////////        [Color(red: 0.52, green: 0.38, blue: 0.14), Color(red: 0.34, green: 0.22, blue: 0.06)],
////////        [Color(red: 0.18, green: 0.40, blue: 0.56), Color(red: 0.10, green: 0.22, blue: 0.38)],
////////        [Color(red: 0.45, green: 0.20, blue: 0.28), Color(red: 0.28, green: 0.10, blue: 0.16)]
////////    ]
////////
////////    private var gradient: LinearGradient {
////////        let c = Self.palettes[gradientSeed % Self.palettes.count]
////////        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
////////    }
////////
////////    var body: some View {
////////        switch source {
////////
////////        // ── Remote URL — AsyncImage with shimmer placeholder ──
////////        case .remote(let url):
////////            AsyncImage(url: url) { phase in
////////                switch phase {
////////                case .success(let image):
////////                    image.resizable().scaledToFill()
////////                case .failure:
////////                    gradientPlaceholder
////////                case .empty:
////////                    shimmerPlaceholder
////////                @unknown default:
////////                    gradientPlaceholder
////////                }
////////            }
////////
////////        // ── Local asset name ──
////////        case .local(let name):
////////            if let uiImg = UIImage(named: name) {
////////                Image(uiImage: uiImg).resizable().scaledToFill()
////////            } else {
////////                gradientPlaceholder   // asset not found yet — shows placeholder
////////            }
////////
////////        // ── No image set — branded gradient placeholder ──
////////        case .none:
////////            gradientPlaceholder
////////        }
////////    }
////////
////////    private var gradientPlaceholder: some View {
////////        ZStack {
////////            gradient
////////            // Subtle icon hint — remove once real images are in
////////            Image(systemName: "photo")
////////                .font(.system(size: 22, weight: .light))
////////                .foregroundStyle(.white.opacity(0.25))
////////        }
////////    }
////////
////////    private var shimmerPlaceholder: some View {
////////        gradient
////////            .overlay(
////////                Rectangle()
////////                    .fill(
////////                        LinearGradient(
////////                            colors: [.clear, .white.opacity(0.12), .clear],
////////                            startPoint: .leading,
////////                            endPoint: .trailing
////////                        )
////////                    )
////////    )
////////    }
////////}
////////
////////// MARK: - Section destination wrappers ────────────────────────────────────────
////////
////////struct HairInsightSectionDest: Hashable {
////////    enum Section: String { case favourites, careTips, homeRemedies, insights }
////////    let section: Section
////////}
////////struct HairInsightItemDest: Hashable { let id: UUID; let type: String }
////////
////////// MARK: - Local routine card model ────────────────────────────────────────────
////////
////////private struct RoutineCard: Identifiable {
////////    let id = UUID()
////////    let icon: String
////////    let title: String
////////    let frequency: String
////////    let description: String
////////    /// Optional asset name or remote URL — add when design assets are ready
////////    var mediaURL: String? = nil
////////}
////////
////////// MARK: - Main View ────────────────────────────────────────────────────────────
////////
////////struct HairInsightsView: View {
////////    @Environment(AppDataStore.self) private var store
////////
////////    @State private var sectionDest: HairInsightSectionDest? = nil
////////    @State private var itemDest:    HairInsightItemDest?    = nil
////////    @State private var carouselIndex: Int = 0
////////
////////    private let routineCards: [RoutineCard] = [
////////        RoutineCard(icon: "shower.fill",     title: "Wash Frequency", frequency: "2–3× per week",   description: "Maintains scalp hydration; avoids barrier damage."),
////////        RoutineCard(icon: "drop.fill",       title: "Oiling Schedule", frequency: "1–2× per week",  description: "Coconut oil reduces protein loss in hair."),
////////        RoutineCard(icon: "comb.fill",       title: "Gentle Combing",  frequency: "Daily",           description: "Wide-tooth comb on damp hair prevents breakage."),
////////        RoutineCard(icon: "bed.double.fill", title: "Sleep Routine",   frequency: "7–8 hrs / night", description: "Hair cells repair during sleep — keep a schedule.")
////////    ]
////////
////////    var body: some View {
////////        NavigationStack {
////////            ScrollView(showsIndicators: false) {
////////                VStack(alignment: .leading, spacing: 28) {
////////                    recommendedSection
////////                        .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
////////                        }
////////
////////                    favouritesSection
////////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
////////                        }
////////
////////                    careTipsSection
////////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
////////                        }
////////
////////                    homeRemediesSection
////////                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
////////                        }
////////
////////                    Spacer(minLength: 32)
////////                }
////////                .padding(.top, 8)
////////            }
////////            .scrollBounceBehavior(.basedOnSize)
////////            .navigationTitle("Hair Insights")
////////            .navigationBarTitleDisplayMode(.large)
////////            .navigationDestination(item: $sectionDest) { dest in
////////                HairInsightsListView(section: dest.section)
////////            }
////////            .navigationDestination(item: $itemDest) { dest in
////////                HairInsightDetailView(itemId: dest.id, type: dest.type)
////////            }
////////            .task {
////////                while !Task.isCancelled {
////////                    try? await Task.sleep(for: .seconds(4))
////////                    withAnimation(.easeInOut(duration: 0.5)) {
////////                        carouselIndex = (carouselIndex + 1) % routineCards.count
////////                    }
////////                }
////////            }
////////        }
////////    }
////////
////////    // MARK: Recommended Carousel
////////
////////    private var recommendedSection: some View {
////////        VStack(alignment: .leading, spacing: 12) {
////////            VStack(alignment: .leading, spacing: 2) {
////////                Text("Recommended")
////////                    .font(.system(size: 24, weight: .bold))
////////                Text("Hair Care Routine")
////////                    .font(.system(size: 15))
////////                    .foregroundStyle(.secondary)
////////            }
////////            .padding(.horizontal, 20)
////////
////////            TabView(selection: $carouselIndex) {
////////                ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
////////                    RoutineCardView(card: card, index: i)
////////                        .tag(i)
////////                        .padding(.horizontal, 20)
////////                }
////////            }
////////            .tabViewStyle(.page(indexDisplayMode: .never))
////////            .frame(height: 110)
////////
////////            HStack(spacing: 8) {
////////                ForEach(0..<routineCards.count, id: \.self) { i in
////////                    Capsule()
////////                        .fill(i == carouselIndex ? Color.hcBrown : Color.secondary.opacity(0.25))
////////                        .frame(width: i == carouselIndex ? 18 : 7, height: 7)
////////                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: carouselIndex)
////////                }
////////            }
////////            .frame(maxWidth: .infinity)
////////        }
////////    }
////////
////////    // MARK: Favourites
////////
////////    private struct FavItem: Identifiable {
////////        let id: UUID
////////        let title: String
////////        let mediaURL: String?
////////        let type: String
////////    }
////////
////////    private var favouriteItems: [FavItem] {
////////        store.userFavorites
////////            .filter { $0.userId == store.currentUserId }
////////            .compactMap { fav -> FavItem? in
////////                switch fav.contentType {
////////                case "homeRemedy":
////////                    if let r = store.homeRemedies.first(where: { $0.id == fav.contentId }) {
////////                        return FavItem(id: r.id, title: r.title, mediaURL: r.mediaURL, type: "homeRemedy")
////////                    }
////////                case "careTip":
////////                    if let t = store.careTips.first(where: { $0.id == fav.contentId }) {
////////                        return FavItem(id: t.id, title: t.title, mediaURL: t.mediaURL, type: "careTip")
////////                    }
////////                case "hairInsight":
////////                    if let h = store.hairInsights.first(where: { $0.id == fav.contentId }) {
////////                        return FavItem(id: h.id, title: h.title, mediaURL: h.mediaURL, type: "hairInsight")
////////                    }
////////                default: break
////////                }
////////                return nil
////////            }
////////    }
////////
////////    private var favouritesSection: some View {
////////        let items = favouriteItems
////////        return VStack(alignment: .leading, spacing: 12) {
////////            SectionHeaderView(title: "Your Favourites", chevron: !items.isEmpty) {
////////                sectionDest = HairInsightSectionDest(section: .favourites)
////////            }
////////            .padding(.horizontal, 20)
////////
////////            if items.isEmpty {
////////                VStack(spacing: 10) {
////////                    Image(systemName: "heart.slash")
////////                        .font(.system(size: 36))
////////                        .foregroundStyle(.secondary.opacity(0.45))
////////                    Text("No favourites yet")
////////                        .font(.system(size: 15, weight: .semibold))
////////                        .foregroundStyle(.secondary)
////////                    Text("Tap ♥ on any item to save it here.")
////////                        .font(.system(size: 13))
////////                        .foregroundStyle(.secondary.opacity(0.7))
////////                        .multilineTextAlignment(.center)
////////                }
////////                .frame(maxWidth: .infinity)
////////                .padding(.vertical, 36)
////////            } else {
////////                ScrollView(.horizontal, showsIndicators: false) {
////////                    HStack(spacing: 12) {
////////                        ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { i, item in
////////                            InsightCard(
////////                                title: item.title,
////////                                eyebrow: nil,
////////                                mediaURL: item.mediaURL,
////////                                width: 150, height: 170,
////////                                gradientSeed: i
////////                            ) { itemDest = HairInsightItemDest(id: item.id, type: item.type) }
////////                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////////                                c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
////////                            }
////////                        }
////////                    }
////////                    .padding(.horizontal, 20).padding(.bottom, 4)
////////                }
////////            }
////////        }
////////    }
////////
////////    // MARK: Care Tips
////////
////////    private var careTipsSection: some View {
////////        VStack(alignment: .leading, spacing: 12) {
////////            SectionHeaderView(title: "Care Tips", chevron: true) {
////////                sectionDest = HairInsightSectionDest(section: .careTips)
////////            }
////////            .padding(.horizontal, 20)
////////
////////            ScrollView(.horizontal, showsIndicators: false) {
////////                HStack(spacing: 12) {
////////                    ForEach(Array(store.careTips.prefix(4).enumerated()), id: \.element.id) { i, tip in
////////                        InsightCard(
////////                            title: tip.title,
////////                            eyebrow: tip.category.uppercased(),
////////                            mediaURL: tip.mediaURL,
////////                            width: 175, height: 200,
////////                            gradientSeed: i + 2
////////                        ) { itemDest = HairInsightItemDest(id: tip.id, type: "careTip") }
////////                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
////////                        }
////////                    }
////////                }
////////                .padding(.horizontal, 20).padding(.bottom, 4)
////////            }
////////        }
////////    }
////////
////////    // MARK: Home Remedies
////////
////////    private var homeRemediesSection: some View {
////////        VStack(alignment: .leading, spacing: 12) {
////////            SectionHeaderView(title: "Home Remedies", chevron: true) {
////////                sectionDest = HairInsightSectionDest(section: .homeRemedies)
////////            }
////////            .padding(.horizontal, 20)
////////
////////            ScrollView(.horizontal, showsIndicators: false) {
////////                HStack(spacing: 12) {
////////                    ForEach(Array(store.homeRemedies.enumerated()), id: \.element.id) { i, remedy in
////////                        InsightCard(
////////                            title: remedy.title,
////////                            eyebrow: "HOME REMEDY",
////////                            mediaURL: remedy.mediaURL,
////////                            width: 175, height: 200,
////////                            gradientSeed: i + 1
////////                        ) { itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy") }
////////                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
////////                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
////////                        }
////////                    }
////////                }
////////                .padding(.horizontal, 20).padding(.bottom, 4)
////////            }
////////        }
////////    }
////////}
////////
////////// MARK: - InsightCard (unified card for all content types) ────────────────────
//////////
//////////  To add an image to any card:
//////////  1. Remote: set mediaURL = "https://your-cdn.com/image.jpg"
//////////  2. Local:  add image to Assets.xcassets, set mediaURL = "asset_name"
//////////  3. Nothing needed in this file — InsightImage handles it automatically.
////////
////////struct InsightCard: View {
////////    let title:       String
////////    let eyebrow:     String?
////////    let mediaURL:    String?
////////    let width:       CGFloat
////////    let height:      CGFloat
////////    let gradientSeed: Int
////////    let onTap:       () -> Void
////////
////////    var body: some View {
////////        Button(action: onTap) {
////////            ZStack(alignment: .bottom) {
////////                // ── Background / image ──
////////                InsightImage(
////////                    source: InsightImageSource(mediaURL),
////////                    gradientSeed: gradientSeed
////////                )
////////                .frame(width: width, height: height)
////////                .clipped()
////////
////////                // ── Vignette ──
////////                LinearGradient(
////////                    stops: [
////////                        .init(color: .clear,               location: 0.0),
////////                        .init(color: .black.opacity(0.12), location: 0.40),
////////                        .init(color: .black.opacity(0.80), location: 1.0)
////////                    ],
////////                    startPoint: .top, endPoint: .bottom
////////                )
////////
////////                // ── Text ──
////////                VStack(alignment: .leading, spacing: 4) {
////////                    if let eyebrow {
////////                        Text(eyebrow)
////////                            .font(.system(size: 10, weight: .bold))
////////                            .foregroundStyle(.white.opacity(0.72))
////////                            .kerning(0.8)
////////                    }
////////                    Text(title)
////////                        .font(.system(size: 15, weight: .bold))
////////                        .foregroundStyle(.white)
////////                        .lineLimit(2)
////////                        .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
////////                }
////////                .frame(maxWidth: .infinity, alignment: .leading)
////////                .padding(.horizontal, 14)
////////                .padding(.bottom, 16)
////////            }
////////            .frame(width: width, height: height)
////////            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
////////            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
////////        }
////////        .buttonStyle(.plain)
////////    }
////////}
////////
////////// MARK: - Section Header ───────────────────────────────────────────────────────
////////
////////struct SectionHeaderView: View {
////////    let title: String
////////    let chevron: Bool
////////    let onTap: () -> Void
////////
////////    var body: some View {
////////        Button(action: onTap) {
////////            HStack(spacing: 4) {
////////                Text(title)
////////                    .font(.system(size: 22, weight: .bold))
////////                    .foregroundStyle(.primary)
////////                if chevron {
////////                    Image(systemName: "chevron.right")
////////                        .font(.system(size: 16, weight: .semibold))
////////                        .foregroundStyle(.primary)
////////                }
////////            }
////////        }
////////        .buttonStyle(.plain)
////////    }
////////}
////////
////////// MARK: - Routine Card ─────────────────────────────────────────────────────────
////////
////////private struct RoutineCardView: View {
////////    let card: RoutineCard
////////    let index: Int
////////
////////    var body: some View {
////////        HStack(spacing: 14) {
////////            // ── Icon or image ──
////////            ZStack {
////////                InsightImage(source: InsightImageSource(card.mediaURL), gradientSeed: index)
////////                    .frame(width: 46, height: 46)
////////                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
////////
////////                // Show SF symbol on top only when no image set
////////                if InsightImageSource(card.mediaURL) == .none {
////////                    Image(systemName: card.icon)
////////                        .font(.system(size: 20, weight: .medium))
////////                        .foregroundStyle(.white.opacity(0.80))
////////                }
////////            }
////////            .frame(width: 46, height: 46)
////////
////////            VStack(alignment: .leading, spacing: 4) {
////////                HStack(alignment: .firstTextBaseline) {
////////                    Text(card.title)
////////                        .font(.system(size: 16, weight: .semibold))
////////                    Spacer()
////////                    Text(card.frequency)
////////                        .font(.system(size: 12, weight: .medium))
////////                        .foregroundStyle(.secondary)
////////                }
////////                Text(card.description)
////////                    .font(.system(size: 13))
////////                    .foregroundStyle(.secondary)
////////                    .lineLimit(2)
////////            }
////////        }
////////        .padding(.horizontal, 18)
////////        .padding(.vertical, 16)
////////        .background(
////////            RoundedRectangle(cornerRadius: 16, style: .continuous)
////////                .fill(Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.6))
////////        )
////////        .overlay(
////////            RoundedRectangle(cornerRadius: 16, style: .continuous)
////////                .stroke(Color(red: 0.55, green: 0.40, blue: 0.30).opacity(0.25), lineWidth: 1)
////////        )
////////    }
////////}
////////
////////// Make InsightImageSource equatable for the .none check above
////////extension InsightImageSource: Equatable {
////////    static func == (lhs: InsightImageSource, rhs: InsightImageSource) -> Bool {
////////        switch (lhs, rhs) {
////////        case (.none, .none):   return true
////////        case (.remote(let a), .remote(let b)): return a == b
////////        case (.local(let a),  .local(let b)):  return a == b
////////        default: return false
////////        }
////////    }
////////}
////////
////////// MARK: - Preview ──────────────────────────────────────────────────────────────
////////
////////#Preview {
////////    HairInsightsView()
////////        .environment(AppDataStore())
////////}
////
////  HairInsightsView.swift
////  Hair Insights main dashboard
//
//import SwiftUI
//
//// MARK: - Section destination wrappers
//
//struct HairInsightSectionDest: Hashable {
//    enum Section: String { case favourites, careTips, homeRemedies, insights }
//    let section: Section
//}
//struct HairInsightItemDest: Hashable { let id: UUID; let type: String }
//
//// MARK: - Local routine card model
//
//private struct RoutineCard: Identifiable {
//    let id = UUID()
//    let icon: String
//    let title: String
//    let frequency: String
//    let description: String
//}
//
//// MARK: - Main View
//
//struct HairInsightsView: View {
//
//    // ── CHANGED: Removed @Environment(AppDataStore.self) entirely.
//    //    All hair-related data (careTips, homeRemedies, hairInsights,
//    //    userFavorites, currentUserId) live in HairInsightsDataStore.
//    //    AppDataStore is no longer needed in this view.
//    @Environment(HairInsightsDataStore.self) private var hairStore
//
//    @State private var sectionDest: HairInsightSectionDest? = nil
//    @State private var itemDest:    HairInsightItemDest?    = nil
//    @State private var carouselIndex: Int = 0
//
//    private let routineCards: [RoutineCard] = [
//        RoutineCard(icon: "shower.fill",     title: "Wash Frequency",  frequency: "2 – 3x per week",  description: "Maintains scalp hydration; avoids barrier damage."),
//        RoutineCard(icon: "drop.fill",       title: "Oiling Schedule", frequency: "1 – 2x per week",  description: "Coconut oil reduces protein loss in hair."),
//        RoutineCard(icon: "comb.fill",       title: "Gentle Combing",  frequency: "Daily",             description: "Wide-tooth comb on damp hair prevents breakage."),
//        RoutineCard(icon: "bed.double.fill", title: "Sleep Routine",   frequency: "7 – 8 hrs / night", description: "Hair cells repair during sleep — maintain a schedule.")
//    ]
//
//    var body: some View {
//        NavigationStack {
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 28) {
//
//                    recommendedSection
//                        .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
//                        }
//
//                    favouritesSection
//                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
//                        }
//
//                    careTipsSection
//                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
//                        }
//
//                    homeRemediesSection
//                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
//                        }
//
//                    Spacer(minLength: 32)
//                }
//                .padding(.top, 8)
//            }
//            .scrollBounceBehavior(.basedOnSize)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .navigationTitle("Hair Insights")
//            .navigationBarTitleDisplayMode(.large)
//            .navigationDestination(item: $sectionDest) { dest in
//                HairInsightsListView(section: dest.section)
//            }
//            .navigationDestination(item: $itemDest) { dest in
//                HairInsightDetailView(itemId: dest.id, type: dest.type)
//            }
//            .task {
//                while !Task.isCancelled {
//                    try? await Task.sleep(for: .seconds(4))
//                    withAnimation(.easeInOut(duration: 0.5)) {
//                        carouselIndex = (carouselIndex + 1) % routineCards.count
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Recommended Carousel
//    // No store references here — uses only local routineCards data.
//
//    private var recommendedSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Recommended")
//                    .font(.system(size: 24, weight: .bold))
//                Text("Hair Care Routine")
//                    .font(.system(size: 15))
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal, 20)
//
//            TabView(selection: $carouselIndex) {
//                ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
//                    RoutineCardView(card: card)
//                        .tag(i)
//                        .padding(.horizontal, 20)
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .frame(height: 110)
//
//            HStack(spacing: 8) {
//                ForEach(0..<routineCards.count, id: \.self) { i in
//                    Circle()
//                        .fill(i == carouselIndex ? Color.primary : Color.secondary.opacity(0.3))
//                        .frame(width: 7, height: 7)
//                        .animation(.easeInOut(duration: 0.2), value: carouselIndex)
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//
//    // MARK: - Your Favourites
//
//    // Unified model so cards can come from any content type
//    private struct FavItem: Identifiable {
//        let id: UUID
//        let title: String
//        let imageUrl: String?
//        let type: String    // "homeRemedy" | "careTip" | "hairInsight"
//    }
//
//    private var favouriteItems: [FavItem] {
//        // ── CHANGED: was store.userFavorites / store.currentUserId
//        //    Both userFavorites and currentUserId now live in hairStore.
//        hairStore.userFavorites
//            .filter { $0.userId == hairStore.currentUserId }
//            .compactMap { fav -> FavItem? in
//                switch fav.contentType {
//                case "homeRemedy":
//                    // ── CHANGED: was store.homeRemedies
//                    if let r = hairStore.homeRemedies.first(where: { $0.id == fav.contentId }) {
//                        return FavItem(id: r.id, title: r.title, imageUrl: r.mediaURL, type: "homeRemedy")
//                    }
//                case "careTip":
//                    // ── CHANGED: was store.careTips
//                    if let t = hairStore.careTips.first(where: { $0.id == fav.contentId }) {
//                        return FavItem(id: t.id, title: t.title, imageUrl: t.mediaURL, type: "careTip")
//                    }
//                case "hairInsight":
//                    // ── CHANGED: was store.hairInsights
//                    if let h = hairStore.hairInsights.first(where: { $0.id == fav.contentId }) {
//                        return FavItem(id: h.id, title: h.title, imageUrl: h.mediaURL, type: "hairInsight")
//                    }
//                default: break
//                }
//                return nil
//            }
//    }
//
//    private var favouritesSection: some View {
//        let items = favouriteItems
//        return VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Your Favourites", chevron: !items.isEmpty) {
//                sectionDest = HairInsightSectionDest(section: .favourites)
//            }
//            .padding(.horizontal, 20)
//
//            if items.isEmpty {
//                VStack(spacing: 10) {
//                    Image(systemName: "heart.slash")
//                        .font(.system(size: 36))
//                        .foregroundColor(.secondary.opacity(0.5))
//                    Text("No favourites yet")
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(.secondary)
//                    Text("Tap the ♥ on any item to save it here.")
//                        .font(.system(size: 13))
//                        .foregroundColor(.secondary.opacity(0.7))
//                        .multilineTextAlignment(.center)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 36)
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { i, item in
//                            FavouriteThumbCard(
//                                label: item.title,
//                                imageUrl: item.imageUrl,
//                                gradientSeed: i
//                            ) {
//                                itemDest = HairInsightItemDest(id: item.id, type: item.type)
//                            }
//                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
//                                c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 4)
//                }
//            }
//        }
//    }
//
//    // MARK: - Care Tips
//
//    private var careTipsSection: some View {
//        // ── CHANGED: was store.careTips
//        //    Extracted into a local constant first — this also fixes the
//        //    "compiler unable to type-check" error (line 165 in original)
//        //    caused by too much type inference inside a complex property body.
//        let tips = Array(hairStore.careTips.prefix(4).enumerated())
//        return VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Care Tips", chevron: true) {
//                sectionDest = HairInsightSectionDest(section: .careTips)
//            }
//            .padding(.horizontal, 20)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(tips, id: \.element.id) { i, tip in
//                        CareTipCard(tip: tip, gradientSeed: i) {
//                            itemDest = HairInsightItemDest(id: tip.id, type: "careTip")
//                        }
//                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 4)
//            }
//        }
//    }
//
//    // MARK: - Home Remedies
//
//    private var homeRemediesSection: some View {
//        // ── CHANGED: was store.homeRemedies
//        //    Same extraction pattern as careTipsSection to avoid
//        //    type-checker timeout and ForEach binding errors.
//        let remedies = Array(hairStore.homeRemedies.enumerated())
//        return VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Home Remedies", chevron: true) {
//                sectionDest = HairInsightSectionDest(section: .homeRemedies)
//            }
//            .padding(.horizontal, 20)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(remedies, id: \.element.id) { i, remedy in
//                        RemedyCard(remedy: remedy, gradientSeed: i) {
//                            itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy")
//                        }
//                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
//                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 4)
//            }
//        }
//    }
//}
//
//// MARK: - Section Header
//
//private struct SectionHeader: View {
//    let title: String
//    let chevron: Bool
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 4) {
//                Text(title)
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.primary)
//                if chevron {
//                    Image(systemName: "chevron.right")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.primary)
//                }
//            }
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Routine Card
//
//private struct RoutineCardView: View {
//    let card: RoutineCard
//
//    var body: some View {
//        HStack(spacing: 14) {
//            Image(systemName: card.icon)
//                .font(.system(size: 24))
//                .foregroundColor(.primary.opacity(0.7))
//                .frame(width: 42, height: 42)
//                .background(Color.secondary.opacity(0.12))
//                .clipShape(Circle())
//
//            VStack(alignment: .leading, spacing: 4) {
//                HStack(alignment: .firstTextBaseline) {
//                    Text(card.title)
//                        .font(.system(size: 16, weight: .semibold))
//                    Spacer()
//                    Text(card.frequency)
//                        .font(.system(size: 12, weight: .medium))
//                        .foregroundColor(.secondary)
//                }
//                Text(card.description)
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                    .lineLimit(2)
//            }
//        }
//        .padding(.horizontal, 18)
//        .padding(.vertical, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.6))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color(red: 0.55, green: 0.40, blue: 0.30).opacity(0.25), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Favourite Thumbnail Card
//
//private struct FavouriteThumbCard: View {
//    let label: String
//    let imageUrl: String?
//    let gradientSeed: Int
//    let onTap: () -> Void
//
//    private static let palettes: [[Color]] = [
//        [Color(hue: 0.58, saturation: 0.55, brightness: 0.55), Color(hue: 0.62, saturation: 0.45, brightness: 0.35)],
//        [Color(hue: 0.08, saturation: 0.60, brightness: 0.55), Color(hue: 0.04, saturation: 0.55, brightness: 0.35)],
//        [Color(hue: 0.38, saturation: 0.50, brightness: 0.48), Color(hue: 0.35, saturation: 0.45, brightness: 0.30)],
//        [Color(hue: 0.78, saturation: 0.45, brightness: 0.50), Color(hue: 0.75, saturation: 0.40, brightness: 0.32)],
//        [Color(hue: 0.12, saturation: 0.55, brightness: 0.52), Color(hue: 0.09, saturation: 0.50, brightness: 0.34)]
//    ]
//
//    private var bgGradient: LinearGradient {
//        let c = Self.palettes[gradientSeed % Self.palettes.count]
//        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
//    }
//
//    var body: some View {
//        Button(action: onTap) {
//            ZStack(alignment: .bottom) {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(bgGradient)
//                    .frame(width: 150, height: 170)
//
//                if let url = imageUrl, let img = UIImage(named: url) {
//                    Image(uiImage: img)
//                        .resizable().scaledToFill()
//                        .frame(width: 150, height: 170)
//                        .clipped()
//                }
//
//                LinearGradient(
//                    stops: [
//                        .init(color: .clear,               location: 0.0),
//                        .init(color: .black.opacity(0.15), location: 0.45),
//                        .init(color: .black.opacity(0.72), location: 1.0)
//                    ],
//                    startPoint: .top, endPoint: .bottom
//                )
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(label)
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(.white)
//                        .lineLimit(2)
//                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 12)
//                .padding(.bottom, 14)
//            }
//            .frame(width: 150, height: 170)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Care Tip Card
//
//private struct CareTipCard: View {
//    let tip: CareTip
//    let gradientSeed: Int
//    let onTap: () -> Void
//
//    private static let categories = ["Scalp Care", "Cleansing", "Styling", "Recovery", "Sleep", "Nutrition"]
//    private static let palettes: [[Color]] = [
//        [Color(hue: 0.60, saturation: 0.60, brightness: 0.52), Color(hue: 0.65, saturation: 0.50, brightness: 0.30)],
//        [Color(hue: 0.06, saturation: 0.65, brightness: 0.55), Color(hue: 0.03, saturation: 0.60, brightness: 0.32)],
//        [Color(hue: 0.36, saturation: 0.55, brightness: 0.48), Color(hue: 0.34, saturation: 0.50, brightness: 0.28)],
//        [Color(hue: 0.80, saturation: 0.50, brightness: 0.50), Color(hue: 0.77, saturation: 0.45, brightness: 0.30)]
//    ]
//
//    private var bgGradient: LinearGradient {
//        let c = Self.palettes[gradientSeed % Self.palettes.count]
//        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
//    }
//    private var category: String { Self.categories[gradientSeed % Self.categories.count] }
//
//    var body: some View {
//        Button(action: onTap) {
//            ZStack(alignment: .bottom) {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(bgGradient)
//                    .frame(width: 175, height: 200)
//
//                if let url = tip.mediaURL, let img = UIImage(named: url) {
//                    Image(uiImage: img)
//                        .resizable().scaledToFill()
//                        .frame(width: 175, height: 200)
//                        .clipped()
//                }
//
//                LinearGradient(
//                    stops: [
//                        .init(color: .clear,               location: 0.0),
//                        .init(color: .black.opacity(0.10), location: 0.40),
//                        .init(color: .black.opacity(0.78), location: 1.0)
//                    ],
//                    startPoint: .top, endPoint: .bottom
//                )
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(category.uppercased())
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(.white.opacity(0.75))
//                        .kerning(0.8)
//                    Text(tip.title)
//                        .font(.system(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                        .lineLimit(2)
//                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 14)
//                .padding(.bottom, 16)
//            }
//            .frame(width: 175, height: 200)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Remedy Card
//
//private struct RemedyCard: View {
//    let remedy: HomeRemedy
//    let gradientSeed: Int
//    let onTap: () -> Void
//
//    private static let categories = ["Home Remedy", "Hair Mask", "Scalp Treat", "Oil Therapy"]
//    private static let palettes: [[Color]] = [
//        [Color(hue: 0.38, saturation: 0.58, brightness: 0.46), Color(hue: 0.35, saturation: 0.52, brightness: 0.26)],
//        [Color(hue: 0.07, saturation: 0.65, brightness: 0.54), Color(hue: 0.04, saturation: 0.58, brightness: 0.32)],
//        [Color(hue: 0.72, saturation: 0.48, brightness: 0.50), Color(hue: 0.70, saturation: 0.42, brightness: 0.30)],
//        [Color(hue: 0.14, saturation: 0.60, brightness: 0.52), Color(hue: 0.11, saturation: 0.55, brightness: 0.30)]
//    ]
//
//    private var bgGradient: LinearGradient {
//        let c = Self.palettes[gradientSeed % Self.palettes.count]
//        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
//    }
//    private var category: String { Self.categories[gradientSeed % Self.categories.count] }
//
//    var body: some View {
//        Button(action: onTap) {
//            ZStack(alignment: .bottom) {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(bgGradient)
//                    .frame(width: 175, height: 200)
//
//                if let url = remedy.mediaURL, let img = UIImage(named: url) {
//                    Image(uiImage: img)
//                        .resizable().scaledToFill()
//                        .frame(width: 175, height: 200)
//                        .clipped()
//                }
//
//                LinearGradient(
//                    stops: [
//                        .init(color: .clear,               location: 0.0),
//                        .init(color: .black.opacity(0.12), location: 0.40),
//                        .init(color: .black.opacity(0.80), location: 1.0)
//                    ],
//                    startPoint: .top, endPoint: .bottom
//                )
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(category.uppercased())
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(.white.opacity(0.75))
//                        .kerning(0.8)
//                    Text(remedy.title)
//                        .font(.system(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                        .lineLimit(2)
//                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 14)
//                .padding(.bottom, 16)
//            }
//            .frame(width: 175, height: 200)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
//        }
//        .buttonStyle(.plain)
//    }
//}
//  HairInsightsView.swift
//  Hair Insights main dashboard

import SwiftUI

// MARK: - Section destination wrappers

struct HairInsightSectionDest: Hashable {
    enum Section: String { case favourites, careTips, homeRemedies, insights }
    let section: Section
}
struct HairInsightItemDest: Hashable { let id: UUID; let type: String }

// MARK: - Local routine card model

private struct RoutineCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let frequency: String
    let description: String
}

// MARK: - Main View

struct HairInsightsView: View {

    @Environment(HairInsightsDataStore.self) private var hairStore
    @Environment(AppDataStore.self) private var appStore
    @State private var sectionDest: HairInsightSectionDest? = nil
    @State private var itemDest:    HairInsightItemDest?    = nil
    @State private var carouselIndex: Int = 0

    // ── CHANGED: Dynamic Routine Cards from RecommendationEngine ──
    private var routineCards: [RoutineCard] {
        // 1. Get the active plan from the store
        guard let activePlan = appStore.userPlans.first(where: { $0.isActive }) else {
            return []
        }
        
        // 2. Generate the routine details using the Engine
        let routine = RecommendationEngine.buildHairCareRoutine(for: activePlan)
        
        // 3. Map the Engine output to the UI Cards
        return [
            RoutineCard(
                icon: "shower.fill",
                title: "Wash Frequency",
                frequency: "Target",
                description: routine.washFrequency
            ),
            RoutineCard(
                icon: "drop.fill",
                title: "Oiling Schedule",
                frequency: "Plan",
                description: routine.oilingSchedule
            ),
            RoutineCard(
                icon: "bubbles.and.sparkles.fill",
                title: "Recommended Wash",
                frequency: "Usage",
                description: routine.shampooType
            ),
            RoutineCard(
                icon: "lightbulb.fill",
                title: "Daily Care Tip",
                frequency: "Daily",
                description: routine.scalpSpecificTips.first ?? "Maintain consistency for best results."
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    recommendedSection
                        .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
                        }

                    favouritesSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
                        }

                    careTipsSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
                        }

                    homeRemediesSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
                        }

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Hair Insights")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $sectionDest) { dest in
                HairInsightsListView(section: dest.section)
            }
            .navigationDestination(item: $itemDest) { dest in
                HairInsightDetailView(itemId: dest.id, type: dest.type)
            }
            .task {
                // Only start auto-scroll if we have cards from the engine
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(4))
                    if !routineCards.isEmpty {
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                carouselIndex = (carouselIndex + 1) % routineCards.count
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recommended Carousel

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recommended")
                    .font(.system(size: 24, weight: .bold))
                Text("Hair Care Routine")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            if !routineCards.isEmpty {
                TabView(selection: $carouselIndex) {
                    ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
                        RoutineCardView(card: card)
                            .tag(i)
                            .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 110)

                HStack(spacing: 8) {
                    ForEach(0..<routineCards.count, id: \.self) { i in
                        Circle()
                            .fill(i == carouselIndex ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 7, height: 7)
                            .animation(.easeInOut(duration: 0.2), value: carouselIndex)
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                // Placeholder if user hasn't completed assessment
                VStack(spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                    Text("Analysis Required")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Complete a scalp scan to unlock your routine.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Your Favourites

    private struct FavItem: Identifiable {
        let id: UUID
        let title: String
        let imageUrl: String?
        let type: String
    }

    private var favouriteItems: [FavItem] {
        hairStore.userFavorites
            .filter { $0.userId == hairStore.currentUserId }
            .compactMap { fav -> FavItem? in
                switch fav.contentType {
                case "homeRemedy":
                    if let r = hairStore.homeRemedies.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: r.id, title: r.title, imageUrl: r.mediaURL, type: "homeRemedy")
                    }
                case "careTip":
                    if let t = hairStore.careTips.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: t.id, title: t.title, imageUrl: t.mediaURL, type: "careTip")
                    }
                case "hairInsight":
                    if let h = hairStore.hairInsights.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: h.id, title: h.title, imageUrl: h.mediaURL, type: "hairInsight")
                    }
                default: break
                }
                return nil
            }
    }

    private var favouritesSection: some View {
        let items = favouriteItems
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Favourites", chevron: !items.isEmpty) {
                sectionDest = HairInsightSectionDest(section: .favourites)
            }
            .padding(.horizontal, 20)

            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No favourites yet")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Tap the ♥ on any item to save it here.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { i, item in
                            FavouriteThumbCard(
                                label: item.title,
                                imageUrl: item.imageUrl,
                                gradientSeed: i
                            ) {
                                itemDest = HairInsightItemDest(id: item.id, type: item.type)
                            }
                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                                c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                }
            }
        }
    }

    // MARK: - Care Tips

    private var careTipsSection: some View {
        let tips = Array(hairStore.careTips.prefix(4).enumerated())
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Care Tips", chevron: true) {
                sectionDest = HairInsightSectionDest(section: .careTips)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tips, id: \.element.id) { i, tip in
                        CareTipCard(tip: tip, gradientSeed: i) {
                            itemDest = HairInsightItemDest(id: tip.id, type: "careTip")
                        }
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Home Remedies

    private var homeRemediesSection: some View {
        let remedies = Array(hairStore.homeRemedies.enumerated())
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Home Remedies", chevron: true) {
                sectionDest = HairInsightSectionDest(section: .homeRemedies)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(remedies, id: \.element.id) { i, remedy in
                        RemedyCard(remedy: remedy, gradientSeed: i) {
                            itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy")
                        }
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Shared UI Components (Subviews)

private struct SectionHeader: View {
    let title: String
    let chevron: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct RoutineCardView: View {
    let card: RoutineCard

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: card.icon)
                .font(.system(size: 24))
                .foregroundColor(.primary.opacity(0.7))
                .frame(width: 42, height: 42)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(card.title)
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text(card.frequency)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Text(card.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.55, green: 0.40, blue: 0.30).opacity(0.25), lineWidth: 1)
        )
    }
}

private struct FavouriteThumbCard: View {
    let label: String
    let imageUrl: String?
    let gradientSeed: Int
    let onTap: () -> Void

    private static let palettes: [[Color]] = [
        [Color(hue: 0.58, saturation: 0.55, brightness: 0.55), Color(hue: 0.62, saturation: 0.45, brightness: 0.35)],
        [Color(hue: 0.08, saturation: 0.60, brightness: 0.55), Color(hue: 0.04, saturation: 0.55, brightness: 0.35)],
        [Color(hue: 0.38, saturation: 0.50, brightness: 0.48), Color(hue: 0.35, saturation: 0.45, brightness: 0.30)],
        [Color(hue: 0.78, saturation: 0.45, brightness: 0.50), Color(hue: 0.75, saturation: 0.40, brightness: 0.32)],
        [Color(hue: 0.12, saturation: 0.55, brightness: 0.52), Color(hue: 0.09, saturation: 0.50, brightness: 0.34)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 150, height: 170)

                if let url = imageUrl, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 150, height: 170)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.45),
                        .init(color: .black.opacity(0.72), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
            }
            .frame(width: 150, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct CareTipCard: View {
    let tip: CareTip
    let gradientSeed: Int
    let onTap: () -> Void

    private static let categories = ["Scalp Care", "Cleansing", "Styling", "Recovery", "Sleep", "Nutrition"]
    private static let palettes: [[Color]] = [
        [Color(hue: 0.60, saturation: 0.60, brightness: 0.52), Color(hue: 0.65, saturation: 0.50, brightness: 0.30)],
        [Color(hue: 0.06, saturation: 0.65, brightness: 0.55), Color(hue: 0.03, saturation: 0.60, brightness: 0.32)],
        [Color(hue: 0.36, saturation: 0.55, brightness: 0.48), Color(hue: 0.34, saturation: 0.50, brightness: 0.28)],
        [Color(hue: 0.80, saturation: 0.50, brightness: 0.50), Color(hue: 0.77, saturation: 0.45, brightness: 0.30)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    private var category: String { Self.categories[gradientSeed % Self.categories.count] }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                if let url = tip.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.10), location: 0.40),
                        .init(color: .black.opacity(0.78), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .kerning(0.8)
                    Text(tip.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
            .frame(width: 175, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct RemedyCard: View {
    let remedy: HomeRemedy
    let gradientSeed: Int
    let onTap: () -> Void

    private static let categories = ["Home Remedy", "Hair Mask", "Scalp Treat", "Oil Therapy"]
    private static let palettes: [[Color]] = [
        [Color(hue: 0.38, saturation: 0.58, brightness: 0.46), Color(hue: 0.35, saturation: 0.52, brightness: 0.26)],
        [Color(hue: 0.07, saturation: 0.65, brightness: 0.54), Color(hue: 0.04, saturation: 0.58, brightness: 0.32)],
        [Color(hue: 0.72, saturation: 0.48, brightness: 0.50), Color(hue: 0.70, saturation: 0.42, brightness: 0.30)],
        [Color(hue: 0.14, saturation: 0.60, brightness: 0.52), Color(hue: 0.11, saturation: 0.55, brightness: 0.30)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    private var category: String { Self.categories[gradientSeed % Self.categories.count] }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                if let url = remedy.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.12), location: 0.40),
                        .init(color: .black.opacity(0.80), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .kerning(0.8)
                    Text(remedy.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
            .frame(width: 175, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
