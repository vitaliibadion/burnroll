import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    BurnRollBrandMark(size: 82)

                    headline

                    libraryProgressCard

                    HStack(spacing: 10) {
                        BurnRollSymbol(
                            systemName: "checkmark.shield.fill",
                            size: 16,
                            role: .keep
                        )
                        Text("Nothing is deleted until you review and confirm.")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(BurnRollTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        BurnRollTheme.surface,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )

                    PrivacyFootnote(alignment: .center)

                    if let summary = appState.lastDeletionSummary {
                        lastCleanupCard(summary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 14)
            }
            .scrollIndicators(.hidden)

            PrimaryButton(
                title: primaryButtonTitle,
                systemImage: "flame.fill",
                isEnabled: allItemCount > 0
            ) {
                if notReviewedItemCount == 0, allItemCount > 0 {
                    appState.selectReviewScope(.all)
                }
                appState.startCleaning()
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(BurnRollTheme.background)
        }
        .burnRollBackground()
    }

    private var allItemCount: Int {
        appState.photoLibrary.itemCount(for: .all)
    }

    private var reviewedItemCount: Int {
        appState.photoLibrary.itemCount(for: .reviewed)
    }

    private var notReviewedItemCount: Int {
        appState.photoLibrary.itemCount(for: .notReviewed)
    }

    private var reviewProgress: Double {
        guard allItemCount > 0 else { return 0 }
        return min(1, max(0, Double(reviewedItemCount) / Double(allItemCount)))
    }

    private var reviewPercentage: Int {
        Int((reviewProgress * 100).rounded())
    }

    private var primaryButtonTitle: String {
        if allItemCount == 0 {
            return "No media to review"
        }
        if notReviewedItemCount == 0 {
            return "Review all again"
        }
        return appState.lastDeletionSummary == nil ? "Start burning" : "Continue burning"
    }

    private var headline: some View {
        VStack(spacing: 7) {
            Text(notReviewedItemCount.formatted())
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text(notReviewedItemCount == 0 ? "all caught up" : "left to review")
                .font(.title2.weight(.semibold))

            Text(
                notReviewedItemCount == 0
                    ? "New photos will appear automatically."
                    : "Your bookmark keeps your place between cleanups."
            )
            .font(.subheadline)
            .foregroundStyle(BurnRollTheme.secondaryText)
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            notReviewedItemCount == 0
                ? "All caught up. No items left to review."
                : "\(notReviewedItemCount) items left to review."
        )
    }

    private var libraryProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 7) {
                    BurnRollSymbol(systemName: "bookmark.fill", size: 14, role: .photo)
                    Text("Library checkpoint")
                }
                .font(.subheadline.weight(.bold))

                Spacer()

                Text("\(reviewPercentage)% reviewed")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(BurnRollTheme.keep)
                    .contentTransition(.numericText())
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(BurnRollTheme.secondaryText.opacity(0.16))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.59, green: 0.80, blue: 0.20), BurnRollTheme.keep],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * reviewProgress)
                }
            }
            .frame(height: 12)
            .animation(.snappy(duration: 0.35), value: reviewProgress)

            HStack(spacing: 0) {
                progressMetric(
                    value: allItemCount,
                    label: "All items",
                    systemImage: "photo.stack.fill",
                    role: .photo
                )
                progressDivider
                progressMetric(
                    value: reviewedItemCount,
                    label: "Reviewed",
                    systemImage: "checkmark.seal.fill",
                    role: .keep
                )
                progressDivider
                progressMetric(
                    value: notReviewedItemCount,
                    label: "Not reviewed",
                    systemImage: "bookmark",
                    role: .burn
                )
            }
        }
        .padding(16)
        .background(
            BurnRollTheme.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(BurnRollTheme.keep.opacity(0.12), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Library checkpoint. \(allItemCount) total items, "
            + "\(reviewedItemCount) reviewed, \(notReviewedItemCount) not reviewed, "
            + "\(reviewPercentage) percent complete."
        )
    }

    private var progressDivider: some View {
        Rectangle()
            .fill(BurnRollTheme.secondaryText.opacity(0.16))
            .frame(width: 1, height: 38)
    }

    private func progressMetric(
        value: Int,
        label: String,
        systemImage: String,
        role: BurnRollSymbolRole
    ) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                BurnRollSymbol(systemName: systemImage, size: 11, role: role)
                Text(value.formatted())
                    .font(.subheadline.weight(.bold))
                    .contentTransition(.numericText())
            }

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(BurnRollTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
    }

    private func lastCleanupCard(_ summary: AppState.DeletionSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 7) {
                BurnRollSymbol(systemName: "clock.arrow.circlepath", size: 14, role: .keep)
                Text("Last cleanup")
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(BurnRollTheme.secondaryText)

            HStack(spacing: 0) {
                cleanupMetric(
                    value: summary.itemCount.formatted(),
                    label: summary.itemCount == 1 ? "item burned" : "items burned"
                )

                Divider()
                    .frame(height: 38)

                cleanupMetric(
                    value: summary.clearedBytes.formattedByteCount,
                    label: "potential space"
                )
            }
        }
        .padding(16)
        .background(BurnRollTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Last cleanup: \(summary.itemCount) items burned, approximately \(summary.clearedBytes.formattedByteCount) potentially recoverable"
        )
    }

    private func cleanupMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(BurnRollTheme.primaryText)
            Text(label)
                .font(.caption)
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
