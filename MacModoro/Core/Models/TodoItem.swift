import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var text: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var session: PomodoroSession?

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.isCompleted = false
        self.createdAt = .now
        self.completedAt = nil
        self.session = nil
    }
}
