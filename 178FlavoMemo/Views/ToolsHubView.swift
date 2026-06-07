//
//  ToolsHubView.swift
//  178FlavoMemo
//

import SwiftUI

/// Hub screen for compare, backup, and reminder tools.
struct ToolsHubView: View {
    @ObservedObject var viewModel: TastingViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                VStack(spacing: 14) {
                    NavigationLink {
                        CompareView(viewModel: viewModel)
                    } label: {
                        AppMenuCell(
                            icon: "rectangle.split.2x1.fill",
                            title: "Compare Tastings",
                            subtitle: "Side-by-side rating and notes",
                            tint: Color(hex: 0x7B8CFF)
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ExportImportView(viewModel: viewModel)
                    } label: {
                        AppMenuCell(
                            icon: "square.and.arrow.up.on.square.fill",
                            title: "Backup & Restore",
                            subtitle: "Export JSON / CSV, import backup",
                            tint: AppColors.success
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        RemindersSettingsView(viewModel: viewModel)
                    } label: {
                        AppMenuCell(
                            icon: "bell.badge.fill",
                            title: "Reminders",
                            subtitle: viewModel.reminderSettings.isEnabled ? "Daily reminder enabled" : "Daily reminder disabled",
                            tint: AppColors.accent
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SettingsView()
                    } label: {
                        AppMenuCell(
                            icon: "gearshape.fill",
                            title: "Settings",
                            subtitle: "Rate us, privacy and terms",
                            tint: Color(hex: 0x9AA0B5)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .appHubNavigationStyle(title: "Tools")
        }
    }
}

#Preview {
    ToolsHubView(viewModel: TastingViewModel())
}
