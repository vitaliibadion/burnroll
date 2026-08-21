import SwiftUI

struct AnimatedLoadingFlame: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let flameColor = Color(red: 1, green: 102 / 255, blue: 97 / 255)

    var body: some View {
        if reduceMotion {
            flameImage
        } else {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                flame(at: time)
            }
        }
    }

    private var flameImage: some View {
        Image("LoadingFlame")
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }

    private func flame(at time: TimeInterval) -> some View {
        let flicker = 0.5 + 0.5 * sin(time * 7.3)
        let sway = sin(time * 3.6)
        let lick = sin(time * 5.1)

        return ZStack {
            Circle()
                .fill(flameColor.opacity(0.22 + 0.10 * flicker))
                .blur(radius: 34)
                .scaleEffect(1.18 + 0.10 * flicker)
                .offset(y: 18)

            flameImage
                .blur(radius: 10)
                .opacity(0.38 + 0.16 * flicker)
                .scaleEffect(
                    x: 1.12 + 0.05 * sway,
                    y: 1.16 + 0.08 * lick,
                    anchor: .bottom
                )
                .offset(x: 4 * sway, y: 6)

            flameImage
                .scaleEffect(
                    x: 1 + 0.045 * sin(time * 6.2),
                    y: 1 + 0.08 * lick,
                    anchor: .bottom
                )
                .rotationEffect(.degrees(2.4 * sway), anchor: .bottom)
                .offset(x: 3.5 * sway, y: 2 * sin(time * 4.4))

            sparks(at: time)
        }
        .accessibilityHidden(true)
    }

    private func sparks(at time: TimeInterval) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let phase = time * (1.35 + Double(index) * 0.17) + Double(index) * 1.7
                let cycle = phase.truncatingRemainder(dividingBy: 1.6) / 1.6
                let rise = -36 - CGFloat(index) * 10 - CGFloat(cycle) * 92
                let drift = CGFloat(sin(phase * 2.1)) * (10 + CGFloat(index) * 3)
                let size: CGFloat = index == 0 ? 9 : (6 - CGFloat(index) * 0.45)
                let fade = cycle < 0.12
                    ? cycle / 0.12
                    : max(0, 1 - (cycle - 0.12) / 0.88)

                Circle()
                    .fill(flameColor)
                    .frame(width: size, height: size)
                    .offset(x: drift + CGFloat(index.isMultiple(of: 2) ? 8 : -12), y: rise)
                    .opacity(fade * (index == 0 ? 0.95 : 0.7))
                    .blur(radius: index == 0 ? 0.2 : 0.6)
            }
        }
        .offset(y: -78)
        .allowsHitTesting(false)
    }
}

struct LaunchFireView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                AnimatedLoadingFlame()
                    .frame(width: 168, height: 230)

                Text("BurnRoll")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color(red: 1, green: 102 / 255, blue: 97 / 255))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("BurnRoll is loading")
    }
}
