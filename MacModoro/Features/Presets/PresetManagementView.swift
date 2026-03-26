import SwiftUI
import SwiftData

struct PresetManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimerPreset.sortOrder) private var presets: [TimerPreset]

    @State private var newLabel: String = ""
    @State private var newMinutes: Int = 25

    var body: some View {
        VStack(spacing: 16) {
            Text("타이머 프리셋 관리")
                .font(.headline)

            // 기존 프리셋 목록
            List {
                ForEach(presets) { preset in
                    HStack {
                        Text(preset.label)
                        Spacer()
                        Text("\(preset.durationMinutes)분")
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deletePresets)
            }
            .frame(height: 150)

            Divider()

            // 새 프리셋 추가
            HStack {
                TextField("이름", text: $newLabel)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)

                Stepper("\(newMinutes)분", value: $newMinutes, in: 1...120)

                Button("추가") {
                    addPreset()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newLabel.isEmpty)
            }

            Button("닫기") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 350, height: 320)
    }

    private func addPreset() {
        let preset = TimerPreset(
            label: newLabel,
            durationMinutes: newMinutes,
            sortOrder: presets.count
        )
        modelContext.insert(preset)
        newLabel = ""
        newMinutes = 25
    }

    private func deletePresets(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(presets[index])
        }
    }
}
