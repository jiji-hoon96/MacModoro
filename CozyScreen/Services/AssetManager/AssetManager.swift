import Foundation
import AppKit

final class AssetManager {
    static let shared = AssetManager()

    let baseDirectory: URL
    let photoDirectory: URL
    let characterDirectory: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseDirectory = appSupport.appendingPathComponent("CozyScreen", isDirectory: true)
        photoDirectory = baseDirectory.appendingPathComponent("Photos", isDirectory: true)
        characterDirectory = baseDirectory.appendingPathComponent("Characters", isDirectory: true)

        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        let fm = FileManager.default
        for dir in [baseDirectory, photoDirectory, characterDirectory] {
            if !fm.fileExists(atPath: dir.path) {
                try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
    }

    func importPhotos(from urls: [URL]) -> [String] {
        var fileNames: [String] = []
        let fm = FileManager.default

        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }

            let uniqueName = "\(UUID().uuidString)_\(url.lastPathComponent)"
            let dest = photoDirectory.appendingPathComponent(uniqueName)
            do {
                try fm.copyItem(at: url, to: dest)
                fileNames.append(uniqueName)
            } catch {
                print("Failed to import photo: \(error)")
            }
        }
        return fileNames
    }

    func importCharacter(from url: URL) -> String? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }

        let uniqueName = "\(UUID().uuidString)_\(url.lastPathComponent)"
        let dest = characterDirectory.appendingPathComponent(uniqueName)
        do {
            try FileManager.default.copyItem(at: url, to: dest)
            return uniqueName
        } catch {
            print("Failed to import character: \(error)")
            return nil
        }
    }

    func deletePhoto(named fileName: String) {
        let url = photoDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    func deleteCharacter(named fileName: String) {
        let url = characterDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    func photoURL(for fileName: String) -> URL {
        photoDirectory.appendingPathComponent(fileName)
    }
}
