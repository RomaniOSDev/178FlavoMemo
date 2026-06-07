//
//  ReminderSettings.swift
//  178FlavoMemo
//

import Foundation

/// Local notification reminder configuration.
struct ReminderSettings: Codable, Equatable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int

    init(isEnabled: Bool = false, hour: Int = 19, minute: Int = 0) {
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
    }
}
