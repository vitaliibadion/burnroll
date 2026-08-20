import Foundation
import Testing
@testable import BurnRollCore

@Suite("Session state")
struct SessionStateTests {
    @Test("Cleanup streak advances once per consecutive day")
    func cleanupStreakAdvancesOnConsecutiveDays() {
        let calendar = utcCalendar
        var streak = CleanupStreak()

        streak.recordCleanup(on: date(year: 2026, month: 8, day: 10, hour: 9), calendar: calendar)
        streak.recordCleanup(on: date(year: 2026, month: 8, day: 10, hour: 18), calendar: calendar)
        #expect(streak.currentCount == 1)

        streak.recordCleanup(on: date(year: 2026, month: 8, day: 11, hour: 8), calendar: calendar)
        #expect(streak.currentCount == 2)
    }

    @Test("Cleanup streak resets after a missed day")
    func cleanupStreakResetsAfterGap() {
        let calendar = utcCalendar
        var streak = CleanupStreak(
            currentCount: 6,
            lastCleanupDay: date(year: 2026, month: 8, day: 10)
        )

        streak.recordCleanup(on: date(year: 2026, month: 8, day: 13), calendar: calendar)

        #expect(streak.currentCount == 1)
    }

    @Test("Switching sources resets progress but preserves decision history")
    func switchingSourcesPreservesDecisionHistory() {
        let burned = makeAsset(id: "burned", bytes: 12_000)
        let kept = makeAsset(id: "kept", bytes: 8_000)
        var state = SessionState(totalAssetCount: 4)
        state.decide(.burn, asset: burned)
        state.decide(.keep, asset: kept)

        state.beginReviewingSource(totalAssetCount: 2)

        #expect(state.currentIndex == 0)
        #expect(state.reviewedCount == 0)
        #expect(state.remainingCount == 2)
        #expect(state.lastAction == nil)
        #expect(state.burnQueue == [burned])
        #expect(state.keptAssets == [kept])
        #expect(state.reviewHistory.map(\.asset) == [burned, kept])
        #expect(state.estimatedBytes == 12_000)
    }

    @Test("Review timing spans the session and finishes only once")
    func reviewTimingSpansSession() {
        var state = SessionState(totalAssetCount: 3)
        let start = Date(timeIntervalSince1970: 1_000)

        state.beginReviewTiming(at: start)
        state.beginReviewTiming(at: start.addingTimeInterval(15))
        state.beginReviewingSource(totalAssetCount: 2)

        #expect(state.reviewStartedAt == start)
        #expect(state.finishReviewTiming(at: start.addingTimeInterval(74)) == 74)
        #expect(state.reviewStartedAt == nil)
        #expect(state.finishReviewTiming(at: start.addingTimeInterval(100)) == 0)
    }

    @Test("Remaining count tracks review progress")
    func remainingCountTracksReviewProgress() {
        var state = SessionState(totalAssetCount: 3)

        #expect(state.remainingCount == 3)

        state.decide(.keep, asset: makeAsset(id: "one", bytes: 1))
        #expect(state.reviewedCount == 1)
        #expect(state.remainingCount == 2)

        state.undoLastAction()
        #expect(state.remainingCount == 3)
    }

    @Test("Burn adds the asset to the queue and estimate")
    func burnAddsAssetToQueueAndStorageEstimate() {
        let asset = makeAsset(id: "one", bytes: 12_000)
        var state = SessionState(totalAssetCount: 2)

        state.decide(.burn, asset: asset)

        #expect(state.currentIndex == 1)
        #expect(state.reviewedCount == 1)
        #expect(state.burnQueue == [asset])
        #expect(state.estimatedBytes == 12_000)
    }

    @Test("Keep never adds an asset to the burn queue")
    func keepDoesNotAddAssetToBurnQueue() {
        var state = SessionState(totalAssetCount: 1)

        state.decide(.keep, asset: makeAsset(id: "one", bytes: 12_000))

        #expect(state.currentIndex == 1)
        #expect(state.reviewedCount == 1)
        #expect(state.burnQueue.isEmpty)
        #expect(state.estimatedBytes == 0)
    }

    @Test("Undoing burn restores the index, queue, and estimate")
    func undoBurnRestoresIndexAndQueue() {
        let asset = makeAsset(id: "one", bytes: 12_000)
        var state = SessionState(totalAssetCount: 3)
        state.decide(.burn, asset: asset)

        let undoneAction = state.undoLastAction()

        #expect(undoneAction?.asset == asset)
        #expect(state.currentIndex == 0)
        #expect(state.reviewedCount == 0)
        #expect(state.burnQueue.isEmpty)
        #expect(state.estimatedBytes == 0)
        #expect(state.lastAction == nil)
    }

    @Test("Undoing keep does not change an existing burn queue")
    func undoKeepRestoresIndexWithoutChangingExistingQueue() {
        let burned = makeAsset(id: "burned", bytes: 5_000)
        let kept = makeAsset(id: "kept", bytes: 9_000)
        var state = SessionState(totalAssetCount: 3)
        state.decide(.burn, asset: burned)
        state.decide(.keep, asset: kept)

        state.undoLastAction()

        #expect(state.currentIndex == 1)
        #expect(state.reviewedCount == 1)
        #expect(state.burnQueue == [burned])
        #expect(state.estimatedBytes == 5_000)
    }

    @Test("Undo walks backward through multiple decisions")
    func undoSupportsMultipleLevels() {
        let first = makeAsset(id: "one", bytes: 10)
        let second = makeAsset(id: "two", bytes: 20)
        let third = makeAsset(id: "three", bytes: 30)
        var state = SessionState(totalAssetCount: 3)
        state.decide(.burn, asset: first)
        state.decide(.keep, asset: second)
        state.decide(.burn, asset: third)

        #expect(state.undoLastAction()?.asset == third)
        #expect(state.undoLastAction()?.asset == second)
        #expect(state.currentIndex == 1)
        #expect(state.reviewedCount == 1)
        #expect(state.reviewHistory.map(\.asset) == [first])
        #expect(state.burnQueue == [first])
        #expect(state.estimatedBytes == 10)

        #expect(state.undoLastAction()?.asset == first)
        #expect(state.undoLastAction() == nil)
        #expect(state.currentIndex == 0)
    }

    @Test("Removing a queued asset recalculates the estimate")
    func removingQueuedAssetRecalculatesEstimate() {
        let first = makeAsset(id: "first", bytes: 10)
        let second = makeAsset(id: "second", bytes: 20)
        var state = SessionState(totalAssetCount: 2)
        state.decide(.burn, asset: first)
        state.decide(.burn, asset: second)

        state.removeFromBurnQueue(id: first.id)

        #expect(state.burnQueue == [second])
        #expect(state.decision(forAssetID: first.id) == .keep)
        #expect(state.estimatedBytes == 20)
    }

    @Test("Changing Keep to Burn updates the queue and estimate")
    func changingKeepToBurnUpdatesQueue() {
        let asset = makeAsset(id: "one", bytes: 12_000)
        var state = SessionState(totalAssetCount: 1)
        state.decide(.keep, asset: asset)

        state.changeDecision(forAssetID: asset.id, to: .burn)

        #expect(state.decision(forAssetID: asset.id) == .burn)
        #expect(state.keptAssets.isEmpty)
        #expect(state.burnQueue == [asset])
        #expect(state.estimatedBytes == 12_000)
    }

    @Test("Changing Burn to Keep removes the asset from deletion")
    func changingBurnToKeepUpdatesQueue() {
        let asset = makeAsset(id: "one", bytes: 12_000)
        var state = SessionState(totalAssetCount: 1)
        state.decide(.burn, asset: asset)

        state.changeDecision(forAssetID: asset.id, to: .keep)

        #expect(state.decision(forAssetID: asset.id) == .keep)
        #expect(state.keptAssets == [asset])
        #expect(state.burnQueue.isEmpty)
        #expect(state.estimatedBytes == 0)
    }

    @Test("Storage estimates are deterministic")
    func storageEstimatorIsStable() {
        #expect(
            StorageEstimator.estimatedBytes(
                mediaType: .photo,
                pixelWidth: 4_000,
                pixelHeight: 3_000,
                duration: 0
            ) == 4_200_000
        )
        #expect(
            StorageEstimator.estimatedBytes(
                mediaType: .video,
                pixelWidth: 1_920,
                pixelHeight: 1_080,
                duration: 10
            ) == 10_000_000
        )
    }

    @Test("Completed deletion only removes confirmed identifiers")
    func completedDeletionOnlyRemovesConfirmedAssets() {
        let first = makeAsset(id: "first", bytes: 10)
        let second = makeAsset(id: "second", bytes: 20)
        var state = SessionState(totalAssetCount: 2)
        state.decide(.burn, asset: first)
        state.decide(.burn, asset: second)

        let deleted = state.completeDeletion(ids: [first.id])

        #expect(deleted == [first])
        #expect(state.burnQueue == [second])
        #expect(state.estimatedBytes == 20)
    }

    @Test("Unavailable assets leave the queue without being counted as deleted")
    func unavailableAssetsAreDiscardedFromQueue() {
        let unavailable = makeAsset(id: "unavailable", bytes: 10)
        let available = makeAsset(id: "available", bytes: 20)
        var state = SessionState(totalAssetCount: 2)
        state.decide(.burn, asset: unavailable)
        state.decide(.burn, asset: available)

        state.discardUnavailableAssets(ids: [unavailable.id])
        let deleted = state.completeDeletion(ids: [available.id])

        #expect(deleted == [available])
        #expect(state.burnQueue.isEmpty)
        #expect(state.estimatedBytes == 0)
    }

    private func makeAsset(id: String, bytes: Int64) -> MediaAsset {
        MediaAsset(
            id: id,
            mediaType: .photo,
            creationDate: nil,
            estimatedByteSize: bytes
        )
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12
    ) -> Date {
        utcCalendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour
            )
        )!
    }
}
