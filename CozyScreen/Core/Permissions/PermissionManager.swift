import AppKit

final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    // Carbon RegisterEventHotKey는 접근성 권한이 필요 없음
    // 향후 CGEvent 기반 기능 추가 시 권한 체크 활성화
    @Published var isAccessibilityGranted: Bool = true

    private init() {}

    func requestAccessibility() {
        // no-op: Carbon HotKey는 권한 불필요
    }
}
