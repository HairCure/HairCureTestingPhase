//
//  MyProfileView.swift
//  HairCureTesting1
//
//  Profile → My Profile — Simple iOS-native List layout
//  Tap "Edit" in toolbar to toggle edit mode.
//

import SwiftUI

// MARK: - MyProfileView

struct MyProfileView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false

    // Personal
    @State private var fullName:     String = ""
    @State private var phoneNumber:  String = ""
    @State private var email:        String = ""
    @State private var dateOfBirth:  Date   = Date()
    @State private var showDOBPicker = false

    // Hair
    @State private var hairType:  String = ""
    @State private var scalpType: String = ""

    // Wellness
    @State private var calorieGoal:    String = ""
    @State private var waterGoalML:    String = ""
    @State private var heightCm:       String = ""
    @State private var weightKg:       String = ""
    @State private var isVegetarian:   Bool   = false
    @State private var yogaMinutes:    String = ""
    @State private var meditationMins: String = ""
    @State private var soundMins:      String = ""

    private var user:      User?                 { store.users.first(where: { $0.id == store.currentUserId }) }
    private var profile:   UserProfile?          { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
    private var report:    ScanReport?           { store.scanReports.last }
    private var plan:      UserPlan?             { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
    private var nutrition: UserNutritionProfile? { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }

    var body: some View {
        List {

            // ── Personal Information ──
            Section("Personal Information") {
                editableRow(label: "Full Name", text: $fullName, placeholder: "Full name")
                editableRow(label: "Phone", text: $phoneNumber, placeholder: "+91 9876543210", keyboard: .phonePad)
                editableRow(label: "Email", text: $email, placeholder: "email@example.com", keyboard: .emailAddress)

                Button {
                    if isEditing { showDOBPicker = true }
                } label: {
                    HStack {
                        Text("Date of Birth")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(dobDisplayText)
                            .foregroundStyle(.secondary)
                        if isEditing {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .disabled(!isEditing)
                .sheet(isPresented: $showDOBPicker) {
                    dobPickerSheet
                }
            }

            // ── Hair Profile ──
            Section("Hair Profile") {
                HStack {
                    Text("Current Diagnosis")
                    Spacer()
                    Text(report?.hairFallStage.displayName ?? "—")
                        .foregroundStyle(.secondary)
                }

                editableRow(label: "Hair Type", text: $hairType, placeholder: "e.g. Wavy")
                editableRow(label: "Scalp Type", text: $scalpType, placeholder: "e.g. Dry")
            }

            // ── Daily Goals ──
            Section("Daily Goals") {
                editableRow(label: "Calorie Goal", text: $calorieGoal, placeholder: "kcal", keyboard: .numberPad, unit: "kcal")
                editableRow(label: "Hydration Goal", text: $waterGoalML, placeholder: "mL", keyboard: .numberPad, unit: "mL")
                editableRow(label: "Height", text: $heightCm, placeholder: "cm", keyboard: .numberPad, unit: "cm")
                editableRow(label: "Weight", text: $weightKg, placeholder: "kg", keyboard: .decimalPad, unit: "kg")

                if isEditing {
                    Toggle("Vegetarian", isOn: $isVegetarian)
                } else {
                    HStack {
                        Text("Vegetarian")
                        Spacer()
                        Text(isVegetarian ? "Yes" : "No")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // ── MindEase ──
            Section("MindEase") {
                editableRow(label: "Yoga", text: $yogaMinutes, placeholder: "min", keyboard: .numberPad, unit: "min/day")
                editableRow(label: "Meditation", text: $meditationMins, placeholder: "min", keyboard: .numberPad, unit: "min/day")
                editableRow(label: "Relaxing Sound", text: $soundMins, placeholder: "min", keyboard: .numberPad, unit: "min/day")
            }

            // ── Save (only in edit mode) ──
            if isEditing {
                Section {
                    Button(action: {
                        saveProfile()
                        isEditing = false
                    }) {
                        Text("Update Profile")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.hcBrown)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveProfile()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear(perform: loadFields)
    }

    // MARK: - Editable Row

    @ViewBuilder
    private func editableRow(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        unit: String? = nil
    ) -> some View {
        HStack {
            Text(label)
            Spacer()
            if isEditing {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.primary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                if let unit {
                    Text(unit)
                        .foregroundStyle(.tertiary)
                }
            } else {
                Text(text.wrappedValue.isEmpty ? "—" : text.wrappedValue + (unit.map { " \($0)" } ?? ""))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - DOB Helpers

    private var dobDisplayText: String {
        if Calendar.current.isDateInToday(dateOfBirth) && fullName.isEmpty {
            return "DD / MM / YYYY"
        }
        let f = DateFormatter()
        f.dateFormat = "dd / MM / yyyy"
        return f.string(from: dateOfBirth)
    }

    private var dobPickerSheet: some View {
        NavigationStack {
            DatePicker("Date of Birth", selection: $dateOfBirth,
                       in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .navigationTitle("Date of Birth")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showDOBPicker = false }
                            .fontWeight(.semibold)
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Load / Save

    private func loadFields() {
        fullName    = user?.name        ?? ""
        phoneNumber = user?.phoneNumber ?? ""
        email       = user?.email       ?? ""
        if let dob = profile?.dateOfBirth { dateOfBirth = dob }

        hairType  = (profile?.hairType  ?? "").capitalized
        scalpType = (profile?.scalpType ?? "").capitalized

        calorieGoal    = "\(Int(nutrition?.tdee ?? 2038))"
        waterGoalML    = "\(Int(nutrition?.waterTargetML ?? 2450))"
        heightCm       = "\(Int(profile?.heightCm ?? 0))"
        weightKg       = "\(Int(profile?.weightKg ?? 0))"
        isVegetarian   = profile?.isVegetarian ?? false
        yogaMinutes    = "\(plan?.yogaMinutesPerDay ?? 0)"
        meditationMins = "\(plan?.meditationMinutesPerDay ?? 0)"
        soundMins      = "\(plan?.soundMinutesPerDay ?? 0)"
    }

    private func saveProfile() {
        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
            store.users[idx].name        = fullName
            store.users[idx].phoneNumber = phoneNumber
            store.users[idx].email       = email
        }
        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userProfiles[idx].displayName  = fullName
            store.userProfiles[idx].dateOfBirth  = dateOfBirth
            store.userProfiles[idx].hairType     = hairType.lowercased()
            store.userProfiles[idx].scalpType    = scalpType.lowercased()
            store.userProfiles[idx].heightCm     = Float(heightCm) ?? store.userProfiles[idx].heightCm
            store.userProfiles[idx].weightKg     = Float(weightKg) ?? store.userProfiles[idx].weightKg
            store.userProfiles[idx].isVegetarian = isVegetarian
        }
        if let idx = store.userNutritionProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userNutritionProfiles[idx].tdee          = Float(calorieGoal) ?? store.userNutritionProfiles[idx].tdee
            store.userNutritionProfiles[idx].waterTargetML = Float(waterGoalML) ?? store.userNutritionProfiles[idx].waterTargetML
        }
        if let idx = store.userPlans.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userPlans[idx].yogaMinutesPerDay       = Int(yogaMinutes)    ?? store.userPlans[idx].yogaMinutesPerDay
            store.userPlans[idx].meditationMinutesPerDay = Int(meditationMins) ?? store.userPlans[idx].meditationMinutesPerDay
            store.userPlans[idx].soundMinutesPerDay      = Int(soundMins)      ?? store.userPlans[idx].soundMinutesPerDay
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { MyProfileView() }
        .environment(AppDataStore())
}
