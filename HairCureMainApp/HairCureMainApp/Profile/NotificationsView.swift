//
//  NotificationsView.swift
//  HairCureTesting1
//
//  Profile → Notifications — iOS-native List layout
//

import SwiftUI

struct NotificationsView: View {
    @State private var dailyReminders    = true
    @State private var mealReminders     = true
    @State private var waterReminders    = true
    @State private var mindEaseReminders = false
    @State private var scanReminders     = true
    @State private var weeklyReport      = true
    @State private var tipsAndArticles   = false

    var body: some View {
        List {

            // ── Reminders ──
            Section {
                Toggle("Daily Reminders", isOn: $dailyReminders)
                Toggle("Meal Logging", isOn: $mealReminders)
                Toggle("Water Intake", isOn: $waterReminders)
                Toggle("MindEase Sessions", isOn: $mindEaseReminders)
                Toggle("Hair Scan Reminder", isOn: $scanReminders)
            } header: {
                Text("Reminders")
            } footer: {
                Text("Get notified to stay on track with your daily goals.")
            }

            // ── Reports ──
            Section {
                Toggle("Weekly Progress Report", isOn: $weeklyReport)
            } header: {
                Text("Reports")
            } footer: {
                Text("Receive a summary of your weekly progress every Sunday.")
            }

            // ── Promotional ──
            Section {
                Toggle("Tips & Articles", isOn: $tipsAndArticles)
            } header: {
                Text("Other")
            } footer: {
                Text("Occasional tips on hair care, nutrition, and wellness.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { NotificationsView() }
}
