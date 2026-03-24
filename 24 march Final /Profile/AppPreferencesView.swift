//
//  AppPreferencesView.swift
//  HairCureTesting1
//
//  Profile → App Preferences — iOS-native List layout
//

import SwiftUI

struct AppPreferencesView: View {
    @State private var selectedAppearance: Appearance = .system
    @State private var selectedUnit: WeightUnit = .kg
    @State private var hapticFeedback = true
    @State private var showCaloriesOnHome = true
    @State private var showWaterOnHome = true
    @State private var showMindfulOnHome = true

    enum Appearance: String, CaseIterable {
        case system = "System"
        case light  = "Light"
        case dark   = "Dark"
    }

    enum WeightUnit: String, CaseIterable {
        case kg  = "Kilograms"
        case lbs = "Pounds"
    }

    var body: some View {
        List {

            // ── Appearance ──
            Section("Appearance") {
                Picker("Theme", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }

            // ── Units ──
            Section("Units") {
                Picker("Weight", selection: $selectedUnit) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }

            // ── Home Screen ──
            Section {
                Toggle("Calories Card", isOn: $showCaloriesOnHome)
                Toggle("Water Intake Card", isOn: $showWaterOnHome)
                Toggle("Mindful Minutes Card", isOn: $showMindfulOnHome)
            } header: {
                Text("Home Screen")
            } footer: {
                Text("Choose which tracker cards appear on your home screen.")
            }

            // ── General ──
            Section("General") {
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("App Preferences")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { AppPreferencesView() }
}
