import SwiftUI
import SwiftData

struct DataSettingsTab: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("데이터 내보내기") {
                Button("JSON으로 내보내기") {
                    DataExportService.exportJSON(container: SharedModelContainer.shared)
                }
                Button("CSV로 내보내기") {
                    DataExportService.exportCSV(container: SharedModelContainer.shared)
                }
            }

            Section("데이터 관리") {
                Button("전체 세션 기록 삭제") {
                    clearAllSessions()
                }
                .foregroundStyle(.red)
            }
        }
        .padding()
    }

    private func clearAllSessions() {
        try? modelContext.delete(model: PomodoroSession.self)
        try? modelContext.save()
    }
}
