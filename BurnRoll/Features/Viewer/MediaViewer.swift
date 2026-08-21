import AVKit
import SwiftUI
@preconcurrency import Photos

struct MediaViewer: View {
    let library: PhotoLibraryService
    let asset: MediaAsset
    var decision: ReviewDecision? = nil
    var onDecisionChange: ((ReviewDecision) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dismissalOffsetY: CGFloat = 0
    @State private var isContentZoomed = false
    @State private var hasCommittedDismissal = false
    @State private var crossedDismissalThreshold = false
    @State private var fixedTopInset: CGFloat = 18
    @State private var fixedBottomInset: CGFloat = 18

    private let dismissalThreshold: CGFloat = 120

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                    .opacity(1 - dismissalProgress * 0.78)
                    .ignoresSafeArea()

                if !reduceMotion {
                    DismissalGlow(
                        progress: dismissalProgress,
                        direction: dismissalDirection,
                        containerSize: proxy.size
                    )
                    .allowsHitTesting(false)
                }

                mediaContent
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .center
                    )
                    .contentShape(Rectangle())
                    .simultaneousGesture(dismissGesture)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: reduceMotion ? 0 : 34 * dismissalProgress,
                            style: .continuous
                        )
                    )
                    .overlay {
                        if !reduceMotion {
                            RoundedRectangle(
                                cornerRadius: 34 * dismissalProgress,
                                style: .continuous
                            )
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.62),
                                        BurnRollTheme.ember.opacity(0.34),
                                        .white.opacity(0.08)
                                    ],
                                    startPoint: dismissalDirection < 0 ? .bottomLeading : .topLeading,
                                    endPoint: dismissalDirection < 0 ? .topTrailing : .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                            .opacity(dismissalProgress)
                        }
                    }
                    .shadow(
                        color: .black.opacity(reduceMotion ? 0 : dismissalProgress * 0.62),
                        radius: 34 * dismissalProgress,
                        y: 18 * dismissalDirection
                    )
                    .scaleEffect(
                        reduceMotion ? 1 : 1 - dismissalProgress * 0.045,
                        anchor: .center
                    )
                    .offset(x: 0, y: dismissalOffsetY)
                    .clipped()

            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .center
            )
            .onAppear {
                captureSafeAreaInsets(from: proxy)
            }
        }
        .overlay(alignment: .topTrailing) {
            ViewerCloseButton { dismiss() }
                .padding(.top, fixedTopInset)
                .padding(.trailing, 18)
        }
        .overlay(alignment: .top) {
            if dismissalProgress > 0.01 {
                LiquidDismissIndicator(
                    direction: dismissalDirection,
                    isPastThreshold: crossedDismissalThreshold
                )
                .padding(.top, fixedTopInset + 62)
                .opacity(min(dismissalProgress * 4, 1))
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .bottom) {
            if let decision, let onDecisionChange {
                ViewerDecisionControls(
                    decision: decision,
                    onDecisionChange: onDecisionChange
                )
                .padding(.horizontal, 24)
                .padding(.bottom, fixedBottomInset)
            }
        }
        .interactiveDismissDisabled()
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    @ViewBuilder
    private var mediaContent: some View {
        if asset.mediaType == .video {
            FullscreenVideoView(library: library, assetID: asset.id)
        } else {
            ZoomablePhotoView(
                library: library,
                asset: asset,
                isZoomed: $isContentZoomed
            )
        }
    }

    private func captureSafeAreaInsets(from proxy: GeometryProxy) {
        fixedTopInset = max(proxy.safeAreaInsets.top, 18)
        fixedBottomInset = max(proxy.safeAreaInsets.bottom, 18)
    }

    private var dismissalProgress: CGFloat {
        min(abs(dismissalOffsetY) / 260, 1)
    }

    private var dismissalDirection: CGFloat {
        dismissalOffsetY < 0 ? -1 : 1
    }

    private var dismissGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .global)
            .onChanged { value in
                guard !isContentZoomed, !hasCommittedDismissal else { return }
                guard abs(value.translation.height) > abs(value.translation.width) else { return }
                dismissalOffsetY = value.translation.height

                let isPastThreshold = abs(value.translation.height) >= dismissalThreshold
                if isPastThreshold && !crossedDismissalThreshold {
                    crossedDismissalThreshold = true
                    Haptics.threshold()
                } else if !isPastThreshold {
                    crossedDismissalThreshold = false
                }
            }
            .onEnded { value in
                guard !hasCommittedDismissal else { return }
                guard !isContentZoomed else {
                    restoreViewerPosition()
                    return
                }

                let translation = value.translation
                let predictedY = value.predictedEndTranslation.height
                let isVertical = abs(translation.height) > abs(translation.width)
                let crossesThreshold = abs(translation.height) >= dismissalThreshold
                    || abs(predictedY) >= dismissalThreshold * 1.8

                guard isVertical, crossesThreshold else {
                    restoreViewerPosition()
                    return
                }

                dismissVertically(toward: predictedY == 0 ? translation.height : predictedY)
            }
    }

    private func restoreViewerPosition() {
        let animation: Animation = reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.42, dampingFraction: 0.76)
        withAnimation(animation) {
            dismissalOffsetY = 0
            crossedDismissalThreshold = false
        }
    }

    private func dismissVertically(toward verticalTranslation: CGFloat) {
        guard !hasCommittedDismissal else { return }
        hasCommittedDismissal = true

        guard !reduceMotion else {
            dismiss()
            return
        }

        let direction: CGFloat = verticalTranslation < 0 ? -1 : 1
        withAnimation(.smooth(duration: 0.28)) {
            dismissalOffsetY = direction * 1_200
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(230))
            dismiss()
        }
    }
}

private struct ViewerDecisionControls: View {
    let decision: ReviewDecision
    let onDecisionChange: (ReviewDecision) -> Void

    var body: some View {
        HStack(spacing: 10) {
            decisionButton(
                .keep,
                title: "Keep",
                systemImage: "heart.fill",
                color: BurnRollTheme.keep
            )
            decisionButton(
                .burn,
                title: "Burn",
                systemImage: "flame.fill",
                color: BurnRollTheme.burn
            )
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private func decisionButton(
        _ targetDecision: ReviewDecision,
        title: String,
        systemImage: String,
        color: Color
    ) -> some View {
        let isSelected = decision == targetDecision

        return Button {
            guard !isSelected else { return }
            onDecisionChange(targetDecision)
            switch targetDecision {
            case .keep: Haptics.keep()
            case .burn: Haptics.burn()
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(isSelected ? color : Color.white.opacity(0.09), in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(.white.opacity(0.45), lineWidth: 1)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mark as \(title)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

private struct ViewerCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
        }
        .modifier(ViewerCloseButtonStyle())
        .accessibilityLabel("Close fullscreen viewer")
    }
}

private struct ViewerCloseButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BurnRollTheme.surface.opacity(0.94), in: Circle())
            .overlay {
                Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1)
            }
    }
}

private struct LiquidDismissIndicator: View {
    let direction: CGFloat
    let isPastThreshold: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isPastThreshold ? "xmark" : direction < 0 ? "chevron.up.2" : "chevron.down.2")
                .font(.subheadline.weight(.black))
                .contentTransition(.symbolEffect(.replace))

            Text(isPastThreshold ? "Release to close" : direction < 0 ? "Swipe up" : "Swipe down")
                .font(.subheadline.weight(.bold))
                .contentTransition(.opacity)
        }
        .foregroundStyle(BurnRollTheme.primaryText)
        .frame(width: 168, height: 48)
        .overlay {
            Capsule()
                .strokeBorder(
                    isPastThreshold
                        ? BurnRollTheme.ember.opacity(0.82)
                        : BurnRollTheme.ember.opacity(0.26),
                    lineWidth: 1
                )
        }
        .modifier(LiquidDismissIndicatorStyle(isPastThreshold: isPastThreshold))
        .shadow(
            color: BurnRollTheme.burn.opacity(isPastThreshold ? 0.42 : 0.12),
            radius: isPastThreshold ? 18 : 8
        )
        .animation(.snappy(duration: 0.2), value: isPastThreshold)
        .accessibilityHidden(true)
    }
}

private struct LiquidDismissIndicatorStyle: ViewModifier {
    let isPastThreshold: Bool

    func body(content: Content) -> some View {
        content
            .background(
                isPastThreshold
                    ? BurnRollTheme.burn.opacity(0.94)
                    : BurnRollTheme.surface.opacity(0.94),
                in: Capsule()
            )
    }
}

private struct DismissalGlow: View {
    let progress: CGFloat
    let direction: CGFloat
    let containerSize: CGSize

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            BurnRollTheme.ember.opacity(0.42 * progress),
                            BurnRollTheme.burn.opacity(0.16 * progress),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 210
                    )
                )
                .frame(
                    width: containerSize.width * (0.72 + progress * 0.42),
                    height: 90 + progress * 180
                )
                .blur(radius: 18 + progress * 24)
                .offset(y: direction * (containerSize.height * 0.43 - progress * 36))

            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.30 * progress), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: 76 + CGFloat(index) * 34 + progress * 46,
                        height: 1.5 + progress
                    )
                    .offset(
                        x: CGFloat(index - 1) * 18,
                        y: direction * (containerSize.height * 0.39 - CGFloat(index) * 13)
                    )
                    .opacity(progress)
            }
        }
        .ignoresSafeArea()
    }
}

private struct ZoomablePhotoView: View {
    let library: PhotoLibraryService
    let asset: MediaAsset
    @Binding var isZoomed: Bool

    @Environment(\.displayScale) private var displayScale
    @State private var steadyScale: CGFloat = 1
    @GestureState private var gestureScale: CGFloat = 1
    @State private var steadyOffset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero

    private var scale: CGFloat {
        min(max(steadyScale * gestureScale, 1), 5)
    }

    private var offset: CGSize {
        CGSize(
            width: steadyOffset.width + gestureOffset.width,
            height: steadyOffset.height + gestureOffset.height
        )
    }

    var body: some View {
        GeometryReader { proxy in
            PhotoAssetImage(
                library: library,
                assetID: asset.id,
                targetSize: CGSize(
                    width: proxy.size.width * displayScale * 1.5,
                    height: proxy.size.height * displayScale * 1.5
                ),
                contentMode: .fit,
                networkAccessAllowed: true
            )
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .scaleEffect(scale)
            .offset(offset)
            .clipped()
            .gesture(zoomGesture.simultaneously(with: panGesture))
            .onTapGesture(count: 2) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    steadyScale = steadyScale > 1 ? 1 : 2.5
                    isZoomed = steadyScale > 1
                    if steadyScale == 1 {
                        steadyOffset = .zero
                    }
                }
            }
            .accessibilityLabel("Fullscreen photo")
            .accessibilityHint("Pinch or double tap to zoom. Swipe up or down to close when not zoomed.")
        }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onChanged { value in
                isZoomed = steadyScale * value > 1.01
            }
            .onEnded { value in
                steadyScale = min(max(steadyScale * value, 1), 5)
                isZoomed = steadyScale > 1.01
                if steadyScale == 1 {
                    steadyOffset = .zero
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                guard scale > 1 else { return }
                state = value.translation
            }
            .onEnded { value in
                guard scale > 1 else {
                    steadyOffset = .zero
                    return
                }
                steadyOffset.width += value.translation.width
                steadyOffset.height += value.translation.height
            }
    }
}

private struct FullscreenVideoView: View {
    let library: PhotoLibraryService
    let assetID: String

    @State private var player: AVPlayer?
    @State private var requestID: PHImageRequestID?
    @State private var isVisible = false

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
            } else {
                ProgressView("Preparing video…")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            isVisible = true
            VideoPlaybackAudioSession.activate()
            requestID = library.requestPlayerItem(localIdentifier: assetID) { playerItem in
                guard let playerItem else { return }
                Task { @MainActor in
                    guard isVisible else { return }
                    let previewPlayer = AVPlayer(playerItem: playerItem)
                    previewPlayer.isMuted = false
                    previewPlayer.volume = 1
                    player = previewPlayer
                }
            }
        }
        .onDisappear {
            isVisible = false
            player?.pause()
            player = nil
            if let requestID {
                library.cancelImageRequest(requestID)
            }
            VideoPlaybackAudioSession.deactivate()
        }
    }
}
