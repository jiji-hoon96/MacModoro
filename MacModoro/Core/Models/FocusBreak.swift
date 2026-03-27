import Foundation
import SwiftData

@Model
final class FocusBreak {
    var id: UUID
    var timestamp: Date
    var secondsSinceSessionStart: Int
    var reason: String
    var session: PomodoroSession?

    init(timestamp: Date = .now, secondsSinceSessionStart: Int, reason: String = "manual") {
        self.id = UUID()
        self.timestamp = timestamp
        self.secondsSinceSessionStart = secondsSinceSessionStart
        self.reason = reason
    }
}
