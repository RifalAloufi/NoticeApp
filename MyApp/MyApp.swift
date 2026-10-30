import SwiftUI

@main
struct MyApp: App {
    @State private var showSplash = true
    @State private var showReminder = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeContainer(onAllQuestsDone: { offerReminders(after: ReminderTiming.delayAfterAllQuests) })

                // Dim background behind the sheet
                if showReminder {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                // Reminder sheet
                if showReminder {
                    VStack {
                        Spacer()
                        ReminderSheet(
                            onTurnOn: turnOnReminders,
                            onLater: remindMeLater
                        )
                    }
                    .transition(.move(edge: .bottom))
                }

                // Splash on top
                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    // Shows the reminder sheet after a short wait, only if it's a good moment (see ReminderTiming)
    func offerReminders(after delay: Double) {
        Task {
            guard !showReminder, await ReminderTiming.shouldShow() else { return }
            try? await Task.sleep(for: .seconds(delay))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
                showReminder = true
            }
        }
    }

    func remindMeLater() {
        ReminderTiming.snooze()
        hideSheet()
    }

    func hideSheet() {
        withAnimation(.easeInOut(duration: 0.35)) {
            showReminder = false
        }
    }

    func turnOnReminders() {
        Task {
            hideSheet()
            try? await Task.sleep(for: .seconds(0.4))
            await NotificationManager.requestAndSchedule()
        }
    }
}
