//
//  TemplateCardCell.swift
//  178FlavoMemo
//

import SwiftUI

/// Custom card cell for drink templates.
struct TemplateCardCell: View {
    let template: DrinkTemplate

    var body: some View {
        HStack(spacing: 14) {
            DrinkTypeIcon(type: template.type, size: 52)

            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)

                HStack(spacing: 8) {
                    DrinkTypeBadge(type: template.type, compact: true)
                    if let method = template.brewMethod, !method.isEmpty {
                        Label(method, systemImage: "drop.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                if !template.flavorTags.isEmpty {
                    FlavorTagListView(tags: template.flavorTags)
                } else if !template.flavorNotes.isEmpty {
                    Text(template.flavorNotes)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
        }
        .padding(14)
        .appListCardSurface()
    }
}
