import SwiftUI

struct SessionSummaryView: View {
    @ObservedObject var timerService: TimerService

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 8)

                    // 완료 아이콘
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.green)

                    Text("집중 완료")
                        .font(.system(size: 20, weight: .semibold))

                    // 통계
                    if let session = timerService.currentSession {
                        VStack(spacing: 10) {
                            StatRow(icon: "clock.fill", label: "집중 시간", value: "\(session.focusedMinutes)분")

                            if !session.goal.isEmpty {
                                StatRow(icon: "target", label: "목표", value: session.goal)
                            }

                            StatRow(icon: "brain.head.profile", label: "집중 깨짐", value: "\(session.breakCount)회")

                            if !session.focusBreaks.isEmpty {
                                BreakTimelineView(breaks: session.focusBreaks)
                            }
                        }
                        .padding(12)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))

                        if !session.todos.isEmpty {
                            TodoReviewView(todos: session.todos) { todo in
                                todo.isCompleted.toggle()
                                todo.completedAt = todo.isCompleted ? .now : nil
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // 완료 버튼
            Button(action: { timerService.dismiss() }) {
                Text("확인")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .padding(.top, 8)
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
                .frame(width: 18)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
        }
    }
}
