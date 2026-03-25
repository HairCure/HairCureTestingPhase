//
//  MainTabView.swift
//  HairCureTesting1
//
//  4 tabs:  0 — Home  |  1 — Wellness  |  2 — Hair Insights  |  3 — Profile
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            WellnessView()
                .tabItem { Label("Wellness", systemImage: "heart.fill") }
                .tag(1)

            HairInsightsView()
                .tabItem { Label("Hair Insights", systemImage: "lightbulb.fill") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .accentColor(Color.hcBrown)
    }
}

#Preview {
    MainTabView()
        .environment(AppDataStore())
        
}
