import SwiftUI

struct ShortcutSettingsTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("집중 깨짐 단축키") {
                    ShortcutRecorderView()
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}
