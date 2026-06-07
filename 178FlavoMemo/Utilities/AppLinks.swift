//
//  AppLinks.swift
//  178FlavoMemo
//

import UIKit

/// External URLs used across the app.
enum AppLinks: String, CaseIterable, Identifiable {
    case privacyPolicy
    case termsOfUse

    var id: String { rawValue }

    /// Display title for settings rows.
    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of Use"
        }
    }

    /// Remote URL for the selected link.
    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/5244f1da-c564-4d8c-9f49-fa0de75347d0"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/9826ee27-6830-4c68-a3f8-dccc8ba12262"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    /// Opens the link in Safari.
    func open() {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
