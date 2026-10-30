import SwiftUI

struct DiaryItem: Identifiable {
    let id = UUID()
    let questName: String
    let date: String
    let photo: Image
    // When the photo was taken. The diary uses it to show today's and yesterday's photos.
    var takenAt: Date = Date()
    // The saved photo this tile shows (nil for sample items)
    var savedID: UUID? = nil
}

extension DiaryItem {
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    // Sample photos for previews only
    static let sampleOrange = DiaryItem(questName: "Find something orange", date: "27 Oct", photo: Image("sampleOrange"))
    static let sampleSunset = DiaryItem(questName: "Find beautiful light", date: "27 Oct", photo: Image("sampleSunset"))
    static let sampleOcean = DiaryItem(questName: "Find a reflection to keep", date: "27 Oct", photo: Image("sampleOcean"))
    static let sampleForest = DiaryItem(questName: "Find something growing", date: "26 Oct", photo: Image("sampleForest"), takenAt: daysAgo(1))
    static let sampleDesert = DiaryItem(questName: "Find a line that leads on", date: "26 Oct", photo: Image("sampleDesert"), takenAt: daysAgo(1))
    static let sampleNight = DiaryItem(questName: "Find calm in a busy place", date: "26 Oct", photo: Image("sampleNight"), takenAt: daysAgo(1))
    static func loadSaved() -> [DiaryItem] {
        PhotoStorage.loadAll().reversed().compactMap { saved in
            guard let ui = PhotoStorage.thumbnail(for: saved) else { return nil }
            return DiaryItem(
                questName: saved.quest,
                date: saved.dayText,
                photo: Image(uiImage: ui),
                takenAt: saved.date,
                savedID: saved.id
            )
        }
    }
 
//the count of the copleted quests
    static func completedTodayCount() -> Int {
        PhotoStorage.loadAll()
            .filter { Calendar.current.isDateInToday($0.date) }
            .count
    }
}
