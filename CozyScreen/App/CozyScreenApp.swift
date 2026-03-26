import SwiftUI
import SwiftData

@main
struct MacModoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let sharedModelContainer: ModelContainer = SharedModelContainer.shared

    init() {
        DefaultPresets.seedIfNeeded(container: sharedModelContainer)
    }

    var body: some Scene {
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}

enum DefaultPresets {
    static func seedIfNeeded(container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TimerPreset>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let defaults = [
            TimerPreset(label: "집중", durationMinutes: 25, sortOrder: 0),
            TimerPreset(label: "짧은 휴식", durationMinutes: 5, sortOrder: 1),
            TimerPreset(label: "긴 집중", durationMinutes: 50, sortOrder: 2),
            TimerPreset(label: "긴 휴식", durationMinutes: 15, sortOrder: 3),
        ]
        defaults.forEach { context.insert($0) }
        try? context.save()
    }
}

enum SharedModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            PomodoroSession.self,
            FocusBreak.self,
            TodoItem.self,
            TimerPreset.self
        ])
        let config = ModelConfiguration("MacModoro", isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
