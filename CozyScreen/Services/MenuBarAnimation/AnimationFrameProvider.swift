import AppKit

enum AnimationFrameProvider {
    static func idleFrames(size: NSSize = NSSize(width: 18, height: 18)) -> [NSImage] {
        // 고양이 앉아있는 정적 프레임
        return [drawCatFrame(pose: .sitting, size: size)]
    }

    static func runningFrames(size: NSSize = NSSize(width: 18, height: 18)) -> [NSImage] {
        // 고양이 달리는 5프레임 애니메이션
        return CatPose.runningSequence.map { drawCatFrame(pose: $0, size: size) }
    }

    private enum CatPose {
        case sitting
        case run1
        case run2
        case run3
        case run4
        case run5

        static let runningSequence: [CatPose] = [.run1, .run2, .run3, .run4, .run5]
    }

    private static func drawCatFrame(pose: CatPose, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let ctx = NSGraphicsContext.current!.cgContext
        let s = size.width / 18.0 // 스케일

        // 색상
        let bodyColor = NSColor.labelColor.cgColor

        ctx.setFillColor(bodyColor)

        switch pose {
        case .sitting:
            // 몸통
            ctx.fillEllipse(in: CGRect(x: 5*s, y: 3*s, width: 8*s, height: 7*s))
            // 머리
            ctx.fillEllipse(in: CGRect(x: 6*s, y: 9*s, width: 6*s, height: 6*s))
            // 왼쪽 귀
            ctx.fill(CGRect(x: 6*s, y: 14*s, width: 2*s, height: 3*s))
            // 오른쪽 귀
            ctx.fill(CGRect(x: 10*s, y: 14*s, width: 2*s, height: 3*s))
            // 꼬리
            ctx.setStrokeColor(bodyColor)
            ctx.setLineWidth(1.5 * s)
            ctx.move(to: CGPoint(x: 13*s, y: 5*s))
            ctx.addQuadCurve(to: CGPoint(x: 16*s, y: 10*s), control: CGPoint(x: 16*s, y: 5*s))
            ctx.strokePath()

        case .run1:
            drawRunningCat(ctx: ctx, s: s, legPhase: 0)
        case .run2:
            drawRunningCat(ctx: ctx, s: s, legPhase: 1)
        case .run3:
            drawRunningCat(ctx: ctx, s: s, legPhase: 2)
        case .run4:
            drawRunningCat(ctx: ctx, s: s, legPhase: 3)
        case .run5:
            drawRunningCat(ctx: ctx, s: s, legPhase: 4)
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func drawRunningCat(ctx: CGContext, s: CGFloat, legPhase: Int) {
        let bodyColor = NSColor.labelColor.cgColor
        ctx.setFillColor(bodyColor)

        // 몸통 (수평, 약간의 상하 bounce)
        let bounceY: CGFloat = [0, 1, 2, 1, 0][legPhase]
        let bodyY = (4 + bounceY) * s

        // 몸통 타원
        ctx.fillEllipse(in: CGRect(x: 3*s, y: bodyY, width: 10*s, height: 5*s))

        // 머리
        ctx.fillEllipse(in: CGRect(x: 11*s, y: bodyY + 2*s, width: 5*s, height: 5*s))

        // 귀
        ctx.fill(CGRect(x: 13*s, y: bodyY + 6*s, width: 1.5*s, height: 2.5*s))
        ctx.fill(CGRect(x: 15*s, y: bodyY + 6*s, width: 1.5*s, height: 2.5*s))

        // 다리 (phase에 따라 위치 변경)
        ctx.setStrokeColor(bodyColor)
        ctx.setLineWidth(1.5 * s)
        ctx.setLineCap(.round)

        let legAngles: [(front1: CGFloat, front2: CGFloat, back1: CGFloat, back2: CGFloat)] = [
            (front1: -0.3, front2: 0.3, back1: 0.3, back2: -0.3),
            (front1: -0.5, front2: 0.5, back1: 0.5, back2: -0.5),
            (front1: -0.2, front2: 0.2, back1: 0.2, back2: -0.2),
            (front1: 0.5, front2: -0.5, back1: -0.5, back2: 0.5),
            (front1: 0.3, front2: -0.3, back1: -0.3, back2: 0.3),
        ]

        let angles = legAngles[legPhase]
        let legLen = 4.0 * s

        // 앞다리 2개
        drawLeg(ctx: ctx, x: 10*s, y: bodyY, angle: angles.front1, length: legLen)
        drawLeg(ctx: ctx, x: 11*s, y: bodyY, angle: angles.front2, length: legLen)

        // 뒷다리 2개
        drawLeg(ctx: ctx, x: 5*s, y: bodyY, angle: angles.back1, length: legLen)
        drawLeg(ctx: ctx, x: 6*s, y: bodyY, angle: angles.back2, length: legLen)

        // 꼬리
        let tailWave = sin(Double(legPhase) * .pi / 2.5) * 2.0
        ctx.setLineWidth(1.5 * s)
        ctx.move(to: CGPoint(x: 3*s, y: bodyY + 3*s))
        ctx.addQuadCurve(
            to: CGPoint(x: 0*s, y: bodyY + 6*s + tailWave * s),
            control: CGPoint(x: 1*s, y: bodyY + 2*s)
        )
        ctx.strokePath()
    }

    private static func drawLeg(ctx: CGContext, x: CGFloat, y: CGFloat, angle: CGFloat, length: CGFloat) {
        let endX = x + sin(angle) * length
        let endY = y - cos(angle) * length
        ctx.move(to: CGPoint(x: x, y: y))
        ctx.addLine(to: CGPoint(x: endX, y: endY))
        ctx.strokePath()
    }
}
