//
//  MindEasePlayerView.swift
//
//  Content player screen:
//  • Full-width hero — uses content.imageurl (gradient fallback)
//  • Title + timer
//  • Progress scrubber with elapsed / remaining time
//  • Playback controls: shuffle · skip-back · play/pause · skip-forward
//  All interactions are local mock state (no actual audio engine).
//

import SwiftUI
internal import Combine

struct MindEasePlayerView: View {
    let content: MindEaseCategoryContent

    @Environment(MindEaseDataStore.self) private var mindEaseStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPlaying:   Bool   = false
    @State private var progress:    Double = 0.05
    @State private var isFavorited: Bool   = false
    @State private var isShuffled:  Bool   = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var heroGradient: LinearGradient {
        let hash = content.title.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        let h    = Double(abs(hash) % 360) / 360.0
        return LinearGradient(
            colors: [
                Color(hue: h, saturation: 0.65, brightness: 0.72),
                Color(hue: (h + 0.14).truncatingRemainder(dividingBy: 1),
                      saturation: 0.50, brightness: 0.48),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var elapsed:   Int { Int(progress * Double(content.durationSeconds)) }
    private var remaining: Int { max(0, content.durationSeconds - elapsed) }

    private func fmt(_ secs: Int) -> String {
        String(format: "%02d : %02d", secs / 60, secs % 60)
    }
    
    private func saveProgress() {
        let mins = Int(progress * Double(content.durationSeconds)) / 60
        // Only log if at least one minute has passed to avoid spamming the store
        if mins > 0 {
            mindEaseStore.logMindfulSession(contentId: content.id, minutesCompleted: mins)
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // ── Hero Section ─────────────────────────────────────────────
                ZStack {
                    Rectangle().fill(heroGradient)

                    if let uiImage = UIImage(named: content.imageurl) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill() // Changed from .fit to .fill to cover the area
                            .frame(width: geo.size.width, height: geo.size.height * 0.42) // Match the container size
                            .clipped() // Prevents the image from bleeding out of the frame
                    }

                    if UIImage(named: content.imageurl) == nil {
                        Image(systemName: content.mediaType == "audio" ? "waveform" : "play.circle")
                            .font(.system(size: 90, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.18))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height * 0.42)
                .clipped()

                // ── Player panel ─────────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {

                        // Title + Timer + Favourite
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(content.title)
                                    .font(.system(size: 22, weight: .bold))
                                Text(content.caption)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isFavorited.toggle()
                                }
                            } label: {
                                Image(systemName: isFavorited ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(isFavorited ? .red : .primary.opacity(0.7))
                                    .symbolEffect(.bounce, value: isFavorited)
                            }
                            
                            Button { } label: {
                                Image(systemName: "timer")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary.opacity(0.7))
                            }
                        }

                        // Scrubber
                        VStack(spacing: 6) {
                            Slider(value: $progress, in: 0...1).tint(.primary)
                            HStack {
                                Text(fmt(elapsed))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(fmt(remaining))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Controls
                        HStack(spacing: 0) {
                            Button {
                                withAnimation { isShuffled.toggle() }
                            } label: {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 22))
                                    .foregroundColor(isShuffled
                                        ? Color(red: 0.40, green: 0.30, blue: 0.85)
                                        : .primary.opacity(0.65))
                            }
                            .frame(maxWidth: .infinity)

                            Button { progress = max(0, progress - 0.05) } label: {
                                Image(systemName: "backward.end.fill")
                                    .font(.system(size: 24)).foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)

                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                    isPlaying.toggle()
                                }
                            } label: {
                                ZStack {
                                    Circle().fill(Color.primary).frame(width: 66, height: 66)
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .contentTransition(.symbolEffect(.replace))
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Button { progress = min(1, progress + 0.05) } label: {
                                Image(systemName: "forward.end.fill")
                                    .font(.system(size: 24)).foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)

                            Button { } label: {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary.opacity(0.65))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(Color(UIColor.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(content.title)
        .onReceive(ticker) { _ in
            guard isPlaying else { return }
            let step = 1.0 / Double(max(1, content.durationSeconds))
            progress = min(1.0, progress + step)
            if progress >= 1.0 {
                isPlaying = false
                saveProgress()
            }
        }
        .onDisappear {
            saveProgress()
        }
    }
}

//#Preview {
//    NavigationStack {
//        MindEasePlayerView(content: MindEaseCategoryContent(
//            id: UUID(), categoryId: UUID(),
//            title: "Ocean Waves",
//            contentDescription: "Rhythmic ocean waves — calms the nervous system",
//            caption: "Soft ocean rhythms for deep calm",
//            mediaURL: "ocean.mp3", mediaType: "audio",
//            durationSeconds: 1800, difficultyLevel: "beginner",
//            imageurl: "ardh",
//            orderIndex: 1, lastPlaybackSeconds: 0
//        ))
//        
//    }
//}
