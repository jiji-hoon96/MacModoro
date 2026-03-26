import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let isRunning: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

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

    private var progressGradient: AngularGradient {
        let color = progressColor
        return AngularGradient(
            colors: [color.opacity(0.6), color],
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * progress)
        )
    }

    private var progressColor: Color {
        if progress > 0.9 { return .red }
        if progress > 0.7 { return .orange }
        return .accentColor
    }
}
