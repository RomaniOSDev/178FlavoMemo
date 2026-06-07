//
//  TastingFormView.swift
//  178FlavoMemo
//

import SwiftUI

/// Screen for creating or editing a tasting entry.
struct TastingFormView: View {
    enum Mode: Equatable {
        case add
        case addFromTemplate(DrinkTemplate)
        case tasteAgain(TastingModel)
        case edit(TastingModel)
    }

    @ObservedObject var viewModel: TastingViewModel
    let mode: Mode

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: DrinkType = .coffee
    @State private var variety = ""
    @State private var rating = 3
    @State private var flavorNotes = ""
    @State private var flavorTags: [FlavorTag] = []
    @State private var location = ""
    @State private var date = Date()
    @State private var photoFileName: String?
    @State private var brewMethod = ""
    @State private var servingTemperature = ""
    @State private var glassType = ""
    @State private var selectedCollectionIds: [UUID] = []
    @State private var showValidationError = false
    @State private var showDiscardAlert = false
    @State private var initialSnapshot = FormSnapshot.empty

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        FormSectionCard(title: "Drink Name *") {
                            TextField("Enter drink name", text: $name)
                                .textFieldStyle(AppTextFieldStyle())
                            if showValidationError {
                                Text("Drink name is required.")
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }

                        FormSectionCard(title: "Drink Type") {
                            Picker("Drink Type", selection: $type) {
                                ForEach(DrinkType.allCases) { drinkType in
                                    Text(drinkType.rawValue).tag(drinkType)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        FormSectionCard(title: "Variety / Producer / Vintage") {
                            TextField("Optional", text: $variety)
                                .textFieldStyle(AppTextFieldStyle())
                        }

                        FormSectionCard(title: "Rating") {
                            StarRatingView(rating: $rating, starSize: 32)
                        }

                        FormSectionCard(title: "Flavor Tags") {
                            FlavorTagPickerView(selectedTags: $flavorTags)
                        }

                        FormSectionCard(title: "Aroma & Flavor Notes") {
                            TextEditor(text: $flavorNotes)
                                .frame(minHeight: 120)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(AppColors.background.opacity(0.35))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(AppColors.primaryText)
                        }

                        FormSectionCard(title: "Tasting Location") {
                            TextField("Optional", text: $location)
                                .textFieldStyle(AppTextFieldStyle())
                        }

                        if type == .coffee || type == .tea {
                            FormSectionCard(title: "Brew Method") {
                                Picker("Brew Method", selection: $brewMethod) {
                                    Text("None").tag("")
                                    ForEach(BrewMethod.allCases) { method in
                                        Text(method.rawValue).tag(method.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppColors.accent)
                            }
                        }

                        if type == .wine {
                            FormSectionCard(title: "Wine Details") {
                                TextField("Serving temperature, e.g. 16°C", text: $servingTemperature)
                                    .textFieldStyle(AppTextFieldStyle())

                                Picker("Glass Type", selection: $glassType) {
                                    Text("None").tag("")
                                    ForEach(WineGlassType.allCases) { glass in
                                        Text(glass.rawValue).tag(glass.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppColors.accent)
                            }
                        }

                        FormSectionCard(title: "Photo") {
                            TastingPhotoView(photoFileName: $photoFileName)
                        }

                        if !viewModel.collections.isEmpty {
                            FormSectionCard(title: "Collections") {
                                CollectionPickerView(
                                    collections: viewModel.collections,
                                    selectedIds: $selectedCollectionIds
                                )
                            }
                        }

                        FormSectionCard(title: "Date & Time") {
                            DatePicker(
                                "Date & Time",
                                selection: $date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            .tint(AppColors.accent)
                        }

                        HStack(spacing: 12) {
                            Button("Cancel") { attemptDismiss() }
                                .buttonStyle(AppSecondaryButtonStyle())
                            Button("Save") { saveTasting() }
                                .buttonStyle(AppPrimaryButtonStyle())
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBarStyle()
            .interactiveDismissDisabled(hasUnsavedChanges)
            .onAppear(perform: populateFields)
            .alert("Discard changes?", isPresented: $showDiscardAlert) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .add, .addFromTemplate, .tasteAgain:
            return "Add Tasting"
        case .edit:
            return "Edit Tasting"
        }
    }

    private var hasUnsavedChanges: Bool {
        currentSnapshot != initialSnapshot
    }

    @ViewBuilder
    private func formField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        FormSectionCard(title: title, content: content)
    }

    private func populateFields() {
        switch mode {
        case .add:
            break
        case .addFromTemplate(let template):
            name = template.name
            type = template.type
            variety = template.variety ?? ""
            flavorNotes = template.flavorNotes
            flavorTags = template.flavorTags
            brewMethod = template.brewMethod ?? ""
            servingTemperature = template.servingTemperature ?? ""
            glassType = template.glassType ?? ""
        case .tasteAgain(let tasting):
            name = tasting.name
            type = tasting.type
            variety = tasting.variety ?? ""
            flavorNotes = tasting.flavorNotes
            flavorTags = tasting.flavorTags
            location = tasting.location ?? ""
            brewMethod = tasting.brewMethod ?? ""
            servingTemperature = tasting.servingTemperature ?? ""
            glassType = tasting.glassType ?? ""
            selectedCollectionIds = tasting.collectionIds
            rating = 3
            date = Date()
        case .edit(let tasting):
            name = tasting.name
            type = tasting.type
            variety = tasting.variety ?? ""
            rating = tasting.rating
            flavorNotes = tasting.flavorNotes
            flavorTags = tasting.flavorTags
            location = tasting.location ?? ""
            date = tasting.date
            photoFileName = tasting.photoFileName
            brewMethod = tasting.brewMethod ?? ""
            servingTemperature = tasting.servingTemperature ?? ""
            glassType = tasting.glassType ?? ""
            selectedCollectionIds = tasting.collectionIds
        }

        initialSnapshot = currentSnapshot
    }

    private var currentSnapshot: FormSnapshot {
        FormSnapshot(
            name: name,
            type: type,
            variety: variety,
            rating: rating,
            flavorNotes: flavorNotes,
            flavorTags: flavorTags,
            location: location,
            date: date,
            photoFileName: photoFileName,
            brewMethod: brewMethod,
            servingTemperature: servingTemperature,
            glassType: glassType,
            collectionIds: selectedCollectionIds
        )
    }

    private func attemptDismiss() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func saveTasting() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showValidationError = true
            return
        }

        showValidationError = false

        let trimmedVariety = variety.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBrewMethod = brewMethod.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTemperature = servingTemperature.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGlass = glassType.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .add, .addFromTemplate:
            let tasting = TastingModel(
                name: trimmedName,
                type: type,
                variety: trimmedVariety.isEmpty ? nil : trimmedVariety,
                rating: rating,
                flavorNotes: flavorNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                flavorTags: flavorTags,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                date: date,
                photoFileName: photoFileName,
                brewMethod: trimmedBrewMethod.isEmpty ? nil : trimmedBrewMethod,
                servingTemperature: trimmedTemperature.isEmpty ? nil : trimmedTemperature,
                glassType: trimmedGlass.isEmpty ? nil : trimmedGlass,
                collectionIds: selectedCollectionIds
            )
            viewModel.save(tasting)

        case .tasteAgain(let source):
            let tasting = TastingModel(
                name: trimmedName,
                type: type,
                variety: trimmedVariety.isEmpty ? nil : trimmedVariety,
                rating: rating,
                flavorNotes: flavorNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                flavorTags: flavorTags,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                date: date,
                drinkGroupId: source.drinkGroupId,
                photoFileName: photoFileName,
                brewMethod: trimmedBrewMethod.isEmpty ? nil : trimmedBrewMethod,
                servingTemperature: trimmedTemperature.isEmpty ? nil : trimmedTemperature,
                glassType: trimmedGlass.isEmpty ? nil : trimmedGlass,
                collectionIds: selectedCollectionIds
            )
            viewModel.save(tasting)

        case .edit(let existing):
            let updated = TastingModel(
                id: existing.id,
                name: trimmedName,
                type: type,
                variety: trimmedVariety.isEmpty ? nil : trimmedVariety,
                rating: rating,
                flavorNotes: flavorNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                flavorTags: flavorTags,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                date: date,
                isFavorite: existing.isFavorite,
                drinkGroupId: existing.drinkGroupId,
                photoFileName: photoFileName,
                brewMethod: trimmedBrewMethod.isEmpty ? nil : trimmedBrewMethod,
                servingTemperature: trimmedTemperature.isEmpty ? nil : trimmedTemperature,
                glassType: trimmedGlass.isEmpty ? nil : trimmedGlass,
                collectionIds: selectedCollectionIds
            )
            viewModel.update(updated)
        }

        dismiss()
    }
}

private struct FormSnapshot: Equatable {
    var name: String
    var type: DrinkType
    var variety: String
    var rating: Int
    var flavorNotes: String
    var flavorTags: [FlavorTag]
    var location: String
    var date: Date
    var photoFileName: String?
    var brewMethod: String
    var servingTemperature: String
    var glassType: String
    var collectionIds: [UUID]

    static let empty = FormSnapshot(
        name: "",
        type: .coffee,
        variety: "",
        rating: 3,
        flavorNotes: "",
        flavorTags: [],
        location: "",
        date: Date(),
        photoFileName: nil,
        brewMethod: "",
        servingTemperature: "",
        glassType: "",
        collectionIds: []
    )
}

private struct CollectionPickerView: View {
    let collections: [TastingCollection]
    @Binding var selectedIds: [UUID]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(collections) { collection in
                Button {
                    toggle(collection.id)
                } label: {
                    HStack {
                        Image(systemName: selectedIds.contains(collection.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(AppColors.accent)
                        Text(collection.name)
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ id: UUID) {
        if let index = selectedIds.firstIndex(of: id) {
            selectedIds.remove(at: index)
        } else {
            selectedIds.append(id)
        }
    }
}

#Preview {
    TastingFormView(viewModel: TastingViewModel(), mode: .add)
}
