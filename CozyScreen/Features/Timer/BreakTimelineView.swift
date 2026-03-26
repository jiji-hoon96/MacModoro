import SwiftUI

struct BreakTimelineView: View {
    let breaks: [FocusBreak]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("깨짐 시점")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ForEach(sortedBreaks) { brk in
                let min = brk.secondsSinceSessionStart / 60
                let sec = brk.secondsSinceSessionStart % 60
                HStack(spacing: 4) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                    Text("\(String(format: "%d:%02d", min, sec)) 경과 시점")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sortedBreaks: [FocusBreak] {
        breaks.sorted { $0.secondsSinceSessionStart < $1.secondsSinceSessionStart }
    }
}
