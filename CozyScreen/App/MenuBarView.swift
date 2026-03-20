import SwiftUI

struct MenuBarView: View {
    @State private var permissionGranted = PermissionManager.shared.isAccessibilityGranted

    var body: some View {
        Button("스크린세이버 시작") {
            ScreenSaverController.shared.activate()
        }
        .keyboardShortcut("s", modifiers: [.command, .shift])

        Divider()

        Button("설정 열기...") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            NSApp.activate(ignoringOtherApps: true)
        }

        if !permissionGranted {
            Divider()
            Button("접근성 권한 설정...") {
                PermissionManager.shared.requestAccessibility()
            }
        }

        Divider()

        Button("종료") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
