import AppKit
import Foundation

final class DistractionDetector {
    static let shared = DistractionDetector()

    var onDistraction: (() -> Void)?

    private var observer: NSObjectProtocol?
    private var lastRecordedTime: Date = .distantPast
    private let cooldown: TimeInterval = 10

    // 집중 깨짐으로 감지할 앱 번들 ID (부분 매칭 포함)
    private let distractingBundlePatterns: [String] = [
        // 메신저
        "com.kakao",              // 카카오톡 (com.kakao.KakaoTalk 등)
        "com.tinyspeck.slackmacgap", // Slack
        "com.hnc.Discord",        // Discord
        "ru.keepcoder.Telegram",  // Telegram
        "net.whatsapp",           // WhatsApp
        "com.linecorp",           // Line
        "com.facebook",           // Messenger
        // SNS
        "com.twitter",            // Twitter/X
        "com.burbn.instagram",    // Instagram
        "com.reddit",             // Reddit
        "com.zhiliaoapp.musically", // TikTok
    ]

    // 브라우저에서 감지 안 함 (개발 작업 중 사용하므로 오탐 많음)
    // 대신 순수 SNS/메신저 앱만 감지

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

        // 번들 ID 부분 매칭 (com.kakao → com.kakao.KakaoTalk도 매칭)
        for pattern in distractingBundlePatterns {
            if bundleID.hasPrefix(pattern) || bundleID == pattern {
                recordDistraction(appName: app.localizedName ?? bundleID)
                return
            }
        }
    }

    private func recordDistraction(appName: String) {
        lastRecordedTime = .now
        print("[MacModoro] 집중 깨짐 감지: \(appName)")
        onDistraction?()
    }
}
