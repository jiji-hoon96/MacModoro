import RealityKit
import Foundation
import Combine

final class CharacterBehaviorController {
    private let entity: ModelEntity
    private let bounds: SIMD2<Float>
    private var currentState: CharacterBehaviorState = .idle
    private var targetPosition: SIMD3<Float> = .zero
    private var updateTimer: Timer?
    private var stateTimer: Timer?
    private var isRunning = false

    init(entity: ModelEntity, bounds: SIMD2<Float>) {
        self.entity = entity
        self.bounds = bounds
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        transitionToState(.idle)
        startUpdateLoop()
    }

    func stop() {
        isRunning = false
        updateTimer?.invalidate()
        updateTimer = nil
        stateTimer?.invalidate()
        stateTimer = nil
    }

    private func transitionToState(_ newState: CharacterBehaviorState) {
        currentState = newState
        stateTimer?.invalidate()

        switch newState {
        case .idle:
            break
        case .walk, .run:
            targetPosition = randomTargetInBounds()
        case .turning:
            targetPosition = randomTargetInBounds()
        }

        let duration = TimeInterval.random(in: newState.durationRange)
        stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.onStateComplete()
        }
    }

    private func onStateComplete() {
        guard isRunning else { return }
        let next = currentState.randomNextState()
        transitionToState(next)
    }

    private func startUpdateLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    private func update() {
        guard isRunning else { return }
        let dt: Float = 1.0 / 30.0

        switch currentState {
        case .idle:
            applyIdleAnimation(dt: dt)
        case .walk, .run:
            moveTowardTarget(speed: currentState.speed, dt: dt)
        case .turning:
            rotateTowardTarget(dt: dt)
        }

        clampToBounds()
    }

    private func applyIdleAnimation(dt: Float) {
        let time = Float(Date.timeIntervalSinceReferenceDate)
        let bob = sin(time * 2.0) * 0.02
        entity.position.y = 0.3 + bob
    }

    private func moveTowardTarget(speed: Float, dt: Float) {
        let current = SIMD2<Float>(entity.position.x, entity.position.z)
        let target = SIMD2<Float>(targetPosition.x, targetPosition.z)
        let direction = target - current
        let distance = simd_length(direction)

        if distance < 0.2 {
            transitionToState(currentState.randomNextState())
            return
        }

        let normalized = direction / distance
        let movement = normalized * speed * dt

        entity.position.x += movement.x
        entity.position.z += movement.y

        let angle = atan2(normalized.x, normalized.y)
        let currentRotation = entity.transform.rotation
        let targetRotation = simd_quatf(angle: angle, axis: [0, 1, 0])
        entity.transform.rotation = simd_slerp(currentRotation, targetRotation, 0.1)

        applyIdleAnimation(dt: dt)
    }

    private func rotateTowardTarget(dt: Float) {
        let current = SIMD2<Float>(entity.position.x, entity.position.z)
        let target = SIMD2<Float>(targetPosition.x, targetPosition.z)
        let direction = target - current
        let distance = simd_length(direction)

        guard distance > 0.01 else { return }

        let normalized = direction / distance
        let angle = atan2(normalized.x, normalized.y)
        let targetRotation = simd_quatf(angle: angle, axis: [0, 1, 0])
        entity.transform.rotation = simd_slerp(entity.transform.rotation, targetRotation, 0.05)
    }

    private func clampToBounds() {
        let halfX = bounds.x / 2
        let halfZ = bounds.y / 2

        if abs(entity.position.x) > halfX || abs(entity.position.z) > halfZ {
            entity.position.x = min(max(entity.position.x, -halfX), halfX)
            entity.position.z = min(max(entity.position.z, -halfZ), halfZ)
            targetPosition = randomTargetInBounds()
            transitionToState(.turning)
        }
    }

    private func randomTargetInBounds() -> SIMD3<Float> {
        let halfX = bounds.x / 2 - 0.5
        let halfZ = bounds.y / 2 - 0.5
        return SIMD3<Float>(
            Float.random(in: -halfX...halfX),
            0,
            Float.random(in: -halfZ...halfZ)
        )
    }

    deinit {
        stop()
    }
}
