import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var timerService: TimerService
    @StateObject private var noiseService = WhiteNoiseService.shared
    @State private var showNoiseMenu = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            // 목표 표시
            if let session = timerService.currentSession, !session.goal.isEmpty {
                Text(session.goal)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }

            // 타이머 링
            CircularTimerView(
                progress: timerService.progress,
                remainingTime: timerService.formattedRemainingTime,
                isRunning: timerService.state == .running
            )
            .frame(width: 170, height: 170)
            .padding(.vertical, 4)

            // 집중 깨짐 카운트
            Group {
                if timerService.focusBreakCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                        Text("\(timerService.focusBreakCount)회 깨짐")
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.08), in: Capsule())
                } else {
                    Text(" ")
                        .font(.system(size: 12))
                }
            }
            .padding(.top, 4)

            Spacer(minLength: 8)

            // 화이트노이즈
            HStack(spacing: 8) {
                Button {
                    showNoiseMenu.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: noiseService.currentNoise == .none ? "speaker.slash" : "speaker.wave.2")
                        Text(noiseService.currentNoise.rawValue)
                    }
                    .font(.system(size: 11))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.05), in: Capsule())
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .popover(isPresented: $showNoiseMenu) {
                    WhiteNoisePickerView(noiseService: noiseService)
                }

                if noiseService.currentNoise != .none {
                    Slider(value: $noiseService.volume, in: 0...1)
                        .frame(width: 80)
                        .controlSize(.mini)
                }
            }
            .padding(.bottom, 8)

            // 컨트롤 버튼
            HStack(spacing: 12) {
                if timerService.state == .running {
                    Button(action: { timerService.pause() }) {
                        Image(systemName: "pause.fill")
                            .frame(width: 44, height: 36)
                    }
                    .buttonStyle(.bordered)
                } else if timerService.state == .paused {
                    Button(action: { timerService.resume() }) {
                        Image(systemName: "play.fill")
                            .frame(width: 44, height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                Button(action: {
                    noiseService.stop()
                    timerService.cancel()
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.bottom, 6)

            Text("Cmd+Shift+B 집중 깨짐 · SNS 전환 자동 감지")
                .font(.system(size: 9))
                .foregroundStyle(.quaternary)
                .padding(.bottom, 10)
        }
        .frame(width: 300, height: 420)
    }
}

// MARK: - 화이트노이즈 선택 팝오버

private struct WhiteNoisePickerView: View {
    @ObservedObject var noiseService: WhiteNoiseService

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 3)

    var body: some View {
        VStack(spacing: 8) {
            Text("배경음")
                .font(.system(size: 12, weight: .semibold))

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(WhiteNoiseType.allCases) { noise in
                    Button {
                        if noise == .none {
                            noiseService.stop()
                        } else {
                            noiseService.play(noise)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: iconFor(noise))
                                .font(.system(size: 16))
                                .frame(height: 22)
                            Text(noise.rawValue)
                                .font(.system(size: 10))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            noiseService.currentNoise == noise
                                ? Color.accentColor.opacity(0.15)
                                : Color.primary.opacity(0.04),
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .frame(width: 200)
    }

    private func iconFor(_ noise: WhiteNoiseType) -> String {
        switch noise {
        case .none: return "speaker.slash"
        case .rain: return "cloud.rain"
        case .cafe: return "cup.and.saucer"
        case .fire: return "flame"
        case .ocean: return "water.waves"
        case .forest: return "leaf"
        case .fan: return "fan"
        }
    }
}
