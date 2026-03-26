import AppKit
import Foundation

final class DistractionDetector {
    static let shared = DistractionDetector()

    var onDistraction: (() -> Void)?

    private var observer: NSObjectProtocol?
    private var lastRecordedTime: Date = .distantPast
    private let cooldown: TimeInterval = 10 // 같은 앱 반복 감지 방지 (10초)

    // 집중 깨짐으로 감지할 앱 번들 ID
    private let distractingBundleIDs: Set<String> = [
        // 영상
        "com.google.Chrome",           // Chrome (YouTube)
        "com.apple.Safari",            // Safari (YouTube)
        "org.mozilla.firefox",         // Firefox
        // SNS / 메신저
        "com.kakao.KakaoTalk",         // 카카오톡
        "com.tinyspeck.slackmacgap",   // Slack
        "com.hnc.Discord",             // Discord
        "com.facebook.archon",         // Messenger
        "ru.keepcoder.Telegram",       // Telegram
        "net.whatsapp.WhatsApp",       // WhatsApp
        "com.linecorp.LineForMac",     // Line
        // SNS 앱
        "com.twitter.twitter-mac",     // Twitter/X
        "com.burbn.instagram",         // Instagram
    ]

    // 브라우저에서 감지할 URL 키워드 (탭 제목 기반)
    private let distractingKeywords: [String] = [
        "youtube", "youtu.be",
        "twitter", "x.com",
        "instagram", "facebook",
        "tiktok", "reddit",
        "netflix", "twitch",
    ]

    private init() {}

    func start() {
        stop()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppActivation(notification)
        }
    }

    func stop() {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observer = nil
    }

    private func handleAppActivation(_ notification: Notification) {
        guard AppSettings.shared.enableDistractionDetection else { return }
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier else { return }

        // 자기 자신 무시
        if bundleID == Bundle.main.bundleIdentifier { return }

        // 쿨다운 체크
        guard Date.now.timeIntervalSince(lastRecordedTime) > cooldown else { return }

        // 번들 ID 직접 매칭
        if distractingBundleIDs.contains(bundleID) {
            recordDistraction()
            return
        }

        // 브라우저인 경우 앱 이름 / 타이틀에서 키워드 확인
        let browserBundleIDs: Set<String> = [
            "com.google.Chrome", "com.apple.Safari", "org.mozilla.firefox",
            "com.microsoft.edgemac", "com.brave.Browser", "com.operasoftware.Opera"
        ]

        if browserBundleIDs.contains(bundleID) {
            // 활성 윈도우 제목에서 키워드 감지
            if let title = app.localizedName {
                let lowered = title.lowercased()
                for keyword in distractingKeywords {
                    if lowered.contains(keyword) {
                        recordDistraction()
                        return
                    }
                }
            }
        }
    }

    private func recordDistraction() {
        lastRecordedTime = .now
        onDistraction?()
    }
}
