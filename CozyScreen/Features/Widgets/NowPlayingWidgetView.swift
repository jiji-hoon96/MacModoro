import SwiftUI

struct NowPlayingWidgetView: View {
    @StateObject private var nowPlaying = NowPlayingService.shared

    var body: some View {
        if nowPlaying.hasContent {
            HStack(spacing: 12) {
                Image(systemName: nowPlaying.isPlaying ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(nowPlaying.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(nowPlaying.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)

                    if !nowPlaying.albumName.isEmpty {
                        Text(nowPlaying.albumName)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }
            }
            .widgetCard()
        }
    }
}
