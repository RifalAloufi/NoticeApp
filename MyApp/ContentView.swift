import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var showReminder = false

    var body: some View {
        ZStack {
            // Home page (from the Home folder)
            HomeView()

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
                        onLater: hideSheet
                    )
                }
                .transition(.move(edge: .bottom))
            }

            // Splash on top
            if showSplash {
                SplashView {
                    showSplash = false
                    Task {
                        try? await Task.sleep(for: .seconds(0.4))
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
                            showReminder = true
                        }
                    }
                }
            }
        }
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

#Preview {
    ContentView()
}

