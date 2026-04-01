//
//  MindEaseDetailView.swift
//

import SwiftUI

struct MindEaseDayDetailView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let date: Date

    private var navTitle: String { date.mindEaseFormatted("EEE, d MMM") }

    private var sessions: [MindfulSession] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindEaseStore.mindfulSessions
            .filter {
                $0.userId == store.currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .sorted { $0.startTime < $1.startTime }
    }

    private var totalMinutes:  Int    { sessions.reduce(0) { $0 + $1.minutesCompleted } }
    private var targetMinutes: Int    { mindEaseStore.dailyMindfulTarget }
    private var completionFraction: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(totalMinutes) / Double(targetMinutes), 1.0)
    }

    private var categoryBreakdown: [(title: String, icon: String, minutes: Int)] {
        var buckets: [UUID: Int] = [:]
        for session in sessions {
            if let content = mindEaseStore.mindEaseCategoryContents
                .first(where: { $0.id == session.contentId }) {
                buckets[content.categoryId, default: 0] += session.minutesCompleted
            }
        }
        return mindEaseStore.mindEaseCategories.compactMap { cat in
            guard let mins = buckets[cat.id], mins > 0 else { return nil }
            return (title: cat.title, icon: cat.cardIconName, minutes: mins)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                DayDetailSummaryCard(
                    totalMinutes: totalMinutes,
                    targetMinutes: targetMinutes,
                    completionFraction: completionFraction
                )
                .padding(.horizontal, 20)
                .padding(.top, 4)

                if !categoryBreakdown.isEmpty {
                    DayDetailBreakdownSection(breakdown: categoryBreakdown)
                }

                DayDetailSessionListSection(sessions: sessions)

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .mindEasePageBackground()
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Summary Card
//
// The straight linear progress bar has been removed.
// The ring + percentage text communicate completion without duplication.

struct DayDetailSummaryCard: View {
    let totalMinutes: Int
    let targetMinutes: Int
    let completionFraction: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                ZStack {
                    MindEaseProgressRing(
                        progress: completionFraction,
                        lineWidth: 10,
                        diameter: 72
                    )
                    VStack(spacing: 1) {
                        Text("\(Int(completionFraction * 100))%")
                            .font(.system(size: 15, weight: .bold))
                        Text("done")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Mindful Minutes")
                        .font(.system(size: 13)).foregroundColor(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("\(totalMinutes)")
                            .mindEaseStatValue(size: 30)
                        Text("/ \(targetMinutes) min")
                            .font(.system(size: 14)).foregroundColor(.secondary)
                    }
                    DayDetailGoalBadge(
                        totalMinutes: totalMinutes,
                        targetMinutes: targetMinutes,
                        completionFraction: completionFraction
                    )
                }
                Spacer()
            }
        }
        .padding(18)
        .mindEaseCard()
    }
}

// MARK: - Goal Badge

struct DayDetailGoalBadge: View {
    let totalMinutes: Int
    let targetMinutes: Int
    let completionFraction: Double

    var body: some View {
        if totalMinutes == 0 {
            Label("No sessions logged", systemImage: "moon.zzz.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        } else if completionFraction >= 1.0 {
            Label("Goal reached", systemImage: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.mindEasePurple)
        } else {
            Label("\(targetMinutes - totalMinutes) min short", systemImage: "minus.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Breakdown Section

struct DayDetailBreakdownSection: View {
    let breakdown: [(title: String, icon: String, minutes: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .mindEaseSectionHeader()

            HStack(spacing: 12) {
                ForEach(breakdown, id: \.title) { item in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.mindEasePurple.opacity(0.10))
                                .frame(width: 52, height: 52)
                            Image(systemName: item.icon)
                                .font(.system(size: 22))
                                .foregroundColor(.mindEasePurple)
                        }
                        Text("\(item.minutes) min")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.mindEasePurple)
                        Text(item.title)
                            .font(.system(size: 11)).foregroundColor(.secondary)
                            .multilineTextAlignment(.center).lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .mindEaseCard(cornerRadius: 14, shadowRadius: 4, shadowY: 2)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Session List Section

struct DayDetailSessionListSection: View {
    let sessions: [MindfulSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sessions.isEmpty ? "Sessions" : "Sessions (\(sessions.count))")
                .mindEaseSectionHeader()

            if sessions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary.opacity(0.35))
                    Text("No sessions logged for this day")
                        .font(.system(size: 15)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 48)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { idx, session in
                        DayDetailSessionRow(session: session)
                            .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                                c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
                            }
                        if idx < sessions.count - 1 {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .mindEaseCard(cornerRadius: 16, shadowRadius: 8, shadowY: 3)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Session Row

struct DayDetailSessionRow: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let session: MindfulSession

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f
    }()

    private var timeLabel: String {
        "\(Self.timeFmt.string(from: session.startTime)) – \(Self.timeFmt.string(from: session.endTime))"
    }

    var body: some View {
        HStack(spacing: 14) {
            MindEaseSessionIconView(
                iconName: mindEaseStore.sessionIcon(for: session),
                size: 52,
                cornerRadius: 10
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(mindEaseStore.contentTitle(for: session))
                    .font(.system(size: 15, weight: .semibold)).lineLimit(1)
                Text(timeLabel)
                    .font(.system(size: 12)).foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(session.minutesCompleted)")
                    .mindEaseStatValue(size: 18)
                Text("min").font(.system(size: 11)).foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Previews

#Preview("Day Detail — with sessions") {
    NavigationStack {
        MindEaseDayDetailView(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Day Detail — empty") {
    NavigationStack {
        MindEaseDayDetailView(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!)
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Summary Card") {
    DayDetailSummaryCard(totalMinutes: 22, targetMinutes: 30, completionFraction: 0.73)
        .padding()
        .mindEasePageBackground()
}
