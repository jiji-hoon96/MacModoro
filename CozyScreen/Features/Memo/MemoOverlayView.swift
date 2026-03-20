import SwiftUI
import SwiftData

struct MemoOverlayView: View {
    @Query(sort: \MemoItem.createdAt, order: .reverse) private var memos: [MemoItem]

    var body: some View {
        VStack {
            Spacer().frame(height: 60)

            HStack {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Divider()
                        .background(Color.white.opacity(0.3))

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(memos) { memo in
                                MemoOverlayRow(memo: memo)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(width: 280, height: min(CGFloat(memos.count * 50 + 80), 400))
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.trailing, 24)
            }

            Spacer()
        }
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
                    .font(.system(size: 14))

                if !memo.content.isEmpty {
                    Text(memo.content)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12))
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
