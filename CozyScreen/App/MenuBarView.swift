import SwiftUI

struct MenuBarPopoverView: View {
    @StateObject private var timerService = TimerService.shared
    @State private var showHistory = false

    var body: some View {
        Group {
            if showHistory {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            showHistory = false
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("뒤로")
                            }
                            .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

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
