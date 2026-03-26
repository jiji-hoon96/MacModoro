import SwiftUI

struct PreSessionView: View {
    @ObservedObject var timerService: TimerService
    @Binding var showHistory: Bool
    @State private var durationMinutes: Int = AppSettings.shared.defaultDurationMinutes
    @State private var goal: String = ""
    @State private var todos: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 헤더
                Text("MacModoro")
                    .font(.title2.bold())

                // 시간 설정
                VStack(spacing: 8) {
                    Text("\(durationMinutes)분")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .monospacedDigit()

                    HStack(spacing: 12) {
                        Button("-5") { adjustDuration(-5) }
                            .buttonStyle(.bordered)
                        Button("-1") { adjustDuration(-1) }
                            .buttonStyle(.bordered)
                        Button("+1") { adjustDuration(1) }
                            .buttonStyle(.bordered)
                        Button("+5") { adjustDuration(5) }
                            .buttonStyle(.bordered)
                    }
                }

                // 프리셋
                PresetsBarView(selectedMinutes: $durationMinutes)

                Divider()

                // 목표 입력
                GoalInputView(goal: $goal)

                // TODO 리스트
                TodoListView(todos: $todos)

                // 시작 버튼
                Button(action: startSession) {
                    Text("집중 시작")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)

                Divider()

                // 하단 메뉴
                HStack {
                    Button("히스토리") { showHistory = true }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("설정") {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
            .padding()
        }
        .frame(width: 300, height: 420)
    }

    private func adjustDuration(_ delta: Int) {
        durationMinutes = max(1, durationMinutes + delta)
    }

    private func startSession() {
        timerService.startSession(
            durationMinutes: durationMinutes,
            goal: goal,
            todos: todos
        )
    }
}
