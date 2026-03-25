//
//  AssessmentView.swift
//  HairCure
//
//  No changes required in this file.
//
//  All store calls (store.assessmentQuestions, store.options, store.saveAnswer,
//  store.saveMultiAnswer, store.savePickerAnswer, store.startAssessment,
//  store.completeAssessment) are forwarded from AppDataStore → AssessmentDataStore
//  via the bridge layer in AppDataStore.swift.
//
//  Original implementation is preserved verbatim below.
//

import SwiftUI

struct AssessmentView: View {
    @Environment(AppDataStore.self) private var store
    let onComplete: () -> Void

    // ── Navigation state ──
    @State private var currentIndex = 0

    // ── Local answer state (reset/restore per question) ──
    @State private var singleSelections: [UUID: UUID]       = [:]
    @State private var multiSelections:  [UUID: Set<UUID>]  = [:]
    @State private var pickerValues:     [UUID: Float]       = [:]
    @State private var imageSelections:  [UUID: UUID]        = [:]
    @State private var textValues:       [UUID: String]      = [:]

    // ── Derived ──
    private var questions:        [Question] { store.assessmentQuestions() }
    private var totalCount:       Int        { questions.count }
    private var currentQuestion:  Question?  {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    // ─────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.hcCream.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                HCProgressBar(current: currentIndex + 1, total: totalCount)
                    .animation(.easeInOut(duration: 0.30), value: currentIndex)
                    .padding(.bottom, 32)

                if let q = currentQuestion {
                    questionBody(q)
                        .id(currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer(minLength: 100)
            }

            continueButton
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
        .onAppear {
            store.startAssessment()
            seedPickerDefaults()
        }
        .animation(.easeInOut(duration: 0.22), value: currentIndex)
    }

    // ─────────────────────────────────────
    // MARK: Header
    // ─────────────────────────────────────

    private var headerBar: some View {
        HStack {
            HCBackButton {
                if currentIndex > 0 { currentIndex -= 1 }
            }
            .opacity(currentIndex > 0 ? 1 : 0.3)
            .disabled(currentIndex == 0)

            Spacer()

            if currentQuestion?.scoreDimension != Optional.none {
                Button("Skip") { advance() }
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
    }

    // ─────────────────────────────────────
    // MARK: Question body — routes by type
    // ─────────────────────────────────────

    @ViewBuilder
    private func questionBody(_ q: Question) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text(q.questionText)
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 8)

                switch q.questionType {
                case .singleChoice:
                    singleChoiceOptions(for: q)
                case .multiChoice:
                    multiChoiceOptions(for: q)
                case .picker:
                    pickerQuestion(for: q)
                case .imageChoice:
                    imageChoiceGrid(for: q)
                case .freeText:
                    freeTextQuestion(for: q)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // ─────────────────────────────────────
    // MARK: Single Choice
    // ─────────────────────────────────────

    private func singleChoiceOptions(for q: Question) -> some View {
        let opts     = store.options(for: q.id)
        let selected = singleSelections[q.id]

        return VStack(spacing: 12) {
            ForEach(opts) { opt in
                Button {
                    singleSelections[q.id] = opt.id
                    store.saveAnswer(questionId: q.id, selectedOptionId: opt.id)
                } label: {
                    HStack {
                        Text(opt.optionText)
                            .font(.system(size: 17, weight: selected == opt.id ? .semibold : .regular))
                            .foregroundColor(selected == opt.id ? .white : .primary)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(selected == opt.id ? Color.hcBrown : Color.hcOptionBg)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selected == opt.id ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: Multi Choice
    // ─────────────────────────────────────

    private func multiChoiceOptions(for q: Question) -> some View {
        let opts     = store.options(for: q.id)
        let selected = multiSelections[q.id] ?? []

        return VStack(spacing: 12) {
            ForEach(opts) { opt in
                let isSelected = selected.contains(opt.id)
                Button {
                    var current = multiSelections[q.id] ?? []
                    if current.contains(opt.id) {
                        current.remove(opt.id)
                    } else {
                        current.insert(opt.id)
                    }
                    multiSelections[q.id] = current
                    store.saveMultiAnswer(questionId: q.id, selectedOptionIds: Array(current))
                } label: {
                    HStack {
                        Text(opt.optionText)
                            .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.leading, 20)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(isSelected ? Color.hcBrown : Color.hcOptionBg)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: Picker (age / height / weight)
    // ─────────────────────────────────────

    private func pickerQuestion(for q: Question) -> some View {
        let minVal  = Int(q.pickerMin  ?? 0)
        let maxVal  = Int(q.pickerMax  ?? 100)
        let unit    = q.pickerUnit ?? ""
        let current = Binding<Float>(
            get: { pickerValues[q.id] ?? q.pickerMin ?? 0 },
            set: { newVal in
                pickerValues[q.id] = newVal
                store.savePickerAnswer(questionId: q.id, pickerValue: newVal)
            }
        )

        let intCurrent = Binding<Int>(
            get: { Int(current.wrappedValue) },
            set: { current.wrappedValue = Float($0) }
        )

        let displayText = Binding<String>(
            get: { "\(Int(current.wrappedValue)) \(unit)" },
            set: { _ in }
        )

        return VStack(spacing: 20) {
            TextField("", text: displayText)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.hcInputBg)
                .cornerRadius(12)
                .disabled(true)

            Picker("", selection: intCurrent) {
                ForEach(minVal...maxVal, id: \.self) { val in
                    Text("\(val) \(unit)").tag(val)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
            .clipped()
        }
        .padding(.horizontal, 4)
    }

    // ─────────────────────────────────────
    // MARK: Image Choice (stage cards)
    // ─────────────────────────────────────

    private func imageChoiceGrid(for q: Question) -> some View {
        let opts     = store.options(for: q.id)
        let selected = imageSelections[q.id]
        let columns  = [GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(opts) { opt in
                let isSelected = selected == opt.id
                Button {
                    imageSelections[q.id] = opt.id
                    store.saveAnswer(questionId: q.id, selectedOptionId: opt.id)
                } label: {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSelected ? Color.hcBrown : Color(.systemGray5),
                                        lineWidth: isSelected ? 2.5 : 1
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
        if let url = imageURL, !url.isEmpty, UIImage(named: url) != nil {
            Image(url).resizable().scaledToFit().padding(12)
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
    // MARK: Free Text
    // ─────────────────────────────────────

    private func freeTextQuestion(for q: Question) -> some View {
        let binding = Binding<String>(
            get: { textValues[q.id] ?? "" },
            set: { textValues[q.id] = $0 }
        )
        return TextField("Your answer", text: binding).hcInputField()
    }

    // ─────────────────────────────────────
    // MARK: Continue Button
    // ─────────────────────────────────────

    private var continueButton: some View {
        Button {
            guard canContinue else { return }
            if currentIndex == totalCount - 1 {
                store.completeAssessment()
                onComplete()
            } else {
                advance()
            }
        } label: {
            Text(currentIndex == totalCount - 1 ? "Finish" : "Continue")
                .hcPrimaryButton()
                .opacity(canContinue ? 1.0 : 0.5)
        }
        .disabled(!canContinue)
    }

    // ─────────────────────────────────────
    // MARK: Can Continue Logic
    // ─────────────────────────────────────

    private var canContinue: Bool {
        guard let q = currentQuestion else { return false }
        switch q.questionType {
        case .singleChoice: return singleSelections[q.id] != nil
        case .multiChoice:  return !(multiSelections[q.id]?.isEmpty ?? true)
        case .picker:       return pickerValues[q.id] != nil
        case .imageChoice:  return imageSelections[q.id] != nil
        case .freeText:
            return !(textValues[q.id]?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
    }

    // ─────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────

    private func advance() {
        if currentIndex < totalCount - 1 { currentIndex += 1 }
    }

    private func seedPickerDefaults() {
        for q in questions where q.questionType == .picker {
            if pickerValues[q.id] == nil {
                let midpoint = ((q.pickerMin ?? 0) + (q.pickerMax ?? 100)) / 2
                pickerValues[q.id] = midpoint
            }
        }
    }
}
