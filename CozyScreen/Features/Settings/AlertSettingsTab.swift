import SwiftUI

struct AlertSettingsTab: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("세션 종료 알림") {
                Toggle("화면 깜빡임 (5초 전)", isOn: $settings.enableScreenFlash)
                Toggle("완료 사운드", isOn: $settings.playCompletionSound)
            }
        }
        .padding()
    }
}
