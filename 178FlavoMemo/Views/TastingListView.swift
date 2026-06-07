//
//  TastingListView.swift
//  178FlavoMemo
//

import SwiftUI

/// Main screen displaying saved tastings with search, filtering, and navigation.
struct TastingListView: View {
    @ObservedObject var viewModel: TastingViewModel
    @State private var showingAddForm = false
    @State private var showingTemplates = false
    @State private var listMode: ListDisplayMode = .list

    enum ListDisplayMode: String, CaseIterable, Identifiable {
        case list = "List"
        case calendar = "Calendar"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                VStack(spacing: 12) {
                    if !viewModel.tastings.isEmpty {
                        summaryHeader
                    }

                    AppSegmentedPicker(options: ListDisplayMode.allCases, selection: $listMode)
                        .padding(.horizontal, 16)

                    quickFilterBar

                    Group {
                        if viewModel.filteredTastings.isEmpty {
                            emptyStateView
                        } else if listMode == .list {
                            listView
                        } else {
                            TastingCalendarView(viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("Tastings")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search name, notes, location")
            .appNavigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { filterMenu }
                ToolbarItem(placement: .topBarLeading) { sortMenu }
                ToolbarItem(placement: .topBarTrailing) { addMenu }
            }
            .sheet(isPresented: $showingAddForm) {
                TastingFormView(viewModel: viewModel, mode: .add)
            }
            .sheet(isPresented: $showingTemplates) {
                TemplatePickerView(viewModel: viewModel)
            }
        }
    }

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            miniStat(icon: "list.bullet", value: "\(viewModel.insights.totalCount)", label: "Total")
            miniStat(icon: "star.fill", value: String(format: "%.1f", viewModel.insights.averageRating), label: "Avg")
            miniStat(icon: "heart.fill", value: "\(viewModel.insights.favoriteCount)", label: "Favs")
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .appListCardSurface(cornerRadius: 14)
    }

    private var quickFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                AppFilterChip(title: "All", isSelected: viewModel.selectedFilter == .all) {
                    viewModel.selectedFilter = .all
                }
                AppFilterChip(title: "Favorites", isSelected: viewModel.selectedFilter == .favorites) {
                    viewModel.selectedFilter = .favorites
                }
                ForEach(DrinkType.allCases) { type in
                    AppFilterChip(
                        title: type.rawValue,
                        isSelected: viewModel.selectedFilter == .drinkType(type)
                    ) {
                        viewModel.selectedFilter = .drinkType(type)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.filteredTastings) { tasting in
                NavigationLink {
                    TastingDetailView(viewModel: viewModel, tasting: tasting)
                } label: {
                    TastingCardCell(
                        tasting: resolvedTasting(tasting),
                        showChevron: false,
                        onFavoriteTap: {
                            viewModel.toggleFavorite(tasting.id)
                        }
                    )
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete { offsets in
                viewModel.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyStateView: some View {
        let message = viewModel.emptyStateMessage()

        return AppEmptyStateView(
            icon: emptyStateIcon,
            title: message.title,
            subtitle: message.subtitle,
            actionTitle: viewModel.searchText.isEmpty ? "Add Tasting" : nil,
            action: viewModel.searchText.isEmpty ? { showingAddForm = true } : nil
        )
    }

    private var emptyStateIcon: String {
        switch viewModel.selectedFilter {
        case .favorites: return "star.slash"
        case .collection: return "folder"
        case .drinkType(let type): return type.iconName
        case .all: return viewModel.searchText.isEmpty ? "cup.and.saucer.fill" : "magnifyingglass"
        }
    }

    private var filterMenu: some View {
        Menu {
            Button("All") { viewModel.selectedFilter = .all }
            Button("Favorites") { viewModel.selectedFilter = .favorites }
            Divider()
            ForEach(DrinkType.allCases) { type in
                Button(type.rawValue) { viewModel.selectedFilter = .drinkType(type) }
            }
            if !viewModel.collections.isEmpty {
                Divider()
                ForEach(viewModel.collections) { collection in
                    Button(collection.name) { viewModel.selectedFilter = .collection(collection.id) }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(AppColors.accent, AppColors.primaryText.opacity(0.4))
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(TastingSortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    if viewModel.sortOption == option {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .foregroundStyle(AppColors.accent)
        }
    }

    private var addMenu: some View {
        Menu {
            Button { showingAddForm = true } label: {
                Label("New Tasting", systemImage: "plus")
            }
            Button { showingTemplates = true } label: {
                Label("From Template", systemImage: "doc.text")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(AppColors.accent)
        }
    }

    private func resolvedTasting(_ tasting: TastingModel) -> TastingModel {
        viewModel.tastings.first(where: { $0.id == tasting.id }) ?? tasting
    }
}

/// Sheet for choosing a template before creating a tasting.
private struct TemplatePickerView: View {
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
    TastingListView(viewModel: TastingViewModel())
}
