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
        let settings = AppSettings.shared
        guard let photoSet = settings.selectedPhotoSet else { return }

        photoURLs = photoSet.photoURLs().filter { FileManager.default.fileExists(atPath: $0.path) }
        guard !photoURLs.isEmpty else { return }

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
        currentImage = NSImage(contentsOf: photoURLs[index])
    }
}
