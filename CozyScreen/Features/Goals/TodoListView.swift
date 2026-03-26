import SwiftUI

struct TodoListView: View {
    @Binding var todos: [String]
    @State private var newTodoText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("할 일", systemImage: "checklist")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ForEach(todos.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Text(todos[index])
                        .font(.subheadline)

                    Spacer()

                    Button {
                        todos.remove(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                TextField("할 일 추가...", text: $newTodoText)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
                    .onSubmit { addTodo() }

                Button(action: addTodo) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .disabled(newTodoText.isEmpty)
            }
        }
    }

    private func addTodo() {
        guard !newTodoText.isEmpty else { return }
        todos.append(newTodoText)
        newTodoText = ""
    }
}
