import SwiftUI

struct TimerSettingsTab: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("기본 설정") {
                Stepper("기본 시간: \(settings.defaultDurationMinutes)분",
                        value: $settings.defaultDurationMinutes,
                        in: 1...120)

                Toggle("메뉴바에 남은 시간 표시", isOn: $settings.showRemainingTimeInMenuBar)
            }

            Section("애니메이션") {
                Picker("테마", selection: $settings.selectedAnimationTheme) {
                    Text("고양이").tag("cat")
                }

                Slider(value: $settings.animationSpeed, in: 0.1...0.5, step: 0.05) {
                    Text("속도: \(String(format: "%.2f", settings.animationSpeed))초")
                }
            }
        }
        .padding()
    }
}
