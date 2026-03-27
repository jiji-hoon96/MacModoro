import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var timerService: TimerService
    @StateObject private var noiseService = WhiteNoiseService.shared
    @State private var showNoiseMenu = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            // 사이클 라벨
            if let cycleLabel = timerService.cycleLabel {
                Text(cycleLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(timerService.isRestPhase ? Color.green.opacity(0.7) : Color.secondary)
                    .kerning(1.5)
            } else if let session = timerService.currentSession, !session.goal.isEmpty {
                Text(session.goal)
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
            }

            Spacer(minLength: 12)

            // 타이머
            CircularTimerView(
                progress: timerService.progress,
                remainingTime: timerService.formattedRemainingTime,
                isRunning: timerService.state == .running || timerService.state == .resting
            )
            .frame(width: 180, height: 180)

            Spacer(minLength: 12)

            // 깨짐 카운트
            if timerService.focusBreakCount > 0 {
                Text("\(timerService.focusBreakCount) distractions")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.orange.opacity(0.8))
                    .kerning(0.5)
            }

            Spacer(minLength: 12)

            // 화이트노이즈 + 볼륨
            HStack(spacing: 8) {
                Button { showNoiseMenu.toggle() } label: {
                    Image(systemName: noiseService.currentNoise == .none ? "speaker.slash" : "speaker.wave.2")
                        .font(.system(size: 12))
                        .frame(width: 32, height: 28)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
                .pointerCursor()
                .popover(isPresented: $showNoiseMenu) {
                    WhiteNoisePickerView(noiseService: noiseService)
                }

                if noiseService.currentNoise != .none {
                    Slider(value: $noiseService.volume, in: 0...1)
                        .frame(width: 80)
                        .controlSize(.mini)
                }
            }

            Spacer(minLength: 16)

            // 컨트롤
            HStack(spacing: 20) {
                if timerService.state == .running {
                    Button(action: { timerService.pause() }) {
                        Image(systemName: "pause")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 48, height: 48)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                } else if timerService.state == .paused {
                    Button(action: { timerService.resume() }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 48, height: 48)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                }

                Button(action: {
                    noiseService.stop()
                    timerService.cancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red.opacity(0.7))
                .pointerCursor()
            }

            Spacer(minLength: 12)
        }
        .frame(width: 280, height: 400)
    }
}

// MARK: - 화이트노이즈 피커

private struct WhiteNoisePickerView: View {
    @ObservedObject var noiseService: WhiteNoiseService

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 3)

    var body: some View {
        VStack(spacing: 10) {
            Text("배경음")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(1)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(WhiteNoiseType.allCases) { noise in
                    Button {
                        if noise == .none { noiseService.stop() }
                        else { noiseService.play(noise) }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: iconFor(noise))
                                .font(.system(size: 15))
                                .frame(height: 20)
                            Text(noise.rawValue)
                                .font(.system(size: 9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            noiseService.currentNoise == noise
                                ? Color.primary.opacity(0.1)
                                : Color.primary.opacity(0.03),
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .frame(width: 190)
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
