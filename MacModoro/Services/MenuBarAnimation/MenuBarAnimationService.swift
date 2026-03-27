import AppKit
import Combine

final class MenuBarAnimationService {
    private var displayLink: CVDisplayLink?
    private var animationTimer: Timer?
    private var currentFrame = 0
    private var currentSpeed: Double
    private var lastFrameTime: CFTimeInterval = 0
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
        // 속도 차이가 0.05 미만이면 타이머 재생성 안 함 (wakes 절감)
        guard abs(speed - currentSpeed) > 0.05 else { return }
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
        // tolerance를 설정하여 OS가 타이머를 합칠 수 있게 함 (에너지 절감)
        let timer = Timer(timeInterval: currentSpeed, repeats: true) { [weak self] _ in
            guard let self, !self.runningFrames.isEmpty else { return }
            self.currentFrame = (self.currentFrame + 1) % self.runningFrames.count
            self.statusItemButton?.image = self.runningFrames[self.currentFrame]
        }
        timer.tolerance = currentSpeed * 0.3 // 30% 허용 오차 → OS가 wakes 합침
        RunLoop.main.add(timer, forMode: .common)
        animationTimer = timer
    }
}
