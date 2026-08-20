import SwiftUI

struct StorageInsightsView: View {
    private static let showsMilestonesInFirstRelease = false

    let insights: AppState.StorageInsights
    let totalBurnCount: Int

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: columns, spacing: 10) {
                insightMetric(
                    value: insights.spaceRecovered.formattedByteCount,
                    label: "Space recovered",
                    systemImage: "internaldrive.fill",
                    role: .burn
                )
                insightMetric(
                    value: insights.photosBurned.formatted(),
                    label: "Photos burned",
                    systemImage: "photo.stack.fill",
                    role: .burn
                )
                insightMetric(
                    value: insights.videosRemoved.formatted(),
                    label: "Videos removed",
                    systemImage: "video.fill",
                    role: .photo
                )
                insightMetric(
                    value: streakValue,
                    label: "Cleanup streak",
                    systemImage: "flame.fill",
                    role: .keep
                )
            }

            if unclassifiedPreviousItems > 0 {
                Text(
                    "\(unclassifiedPreviousItems.formatted()) earlier \(unclassifiedPreviousItems == 1 ? "item is" : "items are") included in space recovered but predate photo/video tracking."
                )
                    .font(.caption2)
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if Self.showsMilestonesInFirstRelease {
                Divider()
                    .overlay(BurnRollTheme.primaryText.opacity(0.08))

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("MILESTONES")
                            .font(.caption2.weight(.bold))
                            .tracking(0.7)
                            .foregroundStyle(BurnRollTheme.secondaryText)

                        Spacer()

                        Text(progressMessage)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(BurnRollTheme.ember)
                            .multilineTextAlignment(.trailing)
                    }

                    LazyVGrid(columns: columns, spacing: 10) {
                        milestone(
                            value: "10",
                            label: "BURNS",
                            systemImage: "flame.fill",
                            isUnlocked: totalBurnCount >= 10,
                            frameStyle: .circle,
                            accessibilityProgress: "\(max(0, 10 - totalBurnCount)) more items"
                        )
                        milestone(
                            value: "100",
                            label: "BURNS",
                            systemImage: "flame.fill",
                            isUnlocked: totalBurnCount >= 100,
                            frameStyle: .circle,
                            accessibilityProgress: "\(max(0, 100 - totalBurnCount)) more items"
                        )
                        milestone(
                            value: "FIRST",
                            label: "BURN",
                            systemImage: "photo.on.rectangle.angled",
                            isUnlocked: totalBurnCount >= 1,
                            frameStyle: .hexagon,
                            accessibilityProgress: "Complete your first cleanup"
                        )
                        milestone(
                            value: "7 DAY",
                            label: "STREAK",
                            systemImage: "calendar",
                            isUnlocked: insights.cleanupStreak >= 7,
                            frameStyle: .hexagon,
                            accessibilityProgress: "\(max(0, 7 - insights.cleanupStreak)) more consecutive days"
                        )
                    }
                }
            }

            Text(
                "* Space is estimated. Items remain recoverable in Apple Photos’ Recently Deleted album for up to 30 days."
            )
                .font(.caption2)
                .foregroundStyle(BurnRollTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var streakValue: String {
        "\(insights.cleanupStreak.formatted()) \(insights.cleanupStreak == 1 ? "day" : "days")"
    }

    private var unclassifiedPreviousItems: Int {
        max(0, totalBurnCount - insights.photosBurned - insights.videosRemoved)
    }

    private var progressMessage: String {
        if totalBurnCount < 1 {
            return "Start with one"
        }
        if totalBurnCount < 10 {
            return "\(10 - totalBurnCount) to next badge"
        }
        if totalBurnCount < 100 {
            return "\(100 - totalBurnCount) to next badge"
        }
        if insights.cleanupStreak < 7 {
            return "Build a 7-day streak"
        }
        return "All unlocked"
    }

    private func insightMetric(
        value: String,
        label: String,
        systemImage: String,
        role: BurnRollSymbolRole
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            BurnRollIconTile(
                systemName: systemImage,
                role: role,
                size: 34,
                symbolSize: 14
            )

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .heavy))
                .foregroundStyle(BurnRollTheme.primaryText)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.70)
                .lineLimit(1)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BurnRollTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    BurnRollTheme.primaryText.opacity(0.070),
                    BurnRollTheme.primaryText.opacity(0.025)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 17, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(.white.opacity(0.055), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }

    private func milestone(
        value: String,
        label: String,
        systemImage: String,
        isUnlocked: Bool,
        frameStyle: MilestoneFrameStyle,
        accessibilityProgress: String
    ) -> some View {
        MilestoneBadge(
            value: value,
            label: label,
            systemImage: systemImage,
            isUnlocked: isUnlocked,
            frameStyle: frameStyle,
            accessibilityProgress: accessibilityProgress
        )
    }
}

private enum MilestoneFrameStyle {
    case circle
    case hexagon
}

private struct MilestoneBadge: View {
    let value: String
    let label: String
    let systemImage: String
    let isUnlocked: Bool
    let frameStyle: MilestoneFrameStyle
    let accessibilityProgress: String

    var body: some View {
        ZStack {
            MilestoneFrameShape(isCircle: frameStyle == .circle)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.88),
                            Color(red: 0.105, green: 0.095, blue: 0.085)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            MilestoneFrameShape(isCircle: frameStyle == .circle)
                .strokeBorder(
                    LinearGradient(
                        colors: isUnlocked
                            ? [BurnRollTheme.ember, BurnRollTheme.burn]
                            : [BurnRollTheme.secondaryText.opacity(0.45), BurnRollTheme.secondaryText.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )

            VStack(spacing: 2) {
                BurnRollSymbol(
                    systemName: isUnlocked ? systemImage : "lock.fill",
                    size: 14,
                    weight: .bold,
                    role: isUnlocked ? .burn : .neutral
                )

                Text(value)
                    .font(.system(size: value.count > 3 ? 13 : 19, weight: .black, design: .rounded))
                    .foregroundStyle(isUnlocked ? Color.white : Color.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(label)
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(isUnlocked ? BurnRollTheme.ember : BurnRollTheme.secondaryText)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .opacity(isUnlocked ? 1 : 0.56)
        .shadow(
            color: isUnlocked ? BurnRollTheme.burn.opacity(0.16) : .clear,
            radius: 9,
            y: 5
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(label) badge")
        .accessibilityValue(isUnlocked ? "Unlocked" : "Locked, \(accessibilityProgress)")
    }
}

private struct MilestoneFrameShape: InsettableShape {
    let isCircle: Bool
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        if isCircle {
            return Path(ellipseIn: rect)
        }

        var path = Path()
        let points = [
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.25),
            CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.75),
            CGPoint(x: rect.midX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.75),
            CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.25)
        ]
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> MilestoneFrameShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
