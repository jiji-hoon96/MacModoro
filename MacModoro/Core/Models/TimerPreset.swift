import Foundation
import SwiftData

@Model
final class TimerPreset {
    var id: UUID
    var label: String
    var durationMinutes: Int
    var sortOrder: Int

    init(label: String, durationMinutes: Int, sortOrder: Int = 0) {
        self.id = UUID()
        self.label = label
        self.durationMinutes = durationMinutes
        self.sortOrder = sortOrder
    }
}
