//
//  ProfileView.swift
//  HairCureTesting1
//
//  Profile tab — Simple iOS-native List layout (Apple Fitness style)
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @Environment(AppDataStore.self) private var store
    @State private var showLogoutAlert = false

    private var user: User? {
        store.users.first(where: { $0.id == store.currentUserId })
    }
    private var plan: UserPlan? { store.activePlan }

    var body: some View {
        NavigationStack {
            List {

                // ── Account header ──
                Section {
                    HStack(spacing: 14) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 60, height: 60)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 58))
                                .foregroundStyle(.gray)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(user?.name ?? "Your Name")
                                .font(.system(size: 18, weight: .semibold))
                            Text(user?.email ?? "email@example.com")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                }

                // ── General ──
                Section {
                    NavigationLink(destination: MyProfileView()) {
                        Label("My Profile", systemImage: "person.fill")
                    }

                    NavigationLink(destination: NotificationsView()) {
                        Label("Notifications", systemImage: "bell.badge.fill")
                    }

                    NavigationLink(destination: AppPreferencesView()) {
                        Label("App Preferences", systemImage: "slider.horizontal.3")
                    }
                }

                // ── Support ──
                Section {
                    NavigationLink(destination: ProgressPlaceholderView(title: "Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }

                    NavigationLink(destination: ProgressPlaceholderView(title: "Terms & Policies")) {
                        Label("Terms & Policies", systemImage: "doc.text.fill")
                    }

                    NavigationLink(destination: ProgressPlaceholderView(title: "About Us")) {
                        Label("About Us", systemImage: "info.circle.fill")
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
                Section("Account") {
                    NavigationLink(destination: DeleteAccountView()) {
                        Label("Delete Account", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                }

                // ── About ──
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
