import Foundation
import SwiftData
import Combine
import UserNotifications
import AppKit

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case finished
    case resting     // 사이클 모드: 휴식 중
}

struct CycleConfig {
    let focusMinutes: Int
    let restMinutes: Int
    let rounds: Int
}

final class TimerService: ObservableObject {
    static let shared = TimerService()

    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var focusBreakCount: Int = 0

    // 사이클 상태
    @Published var currentRound: Int = 0
    @Published var totalRounds: Int = 1
    @Published var isRestPhase: Bool = false

    private(set) var currentSession: PomodoroSession?
    private var timer: DispatchSourceTimer?
    private var modelContext: ModelContext?

    private var cycleConfig: CycleConfig?
    private var sessionTodos: [String] = []

    private init() {}

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Session Lifecycle

    func startSession(durationMinutes: Int, goal: String = "", todos: [String] = []) {
        guard state == .idle || state == .finished else { return }

        cycleConfig = nil
        sessionTodos = todos
        currentRound = 1
        totalRounds = 1
        isRestPhase = false
        beginFocusSession(durationMinutes: durationMinutes, goal: goal, todos: todos)
    }

    func startCycleSession(config: CycleConfig, todos: [String] = []) {
        guard state == .idle || state == .finished else { return }

        cycleConfig = config
        sessionTodos = todos
        currentRound = 1
        totalRounds = config.rounds
        isRestPhase = false
        beginFocusSession(durationMinutes: config.focusMinutes, goal: "사이클 \(currentRound)/\(totalRounds)", todos: todos)
    }

    private func beginFocusSession(durationMinutes: Int, goal: String, todos: [String]) {
        let durationSeconds = durationMinutes * 60
        let session = PomodoroSession(goal: goal, durationSeconds: durationSeconds)

        for todoText in todos where !todoText.isEmpty {
            let todo = TodoItem(text: todoText)
            todo.session = session
            session.todos.append(todo)
        }

        modelContext?.insert(session)
        currentSession = session

        totalSeconds = durationSeconds
        remainingSeconds = durationSeconds
        focusBreakCount = 0
        isRestPhase = false
        state = .running

        startTimer()
    }

    private func beginRestPhase() {
        guard let config = cycleConfig else { return }

        let restSeconds = config.restMinutes * 60
        totalSeconds = restSeconds
        remainingSeconds = restSeconds
        isRestPhase = true
        state = .resting

        startTimer()
        playCompletionSound()
    }

    func pause() {
        guard state == .running || state == .resting else { return }
        state = .paused
        stopTimer()
    }

    func resume() {
        guard state == .paused else { return }
        state = isRestPhase ? .resting : .running
        startTimer()
    }

    func cancel() {
        guard state == .running || state == .paused || state == .resting else { return }
        currentSession?.wasCompleted = false
        currentSession?.endedAt = .now
        saveContext()
        cleanup()
    }

    func finish() {
        state = .finished
        stopTimer()
        sendCompletionNotification()
        playCompletionSound()
    }

    func dismiss() {
        state = .idle
        currentSession = nil
        cycleConfig = nil
    }

    // MARK: - Focus Break

    func recordFocusBreak(reason: String = "manual") {
        guard state == .running, let session = currentSession else { return }

        let elapsed = totalSeconds - remainingSeconds
        let focusBreak = FocusBreak(secondsSinceSessionStart: elapsed, reason: reason)
        focusBreak.session = session
        session.focusBreaks.append(focusBreak)
        modelContext?.insert(focusBreak)
        focusBreakCount = session.focusBreaks.count
        saveContext()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 1, repeating: 1.0)
        timer.setEventHandler { [weak self] in
            self?.tick()
        }
        timer.resume()
        self.timer = timer
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }

        remainingSeconds -= 1

        if remainingSeconds == 5 && !isRestPhase {
            ScreenFlashService.shared.flash()
        }

        if remainingSeconds <= 0 {
            handlePhaseComplete()
        }
    }

    private func handlePhaseComplete() {
        if isRestPhase {
            // 휴식 끝 → 다음 라운드 집중 시작
            if let config = cycleConfig, currentRound < config.rounds {
                currentRound += 1
                beginFocusSession(
                    durationMinutes: config.focusMinutes,
                    goal: "사이클 \(currentRound)/\(totalRounds)",
                    todos: []
                )
            } else {
                // 모든 라운드 완료
                currentSession?.wasCompleted = true
                currentSession?.endedAt = .now
                saveContext()
                finish()
            }
        } else {
            // 집중 끝
            currentSession?.wasCompleted = true
            currentSession?.endedAt = .now
            saveContext()

            if let config = cycleConfig, currentRound <= config.rounds {
                // 사이클 모드: 휴식 시작
                beginRestPhase()
            } else {
                finish()
            }
        }
    }

    private func cleanup() {
        stopTimer()
        state = .idle
        currentSession = nil
        cycleConfig = nil
        remainingSeconds = 0
        totalSeconds = 0
        focusBreakCount = 0
        currentRound = 0
        totalRounds = 1
        isRestPhase = false
    }

    private func saveContext() {
        try? modelContext?.save()
    }

    // MARK: - Helpers

    var elapsedSeconds: Int {
        totalSeconds - remainingSeconds
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var cycleLabel: String? {
        guard totalRounds > 1 else { return nil }
        let phase = isRestPhase ? "REST" : "FOCUS"
        return "\(phase) \(currentRound)/\(totalRounds)"
    }

    // MARK: - Notifications

    private func sendCompletionNotification() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "MacModoro"
            let minutes = (self.currentSession?.focusedMinutes ?? 0)
            let breaks = self.currentSession?.breakCount ?? 0
            content.body = "\(minutes)분 집중 완료! 깨짐 \(breaks)회"
            content.sound = .default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        }
    }

    private func playCompletionSound() {
        guard AppSettings.shared.playCompletionSound else { return }
        NSSound.beep()
    }

    func requestNotificationPermission() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: - App Lifecycle

    func handleAppTermination() {
        guard state == .running || state == .paused || state == .resting else { return }
        currentSession?.wasCompleted = false
        currentSession?.endedAt = .now
        saveContext()
    }
}
