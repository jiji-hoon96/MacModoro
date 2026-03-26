# MacModoro

macOS 메뉴바에서 동작하는 뽀모도로 타이머. 귀여운 픽셀아트 아이콘이 집중 시간 동안 움직입니다.

## Features

- **메뉴바 애니메이션** — 20종 픽셀아트 아이콘 (고양이, 강아지, 로켓 등), 남은 시간이 적을수록 빨라짐
- **집중 깨짐 추적** — 글로벌 단축키(Cmd+Shift+B)로 집중이 깨진 순간을 기록, 세션 종료 후 타임라인 확인
- **목표 & TODO** — 세션 시작 전 목표 설정, 할 일 체크리스트
- **화면 깜빡임 경고** — 종료 5초 전 화면 dim 효과로 알림
- **타이머 프리셋** — 즐겨찾기 시간 저장 (기본: 90분/40분/20분/5분)
- **히스토리** — 오늘/이번 주 집중 통계, 전체 세션 기록
- **데이터 소유** — JSON/CSV 내보내기

## Requirements

- macOS 14.0 (Sonoma) 이상
- Xcode 15.0 이상

## Build

```bash
# XcodeGen 설치 (처음 한 번)
brew install xcodegen

# 프로젝트 생성 및 빌드
xcodegen generate
open MacModoro.xcodeproj
```

Xcode에서 `Cmd + R`로 실행.

## Tech Stack

Swift · SwiftUI · SwiftData · XcodeGen · Carbon API (글로벌 단축키)

## License

MIT
