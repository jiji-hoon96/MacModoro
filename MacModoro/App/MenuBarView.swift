import SwiftUI

struct MenuBarPopoverView: View {
    @StateObject private var timerService = TimerService.shared
    @State private var showHistory = false

    var body: some View {
        Group {
            if showHistory {
                VStack(spacing: 0) {
                    Button {
                        showHistory = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("뒤로")
                            Spacer()
                        }
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()

                    Divider()

                    HistoryView()
                }
            } else {
                switch timerService.state {
                case .idle:
                    PreSessionView(timerService: timerService, showHistory: $showHistory)
                case .running, .paused:
                    ActiveSessionView(timerService: timerService)
                case .finished:
                    SessionSummaryView(timerService: timerService)
                }
            }
        }
    }
}
