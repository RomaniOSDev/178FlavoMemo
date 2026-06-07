//
//  OnboardingService.swift
//  178FlavoMemo
//

import Foundation

/// Persists whether the user has finished the first-run onboarding flow.
final class OnboardingService {
    static let shared = OnboardingService()

    private let completedKey = "has_completed_onboarding"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: completedKey)
    }

    func completeOnboarding() {
        defaults.set(true, forKey: completedKey)
    }

    func resetOnboarding() {
        defaults.removeObject(forKey: completedKey)
    }
}
