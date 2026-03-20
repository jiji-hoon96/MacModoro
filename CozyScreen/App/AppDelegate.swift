import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let shortcutService = GlobalShortcutService.shared
    private let screenSaverController = ScreenSaverController.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        shortcutService.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        shortcutService.unregister()
        screenSaverController.deactivate()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
