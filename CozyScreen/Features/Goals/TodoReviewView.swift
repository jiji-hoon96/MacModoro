import SwiftUI

struct TodoReviewView: View {
    let todos: [TodoItem]
    var onToggle: ((TodoItem) -> Void)?

    var body: some View {
        if !todos.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("할 일 점검", systemImage: "checklist")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                ForEach(todos) { todo in
                    HStack {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.isCompleted ? .green : .secondary)
                            .onTapGesture {
                                onToggle?(todo)
                            }

                        Text(todo.text)
                            .font(.subheadline)
                            .strikethrough(todo.isCompleted)
                            .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    }
                }
            }
        }
    }
}
