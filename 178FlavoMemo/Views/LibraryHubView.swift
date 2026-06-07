//
//  LibraryHubView.swift
//  178FlavoMemo
//

import SwiftUI

/// Hub screen for templates and collections.
struct LibraryHubView: View {
    @ObservedObject var viewModel: TastingViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                VStack(spacing: 14) {
                    NavigationLink {
                        TemplatesListView(viewModel: viewModel)
                    } label: {
                        AppMenuCell(
                            icon: "doc.text.fill",
                            title: "Templates",
                            subtitle: "\(viewModel.templates.count) saved presets",
                            tint: AppColors.accent
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        CollectionsListView(viewModel: viewModel)
                    } label: {
                        AppMenuCell(
                            icon: "folder.fill",
                            title: "Collections",
                            subtitle: "\(viewModel.collections.count) tasting groups",
                            tint: AppColors.success
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .appHubNavigationStyle(title: "Library")
        }
    }
}

#Preview {
    LibraryHubView(viewModel: TastingViewModel())
}
