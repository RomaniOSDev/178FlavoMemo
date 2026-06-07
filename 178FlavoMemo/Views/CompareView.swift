//
//  CompareView.swift
//  178FlavoMemo
//

import SwiftUI

/// Side-by-side comparison of two tasting records.
struct CompareView: View {
    @ObservedObject var viewModel: TastingViewModel

    var body: some View {
        ZStack {
            AppScreenBackground()

            if viewModel.tastings.count < 2 {
                AppEmptyStateView(
                    icon: "rectangle.split.2x1",
                    title: "Need at least 2 tastings",
                    subtitle: "Add more tastings to compare them side by side."
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        selectionHeader
                        selectionList

                        if viewModel.compareTastings.count == 2 {
                            comparisonGrid
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .toolbar {
            if !viewModel.compareSelection.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { viewModel.clearCompareSelection() }
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    private var selectionHeader: some View {
        AppElevatedCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    AppSectionHeader(title: "Select Two Tastings")
                    Text("\(viewModel.compareSelection.count)/2 selected")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(viewModel.compareSelection.count == 2 ? AppColors.success : AppColors.secondaryText)
            }
        }
    }

    private var selectionList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.tastings.sorted(by: { $0.date > $1.date })) { tasting in
                Button { viewModel.toggleCompareSelection(tasting.id) } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    viewModel.compareSelection.contains(tasting.id)
                                        ? AnyShapeStyle(AppGradients.primaryButton)
                                        : AnyShapeStyle(AppColors.cardBackground)
                                )
                                .frame(width: 28, height: 28)
                            Image(systemName: viewModel.compareSelection.contains(tasting.id) ? "checkmark" : "circle")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(viewModel.compareSelection.contains(tasting.id) ? .white : AppColors.secondaryText)
                        }

                        TastingCardCell(tasting: tasting, showChevron: false)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var comparisonGrid: some View {
        let items = viewModel.compareTastings

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Comparison Result")

            HStack(alignment: .top, spacing: 10) {
                compareColumn(tasting: items[0], highlight: items[0].rating >= items[1].rating)
                compareColumn(tasting: items[1], highlight: items[1].rating >= items[0].rating)
            }
        }
    }

    private func compareColumn(tasting: TastingModel, highlight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            DrinkTypeIcon(type: tasting.type, size: 44, photoFileName: tasting.photoFileName)

            Text(tasting.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)

            compareRow("Rating", value: "\(tasting.rating)/5", winner: highlight)
            compareRow("Type", value: tasting.type.rawValue, winner: false)
            compareRow("Date", value: DateFormatting.formatTastingDate(tasting.date), winner: false)

            if !tasting.flavorTags.isEmpty {
                compareRow("Tags", value: tasting.flavorTags.map(\.rawValue).joined(separator: ", "), winner: false)
            }
            if !tasting.flavorNotes.isEmpty {
                compareRow("Notes", value: tasting.flavorNotes, winner: false)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(highlight ? AppColors.success.opacity(0.7) : AppColors.accent.opacity(0.15), lineWidth: highlight ? 2 : 1)
        )
    }

    private func compareRow(_ title: String, value: String, winner: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(winner ? AppColors.success : AppColors.accent)
            Text(value)
                .font(.caption)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        CompareView(viewModel: TastingViewModel())
    }
}
