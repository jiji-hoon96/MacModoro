import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("일반", systemImage: "gear") }

            PhotoSettingsTab()
                .tabItem { Label("사진", systemImage: "photo.on.rectangle") }

            WidgetSettingsTab()
                .tabItem { Label("위젯", systemImage: "square.grid.2x2") }

            MemoSettingsTab()
                .tabItem { Label("메모", systemImage: "note.text") }
        }
        .frame(width: 520, height: 460)
    }
}
