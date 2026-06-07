//
//  DateFormatting.swift
//  178FlavoMemo
//

import Foundation

enum DateFormatting {
    private static let tastingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        return formatter
    }()

    private static let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, dd MMM yyyy"
        return formatter
    }()

    private static let weekDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    static func formatTastingDate(_ date: Date) -> String {
        tastingDateFormatter.string(from: date)
    }

    static func formatSectionDate(_ date: Date) -> String {
        sectionDateFormatter.string(from: date)
    }

    static func formatWeekTitle(startOfWeek: Date) -> String {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
        let start = tastingDateFormatter.string(from: startOfWeek).prefix(11)
        let end = tastingDateFormatter.string(from: weekEnd).prefix(11)
        return "Week of \(start) – \(end)"
    }
}
