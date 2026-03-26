import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var timerService: TimerService

    var body: some View {
        VStack(spacing: 20) {
            // 목표 표시
            if let session = timerService.currentSession, !session.goal.isEmpty {
                Text(session.goal)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // 타이머 링
            CircularTimerView(
                progress: timerService.progress,
                remainingTime: timerService.formattedRemainingTime,
                isRunning: timerService.state == .running
            )
            .frame(width: 160, height: 160)

            // 집중 깨짐 카운트
            if timerService.focusBreakCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                    Text("집중 깨짐: \(timerService.focusBreakCount)회")
                }
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.1), in: Capsule())
            }

            // 컨트롤 버튼
            HStack(spacing: 16) {
                if timerService.state == .running {
                    Button(action: { timerService.pause() }) {
                        Label("일시정지", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)
                } else if timerService.state == .paused {
                    Button(action: { timerService.resume() }) {
                        Label("재개", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                Button(action: { timerService.cancel() }) {
                    Label("취소", systemImage: "xmark")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }

            Text("Cmd+Shift+B로 집중 깨짐 기록")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(width: 300)
    }
}
