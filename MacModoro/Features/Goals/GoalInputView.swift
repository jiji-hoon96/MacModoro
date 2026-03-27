import SwiftUI

struct GoalInputView: View {
    @Binding var goal: String

    var body: some View {
        TextField("목표를 입력하세요", text: $goal)
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
    }
}
