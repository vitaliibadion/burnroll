import SwiftUI

struct SwipeMediaCard: View {
    let library: PhotoLibraryService
    let asset: MediaAsset
    let onOpen: () -> Void
    let onDecision: (ReviewDecision) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.displayScale) private var displayScale
    @State private var offset: CGSize = .zero
    @State private var crossedThreshold = false
    @State private var isCommitting = false

    private let commitThreshold: CGFloat = 105

    var body: some View {
        GeometryReader { proxy in
            let progress = min(abs(offset.width) / commitThreshold, 1)
            let isPortrait = asset.pixelHeight > asset.pixelWidth

            VStack(spacing: 0) {
                ZStack {
                    PhotoAssetImage(
                        library: library,
                        assetID: asset.id,
                        targetSize: CGSize(
                            width: proxy.size.width * displayScale,
                            height: proxy.size.height * displayScale
                        ),
                        contentMode: isPortrait ? .fill : .fit
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, isPortrait ? 0 : 8)
                    .padding(.top, isPortrait ? 0 : 8)
                    .clipped()

                    decisionTint(progress: progress)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                MediaMetadataView(asset: asset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(BurnRollTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(edgeColor.opacity(progress * 0.9), lineWidth: 3)
            }
            .shadow(color: edgeColor.opacity(progress * 0.28), radius: 25, y: 12)
            .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
            .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .onTapGesture {
                guard !isCommitting else { return }
                onOpen()
            }
            .offset(offset)
            .rotationEffect(.degrees(reduceMotion ? 0 : Double(offset.width / 30)))
            .scaleEffect(reduceMotion ? 1 : 1 - progress * 0.025)
            .gesture(dragGesture(containerWidth: proxy.size.width))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityDescription)
            .accessibilityHint("Swipe left to burn or right to keep. Double tap to open fullscreen.")
            .accessibilityAction(named: "Keep photo") {
                commit(.keep, containerWidth: proxy.size.width)
            }
            .accessibilityAction(named: "Burn photo") {
                commit(.burn, containerWidth: proxy.size.width)
            }
        }
    }

    private var edgeColor: Color {
        guard offset.width != 0 else { return .clear }
        return offset.width > 0 ? BurnRollTheme.keep : BurnRollTheme.burn
    }

    private var accessibilityDescription: String {
        let date = asset.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "unknown date"
        return "\(asset.mediaType.rawValue), \(date), approximately \(asset.estimatedByteSize.formattedByteCount)"
    }

    @ViewBuilder
    private func decisionTint(progress: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [edgeColor.opacity(progress * 0.48), .clear],
                startPoint: offset.width > 0 ? .trailing : .leading,
                endPoint: offset.width > 0 ? .leading : .trailing
            )

            HStack {
                if offset.width > 0 { Spacer() }

                HStack(spacing: 8) {
                    BurnRollSymbol(
                        systemName: offset.width > 0 ? "heart.fill" : "flame.fill",
                        size: 19,
                        weight: .black,
                        role: .light
                    )
                    Text(offset.width > 0 ? "KEEP" : "BURN")
                }
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(edgeColor.opacity(0.9), in: Capsule())
                .opacity(progress)
                .scaleEffect(0.85 + progress * 0.15)
                .padding(22)
                .frame(maxHeight: .infinity, alignment: .top)

                if offset.width <= 0 { Spacer() }
            }
        }
        .allowsHitTesting(false)
    }

    private func dragGesture(containerWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isCommitting else { return }
                offset = CGSize(width: value.translation.width, height: value.translation.height * 0.18)

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
                if abs(value.translation.width) >= commitThreshold {
                    commit(value.translation.width > 0 ? .keep : .burn, containerWidth: containerWidth)
                } else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                        offset = .zero
                    }
                    crossedThreshold = false
                }
            }
    }

    private func commit(_ decision: ReviewDecision, containerWidth: CGFloat) {
        guard !isCommitting else { return }
        isCommitting = true

        switch decision {
        case .keep: Haptics.keep()
        case .burn: Haptics.burn()
        }

        let direction: CGFloat = decision == .keep ? 1 : -1
        let duration = reduceMotion ? 0.08 : 0.44

        withAnimation(.easeIn(duration: duration)) {
            offset = CGSize(width: direction * max(containerWidth * 1.5, 520), height: 18)
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration * 0.72))
            onDecision(decision)
            offset = .zero
            crossedThreshold = false
            isCommitting = false
        }
    }
}
