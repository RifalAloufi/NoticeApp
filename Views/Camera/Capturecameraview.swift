import SwiftUI
import AVFoundation

struct CaptureCameraView: View {
    let questTitle: String
    var session: AVCaptureSession? = nil
    var zoom: CGFloat = 1
    var isShutterDisabled: Bool = false
    var onClose: () -> Void = {}
    var onShutter: () -> Void = {}
    var onZoomChange: (CGFloat) -> Void = { _ in }
    var onFlip: () -> Void = {}

    @State private var zoomAtPinchStart: CGFloat = 1
    @State private var isPinching = false

    private var zoomLabel: String {
        abs(zoom - zoom.rounded()) < 0.05
            ? "\(Int(zoom.rounded()))x"
            : String(format: "%.1fx", zoom)
    }

    var body: some View {
        ZStack {
            NTU.cameraBlack.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    CircleCloseButton(action: onClose)
                    Spacer()
                }

                QuestHeaderCard(title: questTitle)

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

                    // مستوى الزوم: اضغط عليه يرجع 1x
                    VStack {
                        Spacer()
                        Button { onZoomChange(1) } label: {
                            Text(zoomLabel)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.45))
                                .clipShape(Capsule())
                        }
                        .accessibilityLabel("Zoom \(zoomLabel). Tap to reset")
                        .padding(.bottom, 14)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .contentShape(Rectangle())
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            if !isPinching {
                                isPinching = true
                                zoomAtPinchStart = zoom
                            }
                            onZoomChange(zoomAtPinchStart * value.magnification)
                        }
                        .onEnded { _ in
                            isPinching = false
                        }
                )

                // Controls
                HStack {
                    Color.clear.frame(width: 44, height: 44)

                    Spacer()

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

                    Spacer()

                    Button(action: onFlip) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Flip camera")
                }
                .frame(height: 70)
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
            .readableWidth(Layout.focusedWidth)
        }
    }
}

struct QuestHeaderCard: View {
    let title: String

    private let mint = Color(red: 142/255, green: 195/255, blue: 176/255)   // 8EC3B0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("YOUR QUEST")
                .font(.system(size: 13, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(mint)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    CaptureCameraView(questTitle: "Find something orange")
}
