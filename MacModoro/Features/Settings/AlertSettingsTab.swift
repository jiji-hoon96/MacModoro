import SwiftUI

struct AlertSettingsTab: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("세션 종료 알림") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("화면 깜빡임 (5초 전)", isOn: $settings.enableScreenFlash)
                        Toggle("완료 사운드", isOn: $settings.playCompletionSound)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("집중 깨짐 감지") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("SNS/메신저 앱 전환 시 자동 기록", isOn: $settings.enableDistractionDetection)

                        if settings.enableDistractionDetection {
                            Text("카카오톡, Discord, Slack, Telegram, Instagram, WhatsApp 등으로 전환하면 집중 깨짐이 자동 기록됩니다. (10초 쿨다운)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}
