import Foundation

struct CharacterAsset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileName: String
    var isBuiltIn: Bool

    var fileURL: URL {
        if isBuiltIn {
            return Bundle.main.url(forResource: fileName, withExtension: "usdz")
                ?? URL(fileURLWithPath: "")
        }
        return AssetManager.shared.characterDirectory.appendingPathComponent(fileName)
    }

    static let placeholder = CharacterAsset(
        id: UUID(),
        name: "기본 캐릭터",
        fileName: "default_character",
        isBuiltIn: true
    )
}
