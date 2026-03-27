import SwiftUI
import SwiftData

struct PreSessionView: View {
    @ObservedObject var timerService: TimerService
    @Binding var showHistory: Bool

    @State private var durationMinutes: Int = AppSettings.shared.defaultDurationMinutes
    @State private var durationText: String = ""
    @State private var todos: [String] = []

    @State private var showCycleSheet = false
    @State private var cycleFocus: Int = 40
    @State private var cycleRest: Int = 5
    @State private var cycleRounds: Int = 2

    // 하드코딩 프리셋 (DB 의존 없음)
    private let quickPresets = [90, 40, 20, 5]

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

            Spacer(minLength: 14)

            // 프리셋 버튼: 90 · 40 · 20 · 5
            HStack(spacing: 6) {
                ForEach(quickPresets, id: \.self) { mins in
                    Button {
                        durationMinutes = mins
                        durationText = "\(mins)"
                    } label: {
                        Text("\(mins)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                durationMinutes == mins
                                    ? Color.primary.opacity(0.12)
                                    : Color.primary.opacity(0.04)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                }
            }

            // 사이클 버튼
            HStack(spacing: 6) {
                Button {
                    timerService.startCycleSession(
                        config: CycleConfig(focusMinutes: cycleFocus, restMinutes: cycleRest, rounds: cycleRounds),
                        todos: todos
                    )
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "repeat")
                            .font(.system(size: 8))
                        Text("\(cycleFocus) + \(cycleRest)min rest × \(cycleRounds)")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .pointerCursor()

                Button { showCycleSheet = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 9))
                        .padding(5)
                        .background(Color.primary.opacity(0.04))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
                .pointerCursor()
            }
            .padding(.top, 6)

            Spacer(minLength: 10)

            // TODO
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
        let mins = max(1, min(durationMinutes, 999))
        timerService.startSession(durationMinutes: mins, goal: "", todos: todos)
    }
}

// MARK: - 사이클 설정

private struct CycleConfigSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var focus: Int
    @Binding var rest: Int
    @Binding var rounds: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("사이클 설정")
                .font(.system(size: 15, weight: .semibold))

            VStack(spacing: 14) {
                HStack {
                    Text("집중")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .leading)
                    Stepper("\(focus)분", value: $focus, in: 5...120, step: 5)
                        .font(.system(size: 13, design: .rounded))
                }
                HStack {
                    Text("휴식")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .leading)
                    Stepper("\(rest)분", value: $rest, in: 1...30)
                        .font(.system(size: 13, design: .rounded))
                }
                HStack {
                    Text("세트")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .leading)
                    Stepper("\(rounds)세트", value: $rounds, in: 1...10)
                        .font(.system(size: 13, design: .rounded))
                }
            }

            Divider()

            Text("총 \(focus * rounds + rest * (rounds - 1))분")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            Button("확인") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Color.primary.opacity(0.85))
                .controlSize(.regular)
                .pointerCursor()
        }
        .padding(24)
        .frame(width: 260)
    }
}
