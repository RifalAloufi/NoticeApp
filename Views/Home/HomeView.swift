import SwiftUI
import AVFoundation

struct HomeView: View {
    var quests: [String] = ["Find something orange", "Find something red", "Find something round"]
    var entries: [DiaryItem] = []
    var onSeeAll: () -> Void = {}
    var onOpenEntry: (DiaryItem) -> Void = { _ in }

    var onPhotoSaved: ((UIImage, String) -> Void)? = nil

    @State private var cameraRoute: CameraRoute?

    // MARK: Storage
    @State private var savedEntries: [DiaryItem] = []   // الصور المحفوظة بالجهاز (الأقدم أول)
    @State private var todayCount = 0                   // عدد صور اليوم

    // لو مررت entries (مثلاً في الـ Preview) نستخدمها، وإلا نقرأ من الجهاز
    private var shownEntries: [DiaryItem] {
        entries.isEmpty ? savedEntries : entries
    }

    private var completed: Int {
        min(entries.isEmpty ? todayCount : entries.count, quests.count)
    }

    private var questTitle: String {
        quests[min(completed, quests.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopPanel(questTitle: questTitle, completed: completed)

            if shownEntries.isEmpty {
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
                    items: Array(shownEntries.reversed()),
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
            CaptureButton(isDisabled: completed >= quests.count, action: captureTapped)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.white)
        }
        .onAppear(perform: loadSaved)                                  // جديد
        .fullScreenCover(item: $cameraRoute, onDismiss: loadSaved) { route in   // onDismiss جديد
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

    // MARK: Storage (جديد): يقرأ الصور المحفوظة ويحوّلها لـ DiaryItem
    private func loadSaved() {
        let saved = PhotoStorage.loadAll()          // الأحدث أول
        todayCount = saved.filter { Calendar.current.isDateInToday($0.date) }.count
        savedEntries = saved.reversed().compactMap { photo in
            guard let ui = PhotoStorage.image(for: photo) else { return nil }
            return DiaryItem(
                questName: photo.quest,
                date: photo.dayText,
                photo: Image(uiImage: ui)
            )
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
