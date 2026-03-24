//
//  HCPrimaryButton.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//


//
//  HCTheme.swift
//  HairCure
//
//  Central design tokens — colours, typography, shared ViewModifiers.
//  Every view imports these via the Color / Font extensions.
//

import SwiftUI

// MARK: - Colours

extension Color {
    /// Dark brown — primary button fill, selected option, progress bar fill
    static let hcBrown       = Color(red: 0.239, green: 0.102, blue: 0.102)   // #3D1A1A
    /// Slightly lighter brown — used on pressed states / borders
    static let hcBrownLight  = Color(red: 0.361, green: 0.176, blue: 0.176)   // #5C2D2D
    /// Teal — link colour, "Continue as guest"
    static let hcTeal        = Color(red: 0.000, green: 0.749, blue: 0.647)   // #00BFA5
    /// Cream — page background for assessment + onboarding
    static let hcCream       = Color(red: 0.980, green: 0.965, blue: 0.941)   // #FAF5EF
    /// Input field background
    static let hcInputBg     = Color(red: 0.929, green: 0.945, blue: 0.961)   // #EDF1F5
    /// Unselected option background
    static let hcOptionBg    = Color(red: 0.965, green: 0.961, blue: 0.957)   // #F6F5F4
    /// Progress bar unfilled segment
    static let hcProgressBg  = Color(red: 0.878, green: 0.867, blue: 0.855)   // #E0DDA9 (muted)
}

// MARK: - Shared Button Styles

struct HCPrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.hcBrown)
            .cornerRadius(14)
    }
}

struct HCSecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.hcBrown)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.hcBrown, lineWidth: 1.5)
            )
    }
}

extension View {
    func hcPrimaryButton() -> some View { modifier(HCPrimaryButton()) }
    func hcSecondaryButton() -> some View { modifier(HCSecondaryButton()) }
}

// MARK: - Input Field Style

struct HCInputField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color.hcInputBg)
            .cornerRadius(12)
    }
}

extension View {
    func hcInputField() -> some View { modifier(HCInputField()) }
}

// MARK: - Progress Bar (dashed segments)

struct HCProgressBar: View {
    let current: Int    // 1-based answered count
    let total: Int

    private let segmentCount = 8

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<segmentCount, id: \.self) { i in
                // Use integer cross-multiplication to avoid Float rounding drift.
                // Segment i is filled when: current / total >= (i+1) / segmentCount
                // ↔ current * segmentCount >= (i + 1) * total
                let filled = current * segmentCount >= (i + 1) * total
                Capsule()
                    .fill(filled ? Color.hcBrown : Color.hcProgressBg)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Back Button

struct HCBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
        }
    }
}