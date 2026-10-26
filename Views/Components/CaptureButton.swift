import SwiftUI

struct CaptureButton: View {
    var isDisabled: Bool = false     
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
            .foregroundStyle(isDisabled ? Color.black : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isDisabled ? Color(white: 0.62) : Palette.brandPrimary,
                in: RoundedRectangle(cornerRadius: 25, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }
}
