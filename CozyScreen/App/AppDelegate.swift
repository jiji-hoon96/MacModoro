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

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupAnimationService()

        let context = ModelContext(SharedModelContainer.shared)
        TimerService.shared.configure(modelContext: context)

        timerStateObserver = TimerService.shared.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.handleTimerStateChange(state)
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

    func openSettings() {
        popover.performClose(nil)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
