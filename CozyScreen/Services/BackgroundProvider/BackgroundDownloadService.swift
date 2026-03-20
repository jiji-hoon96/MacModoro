import Foundation

final class BackgroundDownloadService: ObservableObject {
    static let shared = BackgroundDownloadService()

    @Published var downloadProgress: [String: Double] = [:]
    @Published var downloadedPacks: Set<String> = []

    private let defaults = UserDefaults.standard
    private let downloadedKey = "downloadedBackgroundPacks"

    private init() {
        if let saved = defaults.stringArray(forKey: downloadedKey) {
            downloadedPacks = Set(saved)
        }
    }

    func isDownloaded(_ packID: String) -> Bool {
        guard downloadedPacks.contains(packID) else { return false }
        let localPath = localURL(for: packID)
        return FileManager.default.fileExists(atPath: localPath.path)
    }

    func localURL(for packID: String) -> URL {
        AssetManager.shared.backgroundDirectory.appendingPathComponent("\(packID).jpg")
    }

    func previewURL(for packID: String) -> URL {
        localURL(for: packID)
    }

    func download(_ pack: BackgroundPack) async throws {
        let destination = localURL(for: pack.id)

        if FileManager.default.fileExists(atPath: destination.path) {
            await MainActor.run { markDownloaded(pack.id) }
            return
        }

        let (asyncBytes, response) = try await URLSession.shared.bytes(from: pack.downloadURL)

        let expectedLength = (response as? HTTPURLResponse)
            .flatMap { Int($0.value(forHTTPHeaderField: "Content-Length") ?? "") } ?? 0

        var data = Data()
        if expectedLength > 0 {
            data.reserveCapacity(expectedLength)
        }

        var received = 0
        for try await byte in asyncBytes {
            data.append(byte)
            received += 1
            if expectedLength > 0 && received % 4096 == 0 {
                let progress = Double(received) / Double(expectedLength)
                await MainActor.run {
                    self.downloadProgress[pack.id] = min(progress, 1.0)
                }
            }
        }

        try data.write(to: destination)

        await MainActor.run {
            markDownloaded(pack.id)
            downloadProgress.removeValue(forKey: pack.id)
        }
    }

    func deleteDownload(_ packID: String) {
        let file = localURL(for: packID)
        try? FileManager.default.removeItem(at: file)
        downloadedPacks.remove(packID)
        saveState()
    }

    private func markDownloaded(_ id: String) {
        downloadedPacks.insert(id)
        saveState()
    }

    private func saveState() {
        defaults.set(Array(downloadedPacks), forKey: downloadedKey)
    }
}
