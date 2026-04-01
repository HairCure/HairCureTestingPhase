//
//  MindEaseProgressView.swift
//
import SwiftUI

// MARK: - MindEaseProgressView

struct MindEaseProgressView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    private var ringDates: [Date] {
        let calendar = Calendar.current
        let today    = calendar.startOfDay(for: Date())
        return (0..<4).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    @State private var selectedDate   = Calendar.current.startOfDay(for: Date())
    @State private var showDatePicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                ProgressTodaySummaryCard(userId: store.currentUserId)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
                    }

                ProgressRingSelectorSection(
                    ringDates: ringDates,
                    selectedDate: $selectedDate,
                    showDatePicker: $showDatePicker
                )
                .padding(.horizontal, 20)
                .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0.2).scaleEffect(p.isIdentity ? 1 : 0.95)
                }

                ProgressSelectedDayDetail(
                    selectedDate: selectedDate,
                    userId: store.currentUserId
                )
                .padding(.horizontal, 20)
                .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 18)
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        // ← hcCream from HairCure via the shared ViewModifier
        .mindEasePageBackground()
        .navigationTitle("MindEase Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Today Summary Card

struct ProgressTodaySummaryCard: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let userId: UUID

    private var done:     Int    { mindEaseStore.mindfulMinutes(for: Date()) }
    private var target:   Int    { max(1, mindEaseStore.dailyMindfulTarget) }
    private var progress: Double { min(Double(done) / Double(target), 1.0) }

    private var todaySessions: [MindfulSession] {
        mindEaseStore.sessions(for: Date()).filter { $0.userId == userId }
    }

    private func categoryMinutes(for categoryTitle: String) -> Int {
        todaySessions.filter { session in
            guard
                let content = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == session.contentId }),
                let cat     = mindEaseStore.mindEaseCategories.first(where: { $0.id == content.categoryId })
            else { return false }
            return cat.title == categoryTitle
        }
        .reduce(0) { $0 + $1.minutesCompleted }
    }

    private var categoryChips: [(name: String, mins: Int, icon: String, color: Color)] {
        [
            ("Meditation", categoryMinutes(for: "Meditation"), "brain.head.profile", Color(red: 0.55, green: 0.32, blue: 0.12)),
            ("Yoga",       categoryMinutes(for: "Yoga"),       "figure.yoga",        Color(red: 0.26, green: 0.20, blue: 0.16)),
            ("Sounds",     categoryMinutes(for: "Relaxing Sounds"), "waveform",       Color(red: 0.08, green: 0.30, blue: 0.30)),
        ].filter { $0.mins > 0 }
    }

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                MindEaseProgressRing(progress: progress, lineWidth: 10, diameter: 80)
                VStack(spacing: 0) {
                    Text("\(done)")
                        .mindEaseStatValue(size: 17)
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
                        .mindEaseStatValue()
                    Text("/ \(target) min")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                if categoryChips.isEmpty {
                    Text("No sessions logged yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 8) {
                        ForEach(categoryChips, id: \.name) { item in
                            ProgressCategoryChip(icon: item.icon, label: "\(item.mins)m", color: item.color)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(18)
        // ← replaces .background / .clipShape / .shadow triple
        .mindEaseCard()
    }
}

// MARK: - Ring Selector Section

struct ProgressRingSelectorSection: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let ringDates: [Date]
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tap a day to view details")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Button { showDatePicker = true } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.mindEasePurple)
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePickerSheet(
                        selectedDate: $selectedDate,
                        accentColor: .mindEasePurple,
                        isPresented: $showDatePicker
                    )
                }
            }

            HStack(spacing: 0) {
                ForEach(ringDates, id: \.self) { date in
                    ProgressRingDayButton(
                        date: date,
                        selectedDate: $selectedDate,
                        dailyTarget: mindEaseStore.dailyMindfulTarget,
                        minutesForDate: { mindEaseStore.mindfulMinutes(for: $0) }
                    )
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .mindEaseCard(cornerRadius: 18, shadowRadius: 8, shadowY: 3)
        }
    }
}

// MARK: - Ring Day Button

struct ProgressRingDayButton: View {
    let date: Date
    @Binding var selectedDate: Date
    let dailyTarget: Int
    let minutesForDate: (Date) -> Int

    private static let dayFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f
    }()

    private var cal:        Calendar { .current }
    private var isSelected: Bool     { cal.startOfDay(for: selectedDate) == cal.startOfDay(for: date) }
    private var mins:       Int      { minutesForDate(date) }
    private var prog:       Double   { min(Double(mins) / Double(max(1, dailyTarget)), 1.0) }

    private var dayLabel: String {
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return Self.dayFmt.string(from: date)
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = cal.startOfDay(for: date)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    // Use MindEaseProgressRing instead of inline Circle/trim
                    MindEaseProgressRing(
                        progress: prog,
                        lineWidth: isSelected ? 7 : 5,
                        diameter: 58,
                        trackOpacity: isSelected ? 0.25 : 0.15
                    )
                    .frame(width: 58, height: 58)

                    if mins > 0 {
                        VStack(spacing: 0) {
                            Text("\(mins)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(isSelected ? .mindEasePurple : .primary)
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

                Text(dayLabel)
                    .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .mindEasePurple : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Selected Day Detail
//
// The straight linear progress bar has been removed.
// The small ring in the header provides sufficient visual progress cue.

struct ProgressSelectedDayDetail: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let selectedDate: Date
    let userId: UUID

    private var sessions: [MindfulSession] {
        mindEaseStore.sessions(for: selectedDate)
            .filter { $0.userId == userId }
            .sorted { $0.startTime < $1.startTime }
    }

    private var totalMins: Int    { sessions.reduce(0) { $0 + $1.minutesCompleted } }
    private var target:    Int    { max(1, mindEaseStore.dailyMindfulTarget) }
    private var progress:  Double { min(Double(totalMins) / Double(target), 1.0) }

    private var titleLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(selectedDate)     { return "Today" }
        if cal.isDateInYesterday(selectedDate) { return "Yesterday" }
        return selectedDate.mindEaseFormatted("EEE, d MMM")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Day header — ring only, no straight bar ──────────────────────
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
                    MindEaseProgressRing(progress: progress, lineWidth: 4, diameter: 40)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 11))
                        .foregroundColor(.mindEasePurple)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)

            // ── Session rows ─────────────────────────────────────────────────
            if !sessions.isEmpty {
                Divider().padding(.horizontal, 18)

                VStack(spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { idx, session in
                        ProgressSessionDetailRow(session: session)
                        if idx < sessions.count - 1 {
                            Divider().padding(.leading, 74)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .mindEaseCard(cornerRadius: 18, shadowRadius: 8, shadowY: 3)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedDate)
    }
}

// MARK: - Session Detail Row

struct ProgressSessionDetailRow: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let session: MindfulSession

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            MindEaseSessionIconView(
                iconName: mindEaseStore.sessionIcon(for: session),
                size: 40,
                cornerRadius: 8
            )
            .padding(.leading, 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(mindEaseStore.contentTitle(for: session))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(mindEaseStore.categoryName(for: session)) · \(Self.timeFmt.string(from: session.startTime))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(session.minutesCompleted) min")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.mindEasePurple)
                .padding(.trailing, 18)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Category Chip

struct ProgressCategoryChip: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}
// MARK: - Shared Session Icon

struct MindEaseSessionIconView: View {
    let iconName: String
    let size: CGFloat
    let cornerRadius: CGFloat
    var color: Color = .mindEasePurple

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color.opacity(0.10))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: iconName)
                    .font(.system(size: size * 0.45))
                    .foregroundColor(color)
            )
    }
}
// MARK: - Shared Progress Ring

struct MindEaseProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let diameter: CGFloat
    var color: Color = .mindEasePurple
    var trackOpacity: Double = 0.15

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(trackOpacity), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - Previews

#Preview("Progress View") {
    NavigationStack {
        MindEaseProgressView()
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Today Summary Card") {
    ProgressTodaySummaryCard(userId: UUID())
        .environment(AppDataStore())
        .environment(MindEaseDataStore(currentUserId: UUID()))
        .padding()
        .mindEasePageBackground()
}

#Preview("Progress Ring") {
    HStack(spacing: 24) {
        MindEaseProgressRing(progress: 0.0,  lineWidth: 8, diameter: 64)
        MindEaseProgressRing(progress: 0.55, lineWidth: 8, diameter: 64)
        MindEaseProgressRing(progress: 1.0,  lineWidth: 8, diameter: 64)
    }
    .padding()
    .mindEasePageBackground()
}
