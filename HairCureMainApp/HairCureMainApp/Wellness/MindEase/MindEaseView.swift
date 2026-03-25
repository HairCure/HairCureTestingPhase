//
//  MindEaseView.swift
//

import SwiftUI

// MARK: - Nav destination wrappers

struct MindEaseCategoryDest: Hashable { let id: UUID }
struct MindEaseContentDest:  Hashable { let id: UUID }
struct MindEaseDayDest:      Hashable { let date: Date }

// MARK: - Main View

struct MindEaseView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    @State private var catDest:           MindEaseCategoryDest? = nil
    @State private var contentDest:       MindEaseContentDest?  = nil
    @State private var pushedDay:         MindEaseDayDest?      = nil
    @State private var showCalendarSheet: Bool                  = false
    @State private var calendarPickedDate: Date                 = Calendar.current.date(
        byAdding: .day, value: -1, to: Date()) ?? Date()

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    private var weekDates: [Date] {
        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let offset  = -(weekday - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: offset + $0, to: today) }
    }

    private var todayDateString: String {
        let f = DateFormatter(); f.dateFormat = "d MMM yyyy"; return f.string(from: Date())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                dateHeader
                    .scrollTransition(.animated.threshold(.visible(0.3))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : -10)
                    }

                weekCalendar
                    .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0.2).scaleEffect(p.isIdentity ? 1 : 0.94)
                    }

                categorySection
                todaysPlanSection
                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationDestination(item: $pushedDay) { dest in
            MindEaseDayDetailView(date: dest.date)
        }
        .navigationDestination(item: $catDest) { dest in
            if let cat = mindEaseStore.mindEaseCategories.first(where: { $0.id == dest.id }) {
                MindEaseCategoryListView(category: cat)
            }
        }
        .navigationDestination(item: $contentDest) { dest in
            if let c = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == dest.id }) {
                MindEasePlayerView(content: c)
            }
        }
        .sheet(isPresented: $showCalendarSheet) { calendarSheet }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack(spacing: 8) {
            Text("Today, \(todayDateString)")
                .font(.system(size: 20, weight: .bold))
            Spacer()
            Button {
                calendarPickedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                showCalendarSheet  = true
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(purple)
                    .padding(8)
                    .background(purple.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Calendar Sheet

    private var calendarSheet: some View {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select a past date",
                    selection: $calendarPickedDate,
                    in: ...yesterday,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(purple)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                Spacer()
            }
            .navigationTitle("View Past Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCalendarSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("View Day") {
                        showCalendarSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            pushedDay = MindEaseDayDest(
                                date: Calendar.current.startOfDay(for: calendarPickedDate))
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(purple)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        let cal        = Calendar.current
        let today      = cal.startOfDay(for: Date())
        let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]
        let target     = Double(mindEaseStore.dailyMindfulTarget)

        func ringProgress(_ date: Date) -> Double {
            guard target > 0 else { return 0 }
            return min(Double(mindEaseStore.mindfulMinutes(for: date)) / target, 1.0)
        }

        return HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { _, date in
                let dayStart  = cal.startOfDay(for: date)
                let isToday   = dayStart == today
                let isFuture  = dayStart > today
                let letterIdx = cal.component(.weekday, from: date) - 1
                let prog      = ringProgress(date)

                VStack(spacing: 6) {
                    ZStack {
                        if isToday {
                            Circle().fill(purple).frame(width: 28, height: 28)
                        }
                        Text(dayLetters[letterIdx])
                            .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                            .foregroundColor(isToday ? .white : .secondary)
                    }
                    .frame(width: 28, height: 28)

                    ZStack {
                        // Background track circle
                        Circle()
                            .stroke(Color.gray.opacity(0.12), lineWidth: 4)
                            .frame(width: 32, height: 32)
                        
                        if prog > 0 {
                            Circle()
                                .trim(from: 0, to: prog)
                                .stroke(
                                    isFuture ? Color.gray.opacity(0.3) : purple,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 32, height: 32)
                                .animation(.easeInOut(duration: 0.4), value: prog)
                        }
                    }
                    .frame(width: 36, height: 36)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !isFuture, !isToday else { return }
                    pushedDay = MindEaseDayDest(date: dayStart)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Categories

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)
                .scrollTransition(.animated) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : -20)
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(mindEaseStore.mindEaseCategories) { cat in
                        MindEaseCategoryCard(category: cat) {
                            catDest = MindEaseCategoryDest(id: cat.id)
                        }
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

    // MARK: - Today's Plan

    private var todaysPlanSection: some View {
        let plans = mindEaseStore.todaysPlans
            .filter { $0.userId == store.currentUserId && Calendar.current.isDateInToday($0.planDate) }
            .sorted { $0.orderIndex < $1.orderIndex }

        return VStack(alignment: .leading, spacing: 14) {
            Text("Today's Plan")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)
                .scrollTransition(.animated) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : -20)
                }

            VStack(spacing: 0) {
                ForEach(Array(plans.enumerated()), id: \.element.id) { idx, plan in
                    if let content = mindEaseStore.mindEaseCategoryContents
                        .first(where: { $0.id == plan.contentId }) {
                        MindEasePlanRow(plan: plan, content: content) {
                            contentDest = MindEaseContentDest(id: content.id)
                        }
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 22)
                        }
                        if idx < plans.count - 1 {
                            Divider().padding(.leading, 96)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Card

struct MindEaseCategoryCard: View {
    let category: MindEaseCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Image(category.cardImageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 220, height: 145)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                LinearGradient(colors: [.clear, .black.opacity(0.75)],
                               startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(width: 220, height: 145)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(category.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                    }
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
        .buttonStyle(.plain)
    }
}

// MARK: - Today's Plan Row

struct MindEasePlanRow: View {
    let plan: TodaysPlan
    let content: MindEaseCategoryContent
    let onStart: () -> Void

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    var body: some View {
        HStack(spacing: 14) {
            Image(content.imageurl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(purple.opacity(0.05))

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.system(size: 16, weight: .semibold))
                HStack(spacing: 6) {
                    Text("\(content.durationMinutes) mins")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(purple)
                    Text(content.difficultyLevel.capitalized)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            if plan.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(purple)
            } else {
                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(purple)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
