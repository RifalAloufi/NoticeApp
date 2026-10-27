import SwiftUI

/// Connects HomeView to today's quests and the photos saved on the device.
/// Everything is read from local storage, so it works offline.
struct HomeContainer: View {
    @State private var photos: [SavedPhoto] = PhotoStorage.loadAll()
    @State private var today = Date()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        HomeView(
            quests: QuestProvider.quests(for: today),
            entries: photos.compactMap(DiaryItem.init),
            completedToday: photosTakenToday,
            onCaptureFlowDismissed: reload
        )
        // Pick up a new day (new quests, progress back to 0) when the app comes back
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload() }
        }
    }

    private var photosTakenToday: Int {
        photos.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }.count
    }

    private func reload() {
        today = Date()
        photos = PhotoStorage.loadAll()
    }
}

private extension DiaryItem {
    init?(_ photo: SavedPhoto) {
        guard let image = PhotoStorage.image(for: photo) else { return nil }
        self.init(
            questName: photo.quest,
            date: photo.date.formatted(.dateTime.day().month(.abbreviated)),
            photo: Image(uiImage: image),
            takenAt: photo.date
        )
    }
}
