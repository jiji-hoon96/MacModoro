import Foundation
import Carbon.HIToolbox

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let shortcutKeyCode = "shortcutKeyCode"
        static let shortcutModifiers = "shortcutModifiers"
        static let exitOnMouseMove = "exitOnMouseMove"
        static let exitOnKeyPress = "exitOnKeyPress"
        static let showMemoOverlay = "showMemoOverlay"
        static let selectedCharacterID = "selectedCharacterID"
        static let selectedPhotoSetID = "selectedPhotoSetID"
        static let photoTransitionInterval = "photoTransitionInterval"
        static let availableCharacters = "availableCharacters"
        static let photoSets = "photoSets"
        static let selectedBackgroundID = "selectedBackgroundID"
    }

    @Published var shortcutKeyCode: UInt32 {
        didSet { defaults.set(shortcutKeyCode, forKey: Keys.shortcutKeyCode) }
    }

    @Published var shortcutModifiers: UInt32 {
        didSet { defaults.set(shortcutModifiers, forKey: Keys.shortcutModifiers) }
    }

    @Published var exitOnMouseMove: Bool {
        didSet { defaults.set(exitOnMouseMove, forKey: Keys.exitOnMouseMove) }
    }

    @Published var exitOnKeyPress: Bool {
        didSet { defaults.set(exitOnKeyPress, forKey: Keys.exitOnKeyPress) }
    }

    @Published var showMemoOverlay: Bool {
        didSet { defaults.set(showMemoOverlay, forKey: Keys.showMemoOverlay) }
    }

    @Published var selectedCharacterID: String? {
        didSet { defaults.set(selectedCharacterID, forKey: Keys.selectedCharacterID) }
    }

    @Published var selectedPhotoSetID: String? {
        didSet { defaults.set(selectedPhotoSetID, forKey: Keys.selectedPhotoSetID) }
    }

    @Published var photoTransitionInterval: TimeInterval {
        didSet { defaults.set(photoTransitionInterval, forKey: Keys.photoTransitionInterval) }
    }

    @Published var selectedBackgroundID: String? {
        didSet { defaults.set(selectedBackgroundID, forKey: Keys.selectedBackgroundID) }
    }

    var availableCharacters: [CharacterAsset] {
        get {
            guard let data = defaults.data(forKey: Keys.availableCharacters),
                  let chars = try? JSONDecoder().decode([CharacterAsset].self, from: data) else {
                return [.placeholder]
            }
            return chars
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.availableCharacters)
            }
            objectWillChange.send()
        }
    }

    var photoSets: [PhotoSet] {
        get {
            guard let data = defaults.data(forKey: Keys.photoSets),
                  let sets = try? JSONDecoder().decode([PhotoSet].self, from: data) else {
                return []
            }
            return sets
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.photoSets)
            }
            objectWillChange.send()
        }
    }

    var selectedCharacter: CharacterAsset {
        if let id = selectedCharacterID,
           let uuid = UUID(uuidString: id),
           let char = availableCharacters.first(where: { $0.id == uuid }) {
            return char
        }
        return .placeholder
    }

    var selectedPhotoSet: PhotoSet? {
        if let id = selectedPhotoSetID,
           let uuid = UUID(uuidString: id) {
            return photoSets.first(where: { $0.id == uuid })
        }
        return photoSets.first
    }

    private init() {
        let d = defaults

        let keyCode = UInt32(d.integer(forKey: Keys.shortcutKeyCode))
        self.shortcutKeyCode = keyCode != 0 ? keyCode : UInt32(kVK_ANSI_S)

        let mods = UInt32(d.integer(forKey: Keys.shortcutModifiers))
        self.shortcutModifiers = mods != 0 ? mods : UInt32(cmdKey | shiftKey)

        self.exitOnMouseMove = d.object(forKey: Keys.exitOnMouseMove) as? Bool ?? false
        self.exitOnKeyPress = d.object(forKey: Keys.exitOnKeyPress) as? Bool ?? true
        self.showMemoOverlay = d.object(forKey: Keys.showMemoOverlay) as? Bool ?? true
        self.selectedCharacterID = d.string(forKey: Keys.selectedCharacterID)
        self.selectedPhotoSetID = d.string(forKey: Keys.selectedPhotoSetID)
        self.photoTransitionInterval = d.object(forKey: Keys.photoTransitionInterval) as? TimeInterval ?? 10.0
        self.selectedBackgroundID = d.string(forKey: Keys.selectedBackgroundID)
    }
}
