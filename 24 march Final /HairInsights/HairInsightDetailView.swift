//
//  HairInsightDetailView.swift
//  HairCure
//
//  Detail / player screen for a Hair Insight item.
//  Now reads from HairInsightsDataStore instead of AppDataStore.
//  Favourite toggle calls store.setFavourited(_:contentType:contentId:).
//

import SwiftUI
internal import Combine

struct HairInsightDetailView: View {
    let itemId: UUID
    let type:   String      // "homeRemedy" | "careTip" | "hairInsight"

    // ← Changed from AppDataStore to HairInsightsDataStore
    @Environment(HairInsightsDataStore.self) private var store

    // Player state
    @State private var isPlaying:   Bool   = false
    @State private var progress:    Double = 0.05
    @State private var isFavorited: Bool   = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Resolved item data

    private struct ItemData {
        let title: String
        let headline: String
        let body: String
        let imageUrl: String?
        let durationSeconds: Int
    }

    private var item: ItemData? {
        switch type {
        case "homeRemedy":
            if let r = store.homeRemedies.first(where: { $0.id == itemId }) {
                return ItemData(
                    title:           r.title,
                    headline:        "Give your hair a natural boost with \(r.title.lowercased()).",
                    body:            r.instructions,
                    imageUrl:        r.mediaURL,
                    durationSeconds: 120
                )
            }
        case "careTip":
            if let t = store.careTips.first(where: { $0.id == itemId }) {
                return ItemData(
                    title:           t.title,
                    headline:        t.title,
                    body:            t.tipDescription + "\n\n" + t.benefits,
                    imageUrl:        t.mediaURL,
                    durationSeconds: 90
                )
            }
        case "hairInsight":
            if let h = store.hairInsights.first(where: { $0.id == itemId }) {
                return ItemData(
                    title:           h.title,
                    headline:        h.title,
                    body:            h.insightDescription,
                    imageUrl:        h.mediaURL,
                    durationSeconds: 60
                )
            }
        default: break
        }
        return nil
    }

    // MARK: - Hero gradient (deterministic per itemId)

    private var heroGradient: LinearGradient {
        let hash = itemId.uuidString.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        let h    = Double(abs(hash) % 360) / 360.0
        return LinearGradient(
            colors: [
                Color(hue: h, saturation: 0.50, brightness: 0.68),
                Color(hue: (h + 0.12).truncatingRemainder(dividingBy: 1),
                      saturation: 0.42, brightness: 0.50)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private func fmt(_ secs: Int) -> String {
        String(format: "%02d : %02d", secs / 60, secs % 60)
    }

    private var elapsedSec: Int {
        Int(progress * Double(item?.durationSeconds ?? 120))
    }
    private var remainSec: Int {
        max(0, (item?.durationSeconds ?? 120) - elapsedSec)
    }

    var body: some View {
        if let data = item {
            GeometryReader { geo in
                VStack(spacing: 0) {

                    // ── Hero ────────────────────────────────────────
                    ZStack {
                        Rectangle().fill(heroGradient)

                        if let url = data.imageUrl, let img = UIImage(named: url) {
                            Image(uiImage: img)
                                .resizable().scaledToFill()
                        }

                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                isPlaying.toggle()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.black.opacity(0.55))
                                    .frame(width: 64, height: 64)
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height * 0.40)
                    .clipped()

                    // ── Scrollable content ──────────────────────────
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {

                            // Favourite + Scrubber row
                            VStack(spacing: 8) {
                                HStack {
                                    Spacer()
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            isFavorited.toggle()
                                        }
                                        // ← Delegate to HairInsightsDataStore helper
                                        store.setFavourited(isFavorited,
                                                            contentType: type,
                                                            contentId: itemId)
                                    } label: {
                                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                                            .font(.system(size: 24))
                                            .foregroundColor(isFavorited ? .red : .secondary)
                                            .symbolEffect(.bounce, value: isFavorited)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 18)

                                // Scrubber
                                VStack(spacing: 4) {
                                    Slider(value: $progress, in: 0...1)
                                        .tint(.primary)
                                        .padding(.horizontal, 24)
                                    HStack {
                                        Text(fmt(elapsedSec))
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(fmt(remainSec))
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }

                            // Headline
                            Text(data.headline)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 24)
                                .padding(.top, 18)

                            // Body
                            Text(data.body)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)
                                .padding(.top, 10)

                            Spacer(minLength: 40)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle(data.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // ← Uses store.isFavourited(_:) instead of manual array lookup
                isFavorited = store.isFavourited(contentId: itemId)
            }
            .onReceive(ticker) { _ in
                guard isPlaying else { return }
                let step = 1.0 / Double(max(1, item?.durationSeconds ?? 120))
                progress = min(1.0, progress + step)
                if progress >= 1.0 { isPlaying = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HairInsightDetailView(itemId: UUID(), type: "homeRemedy")
            .environment(HairInsightsDataStore(currentUserId: UUID()))
    }
}
