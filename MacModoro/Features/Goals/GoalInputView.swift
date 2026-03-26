import SwiftUI

struct GoalInputView: View {
    @Binding var goal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("목표", systemImage: "target")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("이번 세션에서 이루고 싶은 것...", text: $goal)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
        }
    }
}
