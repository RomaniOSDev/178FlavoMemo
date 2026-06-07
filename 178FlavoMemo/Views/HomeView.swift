//
//  HomeView.swift
//  178FlavoMemo
//

import SwiftUI

/// Dashboard home screen with widgets, quick actions, and recent activity.
struct HomeView: View {
    @ObservedObject var viewModel: TastingViewModel
    @Binding var selectedTab: Int

    @State private var showingAddForm = false
    @State private var showingTemplatePicker = false

    private var insights: InsightsData {
        viewModel.insights
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroBanner
                        statsWidgetGrid
                        quickActionsWidget
                        drinkTypeWidgets
                        recentTastingsWidget
                        favoritesWidget
                        topFlavorsWidget
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .scrollContentBackground(.hidden)
            }
            .appHubNavigationStyle(title: "Home")
            .sheet(isPresented: $showingAddForm) {
                TastingFormView(viewModel: viewModel, mode: .add)
            }
            .sheet(isPresented: $showingTemplatePicker) {
                HomeTemplatePickerView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.55), .clear, .black.opacity(0.35)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Capture today's flavors and aromas")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                Button {
                    showingAddForm = true
                } label: {
                    Label("Log Tasting", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(AppGradients.secondaryButton)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.25), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
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

    // MARK: - Stats

    private var statsWidgetGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            HomeStatWidget(
                icon: "cup.and.saucer.fill",
                title: "Total",
                value: "\(insights.totalCount)",
                tint: AppColors.accent
            )
            HomeStatWidget(
                icon: "star.fill",
                title: "Avg Rating",
                value: insights.totalCount == 0 ? "—" : String(format: "%.1f", insights.averageRating),
                tint: AppColors.success
            )
            HomeStatWidget(
                icon: "calendar",
                title: "This Month",
                value: "\(viewModel.tastingsThisMonth)",
                tint: Color(hex: 0x7B8CFF)
            )
            HomeStatWidget(
                icon: "heart.fill",
                title: "Favorites",
                value: "\(insights.favoriteCount)",
                tint: Color(hex: 0xE05A7A)
            )
        }
    }

    // MARK: - Quick Actions

    private var quickActionsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader(title: "Quick Actions", icon: "bolt.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    HomeQuickActionButton(title: "Add", icon: "plus", tint: AppColors.success) {
                        showingAddForm = true
                    }
                    HomeQuickActionButton(title: "Template", icon: "doc.text", tint: AppColors.accent) {
                        showingTemplatePicker = true
                    }
                    HomeQuickActionButton(title: "Insights", icon: "chart.bar", tint: Color(hex: 0x7B8CFF)) {
                        selectedTab = 2
                    }
                    HomeQuickActionButton(title: "Library", icon: "books.vertical", tint: Color(hex: 0x4FAF7A)) {
                        selectedTab = 3
                    }
                    HomeQuickActionButton(title: "Tools", icon: "wrench.and.screwdriver", tint: Color(hex: 0x9AA0B5)) {
                        selectedTab = 4
                    }
                }
            }
        }
    }

    // MARK: - Drink Types

    private var drinkTypeWidgets: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader(title: "Your Drinks", icon: "drop.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HomeDrinkTypeWidget(
                        imageName: "WidgetCoffee",
                        title: "Coffee",
                        count: viewModel.count(for: .coffee),
                        tint: Color(hex: 0xC68E4A)
                    ) {
                        openTastings(filter: .drinkType(.coffee))
                    }

                    HomeDrinkTypeWidget(
                        imageName: "WidgetWine",
                        title: "Wine",
                        count: viewModel.count(for: .wine),
                        tint: Color(hex: 0xA63D56)
                    ) {
                        openTastings(filter: .drinkType(.wine))
                    }

                    HomeDrinkTypeWidget(
                        imageName: "WidgetTea",
                        title: "Tea",
                        count: viewModel.count(for: .tea),
                        tint: Color(hex: 0x4FAF7A)
                    ) {
                        openTastings(filter: .drinkType(.tea))
                    }
                }
            }
        }
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentTastingsWidget: some View {
        if viewModel.recentTastings.isEmpty {
            AppElevatedCard {
                VStack(alignment: .leading, spacing: 10) {
                    widgetHeader(title: "Recent Tastings", icon: "clock.fill")
                    Text("No tastings yet. Start your flavor journal today.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                    Button("Add First Tasting") { showingAddForm = true }
                        .buttonStyle(AppSecondaryButtonStyle())
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    widgetHeader(title: "Recent Tastings", icon: "clock.fill")
                    Spacer()
                    Button("See All") { openTastings(filter: .all) }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.accent)
                }

                ForEach(viewModel.recentTastings.prefix(3)) { tasting in
                    NavigationLink {
                        TastingDetailView(viewModel: viewModel, tasting: tasting)
                    } label: {
                        TastingCardCell(tasting: tasting, showChevron: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Favorites

    @ViewBuilder
    private var favoritesWidget: some View {
        if !viewModel.favoriteTastings.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    widgetHeader(title: "Favorites", icon: "star.fill")
                    Spacer()
                    Button("See All") { openTastings(filter: .favorites) }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.accent)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.favoriteTastings.prefix(5)) { tasting in
                            NavigationLink {
                                TastingDetailView(viewModel: viewModel, tasting: tasting)
                            } label: {
                                HomeFavoriteMiniCard(tasting: tasting)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Top Flavors

    @ViewBuilder
    private var topFlavorsWidget: some View {
        if !insights.topFlavorTags.isEmpty {
            AppElevatedCard {
                VStack(alignment: .leading, spacing: 12) {
                    widgetHeader(title: "Top Flavor Notes", icon: "tag.fill")

                    ForEach(insights.topFlavorTags.prefix(3), id: \.tag.id) { item in
                        HStack {
                            Text(item.tag.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
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

    // MARK: - Helpers

    private func widgetHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconWell)
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.accent)
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.primaryText)
        }
    }

    private func openTastings(filter: ListFilter) {
        viewModel.selectedFilter = filter
        selectedTab = 1
    }
}

// MARK: - Home Widget Components

private struct HomeStatWidget: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        AppElevatedCard {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.caption.weight(.bold))
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

private struct HomeQuickActionButton: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(width: 78)
            .padding(.vertical, 10)
            .appListCardSurface(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeDrinkTypeWidget: View {
    let imageName: String
    let title: String
    let count: Int
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 100)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColors.primaryText)
                    Text("\(count) tasting\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
            }
            .frame(width: 140)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [tint.opacity(0.55), tint.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .compositingGroup()
            .shadow(
                color: .black.opacity(AppCardElevation.standard.shadowOpacity),
                radius: AppCardElevation.standard.shadowRadius,
                x: 0,
                y: AppCardElevation.standard.shadowY
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HomeFavoriteMiniCard: View {
    let tasting: TastingModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let photoFileName = tasting.photoFileName,
               let image = PhotoStorageService.shared.loadPhoto(fileName: photoFileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .clipped()
            } else {
                Image(drinkImageName(for: tasting.type))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .clipped()
            }

            Text(tasting.name)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .frame(width: 120)
        .appListCardSurface(cornerRadius: 14)
    }

    private func drinkImageName(for type: DrinkType) -> String {
        switch type {
        case .coffee: return "WidgetCoffee"
        case .wine: return "WidgetWine"
        case .tea: return "WidgetTea"
        }
    }
}

/// Compact template picker used from the home screen.
private struct HomeTemplatePickerView: View {
    @ObservedObject var viewModel: TastingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: DrinkTemplate?

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                if viewModel.templates.isEmpty {
                    AppEmptyStateView(
                        icon: "doc.text",
                        title: "No templates yet",
                        subtitle: "Create templates in the Library tab."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.templates) { template in
                                Button { selectedTemplate = template } label: {
                                    TemplateCardCell(template: template)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.accent)
                }
            }
            .sheet(item: $selectedTemplate) { template in
                TastingFormView(viewModel: viewModel, mode: .addFromTemplate(template))
            }
        }
    }
}

#Preview {
    HomeView(viewModel: TastingViewModel(), selectedTab: .constant(0))
}
