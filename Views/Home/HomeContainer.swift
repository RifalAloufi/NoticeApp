import SwiftUI

// The screens you can open from Home
enum DiaryRoute: Hashable {
    case diary                          // "See all": years and months
    case month(name: String, year: Int) // one month's photos
    case photo(UUID)                    // one saved photo
}

/// Connects Home to today's quests, the photos saved on the device, and the diary screens.
/// Everything is read from local storage, so it works offline.
///
///   Home ── See all ──▶ DiaryView ──▶ MonthView ──▶ PhotoDetails ──▶ ShareView
///    └──── diary photo ──────────────────────────────▶ PhotoDetails
///    └──── Capture ──▶ camera ──▶ saved photo ──▶ back to Home
struct HomeContainer: View {
    // Called once, right after the last of today's quests is finished (used to offer daily reminders)
    var onAllQuestsDone: () -> Void = {}

    @State private var photos: [SavedPhoto] = PhotoStorage.loadAll()
    @State private var today = Date()
    @State private var path: [DiaryRoute] = []
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                quests: QuestProvider.quests(for: today),
                entries: photos.compactMap { DiaryItem($0) },
                onSeeAll: { path.append(.diary) },
                onOpenEntry: { item in
                    if let id = item.savedID { path.append(.photo(id)) }
                },
                completedToday: photosTakenToday,
                onCaptureFlowDismissed: reload
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: DiaryRoute.self) { route in
                switch route {
                case .diary:
                    DiaryView()
                case .month(let name, let year):
                    MonthView(month: name, year: year)
                case .photo(let id):
                    PhotoDetails(photoID: id)
                }
            }
        }
        // Pick up a new day (new quests, progress back to 0) when the app comes back
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload() }
        }
        // Coming back from the diary or a photo (a photo may have been deleted)
        .onChange(of: path) { _, _ in reload() }
    }

    private var photosTakenToday: Int {
        photos.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }.count
    }

    private func reload() {
        let doneBefore = photosTakenToday
        today = Date()
        photos = PhotoStorage.loadAll()
        let perDay = QuestProvider.questsPerDay
        if doneBefore < perDay && photosTakenToday >= perDay { onAllQuestsDone() }
    }
}

private extension DiaryItem {
    init?(_ photo: SavedPhoto) {
        guard let image = PhotoStorage.thumbnail(for: photo) else { return nil }
        self.init(
            questName: photo.quest,
            date: photo.date.formatted(.dateTime.day().month(.abbreviated)),
            photo: Image(uiImage: image),
            takenAt: photo.date,
            savedID: photo.id
        )
    }
}
