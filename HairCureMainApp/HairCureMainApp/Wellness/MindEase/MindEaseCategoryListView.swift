//
//  MindEaseCategoryListView.swift
//
//  Category detail screen:
//  • Collapsing hero header — gradient + tagline (no separate banner image)
//  • List of content items — uses content.listImageURL for the wide row thumbnail
//  • Tapping a row navigates to MindEasePlayerView
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

    // ── Hero gradient per category ────────────────────────────────────────────

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
                heroHeader
                contentList.padding(.top, 8)
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
    //  The category card image (cardImageUrl) doubles as the hero background.
    //  No separate bannerImageURL is needed.

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 1: gradient fallback
            Rectangle()
                .fill(heroGradient)
                .frame(height: 240)

            // Layer 2: card image used as hero (same asset as the home card)
            if let uiImage = UIImage(named: category.cardImageUrl) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
            }

            // Layer 3: dark gradient — keeps text readable
            LinearGradient(
                colors: [.black.opacity(0.10), .black.opacity(0.65)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 240)

            // Layer 4: decorative SF Symbol (only when no real image)
            if UIImage(named: category.cardImageUrl) == nil {
                Image(systemName: category.cardIconName)
                    .font(.system(size: 110, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.08))
                    .frame(maxWidth: .infinity, maxHeight: 240, alignment: .topTrailing)
                    .offset(x: -16, y: 20)
                    .allowsHitTesting(false)
            }

            // Layer 5: tagline text  ← was category.bannerTagline, now category.tagline
            VStack(alignment: .leading, spacing: 4) {
                Text(category.tagline)
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
        .scrollTransition(.interactive, axis: .vertical) { content, phase in
            content
                .scaleEffect(
                    y: phase.isIdentity ? 1.0 : max(0.7, 1.0 - max(0, phase.value) * 0.3),
                    anchor: .top
                )
                .opacity(phase.isIdentity ? 1.0 : max(0, 1.0 - max(0, phase.value) * 1.8))
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
//  Uses content.listImageURL for the wide rectangular thumbnail in the list.

struct MindEaseContentRow: View {
    let content: MindEaseCategoryContent
    let onTap: () -> Void

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    private var rowGradient: LinearGradient {
        let h = Double(abs(content.title.unicodeScalars.reduce(0) {
            ($0 &* 31) &+ Int($1.value)
        }) % 360) / 360.0
        return LinearGradient(
            colors: [Color(hue: h, saturation: 0.5, brightness: 0.65),
                     Color(hue: (h + 0.07).truncatingRemainder(dividingBy: 1),
                           saturation: 0.40, brightness: 0.50)],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                // Thumbnail — uses listImageURL (wide row image)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(rowGradient)
                        .frame(width: 78, height: 58)

                    if let uiImage = UIImage(named: content.imageurl) {
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
                    // caption shown as the subtitle (e.g. "Forward Fold")
                    Text(content.caption)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    // duration badge
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("\(content.durationMinutes > 0 ? "\(content.durationMinutes)" : "<1") min")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
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
