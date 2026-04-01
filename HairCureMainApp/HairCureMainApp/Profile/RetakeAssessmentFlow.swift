//
//  RetakeAssessmentFlow.swift
//  HairCure
//
//  Presented as a fullScreenCover from ProfileView.
//  Walks the user through: Assessment → Hair Analysis → Plan Results → Done.
//  On completion the engine has re-run, the active plan is updated,
//  and the user returns to the Profile tab.
//

import SwiftUI

struct RetakeAssessmentFlow: View {
    let onFinish: () -> Void

    @Environment(AppDataStore.self) private var store

    enum Step { case assessment, hairAnalysis, planResults }
    @State private var step: Step = .assessment

    var body: some View {
        Group {
            switch step {
            case .assessment:
                AssessmentView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step = .hairAnalysis
                    }
                }
            case .hairAnalysis:
                HairAnalysisView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step = .planResults
                    }
                }
            case .planResults:
                PlanResultsView {
                    onFinish()
                }
            }
        }
        .onAppear {
            // Clear old answers so the user starts fresh
            store.startAssessment()
        }
    }
}
