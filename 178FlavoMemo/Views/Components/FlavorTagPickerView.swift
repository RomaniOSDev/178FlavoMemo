//
//  FlavorTagPickerView.swift
//  178FlavoMemo
//

import SwiftUI

/// Multi-select chip picker for flavor descriptor tags.
struct FlavorTagPickerView: View {
    @Binding var selectedTags: [FlavorTag]

    private let columns = [
        GridItem(.adaptive(minimum: 96), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(FlavorTag.allCases) { tag in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        toggle(tag)
                    }
                } label: {
                    Text(tag.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected(tag) ? AppColors.background : AppColors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .background {
                            if isSelected(tag) {
                                Capsule().fill(AppGradients.secondaryButton)
                            } else {
                                Capsule().fill(AppColors.background.opacity(0.35))
                            }
                        }
                        .overlay(
                            Capsule()
                                .stroke(AppColors.accent.opacity(isSelected(tag) ? 0 : 0.35), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func isSelected(_ tag: FlavorTag) -> Bool {
        selectedTags.contains(tag)
    }

    private func toggle(_ tag: FlavorTag) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
}

/// Read-only tag chips for list and detail views.
struct FlavorTagListView: View {
    let tags: [FlavorTag]

    var body: some View {
        if tags.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tags) { tag in
                        Text(tag.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppColors.background)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(AppGradients.accentBadge)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    FlavorTagPickerView(selectedTags: .constant([.fruity, .floral]))
        .padding()
        .background(AppColors.background)
}
