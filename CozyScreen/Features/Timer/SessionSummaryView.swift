import SwiftUI

struct SessionSummaryView: View {
    @ObservedObject var timerService: TimerService

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 완료 아이콘
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)

                Text("세션 완료!")
                    .font(.title2.bold())

                // 통계
                if let session = timerService.currentSession {
                    VStack(spacing: 12) {
                        StatRow(icon: "clock.fill", label: "집중 시간", value: "\(session.focusedMinutes)분")

                        if !session.goal.isEmpty {
                            StatRow(icon: "target", label: "목표", value: session.goal)
                        }

                        StatRow(icon: "brain.head.profile", label: "집중 깨짐", value: "\(session.breakCount)회")

                        // 깨짐 타임라인
                        if !session.focusBreaks.isEmpty {
                            BreakTimelineView(breaks: session.focusBreaks)
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                    // TODO 점검
                    if !session.todos.isEmpty {
                        TodoReviewView(todos: session.todos) { todo in
                            todo.isCompleted.toggle()
                            todo.completedAt = todo.isCompleted ? .now : nil
                        }
                        .padding()
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                // 완료 버튼
                Button(action: { timerService.dismiss() }) {
                    Text("확인")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
        .frame(width: 300, height: 420)
    }
}

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
