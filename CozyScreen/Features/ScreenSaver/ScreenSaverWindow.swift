import AppKit

final class ScreenSaverWindow: NSWindow {
    convenience init(screen: NSScreen) {
        self.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.setFrame(screen.frame, display: true)
        self.level = .statusBar
        self.isOpaque = true
        self.hasShadow = false
        self.backgroundColor = .black
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.acceptsMouseMovedEvents = true
        self.isMovableByWindowBackground = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
