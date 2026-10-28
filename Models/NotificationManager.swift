import UserNotifications

// Handles asking for permission and scheduling the daily reminder
enum NotificationManager {

    // Asks the user for permission. If allowed, schedules the daily reminder.
    static func requestAndSchedule() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                scheduleDaily(hour: 18, minute: 30)
            }
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    // A notification every day at the given time
    static func scheduleDaily(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyQuest"])

        let content = UNMutableNotificationContent()
        content.title = "Notice"
        content.body = "Today's quest: find something red."
        content.sound = .default

        var time = DateComponents()
        time.hour = hour
        time.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyQuest", content: content, trigger: trigger)
        center.add(request)
    }

    // A test notification after 5 seconds
    static func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "Notice"
        content.body = "Today's quest: find something red."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testQuest", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

