import SwiftUI

struct ScreenSaverContentView: View {
    let onExit: () -> Void
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            // 최하단: 사진 배경
            PhotoBackgroundView()

            // 중간: 3D 씬 (투명 배경)
            Scene3DContainerView()
                .allowsHitTesting(false)

            // 최상단: 메모 오버레이
            if settings.showMemoOverlay {
                MemoOverlayView()
                    .transition(.move(edge: .trailing))
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .onExitCommand(perform: onExit)
    }
}
