import SwiftUI
import SwiftData

struct ScreenSaverContentView: View {
    let onExit: () -> Void
    @StateObject private var settings = AppSettings.shared
    @Query(sort: \MemoItem.createdAt, order: .reverse) private var memos: [MemoItem]

    var body: some View {
        ZStack {
            PhotoBackgroundView()

            Scene3DContainerView()
                .allowsHitTesting(false)

            if settings.showMemoOverlay && !memos.isEmpty {
                MemoOverlayView()
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .onExitCommand(perform: onExit)
    }
}
