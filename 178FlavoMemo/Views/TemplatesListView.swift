//
//  TemplatesListView.swift
//  178FlavoMemo
//

import SwiftUI

/// List and management screen for drink templates.
struct TemplatesListView: View {
    @ObservedObject var viewModel: TastingViewModel
    @State private var showingAddTemplate = false
    @State private var editingTemplate: DrinkTemplate?

    var body: some View {
        ZStack {
            AppScreenBackground()

            if viewModel.templates.isEmpty {
                AppEmptyStateView(
                    icon: "doc.text.fill",
                    title: "No templates yet",
                    subtitle: "Save presets for drinks you taste often.",
                    actionTitle: "Create Template",
                    action: { showingAddTemplate = true }
                )
            } else {
                List {
                    ForEach(viewModel.templates) { template in
                        Button { editingTemplate = template } label: {
                            TemplateCardCell(template: template)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { viewModel.templates[$0].id }
                        ids.forEach { viewModel.deleteTemplate($0) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddTemplate = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddTemplate) {
            TemplateFormView(viewModel: viewModel, mode: .add)
        }
        .sheet(item: $editingTemplate) { template in
            TemplateFormView(viewModel: viewModel, mode: .edit(template))
        }
    }
}

/// Form for creating or editing a drink template.
struct TemplateFormView: View {
    enum Mode {
        case add
        case edit(DrinkTemplate)
    }

    @ObservedObject var viewModel: TastingViewModel
    let mode: Mode

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: DrinkType = .coffee
    @State private var variety = ""
    @State private var flavorNotes = ""
    @State private var flavorTags: [FlavorTag] = []
    @State private var brewMethod = ""
    @State private var servingTemperature = ""
    @State private var glassType = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        FormSectionCard(title: "Template Info") {
                            TextField("Template name", text: $name)
                                .textFieldStyle(AppTextFieldStyle())
                            Picker("Type", selection: $type) {
                                ForEach(DrinkType.allCases) { drinkType in
                                    Text(drinkType.rawValue).tag(drinkType)
                                }
                            }
                            .pickerStyle(.segmented)
                            TextField("Variety / Producer / Vintage", text: $variety)
                                .textFieldStyle(AppTextFieldStyle())
                        }

                        FormSectionCard(title: "Flavor Profile") {
                            FlavorTagPickerView(selectedTags: $flavorTags)
                            TextEditor(text: $flavorNotes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(AppColors.background.opacity(0.35))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(AppColors.primaryText)
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
                                TextField("Serving Temperature", text: $servingTemperature)
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

                        Button("Save Template") { saveTemplate() }
                            .buttonStyle(AppPrimaryButtonStyle())
                    }
                    .padding(16)
                }
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
            .onAppear(perform: populate)
        }
    }

    private var modeTitle: String {
        switch mode {
        case .add: return "New Template"
        case .edit: return "Edit Template"
        }
    }

    private func populate() {
        guard case let .edit(template) = mode else { return }
        name = template.name
        type = template.type
        variety = template.variety ?? ""
        flavorNotes = template.flavorNotes
        flavorTags = template.flavorTags
        brewMethod = template.brewMethod ?? ""
        servingTemperature = template.servingTemperature ?? ""
        glassType = template.glassType ?? ""
    }

    private func saveTemplate() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        switch mode {
        case .add:
            viewModel.saveTemplate(
                DrinkTemplate(
                    name: trimmedName,
                    type: type,
                    variety: variety.nilIfEmpty,
                    flavorNotes: flavorNotes,
                    flavorTags: flavorTags,
                    brewMethod: brewMethod.nilIfEmpty,
                    servingTemperature: servingTemperature.nilIfEmpty,
                    glassType: glassType.nilIfEmpty
                )
            )
        case .edit(let existing):
            viewModel.updateTemplate(
                DrinkTemplate(
                    id: existing.id,
                    name: trimmedName,
                    type: type,
                    variety: variety.nilIfEmpty,
                    flavorNotes: flavorNotes,
                    flavorTags: flavorTags,
                    brewMethod: brewMethod.nilIfEmpty,
                    servingTemperature: servingTemperature.nilIfEmpty,
                    glassType: glassType.nilIfEmpty
                )
            )
        }

        dismiss()
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#Preview {
    NavigationStack {
        TemplatesListView(viewModel: TastingViewModel())
    }
}
