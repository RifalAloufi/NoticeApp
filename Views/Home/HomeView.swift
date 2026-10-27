import SwiftUI
import AVFoundation

struct HomeView: View {
    var quests: [String] = ["Find something orange", "Find something red", "Find something round"]
    var entries: [DiaryItem] = []
    var onSeeAll: () -> Void = {}
    var onOpenEntry: (DiaryItem) -> Void = { _ in }

    var onPhotoSaved: ((UIImage, String) -> Void)? = nil

    // Quests finished today. When nil, every entry counts (previews).
    var completedToday: Int? = nil
    // Called after the capture screen closes, so the parent can reload saved photos
    var onCaptureFlowDismissed: () -> Void = {}

    @State private var cameraRoute: CameraRoute?

    private var completed: Int {
        min(completedToday ?? entries.count, quests.count)
    }

    private var questTitle: String {
        quests[min(completed, quests.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopPanel(questTitle: questTitle, completed: completed)

            if entries.isEmpty {
                Text("Your diary")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(height: 20)
                    .padding(.leading, 26)
                    .padding(.top, 41)

                DiaryEmptyState()
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
            } else {
                DiaryPreview(
                    items: Array(entries.reversed()),
                    onSeeAll: onSeeAll,
                    onOpen: onOpenEntry
                )
                .padding(.horizontal, 20)
                .padding(.top, 41)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            CaptureButton(isEnabled: completed < quests.count, action: captureTapped)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.white)
        }
        .fullScreenCover(item: $cameraRoute, onDismiss: onCaptureFlowDismissed) { route in
            switch route {
            case .camera:
                // entire flow
                CaptureFlowView(
                    questTitle: questTitle,
                    onSaved: onPhotoSaved.map { handler in
                        { image in handler(image, questTitle) }
                    },
                    onFinish: { cameraRoute = nil }
                )
            case .accessOff:
                CaptureAccessOffView(
                    onClose: { cameraRoute = nil },
                    onBackToHome: { cameraRoute = nil }
                )
            }
        }
    }

    private func captureTapped() {
        Task {
            let granted = await CameraPermission.request()
            cameraRoute = granted ? .camera : .accessOff
        }
    }
}

enum CameraRoute: Identifiable {
    case camera
    case accessOff

    var id: Self { self }
}

#Preview("First use") {
    HomeView()
}

#Preview("Quest active") {
    HomeView(entries: [.sampleOrange])
}

#Preview("Today and yesterday") {
    HomeView(
        entries: [.sampleForest, .sampleDesert, .sampleNight, .sampleOrange, .sampleSunset],
        completedToday: 2
    )
}

#Preview("All done") {
    HomeView(
        entries: [.sampleForest, .sampleDesert, .sampleNight, .sampleOrange, .sampleSunset, .sampleOcean],
        completedToday: 3
    )
}
