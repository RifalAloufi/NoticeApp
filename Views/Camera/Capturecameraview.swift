import SwiftUI
import AVFoundation

// Camera with quest (dark)
struct CaptureCameraView: View {
    let questTitle: String
    var session: AVCaptureSession? = nil         
    var isShutterDisabled: Bool = false
    var onClose: () -> Void = {}
    var onShutter: () -> Void = {}

    var body: some View {
        ZStack {
            NTU.cameraBlack.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    CircleCloseButton(action: onClose)
                    Spacer()
                }

                CaptureQuestCard(label: "YOUR QUEST", title: questTitle)

                // Viewfinder
                ZStack {
                    Rectangle().fill(Color(white: 0.08))

                    if let session {
                        LiveCameraPreview(session: session)
                    }

                    ThirdsGrid()
                        .stroke(Color.white.opacity(0.18), lineWidth: 0.5)

                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1.2)
                        .frame(width: 44, height: 44)

                    CornerBrackets()
                        .stroke(Color.white.opacity(0.75), lineWidth: 1.8)
                        .padding(10)

                    VStack {
                        Spacer()
                        Text("1x")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.bottom, 14)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Shutter
                Button(action: onShutter) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 58, height: 58)
                    }
                    .opacity(isShutterDisabled ? 0.5 : 1)
                }
                .disabled(isShutterDisabled)
                .accessibilityLabel("Take photo")
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    CaptureCameraView(questTitle: "Find something orange")
}
