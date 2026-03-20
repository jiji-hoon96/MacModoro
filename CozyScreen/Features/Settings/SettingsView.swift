import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var permissions = PermissionManager.shared

    private enum Tab: String, Hashable {
        case general = "일반"
        case photos = "사진"
        case character = "캐릭터"
        case memo = "메모"
    }

    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("일반", systemImage: "gear") }
                .tag(Tab.general)

            PhotoSettingsTab()
                .tabItem { Label("사진", systemImage: "photo.on.rectangle") }
                .tag(Tab.photos)

            CharacterSettingsTab()
                .tabItem { Label("캐릭터", systemImage: "figure.walk") }
                .tag(Tab.character)

            MemoSettingsTab()
                .tabItem { Label("메모", systemImage: "note.text") }
                .tag(Tab.memo)
        }
        .frame(width: 520, height: 420)
    }
}
