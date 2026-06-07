//
//  TastingCardCell.swift
//  178FlavoMemo
//

import SwiftUI

/// Custom card cell for tasting list and calendar views.
struct TastingCardCell: View {
    let tasting: TastingModel
    var showChevron: Bool = true
    var onFavoriteTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            DrinkTypeIcon(type: tasting.type, size: 58, photoFileName: tasting.photoFileName)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text(tasting.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)

                    Spacer(minLength: 4)

                    if let onFavoriteTap {
                        Button(action: onFavoriteTap) {
                            Image(systemName: tasting.isFavorite ? "star.fill" : "star")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppColors.accent)
                                .padding(4)
                        }
                        .buttonStyle(.plain)
                    } else if tasting.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.accent)
                    }
                }

                HStack(spacing: 8) {
                    DrinkTypeBadge(type: tasting.type, compact: true)
                    RatingBadge(rating: tasting.rating)
                }

                if !tasting.flavorTags.isEmpty {
                    FlavorTagListView(tags: tasting.flavorTags)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(DateFormatting.formatTastingDate(tasting.date))
                        .font(.caption)
                        .lineLimit(1)

                    if let location = tasting.location, !location.isEmpty {
                        Text("•")
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(location)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(AppColors.secondaryText)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.secondaryText.opacity(0.7))
            }
        }
        .padding(14)
        .appListCardSurface()
    }
}

#Preview {
    TastingCardCell(
        tasting: TastingModel(
            name: "Ethiopian Yirgacheffe",
            type: .coffee,
            variety: "Single Origin",
            rating: 5,
            flavorNotes: "Floral",
            flavorTags: [.floral, .citrus],
            location: "Home",
            date: Date(),
            isFavorite: true
        ),
        onFavoriteTap: {}
    )
    .padding()
    .background(AppColors.background)
}
