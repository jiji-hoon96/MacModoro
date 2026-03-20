import SwiftUI
import EventKit

struct CalendarWidgetView: View {
    @StateObject private var eventKit = EventKitService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("다가오는 일정", systemImage: "calendar")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            if !eventKit.calendarAuthorized {
                Button("캘린더 접근 허용") {
                    Task { await eventKit.requestCalendarAccess() }
                }
                .font(.system(size: 13))
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            } else if eventKit.calendarEvents.isEmpty {
                Text("예정된 일정이 없습니다")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 4)
            } else {
                ForEach(eventKit.calendarEvents, id: \.eventIdentifier) { event in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(cgColor: event.calendar.cgColor))
                            .frame(width: 4, height: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(eventTimeString(event))
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
        .frame(width: 240, alignment: .leading)
        .widgetCard()
        .onAppear {
            Task { await eventKit.refreshAll() }
        }
    }

    private func eventTimeString(_ event: EKEvent) -> String {
        if event.isAllDay { return "종일" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        let start = f.string(from: event.startDate)

        if Calendar.current.isDateInToday(event.startDate) {
            return "오늘 \(start)"
        } else if Calendar.current.isDateInTomorrow(event.startDate) {
            return "내일 \(start)"
        } else {
            let dayF = DateFormatter()
            dayF.locale = Locale(identifier: "ko_KR")
            dayF.dateFormat = "M/d a h:mm"
            return dayF.string(from: event.startDate)
        }
    }
}
