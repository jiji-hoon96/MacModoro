import Carbon.HIToolbox
import AppKit

final class GlobalShortcutService {
    static let shared = GlobalShortcutService()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D4D4452), id: 1) // "MMDR"

    var onHotKeyPressed: (() -> Void)?

    private init() {}

    func register() {
        unregister()

        let settings = AppSettings.shared
        let keyCode = settings.focusBreakKeyCode
        let modifiers = settings.focusBreakModifiers

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            DispatchQueue.main.async {
                GlobalShortcutService.shared.onHotKeyPressed?()
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        var hotKeyIDVar = hotKeyID
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyIDVar,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let ref = eventHandlerRef {
            RemoveEventHandler(ref)
            eventHandlerRef = nil
        }
    }
}
