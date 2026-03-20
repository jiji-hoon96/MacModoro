import Foundation

struct PhotoSet: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var photoFileNames: [String]

    init(id: UUID = UUID(), name: String, photoFileNames: [String] = []) {
        self.id = id
        self.name = name
        self.photoFileNames = photoFileNames
    }

    func photoURLs() -> [URL] {
        photoFileNames.map { fileName in
            AssetManager.shared.photoDirectory.appendingPathComponent(fileName)
        }
    }
}
