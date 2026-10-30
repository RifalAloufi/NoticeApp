import SwiftUI
import AVFoundation

struct HomeView: View {
    var quests: [String] = ["Find something orange", "Find something red", "Find something round"]

    var entries: [DiaryItem]? = nil
    var onSeeAll: () -> Void = {}
    var onOpenEntry: (DiaryItem) -> Void = { _ in }

    var onPhotoSaved: ((UIImage, String) -> Void)? = nil

    // Quests finished today. When nil, it's counted from the saved photos (or entries in previews).
    var completedToday: Int? = nil
    // Called after the capture screen closes, so the parent can reload saved photos
    var onCaptureFlowDismissed: () -> Void = {}

    @State private var cameraRoute: CameraRoute?

    // الصور المحفوظة بالجهاز (الأقدم أول)
    @State private var savedEntries: [DiaryItem] = []
    @State private var savedTodayCount = 0

    private var shownEntries: [DiaryItem] {
        entries ?? savedEntries
    }

    private var completed: Int {
        min(completedToday ?? (entries?.count ?? savedTodayCount), quests.count)
    }

    private var questTitle: String {
        quests[min(completed, quests.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopPanel(questTitle: questTitle, completed: completed)

            // We're done!
            ScrollView {
                if shownEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your diary")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(height: 20)
                            .padding(.leading, 6)
                            .padding(.top, 41)

                        DiaryEmptyState()
                            .padding(.top, 22)
                    }
                    .padding(.horizontal, 20)
                    .readableWidth()
                } else {
                    DiaryPreview(
                        items: Array(shownEntries.reversed()),
                        onSeeAll: onSeeAll,
                        onOpen: onOpenEntry
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 41)
                    .readableWidth()
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .safeAreaInset(edge: .bottom) {
            CaptureButton(isEnabled: completed < quests.count, action: captureTapped)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .readableWidth(Layout.focusedWidth)
                .background(Color.white)
        }
        .onAppear(perform: loadSaved)
        .fullScreenCover(item: $cameraRoute, onDismiss: {
            loadSaved()
            onCaptureFlowDismissed()
        }) { route in
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

    // يقرأ الصور المحفوظة (DiaryItem+Storage.swift)
    private func loadSaved() {
        savedEntries = DiaryItem.loadSaved()
        savedTodayCount = DiaryItem.completedTodayCount()
    }
}

enum CameraRoute: Identifiable {
    case camera
    case accessOff

    var id: Self { self }
}

#Preview("First use") {
    HomeView(entries: [])
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
