import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let isRunning: Bool

    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            // 진행 원
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // 남은 시간 텍스트
            VStack(spacing: 4) {
                Text(remainingTime)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .monospacedDigit()

                Text(isRunning ? "집중 중" : "일시정지")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progressColor: Color {
        if progress > 0.9 {
            return .red
        } else if progress > 0.7 {
            return .orange
        } else {
            return .green
        }
    }
}
