import SwiftUI

struct AfterCaptureView: View {
    let questTitle: String
    var photo: Image? = nil
    var onClose: () -> Void = {}
    var onRetake: () -> Void = {}
    var onSave: () -> Void = {}

    var body: some View {
        ZStack {
            NTU.cameraBlack.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    CircleCloseButton(action: onClose)
                    Spacer()
                }

                CaptureQuestCard(label: "YOUR QUEST", title: questTitle)
                Color(white: 0.08)
                    .overlay {
                        if let photo {
                            photo
                                .resizable()
                                .scaledToFill()
                        } else {
                            Text("your photo")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                // Actions
                HStack(spacing: 10) {
                    Button("Retake", action: onRetake)
                        .buttonStyle(NTUSecondaryButtonStyle())
                        .frame(width: 110)

                    Button("Save to diary", action: onSave)
                        .buttonStyle(NTUPrimaryButtonStyle())
                }
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
            .readableWidth(Layout.focusedWidth)
        }
    }
}

#Preview {
    AfterCaptureView(questTitle: "Find something orange")
}
