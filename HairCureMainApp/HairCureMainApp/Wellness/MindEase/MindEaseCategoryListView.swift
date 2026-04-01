//
//  MindEaseCategoryListView.swift


import SwiftUI

struct MindEaseCategoryListView: View {
    let category: MindEaseCategory

    @Environment(MindEaseDataStore.self) private var mindEaseStore

    private var contents: [MindEaseCategoryContent] {
        mindEaseStore.mindEaseCategoryContents
            .filter { $0.categoryId == category.id }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                MindEaseCategoryHero(category: category)
                MindEaseContentList(contents: contents)
                    .padding(.top, 8)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea(edges: .top)
        .mindEasePageBackground()
        .navigationDestination(for: MindEaseCategoryContent.self) { content in
            MindEasePlayerView(content: content)
        }
    }
}

// MARK: - Hero Header

struct MindEaseCategoryHero: View {
    let category: MindEaseCategory

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
        default:
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.16, blue: 0.28),
                         Color(red: 0.10, green: 0.28, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(heroGradient)
                .frame(height: 240)

            if let uiImage = UIImage(named: category.cardImageUrl) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
            }

            LinearGradient(
                colors: [.black.opacity(0.10), .black.opacity(0.65)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 240)

            if UIImage(named: category.cardImageUrl) == nil {
                Image(systemName: category.cardIconName)
                    .font(.system(size: 110, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.08))
                    .frame(maxWidth: .infinity, maxHeight: 240, alignment: .topTrailing)
                    .offset(x: -16, y: 20)
                    .allowsHitTesting(false)
            }

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
}

// MARK: - Content List

struct MindEaseContentList: View {
    let contents: [MindEaseCategoryContent]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(contents.enumerated()), id: \.element.id) { idx, content in
                NavigationLink(value: content) {
                    MindEaseContentRow(content: content)
                }
                .buttonStyle(.plain)
                .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : 24)
                }

                if idx < contents.count - 1 {
                    Divider().padding(.leading, 100)
                }
            }
        }
        .mindEaseCard(cornerRadius: 0, shadowRadius: 0, shadowY: 0)
    }
}

// MARK: - Content Row

struct MindEaseContentRow: View {
    let content: MindEaseCategoryContent

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: content.rowGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 78, height: 58)

                if let uiImage = UIImage(named: content.imageurl) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 78, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: content.mediaIcon)
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
                Text(content.caption)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
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
}

// MARK: - Previews

#Preview("Category List — Yoga") {
    let store = MindEaseDataStore(currentUserId: UUID())
    return NavigationStack {
        MindEaseCategoryListView(category: store.mindEaseCategories[0])
            .environment(store)
    }
}

#Preview("Content Row") {
    let content = MindEaseCategoryContent(
        id: UUID(), categoryId: UUID(),
        title: "Bhramari", contentDescription: "Humming bee breath",
        caption: "Humming Bee Breath",
        mediaURL: "meditation_1.mp4", mediaType: "audio",
        durationSeconds: 600, difficultyLevel: "beginner",
        imageurl: "", lastPlaybackSeconds: 0
    )
    return MindEaseContentRow(content: content)
        .padding()
        .mindEasePageBackground()
}
