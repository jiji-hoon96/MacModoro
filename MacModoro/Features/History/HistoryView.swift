import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PomodoroSession.startedAt, order: .reverse) private var sessions: [PomodoroSession]

    var body: some View {
        VStack(spacing: 0) {
            // 통계 요약
            StatsHeaderView(sessions: sessions)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()
                .padding(.horizontal, 16)

            // 세션 목록
            if sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.quaternary)
                    Text("아직 기록이 없습니다")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(sessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(width: 300, height: 380)
    }
}

// MARK: - 오늘/이번주 통계

private struct StatsHeaderView: View {
    let sessions: [PomodoroSession]

    var body: some View {
        HStack(spacing: 12) {
            StatBlock(
                title: "오늘",
                minutes: todayMinutes,
                breaks: todayBreaks
            )
            StatBlock(
                title: "이번 주",
                minutes: weekMinutes,
                breaks: weekBreaks
            )
        }
    }

    private var todaySessions: [PomodoroSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startedAt) && $0.wasCompleted }
    }

    private var weekSessions: [PomodoroSession] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return sessions.filter { $0.startedAt >= startOfWeek && $0.wasCompleted }
    }

    private var todayMinutes: Int { todaySessions.reduce(0) { $0 + $1.focusedMinutes } }
    private var todayBreaks: Int { todaySessions.reduce(0) { $0 + $1.breakCount } }
    private var weekMinutes: Int { weekSessions.reduce(0) { $0 + $1.focusedMinutes } }
    private var weekBreaks: Int { weekSessions.reduce(0) { $0 + $1.breakCount } }
}

private struct StatBlock: View {
    let title: String
    let minutes: Int
    let breaks: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)

            Text(formattedTime)
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            HStack(spacing: 3) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 9))
                Text("\(breaks)회")
                    .font(.system(size: 10))
            }
            .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
    }

    private var formattedTime: String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - 세션 행

private struct SessionRowView: View {
    let session: PomodoroSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(session.wasCompleted ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 6, height: 6)

                Text(session.startedAt, style: .date)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Text(session.startedAt, style: .time)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)

                Spacer()

                Text("\(session.focusedMinutes)분")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }

            if !session.goal.isEmpty {
                Text(session.goal)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }

            if session.breakCount > 0 || !session.todos.isEmpty {
                HStack(spacing: 8) {
                    if session.breakCount > 0 {
                        Label("\(session.breakCount)회", systemImage: "brain.head.profile")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                    }

                    let done = session.todos.filter(\.isCompleted).count
                    let total = session.todos.count
                    if total > 0 {
                        Label("\(done)/\(total)", systemImage: "checklist")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
    }
}
