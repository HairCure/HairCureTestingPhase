//
//  ProfileView.swift
//  HairCureMainApp
//
//  Profile tab — iOS 18 Apple-native design
//  Polished initials header, plan summary card, icon-row navigation.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @Environment(AppDataStore.self) private var store
    @State private var showLogoutAlert = false
    @State private var showRetakeAssessment = false

    private var user: User? {
        store.users.first(where: { $0.id == store.currentUserId })
    }
    private var plan: UserPlan? { store.activePlan }

    var body: some View {
        NavigationStack {
            List {

                // ── Account Header ──
                accountHeaderSection

                // ── Your Plan ──
                planSummarySection

                // ── General ──
                Section {
                    ProfileRow(icon: "person.fill", color: .blue, title: "My Profile") {
                        MyProfileView()
                    }
                    ProfileRow(icon: "bell.badge.fill", color: .red, title: "Notifications") {
                        NotificationsView()
                    }
                    ProfileRow(icon: "gearshape.fill", color: Color(.systemGray), title: "App Preferences") {
                        AppPreferencesView()
                    }
                }

                // ── Support ──
                Section {
                    ProfileRow(icon: "questionmark.circle.fill", color: .purple, title: "Help & Support") {
                        ProgressPlaceholderView(title: "Help & Support")
                    }
                    ProfileRow(icon: "doc.text.fill", color: .orange, title: "Terms & Policies") {
                        ProgressPlaceholderView(title: "Terms & Policies")
                    }
                    ProfileRow(icon: "info.circle.fill", color: .teal, title: "About Us") {
                        ProgressPlaceholderView(title: "About Us")
                    }
                }

                // ── Sign Out ──
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }

                // ── Account Management ──
                Section {
                    NavigationLink(destination: DeleteAccountView()) {
                        HStack(spacing: 14) {
                            iconBadge(systemName: "trash.fill", color: Color(.systemRed))
                            Text("Delete Account")
                                .foregroundStyle(.red)
                        }
                    }
                }

                // ── Footer ──
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Made with ❤️ for healthier hair")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    // TODO: Implement actual sign-out logic
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .fullScreenCover(isPresented: $showRetakeAssessment) {
                RetakeAssessmentFlow {
                    showRetakeAssessment = false
                }
                .environment(store)
                .environment(store.hairInsightsStore)
                .environment(store.dietMateStore)
                .environment(store.mindEaseStore)
            }
        }
    }

    // MARK: - Account Header

    private var accountHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                // Initials avatar
                initialsAvatar
                    .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 3) {
                    Text(user?.name ?? "Your Name")
                        .font(.system(size: 20, weight: .semibold))
                    Text(user?.email ?? "email@example.com")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    private var initialsAvatar: some View {
        let name = user?.name ?? ""
        let initials = name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map { String($0) } }
            .joined()
            .uppercased()

        return ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.36, green: 0.18, blue: 0.18),
                            Color(red: 0.48, green: 0.28, blue: 0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(initials.isEmpty ? "?" : initials)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Plan Summary Card

    private var planSummarySection: some View {
        Section {
            if let plan = plan {
                activePlanCard(plan)
            } else {
                noPlanCard
            }
        }
    }

    private func activePlanCard(_ plan: UserPlan) -> some View {
        let daysOnPlan = Calendar.current.dateComponents(
            [.day], from: plan.assignedAt, to: Date()
        ).day ?? 0
        let planName = plan.planId.planDisplayName

        return VStack(alignment: .leading, spacing: 14) {

            // Top row: plan name + badge
            HStack(spacing: 10) {
                // Plan icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.36, green: 0.18, blue: 0.18),
                                    Color(red: 0.50, green: 0.30, blue: 0.30)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(planName)
                        .font(.system(size: 17, weight: .semibold))
                    Text("Day \(daysOnPlan + 1) · \(plan.lifestyleProfile.rawValue.capitalized) lifestyle")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Plan ID badge
                Text(plan.planId)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.18))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Color(red: 0.36, green: 0.18, blue: 0.18).opacity(0.10),
                        in: Capsule()
                    )
            }

            // Info chips
            HStack(spacing: 12) {
                planInfoChip(icon: "chart.bar.fill", label: "Stage \(plan.stage)")
                planInfoChip(icon: "figure.mind.and.body", label: "\(plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay) min/day")
                planInfoChip(icon: "calendar", label: "\(plan.sessionFrequencyPerWeek)×/week")
            }

            // Retake button
            Button {
                showRetakeAssessment = true
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Retake Assessment")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.hcBrown, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private func planInfoChip(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var noPlanCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(Color.hcBrown.opacity(0.6))

            Text("No Active Plan")
                .font(.system(size: 17, weight: .semibold))

            Text("Complete an assessment to get your personalised hair care plan.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showRetakeAssessment = true
            } label: {
                Text("Start Assessment")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.hcBrown, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Icon Badge Helper

    private func iconBadge(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color.gradient)
                .frame(width: 30, height: 30)

            Image(systemName: systemName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - ProfileRow (iOS 18 icon-row style)

private struct ProfileRow<Destination: View>: View {
    let icon: String
    let color: Color
    let title: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(color.gradient)
                        .frame(width: 30, height: 30)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }

                Text(title)
            }
        }
    }
}

// MARK: - Delete Account View

struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    var body: some View {
        List {
            Section {
                Text("Deleting your account will permanently remove all your data, including your profile, progress, and preferences. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete My Account")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure?", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: Implement actual account deletion
                dismiss()
            }
        } message: {
            Text("This will permanently delete your account and all associated data.")
        }
    }
}

// MARK: - Placeholder for unbuilt screens

struct ProgressPlaceholderView: View {
    let title: String
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text(title).font(.system(size: 20, weight: .semibold))
            Text("Coming soon").foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    ProfileView().environment(AppDataStore())
}
