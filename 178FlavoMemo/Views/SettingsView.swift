//
//  SettingsView.swift
//  178FlavoMemo
//

import StoreKit
import SwiftUI
import UIKit

/// App settings screen with review and legal links.
struct SettingsView: View {
    var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 14) {
                    settingsSection(title: "Support") {
                        SettingsActionRow(
                            icon: "star.fill",
                            title: "Rate Us",
                            subtitle: "Enjoying the app? Leave a review.",
                            tint: AppColors.accent
                        ) {
                            rateApp()
                        }
                    }

                    settingsSection(title: "Legal") {
                        SettingsActionRow(
                            icon: "hand.raised.fill",
                            title: AppLinks.privacyPolicy.title,
                            subtitle: "How we handle your data",
                            tint: AppColors.success
                        ) {
                            openLink(.privacyPolicy)
                        }

                        SettingsActionRow(
                            icon: "doc.text.fill",
                            title: AppLinks.termsOfUse.title,
                            subtitle: "Terms and conditions",
                            tint: Color(hex: 0x7B8CFF)
                        ) {
                            openLink(.termsOfUse)
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: title)
            content()
        }
    }

    private func openLink(_ link: AppLinks) {
        if let url = URL(string: link.urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

/// Tappable settings row styled as a custom cell.
private struct SettingsActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AppMenuCell(icon: icon, title: title, subtitle: subtitle, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
