import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let isRunning: Bool

    @State private var displayedProgress: Double = 0

    var body: some View {
        ZStack {
            // 트랙
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: 3)

            // 진행
            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // 시간
            VStack(spacing: 2) {
                Text(remainingTime)
                    .font(.system(size: 44, weight: .thin, design: .rounded))
                    .monospacedDigit()

                if isRunning {
                    Text("FOCUS")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .kerning(2)
                } else {
                    Text("PAUSED")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.orange.opacity(0.6))
                        .kerning(2)
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.linear(duration: 0.8)) {
                displayedProgress = min(newValue, 1.0)
            }
        }
        .onAppear {
            displayedProgress = min(progress, 1.0)
        }
    }

    private var progressColor: Color {
        if displayedProgress > 0.9 { return .red.opacity(0.7) }
        if displayedProgress > 0.7 { return .orange.opacity(0.7) }
        return .primary.opacity(0.3)
    }
}
