//
//  HairCureApp.swift
//  HairCure
//
//  Route order:
//  auth → profileSetup → assessment → hairAnalysis → planResults → mainApp
//

import SwiftUI

@main
struct Hair12App: App {
    @State private var store = AppDataStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(store.hairInsightsStore)
                .environment(store.dietMateStore)
                .environment(store.mindEaseStore)
        }
    }
}

enum AppRoute: Hashable {
    case auth
    case profileSetup
    case assessment
    case hairAnalysis
    case planResults
    case mainApp
}

struct ContentView: View {
    @State private var route: AppRoute = .auth

    var body: some View {
        Group {
            switch route {
            case .auth:
                AuthLandingView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .profileSetup }
                }
            case .profileSetup:
                ProfileSetupView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .assessment }
                }
                .transition(.opacity)
            case .assessment:
                AssessmentView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .hairAnalysis }
                }
                .transition(.opacity)
            case .hairAnalysis:
                HairAnalysisView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .planResults }
                }
                .transition(.opacity)
            case .planResults:
                PlanResultsView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .mainApp }
                }
                .transition(.opacity)
            case .mainApp:
                MainTabView()
                    .transition(.opacity)
            }
        }
    }
}
