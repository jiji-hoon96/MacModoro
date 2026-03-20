import Carbon.HIToolbox
import AppKit

final class GlobalShortcutService {
    static let shared = GlobalShortcutService()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let settings = AppSettings.shared

    private init() {}

    func register() {
        guard PermissionManager.shared.isAccessibilityGranted else {
            PermissionManager.shared.requestAccessibility()
            return
        }

        unregister()

        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard type == .keyDown else { return Unmanaged.passRetained(event) }

                let service = GlobalShortcutService.shared
                let keyCode = UInt32(event.getIntegerValueField(.keyboardEventKeycode))
                let flags = event.flags

                let expectedKey = service.settings.shortcutKeyCode
                let expectedMods = service.settings.shortcutModifiers

                var currentMods: UInt32 = 0
                if flags.contains(.maskCommand) { currentMods |= UInt32(cmdKey) }
                if flags.contains(.maskShift) { currentMods |= UInt32(shiftKey) }
                if flags.contains(.maskAlternate) { currentMods |= UInt32(optionKey) }
                if flags.contains(.maskControl) { currentMods |= UInt32(controlKey) }

                if keyCode == expectedKey && currentMods == expectedMods {
                    DispatchQueue.main.async {
                        ScreenSaverController.shared.toggle()
                    }
                    return nil
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: nil
        )

        guard let eventTap else { return }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    func unregister() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        eventTap = nil
        runLoopSource = nil
    }
}
