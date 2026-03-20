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
                    .transition(.opacity)
                    .id(viewModel.currentIndex)
            }
        }
        .animation(.easeInOut(duration: 2.0), value: viewModel.currentIndex)
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
        let settings = AppSettings.shared

        guard let photoSet = settings.selectedPhotoSet else {
            print("[PhotoBackground] No photo set selected")
            return
        }

        photoURLs = photoSet.photoURLs().filter {
            FileManager.default.fileExists(atPath: $0.path(percentEncoded: false))
        }

        guard !photoURLs.isEmpty else {
            print("[PhotoBackground] No photos found in set '\(photoSet.name)'")
            return
        }

        print("[PhotoBackground] Loaded \(photoURLs.count) photos from '\(photoSet.name)'")
        loadPhoto(at: 0)

        timer = Timer.scheduledTimer(withTimeInterval: settings.photoTransitionInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.advancePhoto()
            }
        }
    }

    func stopSlideshow() {
        timer?.invalidate()
        timer = nil
    }

    private func advancePhoto() {
        guard !photoURLs.isEmpty else { return }
        currentIndex = (currentIndex + 1) % photoURLs.count
        loadPhoto(at: currentIndex)
    }

    private func loadPhoto(at index: Int) {
        guard index < photoURLs.count else { return }
        let url = photoURLs[index]
        currentImage = NSImage(contentsOf: url) ?? NSImage(contentsOfFile: url.path(percentEncoded: false))
    }
}
