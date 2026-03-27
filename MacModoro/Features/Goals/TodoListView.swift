import SwiftUI

struct TodoListView: View {
    @Binding var todos: [String]
    @State private var newTodoText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(todos.indices, id: \.self) { index in
                HStack(spacing: 6) {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        .frame(width: 12, height: 12)

                    Text(todos[index])
                        .font(.system(size: 12))

                    Spacer()

                    Button {
                        todos.remove(at: index)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 6) {
                TextField("할 일 추가", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .onSubmit { addTodo() }

                if !newTodoText.isEmpty {
                    Button(action: addTodo) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
        }
    }

    private func addTodo() {
        guard !newTodoText.isEmpty else { return }
        todos.append(newTodoText)
        newTodoText = ""
    }
}
