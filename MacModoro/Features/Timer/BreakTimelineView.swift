import SwiftUI

struct BreakTimelineView: View {
    let breaks: [FocusBreak]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(sortedBreaks) { brk in
                let min = brk.secondsSinceSessionStart / 60
                let sec = brk.secondsSinceSessionStart % 60
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange.opacity(0.5))
                        .frame(width: 4, height: 4)

                    Text("\(String(format: "%d:%02d", min, sec))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)

                    Text(brk.reason)
                        .font(.system(size: 10))
                        .foregroundStyle(.orange.opacity(0.7))
                }
            }
        }
    }

    private var sortedBreaks: [FocusBreak] {
        breaks.sorted { $0.secondsSinceSessionStart < $1.secondsSinceSessionStart }
    }
}
