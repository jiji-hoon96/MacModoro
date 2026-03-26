import AppKit
import Combine

final class MenuBarAnimationService {
    private var animationTimer: Timer?
    private var currentFrame = 0
    private var currentSpeed: Double
    private var runningFrames: [NSImage] = []
    private var idleImage: NSImage?
    private weak var statusItemButton: NSStatusBarButton?

    private let settings = AppSettings.shared

    init(statusItemButton: NSStatusBarButton?) {
        self.statusItemButton = statusItemButton
        self.currentSpeed = settings.animationSpeed
        loadTheme()
    }

    func loadTheme() {
        let theme = settings.selectedAnimationTheme
        idleImage = AnimationFrameProvider.idleFrame(theme: theme)
        runningFrames = AnimationFrameProvider.runningFrames(theme: theme)
    }

    func startAnimation() {
        stopAnimationOnly()
        loadTheme()
        currentFrame = 0
        currentSpeed = settings.animationSpeed
        scheduleTimer()
    }

    func updateSpeed(_ speed: Double) {
        guard abs(speed - currentSpeed) > 0.02 else { return }
        currentSpeed = speed
        animationTimer?.invalidate()
        scheduleTimer()
    }

    func stopAnimation() {
        stopAnimationOnly()
        showIdle()
    }

    func showIdle() {
        if idleImage == nil { loadTheme() }
        statusItemButton?.image = idleImage
    }

    func updateTimeText(_ text: String?) {
        statusItemButton?.title = text.map { " \($0)" } ?? ""
    }

    private func stopAnimationOnly() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    private func scheduleTimer() {
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: currentSpeed,
            repeats: true
        ) { [weak self] _ in
            guard let self, !self.runningFrames.isEmpty else { return }
            self.currentFrame = (self.currentFrame + 1) % self.runningFrames.count
            self.statusItemButton?.image = self.runningFrames[self.currentFrame]
        }
    }
}
