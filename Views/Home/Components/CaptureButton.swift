import SwiftUI

struct CaptureButton: View {
    var isEnabled: Bool = true          // false لما تخلص الكويستز الثلاثة
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 22))

                Text("Capture")
                    .font(.system(size: 17, weight: .semibold))
            }
            .offset(x: 1)
            .foregroundStyle(isEnabled ? Color.white : Color.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isEnabled ? Palette.brandPrimary : Color(white: 0.62),
                in: RoundedRectangle(cornerRadius: 25, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
