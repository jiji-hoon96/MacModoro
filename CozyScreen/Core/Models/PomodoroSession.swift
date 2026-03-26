import Foundation
import SwiftData

@Model
final class PomodoroSession {
    var id: UUID
    var goal: String
    var durationSeconds: Int
    var startedAt: Date
    var endedAt: Date?
    var wasCompleted: Bool

    @Relationship(deleteRule: .cascade, inverse: \FocusBreak.session)
    var focusBreaks: [FocusBreak]

    @Relationship(deleteRule: .cascade, inverse: \TodoItem.session)
    var todos: [TodoItem]

    var focusedMinutes: Int { durationSeconds / 60 }
    var breakCount: Int { focusBreaks.count }

    init(
        goal: String = "",
        durationSeconds: Int,
        startedAt: Date = .now
    ) {
        self.id = UUID()
        self.goal = goal
        self.durationSeconds = durationSeconds
        self.startedAt = startedAt
        self.endedAt = nil
        self.wasCompleted = false
        self.focusBreaks = []
        self.todos = []
    }
}
