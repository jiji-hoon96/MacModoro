import AppKit

final class ScreenFlashService {
    static let shared = ScreenFlashService()

    private var dimWindows: [NSWindow] = []
    private var flashTimer: Timer?
    private var flashCount = 0

    private init() {}

    func flash() {
        guard AppSettings.shared.enableScreenFlash else { return }

        flashCount = 0
        createDimWindows()
        startFlashing()
    }

    func stop() {
        flashTimer?.invalidate()
        flashTimer = nil
        removeDimWindows()
    }

    private func createDimWindows() {
        removeDimWindows()

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.level = .floating
            window.backgroundColor = NSColor.black.withAlphaComponent(0)
            window.isOpaque = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.orderFront(nil)
            dimWindows.append(window)
        }
    }

    private func startFlashing() {
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.flashCount += 1

            // 화면이 어두워졌다 밝아지는 패턴 (opacity dim)
            let isDim = self.flashCount % 2 == 1
            let alpha: CGFloat = isDim ? 0.25 : 0

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                for window in self.dimWindows {
                    window.animator().backgroundColor = NSColor.black.withAlphaComponent(alpha)
                }
            }

            // 5초간 약 8회 (0.6초 간격)
            if self.flashCount >= 8 {
                self.stop()
            }
        }
    }

    private func removeDimWindows() {
        for window in dimWindows {
            window.orderOut(nil)
        }
        dimWindows.removeAll()
    }
}
