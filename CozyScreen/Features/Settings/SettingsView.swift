import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            TimerSettingsTab()
                .tabItem { Label("타이머", systemImage: "timer") }

            ShortcutSettingsTab()
                .tabItem { Label("단축키", systemImage: "keyboard") }

            AlertSettingsTab()
                .tabItem { Label("알림", systemImage: "bell") }

            DataSettingsTab()
                .tabItem { Label("데이터", systemImage: "externaldrive") }
        }
        .frame(width: 480, height: 360)
    }
}
