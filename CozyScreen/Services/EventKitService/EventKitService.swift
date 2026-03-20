import EventKit
import Foundation

@MainActor
final class EventKitService: ObservableObject {
    static let shared = EventKitService()

    private let store = EKEventStore()

    @Published var calendarEvents: [EKEvent] = []
    @Published var reminders: [EKReminder] = []
    @Published var calendarAuthorized = false
    @Published var remindersAuthorized = false

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged),
            name: .EKEventStoreChanged,
            object: store
        )
    }

    @objc private func storeChanged() {
        Task { @MainActor in
            await refreshAll()
        }
    }

    // MARK: - Permissions

    func requestCalendarAccess() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            calendarAuthorized = granted
            if granted { await fetchCalendarEvents() }
        } catch {
            print("Calendar access error: \(error)")
        }
    }

    func requestRemindersAccess() async {
        do {
            let granted = try await store.requestFullAccessToReminders()
            remindersAuthorized = granted
            if granted { await fetchReminders() }
        } catch {
            print("Reminders access error: \(error)")
        }
    }

    func checkPermissions() {
        let calStatus = EKEventStore.authorizationStatus(for: .event)
        calendarAuthorized = calStatus == .fullAccess || calStatus == .authorized

        let remStatus = EKEventStore.authorizationStatus(for: .reminder)
        remindersAuthorized = remStatus == .fullAccess || remStatus == .authorized
    }

    // MARK: - Fetch

    func refreshAll() async {
        checkPermissions()
        if calendarAuthorized { await fetchCalendarEvents() }
        if remindersAuthorized { await fetchReminders() }
    }

    func fetchCalendarEvents() async {
        let hours = AppSettings.shared.calendarHorizonHours
        let start = Date()
        let end = Calendar.current.date(byAdding: .hour, value: hours, to: start)!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
        calendarEvents = Array(events.prefix(10))
    }

    func fetchReminders() async {
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            calendars: nil
        )

        await withCheckedContinuation { continuation in
            store.fetchReminders(matching: predicate) { [weak self] result in
                Task { @MainActor in
                    let sorted = (result ?? [])
                        .sorted { ($0.dueDateComponents?.date ?? .distantFuture) < ($1.dueDateComponents?.date ?? .distantFuture) }
                    self?.reminders = Array(sorted.prefix(10))
                    continuation.resume()
                }
            }
        }
    }
}
