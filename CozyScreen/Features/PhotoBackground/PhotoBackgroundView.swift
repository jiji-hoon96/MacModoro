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

        guard !photoURLs.isEmpty else {
            print("[PhotoBackground] No photo sources found")
            return
        }

        print("[PhotoBackground] Found \(photoURLs.count) photos")
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
        let fm = FileManager.default

        // 1. 선택된 Poly Haven 배경
        if let bgID = settings.selectedBackgroundID {
            let localURL = downloadService.localURL(for: bgID)
            if fm.fileExists(atPath: localURL.path(percentEncoded: false)) {
                urls.append(localURL)
                print("[PhotoBackground] Selected background: \(localURL.lastPathComponent)")
            } else {
                print("[PhotoBackground] Selected background file not found: \(localURL.path(percentEncoded: false))")
            }
        }

        // 2. 다운로드된 다른 배경들도 슬라이드쇼에 추가
        for pack in BackgroundCatalog.curated where downloadService.isDownloaded(pack.id) {
            let localURL = downloadService.localURL(for: pack.id)
            if fm.fileExists(atPath: localURL.path(percentEncoded: false)) && !urls.contains(localURL) {
                urls.append(localURL)
            }
        }

        // 3. 사용자 사진 세트
        if let photoSet = settings.selectedPhotoSet {
            let setURLs = photoSet.photoURLs().filter { fm.fileExists(atPath: $0.path(percentEncoded: false)) }
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
        let url = photoURLs[index]

        if let image = NSImage(contentsOf: url) {
            currentImage = image
        } else {
            // file URL path로 직접 시도
            let image = NSImage(contentsOfFile: url.path(percentEncoded: false))
            currentImage = image
            if image == nil {
                print("[PhotoBackground] Failed to load: \(url.path(percentEncoded: false))")
            }
        }
    }
}
