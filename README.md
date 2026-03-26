# MacModoro

macOS 메뉴바에서 동작하는 뽀모도로 타이머. 귀여운 픽셀아트 아이콘이 집중 시간 동안 움직입니다.

## Install

### Homebrew (권장)

```bash
brew tap jiji-hoon96/macmodoro https://github.com/jiji-hoon96/cozyScreen
brew install --cask macmodoro
```

### 직접 다운로드

[Releases](https://github.com/jiji-hoon96/cozyScreen/releases)에서 최신 zip 다운로드 → 압축 해제 → `MacModoro.app`을 Applications로 이동

> 처음 실행 시 "확인되지 않은 개발자" 경고가 뜨면: 우클릭 > 열기, 또는 `시스템 설정 > 개인정보 보호 및 보안`에서 허용

### 삭제

```bash
# Homebrew로 설치한 경우
brew uninstall macmodoro

# 직접 설치한 경우
# MacModoro.app을 휴지통으로 이동
```

## Features

- **메뉴바 애니메이션** — 20종 픽셀아트 아이콘 (고양이, 강아지, 로켓 등), 남은 시간이 적을수록 빨라짐
- **집중 깨짐 추적** — 글로벌 단축키(`Cmd+Shift+B`)로 집중이 깨진 순간을 기록, 세션 종료 후 타임라인 확인
- **목표 & TODO** — 세션 시작 전 목표 설정, 할 일 체크리스트
- **화면 dim 경고** — 종료 5초 전 화면 어두워짐으로 알림 (설정에서 on/off)
- **타이머 프리셋** — 즐겨찾기 시간 저장 (기본: 90분/40분/20분/5분)
- **히스토리** — 오늘/이번 주 집중 통계, 전체 세션 기록
- **데이터 소유** — JSON/CSV 내보내기

## Usage

1. 메뉴바 아이콘 클릭 → 시간 설정 (직접 입력 또는 프리셋)
2. 목표/할 일 입력 (선택)
3. **집중 시작** 클릭
4. 집중이 깨지면 `Cmd+Shift+B` (횟수와 시점 자동 기록)
5. 세션 종료 → 통계 확인

## Build from Source

```bash
brew install xcodegen
git clone https://github.com/jiji-hoon96/cozyScreen.git
cd cozyScreen
xcodegen generate
open MacModoro.xcodeproj
# Cmd + R 로 실행
```

## Tech Stack

Swift · SwiftUI · SwiftData · XcodeGen · Carbon API

## License

MIT
