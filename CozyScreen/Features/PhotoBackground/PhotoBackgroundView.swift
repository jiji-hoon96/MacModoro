import SwiftUI

struct PhotoBackgroundView: View {
    @StateObject private var viewModel = PhotoBackgroundViewModel()

    var body: some View {
        ZStack {
            Color.black

            if let currentImage = viewModel.currentImage {
                Image(nsImage: currentImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.6)
                    .transition(.opacity)
                    .id(viewModel.currentIndex)
            }
        }
        .animation(.easeInOut(duration: 1.5), value: viewModel.currentIndex)
        .onAppear { viewModel.startSlideshow() }
        .onDisappear { viewModel.stopSlideshow() }
    }
}

@MainActor
final class PhotoBackgroundViewModel: ObservableObject {
    @Published var currentImage: NSImage?
    @Published var currentIndex: Int = 0

    private var photoURLs: [URL] = []
    private var timer: Timer?

    func startSlideshow() {
        collectPhotoSources()
        guard !photoURLs.isEmpty else { return }

        loadPhoto(at: 0)

        let interval = AppSettings.shared.photoTransitionInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.advancePhoto()
            }
        }
    }

    func stopSlideshow() {
        timer?.invalidate()
        timer = nil
    }

    private func collectPhotoSources() {
        var urls: [URL] = []
        let settings = AppSettings.shared
        let downloadService = BackgroundDownloadService.shared

        // 1. 다운로드된 Poly Haven 배경 (선택된 것 우선)
        if let bgID = settings.selectedBackgroundID, downloadService.isDownloaded(bgID) {
            let previewURL = downloadService.previewURL(for: bgID)
            if FileManager.default.fileExists(atPath: previewURL.path) {
                urls.append(previewURL)
            }
        }

        // 2. 다운로드된 다른 배경들도 추가
        for pack in BackgroundCatalog.curated where downloadService.isDownloaded(pack.id) {
            let previewURL = downloadService.previewURL(for: pack.id)
            if FileManager.default.fileExists(atPath: previewURL.path) && !urls.contains(previewURL) {
                urls.append(previewURL)
            }
        }

        // 3. 사용자 사진 세트
        if let photoSet = settings.selectedPhotoSet {
            let setURLs = photoSet.photoURLs().filter { FileManager.default.fileExists(atPath: $0.path) }
            urls.append(contentsOf: setURLs)
        }

        photoURLs = urls
    }

    private func advancePhoto() {
        guard !photoURLs.isEmpty else { return }
        currentIndex = (currentIndex + 1) % photoURLs.count
        loadPhoto(at: currentIndex)
    }

    private func loadPhoto(at index: Int) {
        guard index < photoURLs.count else { return }
        currentImage = NSImage(contentsOf: photoURLs[index])
    }
}
