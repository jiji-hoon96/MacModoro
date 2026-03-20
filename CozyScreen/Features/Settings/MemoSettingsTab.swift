import SwiftUI
import SwiftData

struct MemoSettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoItem.createdAt, order: .reverse) private var memos: [MemoItem]

    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var editingMemo: MemoItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("새 메모 제목", text: $newTitle)
                    .textFieldStyle(.roundedBorder)

                Button("추가") {
                    addMemo()
                }
                .disabled(newTitle.isEmpty)
            }

            TextField("내용 (선택사항)", text: $newContent)
                .textFieldStyle(.roundedBorder)

            List {
                ForEach(memos) { memo in
                    HStack {
                        Button {
                            memo.isCompleted.toggle()
                            memo.updatedAt = .now
                        } label: {
                            Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(memo.isCompleted ? .green : .secondary)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(memo.title)
                                .strikethrough(memo.isCompleted)
                            if !memo.content.isEmpty {
                                Text(memo.content)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Text(memo.createdAt.formatted(.dateTime.month().day()))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .contextMenu {
                        Button("삭제", role: .destructive) {
                            modelContext.delete(memo)
                        }
                    }
                }
            }
            .listStyle(.bordered)
        }
        .padding()
    }

    private func addMemo() {
        let memo = MemoItem(title: newTitle, content: newContent)
        modelContext.insert(memo)
        newTitle = ""
        newContent = ""
    }
}
