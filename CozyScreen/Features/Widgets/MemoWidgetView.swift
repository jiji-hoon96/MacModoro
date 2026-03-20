import SwiftUI
import SwiftData

struct MemoWidgetView: View {
    @Query(sort: \MemoItem.createdAt, order: .reverse) private var memos: [MemoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("메모", systemImage: "note.text")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            if memos.isEmpty {
                Text("메모가 없습니다")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                ForEach(memos.prefix(8)) { memo in
                    HStack(spacing: 8) {
                        Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(memo.isCompleted ? .green : .white.opacity(0.5))
                            .font(.system(size: 12))

                        Text(memo.title)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .strikethrough(memo.isCompleted)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(width: 240, alignment: .leading)
        .widgetCard()
    }
}
