//
//  ScanSchedule.swift
//  Hair12
//
//  Created by Chetan Kandpal on 24/03/26.
//


//
//  ScanSchedule.swift
//  HairCureTesting1
//
//  Created by Chetan Kandpal on 24/03/26.
//


//
//  RecommendationEngine+Schedule.swift
//  HairCureTesting1
//
//  Scan cadence rules:
//  ─────────────────────────────────────────────────────────
//  No prior scan          → firstScan    → full monthly assessment
//  0–6 days since last    → notDue       → countdown chip only
//  7–27 days since last   → weeklyDue    → WeeklyScanView (3 photos)
//  ≥28 days since last    → monthlyDue   → full re-assessment (AssessmentView)
//  ─────────────────────────────────────────────────────────

import Foundation

extension RecommendationEngine {

    // MARK: - Scan Schedule Enum

    enum ScanSchedule: Equatable {
        /// No scans exist at all — launch full first-time assessment.
        case firstScan
        /// 7–27 days since last scan — photo-only weekly scan.
        case weeklyDue(dueDate: Date)
        /// ≥28 days since last scan — full re-assessment with photos + 12 questions.
        case monthlyDue(dueDate: Date)
        /// <7 days since last scan — show countdown, no scan allowed.
        case notDue(nextDate: Date, daysLeft: Int)
    }

    // MARK: - Schedule Resolver

    /// Returns the current scan schedule based on the store's scan history.
    static func scanSchedule(store: AppDataStore) -> ScanSchedule {
        guard let latest = store.latestScanReport else {
            return .firstScan
        }

        let cal         = Calendar.current
        let now         = Date()
        let daysSince   = cal.dateComponents([.day], from: latest.createdAt, to: now).day ?? 0

        let nextWeekly  = cal.date(byAdding: .day, value: 7,  to: latest.createdAt) ?? now
        let nextMonthly = cal.date(byAdding: .day, value: 28, to: latest.createdAt) ?? now

        switch daysSince {
        case ..<7:
            return .notDue(nextDate: nextWeekly, daysLeft: max(1, 7 - daysSince))
        case 7..<28:
            return .weeklyDue(dueDate: nextWeekly)
        default:
            return .monthlyDue(dueDate: nextMonthly)
        }
    }

    // MARK: - Chip Display Info

    /// Returns the FAB chip label text and whether the scan is actively due.
    static func scheduleChipInfo(for schedule: ScanSchedule) -> (label: String, isActive: Bool) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM"

        switch schedule {

        case .firstScan:
            return ("Take Your First Scan", true)

        case .weeklyDue(let due):
            let dueStr = Calendar.current.isDateInToday(due)
                ? "Today"
                : df.string(from: due)
            return ("Weekly Scan · Due \(dueStr)", true)

        case .monthlyDue(let due):
            let dueStr = Calendar.current.isDateInToday(due)
                ? "Today"
                : df.string(from: due)
            return ("Monthly Assessment · Due \(dueStr)", true)

        case .notDue(_, let days):
            return ("Next scan in \(days) day\(days == 1 ? "" : "s")", false)
        }
    }

    // MARK: - Next Scan Type Label (plain string for display)

    static func nextScanTypeLabel(for schedule: ScanSchedule) -> String {
        switch schedule {
        case .firstScan, .monthlyDue: return "Monthly Assessment"
        case .weeklyDue:              return "Weekly Scan"
        case .notDue(_, let days):    return "In \(days) day\(days == 1 ? "" : "s")"
        }
    }
}
