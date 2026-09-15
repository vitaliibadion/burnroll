import SwiftUI

enum OnboardingDemoKind: Hashable {
    case swipe
    case undo
    case review
    case storage
}

/// A ~2.6s looping product clip. Drawn in SwiftUI so KEEP/BURN follow the system language.
struct OnboardingDemoReel: View {
    let kind: OnboardingDemoKind
    var isActive = true
    var accent = BurnRollTheme.keep

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var anchor = Date()

    private let loopDuration: TimeInterval = 2.6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isActive || reduceMotion)) { context in
            reel(at: displayTime(at: context.date))
        }
        .frame(maxWidth: 280)
        .frame(height: 318)
        .onAppear(perform: restartLoop)
        .onChange(of: isActive) { _, active in
            if active { restartLoop() }
        }
        .accessibilityHidden(true)
    }

    private func restartLoop() {
        anchor = Date()
    }

    private func displayTime(at date: Date) -> CGFloat {
        if reduceMotion || !isActive {
            switch kind {
            case .swipe: 0.72
            case .undo: 0.95
            case .review: 1.15
            case .storage: 1.7
            }
        } else {
            CGFloat(date.timeIntervalSince(anchor).truncatingRemainder(dividingBy: loopDuration))
        }
    }

    @ViewBuilder
    private func reel(at time: CGFloat) -> some View {
        switch kind {
        case .storage:
            storageDemo(time: time)
        case .swipe, .undo, .review:
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(BurnRollTheme.surface)
                    .shadow(color: accent.opacity(0.18), radius: 28, y: 16)

                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)

                Group {
                    switch kind {
                    case .swipe:
                        swipeDemo(time: time)
                    case .undo:
                        undoDemo(time: time)
                    case .review:
                        reviewDemo(time: time)
                    case .storage:
                        EmptyView()
                    }
                }
                .padding(16)
                .opacity(sceneOpacity(time))
            }
        }
    }

    private func sceneOpacity(_ time: CGFloat) -> CGFloat {
        if time < 0.1 { return smoothstep(time, 0, 0.1) }
        if time > 2.48 { return 1 - smoothstep(time, 2.48, 2.6) }
        return 1
    }

    private func swipeDemo(time: CGFloat) -> some View {
        let pose = SwipePose(time: time)
        return VStack(spacing: 12) {
            ZStack {
                demoCard(
                    photo: pose.backPhoto,
                    offset: 0,
                    progress: 0,
                    decision: .keep
                )
                .scaleEffect(0.92 + 0.08 * pose.fly)
                .offset(y: 10 - 10 * pose.fly)
                .opacity(0.5 + 0.5 * pose.fly)

                demoCard(
                    photo: pose.frontPhoto,
                    offset: pose.offset,
                    progress: pose.progress,
                    decision: pose.decision
                )
                .rotationEffect(.degrees(Double(pose.offset / 28)))

                if pose.fingerOpacity > 0.02 {
                    finger(opacity: pose.fingerOpacity)
                        .offset(x: pose.offset * 0.92, y: 38)
                }
            }
            .frame(height: 198)

            mockDecisionBar(highlighted: pose.barHighlight)
        }
    }

    private func undoDemo(time: CGFloat) -> some View {
        let pose = UndoPose(time: time)
        return VStack(spacing: 12) {
            ZStack {
                demoCard(
                    photo: .coast,
                    offset: pose.offset,
                    progress: pose.progress,
                    decision: .burn
                )
                .rotationEffect(.degrees(Double(pose.offset / 28)))

                if pose.fingerOpacity > 0.02 {
                    finger(opacity: pose.fingerOpacity)
                        .offset(x: pose.offset * 0.92, y: 38)
                }
            }
            .frame(height: 198)

            mockDecisionBar(undoPulse: pose.undoPulse)
        }
    }

    private func reviewDemo(time: CGFloat) -> some View {
        let press = pulse(time, from: 0.88, to: 1.18)
        let confirm = smoothstep(time, 1.12, 1.55)
        let burnCount = 4
        let burnBytes = Int64(48 * 1_048_576)
        let buttonTitle = confirm > 0.55
            ? String(localized: "Cleaning complete")
            : String(localized: "Burn \(burnCount) · \(burnBytes.formattedByteCount)")

        return VStack(spacing: 10) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
                spacing: 6
            ) {
                ForEach(Array(reviewThumbs.enumerated()), id: \.offset) { _, item in
                    demoThumb(photo: item.photo, decision: item.decision)
                        .opacity(item.decision == .burn ? 1 - 0.72 * confirm : 1)
                        .scaleEffect(item.decision == .burn ? 1 - 0.08 * confirm : 1)
                }
            }

            Capsule()
                .fill(confirm > 0.55 ? BurnRollTheme.keep : BurnRollTheme.burn)
                .frame(height: 36)
                .overlay {
                    HStack(spacing: 6) {
                        Image(systemName: confirm > 0.55 ? "checkmark" : "flame.fill")
                            .font(.footnote.weight(.bold))
                        Text(buttonTitle)
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(.white)
                }
                .scaleEffect(1 - 0.05 * press + 0.03 * confirm)
                .opacity(0.55 + 0.45 * smoothstep(time, 0.28, 0.62))
        }
    }

    private func storageDemo(time: CGFloat) -> some View {
        let fill = smoothstep(time, 0.18, 1.92)
        let bytes = Int64((1_800_000_000 * Double(fill)).rounded())
        let items = Int((48 * Double(fill)).rounded())

        return BurnedPaperSpaceCard(
            recoveredBytes: bytes,
            itemCount: items,
            isActive: isActive && !reduceMotion
        )
        .scaleEffect(0.98 + 0.02 * fill)
    }

    private var reviewThumbs: [(photo: DemoPhoto, decision: ReviewDecision)] {
        [
            (.plants, .keep),
            (.coast, .burn),
            (.coffee, .burn),
            (.cat, .keep),
            (.market, .burn),
            (.picnic, .burn)
        ]
    }

    private func demoCard(
        photo: DemoPhoto,
        offset: CGFloat,
        progress: CGFloat,
        decision: ReviewDecision
    ) -> some View {
        let edge = decision == .keep ? BurnRollTheme.keep : BurnRollTheme.burn
        return ZStack(alignment: .top) {
            photo.view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            LinearGradient(
                colors: [edge.opacity(progress * 0.48), .clear],
                startPoint: decision == .keep ? .leading : .trailing,
                endPoint: decision == .keep ? .trailing : .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            HStack {
                if decision == .burn { Spacer() }
                HStack(spacing: 5) {
                    BurnRollSymbol(
                        systemName: decision == .keep ? "heart.fill" : "flame.fill",
                        size: 11,
                        weight: .black,
                        role: .light
                    )
                    Text(decision == .keep ? String(localized: "KEEP") : String(localized: "BURN"))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(edge.opacity(0.92), in: Capsule())
                .opacity(progress)
                .padding(10)
                if decision == .keep { Spacer() }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(edge.opacity(progress * 0.9), lineWidth: 2.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(x: offset)
        .shadow(color: edge.opacity(progress * 0.28), radius: 12, y: 6)
    }

    private func demoThumb(photo: DemoPhoto, decision: ReviewDecision) -> some View {
        let edge = decision == .burn ? BurnRollTheme.burn : BurnRollTheme.keep
        return photo.view
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: decision == .burn ? "flame.fill" : "heart.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(edge, in: Circle())
                    .overlay { Circle().strokeBorder(.white.opacity(0.78), lineWidth: 0.8) }
                    .padding(4)
            }
    }

    private func mockDecisionBar(highlighted: ReviewDecision? = nil, undoPulse: CGFloat = 0) -> some View {
        HStack(spacing: 8) {
            mockPill(
                title: String(localized: "Keep"),
                systemImage: "heart.fill",
                color: BurnRollTheme.keep,
                dimmed: highlighted == .burn
            )
            ZStack {
                Circle()
                    .fill(BurnRollTheme.background)
                    .frame(width: 36, height: 36)
                BurnRollSymbol(systemName: "arrow.uturn.backward", size: 13, role: .neutral)
            }
            .scaleEffect(1 + undoPulse * 0.18)
            .overlay {
                Circle()
                    .strokeBorder(BurnRollTheme.ember.opacity(undoPulse), lineWidth: 2)
            }
            mockPill(
                title: String(localized: "Burn"),
                systemImage: "flame.fill",
                color: BurnRollTheme.burn,
                dimmed: highlighted == .keep
            )
        }
    }

    private func mockPill(title: String, systemImage: String, color: Color, dimmed: Bool) -> some View {
        HStack(spacing: 4) {
            BurnRollSymbol(systemName: systemImage, size: 10, weight: .bold, role: .light)
            Text(title)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(dimmed ? 0.42 : 1), in: Capsule())
    }

    private func finger(opacity: CGFloat) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [.white, Color(white: 0.92)],
                    center: .topLeading,
                    startRadius: 2,
                    endRadius: 18
                )
            )
            .frame(width: 26, height: 32)
            .overlay {
                Ellipse().strokeBorder(.black.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.22), radius: 6, y: 3)
            .opacity(opacity)
            .allowsHitTesting(false)
    }
}

private enum DemoPhoto: CaseIterable {
    case plants
    case coast
    case coffee
    case cat
    case market
    case picnic

    private var assetName: String {
        switch self {
        case .plants: "OnboardingDemoPlants"
        case .coast: "OnboardingDemoCoast"
        case .coffee: "OnboardingDemoCoffee"
        case .cat: "OnboardingDemoCat"
        case .market: "OnboardingDemoMarket"
        case .picnic: "OnboardingDemoPicnic"
        }
    }

    var view: some View {
        Image(assetName)
            .resizable()
            .scaledToFill()
    }
}

private struct SwipePose {
    var offset: CGFloat
    var progress: CGFloat
    var fly: CGFloat
    var decision: ReviewDecision
    var frontPhoto: DemoPhoto
    var backPhoto: DemoPhoto
    var fingerOpacity: CGFloat
    var barHighlight: ReviewDecision?

    init(time: CGFloat) {
        if time < 1.2 {
            let drag = smoothstep(time, 0.22, 0.82)
            fly = smoothstep(time, 0.82, 1.12)
            offset = 68 * drag + 150 * fly
            progress = min(1, drag * 1.2)
            decision = .keep
            frontPhoto = .plants
            backPhoto = .coast
            fingerOpacity = smoothstep(time, 0.08, 0.2) * (1 - fly)
            barHighlight = drag > 0.18 ? .keep : nil
        } else {
            let local = time - 1.2
            let drag = smoothstep(local, 0.16, 0.72)
            fly = smoothstep(local, 0.72, 1.02)
            offset = -68 * drag - 150 * fly
            progress = min(1, drag * 1.2)
            decision = .burn
            frontPhoto = .coast
            backPhoto = .coffee
            fingerOpacity = smoothstep(local, 0.04, 0.16) * (1 - fly)
            barHighlight = drag > 0.18 ? .burn : nil
        }
    }
}

private struct UndoPose {
    var offset: CGFloat
    var progress: CGFloat
    var undoPulse: CGFloat
    var fingerOpacity: CGFloat

    init(time: CGFloat) {
        let drag = smoothstep(time, 0.16, 0.7)
        let rewind = 1 - smoothstep(time, 1.38, 1.92)
        offset = -64 * drag * rewind
        progress = min(1, drag * rewind * 1.2)
        undoPulse = pulse(time, from: 1.02, to: 1.48)
        fingerOpacity = smoothstep(time, 0.1, 0.24) * (1 - smoothstep(time, 0.7, 0.9))
    }
}

private func pulse(_ time: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
    guard time >= from, time <= to else { return 0 }
    let u = (time - from) / max(to - from, 0.001)
    return sin(u * .pi)
}

private func smoothstep(_ time: CGFloat, _ edge0: CGFloat, _ edge1: CGFloat) -> CGFloat {
    let span = max(edge1 - edge0, 0.001)
    let x = min(max((time - edge0) / span, 0), 1)
    return x * x * (3 - 2 * x)
}
