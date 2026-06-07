//
//  TastingViewModel.swift
//  178FlavoMemo
//

import Combine
import Foundation

/// Manages tasting list state, filtering, sorting, and persistence.
@MainActor
final class TastingViewModel: ObservableObject {
    @Published var tastings: [TastingModel] = []
    @Published var templates: [DrinkTemplate] = []
    @Published var collections: [TastingCollection] = []
    @Published var reminderSettings: ReminderSettings = ReminderSettings()
    @Published var selectedFilter: ListFilter = .all
    @Published var searchText = ""
    @Published var sortOption: TastingSortOption = .dateNewest
    @Published var compareSelection: [UUID] = []

    private let storage: AppStorageProtocol
    private let exportImportService = ExportImportService()

    /// Returns tastings filtered, searched, and sorted for display.
    var filteredTastings: [TastingModel] {
        var result = tastings

        switch selectedFilter {
        case .all:
            break
        case .drinkType(let type):
            result = result.filter { $0.type == type }
        case .favorites:
            result = result.filter(\.isFavorite)
        case .collection(let collectionId):
            result = result.filter { $0.collectionIds.contains(collectionId) }
        }

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result.filter { $0.matchesSearch(searchText) }
        }

        return sort(result)
    }

    var insights: InsightsData {
        InsightsData.build(from: tastings)
    }

    var compareTastings: [TastingModel] {
        compareSelection.compactMap { id in
            tastings.first(where: { $0.id == id })
        }
    }

    /// Latest tastings for the home screen carousel.
    var recentTastings: [TastingModel] {
        Array(tastings.sorted { $0.date > $1.date }.prefix(5))
    }

    /// Favorite tastings for the home screen widget.
    var favoriteTastings: [TastingModel] {
        tastings.filter(\.isFavorite).sorted { $0.date > $1.date }
    }

    /// Number of tastings logged in the current calendar month.
    var tastingsThisMonth: Int {
        let calendar = Calendar.current
        return tastings.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }.count
    }

    /// Counts grouped by drink type for home widgets.
    func count(for type: DrinkType) -> Int {
        tastings.filter { $0.type == type }.count
    }

    init(storage: AppStorageProtocol = TastingStorageService()) {
        self.storage = storage
        load()
    }

    func load() {
        tastings = storage.loadTastings()
        templates = storage.loadTemplates()
        collections = storage.loadCollections()
        reminderSettings = storage.loadReminderSettings()
    }

    func save(_ tasting: TastingModel) {
        var newTasting = tasting
        syncCollections(for: &newTasting, previousCollectionIds: [])
        tastings.append(newTasting)
        persistAll()
    }

    func update(_ tasting: TastingModel) {
        guard let index = tastings.firstIndex(where: { $0.id == tasting.id }) else { return }

        var updatedTasting = tasting
        let previousCollectionIds = tastings[index].collectionIds
        syncCollections(for: &updatedTasting, previousCollectionIds: previousCollectionIds)
        tastings[index] = updatedTasting
        persistAll()
    }

    func delete(_ id: UUID) {
        if let tasting = tastings.first(where: { $0.id == id }) {
            removeTastingFromCollections(tastingId: id, collectionIds: tasting.collectionIds)
            if let photoFileName = tasting.photoFileName {
                PhotoStorageService.shared.deletePhoto(fileName: photoFileName)
            }
        }

        tastings.removeAll { $0.id == id }
        compareSelection.removeAll { $0 == id }
        persistAll()
    }

    func delete(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredTastings[$0] }
        for item in itemsToDelete {
            delete(item.id)
        }
    }

    func toggleFavorite(_ id: UUID) {
        guard let index = tastings.firstIndex(where: { $0.id == id }) else { return }
        tastings[index].isFavorite.toggle()
        persistAll()
    }

    func tasteAgain(from tasting: TastingModel) -> TastingModel {
        TastingModel(
            name: tasting.name,
            type: tasting.type,
            variety: tasting.variety,
            rating: 3,
            flavorNotes: tasting.flavorNotes,
            flavorTags: tasting.flavorTags,
            location: tasting.location,
            date: Date(),
            isFavorite: false,
            drinkGroupId: tasting.drinkGroupId,
            brewMethod: tasting.brewMethod,
            servingTemperature: tasting.servingTemperature,
            glassType: tasting.glassType,
            collectionIds: tasting.collectionIds
        )
    }

    func tastingHistory(for drinkGroupId: UUID) -> [TastingModel] {
        tastings
            .filter { $0.drinkGroupId == drinkGroupId }
            .sorted { $0.date > $1.date }
    }

    func calendarSections() -> [(date: Date, items: [TastingModel])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTastings) { tasting in
            calendar.startOfDay(for: tasting.date)
        }

        return grouped
            .map { (date: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    func emptyStateMessage() -> (title: String, subtitle: String) {
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ("No results found", "Try a different search term.")
        }

        switch selectedFilter {
        case .all:
            return ("No tastings yet", "Tap + to record your first drink tasting.")
        case .drinkType(let type):
            return ("No \(type.rawValue.lowercased()) tastings yet", "Add a \(type.rawValue.lowercased()) tasting or change the filter.")
        case .favorites:
            return ("No favorites yet", "Mark tastings with the star icon to see them here.")
        case .collection(let id):
            let name = collections.first(where: { $0.id == id })?.name ?? "this collection"
            return ("No tastings in \(name)", "Edit a tasting to add it to this collection.")
        }
    }

    // MARK: - Templates

    func saveTemplate(_ template: DrinkTemplate) {
        templates.append(template)
        storage.saveTemplates(templates)
    }

    func updateTemplate(_ template: DrinkTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index] = template
        storage.saveTemplates(templates)
    }

    func deleteTemplate(_ id: UUID) {
        templates.removeAll { $0.id == id }
        storage.saveTemplates(templates)
    }

    // MARK: - Collections

    func saveCollection(_ collection: TastingCollection) {
        collections.append(collection)
        storage.saveCollections(collections)
    }

    func updateCollection(_ collection: TastingCollection) {
        guard let index = collections.firstIndex(where: { $0.id == collection.id }) else { return }
        collections[index] = collection
        storage.saveCollections(collections)
    }

    func deleteCollection(_ id: UUID) {
        collections.removeAll { $0.id == id }

        for index in tastings.indices {
            tastings[index].collectionIds.removeAll { $0 == id }
        }

        if case .collection(let selectedId) = selectedFilter, selectedId == id {
            selectedFilter = .all
        }

        persistAll()
    }

    func collectionName(for id: UUID) -> String {
        collections.first(where: { $0.id == id })?.name ?? "Collection"
    }

    func tastings(in collectionId: UUID) -> [TastingModel] {
        tastings.filter { $0.collectionIds.contains(collectionId) }
    }

    // MARK: - Compare

    func toggleCompareSelection(_ id: UUID) {
        if compareSelection.contains(id) {
            compareSelection.removeAll { $0 == id }
            return
        }

        if compareSelection.count >= 2 {
            compareSelection.removeFirst()
        }

        compareSelection.append(id)
    }

    func clearCompareSelection() {
        compareSelection.removeAll()
    }

    // MARK: - Export / Import

    func exportJSONData() throws -> Data {
        let bundle = exportImportService.makeExportBundle(
            tastings: tastings,
            templates: templates,
            collections: collections
        )
        return try exportImportService.exportJSON(bundle: bundle)
    }

    func exportCSVString() -> String {
        exportImportService.exportCSV(tastings: tastings)
    }

    func importBundle(_ bundle: ExportBundle, merge: Bool) {
        if merge {
            mergeImportedData(bundle)
        } else {
            replaceImportedData(bundle)
        }

        persistAll()
        storage.saveTemplates(templates)
        storage.saveCollections(collections)
    }

    // MARK: - Reminders

    func updateReminderSettings(_ settings: ReminderSettings) async {
        reminderSettings = settings
        storage.saveReminderSettings(settings)

        if settings.isEnabled {
            let granted = await NotificationService.shared.requestAuthorization()
            guard granted else { return }
            await NotificationService.shared.scheduleDailyReminder(
                hour: settings.hour,
                minute: settings.minute
            )
        } else {
            NotificationService.shared.cancelReminder()
        }
    }

    // MARK: - Private

    private func sort(_ items: [TastingModel]) -> [TastingModel] {
        switch sortOption {
        case .dateNewest:
            return items.sorted { $0.date > $1.date }
        case .dateOldest:
            return items.sorted { $0.date < $1.date }
        case .ratingHighest:
            return items.sorted {
                if $0.rating == $1.rating { return $0.date > $1.date }
                return $0.rating > $1.rating
            }
        case .ratingLowest:
            return items.sorted {
                if $0.rating == $1.rating { return $0.date > $1.date }
                return $0.rating < $1.rating
            }
        case .nameAZ:
            return items.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
    }

    private func persistAll() {
        storage.saveTastings(tastings)
    }

    private func syncCollections(for tasting: inout TastingModel, previousCollectionIds: [UUID]) {
        let removedIds = Set(previousCollectionIds).subtracting(tasting.collectionIds)
        let addedIds = Set(tasting.collectionIds).subtracting(previousCollectionIds)

        for index in collections.indices {
            if removedIds.contains(collections[index].id) {
                collections[index].tastingIds.removeAll { $0 == tasting.id }
            }

            if addedIds.contains(collections[index].id),
               !collections[index].tastingIds.contains(tasting.id) {
                collections[index].tastingIds.append(tasting.id)
            }
        }

        storage.saveCollections(collections)
    }

    private func removeTastingFromCollections(tastingId: UUID, collectionIds: [UUID]) {
        for collectionId in collectionIds {
            guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { continue }
            collections[index].tastingIds.removeAll { $0 == tastingId }
        }
        storage.saveCollections(collections)
    }

    private func mergeImportedData(_ bundle: ExportBundle) {
        for importedTasting in bundle.tastings where !tastings.contains(where: { $0.id == importedTasting.id }) {
            tastings.append(importedTasting)
        }

        for importedTemplate in bundle.templates where !templates.contains(where: { $0.id == importedTemplate.id }) {
            templates.append(importedTemplate)
        }

        for importedCollection in bundle.collections where !collections.contains(where: { $0.id == importedCollection.id }) {
            collections.append(importedCollection)
        }
    }

    private func replaceImportedData(_ bundle: ExportBundle) {
        tastings = bundle.tastings
        templates = bundle.templates
        collections = bundle.collections
        compareSelection.removeAll()
    }
}
