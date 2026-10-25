import SwiftUI

struct DiaryItem: Identifiable {
    let id = UUID()
    let questName: String
    let date: String
    let photo: Image
}

extension DiaryItem {
    static let sampleOrange = DiaryItem(questName: "Find something orange", date: "12 Oct", photo: Image("sampleOrange"))
    static let sampleRed = DiaryItem(questName: "Find something red", date: "12 Oct", photo: Image("sampleRed"))
}
