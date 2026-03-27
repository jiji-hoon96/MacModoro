import SwiftUI

struct SessionSummaryView: View {
    @ObservedObject var timerService: TimerService
    @State private var refreshID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 8)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.green)

                    Text("집중 완료")
                        .font(.system(size: 20, weight: .semibold))

                    if let session = timerService.currentSession {
                        // 통계 카드
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

                        // TODO 점검 카드
                        if !session.todos.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                let completed = session.todos.filter(\.isCompleted).count
                                let total = session.todos.count

                                HStack {
                                    Label("할 일 점검", systemImage: "checklist")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Text("\(completed)/\(total) 완료")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(completed == total ? .green : .orange)
                                }

                                // 진행률 바
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.primary.opacity(0.08))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(completed == total ? Color.green : Color.orange)
                                            .frame(width: geo.size.width * CGFloat(completed) / max(CGFloat(total), 1))
                                    }
                                }
                                .frame(height: 6)

                                // 각 TODO 항목 (탭해서 체크)
                                ForEach(session.todos) { todo in
                                    Button {
                                        todo.isCompleted.toggle()
                                        todo.completedAt = todo.isCompleted ? .now : nil
                                        refreshID = UUID()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(todo.isCompleted ? .green : .secondary)
                                                .font(.system(size: 16))

                                            Text(todo.text)
                                                .font(.system(size: 13))
                                                .strikethrough(todo.isCompleted)
                                                .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                            .id(refreshID)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

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
