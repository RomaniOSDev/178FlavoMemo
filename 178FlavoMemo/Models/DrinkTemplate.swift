//
//  DrinkTemplate.swift
//  178FlavoMemo
//

import Foundation

/// Saved preset used to quickly create a new tasting entry.
struct DrinkTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: DrinkType
    var variety: String?
    var flavorNotes: String
    var flavorTags: [FlavorTag]
    var brewMethod: String?
    var servingTemperature: String?
    var glassType: String?

    init(
        id: UUID = UUID(),
        name: String,
        type: DrinkType,
        variety: String? = nil,
        flavorNotes: String = "",
        flavorTags: [FlavorTag] = [],
        brewMethod: String? = nil,
        servingTemperature: String? = nil,
        glassType: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.variety = variety
        self.flavorNotes = flavorNotes
        self.flavorTags = flavorTags
        self.brewMethod = brewMethod
        self.servingTemperature = servingTemperature
        self.glassType = glassType
    }

    /// Converts the template into a new tasting model.
    func makeTasting() -> TastingModel {
        TastingModel(
            name: name,
            type: type,
            variety: variety,
            rating: 3,
            flavorNotes: flavorNotes,
            flavorTags: flavorTags,
            brewMethod: brewMethod,
            servingTemperature: servingTemperature,
            glassType: glassType
        )
    }
}
