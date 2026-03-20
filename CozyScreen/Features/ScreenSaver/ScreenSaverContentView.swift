import SwiftUI

struct ScreenSaverContentView: View {
    let onExit: () -> Void
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            PhotoBackgroundView()

            Scene3DContainerView()

            if settings.showMemoOverlay {
                MemoOverlayView()
                    .transition(.move(edge: .trailing))
            }
        }
        .ignoresSafeArea()
        .onExitCommand(perform: onExit)
    }
}
