//
//  FormStyles.swift
//  178FlavoMemo
//

import SwiftUI

/// Styled text field matching the app palette.
struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppColors.background.opacity(0.35))
            .foregroundStyle(AppColors.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppGradients.cardBorder, lineWidth: 1)
            )
    }
}

/// Green save button style.
struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppGradients.primaryButton.opacity(configuration.isPressed ? 0.88 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .compositingGroup()
            .shadow(
                color: AppColors.success.opacity(configuration.isPressed ? 0.18 : 0.32),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 3
            )
    }
}

/// Yellow cancel button style.
struct AppSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppGradients.secondaryButton.opacity(configuration.isPressed ? 0.88 : 1))
            .foregroundStyle(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .compositingGroup()
            .shadow(
                color: AppColors.accent.opacity(configuration.isPressed ? 0.16 : 0.28),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 3
            )
    }
}

/// Reusable section header for forms and detail screens.
struct AppSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppColors.accent)
            .textCase(.uppercase)
            .tracking(0.4)
    }
}

/// Card container used on detail and insights screens.
struct AppCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        AppElevatedCard {
            content
        }
    }
}
