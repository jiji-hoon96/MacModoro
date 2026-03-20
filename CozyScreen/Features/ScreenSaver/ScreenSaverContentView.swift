import SwiftUI
import SwiftData

struct ScreenSaverContentView: View {
    let onExit: () -> Void

    var body: some View {
        ZStack {
            PhotoBackgroundView()

            WidgetOverlayView()
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
        .onExitCommand(perform: onExit)
    }
}
