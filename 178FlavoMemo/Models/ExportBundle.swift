//
//  ExportBundle.swift
//  178FlavoMemo
//

import Foundation

/// Container for export and import operations.
struct ExportBundle: Codable {
    var tastings: [TastingModel]
    var templates: [DrinkTemplate]
    var collections: [TastingCollection]
    var exportDate: Date
}
