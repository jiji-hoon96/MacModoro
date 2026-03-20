import SwiftUI

struct WidgetSettingsTab: View {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var eventKit = EventKitService.shared

    var body: some View {
        Form {
            Section("위젯 표시") {
                Toggle("시계", isOn: $settings.showClockWidget)
                Toggle("메모", isOn: $settings.showMemoWidget)
                Toggle("Apple 캘린더", isOn: $settings.showCalendarWidget)
                Toggle("Apple 미리알림", isOn: $settings.showRemindersWidget)
                Toggle("지금 재생 중 (Music/Spotify)", isOn: $settings.showNowPlayingWidget)
            }

            Section("시계 설정") {
                Toggle("24시간 형식", isOn: $settings.use24HourClock)
            }

            Section("캘린더 설정") {
                Picker("일정 표시 범위", selection: $settings.calendarHorizonHours) {
                    Text("12시간").tag(12)
                    Text("24시간").tag(24)
                    Text("48시간").tag(48)
                    Text("7일").tag(168)
                }

                HStack {
                    Image(systemName: eventKit.calendarAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(eventKit.calendarAuthorized ? .green : .red)
                    Text("캘린더 권한")
                    Spacer()
                    if !eventKit.calendarAuthorized {
                        Button("권한 요청") {
                            Task { await eventKit.requestCalendarAccess() }
                        }
                    }
                }

                HStack {
                    Image(systemName: eventKit.remindersAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(eventKit.remindersAuthorized ? .green : .red)
                    Text("미리알림 권한")
                    Spacer()
                    if !eventKit.remindersAuthorized {
                        Button("권한 요청") {
                            Task { await eventKit.requestRemindersAccess() }
                        }
                    }
                }
            }

            Section("위젯 스타일") {
                HStack {
                    Text("위젯 투명도")
                    Slider(value: $settings.widgetOpacity, in: 0.3...1.0, step: 0.05)
                    Text("\(Int(settings.widgetOpacity * 100))%")
                        .frame(width: 40)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            eventKit.checkPermissions()
        }
    }
}
