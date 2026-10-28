import SwiftUI

struct CaptureButton: View {
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
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Palette.brandPrimary, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
