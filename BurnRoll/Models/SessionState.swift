import Foundation

public struct SessionState: Equatable, Sendable {
    private struct UndoEntry: Equatable, Sendable {
        var action: ReviewAction
        let previousAction: ReviewAction?
        let previousHistoryIndex: Int?
    }

    public private(set) var currentIndex: Int
    public private(set) var burnQueue: [MediaAsset]
    public private(set) var reviewHistory: [ReviewAction]
    public private(set) var reviewedCount: Int
    public private(set) var estimatedBytes: Int64
    public private(set) var totalAssetCount: Int
    public private(set) var reviewStartedAt: Date?

    private var undoStack: [UndoEntry]

    public init(totalAssetCount: Int = 0) {
        currentIndex = 0
        burnQueue = []
        reviewHistory = []
        reviewedCount = 0
        estimatedBytes = 0
        self.totalAssetCount = max(0, totalAssetCount)
        reviewStartedAt = nil
        undoStack = []
    }

    public var lastAction: ReviewAction? {
        undoStack.last?.action
    }

    public var hasMoreAssets: Bool {
        currentIndex < totalAssetCount
    }

    public var remainingCount: Int {
        max(0, totalAssetCount - reviewedCount)
    }

    public var keptAssets: [MediaAsset] {
        reviewHistory.compactMap { action in
            action.decision == .keep ? action.asset : nil
        }
    }

    public func decision(forAssetID id: String) -> ReviewDecision? {
        reviewHistory.first(where: { $0.asset.id == id })?.decision
    }

    public mutating func reset(totalAssetCount: Int) {
        self = SessionState(totalAssetCount: totalAssetCount)
    }

    public mutating func beginReviewingSource(totalAssetCount: Int) {
        currentIndex = 0
        reviewedCount = 0
        self.totalAssetCount = max(0, totalAssetCount)
        undoStack.removeAll(keepingCapacity: true)
    }

    public mutating func beginReviewTiming(at date: Date) {
        guard reviewStartedAt == nil else { return }
        reviewStartedAt = date
    }

    @discardableResult
    public mutating func finishReviewTiming(at date: Date) -> TimeInterval {
        guard let reviewStartedAt else { return 0 }
        self.reviewStartedAt = nil
        return max(0, date.timeIntervalSince(reviewStartedAt))
    }

    public mutating func decide(_ decision: ReviewDecision, asset: MediaAsset) {
        guard hasMoreAssets else { return }

        let previousHistoryIndex = reviewHistory.firstIndex(where: { $0.asset.id == asset.id })
        let previousAction = previousHistoryIndex.map { reviewHistory[$0] }
        if let previousHistoryIndex {
            reviewHistory.remove(at: previousHistoryIndex)
        }

        let action = ReviewAction(
            asset: asset,
            decision: decision,
            indexBeforeAction: currentIndex
        )
        reviewHistory.append(action)
        undoStack.append(
            UndoEntry(
                action: action,
                previousAction: previousAction,
                previousHistoryIndex: previousHistoryIndex
            )
        )

        currentIndex += 1
        reviewedCount += 1
        rebuildBurnQueue()
    }

    @discardableResult
    public mutating func undoLastAction() -> ReviewAction? {
        guard let entry = undoStack.popLast() else { return nil }

        reviewHistory.removeAll { $0.asset.id == entry.action.asset.id }
        if let previousAction = entry.previousAction {
            let insertionIndex = min(
                entry.previousHistoryIndex ?? reviewHistory.endIndex,
                reviewHistory.endIndex
            )
            reviewHistory.insert(previousAction, at: insertionIndex)
        }

        currentIndex = entry.action.indexBeforeAction
        reviewedCount = max(0, reviewedCount - 1)
        rebuildBurnQueue()
        return entry.action
    }

    @discardableResult
    public mutating func changeDecision(
        forAssetID id: String,
        to decision: ReviewDecision
    ) -> ReviewAction? {
        guard let historyIndex = reviewHistory.firstIndex(where: { $0.asset.id == id }) else {
            return nil
        }

        let existingAction = reviewHistory[historyIndex]
        guard existingAction.decision != decision else { return existingAction }

        let changedAction = ReviewAction(
            asset: existingAction.asset,
            decision: decision,
            indexBeforeAction: existingAction.indexBeforeAction
        )
        reviewHistory[historyIndex] = changedAction

        if let undoIndex = undoStack.lastIndex(where: { $0.action.asset.id == id }) {
            undoStack[undoIndex].action = changedAction
        }

        rebuildBurnQueue()
        return changedAction
    }

    @discardableResult
    public mutating func removeFromBurnQueue(id: String) -> MediaAsset? {
        guard
            let action = reviewHistory.first(where: { $0.asset.id == id }),
            action.decision == .burn
        else {
            return nil
        }

        _ = changeDecision(forAssetID: id, to: .keep)
        return action.asset
    }

    @discardableResult
    public mutating func completeDeletion(ids: Set<String>) -> [MediaAsset] {
        let deleted = burnQueue.filter { ids.contains($0.id) }
        guard !deleted.isEmpty else { return [] }

        reviewHistory.removeAll { ids.contains($0.asset.id) }
        undoStack.removeAll { ids.contains($0.action.asset.id) }
        rebuildBurnQueue()
        return deleted
    }

    public mutating func discardUnavailableAssets(ids: Set<String>) {
        guard !ids.isEmpty else { return }

        reviewHistory.removeAll { ids.contains($0.asset.id) }
        undoStack.removeAll { ids.contains($0.action.asset.id) }
        rebuildBurnQueue()
    }

    private mutating func rebuildBurnQueue() {
        burnQueue = reviewHistory.compactMap { action in
            action.decision == .burn ? action.asset : nil
        }
        estimatedBytes = burnQueue.reduce(0) { $0 + $1.estimatedByteSize }
    }

    #if DEBUG
    mutating func seedScreenshotHistory(
        decisions: [(MediaAsset, ReviewDecision)],
        estimatedBytesOverride: Int64? = nil
    ) {
        reviewHistory = decisions.enumerated().map { index, pair in
            ReviewAction(asset: pair.0, decision: pair.1, indexBeforeAction: index)
        }
        reviewedCount = reviewHistory.count
        currentIndex = 0
        rebuildBurnQueue()
        if let estimatedBytesOverride {
            estimatedBytes = estimatedBytesOverride
        }
    }
    #endif
}
