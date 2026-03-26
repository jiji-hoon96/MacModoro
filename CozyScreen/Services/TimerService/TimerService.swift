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
}

final class TimerService: ObservableObject {
    static let shared = TimerService()

    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var focusBreakCount: Int = 0

    private(set) var currentSession: PomodoroSession?
    private var timer: DispatchSourceTimer?
    private var modelContext: ModelContext?

    private init() {}

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Session Lifecycle

    func startSession(durationMinutes: Int, goal: String = "", todos: [String] = []) {
        guard state == .idle || state == .finished else { return }

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
        state = .running

        startTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimer()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
    }

    func cancel() {
        guard state == .running || state == .paused else { return }
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
    }

    // MARK: - Focus Break

    func recordFocusBreak() {
        guard state == .running, let session = currentSession else { return }

        let elapsed = totalSeconds - remainingSeconds
        let focusBreak = FocusBreak(secondsSinceSessionStart: elapsed)
        focusBreak.session = session
        session.focusBreaks.append(focusBreak)
        modelContext?.insert(focusBreak)
        focusBreakCount = session.focusBreaks.count
        saveContext()
    }

    // MARK: - Timer

    private func startTimer() {
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

        if remainingSeconds == 5 {
            ScreenFlashService.shared.flash()
        }

        if remainingSeconds <= 0 {
            currentSession?.wasCompleted = true
            currentSession?.endedAt = .now
            saveContext()
            finish()
        }
    }

    private func cleanup() {
        stopTimer()
        state = .idle
        currentSession = nil
        remainingSeconds = 0
        totalSeconds = 0
        focusBreakCount = 0
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
        guard state == .running || state == .paused else { return }
        currentSession?.wasCompleted = false
        currentSession?.endedAt = .now
        saveContext()
    }
}
