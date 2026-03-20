import AppKit
import SwiftUI

final class ScreenSaverController: ObservableObject {
    static let shared = ScreenSaverController()

    @Published private(set) var isActive = false

    private var windows: [NSWindow] = []
    private var localEventMonitor: Any?
    private var globalMouseMonitor: Any?

    private init() {}

    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }

    func activate() {
        guard !isActive else { return }
        isActive = true

        let screen = NSScreen.main ?? NSScreen.screens.first!
        let window = ScreenSaverWindow(screen: screen)

        let hostView = NSHostingView(
            rootView: ScreenSaverContentView(onExit: { [weak self] in
                self?.deactivate()
            })
        )
        window.contentView = hostView
        window.makeKeyAndOrderFront(nil)

        windows.append(window)
        NSCursor.hide()
        setupEventMonitors()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        removeEventMonitors()
        NSCursor.unhide()

        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
    }

    private func setupEventMonitors() {
        let settings = AppSettings.shared

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, self.isActive else { return event }

            if event.type == .keyDown && event.keyCode == 53 { // ESC
                self.deactivate()
                return nil
            }

            if settings.exitOnKeyPress && event.type == .keyDown {
                self.deactivate()
                return nil
            }

            if settings.exitOnMouseMove && event.type == .mouseMoved {
                self.deactivate()
                return nil
            }

            if event.type == .leftMouseDown || event.type == .rightMouseDown {
                self.deactivate()
                return nil
            }

            return event
        }
    }

    private func removeEventMonitors() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
    }
}
