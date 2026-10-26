import UIKit


struct SavedPhoto: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let quest: String
    // اسم التحدي مثل "Find something red"
    let date: Date
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

    static func loadAll() -> [SavedPhoto] {
        guard let data = try? Data(contentsOf: indexURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([SavedPhoto].self, from: data)) ?? []
    }

    @discardableResult
    static func save(_ image: UIImage, quest: String) throws -> SavedPhoto {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        try data.write(to: folder.appendingPathComponent(fileName), options: .atomic)

        let item = SavedPhoto(id: id, fileName: fileName, quest: quest, date: Date())
        var all = loadAll()
        all.append(item)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(all).write(to: indexURL, options: .atomic)
        return item
    }

    static func image(for photo: SavedPhoto) -> UIImage? {
        UIImage(contentsOfFile: folder.appendingPathComponent(photo.fileName).path)
    }
}
