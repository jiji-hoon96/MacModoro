import SwiftUI

struct TimerSettingsTab: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var previewFrames: [NSImage] = []
    @State private var previewFrame = 0
    @State private var previewTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("기본 설정") {
                    Stepper("기본 시간: \(settings.defaultDurationMinutes)분",
                            value: $settings.defaultDurationMinutes,
                            in: 1...180)

                    Toggle("메뉴바에 남은 시간 표시", isOn: $settings.showRemainingTimeInMenuBar)
                }

                Section("애니메이션 속도") {
                    HStack {
                        Text("느리게")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $settings.animationSpeed, in: 0.1...0.5, step: 0.05)
                        Text("빠르게")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .padding(.vertical, 8)

            // 테마 선택 그리드
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("아이콘 테마")
                        .font(.headline)

                    Spacer()

                    // 선택된 테마 미리보기
                    if let frame = previewFrames[safe: previewFrame] {
                        Image(nsImage: frame)
                            .frame(width: 24, height: 24)
                    }

                    if let theme = AnimationFrameProvider.allThemes.first(where: { $0.id == settings.selectedAnimationTheme }) {
                        Text(theme.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                        ForEach(AnimationFrameProvider.allThemes) { theme in
                            ThemeCell(
                                theme: theme,
                                isSelected: settings.selectedAnimationTheme == theme.id
                            ) {
                                settings.selectedAnimationTheme = theme.id
                                startPreview()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .onAppear { startPreview() }
        .onDisappear { previewTimer?.invalidate() }
    }

    private func startPreview() {
        previewTimer?.invalidate()
        previewFrames = AnimationFrameProvider.runningFrames(
            theme: settings.selectedAnimationTheme,
            size: NSSize(width: 24, height: 24)
        )
        previewFrame = 0
        previewTimer = Timer.scheduledTimer(withTimeInterval: settings.animationSpeed, repeats: true) { _ in
            previewFrame = (previewFrame + 1) % max(previewFrames.count, 1)
        }
    }
}

private struct ThemeCell: View {
    let theme: AnimationTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: theme.icon)
                    .font(.system(size: 20))
                    .frame(width: 36, height: 36)

                Text(theme.name)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.04),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
