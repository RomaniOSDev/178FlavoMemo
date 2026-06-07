//
//  CollectionsListView.swift
//  178FlavoMemo
//

import SwiftUI

/// List and management screen for tasting collections.
struct CollectionsListView: View {
    @ObservedObject var viewModel: TastingViewModel
    @State private var showingAddCollection = false
    @State private var editingCollection: TastingCollection?

    var body: some View {
        ZStack {
            AppScreenBackground()

            if viewModel.collections.isEmpty {
                AppEmptyStateView(
                    icon: "folder.fill",
                    title: "No collections yet",
                    subtitle: "Group tastings into collections like trips or themes.",
                    actionTitle: "Create Collection",
                    action: { showingAddCollection = true }
                )
            } else {
                List {
                    ForEach(viewModel.collections) { collection in
                        NavigationLink {
                            CollectionDetailView(viewModel: viewModel, collection: collection)
                        } label: {
                            CollectionCardCell(
                                name: collection.name,
                                count: collection.tastingIds.count
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button {
                                editingCollection = collection
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(AppColors.accent)
                        }
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { viewModel.collections[$0].id }
                        ids.forEach { viewModel.deleteCollection($0) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddCollection = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddCollection) {
            CollectionFormView(viewModel: viewModel, mode: .add)
        }
        .sheet(item: $editingCollection) { collection in
            CollectionFormView(viewModel: viewModel, mode: .edit(collection))
        }
    }
}

/// Detail screen for a single collection.
struct CollectionDetailView: View {
    @ObservedObject var viewModel: TastingViewModel
    let collection: TastingCollection

    private var currentCollection: TastingCollection {
        viewModel.collections.first(where: { $0.id == collection.id }) ?? collection
    }

    private var tastings: [TastingModel] {
        viewModel.tastings(in: currentCollection.id)
    }

    var body: some View {
        ZStack {
            AppScreenBackground()

            if tastings.isEmpty {
                AppEmptyStateView(
                    icon: "tray",
                    title: "Collection is empty",
                    subtitle: "Edit a tasting and assign it to this collection."
                )
            } else {
                List {
                    ForEach(tastings) { tasting in
                        NavigationLink {
                            TastingDetailView(viewModel: viewModel, tasting: tasting)
                        } label: {
                            TastingCardCell(tasting: tasting, showChevron: false)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(currentCollection.name)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
    }
}

/// Form for creating or editing a collection.
struct CollectionFormView: View {
    enum Mode {
        case add
        case edit(TastingCollection)
    }

    @ObservedObject var viewModel: TastingViewModel
    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                VStack(spacing: 16) {
                    FormSectionCard(title: "Collection Name") {
                        TextField("e.g. Home Bar, Trip to Italy", text: $name)
                            .textFieldStyle(AppTextFieldStyle())
                    }

                    Button("Save") { saveCollection() }
                        .buttonStyle(AppPrimaryButtonStyle())

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle(modeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.accent)
                }
            }
            .onAppear {
                if case let .edit(collection) = mode {
                    name = collection.name
                }
            }
        }
    }

    private var modeTitle: String {
        switch mode {
        case .add: return "New Collection"
        case .edit: return "Edit Collection"
        }
    }

    private func saveCollection() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        switch mode {
        case .add:
            viewModel.saveCollection(TastingCollection(name: trimmedName))
        case .edit(let existing):
            viewModel.updateCollection(
                TastingCollection(
                    id: existing.id,
                    name: trimmedName,
                    tastingIds: existing.tastingIds
                )
            )
        }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        CollectionsListView(viewModel: TastingViewModel())
    }
}
