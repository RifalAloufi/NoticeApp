import SwiftUI

struct ReminderSheet: View {
    var onTurnOn: () -> Void
    var onLater: () -> Void

    private let green = Color(red: 0.15, green: 0.31, blue: 0.25)

    var body: some View {
        VStack(spacing: 14) {
            // Bell icon
            Image(systemName: "bell")
                .font(.system(size: 22))
                .foregroundColor(.black)
                .frame(width: 68, height: 68)
                .background(Color(red: 0.93, green: 0.96, blue: 0.94))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("Want a gentle reminder?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Text("We’ll show today’s quests on top of your screen each day. You can change this any time in your iPhone settings.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            // Main button
            Button(action: onTurnOn) {
                Text("Turn on reminders")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(green)
                    .clipShape(Capsule())
            }
            .padding(.top, 14)

            // Secondary button
            Button(action: onLater) {
                Text("Maybe later")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(Capsule().stroke(green, lineWidth: 1.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 44, topTrailingRadius: 44)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ReminderSheet(onTurnOn: {}, onLater: {})
}
