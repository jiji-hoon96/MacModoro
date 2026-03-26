import SwiftUI

struct GoalInputView: View {
    @Binding var goal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("목표", systemImage: "target")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            TextField("이번 세션의 목표...", text: $goal)
                .textFieldStyle(.roundedBorder)
        }
    }
}
