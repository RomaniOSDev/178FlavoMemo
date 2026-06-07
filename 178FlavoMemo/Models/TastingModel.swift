//
//  TastingModel.swift
//  178FlavoMemo
//

import Foundation

/// Supported drink categories for a tasting entry.
enum DrinkType: String, CaseIterable, Codable, Identifiable {
    case coffee = "Coffee"
    case wine = "Wine"
    case tea = "Tea"

    var id: String { rawValue }
}

/// Predefined flavor descriptor tags.
enum FlavorTag: String, CaseIterable, Codable, Identifiable {
    case fruity = "Fruity"
    case nutty = "Nutty"
    case floral = "Floral"
    case bitter = "Bitter"
    case sweet = "Sweet"
    case spicy = "Spicy"
    case smoky = "Smoky"
    case citrus = "Citrus"
    case chocolate = "Chocolate"
    case earthy = "Earthy"

    var id: String { rawValue }
}

/// Sort options for the tasting list.
enum TastingSortOption: String, CaseIterable, Identifiable, Codable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case ratingHighest = "Rating (Highest)"
    case ratingLowest = "Rating (Lowest)"
    case nameAZ = "Name (A–Z)"

    var id: String { rawValue }
}

/// Active list filter including drink type, favorites, and collections.
enum ListFilter: Equatable, Hashable {
    case all
    case drinkType(DrinkType)
    case favorites
    case collection(UUID)

    var title: String {
        switch self {
        case .all:
            return "All"
        case .drinkType(let type):
            return type.rawValue
        case .favorites:
            return "Favorites"
        case .collection:
            return "Collection"
        }
    }
}

/// Common coffee and tea brew methods.
enum BrewMethod: String, CaseIterable, Identifiable {
    case espresso = "Espresso"
    case pourOver = "Pour Over"
    case v60 = "V60"
    case frenchPress = "French Press"
    case aeropress = "AeroPress"
    case coldBrew = "Cold Brew"
    case mokaPot = "Moka Pot"
    case steeped = "Steeped"
    case other = "Other"

    var id: String { rawValue }
}

/// Common wine glass types.
enum WineGlassType: String, CaseIterable, Identifiable {
    case red = "Red Wine"
    case white = "White Wine"
    case sparkling = "Sparkling"
    case universal = "Universal"
    case other = "Other"

    var id: String { rawValue }
}

/// Represents a single drink tasting record stored locally.
struct TastingModel: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: DrinkType
    var variety: String?
    var rating: Int
    var flavorNotes: String
    var flavorTags: [FlavorTag]
    var location: String?
    var date: Date
    var isFavorite: Bool
    var drinkGroupId: UUID
    var photoFileName: String?
    var brewMethod: String?
    var servingTemperature: String?
    var glassType: String?
    var collectionIds: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        type: DrinkType,
        variety: String? = nil,
        rating: Int = 3,
        flavorNotes: String = "",
        flavorTags: [FlavorTag] = [],
        location: String? = nil,
        date: Date = Date(),
        isFavorite: Bool = false,
        drinkGroupId: UUID? = nil,
        photoFileName: String? = nil,
        brewMethod: String? = nil,
        servingTemperature: String? = nil,
        glassType: String? = nil,
        collectionIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.variety = variety
        self.rating = min(max(rating, 1), 5)
        self.flavorNotes = flavorNotes
        self.flavorTags = flavorTags
        self.location = location
        self.date = date
        self.isFavorite = isFavorite
        self.drinkGroupId = drinkGroupId ?? id
        self.photoFileName = photoFileName
        self.brewMethod = brewMethod
        self.servingTemperature = servingTemperature
        self.glassType = glassType
        self.collectionIds = collectionIds
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, variety, rating, flavorNotes, location, date
        case flavorTags, isFavorite, drinkGroupId, photoFileName
        case brewMethod, servingTemperature, glassType, collectionIds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(DrinkType.self, forKey: .type)
        variety = try container.decodeIfPresent(String.self, forKey: .variety)
        rating = try container.decode(Int.self, forKey: .rating)
        flavorNotes = try container.decodeIfPresent(String.self, forKey: .flavorNotes) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location)
        date = try container.decode(Date.self, forKey: .date)
        flavorTags = try container.decodeIfPresent([FlavorTag].self, forKey: .flavorTags) ?? []
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        drinkGroupId = try container.decodeIfPresent(UUID.self, forKey: .drinkGroupId) ?? id
        photoFileName = try container.decodeIfPresent(String.self, forKey: .photoFileName)
        brewMethod = try container.decodeIfPresent(String.self, forKey: .brewMethod)
        servingTemperature = try container.decodeIfPresent(String.self, forKey: .servingTemperature)
        glassType = try container.decodeIfPresent(String.self, forKey: .glassType)
        collectionIds = try container.decodeIfPresent([UUID].self, forKey: .collectionIds) ?? []
    }

    /// Returns true when searchable fields contain the query.
    func matchesSearch(_ query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return true }

        let fields = [
            name,
            variety ?? "",
            flavorNotes,
            location ?? "",
            flavorTags.map(\.rawValue).joined(separator: " ")
        ]

        return fields.contains { $0.lowercased().contains(normalizedQuery) }
    }
}
