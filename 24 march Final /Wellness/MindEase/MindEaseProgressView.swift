//
//  MindEaseProgressView.swift
//  HairCureTesting1
//
//  Profile → MindEase Progress
//  4-day tappable ring selector — tap a ring or pick a date via calendar icon
//  to view that day's session detail panel.
//

import SwiftUI

// MARK: - MindEaseProgressView

struct MindEaseProgressView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    // 4 days: oldest → newest so Today is on the RIGHT
    private var ringDates: [Date] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<4).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showDatePicker      = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // ── Today summary card ──
                todaySummaryCard
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
                    }

                // ── 4-day tappable ring selector ──
                ringSelectorSection
                    .padding(.horizontal, 20)
                    .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0.2).scaleEffect(p.isIdentity ? 1 : 0.95)
                    }

                // ── Selected day detail ──
                selectedDayDetail
                    .padding(.horizontal, 20)
                    .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 18)
                    }

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("MindEase Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Today summary card

    private var todaySummaryCard: some View {
        let done   = mindEaseStore.mindfulMinutes(for: Date())
        let target = max(1, mindEaseStore.dailyMindfulTarget)
        let prog   = min(Double(done) / Double(target), 1.0)

        let cal        = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let sessions   = mindEaseStore.mindfulSessions.filter {
            $0.userId == store.currentUserId &&
            cal.startOfDay(for: $0.sessionDate) == todayStart
        }
        let catMins: [(name: String, mins: Int, icon: String, color: Color)] = [
            ("Meditation", sessions.filter { rowContent(for: $0.contentId).category == "Meditation" }.reduce(0) { $0 + $1.minutesCompleted }, "brain.head.profile", Color(red: 0.55, green: 0.32, blue: 0.12)),
            ("Yoga",       sessions.filter { rowContent(for: $0.contentId).category == "Yoga" }.reduce(0)       { $0 + $1.minutesCompleted }, "figure.yoga",         Color(red: 0.26, green: 0.20, blue: 0.16)),
            ("Sounds",     sessions.filter { rowContent(for: $0.contentId).category != "Meditation" && rowContent(for: $0.contentId).category != "Yoga" }.reduce(0) { $0 + $1.minutesCompleted }, "waveform", Color(red: 0.08, green: 0.30, blue: 0.30))
        ].filter { $0.mins > 0 }

        return HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(purple.opacity(0.15), lineWidth: 10)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: prog)
                    .stroke(purple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: prog)
                VStack(spacing: 0) {
                    Text("\(done)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(purple)
                    Text("min")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Today's Sessions")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(done)")
                        .font(.system(size: 28, weight: .bold))
                    Text("/ \(target) min")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                if catMins.isEmpty {
                    Text("No sessions logged yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 8) {
                        ForEach(catMins, id: \.name) { item in
                            MindCategoryChip(icon: item.icon, label: "\(item.mins)m", color: item.color)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    // MARK: - 4-day tappable ring selector

    private var ringSelectorSection: some View {
        let cal    = Calendar.current
        let target = Double(max(1, mindEaseStore.dailyMindfulTarget))

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tap a day to view details")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    showDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(purple)
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePickerSheet(selectedDate: $selectedDate,
                                    accentColor: purple,
                                    isPresented: $showDatePicker)
                }
            }

            HStack(spacing: 0) {
                ForEach(ringDates, id: \.self) { date in
                    let isSelected = cal.startOfDay(for: selectedDate) == cal.startOfDay(for: date)
                    let mins       = mindEaseStore.mindfulMinutes(for: date)
                    let prog       = min(Double(mins) / target, 1.0)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDate = cal.startOfDay(for: date)
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(
                                        isSelected ? purple.opacity(0.25) : Color.gray.opacity(0.15),
                                        lineWidth: isSelected ? 7 : 5
                                    )
                                    .frame(width: 58, height: 58)
                                if prog > 0 {
                                    Circle()
                                        .trim(from: 0, to: prog)
                                        .stroke(purple,
                                                style: StrokeStyle(lineWidth: isSelected ? 7 : 5,
                                                                   lineCap: .round))
                                        .frame(width: 58, height: 58)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 0.4), value: prog)
                                }
                                if mins > 0 {
                                    VStack(spacing: 0) {
                                        Text("\(mins)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(isSelected ? purple : .primary)
                                        Text("min")
                                            .font(.system(size: 9))
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .scaleEffect(isSelected ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)

                            Text(shortDayLabel(date))
                                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? purple : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
    }

    // MARK: - Selected day detail panel

    private var selectedDayDetail: some View {
        let cal    = Calendar.current
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let sessions = mindEaseStore.mindfulSessions.filter {
            $0.userId == store.currentUserId &&
            Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
        }.sorted { $0.startTime < $1.startTime }

        let totalMins = sessions.reduce(0) { $0 + $1.minutesCompleted }
        let target    = max(1, mindEaseStore.dailyMindfulTarget)
        let progress  = min(Double(totalMins) / Double(target), 1.0)

        let titleLabel: String = {
            if cal.isDateInToday(selectedDate)     { return "Today" }
            if cal.isDateInYesterday(selectedDate) { return "Yesterday" }
            let f = DateFormatter(); f.dateFormat = "EEE, d MMM"
            return f.string(from: selectedDate)
        }()

        return VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleLabel)
                        .font(.system(size: 18, weight: .bold))
                    if totalMins > 0 {
                        Text("\(totalMins) min · \(Int(progress * 100))% of goal · \(sessions.count) session\(sessions.count == 1 ? "" : "s")")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Rest day — no sessions")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(purple.opacity(0.15), lineWidth: 4)
                        .frame(width: 40, height: 40)
                    if progress > 0 {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: progress)
                    }
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 11))
                        .foregroundColor(purple)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, sessions.isEmpty ? 16 : 10)

            if !sessions.isEmpty {
                Divider().padding(.horizontal, 18)

                VStack(spacing: 0) {
                    ForEach(sessions) { session in
                        SessionDetailRow(session: session, purple: purple)
                        if session.id != sessions.last?.id {
                            Divider().padding(.leading, 74)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedDate)
    }

    // MARK: - Category helpers

    private func rowContent(for contentId: UUID) -> (title: String, category: String) {
        guard let c = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == contentId }),
              let cat = mindEaseStore.mindEaseCategories.first(where: { $0.id == c.categoryId })
        else { return ("Mindful Session", "Relaxation") }
        return (c.title, cat.title)
    }

    private func rowIcon(for contentId: UUID) -> String {
        guard let c = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == contentId }),
              let cat = mindEaseStore.mindEaseCategories.first(where: { $0.id == c.categoryId })
        else { return "figure.mind.and.body" } // Default icon if not found
        switch cat.title {
        case "Yoga":       return "figure.yoga"
        case "Meditation": return "brain.head.profile"
        default:           return "waveform"
        }
    }

    private func shortDayLabel(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: date)
    }
}

// MARK: - Session detail row

private struct SessionDetailRow: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let session: MindfulSession
    let purple: Color

    private var contentInfo: (title: String, icon: String, catName: String) {
        guard let c   = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId }),
              let cat = mindEaseStore.mindEaseCategories.first(where: { $0.id == c.categoryId })
        else { return ("Session", "figure.mind.and.body", "MindEase") }
        let icon: String
        switch cat.title {
        case "Yoga":       icon = "figure.yoga"
        case "Meditation": icon = "brain.head.profile"
        default:           icon = "waveform"
        }
        return (c.title, icon, cat.title)
    }

    private var timeLabel: String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return f.string(from: session.startTime)
    }

    var body: some View {
        let info = contentInfo
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(purple.opacity(0.10))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: info.icon)
                        .font(.system(size: 18))
                        .foregroundColor(purple)
                )
                .padding(.leading, 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(info.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(info.catName) · \(timeLabel)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(session.minutesCompleted) min")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(purple)
                .padding(.trailing, 18)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Category chip

private struct MindCategoryChip: View {
    let icon: String; let label: String; let color: Color
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 10, weight: .medium)).foregroundColor(.secondary)
        }
        .padding(.horizontal, 7).padding(.vertical, 4)
        .background(color.opacity(0.12)).clipShape(Capsule())
    }
}

// MARK: - Preview
//
//#Preview {
//    NavigationStack { MindEaseProgressView() }
//    .environment(AppDataStore())
//    .environment(MindEaseDataStore())
//}
