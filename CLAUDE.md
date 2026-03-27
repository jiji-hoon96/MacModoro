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
- `MacModoro/Services/` — TimerService, GlobalShortcutService, MenuBarAnimation, ScreenFlash, DataExport, WhiteNoise, DistractionDetector
- `MacModoro/Features/` — SwiftUI 뷰 (Timer, Goals, Presets, History, Settings)

## 디자인 원칙

Ref: [Minimalist Pomodoro Timer](https://dribbble.com/shots/25936866), [Daily UI 014](https://dribbble.com/shots/22102886), [Apple HIG Menu Bar](https://developer.apple.com/design/human-interface-guidelines/the-menu-bar)

- **타이포그래피**: `.rounded` 디자인, `.thin`~`.ultraLight` weight로 큰 숫자 표현
- **색상**: `Color.primary.opacity()` 기반 모노톤. 강조색은 `.orange`, `.green`, `.red`만 사용
- **라벨**: uppercase + `kerning(1~2)` (예: "FOCUS", "MINUTES", "COMPLETE")
- **여백**: 넉넉하게. 요소 간 Spacer 활용, padding 최소 16~24
- **컴포넌트**: 배경은 `Color.primary.opacity(0.03~0.06)`, 카드 테두리 없음
- **버튼**: 캡슐형(Capsule) 기본, 원형(Circle) 컨트롤, plain 스타일 + background
- **진행률**: 3pt thin stroke, lineCap .round
- **텍스트필드**: 라벨 없음, placeholder만, plain + 배경
- **팝오버 크기**: 280pt 폭, 400pt 높이

## 규칙
- 설정 열기: `NotificationCenter`로 `AppDelegate.openSettingsNotification` post
- 메뉴바는 `NSStatusItem` + `NSPopover` (MenuBarExtra 사용 안 함)
- 글로벌 단축키: Carbon API (`GlobalShortcutService`)
- 새 파일 추가 후 반드시 `xcodegen generate` 실행
- 설정 변경은 AppDelegate에서 Combine으로 실시간 반영 (타이머 재시작 불필요)
- 작업 단위별로 커밋할 것 (1건 작업 → 빌드 확인 → 커밋 → 다음)

## 릴리즈
```bash
./scripts/bump-version.sh 1.x.0
# CHANGELOG.md 업데이트
git add -A && git commit -m "release: v1.x.0"
git tag v1.x.0
git push origin main --tags
# GitHub Actions가 자동으로 Release + zip 생성
```
