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
                // 직접 입력
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
            VStack(spacing: 10) {
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

                // 하단 메뉴
                HStack {
                    Button { showHistory = true } label: {
                        Label("기록", systemImage: "clock.arrow.circlepath")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        if let delegate = NSApp.delegate as? AppDelegate {
                            delegate.openSettings()
                        }
                    } label: {
                        Label("설정", systemImage: "gearshape")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
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
