import Foundation
import Carbon.HIToolbox

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let defaultDurationMinutes = "defaultDurationMinutes"
        static let focusBreakKeyCode = "focusBreakKeyCode"
        static let focusBreakModifiers = "focusBreakModifiers"
        static let showRemainingTimeInMenuBar = "showRemainingTimeInMenuBar"
        static let enableScreenFlash = "enableScreenFlash"
        static let selectedAnimationTheme = "selectedAnimationTheme"
        static let animationSpeed = "animationSpeed"
        static let playCompletionSound = "playCompletionSound"
        static let enableDistractionDetection = "enableDistractionDetection"
    }

    // MARK: - Timer
    @Published var defaultDurationMinutes: Int {
        didSet { defaults.set(defaultDurationMinutes, forKey: Keys.defaultDurationMinutes) }
    }

    // MARK: - Focus Break Shortcut
    @Published var focusBreakKeyCode: UInt32 {
        didSet { defaults.set(focusBreakKeyCode, forKey: Keys.focusBreakKeyCode) }
    }
    @Published var focusBreakModifiers: UInt32 {
        didSet { defaults.set(focusBreakModifiers, forKey: Keys.focusBreakModifiers) }
    }

    // MARK: - Menu Bar
    @Published var showRemainingTimeInMenuBar: Bool {
        didSet { defaults.set(showRemainingTimeInMenuBar, forKey: Keys.showRemainingTimeInMenuBar) }
    }

    // MARK: - Alerts
    @Published var enableScreenFlash: Bool {
        didSet { defaults.set(enableScreenFlash, forKey: Keys.enableScreenFlash) }
    }
    @Published var playCompletionSound: Bool {
        didSet { defaults.set(playCompletionSound, forKey: Keys.playCompletionSound) }
    }

    // MARK: - Distraction
    @Published var enableDistractionDetection: Bool {
        didSet { defaults.set(enableDistractionDetection, forKey: Keys.enableDistractionDetection) }
    }

    // MARK: - Animation
    @Published var selectedAnimationTheme: String {
        didSet { defaults.set(selectedAnimationTheme, forKey: Keys.selectedAnimationTheme) }
    }
    @Published var animationSpeed: Double {
        didSet { defaults.set(animationSpeed, forKey: Keys.animationSpeed) }
    }

    private init() {
        let d = defaults

        self.defaultDurationMinutes = d.object(forKey: Keys.defaultDurationMinutes) as? Int ?? 25

        let keyCode = UInt32(d.integer(forKey: Keys.focusBreakKeyCode))
        self.focusBreakKeyCode = keyCode != 0 ? keyCode : UInt32(kVK_ANSI_B)

        let mods = UInt32(d.integer(forKey: Keys.focusBreakModifiers))
        self.focusBreakModifiers = mods != 0 ? mods : UInt32(cmdKey | shiftKey)

        self.showRemainingTimeInMenuBar = d.object(forKey: Keys.showRemainingTimeInMenuBar) as? Bool ?? false
        self.enableScreenFlash = d.object(forKey: Keys.enableScreenFlash) as? Bool ?? true
        self.playCompletionSound = d.object(forKey: Keys.playCompletionSound) as? Bool ?? true
        self.enableDistractionDetection = d.object(forKey: Keys.enableDistractionDetection) as? Bool ?? true
        self.selectedAnimationTheme = d.string(forKey: Keys.selectedAnimationTheme) ?? "cat"
        self.animationSpeed = d.object(forKey: Keys.animationSpeed) as? Double ?? 0.2
    }
}
