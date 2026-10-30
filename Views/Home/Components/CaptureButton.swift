import SwiftUI

struct CaptureButton: View {
    // Turned off (grey) once all of today's quests are done
    var isEnabled: Bool = true
    var action: () -> Void = {}

    var body: some View {
        Button(action: { if isEnabled { action() } }) {
            HStack(spacing: 6) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 22))

                Text("Capture")
                    .font(.system(size: 17, weight: .semibold))
            }
            .offset(x: 1)
            .foregroundStyle(isEnabled ? Color.white : Palette.secondaryLabel)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Palette.brandPrimary : Palette.disabledFill, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isEnabled)
        .accessibilityHint(isEnabled ? "" : "All of today's quests are done")
    }
}
