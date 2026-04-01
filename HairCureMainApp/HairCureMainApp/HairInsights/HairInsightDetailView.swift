import SwiftUI
import AVKit

// MARK: - HomeRemedyDetailView

struct HomeRemedyDetailView: View {
    let remedy: HomeRemedy
    let insightStore: HairInsightsDataStore  // let, not var

    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.0
    @State private var playbackTask: Task<Void, Never>?

    private var isFav: Bool {
        insightStore.isFavorite(contentId: remedy.id)
    }

    private var totalDuration: Double {
        Double(remedy.videoDurationSeconds ?? 120)
    }

    private var currentTimeString: String { formatTime(Int(progress)) }
    private var totalTimeString: String    { formatTime(remedy.videoDurationSeconds ?? 120) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Hero / Video area
                ZStack(alignment: .center) {
                    if let imageName = remedy.mediaURL {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 280)
                            .overlay(
                                Image(systemName: "play.rectangle")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color(.systemGray2))
                            )
                    }

                    Button {
                        togglePlayback()
                    } label: {
                        Circle()
                            .fill(Color.black.opacity(0.65))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Favourite + Scrubber row
                    HStack {
                        Spacer()
                        Button {
                            insightStore.toggleFavorite(contentId: remedy.id)
                        } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFav ? .red : Color(.systemGray2))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                    // Scrubber
                    VStack(spacing: 6) {
                        Slider(value: $progress, in: 0...totalDuration) { editing in
                            if editing {
                                // iOS 18: cancel task directly — no stopTimer() needed
                                playbackTask?.cancel()
                                playbackTask = nil
                            } else if isPlaying {
                                startPlaybackTask()
                            }
                        }
                        .tint(.primary)

                        HStack {
                            Text(currentTimeString)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(totalTimeString)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    // MARK: Title & Body
                    Text("Give your hair a natural boost with \(remedy.title.lowercased().components(separatedBy: " ").first ?? "").")
                        .font(.title3.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    Text(remedy.benefits)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    Divider()
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    Text("How to use")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Text(remedy.instructions)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                    Spacer(minLength: 40)
                }
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(remedy.title)
        .navigationBarTitleDisplayMode(.inline)
        // iOS 18: .task cancels automatically when view disappears — no .onDisappear needed
        .task(id: isPlaying) {
            guard isPlaying else { return }
            await runPlayback()
        }
    }

    // MARK: Playback helpers (structured concurrency)

    private func togglePlayback() {
        if isPlaying {
            isPlaying = false
            playbackTask?.cancel()
            playbackTask = nil
        } else {
            isPlaying = true
            startPlaybackTask()
        }
    }

    private func startPlaybackTask() {
        playbackTask?.cancel()
        playbackTask = Task { await runPlayback() }
    }

    private func runPlayback() async {
        while progress < totalDuration {
            // iOS 18: try? Task.sleep replaces Timer entirely
            try? await Task.sleep(for: .milliseconds(500))
            if Task.isCancelled { return }
            progress = min(progress + 0.5, totalDuration)
        }
        // Reached end
        isPlaying = false
        playbackTask = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d : %02d", seconds / 60, seconds % 60)
    }
}

// MARK: - CareTipDetailView

struct CareTipDetailView: View {
    let tip: CareTip
    let insightStore: HairInsightsDataStore  // let, not var

    private var isFav: Bool {
        insightStore.isFavorite(contentId: tip.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 240)

                    if let imageName = tip.mediaURL {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: "leaf")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {

                    // Fav button
                    HStack {
                        Spacer()
                        Button {
                            insightStore.toggleFavorite(contentId: tip.id)
                        } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFav ? .red : Color(.systemGray2))
                        }
                    }
                    .padding(.top, 12)

                    Text(tip.title)
                        .font(.title3.bold())

                    Text(tip.tipDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(tip.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
