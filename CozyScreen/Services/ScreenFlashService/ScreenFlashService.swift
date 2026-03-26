import AppKit

final class ScreenFlashService {
    static let shared = ScreenFlashService()

    private var flashWindows: [NSWindow] = []
    private var flashTimer: Timer?
    private var flashCount = 0

    private init() {}

    func flash() {
        guard AppSettings.shared.enableScreenFlash else { return }

        flashCount = 0
        createFlashWindows()
        startFlashing()
    }

    func stop() {
        flashTimer?.invalidate()
        flashTimer = nil
        removeFlashWindows()
    }

    private func createFlashWindows() {
        removeFlashWindows()

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.level = .floating
            window.backgroundColor = NSColor.red.withAlphaComponent(0)
            window.isOpaque = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.orderFront(nil)
            flashWindows.append(window)
        }
    }

    private func startFlashing() {
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.flashCount += 1

            let isOn = self.flashCount % 2 == 1
            let alpha: CGFloat = isOn ? 0.15 : 0

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                for window in self.flashWindows {
                    window.animator().backgroundColor = NSColor.red.withAlphaComponent(alpha)
                }
            }

            // 5초 = 10회 (0.5초 간격)
            if self.flashCount >= 10 {
                self.stop()
            }
        }
    }

    private func removeFlashWindows() {
        for window in flashWindows {
            window.orderOut(nil)
        }
        flashWindows.removeAll()
    }
}
