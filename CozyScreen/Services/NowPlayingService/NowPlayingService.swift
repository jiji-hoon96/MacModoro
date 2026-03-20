import Foundation
import AppKit

@MainActor
final class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var albumName: String = ""
    @Published var artwork: NSImage?
    @Published var isPlaying: Bool = false

    var hasContent: Bool {
        !title.isEmpty
    }

    private init() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(nowPlayingChanged),
            name: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil
        )

        // Spotify 지원
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(spotifyChanged),
            name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil
        )
    }

    @objc private func nowPlayingChanged(_ notification: Notification) {
        guard let info = notification.userInfo else { return }

        title = info["Name"] as? String ?? ""
        artist = info["Artist"] as? String ?? ""
        albumName = info["Album"] as? String ?? ""

        let state = info["Player State"] as? String ?? ""
        isPlaying = state == "Playing"

        // artwork는 Music.app에서 직접 가져오기 어려우므로 nil 유지
    }

    @objc private func spotifyChanged(_ notification: Notification) {
        guard let info = notification.userInfo else { return }

        title = info["Name"] as? String ?? ""
        artist = info["Artist"] as? String ?? ""
        albumName = info["Album"] as? String ?? ""

        let state = info["Player State"] as? String ?? ""
        isPlaying = state == "Playing"
    }
}
