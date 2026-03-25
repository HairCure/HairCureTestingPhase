//
//  HairInsightsListView.swift
//  HairCureTesting1
//
//  List view for a Hair Insights section.
//  Matches screenshot: nav bar title, rows with gradient thumbnail,
//  title, description, chevron. Tapping a row pushes HairInsightDetailView.
//  iOS 17: scrollTransition on each row, scrollBounceBehavior.
//
//
//  HairInsightsListView.swift
//  HairCure
//
//  List view for a Hair Insights section.
//  Now reads from HairInsightsDataStore instead of AppDataStore.
//

import SwiftUI

struct HairInsightsListView: View {
    let section: HairInsightSectionDest.Section

    // ← Changed from AppDataStore to HairInsightsDataStore
    @Environment(HairInsightsDataStore.self) private var store
    @State private var detailDest: HairInsightItemDest? = nil

    private var navTitle: String {
        switch section {
        case .careTips:     return "Care Tips"
        case .homeRemedies: return "Home Remedies"
        case .favourites:   return "Your Favourites"
        case .insights:     return "Hair Insights"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                    InsightListRow(
                        title:        row.title,
                        subtitle:     row.subtitle,
                        imageUrl:     row.imageUrl,
                        gradientSeed: idx
                    ) {
                        detailDest = HairInsightItemDest(id: row.id, type: row.type)
                    }
                    .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : 24)
                    }

                    if idx < rows.count - 1 {
                        Divider().padding(.leading, 106)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .padding(.top, 4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $detailDest) { dest in
            HairInsightDetailView(itemId: dest.id, type: dest.type)
        }
    }

    // MARK: - Row data

    private struct RowData {
        let id: UUID; let title: String; let subtitle: String
        let imageUrl: String?; let type: String
    }

    private var rows: [RowData] {
        switch section {
        case .careTips:
            // Uses store.sortedCareTips (convenience on HairInsightsDataStore)
            return store.sortedCareTips.map {
                RowData(id: $0.id, title: $0.title, subtitle: $0.tipDescription,
                        imageUrl: $0.mediaURL, type: "careTip")
            }
        case .homeRemedies:
            return store.homeRemedies.map {
                RowData(id: $0.id, title: $0.title, subtitle: $0.remedyDescription,
                        imageUrl: $0.mediaURL, type: "homeRemedy")
            }
        case .favourites:
            // Resolve each favourite to its underlying content item
            return store.currentUserFavorites.compactMap { fav -> RowData? in
                switch fav.contentType {
                case "homeRemedy":
                    if let r = store.homeRemedies.first(where: { $0.id == fav.contentId }) {
                        return RowData(id: r.id, title: r.title, subtitle: r.remedyDescription,
                                       imageUrl: r.mediaURL, type: "homeRemedy")
                    }
                case "careTip":
                    if let t = store.careTips.first(where: { $0.id == fav.contentId }) {
                        return RowData(id: t.id, title: t.title, subtitle: t.tipDescription,
                                       imageUrl: t.mediaURL, type: "careTip")
                    }
                case "hairInsight":
                    if let h = store.hairInsights.first(where: { $0.id == fav.contentId }) {
                        return RowData(id: h.id, title: h.title, subtitle: h.insightDescription,
                                       imageUrl: h.mediaURL, type: "hairInsight")
                    }
                default: break
                }
                return nil
            }
        case .insights:
            return store.hairInsights.map {
                RowData(id: $0.id, title: $0.title, subtitle: $0.insightDescription,
                        imageUrl: $0.mediaURL, type: "hairInsight")
            }
        }
    }
}

// MARK: - List Row  (unchanged)

struct InsightListRow: View {
    let title:        String
    let subtitle:     String
    let imageUrl:     String?
    let gradientSeed: Int
    let onTap:        () -> Void

    private static let palettes: [[Color]] = [
        [Color(red:0.22,green:0.45,blue:0.32), Color(red:0.12,green:0.30,blue:0.20)],
        [Color(red:0.58,green:0.32,blue:0.22), Color(red:0.38,green:0.18,blue:0.10)],
        [Color(red:0.28,green:0.42,blue:0.60), Color(red:0.14,green:0.26,blue:0.46)],
        [Color(red:0.50,green:0.38,blue:0.22), Color(red:0.32,green:0.22,blue:0.10)],
        [Color(red:0.38,green:0.28,blue:0.55), Color(red:0.22,green:0.14,blue:0.40)],
        [Color(red:0.55,green:0.45,blue:0.22), Color(red:0.35,green:0.28,blue:0.10)]
    ]

    private var gradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gradient)
                        .frame(width: 80, height: 60)

                    if let url = imageUrl, let img = UIImage(named: url) {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(width: 80, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .frame(width: 80, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HairInsightsListView(section: .homeRemedies)
            .environment(HairInsightsDataStore(currentUserId: UUID()))
    }
}
