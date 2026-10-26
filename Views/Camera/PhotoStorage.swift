import UIKit

// تخزين (أوفلاين) داخل الجهاز:
//   Documents/DiaryPhotos/<uuid>.jpg   ← الصورة
//   Documents/DiaryPhotos/index.json   ← بيانات كل صورة (اسم التحدي + التاريخ والوقت)
struct SavedPhoto: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let quest: String      // اسم التحدي مثل "Find something red"
    let date: Date         // التاريخ والوقت وقت الحفظ

    // "12 Oct"
    var dayText: String {
        Self.dayFormatter.string(from: date)
    }
    // "6:30 PM"
    var timeText: String {
        Self.timeFormatter.string(from: date)
    }
    // "October 2026" (لتجميع الدايري بالأشهر)
    var monthText: String {
        Self.monthFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .none; return f
    }()
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f
    }()
}

enum PhotoStorage {
    private static var folder: URL {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DiaryPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static var indexURL: URL { folder.appendingPathComponent("index.json") }

    // كل الصور المحفوظة، الأحدث أول
    static func loadAll() -> [SavedPhoto] {
        guard let data = try? Data(contentsOf: indexURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let all = (try? decoder.decode([SavedPhoto].self, from: data)) ?? []
        return all.sorted { $0.date > $1.date }
    }

    static func groupedByMonth() -> [(month: String, photos: [SavedPhoto])] {
        var order: [String] = []
        var groups: [String: [SavedPhoto]] = [:]
        for photo in loadAll() {
            if groups[photo.monthText] == nil { order.append(photo.monthText) }
            groups[photo.monthText, default: []].append(photo)
        }
        return order.map { ($0, groups[$0] ?? []) }
    }

    @discardableResult
    static func save(_ image: UIImage, quest: String, date: Date = Date()) throws -> SavedPhoto {
        guard let data = normalized(image).jpegData(compressionQuality: 0.85) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        try data.write(to: folder.appendingPathComponent(fileName), options: .atomic)

        let item = SavedPhoto(id: id, fileName: fileName, quest: quest, date: date)

        var all: [SavedPhoto] = []
        if let existing = try? Data(contentsOf: indexURL) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            all = (try? decoder.decode([SavedPhoto].self, from: existing)) ?? []
        }
        all.append(item)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(all).write(to: indexURL, options: .atomic)
        return item
    }

    static func image(for photo: SavedPhoto) -> UIImage? {
        UIImage(contentsOfFile: folder.appendingPathComponent(photo.fileName).path)
    }

    static func delete(_ photo: SavedPhoto) {
        try? FileManager.default.removeItem(at: folder.appendingPathComponent(photo.fileName))
        let remaining = loadAll().filter { $0.id != photo.id }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try? encoder.encode(remaining).write(to: indexURL, options: .atomic)
    }

    // يثبّت اتجاه الصورة عشان ما تطلع مقلوبة بعد الحفظ
    private static func normalized(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        return UIGraphicsImageRenderer(size: image.size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
