import SwiftUI
import Carbon.HIToolbox

struct ShortcutRecorderView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("집중 깨짐 단축키")
                .font(.headline)

            HStack {
                Text(shortcutDisplayString)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isRecording ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isRecording ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                    )

                Button(isRecording ? "취소" : "변경") {
                    isRecording.toggle()
                }
                .buttonStyle(.bordered)
            }

            if isRecording {
                Text("새로운 단축키를 누르세요...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("뽀모도로 진행 중 이 단축키를 누르면 집중 깨짐이 기록됩니다.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .background(
            isRecording ? ShortcutKeyListener(
                onKeyDown: { keyCode, modifiers in
                    settings.focusBreakKeyCode = keyCode
                    settings.focusBreakModifiers = modifiers
                    isRecording = false
                    GlobalShortcutService.shared.register()
                }
            ) : nil
        )
    }

    private var shortcutDisplayString: String {
        var parts: [String] = []
        let mods = settings.focusBreakModifiers

        if mods & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if mods & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if mods & UInt32(optionKey) != 0 { parts.append("⌥") }
        if mods & UInt32(controlKey) != 0 { parts.append("⌃") }

        parts.append(keyCodeToString(settings.focusBreakKeyCode))
        return parts.joined(separator: "")
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        let mapping: [UInt32: String] = [
            UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
            UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
            UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
            UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
            UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
            UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
            UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
            UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
            UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
            UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
            UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
            UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
            UInt32(kVK_ANSI_9): "9",
            UInt32(kVK_Space): "Space", UInt32(kVK_Return): "↩",
            UInt32(kVK_Tab): "⇥", UInt32(kVK_Escape): "⎋",
        ]
        return mapping[keyCode] ?? "Key\(keyCode)"
    }
}

private struct ShortcutKeyListener: NSViewRepresentable {
    let onKeyDown: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> KeyListenerView {
        let view = KeyListenerView()
        view.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyListenerView, context: Context) {}
}

final class KeyListenerView: NSView {
    var onKeyDown: ((UInt32, UInt32) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        var carbonMods: UInt32 = 0
        if event.modifierFlags.contains(.command) { carbonMods |= UInt32(cmdKey) }
        if event.modifierFlags.contains(.shift) { carbonMods |= UInt32(shiftKey) }
        if event.modifierFlags.contains(.option) { carbonMods |= UInt32(optionKey) }
        if event.modifierFlags.contains(.control) { carbonMods |= UInt32(controlKey) }

        guard carbonMods != 0 else { return }

        onKeyDown?(UInt32(event.keyCode), carbonMods)
    }
}
