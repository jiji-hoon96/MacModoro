import SwiftUI

enum TimerPhase {
    case focus, rest, paused
}

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let phase: TimerPhase

    @State private var displayedProgress: Double = 0

    init(progress: Double, remainingTime: String, isRunning: Bool) {
        self.progress = progress
        self.remainingTime = remainingTime
        // 호환: isRunning이면 TimerService에서 판단
        let service = TimerService.shared
        if service.isRestPhase && isRunning {
            self.phase = .rest
        } else if isRunning {
            self.phase = .focus
        } else {
            self.phase = .paused
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: 3)

            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(remainingTime)
                    .font(.system(size: 44, weight: .thin, design: .rounded))
                    .monospacedDigit()

                Text(phaseLabel)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(phaseLabelColor)
                    .kerning(2)
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

    private var phaseLabel: String {
        switch phase {
        case .focus: return "FOCUS"
        case .rest: return "REST"
        case .paused: return "PAUSED"
        }
    }

    private var phaseLabelColor: Color {
        switch phase {
        case .focus: return .primary.opacity(0.3)
        case .rest: return .primary.opacity(0.5)
        case .paused: return .primary.opacity(0.35)
        }
    }

    private var ringColor: Color {
        switch phase {
        case .rest: return .primary.opacity(0.4)
        case .paused: return .primary.opacity(0.2)
        case .focus:
            if displayedProgress > 0.9 { return .primary.opacity(0.5) }
            if displayedProgress > 0.7 { return .primary.opacity(0.35) }
            return .primary.opacity(0.3)
        }
    }
}
