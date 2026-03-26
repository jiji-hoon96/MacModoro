import SwiftUI

struct MenuBarPopoverView: View {
    @StateObject private var timerService = TimerService.shared
    @State private var showHistory = false

    var body: some View {
        Group {
            if showHistory {
                VStack {
                    HStack {
                        Button {
                            showHistory = false
                        } label: {
                            Label("뒤로", systemImage: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

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
