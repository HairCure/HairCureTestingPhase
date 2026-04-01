//
//  ProfileSetupView.swift
//  HairCure
//
//  One-time profile setup shown after registration.
//  Collects: date of birth, height, weight.
//  Saves to UserProfile — engine reads these silently, never asks again.
//

import SwiftUI

struct ProfileSetupView: View {
    let onComplete: () -> Void

    @Environment(AppDataStore.self) private var store

    // Local state
    @State private var age:           Float = 22
    @State private var heightCm:      Float = 170
    @State private var weightKg:      Float = 70

    // Step navigation (3 steps)
    @State private var step = 0
    private let totalSteps = 3

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.hcCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header with back button ──
                HStack {
                    HCBackButton {
                        if step > 0 { step -= 1 }
                    }
                    .opacity(step > 0 ? 1 : 0.3)
                    .disabled(step == 0)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // ── Paged content ──
//                TabView(selection: $step) {
//                    ForEach(0..<totalSteps, id: \.self) { index in
//                        VStack(spacing: 0) {
//                            Spacer(minLength: 20)
//                            stepPage(for: index)
//                                .padding(.horizontal, 24)
//                            Spacer(minLength: 120)
//                        }
//                        .tag(index)
//                    }
//                }
                TabView(selection: $step) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        VStack(spacing: 0) {
                            stepPage(for: index)
                                .padding(.horizontal, 24)
                                .padding(.top, 60)          // ← fixed distance from header
                            Spacer()                        // ← only one spacer, pushes content UP
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            // Block swipe—only Continue/Back advances
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture().onChanged { _ in }
            )

            // ── Dots + Continue button ──
            VStack(spacing: 16) {
                Spacer()

                // Paging dots
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Color.hcBrown : Color.hcBrown.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                Button { handleContinue() } label: {
                    Text(step == totalSteps - 1 ? "Get Started" : "Continue")
                        .hcPrimaryButton()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: step)
    }

    // ─────────────────────────────────────
    // MARK: Step Content
    // ─────────────────────────────────────

    @ViewBuilder
    private func stepPage(for index: Int) -> some View {
        switch index {
        case 0: ageStep
        case 1: heightStep
        case 2: weightStep
        default: EmptyView()
        }
    }

    // Step 0 — Age
    private var ageStep: some View {
        VStack(spacing: 24) {
            questionTitle("What is your age?")

            // Display field
            Text("\(Int(age)) yrs")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.hcInputBg)
                .cornerRadius(12)

            Picker("Age", selection: Binding(
                get: { Int(age) },
                set: { age = Float($0) }
            )) {
                ForEach(15...60, id: \.self) { v in
                    Text("\(v) yrs").tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
            .clipped()
        }
    }

    // Step 1 — Height
    private var heightStep: some View {
        VStack(spacing: 24) {
            questionTitle("What is your height?")

            Text("\(Int(heightCm)) cm")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.hcInputBg)
                .cornerRadius(12)

            Picker("Height", selection: Binding(
                get: { Int(heightCm) },
                set: { heightCm = Float($0) }
            )) {
                ForEach(140...220, id: \.self) { v in
                    Text("\(v) cm").tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
            .clipped()
        }
    }

    // Step 2 — Weight
    private var weightStep: some View {
        // Use 0.5kg steps: 40.0 to 150.0 → index × 0.5 + 40
        let steps = stride(from: Float(40), through: Float(150), by: Float(0.5)).map { $0 }

        let selIdx = Binding<Int>(
            get: {
                let idx = steps.firstIndex(where: { abs($0 - weightKg) < 0.01 }) ?? 60
                return idx
            },
            set: { weightKg = steps[$0] }
        )

        return VStack(spacing: 24) {
            questionTitle("What is your weight?")

            Text(String(format: "%.1f kg", weightKg))
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.hcInputBg)
                .cornerRadius(12)

            Picker("Weight", selection: selIdx) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Text(String(format: "%.1f kg", steps[i])).tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
            .clipped()
        }
    }



    // ─────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────

    private func stylePageDots() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.hcBrown)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.hcBrown.opacity(0.2))
    }

    private func questionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 26, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func handleContinue() {
        if step < totalSteps - 1 {
            step += 1
            return
        }
        // Save to UserProfile
        saveToProfile()
        onComplete()
    }

    private func saveToProfile() {
        guard let idx = store.userProfiles.firstIndex(
            where: { $0.userId == store.currentUserId }
        ) else { return }

        let dob = Calendar.current.date(
            byAdding: .year,
            value: -Int(age),
            to: Date()
        ) ?? store.userProfiles[idx].dateOfBirth

        store.userProfiles[idx].dateOfBirth   = dob
        store.userProfiles[idx].heightCm      = heightCm
        store.userProfiles[idx].weightKg      = weightKg

        // Recalculate nutrition with default activity — Q7 in assessment sets actual level
        store.updatePhysicalProfile(
            heightCm: heightCm,
            weightKg: weightKg
        )
    }
}
