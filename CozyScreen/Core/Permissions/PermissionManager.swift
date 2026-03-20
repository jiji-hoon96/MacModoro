import AppKit
import ApplicationServices

final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published var isAccessibilityGranted: Bool = false

    private init() {
        checkAccessibility()
    }

    func checkAccessibility() {
        isAccessibilityGranted = AXIsProcessTrusted()
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        isAccessibilityGranted = trusted

        if !trusted {
            startPollingForPermission()
        }
    }

    private func startPollingForPermission() {
        Task { @MainActor in
            while !isAccessibilityGranted {
                try? await Task.sleep(for: .seconds(2))
                checkAccessibility()
            }
            GlobalShortcutService.shared.register()
        }
    }
}
