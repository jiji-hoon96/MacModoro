import AppKit
import SwiftUI
import SwiftData
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let shortcutService = GlobalShortcutService.shared
    private var animationService: MenuBarAnimationService?
    private var timerStateObserver: AnyCancellable?
    private var timeTextObserver: AnyCancellable?
    private var speedObserver: AnyCancellable?
    private var settingsObservers: Set<AnyCancellable> = []

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?

    static let openSettingsNotification = Notification.Name("MacModoro.openSettings")

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupAnimationService()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleOpenSettings),
            name: Self.openSettingsNotification, object: nil
        )

        let context = ModelContext(SharedModelContainer.shared)
        TimerService.shared.configure(modelContext: context)

        timerStateObserver = TimerService.shared.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.handleTimerStateChange(state)
            }

        // #5: 남은 시간 비율에 따라 연속적으로 속도 가변
        speedObserver = TimerService.shared.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] remaining in
                self?.updateAnimationSpeed(remaining: remaining)
            }

        shortcutService.onHotKeyPressed = {
            TimerService.shared.recordFocusBreak(reason: "단축키")
        }
        shortcutService.register()

        TimerService.shared.requestNotificationPermission()

        DistractionDetector.shared.onDistraction = { appName in
            TimerService.shared.recordFocusBreak(reason: appName)
        }

        // #4: 설정 변경 즉시 반영
        observeSettingsChanges()
    }

    func applicationWillTerminate(_ notification: Notification) {
        TimerService.shared.handleAppTermination()
        shortcutService.unregister()
        animationService?.stopAnimation()
        DistractionDetector.shared.stop()
        WhiteNoiseService.shared.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    // MARK: - #4: 설정 변경 즉시 반영

    private func observeSettingsChanges() {
        let settings = AppSettings.shared

        // 아이콘 테마 변경 → 즉시 반영
        settings.$selectedAnimationTheme
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.animationService?.loadTheme()
                if TimerService.shared.state == .running {
                    self?.animationService?.startAnimation()
                } else {
                    self?.animationService?.showIdle()
                }
            }
            .store(in: &settingsObservers)

        // 시간 표시 토글 → 즉시 반영
        settings.$showRemainingTimeInMenuBar
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                if show && TimerService.shared.state == .running {
                    self?.observeTimeText()
                } else {
                    self?.animationService?.updateTimeText(nil)
                    self?.timeTextObserver?.cancel()
                }
            }
            .store(in: &settingsObservers)

        // 애니메이션 속도 변경 → 즉시 반영
        settings.$animationSpeed
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] newSpeed in
                if TimerService.shared.state == .running {
                    self?.animationService?.updateSpeed(newSpeed)
                }
            }
            .store(in: &settingsObservers)
    }

    // MARK: - Timer State → Animation

    private func handleTimerStateChange(_ state: TimerState) {
        switch state {
        case .running:
            animationService?.startAnimation()
            observeTimeText()
            DistractionDetector.shared.start()
        case .paused:
            animationService?.stopAnimation()
            animationService?.updateTimeText(nil)
            DistractionDetector.shared.stop()
        case .idle, .finished:
            animationService?.stopAnimation()
            animationService?.updateTimeText(nil)
            DistractionDetector.shared.stop()
        }
    }

    // #5: 남은 시간 비율에 따라 연속적으로 속도 가변 (느림 → 빠름)
    private func updateAnimationSpeed(remaining: Int) {
        guard TimerService.shared.state == .running else { return }
        let total = TimerService.shared.totalSeconds
        guard total > 0 else { return }

        let ratio = Double(remaining) / Double(total) // 1.0 → 0.0
        let baseSpeed = AppSettings.shared.animationSpeed

        // ratio 1.0일 때 baseSpeed, ratio 0.0일 때 baseSpeed * 0.2
        // 선형 보간: speed = baseSpeed * (0.2 + 0.8 * ratio)
        let speed = baseSpeed * (0.2 + 0.8 * ratio)

        animationService?.updateSpeed(speed)
    }

    private func observeTimeText() {
        guard AppSettings.shared.showRemainingTimeInMenuBar else {
            animationService?.updateTimeText(nil)
            timeTextObserver?.cancel()
            return
        }
        timeTextObserver = TimerService.shared.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                let text = TimerService.shared.formattedRemainingTime
                self?.animationService?.updateTimeText(text)
            }
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupAnimationService() {
        animationService = MenuBarAnimationService(statusItemButton: statusItem.button)
        animationService?.showIdle()
    }

    // MARK: - Popover

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView()
                .modelContainer(SharedModelContainer.shared)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - Settings

    @objc private func handleOpenSettings() {
        openSettings()
    }

    func openSettings() {
        popover.performClose(nil)

        if settingsWindow == nil {
            let settingsView = SettingsView()
                .modelContainer(SharedModelContainer.shared)
            let controller = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: controller)
            window.title = "MacModoro 설정"
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 480, height: 400))
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
