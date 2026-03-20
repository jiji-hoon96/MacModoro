import Foundation

enum CharacterBehaviorState: String, CaseIterable {
    case idle
    case walk
    case run
    case turning

    var animationName: String { rawValue }

    var durationRange: ClosedRange<TimeInterval> {
        switch self {
        case .idle: return 2.0...5.0
        case .walk: return 3.0...8.0
        case .run: return 2.0...4.0
        case .turning: return 0.5...1.0
        }
    }

    var speed: Float {
        switch self {
        case .idle: return 0
        case .walk: return 0.5
        case .run: return 1.5
        case .turning: return 0
        }
    }

    func randomNextState() -> CharacterBehaviorState {
        let weights: [(CharacterBehaviorState, Double)]
        switch self {
        case .idle:
            weights = [(.walk, 0.6), (.run, 0.2), (.idle, 0.2)]
        case .walk:
            weights = [(.idle, 0.3), (.walk, 0.3), (.run, 0.15), (.turning, 0.25)]
        case .run:
            weights = [(.walk, 0.4), (.idle, 0.3), (.turning, 0.3)]
        case .turning:
            weights = [(.walk, 0.5), (.idle, 0.3), (.run, 0.2)]
        }

        let total = weights.reduce(0) { $0 + $1.1 }
        var random = Double.random(in: 0..<total)
        for (state, weight) in weights {
            random -= weight
            if random <= 0 { return state }
        }
        return .idle
    }
}
