//
//  TastingCollection.swift
//  178FlavoMemo
//

import Foundation

/// User-defined group of tasting records.
struct TastingCollection: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var tastingIds: [UUID]

    init(id: UUID = UUID(), name: String, tastingIds: [UUID] = []) {
        self.id = id
        self.name = name
        self.tastingIds = tastingIds
    }
}
