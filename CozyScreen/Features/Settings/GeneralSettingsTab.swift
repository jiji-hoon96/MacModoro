import SwiftUI
import Carbon.HIToolbox

struct GeneralSettingsTab: View {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var permissions = PermissionManager.shared
    @State private var isRecordingShortcut = false

    var body: some View {
        Form {
            Section("권한") {
                HStack {
                    Image(systemName: permissions.isAccessibilityGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(permissions.isAccessibilityGranted ? .green : .red)
                    Text("접근성 권한")
                    Spacer()
                    if !permissions.isAccessibilityGranted {
                        Button("권한 요청") {
                            permissions.requestAccessibility()
                        }
                    } else {
                        Text("허용됨")
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("단축키") {
                HStack {
                    Text("활성화 단축키")
                    Spacer()
                    Button(isRecordingShortcut ? "키 입력 대기 중..." : shortcutDisplayString) {
                        isRecordingShortcut.toggle()
                    }
                    .onKeyPress { press in
                        guard isRecordingShortcut else { return .ignored }
                        // SwiftUI onKeyPress is limited; full implementation requires NSEvent
                        isRecordingShortcut = false
                        return .handled
                    }
                }
            }

            Section("종료 방식") {
                Toggle("ESC 키로 종료", isOn: .constant(true))
                    .disabled(true)
                Toggle("마우스 이동 시 종료", isOn: $settings.exitOnMouseMove)
                Toggle("아무 키 입력 시 종료", isOn: $settings.exitOnKeyPress)
            }

            Section("배경") {
                HStack {
                    Text("사진 전환 간격")
                    Spacer()
                    Picker("", selection: $settings.photoTransitionInterval) {
                        Text("5초").tag(TimeInterval(5))
                        Text("10초").tag(TimeInterval(10))
                        Text("30초").tag(TimeInterval(30))
                        Text("1분").tag(TimeInterval(60))
                    }
                    .frame(width: 100)
                }
            }

            Section("오버레이") {
                Toggle("메모 오버레이 표시", isOn: $settings.showMemoOverlay)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var shortcutDisplayString: String {
        var parts: [String] = []
        let mods = settings.shortcutModifiers
        if mods & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if mods & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if mods & UInt32(optionKey) != 0 { parts.append("⌥") }
        if mods & UInt32(controlKey) != 0 { parts.append("⌃") }

        let keyName = keyCodeToString(settings.shortcutKeyCode)
        parts.append(keyName)
        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        let mapping: [UInt32: String] = [
            UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_D): "D",
            UInt32(kVK_ANSI_F): "F", UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H",
            UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
            UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_E): "E",
            UInt32(kVK_ANSI_R): "R", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_Y): "Y",
            UInt32(kVK_ANSI_U): "U", UInt32(kVK_ANSI_I): "I", UInt32(kVK_ANSI_O): "O",
            UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Z): "Z", UInt32(kVK_ANSI_X): "X",
            UInt32(kVK_ANSI_C): "C", UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_B): "B",
            UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_M): "M",
        ]
        return mapping[keyCode] ?? "?"
    }
}
