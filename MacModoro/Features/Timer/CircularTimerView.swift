import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let isRunning: Bool

    var body: some View {
        ZStack {
            // 배경 트랙
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 6)

            // 진행 링 (단색 + round cap)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)

            // 시간 텍스트
            VStack(spacing: 2) {
                Text(remainingTime)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .monospacedDigit()

                Text(isRunning ? "집중 중" : "일시정지")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progressColor: Color {
        if progress > 0.9 { return .red }
        if progress > 0.7 { return .orange }
        return .accentColor
    }
}
