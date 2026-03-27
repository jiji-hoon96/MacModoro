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
    private static let currentVersion = 2

    static func seedIfNeeded(container: ModelContainer) {
        let context = ModelContext(container)
        let savedVersion = UserDefaults.standard.integer(forKey: "presetVersion")

        guard savedVersion < currentVersion else { return }

        // 기존 프리셋 삭제
        try? context.delete(model: TimerPreset.self)

        let defaults = [
            TimerPreset(label: "몰입", durationMinutes: 90, sortOrder: 0),
            TimerPreset(label: "집중", durationMinutes: 40, sortOrder: 1),
            TimerPreset(label: "짧은 집중", durationMinutes: 20, sortOrder: 2),
            TimerPreset(label: "휴식", durationMinutes: 5, sortOrder: 3),
        ]
        defaults.forEach { context.insert($0) }
        try? context.save()

        UserDefaults.standard.set(currentVersion, forKey: "presetVersion")
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
            // 스키마 변경으로 기존 스토어 호환 안 될 때 삭제 후 재생성
            let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            for ext in ["MacModoro.store", "MacModoro.store-shm", "MacModoro.store-wal"] {
                try? FileManager.default.removeItem(at: storeURL.appendingPathComponent(ext))
            }
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()
}
