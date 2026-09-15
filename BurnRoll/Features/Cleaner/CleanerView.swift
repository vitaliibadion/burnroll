import SwiftUI

struct CleanerView: View {
    fileprivate enum SheetDestination: String, Identifiable {
        case settings
        case mediaSource
        case review

        var id: String { rawValue }
    }

    @Environment(AppState.self) private var appState
    @State private var viewerAsset: MediaAsset?
    @State private var sheetDestination: SheetDestination?

    var body: some View {
        VStack(spacing: 10) {
            header

            if let summary = appState.lastDeletionSummary {
                lastCleanupReminder(summary)
            }

            RecentDecisionsStrip(
                library: appState.photoLibrary,
                actions: appState.session.reviewHistory,
                onOpen: { viewerAsset = $0 }
            )
            .frame(maxWidth: .infinity)
            .frame(height: 64)

            Group {
                if let asset = appState.currentAsset {
                    SwipeMediaCard(
                        library: appState.photoLibrary,
                        asset: asset,
                        playsSwipeHint: appState.shouldPlaySwipeHint,
                        posedOffset: screenshotCardOffset,
                        onOpen: { viewerAsset = asset },
                        onDecision: appState.decide,
                        onSwipeHintFinished: appState.completeSwipeHint
                    )
                    .id("\(asset.id)-\(appState.swipeHintGeneration)")
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            progressBanner

            bottomBar
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .burnRollBackground()
        .fullScreenCover(item: $viewerAsset) { asset in
            MediaViewer(
                library: appState.photoLibrary,
                asset: asset,
                decision: appState.session.decision(forAssetID: asset.id),
                onDecisionChange: appState.session.decision(forAssetID: asset.id) == nil
                    ? nil
                    : { appState.changeDecision(for: asset, to: $0) }
            )
        }
        .modifier(CleanerDestinationPresenter(destination: $sheetDestination, appState: appState))
        .task(id: "\(appState.photoLibrary.selectedSource.id)-\(appState.session.currentIndex)") {
            appState.photoLibrary.updateCache(
                around: appState.session.currentIndex,
                targetSize: CGSize(width: 1_200, height: 1_600)
            )
        }
        .onAppear {
            presentScreenshotDestinationIfNeeded()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(spacing: 8) {
                Button {
                    sheetDestination = .settings
                } label: {
                    BurnRollIconTile(
                        systemName: "gearshape",
                        role: .light
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Settings"))

                Button {
                    sheetDestination = .mediaSource
                } label: {
                    BurnRollIconTile(
                        systemName: appState.photoLibrary.selectedSource.systemImage,
                        role: .photo
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    String(
                        localized: "Media source, \(appState.photoLibrary.selectedSource.title), \(appState.photoLibrary.selectedReviewScope.title)"
                    )
                )
                .accessibilityHint(String(localized: "Choose review status, media type, or album"))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(
                    String(
                        localized: "\(appState.photoLibrary.selectedReviewScope.shortTitle) - \(appState.photoLibrary.selectedSource.title) - will free"
                    )
                )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .truncationMode(.tail)
                Text(appState.session.estimatedBytes.formattedByteCount)
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Button {
                sheetDestination = .review
            } label: {
                HStack(spacing: 6) {
                    BurnRollSymbol(systemName: "photo.stack.fill", size: 16, role: .photo)
                    Text("Review \(appState.session.reviewHistory.count)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BurnRollTheme.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(BurnRollTheme.surface, in: Capsule())
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .fixedSize(horizontal: true, vertical: false)
            .layoutPriority(1)
            .accessibilityLabel(
                String(localized: "Review history, \(appState.session.reviewHistory.count) decisions")
            )
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            decisionButton(
                title: String(localized: "Keep"),
                systemImage: "heart.fill",
                color: BurnRollTheme.keep,
                decision: .keep
            )

            Button {
                appState.undo()
                Haptics.undo()
            } label: {
                BurnRollSymbol(systemName: "arrow.uturn.backward", size: 18, role: .neutral)
                    .frame(width: 52, height: 52)
                    .background(BurnRollTheme.surface, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(appState.session.lastAction == nil)
            .opacity(appState.session.lastAction == nil ? 0.4 : 1)
            .accessibilityLabel(String(localized: "Undo last decision"))

            decisionButton(
                title: String(localized: "Burn"),
                systemImage: "flame.fill",
                color: BurnRollTheme.burn,
                decision: .burn
            )
        }
    }

    private func decisionButton(
        title: String,
        systemImage: String,
        color: Color,
        decision: ReviewDecision
    ) -> some View {
        Button {
            appState.decide(decision)
            if decision == .keep {
                Haptics.keep()
            } else {
                Haptics.burn()
            }
        } label: {
            HStack(spacing: 7) {
                BurnRollSymbol(systemName: systemImage, size: 16, role: .light)
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(appState.currentAsset == nil)
        .opacity(appState.currentAsset == nil ? 0.4 : 1)
        .accessibilityHint(String(localized: "Makes the same decision as swiping the current item"))
    }

    private var progressBanner: some View {
        HStack(spacing: 0) {
            progressMetric(appState.session.totalAssetCount, label: String(localized: "Total"))
            progressDivider
            progressMetric(appState.session.reviewedCount, label: String(localized: "Processed"))
            progressDivider
            progressMetric(appState.session.remainingCount, label: String(localized: "Remaining"))
        }
        .padding(.vertical, 10)
        .background(BurnRollTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(
                localized: "Library progress, \(appState.session.totalAssetCount) total, \(appState.session.reviewedCount) processed, \(appState.session.remainingCount) remaining"
            )
        )
    }

    private var progressDivider: some View {
        Rectangle()
            .fill(BurnRollTheme.secondaryText.opacity(0.18))
            .frame(width: 1, height: 28)
    }

    private func progressMetric(_ value: Int, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value.formatted())
                .font(.subheadline.weight(.bold))
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func lastCleanupReminder(_ summary: AppState.DeletionSummary) -> some View {
        HStack(spacing: 10) {
            BurnRollSymbol(systemName: "clock.arrow.circlepath", size: 15, role: .keep)

            Text("Last cleanup")
                .font(.subheadline.weight(.semibold))

            Spacer(minLength: 8)

            Text("\(summary.clearedBytes.formattedByteCount) \(String(localized: "potential"))")
                .font(.subheadline.weight(.bold))

            Text(L10n.items(summary.itemCount))
                .font(.caption.weight(.medium))
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(BurnRollTheme.surface, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                localized: "Last cleanup selected approximately \(summary.clearedBytes.formattedByteCount) from \(summary.itemCount) items"
            )
        )
    }

    private var emptyState: some View {
        Group {
            if appState.session.totalAssetCount == 0 {
                emptyFilteredLibraryState
            } else {
                ContentUnavailableView {
                    Label(
                        appState.photoLibrary.selectedReviewScope == .notReviewed
                            ? String(localized: "Checkpoint saved")
                            : String(localized: "You’re all caught up"),
                        systemImage: appState.photoLibrary.selectedReviewScope == .notReviewed
                            ? "bookmark.fill"
                            : "sparkles"
                    )
                } description: {
                    if appState.photoLibrary.selectedReviewScope == .notReviewed {
                        Text(
                            String(
                                localized: "You reviewed everything in \(appState.photoLibrary.selectedSource.title). Come back later and new items will appear here automatically."
                            )
                        )
                    } else {
                        Text("You reviewed everything in \(appState.photoLibrary.selectedSource.title).")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyFilteredLibraryState: some View {
        switch appState.photoLibrary.selectedReviewScope {
        case .notReviewed:
            ContentUnavailableView {
                Label("Nothing left to review", systemImage: "checkmark.seal.fill")
            } description: {
                Text(
                    String(
                        localized: "Your bookmark is up to date. New photos will appear here automatically, or choose Reviewed or All items from the top-left button."
                    )
                )
            }
        case .reviewed:
            ContentUnavailableView {
                Label("No reviewed items", systemImage: "bookmark")
            } description: {
                Text("Make a Keep or Burn decision first, or choose Not reviewed or All items.")
            }
        case .all:
            ContentUnavailableView {
                Label(
                    appState.photoLibrary.selectedSource.id == "all"
                        ? String(localized: "No media found")
                        : String(localized: "No items in \(appState.photoLibrary.selectedSource.title)"),
                    systemImage: appState.photoLibrary.selectedSource.systemImage
                )
            } description: {
                Text("Choose another media type or album from the top-left button.")
            }
        }
    }

    private var screenshotCardOffset: CGFloat {
        #if DEBUG
        ScreenshotDemo.isActive ? ScreenshotDemo.posedCardOffset : 0
        #else
        0
        #endif
    }

    private func presentScreenshotDestinationIfNeeded() {
        #if DEBUG
        guard ScreenshotDemo.isActive else { return }
        if ScreenshotDemo.shouldOpenReview {
            sheetDestination = .review
        } else if ScreenshotDemo.shouldOpenSettings {
            sheetDestination = .settings
        }
        #endif
    }
}

private struct CleanerDestinationPresenter: ViewModifier {
    @Binding var destination: CleanerView.SheetDestination?
    let appState: AppState

    func body(content: Content) -> some View {
        #if DEBUG
        if ScreenshotDemo.isActive {
            content.fullScreenCover(item: $destination) { cover in
                destinationView(cover)
            }
        } else {
            content.sheet(item: $destination) { cover in
                destinationView(cover)
            }
        }
        #else
        content.sheet(item: $destination) { cover in
            destinationView(cover)
        }
        #endif
    }

    @ViewBuilder
    private func destinationView(_ destination: CleanerView.SheetDestination) -> some View {
        switch destination {
        case .settings:
            SettingsView()
                .environment(appState)
        case .mediaSource:
            MediaSourcePickerView()
                .environment(appState)
        case .review:
            ReviewHistoryView()
                .environment(appState)
        }
    }
}
