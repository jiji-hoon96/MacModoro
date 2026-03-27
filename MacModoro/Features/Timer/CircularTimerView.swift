import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let isRunning: Bool

    @State private var displayedProgress: Double = 0

    var body: some View {
        ZStack {
            // 배경 트랙
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 6)

            // 진행 링
            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

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
        if displayedProgress > 0.9 { return .red }
        if displayedProgress > 0.7 { return .orange }
        return .accentColor
    }
}
