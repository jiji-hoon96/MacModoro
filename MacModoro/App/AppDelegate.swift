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

        // #4: 남은 시간에 따라 애니메이션 속도 가변
        speedObserver = TimerService.shared.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] remaining in
                self?.updateAnimationSpeed(remaining: remaining)
            }

        shortcutService.onHotKeyPressed = {
            TimerService.shared.recordFocusBreak()
        }
        shortcutService.register()

        TimerService.shared.requestNotificationPermission()
    }

    func applicationWillTerminate(_ notification: Notification) {
        TimerService.shared.handleAppTermination()
        shortcutService.unregister()
        animationService?.stopAnimation()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    // MARK: - Timer State → Animation

    private func handleTimerStateChange(_ state: TimerState) {
        switch state {
        case .running:
            animationService?.startAnimation()
            observeTimeText()
        case .paused:
            animationService?.stopAnimation()
            animationService?.updateTimeText(nil)
        case .idle, .finished:
            animationService?.stopAnimation()
            animationService?.updateTimeText(nil)
        }
    }

    private func updateAnimationSpeed(remaining: Int) {
        guard TimerService.shared.state == .running else { return }
        let total = TimerService.shared.totalSeconds
        guard total > 0 else { return }

        let ratio = Double(remaining) / Double(total)
        let baseSpeed = AppSettings.shared.animationSpeed

        let speed: Double
        if ratio < 0.1 {
            speed = baseSpeed * 0.3
        } else if ratio < 0.25 {
            speed = baseSpeed * 0.5
        } else if ratio < 0.5 {
            speed = baseSpeed * 0.7
        } else {
            speed = baseSpeed
        }

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
        popover.behavior = .semitransient
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
            window.setContentSize(NSSize(width: 480, height: 360))
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
