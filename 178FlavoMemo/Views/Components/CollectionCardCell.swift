//
//  CollectionCardCell.swift
//  178FlavoMemo
//

import SwiftUI

/// Custom card cell for tasting collections.
struct CollectionCardCell: View {
    let name: String
    let count: Int
    var onEdit: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppGradients.secondaryButton)
                    .frame(width: 52, height: 52)
                Image(systemName: "folder.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.background)
            }
            .compositingGroup()
            .shadow(color: AppColors.accent.opacity(0.2), radius: 3, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)

                HStack(spacing: 6) {
                    Image(systemName: "cup.and.saucer")
                        .font(.caption2)
                    Text("\(count) tasting\(count == 1 ? "" : "s")")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
        }
        .padding(14)
        .appListCardSurface()
    }
}
