//
//  InsightsView.swift
//  178FlavoMemo
//

import SwiftUI

/// Statistics and summary screen.
struct InsightsView: View {
    @ObservedObject var viewModel: TastingViewModel

    private var data: InsightsData {
        viewModel.insights
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                if data.totalCount == 0 {
                    AppEmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "No data yet",
                        subtitle: "Add tastings to unlock personalized insights."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                AppStatTile(icon: "cup.and.saucer.fill", title: "Total", value: "\(data.totalCount)", tint: AppColors.accent)
                                AppStatTile(icon: "star.fill", title: "Avg Rating", value: String(format: "%.1f", data.averageRating), tint: AppColors.success)
                                AppStatTile(icon: "heart.fill", title: "Favorites", value: "\(data.favoriteCount)", tint: Color(hex: 0xE05A7A))
                                AppStatTile(icon: "tag.fill", title: "Top Tags", value: "\(data.topFlavorTags.count)", tint: Color(hex: 0x7B8CFF))
                            }

                            AppElevatedCard {
                                VStack(alignment: .leading, spacing: 14) {
                                    AppSectionHeader(title: "By Drink Type")
                                    AppProgressRow(label: "Coffee", count: data.coffeeCount, total: data.totalCount, tint: Color(hex: 0xC68E4A))
                                    AppProgressRow(label: "Wine", count: data.wineCount, total: data.totalCount, tint: Color(hex: 0xA63D56))
                                    AppProgressRow(label: "Tea", count: data.teaCount, total: data.totalCount, tint: Color(hex: 0x4FAF7A))
                                }
                            }

                            if let best = data.bestTasting {
                                AppElevatedCard {
                                    HStack(spacing: 14) {
                                        DrinkTypeIcon(type: best.type, size: 56, photoFileName: best.photoFileName)
                                        VStack(alignment: .leading, spacing: 8) {
                                            AppSectionHeader(title: "Best Rated")
                                            Text(best.name)
                                                .font(.headline)
                                                .foregroundStyle(AppColors.primaryText)
                                            StarRatingView(rating: .constant(best.rating), starSize: 16, interactive: false)
                                        }
                                    }
                                }
                            }

                            if let last = data.lastTasting {
                                AppElevatedCard {
                                    HStack(spacing: 14) {
                                        DrinkTypeIcon(type: last.type, size: 56, photoFileName: last.photoFileName)
                                        VStack(alignment: .leading, spacing: 8) {
                                            AppSectionHeader(title: "Last Tasting")
                                            Text(last.name)
                                                .font(.headline)
                                                .foregroundStyle(AppColors.primaryText)
                                            Text(DateFormatting.formatTastingDate(last.date))
                                                .font(.caption)
                                                .foregroundStyle(AppColors.secondaryText)
                                        }
                                    }
                                }
                            }

                            if !data.topFlavorTags.isEmpty {
                                AppElevatedCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        AppSectionHeader(title: "Top Flavor Tags")
                                        ForEach(data.topFlavorTags, id: \.tag.id) { item in
                                            HStack {
                                                Text(item.tag.rawValue)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(AppColors.background)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(AppGradients.accentBadge)
                                                    .clipShape(Capsule())
                                                Spacer()
                                                Text("\(item.count)")
                                                    .font(.headline.weight(.bold))
                                                    .foregroundStyle(AppColors.accent)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .appHubNavigationStyle(title: "Insights")
        }
    }
}

#Preview {
    InsightsView(viewModel: TastingViewModel())
}
