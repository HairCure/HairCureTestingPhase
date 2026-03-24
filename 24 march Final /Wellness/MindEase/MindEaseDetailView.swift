//
//  MindEaseDayDetailView.swift
//  HairCureTesting1
//
//  Read-only past-day mindful session summary.
//  Pushed from MindEaseView when:
//    (a) the user taps a past-day ring in the week calendar, or
//    (b) the user picks a date in the calendar sheet and taps "View Day".
//

import SwiftUI

struct MindEaseDayDetailView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let date: Date

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    // Nav title e.g. "Mon, 17 Mar"
    private var navTitle: String {
        let f = DateFormatter(); f.dateFormat = "EEE, d MMM"; return f.string(from: date)
    }

    // All mindful sessions logged on this date
    private var sessions: [MindfulSession] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindEaseStore.mindfulSessions
            .filter {
                $0.userId == store.currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .sorted { $0.startTime < $1.startTime }
    }

    // Total minutes logged this day
    private var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.minutesCompleted }
    }

    // Target from the active plan
    private var targetMinutes: Int { mindEaseStore.dailyMindfulTarget }

    private var completionFraction: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(totalMinutes) / Double(targetMinutes), 1.0)
    }

    // Category breakdown: sum minutes per category title
    private var categoryBreakdown: [(title: String, icon: String, minutes: Int)] {
        var buckets: [UUID: Int] = [:]
        for session in sessions {
            if let content = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId }) {
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

                // ── Summary card ──
                summaryCard
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                // ── Category breakdown ──
                if !categoryBreakdown.isEmpty {
                    breakdownSection
                }

                // ── Session list ──
                sessionListSection

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 16) {

            HStack(spacing: 20) {
                // Donut ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.18), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: completionFraction)
                        .stroke(
                            purple,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: completionFraction)

                    VStack(spacing: 1) {
                        Text("\(Int(completionFraction * 100))%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Text("done")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Mindful Minutes")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("\(totalMinutes)")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(purple)
                        Text("/ \(targetMinutes) min")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    goalBadge
                }

                Spacer()
            }

            // Thin progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(purple)
                        .frame(width: geo.size.width * CGFloat(completionFraction), height: 6)
                        .animation(.easeOut(duration: 0.45), value: completionFraction)
                }
            }
            .frame(height: 6)
        }
        .padding(18)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var goalBadge: some View {
        if totalMinutes == 0 {
            Label("No sessions logged", systemImage: "moon.zzz.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        } else if completionFraction >= 1.0 {
            Label("Goal reached", systemImage: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(purple)
        } else {
            Label("\(targetMinutes - totalMinutes) min short", systemImage: "minus.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Category Breakdown

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                ForEach(categoryBreakdown, id: \.title) { item in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(purple.opacity(0.10))
                                .frame(width: 52, height: 52)
                            Image(systemName: item.icon)
                                .font(.system(size: 22))
                                .foregroundColor(purple)
                        }
                        Text("\(item.minutes) min")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(purple)
                        Text(item.title)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Session List

    private var sessionListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sessions.isEmpty ? "Sessions" : "Sessions (\(sessions.count))")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 20)

            if sessions.isEmpty {
                // Empty state
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary.opacity(0.35))
                    Text("No sessions logged for this day")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { idx, session in
                        SessionRow(session: session, purple: purple)
                            .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                                c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
                            }
                        if idx < sessions.count - 1 {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Session Row

private struct SessionRow: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let session: MindfulSession
    let purple: Color

    // Look up the content title and category icon from the store
    private var contentTitle: String {
        mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId })?.title ?? "Session"
    }

    private var categoryIcon: String {
        guard
            let content  = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId }),
            let category = mindEaseStore.mindEaseCategories.first(where: { $0.id == content.categoryId })
        else { return "brain.head.profile" }
        return category.cardIconName
    }

    private var mediaType: String {
        mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId })?.mediaType ?? "video"
    }

    private var timeLabel: String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return "\(f.string(from: session.startTime)) – \(f.string(from: session.endTime))"
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon tile
            RoundedRectangle(cornerRadius: 10)
                .fill(purple.opacity(0.10))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: mediaType == "audio" ? "waveform" : categoryIcon)
                        .font(.system(size: 22))
                        .foregroundColor(purple)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(contentTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text(timeLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Duration badge
            VStack(spacing: 2) {
                Text("\(session.minutesCompleted)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(purple)
                Text("min")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
//
//#Preview {
//    NavigationStack {
//        MindEaseDayDetailView(
//            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
//        )
//        .environment(AppDataStore())
//        .environment(MindEaseDataStore())
//    }
//}
