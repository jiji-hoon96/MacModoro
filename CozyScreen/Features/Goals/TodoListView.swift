import SwiftUI

struct TodoListView: View {
    @Binding var todos: [String]
    @State private var newTodoText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("할 일", systemImage: "checklist")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            ForEach(todos.indices, id: \.self) { index in
                HStack(spacing: 6) {
                    Image(systemName: "circle")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    Text(todos[index])
                        .font(.system(size: 13))

                    Spacer()

                    Button {
                        todos.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 6) {
                TextField("할 일 추가...", text: $newTodoText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onSubmit { addTodo() }

                Button(action: addTodo) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(newTodoText.isEmpty)
                .foregroundStyle(newTodoText.isEmpty ? Color.gray : Color.accentColor)
            }
        }
    }

    private func addTodo() {
        guard !newTodoText.isEmpty else { return }
        todos.append(newTodoText)
        newTodoText = ""
    }
}
