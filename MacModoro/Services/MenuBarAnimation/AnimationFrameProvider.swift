import AppKit

struct AnimationTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let runningIcons: [String] // 애니메이션 프레임용 SF Symbol 이름들
    let idleIcon: String       // 정적 아이콘
}

enum AnimationFrameProvider {
    static let allThemes: [AnimationTheme] = [
        AnimationTheme(id: "cat", name: "고양이", icon: "cat.fill",
                       runningIcons: ["cat.fill", "cat", "cat.fill", "cat", "cat.fill"],
                       idleIcon: "cat.fill"),
        AnimationTheme(id: "dog", name: "강아지", icon: "dog.fill",
                       runningIcons: ["dog.fill", "dog", "dog.fill", "dog", "dog.fill"],
                       idleIcon: "dog.fill"),
        AnimationTheme(id: "bird", name: "새", icon: "bird.fill",
                       runningIcons: ["bird", "bird.fill", "bird", "bird.fill", "bird"],
                       idleIcon: "bird.fill"),
        AnimationTheme(id: "hare", name: "토끼", icon: "hare.fill",
                       runningIcons: ["hare", "hare.fill", "hare", "hare.fill", "hare"],
                       idleIcon: "hare.fill"),
        AnimationTheme(id: "fish", name: "물고기", icon: "fish.fill",
                       runningIcons: ["fish", "fish.fill", "fish", "fish.fill", "fish"],
                       idleIcon: "fish.fill"),
        AnimationTheme(id: "heart", name: "하트", icon: "heart.fill",
                       runningIcons: ["heart", "heart.fill", "heart", "heart.fill", "heart"],
                       idleIcon: "heart.fill"),
        AnimationTheme(id: "star", name: "별", icon: "star.fill",
                       runningIcons: ["star", "star.fill", "star.leadinghalf.filled", "star.fill", "star"],
                       idleIcon: "star.fill"),
        AnimationTheme(id: "flame", name: "불꽃", icon: "flame.fill",
                       runningIcons: ["flame", "flame.fill", "flame", "flame.fill", "flame"],
                       idleIcon: "flame.fill"),
        AnimationTheme(id: "bolt", name: "번개", icon: "bolt.fill",
                       runningIcons: ["bolt", "bolt.fill", "bolt.circle", "bolt.fill", "bolt"],
                       idleIcon: "bolt.fill"),
        AnimationTheme(id: "moon", name: "달", icon: "moon.fill",
                       runningIcons: ["moon.stars", "moon.fill", "moon.stars.fill", "moon.fill", "moon.stars"],
                       idleIcon: "moon.fill"),
        AnimationTheme(id: "sun", name: "해", icon: "sun.max.fill",
                       runningIcons: ["sun.min", "sun.max", "sun.max.fill", "sun.max", "sun.min"],
                       idleIcon: "sun.max.fill"),
        AnimationTheme(id: "cloud", name: "구름", icon: "cloud.fill",
                       runningIcons: ["cloud", "cloud.fill", "cloud.rain", "cloud.fill", "cloud"],
                       idleIcon: "cloud.fill"),
        AnimationTheme(id: "drop", name: "물방울", icon: "drop.fill",
                       runningIcons: ["drop", "drop.fill", "drop", "drop.fill", "drop"],
                       idleIcon: "drop.fill"),
        AnimationTheme(id: "leaf", name: "나뭇잎", icon: "leaf.fill",
                       runningIcons: ["leaf", "leaf.fill", "leaf.arrow.circlepath", "leaf.fill", "leaf"],
                       idleIcon: "leaf.fill"),
        AnimationTheme(id: "pencil", name: "연필", icon: "pencil",
                       runningIcons: ["pencil", "pencil.line", "pencil", "pencil.circle.fill", "pencil"],
                       idleIcon: "pencil"),
        AnimationTheme(id: "gear", name: "톱니바퀴", icon: "gearshape.fill",
                       runningIcons: ["gearshape", "gearshape.fill", "gearshape.2", "gearshape.fill", "gearshape"],
                       idleIcon: "gearshape.fill"),
        AnimationTheme(id: "hourglass", name: "모래시계", icon: "hourglass",
                       runningIcons: ["hourglass.tophalf.filled", "hourglass", "hourglass.bottomhalf.filled", "hourglass", "hourglass.tophalf.filled"],
                       idleIcon: "hourglass"),
        AnimationTheme(id: "music", name: "음표", icon: "music.note",
                       runningIcons: ["music.note", "music.note.list", "music.note", "music.quarternote.3", "music.note"],
                       idleIcon: "music.note"),
        AnimationTheme(id: "rocket", name: "로켓", icon: "paperplane.fill",
                       runningIcons: ["paperplane", "paperplane.fill", "paperplane.circle", "paperplane.fill", "paperplane"],
                       idleIcon: "paperplane.fill"),
        AnimationTheme(id: "coffee", name: "커피", icon: "cup.and.saucer.fill",
                       runningIcons: ["cup.and.saucer", "cup.and.saucer.fill", "cup.and.saucer", "cup.and.saucer.fill", "cup.and.saucer"],
                       idleIcon: "cup.and.saucer.fill"),
    ]

    // MARK: - Public API

    static func idleFrame(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> NSImage {
        let themeData = allThemes.first { $0.id == theme } ?? allThemes[0]
        return renderSFSymbol(name: themeData.idleIcon, size: size)
    }

    static func runningFrames(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> [NSImage] {
        let themeData = allThemes.first { $0.id == theme } ?? allThemes[0]
        return themeData.runningIcons.map { renderSFSymbol(name: $0, size: size) }
    }

    // MARK: - SF Symbol Rendering

    private static func renderSFSymbol(name: String, size: NSSize) -> NSImage {
        let config = NSImage.SymbolConfiguration(pointSize: size.height * 0.75, weight: .regular)
        if let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
            let configured = symbol.withSymbolConfiguration(config) ?? symbol
            configured.isTemplate = true
            // 크기 정규화
            let result = NSImage(size: size)
            result.lockFocus()
            let symbolSize = configured.size
            let x = (size.width - symbolSize.width) / 2
            let y = (size.height - symbolSize.height) / 2
            configured.draw(in: NSRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))
            result.unlockFocus()
            result.isTemplate = true
            return result
        }
        // fallback
        let fallback = NSImage(size: size)
        fallback.isTemplate = true
        return fallback
    }
}
