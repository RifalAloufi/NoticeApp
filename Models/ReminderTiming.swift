import Foundation
import UserNotifications

/// Decides when the "Want a gentle reminder?" sheet may be shown.
///
/// Apple's guidance is to ask for notification permission in a moment that makes
/// the reason obvious, not at first launch. Notice asks once the person has finished
/// all of the day's quests, when a daily reminder clearly makes sense.
/// If they pick "Maybe later", the sheet stays away for a few days.
enum ReminderTiming {
    // How long "Maybe later" keeps the sheet away
    static let snoozeDays = 3

    // How long to wait after the last quest is done before the sheet slides in,
    // so the person first enjoys the "Lovely, all quests done!" moment on Home
    static let delayAfterAllQuests: Double = 2.0

    private static let laterKey = "reminderPromptLaterDate"

    /// "Maybe later" was tapped: don't ask again for `snoozeDays` days
    static func snooze() {
        UserDefaults.standard.set(Date(), forKey: laterKey)
    }

    /// True only while the system has never been asked (the system prompt can only appear
    /// once) and "Maybe later" isn't still in effect.
    static func shouldShow() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return false }

        if let later = UserDefaults.standard.object(forKey: laterKey) as? Date {
            let snoozeSeconds = Double(snoozeDays) * 24 * 60 * 60
            if Date().timeIntervalSince(later) < snoozeSeconds { return false }
        }
        return true
    }
}
