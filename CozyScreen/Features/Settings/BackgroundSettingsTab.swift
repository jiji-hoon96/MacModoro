import SwiftUI

struct BackgroundSettingsTab: View {
    @StateObject private var downloadService = BackgroundDownloadService.shared
    @StateObject private var settings = AppSettings.shared
    @State private var selectedCategory: BackgroundCategory = .urban

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("배경 다운로드")
                    .font(.headline)
                Spacer()
                Text("Poly Haven (CC0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("카테고리", selection: $selectedCategory) {
                ForEach(BackgroundCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)

            let packs = BackgroundCatalog.packs(for: selectedCategory)

            List {
                ForEach(packs) { pack in
                    BackgroundPackRow(
                        pack: pack,
                        isDownloaded: downloadService.isDownloaded(pack.id),
                        isSelected: settings.selectedBackgroundID == pack.id,
                        progress: downloadService.downloadProgress[pack.id]
                    )
                }
            }
            .listStyle(.bordered)

            HStack {
                let downloadedCount = BackgroundCatalog.curated.filter { downloadService.isDownloaded($0.id) }.count
                Text("\(downloadedCount)/\(BackgroundCatalog.curated.count)개 다운로드됨")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
    }
}

struct BackgroundPackRow: View {
    let pack: BackgroundPack
    let isDownloaded: Bool
    let isSelected: Bool
    let progress: Double?

    @StateObject private var downloadService = BackgroundDownloadService.shared
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if isDownloaded, let nsImage = NSImage(contentsOf: downloadService.localURL(for: pack.id)) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 45)
                        .cornerRadius(6)
                        .clipped()
                } else {
                    AsyncImage(url: pack.previewURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 45)
                                .cornerRadius(6)
                                .clipped()
                        default:
                            previewPlaceholder
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pack.name)
                        .font(.body)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.caption)
                    }
                }

                HStack(spacing: 8) {
                    Text(pack.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .cornerRadius(4)

                    Text(String(format: "%.1fMB", pack.fileSizeMB))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let progress {
                ProgressView(value: progress)
                    .frame(width: 60)
            } else if isDownloaded {
                HStack(spacing: 8) {
                    Button("선택") {
                        settings.selectedBackgroundID = pack.id
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(isSelected)

                    Button(role: .destructive) {
                        downloadService.deleteDownload(pack.id)
                        if settings.selectedBackgroundID == pack.id {
                            settings.selectedBackgroundID = nil
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .controlSize(.small)
                }
            } else {
                Button("다운로드") {
                    Task {
                        try? await downloadService.download(pack)
                    }
                }
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    private var previewPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.quaternary)
            .frame(width: 80, height: 45)
            .overlay {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
    }
}
