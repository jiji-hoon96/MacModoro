import SwiftUI
import UniformTypeIdentifiers

struct CharacterSettingsTab: View {
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3D 캐릭터 선택")
                .font(.headline)

            List {
                ForEach(settings.availableCharacters) { character in
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                            .frame(width: 36)

                        VStack(alignment: .leading) {
                            Text(character.name)
                                .font(.body)
                            Text(character.isBuiltIn ? "기본 캐릭터" : character.fileName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if settings.selectedCharacterID == character.id.uuidString {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settings.selectedCharacterID = character.id.uuidString
                    }
                    .contextMenu {
                        if !character.isBuiltIn {
                            Button("삭제", role: .destructive) {
                                deleteCharacter(character)
                            }
                        }
                    }
                }
            }
            .listStyle(.bordered)

            HStack {
                Button("USDZ 파일 가져오기") {
                    importCharacter()
                }

                Spacer()

                Text("지원 형식: .usdz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private func importCharacter() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        let usdzType = UTType(filenameExtension: "usdz") ?? .data
        panel.allowedContentTypes = [usdzType]

        guard panel.runModal() == .OK, let url = panel.url else { return }

        if let fileName = AssetManager.shared.importCharacter(from: url) {
            let name = url.deletingPathExtension().lastPathComponent
            let asset = CharacterAsset(
                id: UUID(),
                name: name,
                fileName: fileName,
                isBuiltIn: false
            )
            var chars = settings.availableCharacters
            chars.append(asset)
            settings.availableCharacters = chars
            settings.selectedCharacterID = asset.id.uuidString
        }
    }

    private func deleteCharacter(_ character: CharacterAsset) {
        AssetManager.shared.deleteCharacter(named: character.fileName)
        var chars = settings.availableCharacters
        chars.removeAll { $0.id == character.id }
        settings.availableCharacters = chars

        if settings.selectedCharacterID == character.id.uuidString {
            settings.selectedCharacterID = chars.first?.id.uuidString
        }
    }
}
