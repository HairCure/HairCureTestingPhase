
//
//  FallbackAssessmentView.swift
//  HairCure
//
//  Path B — 3 fallback questions shown when the user skips/fails AI scan.
//  Reads from store.fallbackQuestions() (orderIndex 13, 14, 15).
//
//  Q13 (orderIndex 13) — imageChoice   → hairFallStage
//  Q14 (orderIndex 14) — singleChoice  → scalpCondition
//  Q15 (orderIndex 15) — singleChoice  → hairDensity
//
//  After Q15 Continue → maps selections to enums → calls
//  store.submitSelfAssessedStage() → engine runs → onComplete()
//
//  Stage 4 edge case: engine returns .referDoctor →
//  show inline doctor message instead of proceeding to main app.
//

import SwiftUI

struct FallbackAssessmentView: View {
    let onComplete: () -> Void

    @Environment(AppDataStore.self) private var store
    
    @State private var pendingScalp:   ScalpCondition  = .normal
    @State private var pendingDensity: HairDensityLevel = .medium

    @State private var currentIndex    = 0
    @State private var stageOptionId:  UUID? = nil
    @State private var scalpOptionId:  UUID? = nil
    @State private var densityOptionId: UUID? = nil

    @State private var showDoctorAlert = false
    @State private var doctorMessage   = ""

    private var questions: [Question] { store.fallbackQuestions() }
    private var total: Int { questions.count }
    private var current: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.hcCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                HStack {
                    HCBackButton {
                        if currentIndex > 0 { currentIndex -= 1 }
                    }
                    .opacity(currentIndex > 0 ? 1 : 0.3)
                    .disabled(currentIndex == 0)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // ── Progress bar (3 segments) ──
                HCProgressBar(current: currentIndex + 1, total: total)
                    .padding(.bottom, 32)

                // ── Question ──
                if let q = current {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            Text(q.questionText)
                                .font(.system(size: 26, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 8)

                            switch q.questionType {
                            case .imageChoice:
                                stageImageGrid(for: q)
                            case .singleChoice:
                                singleChoiceOptions(for: q)
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
            }

            // ── Continue button ──
            Button {
                handleContinue()
            } label: {
                Text(currentIndex == total - 1 ? "Get My Plan" : "Continue")
                    .hcPrimaryButton()
                    .opacity(canContinue ? 1.0 : 0.5)
            }
            .disabled(!canContinue)
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .animation(.easeInOut(duration: 0.22), value: currentIndex)
        .alert("Doctor Consultation Recommended", isPresented: $showDoctorAlert) {
            Button("Understood") { onComplete() }
        } message: {
            Text(doctorMessage)
        }
    }

    // ─────────────────────────────────────
    // MARK: Stage Image Grid (Q13)
    // ─────────────────────────────────────

    private func stageImageGrid(for q: Question) -> some View {
        let opts     = store.options(for: q.id)
        let selected = stageOptionId
        let columns  = [GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(opts) { opt in
                let isSel = selected == opt.id
                Button {
                    stageOptionId = opt.id
                    store.saveAnswer(questionId: q.id, selectedOptionId: opt.id)
                } label: {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSel ? Color.hcBrown : Color(.systemGray5),
                                        lineWidth: isSel ? 2.5 : 1
                                    )
                            )

                        VStack(spacing: 0) {
                            stageImage(imageURL: opt.imageURL, index: opt.optionOrderIndex)
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .clipped()
                        }

                        Text("\(opt.optionOrderIndex)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                    .frame(height: 150)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func stageImage(imageURL: String?, index: Int) -> some View {
        if let url = imageURL, UIImage(named: url) != nil {
            Image(url)
                .resizable()
                .scaledToFit()
                .padding(12)
        } else {
            ZStack {
                Color(.systemGray6)
                VStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(.systemGray3))
                    Text("Stage \(index)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.systemGray2))
                }
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: Single Choice (Q14 / Q15)
    // ─────────────────────────────────────

    private func singleChoiceOptions(for q: Question) -> some View {
        let opts = store.options(for: q.id)
        let selected: UUID? = q.questionOrderIndex == 14 ? scalpOptionId : densityOptionId

        return VStack(spacing: 12) {
            ForEach(opts) { opt in
                let isSel = selected == opt.id
                Button {
                    if q.questionOrderIndex == 14 {
                        scalpOptionId = opt.id
                    } else {
                        densityOptionId = opt.id
                    }
                    store.saveAnswer(questionId: q.id, selectedOptionId: opt.id)
                } label: {
                    HStack {
                        Text(opt.optionText)
                            .font(.system(size: 17, weight: isSel ? .semibold : .regular))
                            .foregroundColor(isSel ? .white : .primary)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity).frame(height: 58)
                    .background(isSel ? Color.hcBrown : Color.hcOptionBg)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSel ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: Can Continue
    // ─────────────────────────────────────

    private var canContinue: Bool {
        guard let q = current else { return false }
        switch q.questionOrderIndex {
        case 13: return stageOptionId   != nil
        case 14: return scalpOptionId   != nil
        case 15: return densityOptionId != nil
        default: return true
        }
    }

    // ─────────────────────────────────────
    // MARK: Handle Continue / Submit
    // ─────────────────────────────────────

    private func handleContinue() {
        if currentIndex < total - 1 {
            currentIndex += 1
            return
        }
        // All 3 answered — submit to engine
        submitToEngine()
    }

    private func submitToEngine() {
        let stage   = resolveStage()
        let scalp   = resolveScalp()
        let density = resolveDensity()

        let result = store.submitSelfAssessedStage(
            stage: stage, scalp: scalp, density: density
        )

        switch result {
        case .referDoctor(let msg):
            doctorMessage   = msg
            showDoctorAlert = true
            
            // Store scalp + density so we can use them after "Understood"
                pendingScalp    = scalp
                pendingDensity  = density
        default:
            onComplete()
        }
    }

    // ─────────────────────────────────────
    // MARK: Enum Mappers
    // ─────────────────────────────────────

    private func resolveStage() -> HairFallStage {
        guard let optId = stageOptionId,
              let q = questions.first(where: { $0.questionOrderIndex == 13 }),
              let opt = store.options(for: q.id).first(where: { $0.id == optId })
        else { return .stage2 }

        switch opt.optionOrderIndex {
        case 1: return .stage1
        case 2: return .stage2
        case 3: return .stage3
        case 4: return .stage4
        default: return .stage2
        }
    }

    private func resolveScalp() -> ScalpCondition {
        guard let optId = scalpOptionId,
              let q = questions.first(where: { $0.questionOrderIndex == 14 }),
              let opt = store.options(for: q.id).first(where: { $0.id == optId })
        else { return .normal }

        let text = opt.optionText.lowercased()
        if text.contains("flak") || text.contains("dandruff") { return .dandruff }
        if text.contains("tight") || text.contains("dry")     { return .dry }
        if text.contains("greasy") || text.contains("oily")   { return .oily }
        if text.contains("red") || text.contains("inflam")    { return .inflamed }
        return .normal
    }

    private func resolveDensity() -> HairDensityLevel {
        guard let optId = densityOptionId,
              let q = questions.first(where: { $0.questionOrderIndex == 15 }),
              let opt = store.options(for: q.id).first(where: { $0.id == optId })
        else { return .medium }

        let text = opt.optionText.lowercased()
        if text.contains("thick")      { return .high }
        if text.contains("medium")     { return .medium }
        if text.contains("very thin")  { return .veryLow }
        if text.contains("thin")       { return .low }
        return .medium
    }
}
