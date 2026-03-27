import SwiftUI

struct SessionSummaryView: View {
    @ObservedObject var timerService: TimerService
    @State private var refreshID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 16)

                    // 완료
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(.primary.opacity(0.6))

                        Text("Complete")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .textCase(.uppercase)
                            .kerning(2)
                    }

                    if let session = timerService.currentSession {
                        // 집중 시간 — 큰 숫자
                        VStack(spacing: 2) {
                            Text("\(session.focusedMinutes)")
                                .font(.system(size: 48, weight: .thin, design: .rounded))
                            Text("minutes focused")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                                .kerning(0.5)
                        }

                        // 통계 행
                        if !session.goal.isEmpty || session.breakCount > 0 {
                            VStack(spacing: 8) {
                                if !session.goal.isEmpty {
                                    HStack {
                                        Text("목표")
                                            .foregroundStyle(.tertiary)
                                        Spacer()
                                        Text(session.goal)
                                            .lineLimit(1)
                                    }
                                    .font(.system(size: 12))
                                }

                                HStack {
                                    Text("집중 깨짐")
                                        .foregroundStyle(.tertiary)
                                    Spacer()
                                    Text("\(session.breakCount)회")
                                        .foregroundStyle(session.breakCount > 0 ? Color.primary.opacity(0.4) : Color.primary)
                                }
                                .font(.system(size: 12))

                                if !session.focusBreaks.isEmpty {
                                    BreakTimelineView(breaks: session.focusBreaks)
                                }
                            }
                            .padding(14)
                            .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
                        }

                        // TODO 점검
                        if !session.todos.isEmpty {
                            let completed = session.todos.filter(\.isCompleted).count
                            let total = session.todos.count

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("할 일")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.tertiary)
                                        .textCase(.uppercase)
                                        .kerning(1)
                                    Spacer()
                                    Text("\(completed)/\(total)")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.primary.opacity(completed == total ? 0.6 : 0.4))
                                }

                                // 프로그레스
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.primary.opacity(0.06))
                                        Capsule()
                                            .fill(completed == total ? Color.primary.opacity(0.5) : Color.primary.opacity(0.35))
                                            .frame(width: geo.size.width * CGFloat(completed) / max(CGFloat(total), 1))
                                            .animation(.easeOut(duration: 0.3), value: completed)
                                    }
                                }
                                .frame(height: 4)

                                ForEach(session.todos) { todo in
                                    Button {
                                        todo.isCompleted.toggle()
                                        todo.completedAt = todo.isCompleted ? .now : nil
                                        refreshID = UUID()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 14))
                                                .foregroundStyle(todo.isCompleted ? Color.primary.opacity(0.6) : Color.gray.opacity(0.3))

                                            Text(todo.text)
                                                .font(.system(size: 12))
                                                .strikethrough(todo.isCompleted)
                                                .foregroundStyle(todo.isCompleted ? .tertiary : .primary)

                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .pointerCursor()
                                }
                            }
                            .padding(14)
                            .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
                            .id(refreshID)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // 확인
            Button(action: { timerService.dismiss() }) {
                Text("Done")
                    .font(.system(size: 14, weight: .semibold))
                    .kerning(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.primary.opacity(0.85))
            .clipShape(Capsule())
            .controlSize(.large)
            .padding(.horizontal, 40)
            .padding(.bottom, 12)
            .padding(.top, 8)
            .pointerCursor()
        }
        .frame(width: 280, height: 400)
    }
}
