import SwiftUI

struct WidgetOverlayView: View {
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            // 시계: 좌측 중앙
            if settings.showClockWidget {
                VStack {
                    Spacer()
                    HStack {
                        ClockWidgetView()
                            .padding(.leading, 60)
                        Spacer()
                    }
                    Spacer()
                }
            }

            // 우측 패널: 정보 위젯들
            VStack {
                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 16) {
                        if settings.showCalendarWidget {
                            CalendarWidgetView()
                        }

                        if settings.showRemindersWidget {
                            RemindersWidgetView()
                        }

                        if settings.showMemoWidget {
                            MemoWidgetView()
                        }
                    }
                    .padding(.trailing, 40)
                }
                .padding(.top, 60)

                Spacer()
            }

            // 하단: 지금 재생 중
            if settings.showNowPlayingWidget {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NowPlayingWidgetView()
                            .padding(.bottom, 40)
                        Spacer()
                    }
                }
            }
        }
    }
}
