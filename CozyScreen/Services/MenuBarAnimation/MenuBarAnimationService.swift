import AppKit
import Combine

final class MenuBarAnimationService {
    private var animationTimer: Timer?
    private var currentFrame = 0
    private var runningFrames: [NSImage] = []
    private var idleImage: NSImage?
    private weak var statusItemButton: NSStatusBarButton?

    private let settings = AppSettings.shared

    init(statusItemButton: NSStatusBarButton?) {
        self.statusItemButton = statusItemButton
        loadTheme()
    }

    func loadTheme() {
        let theme = settings.selectedAnimationTheme
        idleImage = AnimationFrameProvider.idleFrame(theme: theme)
        runningFrames = AnimationFrameProvider.runningFrames(theme: theme)
    }

    func startAnimation() {
        stopAnimation()
        loadTheme()
        currentFrame = 0

        animationTimer = Timer.scheduledTimer(
            withTimeInterval: settings.animationSpeed,
            repeats: true
        ) { [weak self] _ in
            guard let self, !self.runningFrames.isEmpty else { return }
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
        if idleImage == nil { loadTheme() }
        statusItemButton?.image = idleImage
    }

    func updateTimeText(_ text: String?) {
        statusItemButton?.title = text.map { " \($0)" } ?? ""
    }
}
