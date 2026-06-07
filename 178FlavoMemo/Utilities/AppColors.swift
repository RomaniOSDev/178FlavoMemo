//
//  AppColors.swift
//  178FlavoMemo
//

import SwiftUI

/// Centralized palette for light and dark appearance.
enum AppColors {
    static let background = Color("AppBackground")
    static let accent = Color("AppAccent")
    static let success = Color("AppSuccess")
    static let cardBackground = Color("AppCardBackground")
    static let primaryText = Color("AppPrimaryText")
    static let secondaryText = Color("AppSecondaryText")
}

/// Static gradients reused across the app to avoid runtime allocation in lists.
enum AppGradients {
    static func screenBase(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: 0x3E4464),
                Color(hex: 0x363B58),
                Color(hex: 0x3E4464)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func screenDepth(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: 0x3CC45B, opacity: 0.07),
                Color.clear,
                Color(hex: 0xFCC418, opacity: 0.06)
            ],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }

    static func screenVignette(for scheme: ColorScheme) -> RadialGradient {
        RadialGradient(
            colors: [Color.clear, Color(hex: 0x151822, opacity: 0.45)],
            center: .center,
            startRadius: 80,
            endRadius: 520
        )
    }

    static func screenOrbGold(for scheme: ColorScheme) -> RadialGradient {
        RadialGradient(
            colors: [
                Color(hex: 0xFCC418, opacity: 0.20),
                Color(hex: 0xFCC418, opacity: 0.05),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 180
        )
    }

    static func screenOrbGreen(for scheme: ColorScheme) -> RadialGradient {
        RadialGradient(
            colors: [
                Color(hex: 0x3CC45B, opacity: 0.16),
                Color(hex: 0x3CC45B, opacity: 0.04),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 160
        )
    }

    static func screenOrbWine(for scheme: ColorScheme) -> RadialGradient {
        RadialGradient(
            colors: [
                Color(hex: 0xA63D56, opacity: 0.12),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 120
        )
    }

    static let cardBorder = LinearGradient(
        colors: [Color(hex: 0xFCC418, opacity: 0.45), Color(hex: 0xFCC418, opacity: 0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardFill = LinearGradient(
        colors: [Color(hex: 0xFFFFFF, opacity: 0.04), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [Color(hex: 0x52D86F), Color(hex: 0x3CC45B)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryButton = LinearGradient(
        colors: [Color(hex: 0xFFD84D), Color(hex: 0xFCC418)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentBadge = LinearGradient(
        colors: [Color(hex: 0xFFD84D), Color(hex: 0xFCC418)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let iconWell = LinearGradient(
        colors: [Color(hex: 0xFCC418, opacity: 0.24), Color(hex: 0xFCC418, opacity: 0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Shadow presets tuned for performance in scrollable lists.
enum AppCardElevation {
    case list
    case standard
    case hero

    var shadowOpacity: Double {
        switch self {
        case .list: return 0.07
        case .standard: return 0.11
        case .hero: return 0.16
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .list: return 4
        case .standard: return 8
        case .hero: return 12
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .list: return 2
        case .standard: return 4
        case .hero: return 6
        }
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension View {
    /// Applies an optimized card surface with one composited shadow pass.
    func appCardSurface(
        cornerRadius: CGFloat = 18,
        elevation: AppCardElevation = .standard,
        showTopSheen: Bool = true
    ) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppColors.cardBackground)
                .overlay {
                    if showTopSheen {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AppGradients.cardFill)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppGradients.cardBorder, lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compositingGroup()
        .shadow(
            color: .black.opacity(elevation.shadowOpacity),
            radius: elevation.shadowRadius,
            x: 0,
            y: elevation.shadowY
        )
    }

    /// Lightweight card styling for long scrolling lists.
    func appListCardSurface(cornerRadius: CGFloat = 18) -> some View {
        appCardSurface(cornerRadius: cornerRadius, elevation: .list, showTopSheen: false)
    }
}
