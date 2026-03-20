import SwiftUI
import SwiftData

@main
struct CozyScreenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let sharedModelContainer: ModelContainer = SharedModelContainer.shared

    var body: some Scene {
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }

        MenuBarExtra("CozyScreen", systemImage: "sparkles.tv") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
    }
}

enum SharedModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([MemoItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
