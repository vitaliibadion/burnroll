import SwiftUI

struct SwipeMediaCard: View {
    let library: PhotoLibraryService
    let asset: MediaAsset
    var playsSwipeHint = false
    var posedOffset: CGFloat = 0
    let onOpen: () -> Void
    let onDecision: (ReviewDecision) -> Void
    var onSwipeHintFinished: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.displayScale) private var displayScale
    @State private var offsetX: CGFloat = .zero
    @State private var crossedThreshold = false
    @State private var isCommitting = false
    @State private var isPlayingHint = false

    private let commitThreshold: CGFloat = 105
    private let hintOffset: CGFloat = 82

    var body: some View {
        GeometryReader { proxy in
            let progress = visualProgress

            VStack(spacing: 0) {
                Color.clear
                    .overlay {
                        PhotoAssetImage(
                            library: library,
                            assetID: asset.id,
                            targetSize: CGSize(
                                width: proxy.size.width * displayScale,
                                height: proxy.size.height * displayScale
                            ),
                            contentMode: .fill
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .overlay {
                        decisionTint(progress: progress)
                    }
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 30,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 30,
                            style: .continuous
                        )
                    )

                MediaMetadataView(asset: asset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(BurnRollTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .compositingGroup()
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(edgeColor.opacity(progress * 0.9), lineWidth: 3)
            }
            .shadow(color: edgeColor.opacity(progress * 0.28), radius: 25, y: 12)
            .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
            .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .onTapGesture {
                if isPlayingHint {
                    skipSwipeHint()
                    return
                }
                guard !isCommitting else { return }
                onOpen()
            }
            .offset(x: offsetX)
            .rotationEffect(.degrees(reduceMotion ? 0 : Double(offsetX / 30)))
            .scaleEffect(reduceMotion ? 1 : 1 - progress * 0.025)
            .gesture(dragGesture(containerWidth: proxy.size.width))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityDescription)
            .accessibilityHint(String(localized: "Swipe left to burn or right to keep. Double tap to open fullscreen."))
            .accessibilityAction(named: String(localized: "Keep photo")) {
                commit(.keep, containerWidth: proxy.size.width)
            }
            .accessibilityAction(named: String(localized: "Burn photo")) {
                commit(.burn, containerWidth: proxy.size.width)
            }
            .onAppear {
                if posedOffset != 0 {
                    offsetX = posedOffset
                    crossedThreshold = true
                }
            }
            .task(id: "\(asset.id)-\(playsSwipeHint)") {
                await playSwipeHintIfNeeded()
            }
        }
    }

    private var edgeColor: Color {
        guard offsetX != 0 else { return .clear }
        return offsetX > 0 ? BurnRollTheme.keep : BurnRollTheme.burn
    }

    private var visualProgress: CGFloat {
        let raw = min(abs(offsetX) / commitThreshold, 1)
        // Marketing poses use a modest offset so the photo stays in frame;
        // keep the tint and KEEP/BURN capsule fully readable anyway.
        if posedOffset != 0 {
            return max(raw, 0.88)
        }
        return raw
    }

    private var accessibilityDescription: String {
        let date = asset.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? String(localized: "unknown date")
        return String(
            localized: "\(asset.mediaType.localizedTitle), \(date), approximately \(asset.estimatedByteSize.formattedByteCount)"
        )
    }

    @ViewBuilder
    private func decisionTint(progress: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [edgeColor.opacity(progress * 0.48), .clear],
                startPoint: offsetX > 0 ? .leading : .trailing,
                endPoint: offsetX > 0 ? .trailing : .leading
            )

            HStack {
                if offsetX <= 0 { Spacer() }

                HStack(spacing: 8) {
                    BurnRollSymbol(
                        systemName: offsetX > 0 ? "heart.fill" : "flame.fill",
                        size: 19,
                        weight: .black,
                        role: .light
                    )
                    Text(offsetX > 0 ? String(localized: "KEEP") : String(localized: "BURN"))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(edgeColor.opacity(0.9), in: Capsule())
                .opacity(progress)
                .scaleEffect(0.85 + progress * 0.15)
                .fixedSize()
                .padding(18)
                .frame(maxHeight: .infinity, alignment: .top)

                if offsetX > 0 { Spacer() }
            }
        }
        .allowsHitTesting(false)
    }

    private func dragGesture(containerWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                if isPlayingHint {
                    skipSwipeHint(resetOffset: false)
                }
                guard !isCommitting else { return }
                guard abs(value.translation.width) >= abs(value.translation.height) else {
                    if offsetX != 0 {
                        offsetX = 0
                        crossedThreshold = false
                    }
                    return
                }

                offsetX = value.translation.width

                let isPastThreshold = abs(value.translation.width) >= commitThreshold
                if isPastThreshold && !crossedThreshold {
                    crossedThreshold = true
                    Haptics.threshold()
                } else if !isPastThreshold {
                    crossedThreshold = false
                }
            }
            .onEnded { value in
                guard !isCommitting else { return }
                guard abs(value.translation.width) >= abs(value.translation.height),
                      abs(value.translation.width) >= commitThreshold
                else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                        offsetX = 0
                    }
                    crossedThreshold = false
                    return
                }

                commit(value.translation.width > 0 ? .keep : .burn, containerWidth: containerWidth)
            }
    }

    private func commit(_ decision: ReviewDecision, containerWidth: CGFloat) {
        guard !isCommitting else { return }
        isPlayingHint = false
        isCommitting = true

        switch decision {
        case .keep: Haptics.keep()
        case .burn: Haptics.burn()
        }

        let direction: CGFloat = decision == .keep ? 1 : -1
        let duration = reduceMotion ? 0.08 : 0.44

        withAnimation(.easeIn(duration: duration)) {
            offsetX = direction * max(containerWidth * 1.5, 520)
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration * 0.72))
            onDecision(decision)
            offsetX = 0
            crossedThreshold = false
            isCommitting = false
        }
    }

    private func playSwipeHintIfNeeded() async {
        guard playsSwipeHint, posedOffset == 0, !isCommitting else { return }

        if reduceMotion {
            onSwipeHintFinished()
            return
        }

        try? await Task.sleep(for: .milliseconds(650))
        guard !Task.isCancelled, playsSwipeHint, !isCommitting else { return }

        isPlayingHint = true

        await nudgeCard(to: -hintOffset)
        guard isPlayingHint, !Task.isCancelled else { return }
        Haptics.threshold()
        try? await Task.sleep(for: .milliseconds(900))

        await nudgeCard(to: 0)
        guard isPlayingHint, !Task.isCancelled else { return }
        try? await Task.sleep(for: .milliseconds(280))

        await nudgeCard(to: hintOffset)
        guard isPlayingHint, !Task.isCancelled else { return }
        Haptics.threshold()
        try? await Task.sleep(for: .milliseconds(900))

        await nudgeCard(to: 0)
        guard isPlayingHint, !Task.isCancelled else { return }

        isPlayingHint = false
        onSwipeHintFinished()
    }

    private func nudgeCard(to value: CGFloat) async {
        guard isPlayingHint, !Task.isCancelled else { return }
        withAnimation(.spring(response: 0.52, dampingFraction: 0.82)) {
            offsetX = value
        }
        try? await Task.sleep(for: .milliseconds(520))
    }

    private func skipSwipeHint(resetOffset: Bool = true) {
        guard isPlayingHint else { return }
        isPlayingHint = false
        if resetOffset {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                offsetX = 0
            }
        }
        onSwipeHintFinished()
    }
}
