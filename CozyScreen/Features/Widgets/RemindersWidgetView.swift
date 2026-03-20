import SwiftUI
import EventKit

struct RemindersWidgetView: View {
    @StateObject private var eventKit = EventKitService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("미리알림", systemImage: "checklist")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            if !eventKit.remindersAuthorized {
                Button("미리알림 접근 허용") {
                    Task { await eventKit.requestRemindersAccess() }
                }
                .font(.system(size: 13))
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            } else if eventKit.reminders.isEmpty {
                Text("미완료 미리알림이 없습니다")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 4)
            } else {
                ForEach(eventKit.reminders, id: \.calendarItemIdentifier) { reminder in
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color(cgColor: reminder.calendar.cgColor))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(reminder.title ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            if let due = reminder.dueDateComponents?.date {
                                Text(dueDateString(due))
                                    .font(.system(size: 11))
                                    .foregroundColor(isPastDue(due) ? .red.opacity(0.8) : .white.opacity(0.5))
                            }
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

    private func dueDateString(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "오늘까지" }
        if cal.isDateInTomorrow(date) { return "내일까지" }
        if cal.isDateInYesterday(date) { return "어제 (기한 초과)" }

        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일까지"
        return f.string(from: date)
    }

    private func isPastDue(_ date: Date) -> Bool {
        date < Date()
    }
}
