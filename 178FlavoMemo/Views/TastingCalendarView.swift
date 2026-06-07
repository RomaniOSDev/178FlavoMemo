//
//  TastingCalendarView.swift
//  178FlavoMemo
//

import SwiftUI

/// Calendar-style grouped list of tastings by day.
struct TastingCalendarView: View {
    @ObservedObject var viewModel: TastingViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.calendarSections(), id: \.date) { section in
                    Section {
                        ForEach(section.items) { tasting in
                            NavigationLink {
                                TastingDetailView(viewModel: viewModel, tasting: tasting)
                            } label: {
                                TastingCardCell(tasting: tasting, showChevron: false)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    } header: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DateFormatting.formatSectionDate(section.date))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(AppColors.primaryText)
                                Text("\(section.items.count) tasting\(section.items.count == 1 ? "" : "s")")
                                    .font(.caption2)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundStyle(AppColors.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.cardBackground.opacity(0.92))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(AppGradients.cardBorder, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            AppScreenBackground()
            TastingCalendarView(viewModel: TastingViewModel())
        }
    }
}
