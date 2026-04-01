//
//  MindEaseView.swift
//


import SwiftUI

// MARK: - Main View

struct MindEaseView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    @State private var showCalendarSheet  = false
    @State private var calendarPickedDate = Calendar.current.date(
        byAdding: .day, value: -1, to: Date()) ?? Date()

    private var weekDates: [Date] {
        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let offset  = -(weekday - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: offset + $0, to: today) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                MindEaseDateHeader {
                    calendarPickedDate = Calendar.current.date(
                        byAdding: .day, value: -1, to: Date()) ?? Date()
                    showCalendarSheet = true
                }
                .scrollTransition(.animated.threshold(.visible(0.3))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : -10)
                }

                MindEaseWeekCalendar(
                    weekDates: weekDates,
                    dailyTarget: mindEaseStore.dailyMindfulTarget,
                    minutesForDate: { mindEaseStore.mindfulMinutes(for: $0) }
                )
                .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0.2).scaleEffect(p.isIdentity ? 1 : 0.94)
                }

                MindEaseCategorySection()

                MindEaseTodaysPlanSection()

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .mindEasePageBackground()
        .navigationDestination(for: MindEaseCategory.self) { cat in
            MindEaseCategoryListView(category: cat)
        }
        .navigationDestination(for: MindEaseCategoryContent.self) { content in
            MindEasePlayerView(content: content)
        }
        .navigationDestination(for: Date.self) { date in
            MindEaseDayDetailView(date: date)
        }
        .sheet(isPresented: $showCalendarSheet) {
            MindEaseCalendarSheet(pickedDate: $calendarPickedDate)
        }
    }
}

// MARK: - Date Header

struct MindEaseDateHeader: View {
    let onCalendarTap: () -> Void

    private var todayDateString: String {
        Date().mindEaseFormatted("d MMM yyyy")
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("Today, \(todayDateString)")
                .font(.system(size: 20, weight: .bold))
            Spacer()
            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.mindEasePurple)
                    .padding(8)
                    .background(Color.mindEasePurple.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Calendar Sheet

struct MindEaseCalendarSheet: View {
    @Binding var pickedDate: Date
    @Environment(\.dismiss) private var dismiss

    @State private var pushedDate: Date?

    private var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select a past date",
                    selection: $pickedDate,
                    in: ...yesterday,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.mindEasePurple)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                Spacer()
            }
            .navigationTitle("View Past Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button{ dismiss() }
                    label:{
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("View Day") {
                        pushedDate = Calendar.current.startOfDay(for: pickedDate)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.mindEasePurple)
                }
            }
            .navigationDestination(item: $pushedDate) { date in
                MindEaseDayDetailView(date: date)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Week Calendar

struct MindEaseWeekCalendar: View {
    let weekDates: [Date]
    let dailyTarget: Int
    let minutesForDate: (Date) -> Int

    private let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                MindEaseWeekDayCell(
                    date: date,
                    dailyTarget: dailyTarget,
                    minutesForDate: minutesForDate,
                    dayLetters: dayLetters
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Week Day Cell
//
// Fix: NavigationLink.disabled() applies a system-level opacity tint to the
// entire cell, making today's ring look faded. Only past days get a NavigationLink.

struct MindEaseWeekDayCell: View {
    let date: Date
    let dailyTarget: Int
    let minutesForDate: (Date) -> Int
    let dayLetters: [String]

    private var cal:       Calendar { .current }
    private var dayStart:  Date     { cal.startOfDay(for: date) }
    private var today:     Date     { cal.startOfDay(for: Date()) }
    private var isToday:   Bool     { dayStart == today }
    private var isFuture:  Bool     { dayStart > today }
    private var letterIdx: Int      { cal.component(.weekday, from: date) - 1 }

    private var ringProgress: Double {
        min(Double(minutesForDate(date)) / Double(max(1, dailyTarget)), 1.0)
    }

    var body: some View {
        if !isFuture && !isToday {
            NavigationLink(value: dayStart) {
                cellContent
            }
            .buttonStyle(.plain)
        } else {
            cellContent
        }
    }

    private var cellContent: some View {
        VStack(spacing: 6) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.mindEasePurple)
                        .frame(width: 28, height: 28)
                }
                Text(dayLetters[letterIdx])
                    .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                    .foregroundColor(isToday ? .white : .secondary)
            }
            .frame(width: 28, height: 28)

            MindEaseProgressRing(
                progress: ringProgress,
                lineWidth: 4,
                diameter: 32,
                color: isFuture ? .gray : .mindEasePurple,
                trackOpacity: 0.12
            )
            .frame(width: 36, height: 36)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category Section

struct MindEaseCategorySection: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories")
                .mindEaseSectionHeader()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(mindEaseStore.mindEaseCategories) { cat in
                        NavigationLink(value: cat) {
                            MindEaseCategoryCard(category: cat)
                        }
                        .buttonStyle(.plain)
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Today's Plan Section

struct MindEaseTodaysPlanSection: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    private var plans: [TodaysPlan] {
        mindEaseStore.todaysPlans.filter {
            $0.userId == store.currentUserId &&
            Calendar.current.isDateInToday($0.planDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Plan")
                .mindEaseSectionHeader()

            VStack(spacing: 0) {
                ForEach(Array(plans.enumerated()), id: \.element.id) { idx, plan in
                    if let content = mindEaseStore.mindEaseCategoryContents
                        .first(where: { $0.id == plan.contentId }) {

                        NavigationLink(value: content) {
                            MindEasePlanRow(plan: plan, content: content)
                        }
                        .buttonStyle(.plain)
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 22)
                        }

                        if idx < plans.count - 1 {
                            Divider().padding(.leading, 96)
                        }
                    }
                }
            }
            .mindEaseCard(cornerRadius: 16, shadowRadius: 10, shadowY: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Card

struct MindEaseCategoryCard: View {
    let category: MindEaseCategory

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(category.cardImageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 220, height: 145)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .top, endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(width: 220, height: 145)

            VStack(alignment: .leading, spacing: 5) {
                    Text(category.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                
                Text(category.categoryDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.80))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
        }
        .frame(width: 220, height: 145)
    }
}

// MARK: - Plan Row

struct MindEasePlanRow: View {
    let plan: TodaysPlan
    let content: MindEaseCategoryContent

    var body: some View {
        HStack(spacing: 14) {
            Image(content.imageurl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(Color.mindEasePurple.opacity(0.05))

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                HStack(spacing: 6) {
                    Text("\(content.durationMinutes) mins")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.mindEasePurple)
                    Text(content.difficultyLevel.capitalized)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            if plan.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.mindEasePurple)
            } else {
                Text("Start")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(Color.mindEasePurple)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Previews

#Preview("MindEase Home") {
    NavigationStack {
        MindEaseView()
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Week Calendar") {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let weekday = cal.component(.weekday, from: today)
    let offset = -(weekday - 1)
    let dates = (0..<7).compactMap { cal.date(byAdding: .day, value: offset + $0, to: today) }

    return MindEaseWeekCalendar(
        weekDates: dates,
        dailyTarget: 30,
        minutesForDate: { _ in Int.random(in: 0...35) }
    )
    .padding()
    .mindEasePageBackground()
}
