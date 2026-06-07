//
//  InsightsData.swift
//  178FlavoMemo
//

import Foundation

/// Aggregated statistics for the Insights screen.
struct InsightsData {
    let totalCount: Int
    let averageRating: Double
    let coffeeCount: Int
    let wineCount: Int
    let teaCount: Int
    let bestTasting: TastingModel?
    let lastTasting: TastingModel?
    let favoriteCount: Int
    let topFlavorTags: [(tag: FlavorTag, count: Int)]

    static func build(from tastings: [TastingModel]) -> InsightsData {
        let totalCount = tastings.count
        let averageRating = tastings.isEmpty
            ? 0
            : Double(tastings.map(\.rating).reduce(0, +)) / Double(totalCount)

        let coffeeCount = tastings.filter { $0.type == .coffee }.count
        let wineCount = tastings.filter { $0.type == .wine }.count
        let teaCount = tastings.filter { $0.type == .tea }.count
        let favoriteCount = tastings.filter(\.isFavorite).count

        let bestTasting = tastings.max { lhs, rhs in
            if lhs.rating == rhs.rating {
                return lhs.date < rhs.date
            }
            return lhs.rating < rhs.rating
        }

        let lastTasting = tastings.max(by: { $0.date < $1.date })

        var tagCounts: [FlavorTag: Int] = [:]
        for tasting in tastings {
            for tag in tasting.flavorTags {
                tagCounts[tag, default: 0] += 1
            }
        }

        let topFlavorTags = tagCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (tag: $0.key, count: $0.value) }

        return InsightsData(
            totalCount: totalCount,
            averageRating: averageRating,
            coffeeCount: coffeeCount,
            wineCount: wineCount,
            teaCount: teaCount,
            bestTasting: bestTasting,
            lastTasting: lastTasting,
            favoriteCount: favoriteCount,
            topFlavorTags: topFlavorTags
        )
    }
}
