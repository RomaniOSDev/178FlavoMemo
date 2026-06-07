//
//  StarRatingView.swift
//  178FlavoMemo
//

import SwiftUI

/// Interactive star rating control (1–5).
struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var starSize: CGFloat = 24
    var interactive: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { index in
                Button {
                    guard interactive else { return }
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        rating = index
                    }
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: starSize))
                        .foregroundStyle(
                            index <= rating
                                ? AnyShapeStyle(AppGradients.accentBadge)
                                : AnyShapeStyle(AppColors.secondaryText.opacity(0.55))
                        )
                        .scaleEffect(index <= rating ? 1.05 : 1)
                }
                .buttonStyle(.plain)
                .disabled(!interactive)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maxRating)")
    }
}

#Preview {
    StarRatingView(rating: .constant(4))
        .padding()
        .background(AppColors.background)
}
