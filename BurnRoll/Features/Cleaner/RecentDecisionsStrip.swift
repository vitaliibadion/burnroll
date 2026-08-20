import SwiftUI

struct RecentDecisionsStrip: View {
    let library: PhotoLibraryService
    let actions: [ReviewAction]
    let onOpen: (MediaAsset) -> Void

    private let maximumVisibleActions = 15

    private var recentActions: [ReviewAction] {
        Array(actions.suffix(maximumVisibleActions).reversed())
    }

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                BurnRollSymbol(
                    systemName: "clock.arrow.circlepath",
                    size: 15,
                    role: .neutral
                )
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Recent")
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(recentActions.count.formatted())
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(BurnRollTheme.secondaryText)
                        .contentTransition(.numericText())
                }
            }
            .frame(width: 66, alignment: .leading)

            Rectangle()
                .fill(BurnRollTheme.secondaryText.opacity(0.16))
                .frame(width: 1, height: 34)

            if recentActions.isEmpty {
                Text("Your latest choices will appear here")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 7) {
                        ForEach(recentActions) { action in
                            Button {
                                onOpen(action.asset)
                            } label: {
                                DecisionThumbnail(
                                    library: library,
                                    asset: action.asset,
                                    decision: action.decision,
                                    size: 44
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(accessibilityLabel(for: action))
                            .accessibilityHint("Opens this item so you can change the decision")
                            .transition(.scale(scale: 0.82).combined(with: .opacity))
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .leading)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 10, y: 5)
        .animation(.snappy(duration: 0.3), value: recentActions)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recent decisions, " + recentActions.count.formatted() + " shown")
    }

    private func accessibilityLabel(for action: ReviewAction) -> String {
        let decision = action.decision == .burn ? "marked to burn" : "kept"
        return "\(action.asset.mediaType.rawValue) \(decision)"
    }
}
