import AppKit

struct AnimationTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String       // 설정 그리드용 SF Symbol
    let symbolName: String // 실제 메뉴바에 표시할 SF Symbol
}

enum AnimationFrameProvider {
    static let allThemes: [AnimationTheme] = [
        AnimationTheme(id: "cat", name: "고양이", icon: "cat.fill", symbolName: "cat.fill"),
        AnimationTheme(id: "dog", name: "강아지", icon: "dog.fill", symbolName: "dog.fill"),
        AnimationTheme(id: "bird", name: "새", icon: "bird.fill", symbolName: "bird.fill"),
        AnimationTheme(id: "hare", name: "토끼", icon: "hare.fill", symbolName: "hare.fill"),
        AnimationTheme(id: "fish", name: "물고기", icon: "fish.fill", symbolName: "fish.fill"),
        AnimationTheme(id: "heart", name: "하트", icon: "heart.fill", symbolName: "heart.fill"),
        AnimationTheme(id: "star", name: "별", icon: "star.fill", symbolName: "star.fill"),
        AnimationTheme(id: "flame", name: "불꽃", icon: "flame.fill", symbolName: "flame.fill"),
        AnimationTheme(id: "bolt", name: "번개", icon: "bolt.fill", symbolName: "bolt.fill"),
        AnimationTheme(id: "moon", name: "달", icon: "moon.fill", symbolName: "moon.fill"),
        AnimationTheme(id: "sun", name: "해", icon: "sun.max.fill", symbolName: "sun.max.fill"),
        AnimationTheme(id: "cloud", name: "구름", icon: "cloud.fill", symbolName: "cloud.fill"),
        AnimationTheme(id: "drop", name: "물방울", icon: "drop.fill", symbolName: "drop.fill"),
        AnimationTheme(id: "leaf", name: "나뭇잎", icon: "leaf.fill", symbolName: "leaf.fill"),
        AnimationTheme(id: "pencil", name: "연필", icon: "pencil", symbolName: "pencil"),
        AnimationTheme(id: "gear", name: "톱니바퀴", icon: "gearshape.fill", symbolName: "gearshape.fill"),
        AnimationTheme(id: "hourglass", name: "모래시계", icon: "hourglass", symbolName: "hourglass"),
        AnimationTheme(id: "music", name: "음표", icon: "music.note", symbolName: "music.note"),
        AnimationTheme(id: "rocket", name: "로켓", icon: "paperplane.fill", symbolName: "paperplane.fill"),
        AnimationTheme(id: "coffee", name: "커피", icon: "cup.and.saucer.fill", symbolName: "cup.and.saucer.fill"),
    ]

    // MARK: - Public API

    static func idleFrame(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> NSImage {
        let themeData = allThemes.first { $0.id == theme } ?? allThemes[0]
        return renderSFSymbol(name: themeData.symbolName, size: size, offsetY: 0, rotation: 0, scale: 1.0)
    }

    static func runningFrames(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> [NSImage] {
        let themeData = allThemes.first { $0.id == theme } ?? allThemes[0]
        let name = themeData.symbolName

        // 8프레임: 상단바 안에서만 움직이도록 범위 축소
        let offsets: [(y: CGFloat, rot: CGFloat, scale: CGFloat)] = [
            (y: 0,    rot: 0,    scale: 1.0),
            (y: -0.5, rot: -2,   scale: 1.0),
            (y: -1.0, rot: -3,   scale: 1.0),
            (y: -1.2, rot: 0,    scale: 1.0),
            (y: -1.0, rot: 3,    scale: 1.0),
            (y: -0.5, rot: 2,    scale: 1.0),
            (y: 0,    rot: 0,    scale: 1.0),
            (y: 0.3,  rot: 0,    scale: 1.0),
        ]

        return offsets.map { renderSFSymbol(name: name, size: size, offsetY: $0.y, rotation: $0.rot, scale: $0.scale) }
    }

    // MARK: - SF Symbol Rendering (위치/회전/스케일 변환)

    private static func renderSFSymbol(
        name: String,
        size: NSSize,
        offsetY: CGFloat,
        rotation: CGFloat,
        scale: CGFloat
    ) -> NSImage {
        let config = NSImage.SymbolConfiguration(pointSize: size.height * 0.6, weight: .regular)
        guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil) else {
            let fallback = NSImage(size: size)
            fallback.isTemplate = true
            return fallback
        }

        let configured = symbol.withSymbolConfiguration(config) ?? symbol

        let result = NSImage(size: size)
        result.lockFocus()

        let ctx = NSGraphicsContext.current!.cgContext
        let symbolSize = configured.size
        let cx = size.width / 2
        let cy = size.height / 2

        ctx.saveGState()

        // 중심 기준 변환
        ctx.translateBy(x: cx, y: cy + offsetY)
        ctx.rotate(by: rotation * .pi / 180)
        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: -cx, y: -cy)

        let x = (size.width - symbolSize.width) / 2
        let y = (size.height - symbolSize.height) / 2
        configured.draw(in: NSRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))

        ctx.restoreGState()

        result.unlockFocus()
        result.isTemplate = true
        return result
    }
}
