import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PomodoroSession.startedAt, order: .reverse) private var sessions: [PomodoroSession]

    var body: some View {
        VStack(spacing: 0) {
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
