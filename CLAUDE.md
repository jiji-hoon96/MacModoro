# MacModoro 개발 가이드

## 빌드
```bash
xcodegen generate
xcodebuild -project MacModoro.xcodeproj -scheme MacModoro build
```

## 구조
- `MacModoro/App/` — 앱 진입점, AppDelegate (NSStatusItem + NSPopover)
- `MacModoro/Core/Models/` — SwiftData 모델 (PomodoroSession, FocusBreak, TodoItem, TimerPreset)
- `MacModoro/Core/Persistence/` — AppSettings (UserDefaults 싱글턴)
- `MacModoro/Services/` — TimerService, GlobalShortcutService, MenuBarAnimation, ScreenFlash, DataExport
- `MacModoro/Features/` — SwiftUI 뷰 (Timer, Goals, Presets, History, Settings)

## 규칙
- 설정 열기: `NotificationCenter`로 `AppDelegate.openSettingsNotification` post
- 메뉴바는 `NSStatusItem` + `NSPopover` (MenuBarExtra 사용 안 함)
- 글로벌 단축키: Carbon API (`GlobalShortcutService`)
- 새 파일 추가 후 반드시 `xcodegen generate` 실행

## 릴리즈
```bash
./scripts/bump-version.sh 1.x.0
# CHANGELOG.md 업데이트
git add -A && git commit -m "release: v1.x.0"
git tag v1.x.0
git push origin main --tags
# GitHub Actions가 자동으로 Release + zip 생성
```
