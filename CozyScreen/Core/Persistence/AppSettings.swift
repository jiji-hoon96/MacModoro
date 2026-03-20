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
        static let selectedPhotoSetID = "selectedPhotoSetID"
        static let photoTransitionInterval = "photoTransitionInterval"
        static let photoSets = "photoSets"
        static let showClockWidget = "showClockWidget"
        static let showMemoWidget = "showMemoWidget"
        static let showRemindersWidget = "showRemindersWidget"
        static let showCalendarWidget = "showCalendarWidget"
        static let showNowPlayingWidget = "showNowPlayingWidget"
        static let use24HourClock = "use24HourClock"
        static let calendarHorizonHours = "calendarHorizonHours"
        static let widgetOpacity = "widgetOpacity"
    }

    // MARK: - Shortcut
    @Published var shortcutKeyCode: UInt32 {
        didSet { defaults.set(shortcutKeyCode, forKey: Keys.shortcutKeyCode) }
    }
    @Published var shortcutModifiers: UInt32 {
        didSet { defaults.set(shortcutModifiers, forKey: Keys.shortcutModifiers) }
    }

    // MARK: - Exit Behavior
    @Published var exitOnMouseMove: Bool {
        didSet { defaults.set(exitOnMouseMove, forKey: Keys.exitOnMouseMove) }
    }
    @Published var exitOnKeyPress: Bool {
        didSet { defaults.set(exitOnKeyPress, forKey: Keys.exitOnKeyPress) }
    }

    // MARK: - Photos
    @Published var selectedPhotoSetID: String? {
        didSet { defaults.set(selectedPhotoSetID, forKey: Keys.selectedPhotoSetID) }
    }
    @Published var photoTransitionInterval: TimeInterval {
        didSet { defaults.set(photoTransitionInterval, forKey: Keys.photoTransitionInterval) }
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

    var selectedPhotoSet: PhotoSet? {
        if let id = selectedPhotoSetID,
           let uuid = UUID(uuidString: id) {
            return photoSets.first(where: { $0.id == uuid })
        }
        return photoSets.first
    }

    // MARK: - Widget Toggles
    @Published var showClockWidget: Bool {
        didSet { defaults.set(showClockWidget, forKey: Keys.showClockWidget) }
    }
    @Published var showMemoWidget: Bool {
        didSet { defaults.set(showMemoWidget, forKey: Keys.showMemoWidget) }
    }
    @Published var showRemindersWidget: Bool {
        didSet { defaults.set(showRemindersWidget, forKey: Keys.showRemindersWidget) }
    }
    @Published var showCalendarWidget: Bool {
        didSet { defaults.set(showCalendarWidget, forKey: Keys.showCalendarWidget) }
    }
    @Published var showNowPlayingWidget: Bool {
        didSet { defaults.set(showNowPlayingWidget, forKey: Keys.showNowPlayingWidget) }
    }

    // MARK: - Widget Config
    @Published var use24HourClock: Bool {
        didSet { defaults.set(use24HourClock, forKey: Keys.use24HourClock) }
    }
    @Published var calendarHorizonHours: Int {
        didSet { defaults.set(calendarHorizonHours, forKey: Keys.calendarHorizonHours) }
    }
    @Published var widgetOpacity: Double {
        didSet { defaults.set(widgetOpacity, forKey: Keys.widgetOpacity) }
    }

    private init() {
        let d = defaults

        let keyCode = UInt32(d.integer(forKey: Keys.shortcutKeyCode))
        self.shortcutKeyCode = keyCode != 0 ? keyCode : UInt32(kVK_ANSI_S)

        let mods = UInt32(d.integer(forKey: Keys.shortcutModifiers))
        self.shortcutModifiers = mods != 0 ? mods : UInt32(cmdKey | shiftKey)

        self.exitOnMouseMove = d.object(forKey: Keys.exitOnMouseMove) as? Bool ?? false
        self.exitOnKeyPress = d.object(forKey: Keys.exitOnKeyPress) as? Bool ?? true
        self.selectedPhotoSetID = d.string(forKey: Keys.selectedPhotoSetID)
        self.photoTransitionInterval = d.object(forKey: Keys.photoTransitionInterval) as? TimeInterval ?? 10.0

        self.showClockWidget = d.object(forKey: Keys.showClockWidget) as? Bool ?? true
        self.showMemoWidget = d.object(forKey: Keys.showMemoWidget) as? Bool ?? true
        self.showRemindersWidget = d.object(forKey: Keys.showRemindersWidget) as? Bool ?? true
        self.showCalendarWidget = d.object(forKey: Keys.showCalendarWidget) as? Bool ?? true
        self.showNowPlayingWidget = d.object(forKey: Keys.showNowPlayingWidget) as? Bool ?? true
        self.use24HourClock = d.object(forKey: Keys.use24HourClock) as? Bool ?? true
        self.calendarHorizonHours = d.object(forKey: Keys.calendarHorizonHours) as? Int ?? 24
        self.widgetOpacity = d.object(forKey: Keys.widgetOpacity) as? Double ?? 0.85
    }
}
