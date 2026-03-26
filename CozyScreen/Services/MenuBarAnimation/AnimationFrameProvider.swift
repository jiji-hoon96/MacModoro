import AppKit

struct AnimationTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
}

enum AnimationFrameProvider {
    // MARK: - 20개 테마 목록

    static let allThemes: [AnimationTheme] = [
        AnimationTheme(id: "cat", name: "고양이", icon: "cat.fill"),
        AnimationTheme(id: "dog", name: "강아지", icon: "dog.fill"),
        AnimationTheme(id: "bird", name: "새", icon: "bird.fill"),
        AnimationTheme(id: "fish", name: "물고기", icon: "fish.fill"),
        AnimationTheme(id: "heart", name: "하트", icon: "heart.fill"),
        AnimationTheme(id: "star", name: "별", icon: "star.fill"),
        AnimationTheme(id: "flame", name: "불꽃", icon: "flame.fill"),
        AnimationTheme(id: "bolt", name: "번개", icon: "bolt.fill"),
        AnimationTheme(id: "moon", name: "달", icon: "moon.fill"),
        AnimationTheme(id: "sun", name: "해", icon: "sun.max.fill"),
        AnimationTheme(id: "cloud", name: "구름", icon: "cloud.fill"),
        AnimationTheme(id: "drop", name: "물방울", icon: "drop.fill"),
        AnimationTheme(id: "leaf", name: "나뭇잎", icon: "leaf.fill"),
        AnimationTheme(id: "pencil", name: "연필", icon: "pencil"),
        AnimationTheme(id: "gear", name: "톱니바퀴", icon: "gearshape.fill"),
        AnimationTheme(id: "hourglass", name: "모래시계", icon: "hourglass"),
        AnimationTheme(id: "music", name: "음표", icon: "music.note"),
        AnimationTheme(id: "rocket", name: "로켓", icon: "paperplane.fill"),
        AnimationTheme(id: "coffee", name: "커피", icon: "cup.and.saucer.fill"),
        AnimationTheme(id: "book", name: "책", icon: "book.fill"),
    ]

    // MARK: - Public API

    static func idleFrame(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> NSImage {
        return drawFrame(theme: theme, phase: -1, size: size)
    }

    static func runningFrames(theme: String, size: NSSize = NSSize(width: 18, height: 18)) -> [NSImage] {
        return (0..<5).map { drawFrame(theme: theme, phase: $0, size: size) }
    }

    // MARK: - Frame Drawing

    /// phase == -1: idle, 0~4: running animation
    private static func drawFrame(theme: String, phase: Int, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        let ctx = NSGraphicsContext.current!.cgContext
        let s = size.width / 18.0
        let color = NSColor.labelColor.cgColor

        ctx.setFillColor(color)
        ctx.setStrokeColor(color)
        ctx.setLineCap(.round)

        switch theme {
        case "cat": drawCat(ctx: ctx, s: s, phase: phase)
        case "dog": drawDog(ctx: ctx, s: s, phase: phase)
        case "bird": drawBird(ctx: ctx, s: s, phase: phase)
        case "fish": drawFish(ctx: ctx, s: s, phase: phase)
        case "heart": drawHeart(ctx: ctx, s: s, phase: phase)
        case "star": drawStar(ctx: ctx, s: s, phase: phase)
        case "flame": drawFlame(ctx: ctx, s: s, phase: phase)
        case "bolt": drawBolt(ctx: ctx, s: s, phase: phase)
        case "moon": drawMoon(ctx: ctx, s: s, phase: phase)
        case "sun": drawSun(ctx: ctx, s: s, phase: phase)
        case "cloud": drawCloud(ctx: ctx, s: s, phase: phase)
        case "drop": drawDrop(ctx: ctx, s: s, phase: phase)
        case "leaf": drawLeaf(ctx: ctx, s: s, phase: phase)
        case "pencil": drawPencil(ctx: ctx, s: s, phase: phase)
        case "gear": drawGear(ctx: ctx, s: s, phase: phase)
        case "hourglass": drawHourglass(ctx: ctx, s: s, phase: phase)
        case "music": drawMusic(ctx: ctx, s: s, phase: phase)
        case "rocket": drawRocket(ctx: ctx, s: s, phase: phase)
        case "coffee": drawCoffee(ctx: ctx, s: s, phase: phase)
        case "book": drawBook(ctx: ctx, s: s, phase: phase)
        default: drawCat(ctx: ctx, s: s, phase: phase)
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    // MARK: - 1. Cat

    private static func drawCat(ctx: CGContext, s: CGFloat, phase: Int) {
        if phase < 0 {
            // idle: sitting
            ctx.fillEllipse(in: CGRect(x: 5*s, y: 3*s, width: 8*s, height: 7*s))
            ctx.fillEllipse(in: CGRect(x: 6*s, y: 9*s, width: 6*s, height: 6*s))
            ctx.fill(CGRect(x: 6*s, y: 14*s, width: 2*s, height: 3*s))
            ctx.fill(CGRect(x: 10*s, y: 14*s, width: 2*s, height: 3*s))
            ctx.setLineWidth(1.5 * s)
            ctx.move(to: CGPoint(x: 13*s, y: 5*s))
            ctx.addQuadCurve(to: CGPoint(x: 16*s, y: 10*s), control: CGPoint(x: 16*s, y: 5*s))
            ctx.strokePath()
        } else {
            let bounce: CGFloat = [0, 1, 2, 1, 0][phase]
            let y = (4 + bounce) * s
            ctx.fillEllipse(in: CGRect(x: 3*s, y: y, width: 10*s, height: 5*s))
            ctx.fillEllipse(in: CGRect(x: 11*s, y: y+2*s, width: 5*s, height: 5*s))
            ctx.fill(CGRect(x: 13*s, y: y+6*s, width: 1.5*s, height: 2.5*s))
            ctx.fill(CGRect(x: 15*s, y: y+6*s, width: 1.5*s, height: 2.5*s))
            ctx.setLineWidth(1.5 * s)
            let angles: [(CGFloat,CGFloat,CGFloat,CGFloat)] = [
                (-0.3,0.3,0.3,-0.3),(-0.5,0.5,0.5,-0.5),(-0.2,0.2,0.2,-0.2),(0.5,-0.5,-0.5,0.5),(0.3,-0.3,-0.3,0.3)
            ]
            let a = angles[phase]; let l = 4.0*s
            drawLeg(ctx: ctx, x: 10*s, y: y, angle: a.0, length: l)
            drawLeg(ctx: ctx, x: 11*s, y: y, angle: a.1, length: l)
            drawLeg(ctx: ctx, x: 5*s, y: y, angle: a.2, length: l)
            drawLeg(ctx: ctx, x: 6*s, y: y, angle: a.3, length: l)
            let tw = sin(Double(phase) * .pi / 2.5) * 2.0
            ctx.move(to: CGPoint(x: 3*s, y: y+3*s))
            ctx.addQuadCurve(to: CGPoint(x: 0, y: y+6*s+tw*s), control: CGPoint(x: 1*s, y: y+2*s))
            ctx.strokePath()
        }
    }

    // MARK: - 2. Dog

    private static func drawDog(ctx: CGContext, s: CGFloat, phase: Int) {
        let bounce: CGFloat = phase < 0 ? 0 : [0, 1, 1.5, 1, 0][phase]
        let y = (4 + bounce) * s

        // body
        ctx.fillEllipse(in: CGRect(x: 3*s, y: y, width: 10*s, height: 5*s))
        // head (bigger, rounder than cat)
        ctx.fillEllipse(in: CGRect(x: 11*s, y: y+1*s, width: 6*s, height: 6*s))
        // ears (floppy)
        ctx.setLineWidth(2 * s)
        ctx.move(to: CGPoint(x: 13*s, y: y+6*s))
        ctx.addLine(to: CGPoint(x: 12*s, y: y+4*s))
        ctx.move(to: CGPoint(x: 16*s, y: y+6*s))
        ctx.addLine(to: CGPoint(x: 17*s, y: y+4*s))
        ctx.strokePath()
        // snout
        ctx.fillEllipse(in: CGRect(x: 15*s, y: y+2*s, width: 3*s, height: 3*s))

        if phase >= 0 {
            ctx.setLineWidth(1.5 * s)
            let a: [(CGFloat,CGFloat)] = [(-0.4,0.4),(-0.6,0.2),(0.0,0.0),(0.6,-0.2),(0.4,-0.4)]
            let ang = a[phase]; let l = 4*s
            drawLeg(ctx: ctx, x: 10*s, y: y, angle: ang.0, length: l)
            drawLeg(ctx: ctx, x: 11*s, y: y, angle: ang.1, length: l)
            drawLeg(ctx: ctx, x: 5*s, y: y, angle: -ang.0, length: l)
            drawLeg(ctx: ctx, x: 6*s, y: y, angle: -ang.1, length: l)
        }
        // tail (wagging)
        ctx.setLineWidth(1.5 * s)
        let wag = phase < 0 ? 0.0 : sin(Double(phase) * .pi / 2) * 3.0
        ctx.move(to: CGPoint(x: 3*s, y: y+4*s))
        ctx.addQuadCurve(to: CGPoint(x: 0, y: y+8*s+wag*s), control: CGPoint(x: 1*s, y: y+5*s))
        ctx.strokePath()
    }

    // MARK: - 3. Bird

    private static func drawBird(ctx: CGContext, s: CGFloat, phase: Int) {
        let bounce: CGFloat = phase < 0 ? 0 : [0, 2, 3, 2, 0][phase]
        let y = (6 + bounce) * s
        // body
        ctx.fillEllipse(in: CGRect(x: 5*s, y: y, width: 8*s, height: 5*s))
        // head
        ctx.fillEllipse(in: CGRect(x: 11*s, y: y+3*s, width: 5*s, height: 4*s))
        // beak
        ctx.move(to: CGPoint(x: 16*s, y: y+5*s))
        ctx.addLine(to: CGPoint(x: 18*s, y: y+4.5*s))
        ctx.addLine(to: CGPoint(x: 16*s, y: y+4*s))
        ctx.fillPath()
        // wings
        ctx.setLineWidth(1.5 * s)
        let wingAngle: CGFloat = phase < 0 ? 0 : [-0.3, 0.5, 0.8, 0.5, -0.3][phase]
        ctx.move(to: CGPoint(x: 9*s, y: y+4*s))
        ctx.addLine(to: CGPoint(x: 6*s, y: y+7*s + wingAngle*3*s))
        ctx.strokePath()
        // tail
        ctx.move(to: CGPoint(x: 5*s, y: y+2*s))
        ctx.addLine(to: CGPoint(x: 2*s, y: y+4*s))
        ctx.addLine(to: CGPoint(x: 3*s, y: y+1*s))
        ctx.fillPath()
    }

    // MARK: - 4. Fish

    private static func drawFish(ctx: CGContext, s: CGFloat, phase: Int) {
        let wave: CGFloat = phase < 0 ? 0 : sin(Double(phase) * .pi / 2.0) * 1.5
        let cx: CGFloat = 9*s + wave*s
        let cy: CGFloat = 9*s
        // body
        ctx.fillEllipse(in: CGRect(x: cx-5*s, y: cy-3*s, width: 10*s, height: 6*s))
        // tail
        ctx.move(to: CGPoint(x: cx-5*s, y: cy))
        ctx.addLine(to: CGPoint(x: cx-9*s, y: cy+3*s))
        ctx.addLine(to: CGPoint(x: cx-9*s, y: cy-3*s))
        ctx.fillPath()
        // eye
        ctx.setFillColor(NSColor.windowBackgroundColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx+2*s, y: cy+0.5*s, width: 2*s, height: 2*s))
        ctx.setFillColor(NSColor.labelColor.cgColor)
        // bubbles
        if phase >= 0 {
            let bx = cx + 6*s
            let offsets: [CGFloat] = [0, 1, 2, 1, 0]
            ctx.fillEllipse(in: CGRect(x: bx, y: cy+2*s+offsets[phase]*s, width: 1.5*s, height: 1.5*s))
        }
    }

    // MARK: - 5. Heart (beating)

    private static func drawHeart(ctx: CGContext, s: CGFloat, phase: Int) {
        let scale: CGFloat = phase < 0 ? 1.0 : [1.0, 1.1, 1.2, 1.1, 1.0][phase]
        let cx = 9*s, cy = 8*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: -cx, y: -cy)
        // heart shape
        ctx.move(to: CGPoint(x: cx, y: cy - 2*s))
        ctx.addCurve(to: CGPoint(x: cx, y: cy + 5*s),
                     control1: CGPoint(x: cx - 6*s, y: cy - 6*s),
                     control2: CGPoint(x: cx - 6*s, y: cy + 2*s))
        ctx.move(to: CGPoint(x: cx, y: cy - 2*s))
        ctx.addCurve(to: CGPoint(x: cx, y: cy + 5*s),
                     control1: CGPoint(x: cx + 6*s, y: cy - 6*s),
                     control2: CGPoint(x: cx + 6*s, y: cy + 2*s))
        ctx.fillPath()
        ctx.restoreGState()
    }

    // MARK: - 6. Star (spinning)

    private static func drawStar(ctx: CGContext, s: CGFloat, phase: Int) {
        let rot: CGFloat = phase < 0 ? 0 : CGFloat(phase) * .pi / 5
        let cx = 9*s, cy = 9*s, r = 6*s, ri = 3*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: rot)
        let path = CGMutablePath()
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5 - .pi / 2
            let radius = i % 2 == 0 ? r : ri
            let p = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
        ctx.restoreGState()
    }

    // MARK: - 7. Flame (flickering)

    private static func drawFlame(ctx: CGContext, s: CGFloat, phase: Int) {
        let flicker: CGFloat = phase < 0 ? 0 : [0, 0.5, 1, 0.5, 0][phase]
        let cx = 9*s, base = 3*s
        ctx.move(to: CGPoint(x: cx, y: base))
        ctx.addCurve(to: CGPoint(x: cx, y: 16*s + flicker*s),
                     control1: CGPoint(x: cx - 5*s, y: base + 4*s),
                     control2: CGPoint(x: cx - 3*s - flicker*s, y: 14*s))
        ctx.addCurve(to: CGPoint(x: cx, y: base),
                     control1: CGPoint(x: cx + 3*s + flicker*s, y: 14*s),
                     control2: CGPoint(x: cx + 5*s, y: base + 4*s))
        ctx.fillPath()
    }

    // MARK: - 8. Bolt (flashing)

    private static func drawBolt(ctx: CGContext, s: CGFloat, phase: Int) {
        let offsetY: CGFloat = phase < 0 ? 0 : [0, -0.5, -1, -0.5, 0][phase]
        let y = offsetY * s
        ctx.move(to: CGPoint(x: 10*s, y: 2*s+y))
        ctx.addLine(to: CGPoint(x: 6*s, y: 9*s+y))
        ctx.addLine(to: CGPoint(x: 10*s, y: 8*s+y))
        ctx.addLine(to: CGPoint(x: 7*s, y: 16*s+y))
        ctx.addLine(to: CGPoint(x: 13*s, y: 8*s+y))
        ctx.addLine(to: CGPoint(x: 9*s, y: 9*s+y))
        ctx.closePath()
        ctx.fillPath()
    }

    // MARK: - 9. Moon (rocking)

    private static func drawMoon(ctx: CGContext, s: CGFloat, phase: Int) {
        let rot: CGFloat = phase < 0 ? 0 : sin(Double(phase) * .pi / 2) * 0.15
        let cx = 9*s, cy = 9*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: rot)
        ctx.translateBy(x: -cx, y: -cy)
        ctx.fillEllipse(in: CGRect(x: 4*s, y: 4*s, width: 10*s, height: 10*s))
        ctx.setFillColor(NSColor.windowBackgroundColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: 7*s, y: 6*s, width: 8*s, height: 8*s))
        ctx.restoreGState()
    }

    // MARK: - 10. Sun (pulsing rays)

    private static func drawSun(ctx: CGContext, s: CGFloat, phase: Int) {
        let cx = 9*s, cy = 9*s
        ctx.fillEllipse(in: CGRect(x: cx-3.5*s, y: cy-3.5*s, width: 7*s, height: 7*s))
        let rayLen: CGFloat = phase < 0 ? 3*s : [3, 3.5, 4, 3.5, 3][phase] * s
        ctx.setLineWidth(1.2 * s)
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let inner = 4.5 * s
            ctx.move(to: CGPoint(x: cx + cos(angle)*inner, y: cy + sin(angle)*inner))
            ctx.addLine(to: CGPoint(x: cx + cos(angle)*(inner+rayLen), y: cy + sin(angle)*(inner+rayLen)))
        }
        ctx.strokePath()
    }

    // MARK: - 11. Cloud (drifting)

    private static func drawCloud(ctx: CGContext, s: CGFloat, phase: Int) {
        let dx: CGFloat = phase < 0 ? 0 : [-1, -0.5, 0, 0.5, 1][phase] * s
        ctx.fillEllipse(in: CGRect(x: 3*s+dx, y: 6*s, width: 6*s, height: 5*s))
        ctx.fillEllipse(in: CGRect(x: 6*s+dx, y: 8*s, width: 7*s, height: 5*s))
        ctx.fillEllipse(in: CGRect(x: 9*s+dx, y: 6*s, width: 5*s, height: 5*s))
        ctx.fill(CGRect(x: 3*s+dx, y: 6*s, width: 11*s, height: 3*s))
    }

    // MARK: - 12. Drop (dripping)

    private static func drawDrop(ctx: CGContext, s: CGFloat, phase: Int) {
        let offsetY: CGFloat = phase < 0 ? 0 : [0, 1, 2, 1, 0][phase]
        let y = offsetY * s
        let cx = 9*s
        ctx.move(to: CGPoint(x: cx, y: 15*s+y))
        ctx.addCurve(to: CGPoint(x: cx, y: 4*s+y),
                     control1: CGPoint(x: cx-5*s, y: 10*s+y),
                     control2: CGPoint(x: cx-5*s, y: 6*s+y))
        ctx.addCurve(to: CGPoint(x: cx, y: 15*s+y),
                     control1: CGPoint(x: cx+5*s, y: 6*s+y),
                     control2: CGPoint(x: cx+5*s, y: 10*s+y))
        ctx.fillPath()
    }

    // MARK: - 13. Leaf (swaying)

    private static func drawLeaf(ctx: CGContext, s: CGFloat, phase: Int) {
        let rot: CGFloat = phase < 0 ? 0 : sin(Double(phase) * .pi / 2) * 0.2
        let cx = 9*s, cy = 9*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: rot)
        ctx.translateBy(x: -cx, y: -cy)
        ctx.move(to: CGPoint(x: cx, y: 3*s))
        ctx.addCurve(to: CGPoint(x: cx, y: 15*s),
                     control1: CGPoint(x: cx-7*s, y: 6*s),
                     control2: CGPoint(x: cx-5*s, y: 13*s))
        ctx.addCurve(to: CGPoint(x: cx, y: 3*s),
                     control1: CGPoint(x: cx+5*s, y: 13*s),
                     control2: CGPoint(x: cx+7*s, y: 6*s))
        ctx.fillPath()
        // stem
        ctx.setLineWidth(1 * s)
        ctx.move(to: CGPoint(x: cx, y: 3*s))
        ctx.addLine(to: CGPoint(x: cx, y: 15*s))
        ctx.setStrokeColor(NSColor.windowBackgroundColor.cgColor)
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: - 14. Pencil (writing)

    private static func drawPencil(ctx: CGContext, s: CGFloat, phase: Int) {
        let tilt: CGFloat = phase < 0 ? 0 : sin(Double(phase) * .pi / 2) * 0.15
        let cx = 9*s, cy = 9*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: tilt)
        ctx.translateBy(x: -cx, y: -cy)
        // body
        ctx.fill(CGRect(x: 7*s, y: 4*s, width: 4*s, height: 10*s))
        // tip
        ctx.move(to: CGPoint(x: 7*s, y: 4*s))
        ctx.addLine(to: CGPoint(x: 9*s, y: 1*s))
        ctx.addLine(to: CGPoint(x: 11*s, y: 4*s))
        ctx.fillPath()
        // eraser
        ctx.fill(CGRect(x: 7*s, y: 14*s, width: 4*s, height: 2*s))
        ctx.restoreGState()
    }

    // MARK: - 15. Gear (spinning)

    private static func drawGear(ctx: CGContext, s: CGFloat, phase: Int) {
        let rot: CGFloat = phase < 0 ? 0 : CGFloat(phase) * .pi / 8
        let cx = 9*s, cy = 9*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: rot)
        // center
        ctx.fillEllipse(in: CGRect(x: -3.5*s, y: -3.5*s, width: 7*s, height: 7*s))
        // teeth
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            ctx.fill(CGRect(x: -1.5*s, y: 4*s, width: 3*s, height: 3*s)
                .applying(CGAffineTransform(rotationAngle: angle)))
        }
        ctx.restoreGState()
        // hole
        ctx.setFillColor(NSColor.windowBackgroundColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx-1.5*s, y: cy-1.5*s, width: 3*s, height: 3*s))
    }

    // MARK: - 16. Hourglass (flipping)

    private static func drawHourglass(ctx: CGContext, s: CGFloat, phase: Int) {
        let rot: CGFloat = phase < 0 ? 0 : [0, 0.1, 0, -0.1, 0][phase]
        let cx = 9*s, cy = 9*s
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: rot)
        ctx.translateBy(x: -cx, y: -cy)
        // top
        ctx.move(to: CGPoint(x: 5*s, y: 15*s))
        ctx.addLine(to: CGPoint(x: 13*s, y: 15*s))
        ctx.addLine(to: CGPoint(x: 9*s, y: 9*s))
        ctx.closePath()
        ctx.fillPath()
        // bottom
        ctx.move(to: CGPoint(x: 5*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 13*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 9*s, y: 9*s))
        ctx.closePath()
        ctx.fillPath()
        // frame
        ctx.setLineWidth(1.5 * s)
        ctx.move(to: CGPoint(x: 4*s, y: 15*s)); ctx.addLine(to: CGPoint(x: 14*s, y: 15*s))
        ctx.move(to: CGPoint(x: 4*s, y: 3*s)); ctx.addLine(to: CGPoint(x: 14*s, y: 3*s))
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: - 17. Music (bouncing notes)

    private static func drawMusic(ctx: CGContext, s: CGFloat, phase: Int) {
        let bounce: CGFloat = phase < 0 ? 0 : [0, 1, 2, 1, 0][phase]
        let y = bounce * s
        // note 1
        ctx.fillEllipse(in: CGRect(x: 4*s, y: 4*s+y, width: 4*s, height: 3*s))
        ctx.setLineWidth(1.5 * s)
        ctx.move(to: CGPoint(x: 8*s, y: 5*s+y))
        ctx.addLine(to: CGPoint(x: 8*s, y: 14*s+y))
        ctx.strokePath()
        // note 2
        ctx.fillEllipse(in: CGRect(x: 10*s, y: 3*s-y*0.5, width: 4*s, height: 3*s))
        ctx.move(to: CGPoint(x: 14*s, y: 4*s-y*0.5))
        ctx.addLine(to: CGPoint(x: 14*s, y: 13*s-y*0.5))
        ctx.strokePath()
        // beam
        ctx.setLineWidth(2 * s)
        ctx.move(to: CGPoint(x: 8*s, y: 14*s+y))
        ctx.addLine(to: CGPoint(x: 14*s, y: 13*s-y*0.5))
        ctx.strokePath()
    }

    // MARK: - 18. Rocket (flying)

    private static func drawRocket(ctx: CGContext, s: CGFloat, phase: Int) {
        let boost: CGFloat = phase < 0 ? 0 : [0, 1, 2, 1, 0][phase]
        let y = boost * s
        // body
        ctx.fillEllipse(in: CGRect(x: 6*s, y: 4*s+y, width: 6*s, height: 10*s))
        // nose
        ctx.move(to: CGPoint(x: 6*s, y: 14*s+y))
        ctx.addLine(to: CGPoint(x: 9*s, y: 17*s+y))
        ctx.addLine(to: CGPoint(x: 12*s, y: 14*s+y))
        ctx.fillPath()
        // fins
        ctx.move(to: CGPoint(x: 6*s, y: 6*s+y))
        ctx.addLine(to: CGPoint(x: 3*s, y: 4*s+y))
        ctx.addLine(to: CGPoint(x: 6*s, y: 8*s+y))
        ctx.fillPath()
        ctx.move(to: CGPoint(x: 12*s, y: 6*s+y))
        ctx.addLine(to: CGPoint(x: 15*s, y: 4*s+y))
        ctx.addLine(to: CGPoint(x: 12*s, y: 8*s+y))
        ctx.fillPath()
        // flame
        if phase >= 0 {
            let fl: CGFloat = [1, 2, 3, 2, 1][phase]
            ctx.fillEllipse(in: CGRect(x: 7.5*s, y: 2*s+y-fl*s, width: 3*s, height: fl*s+1*s))
        }
        // window
        ctx.setFillColor(NSColor.windowBackgroundColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: 7.5*s, y: 10*s+y, width: 3*s, height: 3*s))
    }

    // MARK: - 19. Coffee (steaming)

    private static func drawCoffee(ctx: CGContext, s: CGFloat, phase: Int) {
        // cup body
        ctx.fill(CGRect(x: 4*s, y: 2*s, width: 8*s, height: 8*s))
        // handle
        ctx.setLineWidth(1.5 * s)
        ctx.addArc(center: CGPoint(x: 12*s, y: 6*s), radius: 2.5*s,
                   startAngle: -.pi/2, endAngle: .pi/2, clockwise: false)
        ctx.strokePath()
        // saucer
        ctx.fillEllipse(in: CGRect(x: 2*s, y: 1*s, width: 12*s, height: 2*s))
        // steam
        if phase >= 0 {
            let offsets: [CGFloat] = [0, 0.5, 1, 0.5, 0]
            let off = offsets[phase] * s
            ctx.setLineWidth(1 * s)
            for i in 0..<3 {
                let sx = (6 + CGFloat(i) * 2) * s
                let wave = (i % 2 == 0) ? off : -off
                ctx.move(to: CGPoint(x: sx + wave, y: 10*s))
                ctx.addQuadCurve(to: CGPoint(x: sx - wave, y: 15*s),
                                 control: CGPoint(x: sx + wave + 1.5*s, y: 12.5*s))
                ctx.strokePath()
            }
        }
    }

    // MARK: - 20. Book (page flipping)

    private static func drawBook(ctx: CGContext, s: CGFloat, phase: Int) {
        let pageAngle: CGFloat = phase < 0 ? 0 : [0, 0.15, 0.3, 0.15, 0][phase]
        // spine
        ctx.fill(CGRect(x: 8.5*s, y: 3*s, width: 1*s, height: 12*s))
        // left page
        ctx.setLineWidth(1 * s)
        ctx.move(to: CGPoint(x: 8.5*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 3*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 3*s, y: 15*s))
        ctx.addLine(to: CGPoint(x: 8.5*s, y: 15*s))
        ctx.strokePath()
        // right page
        ctx.saveGState()
        ctx.translateBy(x: 8.5*s, y: 9*s)
        ctx.rotate(by: -pageAngle)
        ctx.translateBy(x: -8.5*s, y: -9*s)
        ctx.move(to: CGPoint(x: 8.5*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 15*s, y: 3*s))
        ctx.addLine(to: CGPoint(x: 15*s, y: 15*s))
        ctx.addLine(to: CGPoint(x: 8.5*s, y: 15*s))
        ctx.strokePath()
        ctx.restoreGState()
        // lines on left
        for i in 0..<3 {
            let ly = (6 + i * 3) * Int(s)
            ctx.move(to: CGPoint(x: 4.5*s, y: CGFloat(ly)))
            ctx.addLine(to: CGPoint(x: 7.5*s, y: CGFloat(ly)))
        }
        ctx.strokePath()
    }

    // MARK: - Utility

    private static func drawLeg(ctx: CGContext, x: CGFloat, y: CGFloat, angle: CGFloat, length: CGFloat) {
        let endX = x + sin(angle) * length
        let endY = y - cos(angle) * length
        ctx.move(to: CGPoint(x: x, y: y))
        ctx.addLine(to: CGPoint(x: endX, y: endY))
        ctx.strokePath()
    }
}
