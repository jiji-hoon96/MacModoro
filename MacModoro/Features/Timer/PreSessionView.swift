import SwiftUI
import SwiftData

struct PreSessionView: View {
    @ObservedObject var timerService: TimerService
    @Binding var showHistory: Bool
    @Query(sort: \TimerPreset.sortOrder) private var presets: [TimerPreset]

    @State private var durationMinutes: Int = AppSettings.shared.defaultDurationMinutes
    @State private var durationText: String = ""
    @State private var todos: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            // 타이머 입력
            VStack(spacing: 4) {
                TextField("", text: $durationText)
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .onChange(of: durationText) { _, newValue in
                        if let val = Int(newValue), val > 0 {
                            durationMinutes = min(val, 999)
                        }
                    }

                Text("minutes")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .kerning(2)
            }

            Spacer(minLength: 16)

            // 프리셋
            HStack(spacing: 8) {
                ForEach(presets) { preset in
                    Button {
                        durationMinutes = preset.durationMinutes
                        durationText = "\(preset.durationMinutes)"
                    } label: {
                        Text("\(preset.durationMinutes)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                durationMinutes == preset.durationMinutes
                                    ? Color.primary.opacity(0.12)
                                    : Color.primary.opacity(0.04)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering { NSCursor.pointingHand.push() }
                        else { NSCursor.pop() }
                    }
                }
            }

            Spacer(minLength: 20)

            // TODO
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 24)

                ScrollView {
                    TodoListView(todos: $todos)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .frame(maxHeight: todos.isEmpty ? 50 : 120)
            }

            Spacer(minLength: 8)

            // 시작 버튼
            Button(action: startSession) {
                Text("Start Focus")
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
            .onHover { hovering in
                if hovering { NSCursor.pointingHand.push() }
                else { NSCursor.pop() }
            }

            // 하단 네비게이션
            HStack(spacing: 0) {
                Button { showHistory = true } label: {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() }
                    else { NSCursor.pop() }
                }

                Button {
                    NotificationCenter.default.post(name: AppDelegate.openSettingsNotification, object: nil)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() }
                    else { NSCursor.pop() }
                }
            }
            .padding(.bottom, 4)
        }
        .frame(width: 280, height: 400)
        .onAppear {
            durationText = "\(durationMinutes)"
        }
    }

    private func startSession() {
        timerService.startSession(
            durationMinutes: durationMinutes,
            goal: "",
            todos: todos
        )
    }
}
