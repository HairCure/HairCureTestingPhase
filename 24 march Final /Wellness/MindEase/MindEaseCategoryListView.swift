//
//  MindEaseCategoryListView.swift
//  HairCureTesting1
//
//  Category detail screen — shows:
//  • Collapsing hero header (gradient + decorative icon + tagline)
//    Uses iOS 17 .scrollTransition(.interactive) for the parallax‑collapse feel
//  • List of content items with thumbnail, title, description, chevron
//  • Navigates to MindEasePlayerView when a row is tapped
//

import SwiftUI

struct MindEaseCategoryListView: View {
    let category: MindEaseCategory

    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    @State private var pushContent: MindEaseContentDest? = nil

    private var contents: [MindEaseCategoryContent] {
        mindEaseStore.mindEaseCategoryContents
            .filter { $0.categoryId == category.id }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    // ── Gradient per category ──────────────────────────────────

    private var heroGradient: LinearGradient {
        switch category.title {
        case "Yoga":
            return LinearGradient(
                colors: [Color(red: 0.12, green: 0.14, blue: 0.20),
                         Color(red: 0.30, green: 0.22, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Meditation":
            return LinearGradient(
                colors: [Color(red: 0.18, green: 0.10, blue: 0.34),
                         Color(red: 0.60, green: 0.35, blue: 0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        default: // Relaxing Sounds
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.16, blue: 0.28),
                         Color(red: 0.10, green: 0.28, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Collapsing Hero (iOS 17 .interactive transition) ──
                heroHeader

                // ── Content list ──
                contentList
                    .padding(.top, 8)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea(edges: .top)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $pushContent) { dest in
            if let c = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == dest.id }) {
                MindEasePlayerView(content: c)
            }
        }
    }

    // MARK: - Collapsing Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 1: Gradient fallback
            Rectangle()
                .fill(heroGradient)
                .frame(height: 240)

            // Layer 2: Real banner image — add "yoga_banner" / "meditation_banner" / "sounds_banner"
            //          to your asset catalog and it will appear automatically
            if let uiImage = UIImage(named: category.bannerImageURL) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
            }

            // Layer 3: Dark gradient — always on, keeps text readable over any image
            LinearGradient(
                colors: [.black.opacity(0.10), .black.opacity(0.65)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 240)

            // Layer 4: Decorative icon (only shown if no real image)
            if UIImage(named: category.bannerImageURL) == nil {
                Image(systemName: category.cardIconName)
                    .font(.system(size: 110, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.08))
                    .frame(maxWidth: .infinity, maxHeight: 240, alignment: .topTrailing)
                    .offset(x: -16, y: 20)
                    .allowsHitTesting(false)
            }

            // Layer 5: Tagline
            VStack(alignment: .leading, spacing: 4) {
                Text(category.bannerTagline)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 2)
                Text(category.categoryDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(2)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
        // iOS 17 — interactive scroll transition for the collapsing/parallax feel
        .scrollTransition(.interactive, axis: .vertical) { content, phase in
            content
                // As user scrolls UP (phase.value > 0): hero shrinks from top and fades
                .scaleEffect(
                    y: phase.isIdentity ? 1.0 : max(0.7, 1.0 - max(0, phase.value) * 0.3),
                    anchor: .top
                )
                .opacity(phase.isIdentity ? 1.0 : max(0, 1.0 - max(0, phase.value) * 1.8))
                // Slight parallax: content moves slower than scroll
                .offset(y: phase.isIdentity ? 0 : min(0, phase.value * -30))
        }
    }

    // MARK: - Content List

    private var contentList: some View {
        VStack(spacing: 0) {
            ForEach(Array(contents.enumerated()), id: \.element.id) { idx, content in
                MindEaseContentRow(content: content) {
                    pushContent = MindEaseContentDest(id: content.id)
                }
                .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : 24)
                }

                if idx < contents.count - 1 {
                    Divider().padding(.leading, 100)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Content Row

struct MindEaseContentRow: View {
    let content: MindEaseCategoryContent
    let onTap: () -> Void

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    private var rowGradient: LinearGradient {
        let h = Double(abs(content.title.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }) % 360) / 360.0
        return LinearGradient(
            colors: [Color(hue: h, saturation: 0.5, brightness: 0.65),
                     Color(hue: (h + 0.07).truncatingRemainder(dividingBy: 1), saturation: 0.40, brightness: 0.50)],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Thumbnail — gradient fallback, real image auto-loads from asset catalog
                // Add assets named: "yoga_thumb_1", "meditation_thumb_1", "sound_thumb_1" etc.
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(rowGradient)
                        .frame(width: 78, height: 58)

                    if let uiImage = UIImage(named: content.thumbnailImageURL) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 78, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: content.mediaType == "audio" ? "waveform" : "play.fill")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 78, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(content.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(content.contentDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    NavigationStack {
//        MindEaseCategoryListView(
//            category: MindEaseCategory(
//                id: UUID(), title: "Relaxing Sounds",
//                categoryDescription: "Soothing sounds to help you relax and unwind",
//                bannerImageURL: "sounds_banner", cardImageUrl: "sounds_card",
//                cardIconName: "waveform",
//                bannerTagline: "Sound heals."
//            )
//        )
//        .environment(AppDataStore())
//        .environment(MindEaseDataStore())
//    }
//}
