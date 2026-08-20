import SwiftUI

struct ReviewHistoryView: View {
    private enum ReviewFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case kept = "Kept"
        case burn = "Burn"

        var id: String { rawValue }
    }

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var filter: ReviewFilter = .all
    @State private var viewerAsset: MediaAsset?
    @State private var showingDeleteConfirmation = false
    @State private var deletionSummary: AppState.DeletionSummary?

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 3
    )

    private var filteredActions: [ReviewAction] {
        appState.session.reviewHistory.reversed().filter { action in
            switch filter {
            case .all: true
            case .kept: action.decision == .keep
            case .burn: action.decision == .burn
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                reviewSummary
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                Picker("Decision filter", selection: $filter) {
                    ForEach(ReviewFilter.allCases) { filter in
                        Text(filterTitle(filter)).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                reviewContent

                deleteButton
                    .padding(16)
            }
            .burnRollBackground()
            .navigationTitle("Review decisions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fullScreenCover(item: $viewerAsset) { asset in
                MediaViewer(
                    library: appState.photoLibrary,
                    asset: asset,
                    decision: appState.session.decision(forAssetID: asset.id),
                    onDecisionChange: { decision in
                        withAnimation(.snappy(duration: 0.28)) {
                            appState.changeDecision(for: asset, to: decision)
                        }
                    }
                )
            }
            .alert(
                "Delete \(appState.session.burnQueue.count) photos and videos?",
                isPresented: $showingDeleteConfirmation
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Delete \(appState.session.burnQueue.count)", role: .destructive) {
                    Task {
                        if let summary = await appState.deleteBurnQueue() {
                            deletionSummary = summary
                            Haptics.deletionSucceeded()
                        }
                    }
                }
            } message: {
                Text(
                    "These items will move to Recently Deleted in Photos, where they may remain for up to 30 days. "
                    + "Delete them there to recover storage immediately."
                )
            }
            .alert(
                "Couldn’t delete items",
                isPresented: Binding(
                    get: { appState.deletionErrorMessage != nil },
                    set: { if !$0 { appState.deletionErrorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(appState.deletionErrorMessage ?? "Please try again.")
            }
            .sheet(item: $deletionSummary) { summary in
                CleaningCompleteView(summary: summary) {
                    appState.continueCleaning()
                    deletionSummary = nil
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var reviewContent: some View {
        if appState.session.reviewHistory.isEmpty {
            ContentUnavailableView(
                "Nothing reviewed yet",
                systemImage: "photo.stack",
                description: Text("Keep swiping. Every Keep and Burn decision will appear here.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredActions.isEmpty {
            ContentUnavailableView(
                "No \(filter.rawValue.lowercased()) items",
                systemImage: filter == .kept ? "heart" : "flame",
                description: Text("Change the filter to review your other decisions.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(filteredActions) { action in
                        Button {
                            viewerAsset = action.asset
                        } label: {
                            GeometryReader { proxy in
                                DecisionThumbnail(
                                    library: appState.photoLibrary,
                                    asset: action.asset,
                                    decision: action.decision,
                                    size: proxy.size.width
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(accessibilityLabel(for: action))
                        .accessibilityHint("Opens this item so you can change Keep or Burn")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .animation(.snappy(duration: 0.28), value: filteredActions)
        }
    }

    private var reviewSummary: some View {
        HStack(spacing: 8) {
            summaryMetric(
                value: appState.session.reviewHistory.count.formatted(),
                label: "Reviewed",
                systemImage: "photo.stack.fill",
                color: BurnRollTheme.ember
            )
            summaryMetric(
                value: appState.session.keptAssets.count.formatted(),
                label: "Kept",
                systemImage: "heart.fill",
                color: BurnRollTheme.keep
            )
            summaryMetric(
                value: appState.session.burnQueue.count.formatted(),
                label: "Burn",
                systemImage: "flame.fill",
                color: BurnRollTheme.burn
            )
        }
        .padding(14)
        .background(BurnRollTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(appState.session.reviewHistory.count) reviewed, "
            + "\(appState.session.keptAssets.count) kept, "
            + "\(appState.session.burnQueue.count) marked to burn"
        )
    }

    private var deleteButton: some View {
        PrimaryButton(
            title: deleteButtonTitle,
            systemImage: "flame.fill",
            isEnabled: !appState.session.burnQueue.isEmpty && !appState.isDeleting
        ) {
            showingDeleteConfirmation = true
        }
    }

    private var deleteButtonTitle: String {
        if appState.isDeleting { return "Deleting…" }
        if appState.session.burnQueue.isEmpty { return "Nothing marked to burn" }
        return "Burn \(appState.session.burnQueue.count) · \(appState.session.estimatedBytes.formattedByteCount)"
    }

    private func filterTitle(_ filter: ReviewFilter) -> String {
        switch filter {
        case .all: "All \(appState.session.reviewHistory.count)"
        case .kept: "Kept \(appState.session.keptAssets.count)"
        case .burn: "Burn \(appState.session.burnQueue.count)"
        }
    }

    private func summaryMetric(
        value: String,
        label: String,
        systemImage: String,
        color: Color
    ) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline.bold())
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func accessibilityLabel(for action: ReviewAction) -> String {
        let decision = action.decision == .burn ? "marked to burn" : "kept"
        return "\(action.asset.mediaType.rawValue) \(decision)"
    }
}

private struct CleaningCompleteView: View {
    let summary: AppState.DeletionSummary
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BurnRollIconTile(
                systemName: "checkmark.circle.fill",
                role: .keep,
                size: 112,
                symbolSize: 62
            )

            Text("Cleaning complete")
                .font(.largeTitle.bold())

            HStack(spacing: 10) {
                metric(summary.itemCount.formatted(), label: "items burned")
                metricDivider
                metric(summary.clearedBytes.formattedByteCount, label: "potential space")
                metricDivider
                metric(summary.reviewDuration.formattedReviewDuration, label: "review time")
            }

            RecentlyDeletedNotice()

            Spacer()

            PrimaryButton(title: "Continue burning", systemImage: "flame.fill", action: onDone)
        }
        .padding(24)
        .burnRollBackground()
    }

    private func metric(_ value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(.caption)
                .foregroundStyle(BurnRollTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(BurnRollTheme.secondaryText.opacity(0.20))
            .frame(width: 1, height: 46)
    }
}

extension AppState.DeletionSummary: Identifiable {
    var id: String { "\(itemCount)-\(clearedBytes)-\(Int(reviewDuration * 1_000))" }
}

private extension TimeInterval {
    var formattedReviewDuration: String {
        let totalSeconds = max(1, Int(rounded()))
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        }

        let totalMinutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if totalMinutes < 60 {
            return seconds == 0
                ? "\(totalMinutes)m"
                : "\(totalMinutes)m \(seconds)s"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes == 0
            ? "\(hours)h"
            : "\(hours)h \(minutes)m"
    }
}
