import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PomodoroSession.startedAt, order: .reverse) private var sessions: [PomodoroSession]

    var body: some View {
        VStack(spacing: 0) {
            // 통계 요약
            StatsHeaderView(sessions: sessions)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            Divider()
                .padding(.horizontal, 20)

            // 세션 목록
            if sessions.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Text("No sessions yet")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(sessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(width: 280, height: 360)
    }
}

// MARK: - Stats

private struct StatsHeaderView: View {
    let sessions: [PomodoroSession]

    var body: some View {
        HStack(spacing: 0) {
            StatColumn(label: "TODAY", value: formattedTime(todayMinutes), sub: "\(todayBreaks) breaks")
            Divider().frame(height: 36)
            StatColumn(label: "WEEK", value: formattedTime(weekMinutes), sub: "\(weekBreaks) breaks")
        }
    }

    private var todaySessions: [PomodoroSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startedAt) && $0.wasCompleted }
    }
    private var weekSessions: [PomodoroSession] {
        let start = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return sessions.filter { $0.startedAt >= start && $0.wasCompleted }
    }
    private var todayMinutes: Int { todaySessions.reduce(0) { $0 + $1.focusedMinutes } }
    private var todayBreaks: Int { todaySessions.reduce(0) { $0 + $1.breakCount } }
    private var weekMinutes: Int { weekSessions.reduce(0) { $0 + $1.focusedMinutes } }
    private var weekBreaks: Int { weekSessions.reduce(0) { $0 + $1.breakCount } }

    private func formattedTime(_ m: Int) -> String {
        if m >= 60 { return "\(m / 60)h \(m % 60)m" }
        return "\(m)m"
    }
}

private struct StatColumn: View {
    let label: String
    let value: String
    let sub: String

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
                .kerning(1.5)

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text(sub)
                .font(.system(size: 9))
                .foregroundStyle(.orange.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Row

private struct SessionRowView: View {
    let session: PomodoroSession

    var body: some View {
        HStack(spacing: 10) {
            // 시간
            Text("\(session.focusedMinutes)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(width: 32, alignment: .trailing)

            // 상세
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(session.wasCompleted ? Color.green.opacity(0.7) : Color.red.opacity(0.4))
                        .frame(width: 5, height: 5)

                    Text(session.startedAt, style: .time)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }

                if !session.goal.isEmpty {
                    Text(session.goal)
                        .font(.system(size: 11))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 깨짐
            if session.breakCount > 0 {
                Text("\(session.breakCount)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.orange.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
    }
}
