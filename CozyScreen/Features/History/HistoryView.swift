import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PomodoroSession.startedAt, order: .reverse) private var sessions: [PomodoroSession]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("히스토리", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                Spacer()
            }

            if sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Text("아직 기록이 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 300, height: 420)
    }
}

private struct SessionRowView: View {
    let session: PomodoroSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(session.wasCompleted ? .green : .red)
                    .font(.caption)

                Text(session.startedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(session.startedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(session.focusedMinutes)분")
                    .font(.caption.bold())
            }

            if !session.goal.isEmpty {
                Text(session.goal)
                    .font(.subheadline)
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                if session.breakCount > 0 {
                    Label("\(session.breakCount)회 깨짐", systemImage: "brain.head.profile")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                let completedTodos = session.todos.filter(\.isCompleted).count
                let totalTodos = session.todos.count
                if totalTodos > 0 {
                    Label("\(completedTodos)/\(totalTodos)", systemImage: "checklist")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(8)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}
