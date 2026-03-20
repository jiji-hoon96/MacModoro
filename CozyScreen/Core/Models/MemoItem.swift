import Foundation
import SwiftData

@Model
final class MemoItem {
    var title: String
    var content: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(title: String, content: String = "", isCompleted: Bool = false) {
        self.title = title
        self.content = content
        self.isCompleted = isCompleted
        self.createdAt = .now
        self.updatedAt = .now
    }
}
