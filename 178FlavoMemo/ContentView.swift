//
//  ContentView.swift
//  178FlavoMemo
//
//  Created by Roman on 5/31/26.
//

import SwiftUI

/// Root SwiftUI entry point hosted by UIKit SceneDelegate.
struct ContentView: View {
    @StateObject private var viewModel = TastingViewModel()
    @State private var selectedTab = 0
    @State private var showOnboarding = !OnboardingService.shared.hasCompletedOnboarding

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.cardBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.35), value: showOnboarding)
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            TastingListView(viewModel: viewModel)
                .tabItem {
                    Label("Tastings", systemImage: "cup.and.saucer.fill")
                }
                .tag(1)

            InsightsView(viewModel: viewModel)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(2)

            LibraryHubView(viewModel: viewModel)
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(3)

            ToolsHubView(viewModel: viewModel)
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
                .tag(4)
        }
        .tint(AppColors.accent)
    }
}

#Preview {
    ContentView()
}
