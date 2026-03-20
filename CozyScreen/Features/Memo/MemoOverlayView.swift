import SwiftUI
import SwiftData

struct MemoOverlayView: View {
    @Query(sort: \MemoItem.createdAt, order: .reverse) private var memos: [MemoItem]

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("메모")
                    .font(.headline)
                    .foregroundColor(.white)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(memos) { memo in
                            MemoOverlayRow(memo: memo)
                        }
                    }
                }

                if memos.isEmpty {
                    Text("메모가 없습니다")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                }
            }
            .padding()
            .frame(width: 280, height: 400)
            .background(.ultraThinMaterial.opacity(0.8))
            .cornerRadius(16)
            .padding(.trailing, 24)
            .padding(.top, 60)

            Spacer().frame(width: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

struct MemoOverlayRow: View {
    let memo: MemoItem

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(memo.isCompleted ? .green : .white.opacity(0.6))
                .font(.body)

            VStack(alignment: .leading, spacing: 2) {
                Text(memo.title)
                    .foregroundColor(.white)
                    .strikethrough(memo.isCompleted)
                    .font(.body)

                if !memo.content.isEmpty {
                    Text(memo.content)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
