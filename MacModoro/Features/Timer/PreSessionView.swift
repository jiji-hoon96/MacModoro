import SwiftUI
import SwiftData

struct PreSessionView: View {
    @ObservedObject var timerService: TimerService
    @Binding var showHistory: Bool
    @Query(sort: \TimerPreset.sortOrder) private var presets: [TimerPreset]

    @State private var durationMinutes: Int = AppSettings.shared.defaultDurationMinutes
    @State private var durationText: String = ""
    @State private var todos: [String] = []

    // #2: 사이클 설정
    @State private var showCycleSheet = false
    @State private var cycleFocus: Int = 40
    @State private var cycleRest: Int = 5
    @State private var cycleRounds: Int = 2

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            // 타이머 입력
            VStack(spacing: 4) {
                TextField("", text: $durationText)
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .onChange(of: durationText) { _, newValue in
                        // #4: 1~999 범위 제한
                        if let val = Int(newValue) {
                            durationMinutes = max(1, min(val, 999))
                        }
                    }

                Text("minutes")
                    .font(.system(size: 11))
                    .foregroundStyle(.quaternary)
                    .textCase(.uppercase)
                    .kerning(2)
            }

            Spacer(minLength: 12)

            // 프리셋 + 사이클
            VStack(spacing: 8) {
                // 단일 프리셋
                HStack(spacing: 6) {
                    ForEach(presets) { preset in
                        Button {
                            durationMinutes = preset.durationMinutes
                            durationText = "\(preset.durationMinutes)"
                        } label: {
                            Text("\(preset.durationMinutes)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    durationMinutes == preset.durationMinutes
                                        ? Color.primary.opacity(0.12)
                                        : Color.primary.opacity(0.04)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .pointerCursor()
                    }
                }

                // #2: 사이클 버튼 (하나만, 클릭하면 설정 시트)
                HStack(spacing: 6) {
                    Button {
                        timerService.startCycleSession(
                            config: CycleConfig(focusMinutes: cycleFocus, restMinutes: cycleRest, rounds: cycleRounds),
                            todos: todos
                        )
                    } label: {
                        Text("\(cycleFocus)+\(cycleRest) ×\(cycleRounds)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .pointerCursor()

                    Button {
                        showCycleSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 10))
                            .foregroundStyle(.blue.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                }
            }

            Spacer(minLength: 12)

            // #1: TODO — ScrollView 제거, 직접 표시
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 24)

                TodoListView(todos: $todos)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            }

            Spacer(minLength: 4)

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
            .pointerCursor()

            // 하단 네비게이션
            HStack(spacing: 0) {
                Button { showHistory = true } label: {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.quaternary)
                .pointerCursor()

                Button {
                    NotificationCenter.default.post(name: AppDelegate.openSettingsNotification, object: nil)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.quaternary)
                .pointerCursor()
            }
            .padding(.bottom, 4)
        }
        .frame(width: 280, height: 420)
        .onAppear {
            durationText = "\(durationMinutes)"
        }
        .sheet(isPresented: $showCycleSheet) {
            CycleConfigSheet(focus: $cycleFocus, rest: $cycleRest, rounds: $cycleRounds)
        }
    }

    private func startSession() {
        // #4: 범위 확인
        let mins = max(1, min(durationMinutes, 999))
        timerService.startSession(
            durationMinutes: mins,
            goal: "",
            todos: todos
        )
    }
}

// MARK: - 사이클 설정 시트

private struct CycleConfigSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var focus: Int
    @Binding var rest: Int
    @Binding var rounds: Int

    var body: some View {
        VStack(spacing: 16) {
            Text("사이클 설정")
                .font(.system(size: 14, weight: .semibold))

            VStack(spacing: 10) {
                Stepper("집중: \(focus)분", value: $focus, in: 5...120, step: 5)
                Stepper("휴식: \(rest)분", value: $rest, in: 1...30)
                Stepper("세트: \(rounds)회", value: $rounds, in: 1...10)
            }
            .font(.system(size: 13))

            Text("총 \(focus * rounds + rest * (rounds - 1))분")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Button("확인") { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(20)
        .frame(width: 220)
    }
}
