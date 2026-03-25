
//
//  AuthViews.swift
//  HairCure
//
//  Three auth screens:
//   1. AuthLandingView   — logo + Login / Register / Guest
//   2. LoginView         — email + password form
//   3. RegisterView      — mobile / email / password / confirm
//
//  In mock mode every action calls onProceed() immediately.
//  No credential validation.
//

import SwiftUI

// ─────────────────────────────────────────────
// MARK: 1 — Auth Landing
// ─────────────────────────────────────────────

struct AuthLandingView: View {
    let onProceed: () -> Void

    @State private var showLogin    = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // ── Logo ──
                    logoView
                        .padding(.bottom, 16)

                    // ── App name ──
                    Text("HairCure")
                        .font(.system(size: 38, weight: .regular))
                        .foregroundColor(.primary)

                    Spacer()

                    // ── Buttons ──
                    VStack(spacing: 14) {
                        NavigationLink(destination: LoginView(onProceed: onProceed)) {
                            Text("Login")
                                .hcPrimaryButton()
                        }

                        NavigationLink(destination: RegisterView(onProceed: onProceed)) {
                            Text("Register")
                                .hcSecondaryButton()
                        }

                        Button("Continue as a guest") {
                            onProceed()
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.hcTeal)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // Male head silhouette — uses asset if available, SF Symbol fallback
    private var logoView: some View {
        Group {
            if UIImage(named: "haircure_logo") != nil {
                Image("haircure_logo")
                    .resizable()
                    .scaledToFit()
                    

                    .frame(width: 400, height: 400)
                                }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: 2 — Login
// ─────────────────────────────────────────────

struct LoginView: View {
    let onProceed: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var email        = ""
    @State private var password     = ""
    @State private var showPassword = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Heading ──
                    Text("Welcome back!\nGlad to see you, Again!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 32)
                        .padding(.bottom, 36)

                    // ── Email ──
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .hcInputField()
                        .padding(.bottom, 14)

                    // ── Password ──
                    ZStack(alignment: .trailing) {
                        Group {
                            if showPassword {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
                            }
                        }
                        .hcInputField()

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 16)
                        }
                    }
                    .padding(.bottom, 8)

                    // ── Forgot password ──
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {}
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 28)

                    // ── Login button ──
                    Button("Login") { onProceed() }
                        .hcPrimaryButton()
                        .padding(.bottom, 28)

                    // ── Or login with ──
                    dividerRow(label: "Or Login with")
                        .padding(.bottom, 20)

                    // ── Social buttons ──
                    socialRow { onProceed() }
                        .padding(.bottom, 32)

                    // ── Register link ──
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Button("Register Now") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.hcTeal)
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HCBackButton { dismiss() }
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: 3 — Register
// ─────────────────────────────────────────────

struct RegisterView: View {
    let onProceed: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var mobile          = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Heading ──
                    Text("Hello! Register to\nget started")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 32)
                        .padding(.bottom, 36)

                    // ── Fields ──
                    TextField("Enter your mobile number", text: $mobile)
                        .keyboardType(.phonePad)
                        .hcInputField()
                        .padding(.bottom, 14)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .hcInputField()
                        .padding(.bottom, 14)

                    SecureField("Password", text: $password)
                        .hcInputField()
                        .padding(.bottom, 14)

                    SecureField("Confirm password", text: $confirmPassword)
                        .hcInputField()
                        .padding(.bottom, 28)

                    // ── Register button ──
                    Button("Register") { onProceed() }
                        .hcPrimaryButton()
                        .padding(.bottom, 28)

                    // ── Or register with ──
                    dividerRow(label: "Or Register with")
                        .padding(.bottom, 20)

                    // ── Social buttons ──
                    socialRow { onProceed() }
                        .padding(.bottom, 32)

                    // ── Login link ──
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Button("Login Now") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.hcTeal)
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HCBackButton { dismiss() }
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: Shared Auth Sub-views
// ─────────────────────────────────────────────

private func dividerRow(label: String) -> some View {
    HStack {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(height: 1)
        Text(label)
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .fixedSize()
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(height: 1)
    }
}

private func socialRow(onTap: @escaping () -> Void) -> some View {
    HStack(spacing: 16) {
        Button(action: onTap) {
            HStack {
                Image(systemName: "apple.logo")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }

        Button(action: onTap) {
            HStack {
                // Google "G" coloured icon — text fallback
                Text("G")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .yellow, .green, .blue],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
}
