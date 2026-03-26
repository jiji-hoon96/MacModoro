import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var timerService: TimerService

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
            .frame(width: 180, height: 180)
            .padding(.vertical, 8)

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

            Spacer(minLength: 12)

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

                Button(action: { timerService.cancel() }) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.bottom, 8)

            Text("Cmd+Shift+B 집중 깨짐 기록")
                .font(.system(size: 10))
                .foregroundStyle(.quaternary)
                .padding(.bottom, 12)
        }
        .frame(width: 300, height: 400)
    }
}
