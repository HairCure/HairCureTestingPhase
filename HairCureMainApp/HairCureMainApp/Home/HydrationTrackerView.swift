
import SwiftUI

struct HydrationTrackerView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss)         private var dismiss

    @State private var selectedCupSize: CupOption = .medium
    @State private var banner: String? = nil
    /// IDs of water-intake logs created during *this* sheet session.
    /// Used to roll back if the user taps the ✕ (cancel) button.
    @State private var sessionLogIDs: [UUID] = []

    // ── Strict today-only filter ──
    // Uses Calendar.current.isDateInToday to avoid any timezone/midnight
    // edge cases that could bleed yesterday's logs into today's total.
    private var todayLogs: [WaterIntakeLog] {
        store.waterIntakeLogs
            .filter { $0.userId == store.currentUserId }
            .filter { Calendar.current.isDateInToday($0.loggedAt) }
            .sorted { $0.loggedAt > $1.loggedAt }
    }

    private var todayML:  Float { todayLogs.reduce(0) { $0 + $1.cupSizeAmountInML } }
    private var targetML: Float { store.activeNutritionProfile?.waterTargetML ?? 2450 }
    private var progress: Float { min(todayML / targetML, 1.0) }

    enum CupOption: String, CaseIterable {
        case small  = "Small"
        case medium = "Medium"
        case large  = "Large"

        var ml: Float {
            switch self {
            case .small:  return 150
            case .medium: return 250
            case .large:  return 400
            }
        }

        var icon: String {
            switch self {
            case .small:  return "cup.and.saucer"
            case .medium: return "cup.and.saucer.fill"
            case .large:  return "mug.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hcCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Progress ring
                        progressRing
                            .padding(.top, 8)

                        // Today / Target / Remaining strip
                        HStack(spacing: 0) {
                            statCell(value: formattedML(todayML),          label: "Today")
                            stripDivider
                            statCell(value: formattedML(targetML),         label: "Target")
                            stripDivider
                            statCell(value: formattedML(max(0, targetML - todayML)), label: "Remaining")
                        }
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        // Cup size selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select cup size")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                ForEach(CupOption.allCases, id: \.self) { cup in
                                    cupButton(cup)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Log button
                        Button {
                            logWater()
                        } label: {
                            Text("+ Add \(Int(selectedCupSize.ml)) ml")
                                .hcPrimaryButton()
                        }
                        .padding(.horizontal, 20)

                        // Success banner
                        if let msg = banner {
                            Text(msg)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Today's log list
                        if !todayLogs.isEmpty {
                            todayLogList
                        }
                    }
                    .padding(.bottom, 40)
                    .animation(.easeInOut(duration: 0.25), value: banner)
                    .animation(.easeInOut(duration: 0.25), value: todayML)
                }
            }
            .navigationTitle("Hydration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Undo every water log added during this session
                        for id in sessionLogIDs {
                            store.removeWaterEntry(id: id)
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.hcBrown)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Log action

    private func logWater() {
        // Capture the new log's ID so we can undo it on cancel
        let newID = UUID()
        store.waterIntakeLogs.append(WaterIntakeLog(
            id: newID, userId: store.currentUserId,
            date: Date(), cupSize: selectedCupSize.rawValue.lowercased(),
            cupSizeAmountInML: selectedCupSize.ml, loggedAt: Date()
        ))
        sessionLogIDs.append(newID)

        let totalToday = store.todaysTotalWaterML()
        let target     = store.activeNutritionProfile?.waterTargetML ?? 2500
        let remaining  = max(0, target - totalToday)

        let msg = totalToday >= target
            ? "💧 Daily water goal reached! Great job."
            : "💧 +\(Int(selectedCupSize.ml)) ml logged. \(Int(remaining)) ml remaining today."

        withAnimation { banner = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { banner = nil }
        }
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.15, green: 0.55, blue: 0.9).opacity(0.12), lineWidth: 14)
                .frame(width: 140, height: 140)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color(red: 0.15, green: 0.55, blue: 0.9),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 140, height: 140)
                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: progress)

            VStack(spacing: 2) {
                Text(formattedML(todayML))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                Text("of \(formattedML(targetML))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.9))
            }
        }
    }

    // MARK: - Cup Button

    private func cupButton(_ cup: CupOption) -> some View {
        let isSel = selectedCupSize == cup
        return Button { selectedCupSize = cup } label: {
            VStack(spacing: 8) {
                Image(systemName: cup.icon)
                    .font(.system(size: isSel ? 28 : 22))
                    .foregroundStyle(isSel ? .white : Color(red: 0.15, green: 0.55, blue: 0.9))
                Text(cup.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSel ? .white : .primary)
                Text("\(Int(cup.ml)) ml")
                    .font(.system(size: 11))
                    .foregroundStyle(isSel ? .white.opacity(0.80) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSel
                    ? Color(red: 0.15, green: 0.55, blue: 0.9)
                    : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSel ? Color.clear : Color(.systemGray4),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSel ? Color(red: 0.15, green: 0.55, blue: 0.9).opacity(0.30) : .clear,
                radius: 6, x: 0, y: 3
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: selectedCupSize)
    }

    // MARK: - Today's Log List

    private var todayLogList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's log")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(todayLogs.enumerated()), id: \.element.id) { idx, log in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.15, green: 0.55, blue: 0.9).opacity(0.10))
                                .frame(width: 32, height: 32)
                            Image(systemName: "drop.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.9))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(log.cupSize.capitalized) cup")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                            Text(timeString(log.loggedAt))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("+\(Int(log.cupSizeAmountInML)) ml")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Color(red: 0.15, green: 0.55, blue: 0.9).opacity(0.09),
                                in: Capsule()
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)

                    if idx < todayLogs.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Helpers

    private var stripDivider: some View {
        Rectangle()
            .fill(Color(UIColor.separator).opacity(0.5))
            .frame(width: 1, height: 36)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    /// Shows ml below 1000, switches to "x.xL" above
    private func formattedML(_ ml: Float) -> String {
        ml >= 1000
            ? String(format: "%.1fL", ml / 1000)
            : "\(Int(ml)) ml"
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
