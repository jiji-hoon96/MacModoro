import SwiftUI
import SwiftData

struct PreSessionView: View {
    @ObservedObject var timerService: TimerService
    @Binding var showHistory: Bool
    @Query(sort: \TimerPreset.sortOrder) private var presets: [TimerPreset]

    @State private var durationMinutes: Int = AppSettings.shared.defaultDurationMinutes
    @State private var durationText: String = ""
    @State private var goal: String = ""
    @State private var todos: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            // 시간 선택 영역
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    TextField("", text: $durationText)
                        .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                        .textFieldStyle(.plain)
                        .onChange(of: durationText) { _, newValue in
                            if let val = Int(newValue), val > 0 {
                                durationMinutes = min(val, 999)
                            }
                        }

                    Text("min")
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)

                // 프리셋 버튼
                HStack(spacing: 6) {
                    ForEach(presets) { preset in
                        Button {
                            durationMinutes = preset.durationMinutes
                            durationText = "\(preset.durationMinutes)"
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(preset.durationMinutes)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Text(preset.label)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                durationMinutes == preset.durationMinutes
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.primary.opacity(0.05),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        durationMinutes == preset.durationMinutes
                                            ? Color.accentColor.opacity(0.3)
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // 목표 & TODO
            ScrollView {
                VStack(spacing: 12) {
                    GoalInputView(goal: $goal)
                    TodoListView(todos: $todos)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(maxHeight: 140)

            Spacer(minLength: 0)

            // 시작 버튼
            Button(action: startSession) {
                Text("집중 시작")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .controlSize(.large)
            .padding(.horizontal, 16)

            // #2: 하단 버튼 넓은 터치 영역
            HStack(spacing: 0) {
                Button { showHistory = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("기록")
                    }
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    if let delegate = NSApp.delegate as? AppDelegate {
                        delegate.openSettings()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text("설정")
                    }
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .frame(height: 36)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(width: 300, height: 420)
        .onAppear {
            durationText = "\(durationMinutes)"
        }
    }

    private func startSession() {
        timerService.startSession(
            durationMinutes: durationMinutes,
            goal: goal,
            todos: todos
        )
    }
}
