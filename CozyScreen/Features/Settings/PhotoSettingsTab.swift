import SwiftUI

struct PhotoSettingsTab: View {
    @StateObject private var settings = AppSettings.shared
    @State private var selectedSetID: UUID?
    @State private var newSetName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                TextField("새 사진 세트 이름", text: $newSetName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)

                Button("추가") {
                    guard !newSetName.isEmpty else { return }
                    var sets = settings.photoSets
                    let newSet = PhotoSet(name: newSetName)
                    sets.append(newSet)
                    settings.photoSets = sets
                    selectedSetID = newSet.id
                    newSetName = ""
                }
            }

            if settings.photoSets.isEmpty {
                Spacer()
                Text("사진 세트를 추가해 주세요")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                List(selection: $selectedSetID) {
                    ForEach(settings.photoSets) { photoSet in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(photoSet.name)
                                    .font(.headline)
                                Text("\(photoSet.photoFileNames.count)장")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if settings.selectedPhotoSetID == photoSet.id.uuidString {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .tag(photoSet.id)
                        .contextMenu {
                            Button("배경으로 선택") {
                                settings.selectedPhotoSetID = photoSet.id.uuidString
                            }
                            Button("삭제", role: .destructive) {
                                deletePhotoSet(photoSet)
                            }
                        }
                    }
                }
                .listStyle(.bordered)

                HStack {
                    Button("사진 추가") {
                        importPhotos()
                    }
                    .disabled(selectedSetID == nil)

                    Spacer()

                    if let id = selectedSetID,
                       let set = settings.photoSets.first(where: { $0.id == id }) {
                        Button("배경으로 사용") {
                            settings.selectedPhotoSetID = set.id.uuidString
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func importPhotos() {
        guard let setID = selectedSetID else { return }

        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]

        guard panel.runModal() == .OK else { return }

        let fileNames = AssetManager.shared.importPhotos(from: panel.urls)

        var sets = settings.photoSets
        if let index = sets.firstIndex(where: { $0.id == setID }) {
            sets[index].photoFileNames.append(contentsOf: fileNames)
            settings.photoSets = sets
        }
    }

    private func deletePhotoSet(_ photoSet: PhotoSet) {
        for fileName in photoSet.photoFileNames {
            AssetManager.shared.deletePhoto(named: fileName)
        }
        var sets = settings.photoSets
        sets.removeAll { $0.id == photoSet.id }
        settings.photoSets = sets

        if settings.selectedPhotoSetID == photoSet.id.uuidString {
            settings.selectedPhotoSetID = nil
        }
    }
}
