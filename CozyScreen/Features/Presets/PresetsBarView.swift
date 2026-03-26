import SwiftUI
import SwiftData

struct PresetsBarView: View {
    @Query(sort: \TimerPreset.sortOrder) private var presets: [TimerPreset]
    @Binding var selectedMinutes: Int
    @State private var showManagement = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("즐겨찾기", systemImage: "star")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(presets) { preset in
                    Button {
                        selectedMinutes = preset.durationMinutes
                    } label: {
                        Text("\(preset.durationMinutes)분")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                selectedMinutes == preset.durationMinutes
                                    ? Color.orange.opacity(0.2)
                                    : Color.gray.opacity(0.1),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    showManagement = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showManagement) {
            PresetManagementView()
        }
    }
}
