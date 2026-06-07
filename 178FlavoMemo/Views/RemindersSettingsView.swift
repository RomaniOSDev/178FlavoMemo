//
//  RemindersSettingsView.swift
//  178FlavoMemo
//

import SwiftUI

/// Settings screen for daily tasting reminders.
struct RemindersSettingsView: View {
    @ObservedObject var viewModel: TastingViewModel

    @State private var isEnabled = false
    @State private var reminderTime = Date()
    @State private var showingSavedAlert = false

    var body: some View {
        ZStack {
            AppScreenBackground()

            VStack(spacing: 16) {
                AppElevatedCard {
                    VStack(spacing: 16) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.accent.opacity(0.18))
                                    .frame(width: 56, height: 56)
                                Image(systemName: isEnabled ? "bell.badge.fill" : "bell.slash.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppColors.accent)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Reminder")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.primaryText)
                                Text(isEnabled ? "You will be reminded every day." : "Reminders are currently off.")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                            Spacer()
                        }

                        Toggle("Enable Reminder", isOn: $isEnabled)
                            .tint(AppColors.success)

                        if isEnabled {
                            DatePicker(
                                "Reminder Time",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .tint(AppColors.accent)
                            .labelsHidden()
                        }
                    }
                }

                Button("Save Reminder Settings") {
                    Task { await saveSettings() }
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .onAppear(perform: loadSettings)
        .alert("Reminder Saved", isPresented: $showingSavedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(isEnabled ? "Daily reminder scheduled." : "Daily reminder disabled.")
        }
    }

    private func loadSettings() {
        let settings = viewModel.reminderSettings
        isEnabled = settings.isEnabled

        var components = DateComponents()
        components.hour = settings.hour
        components.minute = settings.minute
        reminderTime = Calendar.current.date(from: components) ?? Date()
    }

    private func saveSettings() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let settings = ReminderSettings(
            isEnabled: isEnabled,
            hour: components.hour ?? 19,
            minute: components.minute ?? 0
        )

        await viewModel.updateReminderSettings(settings)
        showingSavedAlert = true
    }
}

#Preview {
    NavigationStack {
        RemindersSettingsView(viewModel: TastingViewModel())
    }
}
