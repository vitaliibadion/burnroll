import SwiftUI

struct AshPaperBurnArtwork: View {
    var isActive = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion || !isActive {
            Canvas { context, size in
                drawArtwork(context: &context, size: size, time: 0.64)
            }
        } else {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                Canvas(rendersAsynchronously: true) { context, size in
                    drawArtwork(
                        context: &context,
                        size: size,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            }
        }
    }

    private func drawArtwork(
        context: inout GraphicsContext,
        size: CGSize,
        time: TimeInterval
    ) {
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20)
        let cornerRadius: CGFloat = 21
        let paperPath = burnedPaperPath(rect: rect, cornerRadius: cornerRadius)

        drawPaper(
            context: &context,
            rect: rect,
            path: paperPath
        )
        drawCharredEdge(
            context: &context,
            rect: rect,
            path: paperPath,
            cornerRadius: cornerRadius
        )
        drawFlames(
            context: &context,
            rect: rect,
            cornerRadius: cornerRadius,
            time: time
        )
        drawFloatingAsh(
            context: &context,
            rect: rect,
            cornerRadius: cornerRadius,
            time: time
        )
    }

    private func drawPaper(
        context: inout GraphicsContext,
        rect: CGRect,
        path: Path
    ) {
        context.drawLayer { paper in
            paper.addFilter(.shadow(color: .black.opacity(0.62), radius: 8, x: 0, y: 5))
            paper.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.98, green: 0.91, blue: 0.79),
                        Color(red: 0.91, green: 0.76, blue: 0.57),
                        Color(red: 0.97, green: 0.87, blue: 0.72)
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            )
        }

        context.drawLayer { texture in
            texture.clip(to: path)

            for index in 0..<42 {
                let xUnit = CGFloat((index * 37 + 11) % 101) / 101
                let yUnit = CGFloat((index * 61 + 17) % 103) / 103
                let length = CGFloat(7 + index % 5 * 4)
                let y = rect.minY + rect.height * yUnit
                var fiber = Path()
                fiber.move(to: CGPoint(x: rect.minX + rect.width * xUnit, y: y))
                fiber.addLine(to: CGPoint(x: rect.minX + rect.width * xUnit + length, y: y + 0.7))
                texture.stroke(
                    fiber,
                    with: .color(Color.brown.opacity(index.isMultiple(of: 3) ? 0.075 : 0.038)),
                    lineWidth: index.isMultiple(of: 4) ? 0.8 : 0.45
                )
            }

            let highlight = Path(
                ellipseIn: CGRect(
                    x: rect.minX + rect.width * 0.12,
                    y: rect.minY + rect.height * 0.08,
                    width: rect.width * 0.72,
                    height: rect.height * 0.64
                )
            )
            texture.fill(highlight, with: .color(.white.opacity(0.075)))
        }
    }

    private func drawCharredEdge(
        context: inout GraphicsContext,
        rect: CGRect,
        path: Path,
        cornerRadius: CGFloat
    ) {
        context.drawLayer { glow in
            glow.addFilter(.blur(radius: 7))
            glow.opacity = 0.78
            glow.stroke(path, with: .color(BurnRollTheme.burn), lineWidth: 10)
        }

        context.stroke(
            path,
            with: .color(Color(red: 0.13, green: 0.055, blue: 0.025)),
            lineWidth: 9
        )
        context.stroke(
            path,
            with: .color(Color(red: 0.39, green: 0.12, blue: 0.025)),
            lineWidth: 5.2
        )
        context.stroke(
            path,
            with: .color(BurnRollTheme.ember.opacity(0.92)),
            lineWidth: 2.2
        )

        for index in 0..<32 {
            let progress = wrappedUnit(
                CGFloat(index) / 32 + CGFloat(index % 4) * 0.005
            )
            let sample = frameSample(
                progress: progress,
                rect: rect,
                cornerRadius: cornerRadius
            )
            let width = CGFloat(5 + index % 4 * 2)
            let height = CGFloat(2 + index % 3)
            let tangent = CGVector(dx: -sample.normal.dy, dy: sample.normal.dx)
            let angle = Angle.radians(atan2(Double(tangent.dy), Double(tangent.dx)))
            let center = CGPoint(
                x: sample.point.x - sample.normal.dx * 3.5,
                y: sample.point.y - sample.normal.dy * 3.5
            )

            context.drawLayer { char in
                char.opacity = 0.28 + Double(index % 3) * 0.08
                char.translateBy(x: center.x, y: center.y)
                char.rotate(by: angle)
                char.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: -width / 2,
                            y: -height / 2,
                            width: width,
                            height: height
                        )
                    ),
                    with: .color(.black)
                )
            }
        }
    }

    private func drawFlames(
        context: inout GraphicsContext,
        rect: CGRect,
        cornerRadius: CGFloat,
        time: TimeInterval
    ) {
        let anchors: [CGFloat] = [0.02, 0.075, 0.14, 0.21, 0.29, 0.37, 0.49, 0.63, 0.78, 0.91]

        for (index, anchor) in anchors.enumerated() {
            let movement = CGFloat(sin(time * 0.72 + Double(index) * 1.7)) * 0.005
            let progress = wrappedUnit(anchor + movement)
            let sample = frameSample(
                progress: progress,
                rect: rect,
                cornerRadius: cornerRadius
            )
            let flicker = CGFloat(0.76 + 0.24 * sin(time * (5.1 + Double(index % 3)) + Double(index)))
            let flameHeight = CGFloat(14 + index % 4 * 4) * flicker
            let flameWidth = max(5.4, flameHeight * 0.62)
            let tangent = CGVector(dx: -sample.normal.dy, dy: sample.normal.dx)
            let sway = CGFloat(sin(time * 3.4 + Double(index) * 0.8)) * 1.8
            let origin = CGPoint(
                x: sample.point.x + sample.normal.dx * 3 + tangent.dx * sway,
                y: sample.point.y + sample.normal.dy * 3 + tangent.dy * sway
            )
            let angle = Angle.radians(
                atan2(Double(sample.normal.dx), Double(-sample.normal.dy))
            )
            let outerFlame = flamePath(width: flameWidth, height: flameHeight)
            let innerFlame = flamePath(width: flameWidth * 0.44, height: flameHeight * 0.60)

            context.drawLayer { glow in
                glow.addFilter(.blur(radius: 4.5))
                glow.opacity = 0.78
                glow.translateBy(x: origin.x, y: origin.y)
                glow.rotate(by: angle)
                glow.fill(outerFlame, with: .color(BurnRollTheme.burn))
            }

            context.drawLayer { flame in
                flame.translateBy(x: origin.x, y: origin.y)
                flame.rotate(by: angle)
                flame.fill(
                    outerFlame,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 1.0, green: 0.30, blue: 0.035),
                            BurnRollTheme.ember,
                            Color(red: 1.0, green: 0.87, blue: 0.28)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: -flameHeight)
                    )
                )
                flame.fill(innerFlame, with: .color(.white.opacity(0.80)))
            }
        }
    }

    private func drawFloatingAsh(
        context: inout GraphicsContext,
        rect: CGRect,
        cornerRadius: CGFloat,
        time: TimeInterval
    ) {
        let ashColors: [Color] = [
            Color(red: 0.15, green: 0.12, blue: 0.10),
            Color(red: 0.30, green: 0.24, blue: 0.20),
            Color(red: 0.48, green: 0.39, blue: 0.32),
            BurnRollTheme.ember
        ]

        for index in 0..<28 {
            let speed = 0.18 + Double(index % 5) * 0.018
            let life = CGFloat(
                (time * speed + Double(index) / 28)
                    .truncatingRemainder(dividingBy: 1)
            )
            let topSource = CGFloat(index % 14) / 14 * 0.31
            let sideSource: CGFloat = index.isMultiple(of: 4) ? 0.88 + CGFloat(index % 3) * 0.025 : topSource
            let source = frameSample(
                progress: wrappedUnit(sideSource),
                rect: rect,
                cornerRadius: cornerRadius
            )
            let drift = CGFloat(sin(time * 1.3 + Double(index) * 2.1)) * (4 + life * 10)
            let lift = life * CGFloat(20 + index % 6 * 5)
            let center = CGPoint(
                x: source.point.x + drift + source.normal.dx * 4,
                y: source.point.y - lift + source.normal.dy * 2
            )
            let width = CGFloat(2.6) + CGFloat(index % 4)
            let height = CGFloat(1.8) + CGFloat(index % 3)
            let fadeIn = min(1, life * 7)
            let opacity = Double(fadeIn * (1 - life)) * (index % 7 == 0 ? 0.96 : 0.72)

            context.drawLayer { ash in
                ash.opacity = opacity
                ash.translateBy(x: center.x, y: center.y)
                ash.rotate(by: .degrees(time * Double(30 + index % 5 * 12) + Double(index * 23)))
                ash.fill(
                    Path(
                        roundedRect: CGRect(
                            x: -width / 2,
                            y: -height / 2,
                            width: width,
                            height: height
                        ),
                        cornerRadius: 0.8
                    ),
                    with: .color(ashColors[index % ashColors.count])
                )
            }
        }
    }

    private func burnedPaperPath(rect: CGRect, cornerRadius: CGFloat) -> Path {
        var path = Path()
        let points = 128

        for index in 0...points {
            let progress = CGFloat(index) / CGFloat(points)
            let sample = frameSample(
                progress: progress,
                rect: rect,
                cornerRadius: cornerRadius
            )
            let broadWave = 1.6 + 1.4 * sin(progress * .pi * 18 + 0.7)
            let fineWave = 0.9 * sin(progress * .pi * 47 + 1.9)
            let bites = 4.4 * pow(max(0, sin(progress * .pi * 13 + 0.35)), 6)
            let depth = max(0.8, broadWave + fineWave + bites)
            let point = CGPoint(
                x: sample.point.x - sample.normal.dx * depth,
                y: sample.point.y - sample.normal.dy * depth
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }

    private func flamePath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: -height))
        path.addCurve(
            to: CGPoint(x: width / 2, y: 0),
            control1: CGPoint(x: width * 0.22, y: -height * 0.68),
            control2: CGPoint(x: width / 2, y: -height * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: -width / 2, y: 0),
            control1: CGPoint(x: width * 0.25, y: height * 0.12),
            control2: CGPoint(x: -width * 0.28, y: height * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: -height),
            control1: CGPoint(x: -width / 2, y: -height * 0.30),
            control2: CGPoint(x: -width * 0.10, y: -height * 0.62)
        )
        path.closeSubpath()
        return path
    }

    private func frameSample(
        progress: CGFloat,
        rect: CGRect,
        cornerRadius: CGFloat
    ) -> FrameSample {
        let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
        let horizontal = max(0, rect.width - radius * 2)
        let vertical = max(0, rect.height - radius * 2)
        let arc = .pi * radius / 2
        let perimeter = horizontal * 2 + vertical * 2 + arc * 4
        var distance = wrappedUnit(progress) * perimeter

        if distance <= horizontal {
            return FrameSample(
                point: CGPoint(x: rect.minX + radius + distance, y: rect.minY),
                normal: CGVector(dx: 0, dy: -1)
            )
        }
        distance -= horizontal

        if distance <= arc {
            return arcSample(
                distance: distance,
                arcLength: arc,
                center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                radius: radius,
                startAngle: -.pi / 2
            )
        }
        distance -= arc

        if distance <= vertical {
            return FrameSample(
                point: CGPoint(x: rect.maxX, y: rect.minY + radius + distance),
                normal: CGVector(dx: 1, dy: 0)
            )
        }
        distance -= vertical

        if distance <= arc {
            return arcSample(
                distance: distance,
                arcLength: arc,
                center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: 0
            )
        }
        distance -= arc

        if distance <= horizontal {
            return FrameSample(
                point: CGPoint(x: rect.maxX - radius - distance, y: rect.maxY),
                normal: CGVector(dx: 0, dy: 1)
            )
        }
        distance -= horizontal

        if distance <= arc {
            return arcSample(
                distance: distance,
                arcLength: arc,
                center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: .pi / 2
            )
        }
        distance -= arc

        if distance <= vertical {
            return FrameSample(
                point: CGPoint(x: rect.minX, y: rect.maxY - radius - distance),
                normal: CGVector(dx: -1, dy: 0)
            )
        }
        distance -= vertical

        return arcSample(
            distance: distance,
            arcLength: arc,
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .pi
        )
    }

    private func arcSample(
        distance: CGFloat,
        arcLength: CGFloat,
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat
    ) -> FrameSample {
        let angle = startAngle + (distance / max(arcLength, 0.001)) * (.pi / 2)
        let normal = CGVector(dx: cos(angle), dy: sin(angle))
        return FrameSample(
            point: CGPoint(
                x: center.x + normal.dx * radius,
                y: center.y + normal.dy * radius
            ),
            normal: normal
        )
    }

    private func wrappedUnit(_ value: CGFloat) -> CGFloat {
        let remainder = value.truncatingRemainder(dividingBy: 1)
        return remainder >= 0 ? remainder : remainder + 1
    }

    private struct FrameSample {
        let point: CGPoint
        let normal: CGVector
    }
}

struct BurnedPaperSpaceCard: View {
    var recoveredBytes: Int64
    var itemCount: Int
    var isActive = true

    private let paperInk = Color(red: 0.19, green: 0.095, blue: 0.055)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.065, blue: 0.045),
                            Color(red: 0.29, green: 0.095, blue: 0.045),
                            Color(red: 0.095, green: 0.052, blue: 0.060)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            AshPaperBurnArtwork(isActive: isActive)
                .allowsHitTesting(false)

            VStack(spacing: 9) {
                BurnRollSymbol(
                    systemName: "flame.fill",
                    size: 30,
                    weight: .bold,
                    role: .light
                )
                .frame(width: 58, height: 58)
                .background(.black.opacity(0.72), in: Circle())
                .overlay {
                    Circle()
                        .stroke(BurnRollTheme.ember.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: BurnRollTheme.ember.opacity(0.32), radius: 10)

                Text(String(localized: "ESTIMATED SPACE RECOVERABLE"))
                    .font(.caption.weight(.heavy))
                    .tracking(1.1)
                    .foregroundStyle(paperInk.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                Text(recoveredBytes.formattedByteCount)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .foregroundStyle(paperInk)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(String(localized: "From \(itemCount.formatted()) items moved to Recently Deleted"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(paperInk.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2)
            }
            .padding(.horizontal, 28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: BurnRollTheme.burn.opacity(0.18), radius: 24, y: 14)
    }
}
