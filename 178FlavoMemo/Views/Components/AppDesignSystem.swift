//
//  AppDesignSystem.swift
//  178FlavoMemo
//

import SwiftUI

// MARK: - Drink type styling

extension DrinkType {
    var iconName: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .wine: return "wineglass.fill"
        case .tea: return "leaf.fill"
        }
    }

    var accentGradient: LinearGradient {
        switch self {
        case .coffee:
            return LinearGradient(
                colors: [Color(hex: 0x8B5A2B), Color(hex: 0xC68E4A)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .wine:
            return LinearGradient(
                colors: [Color(hex: 0x6B2737), Color(hex: 0xA63D56)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .tea:
            return LinearGradient(
                colors: [Color(hex: 0x2F6B4F), Color(hex: 0x4FAF7A)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Screen chrome

/// Lightweight ambient background — gradients + orbs, rasterized once via drawingGroup.
struct AppScreenBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppColors.background

            AppGradients.screenBase(for: colorScheme)
            AppGradients.screenDepth(for: colorScheme)

            GeometryReader { geo in
                ZStack {
                    orb(AppGradients.screenOrbGold(for: colorScheme), size: geo.size.width * 0.72)
                        .position(x: geo.size.width * 0.12, y: geo.size.height * 0.08)

                    orb(AppGradients.screenOrbGreen(for: colorScheme), size: geo.size.width * 0.65)
                        .position(x: geo.size.width * 0.92, y: geo.size.height * 0.78)

                    orb(AppGradients.screenOrbWine(for: colorScheme), size: geo.size.width * 0.48)
                        .position(x: geo.size.width * 0.78, y: geo.size.height * 0.28)

                    orb(
                        RadialGradient(
                            colors: [
                                Color(hex: 0x4FAF7A, opacity: colorScheme == .dark ? 0.10 : 0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        ),
                        size: geo.size.width * 0.38
                    )
                    .position(x: geo.size.width * 0.08, y: geo.size.height * 0.62)
                }
            }

            AppBackgroundDotPattern(colorScheme: colorScheme)
            AppGradients.screenVignette(for: colorScheme)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }

    private func orb(_ gradient: RadialGradient, size: CGFloat) -> some View {
        Circle()
            .fill(gradient)
            .frame(width: size, height: size)
    }
}

/// Subtle dot grid for texture — drawn once and composited with the screen background.
private struct AppBackgroundDotPattern: View {
    let colorScheme: ColorScheme

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 22
            let dotSize: CGFloat = 1.1
            let dotColor = Color.white.opacity(0.04)

            for x in stride(from: spacing * 0.5, through: size.width, by: spacing) {
                for y in stride(from: spacing * 0.5, through: size.height, by: spacing) {
                    let rect = CGRect(
                        x: x - dotSize * 0.5,
                        y: y - dotSize * 0.5,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct AppEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconWell)
                    .frame(width: 92, height: 92)
                Circle()
                    .stroke(AppGradients.cardBorder, lineWidth: 1)
                    .frame(width: 92, height: 92)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(AppSecondaryButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Cards & badges

struct AppElevatedCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .appCardSurface(elevation: .standard)
    }
}

struct DrinkTypeBadge: View {
    let type: DrinkType
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: type.iconName)
                .font(compact ? .caption2.weight(.bold) : .caption.weight(.bold))
            Text(type.rawValue)
                .font(compact ? .caption2.weight(.bold) : .caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(type.accentGradient)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.22), lineWidth: 0.5)
        )
    }
}

struct DrinkTypeIcon: View {
    let type: DrinkType
    var size: CGFloat = 52
    var photoFileName: String?

    var body: some View {
        Group {
            if let photoFileName,
               let image = PhotoStorageService.shared.loadPhoto(fileName: photoFileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    type.accentGradient
                    Image(systemName: type.iconName)
                        .font(.system(size: size * 0.38, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.45), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
    }
}

struct RatingBadge: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2.weight(.bold))
            Text("\(rating)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(AppColors.background)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(AppGradients.accentBadge)
        .clipShape(Capsule())
    }
}

// MARK: - Hub & menu cells

struct AppMenuCell: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.28), tint.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.8))
        }
        .padding(14)
        .appCardSurface(elevation: .standard)
    }
}

// MARK: - Insights

struct AppStatTile: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        AppElevatedCard {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
            }
        }
    }
}

struct AppProgressRow: View {
    let label: String
    let count: Int
    let total: Int
    let tint: Color

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
                Text("\(count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.background.opacity(0.35))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.85), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * progress, progress > 0 ? 8 : 0))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Filter bar

struct AppFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? AppColors.background : AppColors.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(AppGradients.secondaryButton)
                    } else {
                        Capsule().fill(AppColors.cardBackground)
                    }
                }
                .overlay(
                    Capsule()
                        .stroke(AppColors.accent.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct AppSegmentedPicker<T: Hashable & Identifiable>: View where T: RawRepresentable, T.RawValue == String {
    let options: [T]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selection == option ? AppColors.background : AppColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selection == option {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppGradients.secondaryButton)
                                    .padding(3)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppGradients.cardBorder, lineWidth: 1)
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct DetailInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconWell)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
                Text(value)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

struct FormSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: title)
            content
        }
        .padding(16)
        .appCardSurface(elevation: .standard, showTopSheen: false)
    }
}

/// Shared navigation bar styling for all stacks.
struct AppNavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(AppColors.cardBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func appNavigationBarStyle() -> some View {
        modifier(AppNavigationBarStyle())
    }

    /// Compact inline title for hub screens — avoids extra ScrollView top inset with large titles.
    func appHubNavigationStyle(title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBarStyle()
    }
}
