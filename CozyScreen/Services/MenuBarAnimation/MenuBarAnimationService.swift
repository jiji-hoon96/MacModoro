import AppKit
import Combine

final class MenuBarAnimationService {
    private var animationTimer: Timer?
    private var currentFrame = 0
    private var runningFrames: [NSImage] = []
    private var idleFrames: [NSImage] = []
    private weak var statusItemButton: NSStatusBarButton?

    private let settings = AppSettings.shared

    init(statusItemButton: NSStatusBarButton?) {
        self.statusItemButton = statusItemButton
        self.idleFrames = AnimationFrameProvider.idleFrames()
        self.runningFrames = AnimationFrameProvider.runningFrames()
    }

    func startAnimation() {
        stopAnimation()
        currentFrame = 0

        animationTimer = Timer.scheduledTimer(
            withTimeInterval: settings.animationSpeed,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            self.currentFrame = (self.currentFrame + 1) % self.runningFrames.count
            self.statusItemButton?.image = self.runningFrames[self.currentFrame]
        }
    }

    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        showIdle()
    }

    func showIdle() {
        statusItemButton?.image = idleFrames.first
    }

    func updateTimeText(_ text: String?) {
        statusItemButton?.title = text.map { " \($0)" } ?? ""
    }
}
