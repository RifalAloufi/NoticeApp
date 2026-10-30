import SwiftUI

// Camera access is off
struct CaptureAccessOffView: View {
    var onClose: () -> Void = {}
    var onBackToHome: () -> Void = {}

    private let darkGreen = Color(red: 38/255, green: 77/255, blue: 58/255)

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(white: 0.95))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 32))
                                .foregroundStyle(Color(white: 0.45))
                        )

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    .offset(x: 6, y: -6)
                    .accessibilityLabel("Close")
                }

                Text("Camera access is off")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(NTU.ink)

                Text("Turn it on in your iPhone Settings to take your daily photo. Your photos stay on this device.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(NTU.muted)
                    .padding(.horizontal, 28)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(darkGreen)
                        .clipShape(Capsule())
                }

                Button(action: onBackToHome) {
                    Text("Back to Home")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(darkGreen, lineWidth: 1.5)
                        )
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
        .readableWidth(Layout.focusedWidth)
        .frame(maxWidth: .infinity)
        .background(NTU.background.ignoresSafeArea())
    }
}

#Preview {
    CaptureAccessOffView()
}
