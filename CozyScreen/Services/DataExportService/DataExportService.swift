import Foundation
import SwiftData
import AppKit

enum DataExportService {
    struct ExportSession: Codable {
        let id: String
        let goal: String
        let durationSeconds: Int
        let startedAt: Date
        let endedAt: Date?
        let wasCompleted: Bool
        let focusBreaks: [ExportBreak]
        let todos: [ExportTodo]
    }

    struct ExportBreak: Codable {
        let secondsSinceSessionStart: Int
        let timestamp: Date
    }

    struct ExportTodo: Codable {
        let text: String
        let isCompleted: Bool
    }

    static func exportJSON(container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PomodoroSession>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])

        guard let sessions = try? context.fetch(descriptor), !sessions.isEmpty else { return }

        let exportData = sessions.map { session in
            ExportSession(
                id: session.id.uuidString,
                goal: session.goal,
                durationSeconds: session.durationSeconds,
                startedAt: session.startedAt,
                endedAt: session.endedAt,
                wasCompleted: session.wasCompleted,
                focusBreaks: session.focusBreaks.map { brk in
                    ExportBreak(
                        secondsSinceSessionStart: brk.secondsSinceSessionStart,
                        timestamp: brk.timestamp
                    )
                },
                todos: session.todos.map { todo in
                    ExportTodo(text: todo.text, isCompleted: todo.isCompleted)
                }
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(exportData) else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "macmodoro_sessions.json"
        panel.allowedContentTypes = [.json]

        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url)
        }
    }

    static func exportCSV(container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PomodoroSession>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])

        guard let sessions = try? context.fetch(descriptor), !sessions.isEmpty else { return }

        var csv = "날짜,시작시간,목표,시간(분),완료여부,집중깨짐횟수,할일완료\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        for session in sessions {
            let date = dateFormatter.string(from: session.startedAt)
            let time = timeFormatter.string(from: session.startedAt)
            let goal = session.goal.replacingOccurrences(of: ",", with: ";")
            let completed = session.wasCompleted ? "Y" : "N"
            let completedTodos = session.todos.filter(\.isCompleted).count
            let totalTodos = session.todos.count
            let todoStr = totalTodos > 0 ? "\(completedTodos)/\(totalTodos)" : "-"

            csv += "\(date),\(time),\(goal),\(session.focusedMinutes),\(completed),\(session.breakCount),\(todoStr)\n"
        }

        guard let data = csv.data(using: .utf8) else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "macmodoro_sessions.csv"

        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url)
        }
    }
}
