//
//  TastingStorageService.swift
//  178FlavoMemo
//

import Foundation

/// Abstraction for persisting app data.
protocol AppStorageProtocol {
    func loadTastings() -> [TastingModel]
    func saveTastings(_ tastings: [TastingModel])
    func loadTemplates() -> [DrinkTemplate]
    func saveTemplates(_ templates: [DrinkTemplate])
    func loadCollections() -> [TastingCollection]
    func saveCollections(_ collections: [TastingCollection])
    func loadReminderSettings() -> ReminderSettings
    func saveReminderSettings(_ settings: ReminderSettings)
}

/// UserDefaults-backed storage using JSON encoding.
final class TastingStorageService: AppStorageProtocol {
    private let defaults: UserDefaults
    private let tastingsKey = "saved_tastings"
    private let templatesKey = "saved_templates"
    private let collectionsKey = "saved_collections"
    private let reminderKey = "reminder_settings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTastings() -> [TastingModel] {
        decode([TastingModel].self, forKey: tastingsKey) ?? []
    }

    func saveTastings(_ tastings: [TastingModel]) {
        encode(tastings, forKey: tastingsKey)
    }

    func loadTemplates() -> [DrinkTemplate] {
        decode([DrinkTemplate].self, forKey: templatesKey) ?? []
    }

    func saveTemplates(_ templates: [DrinkTemplate]) {
        encode(templates, forKey: templatesKey)
    }

    func loadCollections() -> [TastingCollection] {
        decode([TastingCollection].self, forKey: collectionsKey) ?? []
    }

    func saveCollections(_ collections: [TastingCollection]) {
        encode(collections, forKey: collectionsKey)
    }

    func loadReminderSettings() -> ReminderSettings {
        decode(ReminderSettings.self, forKey: reminderKey) ?? ReminderSettings()
    }

    func saveReminderSettings(_ settings: ReminderSettings) {
        encode(settings, forKey: reminderKey)
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}

// Legacy alias for existing references.
typealias TastingStorageProtocol = AppStorageProtocol
