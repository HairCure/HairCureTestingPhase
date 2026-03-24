//
//  HairCureApp.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
////
////  HairCureApp.swift
////  HairCure
////
////  @main entry point. Injects AppDataStore into the environment.
////  ContentView drives the top-level navigation state:
////    auth  →  assessment  →  mainApp
////
//
//import SwiftUI
//
//@main
//struct HairCureApp: App {
//    @State private var store = AppDataStore()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(store)
//        }
//    }
//}
//
//// MARK: - App Route
//
//enum AppRoute: Hashable {
//    case auth
//    case assessment
//    case mainApp
//}
//
//// MARK: - Content View (root navigator)
//
//struct ContentView: View {
//    @State private var route: AppRoute = .auth
//
//    var body: some View {
//        Group {
//            switch route {
//            case .auth:
//                AuthLandingView {
//                    withAnimation(.easeInOut(duration: 0.35)) {
//                        route = .assessment
//                    }
//                }
//
//            case .assessment:
//                AssessmentView {
//                    withAnimation(.easeInOut(duration: 0.35)) {
//                        route = .mainApp
//                    }
//                }
//
//            case .mainApp:
//                MainTabView()
//                    .transition(.opacity)
//            }
//        }
//    }
//}

//  HairCureApp.swift
//  HairCure
//
//  @main entry point.
//
//  Navigation flow:
//    auth → assessment → hairAnalysis → planResults → mainApp
//
//
//  HairCureApp.swift
//  HairCure
//
//  Route order: auth → assessment → hairAnalysis → planResults → mainApp
//

import SwiftUI

@main
struct HairCureApp: App {
    @State private var store = AppDataStore()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(store)
        }
    }
}

enum AppRoute: Hashable {
    case auth
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
                    withAnimation(.easeInOut(duration: 0.3)) { route = .assessment }
                }
            case .assessment:
                AssessmentView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .hairAnalysis }
                }
            case .hairAnalysis:
                HairAnalysisView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .planResults }
                }
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
//
//  HairCureApp.swift
//  HairCure
//
//  @main entry point.
//  Route order:  auth → assessment → hairAnalysis → mainApp
//
//
//import SwiftUI
//
//@main
//struct HairCureApp: App {
//    @State private var store = AppDataStore()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(store)
//        }
//    }
//}
//
//enum AppRoute: Hashable {
//    case auth
//    case assessment
//    case hairAnalysis
//    case mainApp
//}
//
//struct ContentView: View {
//    @State private var route: AppRoute = .auth
//
//    var body: some View {
//        Group {
//            switch route {
//            case .auth:
//                AuthLandingView {
//                    withAnimation(.easeInOut(duration: 0.3)) { route = .assessment }
//                }
//            case .assessment:
//                AssessmentView {
//                    withAnimation(.easeInOut(duration: 0.3)) { route = .hairAnalysis }
//                }
//            case .hairAnalysis:
//                HairAnalysisView {
//                    withAnimation(.easeInOut(duration: 0.3)) { route = .mainApp }
//                }
//            case .mainApp:
//                MainTabView()
//                    .transition(.opacity)
//            }
//        }
//    }
//}
