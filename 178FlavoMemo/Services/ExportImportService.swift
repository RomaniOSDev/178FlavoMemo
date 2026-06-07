//
//  ExportImportService.swift
//  178FlavoMemo
//

import Foundation

/// Handles JSON and CSV export/import for backup and transfer.
final class ExportImportService {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func makeExportBundle(
        tastings: [TastingModel],
        templates: [DrinkTemplate],
        collections: [TastingCollection]
    ) -> ExportBundle {
        ExportBundle(
            tastings: tastings,
            templates: templates,
            collections: collections,
            exportDate: Date()
        )
    }

    func exportJSON(bundle: ExportBundle) throws -> Data {
        try encoder.encode(bundle)
    }

    func importJSON(data: Data) throws -> ExportBundle {
        try decoder.decode(ExportBundle.self, from: data)
    }

    func exportCSV(tastings: [TastingModel]) -> String {
        var lines = [
            "Name,Type,Variety,Rating,Flavor Notes,Flavor Tags,Location,Date,Is Favorite,Brew Method,Serving Temperature,Glass Type,Collections Count"
        ]

        let formatter = ISO8601DateFormatter()

        for tasting in tastings {
            let row = [
                csvEscape(tasting.name),
                csvEscape(tasting.type.rawValue),
                csvEscape(tasting.variety ?? ""),
                String(tasting.rating),
                csvEscape(tasting.flavorNotes),
                csvEscape(tasting.flavorTags.map(\.rawValue).joined(separator: "; ")),
                csvEscape(tasting.location ?? ""),
                csvEscape(formatter.string(from: tasting.date)),
                tasting.isFavorite ? "Yes" : "No",
                csvEscape(tasting.brewMethod ?? ""),
                csvEscape(tasting.servingTemperature ?? ""),
                csvEscape(tasting.glassType ?? ""),
                String(tasting.collectionIds.count)
            ]
            lines.append(row.joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }

    private func csvEscape(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
