import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: 1 — Hair Progress View  (journey, main entry)
// ─────────────────────────────────────────────────────────────

struct HairProgressView: View {
    @Environment(AppDataStore.self) private var store

    // ── Scan flow state ──
    @State private var showWeeklyScan        = false
    @State private var showMonthlyAssessment = false
    @State private var showNotDueAlert       = false
    @State private var notDueDaysLeft        = 0

    // ── Post-scan navigation ──
    @State private var pushToEntry: HairProgressEntry? = nil

    private var previewEntries: [HairProgressEntry] {
        Array(hairProgressEntries(for: Date(), store: store).prefix(3))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // ── Main scroll ──────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Hair Journey")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    if previewEntries.isEmpty {
                        emptyJourneyState
                    } else {
                        ForEach(previewEntries) { entry in
                            NavigationLink(destination: HairProgressDetailView(entry: entry)) {
                                HairProgressCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }

                    NavigationLink(destination: HairProgressAllScansView()) {
                        Text("See all")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.hcTeal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 120)
                }
                .padding(.top, 4)
            }
            .background(Color.hcCream.ignoresSafeArea())

            // ── FAB + schedule chip ─────────────────────────────────
            VStack(alignment: .trailing, spacing: 10) {
                scheduleChip
                floatingCameraButton
            }
            .padding(.trailing, 20)
            .padding(.bottom, 28)
        }
        .navigationTitle("Hair Progress")
        .navigationBarTitleDisplayMode(.inline)

        // ── Post-scan push to detail ─────────────────────────────────
        .navigationDestination(item: $pushToEntry) { entry in
            HairProgressDetailView(entry: entry)
        }

        // ── Weekly scan sheet ────────────────────────────────────────
        .sheet(isPresented: $showWeeklyScan) {
            WeeklyScanView { newReport in
                showWeeklyScan = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    pushToEntry = makeEntry(from: newReport)
                }
            }
            .environment(store)
        }

        // ── Monthly (full) re-assessment ─────────────────────────────
        .fullScreenCover(isPresented: $showMonthlyAssessment) {
            MonthlyAssessmentWrapper(
                onComplete: { newReport in
                    showMonthlyAssessment = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        pushToEntry = makeEntry(from: newReport)
                    }
                },
                onCancel: { showMonthlyAssessment = false }
            )
            .environment(store)
        }

        // ── Not-due alert ────────────────────────────────────────────
        .alert("Scan Not Due Yet", isPresented: $showNotDueAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "Your next scan is due in \(notDueDaysLeft) day\(notDueDaysLeft == 1 ? "" : "s"). "
              + "Keep following your plan until then!"
            )
        }
    }

    // MARK: - Schedule Chip

    private var scheduleChip: some View {
        let schedule = RecommendationEngine.scanSchedule(store: store)
        let (label, isActive) = RecommendationEngine.scheduleChipInfo(for: schedule)

        return Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(isActive ? .white : Color.primary.opacity(0.60))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isActive
                    ? Color.hcBrown.opacity(0.92)
                    : Color(UIColor.systemGray5)
            )
            .clipShape(Capsule())
    }

    // MARK: - Floating Camera FAB

    private var floatingCameraButton: some View {
        Button { handleCameraTap() } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.424, green: 0.298, blue: 0.302),
                                Color(red: 0.298, green: 0.192, blue: 0.196),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .shadow(
                        color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.40),
                        radius: 14, x: 0, y: 6
                    )
                Image(systemName: "camera.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Camera Tap Handler

    private func handleCameraTap() {
        let schedule = RecommendationEngine.scanSchedule(store: store)
        switch schedule {
        case .firstScan, .monthlyDue:
            showMonthlyAssessment = true
        case .weeklyDue:
            showWeeklyScan = true
        case .notDue(_, let daysLeft):
            notDueDaysLeft   = daysLeft
            showNotDueAlert  = true
        }
    }

    // MARK: - Empty State

    private var emptyJourneyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 52))
                .foregroundColor(Color.hcBrown.opacity(0.30))
            Text("No scans yet")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            Text("Tap the camera button below\nto take your first scan.")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func makeEntry(from report: ScanReport) -> HairProgressEntry {
        let df = DateFormatter(); df.dateFormat = "dd MMM,yyyy"
        return HairProgressEntry(
            id:             report.id,
            densityPercent: Int(report.hairDensityPercent),
            doneOn:         df.string(from: report.createdAt),
            scanReport:     report
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 2 — All Scans View  (monthly reports + full history)
// ─────────────────────────────────────────────────────────────

struct HairProgressAllScansView: View {
    @Environment(AppDataStore.self) private var store

    @State private var selectedMonth:        Date = Date()
    @State private var showMonthPicker       = false

    // ── Scan flow state ──
    @State private var showWeeklyScan        = false
    @State private var showMonthlyAssessment = false
    @State private var showNotDueAlert       = false
    @State private var notDueDaysLeft        = 0

    private var entries: [HairProgressEntry] {
        hairProgressEntries(for: selectedMonth, store: store)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // ── Month row ────────────────────────────────────
                    HStack {
                        Text("Monthly reports")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                        Button { showMonthPicker.toggle() } label: {
                            HStack(spacing: 6) {
                                Text(monthLabel(selectedMonth))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Image(systemName: "calendar")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.hcBrown)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── Entry cards ──────────────────────────────────
                    if entries.isEmpty {
                        emptyState
                    } else {
                        ForEach(entries) { entry in
                            NavigationLink(destination: HairProgressDetailView(entry: entry)) {
                                HairProgressCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, 8)
            }
            .background(Color.hcCream.ignoresSafeArea())

            // ── FAB + chip ───────────────────────────────────────────
            VStack(alignment: .trailing, spacing: 10) {
                scheduleChip
                floatingCameraButton
            }
            .padding(.trailing, 20)
            .padding(.bottom, 28)
        }
        .navigationTitle("My Hair Progress")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerSheet(selectedMonth: $selectedMonth)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showWeeklyScan) {
            WeeklyScanView { _ in showWeeklyScan = false }
                .environment(store)
        }
        .fullScreenCover(isPresented: $showMonthlyAssessment) {
            MonthlyAssessmentWrapper(
                onComplete: { _ in showMonthlyAssessment = false },
                onCancel:   { showMonthlyAssessment = false }
            )
            .environment(store)
        }
        .alert("Scan Not Due Yet", isPresented: $showNotDueAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "Your next scan is due in \(notDueDaysLeft) day\(notDueDaysLeft == 1 ? "" : "s")."
            )
        }
    }

    // MARK: - Schedule Chip

    private var scheduleChip: some View {
        let schedule = RecommendationEngine.scanSchedule(store: store)
        let (label, isActive) = RecommendationEngine.scheduleChipInfo(for: schedule)
        return Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(isActive ? .white : Color.primary.opacity(0.60))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.hcBrown.opacity(0.92) : Color(UIColor.systemGray5))
            .clipShape(Capsule())
    }

    // MARK: - FAB

    private var floatingCameraButton: some View {
        Button { handleCameraTap() } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.424, green: 0.298, blue: 0.302),
                                Color(red: 0.298, green: 0.192, blue: 0.196),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .shadow(
                        color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.40),
                        radius: 14, x: 0, y: 6
                    )
                Image(systemName: "camera.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func handleCameraTap() {
        let schedule = RecommendationEngine.scanSchedule(store: store)
        switch schedule {
        case .firstScan, .monthlyDue: showMonthlyAssessment = true
        case .weeklyDue:              showWeeklyScan = true
        case .notDue(_, let days):    notDueDaysLeft = days; showNotDueAlert = true
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 52))
                .foregroundColor(Color.hcBrown.opacity(0.35))
            Text("No scans for this month")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    private func monthLabel(_ date: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "dd MMM, yyyy"
        let lastDay = Calendar.current.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        ) ?? date
        return df.string(from: lastDay)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 3 — Monthly Assessment Wrapper
// Wraps AssessmentView in a NavigationStack with a Cancel button.
// After completion reads store.latestScanReport and fires onComplete.
// ─────────────────────────────────────────────────────────────

struct MonthlyAssessmentWrapper: View {
    @Environment(AppDataStore.self) private var store

    let onComplete: (ScanReport) -> Void
    let onCancel:   () -> Void

    var body: some View {
        NavigationStack {
            AssessmentView {
                // AssessmentView called store.completeAssessment() just before this
                if let newReport = store.latestScanReport {
                    onComplete(newReport)
                } else {
                    onCancel()  // fallback — should not normally happen
                }
            }
            .environment(store)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(Color.hcBrown)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 4 — Shared Data Model + hairProgressEntries()
// ─────────────────────────────────────────────────────────────

struct HairProgressEntry: Identifiable, Hashable {
    let id:             UUID
    let densityPercent: Int
    let doneOn:         String          // "05 Dec,2025"
    let scanReport:     ScanReport?     // non-nil only when a real scan exists

    // Hash & equality by id only (ScanReport doesn't need to be Hashable)
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

/// Builds an ordered (newest-first) entry list for a given month.
///
/// Logic:
///  1. Pull every real ScanReport for the month from store.scanReports.
///  2. Generate weekly slot dates (last day of month, -7, -14, -21, -28).
///  3. Past slots:   match a real scan within ±3 days  →  real entry
///                   no match within ±3 days            →  placeholder "not taken"
///  4. Future slots: silently skipped (no upcoming placeholders).
func hairProgressEntries(for month: Date, store: AppDataStore) -> [HairProgressEntry] {
    let cal   = Calendar.current
    let comps = cal.dateComponents([.year, .month], from: month)

    guard let firstOfMonth = cal.date(from: comps),
          let firstOfNext  = cal.date(byAdding: .month, value: 1, to: firstOfMonth)
    else { return [] }

    let df    = DateFormatter(); df.dateFormat = "dd MMM,yyyy"
    let today = cal.startOfDay(for: Date())

    // ── All real scans for this month, newest first ────────────────
    let monthReports = store.scanReports
        .filter { $0.createdAt >= firstOfMonth && $0.createdAt < firstOfNext }
        .sorted  { $0.createdAt > $1.createdAt }

    // ── Weekly slot dates (counting back from last day of month) ───
    let weekOffsets: [Int] = [0, 7, 14, 21, 28]
    var slotDates: [Date] = []
    for offset in weekOffsets {
        guard let d = cal.date(byAdding: .day, value: -offset, to: firstOfNext),
              d >= firstOfMonth
        else { continue }
        slotDates.append(cal.startOfDay(for: d))
    }

    var usedReportIds = Set<UUID>()
    var entries       = [HairProgressEntry]()

    for slotDate in slotDates {

        // Skip future slots — they haven't happened yet
        if slotDate > today { continue }

        // Find the closest unused real scan within ±3 calendar days
        let matched = monthReports.first { report in
            guard !usedReportIds.contains(report.id) else { return false }
            let reportDay = cal.startOfDay(for: report.createdAt)
            let diff      = abs(cal.dateComponents([.day], from: slotDate, to: reportDay).day ?? 99)
            return diff <= 3
        }

        if let report = matched {
            usedReportIds.insert(report.id)
            entries.append(HairProgressEntry(
                id:             report.id,
                densityPercent: Int(report.hairDensityPercent),
                doneOn:         df.string(from: report.createdAt),
                scanReport:     report
            ))
        } else {
            // Past slot with no scan — placeholder
            entries.append(HairProgressEntry(
                id:             UUID(),
                densityPercent: 0,
                doneOn:         df.string(from: slotDate),
                scanReport:     nil
            ))
        }
    }

    // ── Inject any real scans that weren't matched to a slot ───────
    // This handles the case where a scan date doesn't fall within ±3
    // days of any *past* weekly slot (e.g. scan taken today when the
    // nearest slot is still in the future).
    let unmatchedReports = monthReports.filter { !usedReportIds.contains($0.id) }
    for report in unmatchedReports {
        entries.insert(
            HairProgressEntry(
                id:             report.id,
                densityPercent: Int(report.hairDensityPercent),
                doneOn:         df.string(from: report.createdAt),
                scanReport:     report
            ),
            at: 0   // newest-first — prepend
        )
    }

    return entries
}

// ─────────────────────────────────────────────────────────────
// MARK: 5 — Shared Card
// ─────────────────────────────────────────────────────────────

struct HairProgressCard: View {
    let entry: HairProgressEntry

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                if entry.scanReport != nil {
                    Text("Density : \(entry.densityPercent)%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                } else {
                    Text("Scan not taken")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Text("Done on \(entry.doneOn)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("View Details")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(entry.scanReport != nil ? Color.hcBrown : Color(.systemGray3))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 6 — Month Picker Sheet
// ─────────────────────────────────────────────────────────────

private struct MonthPickerSheet: View {
    @Binding var selectedMonth: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DatePicker("Select month",
                       selection: $selectedMonth,
                       displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(Color.hcBrown)
                .padding(.horizontal)
                .navigationTitle("Choose Month")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(Color.hcBrown)
                    }
                }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 7 — Detail View
// ─────────────────────────────────────────────────────────────

struct HairProgressDetailView: View {
    let entry: HairProgressEntry
    @State private var animateBars = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let report = entry.scanReport {
                realScanContent(report: report)
            } else {
                noScanContent
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("Scan Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.85).delay(0.3)) { animateBars = true }
        }
    }

    // MARK: Real scan

    @ViewBuilder
    private func realScanContent(report: ScanReport) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            // Density gauge
            densityGauge(percent: Int(report.hairDensityPercent), doneOn: entry.doneOn)
                .padding(.horizontal, 20)

            // Analysis rows
            VStack(spacing: 10) {
                analysisRow(title: "Hair Density Level",
                            value: densityLevelLabel(report.hairDensityPercent),
                            color: densityColor(report.hairDensityPercent))
                analysisRow(title: "Growth Stage",
                            value: "Stage \(report.hairFallStage.intValue)",
                            color: stageColor(report.hairFallStage.intValue))
                analysisRow(title: "Scalp Condition",
                            value: scalpLabel(report.scalpCondition),
                            color: Color(red: 0.2, green: 0.55, blue: 0.9))
                analysisRow(title: "Scan Type",
                            value: scanTypeLabel(report),
                            color: .primary)
                analysisRow(title: "Analysis Source",
                            value: report.analysisSource.rawValue,
                            color: .primary)
            }
            .padding(.horizontal, 20)

            // Lifestyle scores
            lifestyleScoresCard(report: report)
                .padding(.horizontal, 20)

            // Plan info
            planInfoCard(report: report)
                .padding(.horizontal, 20)

            Spacer(minLength: 40)
        }
        .padding(.top, 16)
    }

    // MARK: No scan placeholder

    private var noScanContent: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 80)

            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 120, height: 120)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(Color.hcBrown.opacity(0.38))
            }

            VStack(spacing: 8) {
                Text("Scan Not Taken")
                    .font(.system(size: 20, weight: .bold))
                Text("No hair scan was recorded\nfor \(entry.doneOn).")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Greyed placeholder rows
            VStack(spacing: 10) {
                ForEach(["Hair Density Level", "Growth Stage", "Scalp Condition",
                         "Scan Type", "Analysis Source"], id: \.self) { title in
                    placeholderRow(title: title)
                }
            }
            .padding(.horizontal, 20)
            .opacity(0.40)

            Spacer(minLength: 80)
        }
    }

    // MARK: Sub-views

    private func densityGauge(percent: Int, doneOn: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.hcBrown.opacity(0.15), lineWidth: 14)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: animateBars ? CGFloat(percent) / 100 : 0)
                    .stroke(Color.hcBrown,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: animateBars)
                VStack(spacing: 2) {
                    Text("\(percent)%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.hcBrown)
                    Text("Hair Density")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 12)
            Text("Done on \(doneOn)")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analysisRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func placeholderRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray4))
                .frame(width: 80, height: 14)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func lifestyleScoresCard(report: ScanReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Lifestyle Scores")
                .font(.system(size: 17, weight: .bold))
            Divider()
            HStack(alignment: .center, spacing: 16) {
                compositeRing(score: report.lifestyleScore)
                    .frame(width: 90, height: 90)
                VStack(spacing: 10) {
                    dimBar("Sleep",     report.sleepScore,    Color(red: 0.3,  green: 0.55, blue: 0.9))
                    dimBar("Stress",    report.stressScore,   Color(red: 0.4,  green: 0.72, blue: 0.35))
                    dimBar("Diet",      report.dietScore,     Color(red: 0.9,  green: 0.58, blue: 0.18))
                    dimBar("Hair Care", report.hairCareScore, Color.hcBrown)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func compositeRing(score: Float) -> some View {
        let frac = CGFloat(score / 10.0)
        let c: Color = score < 5 ? .red : score < 8 ? .orange : .green
        return ZStack {
            Circle().stroke(c.opacity(0.18), lineWidth: 10)
            Circle()
                .trim(from: 0, to: animateBars ? frac : 0)
                .stroke(c, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0).delay(0.2), value: animateBars)
            VStack(spacing: 1) {
                Text(String(format: "%.1f", score))
                    .font(.system(size: 18, weight: .bold))
                Text("/ 10")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func dimBar(_ title: String, _ value: Float, _ c: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.system(size: 12, weight: .semibold))
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(c.opacity(0.15)).frame(height: 5)
                    Capsule().fill(c)
                        .frame(width: animateBars ? g.size.width * CGFloat(value / 10.0) : 0, height: 5)
                        .animation(.easeOut(duration: 0.85).delay(0.3), value: animateBars)
                }
            }
            .frame(height: 5)
        }
    }

    private func planInfoCard(report: ScanReport) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.hcBrown)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.hcBrown.opacity(0.30), radius: 8, y: 3)
                VStack(spacing: 1) {
                    Text("Plan")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    Text(report.planId)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(report.planId.planDisplayName)
                    .font(.system(size: 16, weight: .bold))
                Text(report.recommendedPlan)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: Helpers

    private func scanTypeLabel(_ report: ScanReport) -> String {
        // Heuristic: if it's the first ever scan (lowest createdAt among all) → "Initial Assessment"
        // Otherwise check if lifestyle scores changed vs typical carry-forward (same = weekly)
        // Simple rule: if plan was changed this scan → "Monthly Re-assessment", else "Weekly Scan"
        return "Weekly Scan"   // can be enhanced with a ScanReport.scanType field in future
    }

    private func densityLevelLabel(_ pct: Float) -> String {
        switch pct {
        case 80...100: return "High — Thick & full"
        case 65..<80:  return "Medium"
        default:       return "Low — Thin"
        }
    }

    private func densityColor(_ pct: Float) -> Color {
        switch pct {
        case 80...100: return .green
        case 65..<80:  return .orange
        default:       return .red
        }
    }

    private func stageColor(_ s: Int) -> Color {
        switch s {
        case 1:  return .green
        case 2:  return .orange
        case 3:  return Color(red: 0.85, green: 0.35, blue: 0.1)
        default: return .red
        }
    }

    private func scalpLabel(_ c: ScalpCondition) -> String {
        switch c {
        case .dry:      return "Mild Dryness"
        case .dandruff: return "Dandruff"
        case .oily:     return "Oily Scalp"
        case .inflamed: return "Inflamed"
        case .normal:   return "Normal"
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────

#Preview {
    NavigationStack {
        HairProgressView()
    }
    .environment(AppDataStore())
}

