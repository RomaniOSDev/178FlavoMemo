//
//  OnboardingView.swift
//  178FlavoMemo
//

import SwiftUI
import UIKit

/// Three-screen first-run onboarding shown once before the main app.
struct OnboardingView: View {
    @Binding var isPresented: Bool

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "HomeHero",
            imageStyle: .hero,
            title: "Your Flavor Journal",
            subtitle: "Log every coffee, wine, and tea tasting in one beautiful place.",
            highlights: ["Coffee", "Wine", "Tea"]
        ),
        OnboardingPage(
            imageName: nil,
            imageStyle: .featureIcons(["star.fill", "tag.fill", "photo.on.rectangle.angled"]),
            title: "Capture Every Detail",
            subtitle: "Rate drinks, tag flavor notes, attach photos, and save tasting memories.",
            highlights: ["Ratings", "Flavor Tags", "Photos"]
        ),
        OnboardingPage(
            imageName: nil,
            imageStyle: .featureIcons(["chart.bar.fill", "folder.fill", "bell.fill"]),
            title: "Discover & Organize",
            subtitle: "Track insights, build collections, use templates, and stay inspired.",
            highlights: ["Insights", "Collections", "Reminders"]
        )
    ]

    var body: some View {
        ZStack {
            AppScreenBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") { finishOnboarding() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.accent)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .background(AppColors.background)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(PageTabViewBackgroundClearer())
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                pageIndicator
                    .padding(.top, 4)

                Group {
                    if currentPage == pages.count - 1 {
                        Button("Get Started") { advance() }
                            .buttonStyle(AppPrimaryButtonStyle())
                    } else {
                        Button("Next") { advance() }
                            .buttonStyle(AppSecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(AppGradients.secondaryButton)
                            : AnyShapeStyle(AppColors.secondaryText.opacity(0.30))
                    )
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        OnboardingService.shared.completeOnboarding()
        withAnimation(.easeInOut(duration: 0.35)) {
            isPresented = false
        }
    }
}

// MARK: - Page model

private struct OnboardingPage {
    enum ImageStyle {
        case hero
        case featureIcons([String])
    }

    let imageName: String?
    let imageStyle: ImageStyle
    let title: String
    let subtitle: String
    let highlights: [String]
}

// MARK: - Page view

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 20) {
            illustration

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            HStack(spacing: 8) {
                ForEach(page.highlights, id: \.self) { highlight in
                    Text(highlight)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(AppGradients.accentBadge)
                        .clipShape(Capsule())
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var illustration: some View {
        switch page.imageStyle {
        case .hero:
            if let imageName = page.imageName {
                ZStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.black.opacity(0.35), .clear, .black.opacity(0.25)],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )

                    HStack(spacing: 10) {
                        drinkPreview("WidgetCoffee")
                        drinkPreview("WidgetWine")
                        drinkPreview("WidgetTea")
                    }
                    .padding(.bottom, 16)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppGradients.cardBorder, lineWidth: 1)
                )
                .compositingGroup()
                .shadow(
                    color: .black.opacity(AppCardElevation.hero.shadowOpacity),
                    radius: AppCardElevation.hero.shadowRadius,
                    x: 0,
                    y: AppCardElevation.hero.shadowY
                )
            }

        case .featureIcons(let icons):
            HStack(spacing: 16) {
                ForEach(icons, id: \.self) { icon in
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(AppGradients.iconWell)
                            .frame(width: 88, height: 88)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(AppGradients.cardBorder, lineWidth: 1)
                            .frame(width: 88, height: 88)
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                    }
                    .compositingGroup()
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private func drinkPreview(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: 72, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.45), lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

/// Sets page-style TabView scroll surfaces to AppBackground instead of system white.
private struct PageTabViewBackgroundClearer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor(named: "AppBackground")
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let backgroundColor = UIColor(named: "AppBackground")
        DispatchQueue.main.async {
            var ancestor: UIView? = uiView.superview
            while let current = ancestor {
                if current is UIScrollView || current is UICollectionView {
                    current.backgroundColor = backgroundColor
                    current.subviews.forEach { $0.backgroundColor = backgroundColor }
                }
                ancestor = current.superview
            }
        }
    }
}
