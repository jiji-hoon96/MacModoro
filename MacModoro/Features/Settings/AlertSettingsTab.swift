import SwiftUI

struct AlertSettingsTab: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("세션 종료 알림") {
                Toggle("화면 깜빡임 (5초 전)", isOn: $settings.enableScreenFlash)
                Toggle("완료 사운드", isOn: $settings.playCompletionSound)
            }

            Section("집중 깨짐 감지") {
                Toggle("SNS/영상 앱 전환 시 자동 기록", isOn: $settings.enableDistractionDetection)

                if settings.enableDistractionDetection {
                    Text("카카오톡, YouTube, Discord, Slack, Instagram 등으로 전환하면 집중 깨짐이 자동 기록됩니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
