import Foundation
import SwiftData

@Model
final class FocusBreak {
    var id: UUID
    var timestamp: Date
    var secondsSinceSessionStart: Int
    var session: PomodoroSession?

    init(timestamp: Date = .now, secondsSinceSessionStart: Int) {
        self.id = UUID()
        self.timestamp = timestamp
        self.secondsSinceSessionStart = secondsSinceSessionStart
    }
}
