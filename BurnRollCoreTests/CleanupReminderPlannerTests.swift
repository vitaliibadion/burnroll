import Foundation
import Testing
@testable import BurnRollCore

@Suite("Cleanup reminder planner")
struct CleanupReminderPlannerTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private let now = Date(timeIntervalSince1970: 1_787_140_800)

    @Test("Photo-count rule fires immediately after the threshold is reached")
    func photoThresholdReachedSchedulesSoon() {
        let plan = CleanupReminderPlanner.plan(
            rule: .photos500,
            photoThreshold: 20,
            snapshot: snapshot(totalPhotoCount: 120, recentPhotoCount: 0),
            baseline: baseline(photoCount: 100),
            calendar: calendar
        )

        #expect(plan?.usesSpecificCount == true)
        #expect(plan?.photoCountForBody == 20)
        #expect(plan?.isDue == true)
        #expect(plan?.fireDate == now.addingTimeInterval(5))
    }

    @Test("Photo-count rule still schedules when recent photos are zero")
    func photoThresholdSchedulesWithoutRecentPhotos() {
        let plan = CleanupReminderPlanner.plan(
            rule: .photos500,
            photoThreshold: 20,
            snapshot: snapshot(totalPhotoCount: 105, recentPhotoCount: 0),
            baseline: baseline(photoCount: 100),
            calendar: calendar
        )

        #expect(plan != nil)
        #expect(plan?.usesSpecificCount == false)
        #expect(plan?.fireDate != nil)
    }

    @Test("Monthly reminder is skipped when it is due and there are no recent photos")
    func monthlyReminderSkipsEmptyDueWindow() {
        let plan = CleanupReminderPlanner.plan(
            rule: .days30,
            photoThreshold: 20,
            snapshot: snapshot(totalPhotoCount: 100, recentPhotoCount: 0),
            baseline: baseline(photoCount: 100, date: now.addingTimeInterval(-31 * 86_400)),
            calendar: calendar
        )

        #expect(plan == nil)
    }

    @Test("Monthly reminder still schedules a future check-in with generic copy")
    func monthlyReminderSchedulesFutureCheckIn() {
        let plan = CleanupReminderPlanner.plan(
            rule: .days30,
            photoThreshold: 20,
            snapshot: snapshot(totalPhotoCount: 100, recentPhotoCount: 0),
            baseline: baseline(photoCount: 100, date: now),
            calendar: calendar
        )

        #expect(plan?.usesSpecificCount == false)
        #expect(plan?.photoCountForBody == 0)
        #expect(plan?.fireDate != nil)
    }

    @Test("Notification copy never includes photo identifiers")
    func notificationCopyUsesCountsOnly() {
        let specific = CleanupReminderPlanner.notificationBody(
            photoCount: 20,
            usesSpecificCount: true
        )
        let generic = CleanupReminderPlanner.notificationBody(
            photoCount: 0,
            usesSpecificCount: false
        )

        #expect(specific.contains("20"))
        #expect(specific.contains("Want to clean them up?"))
        #expect(!specific.contains("/"))
        #expect(generic.contains("Open BurnRoll"))
        #expect(!generic.contains("/"))
    }

    @Test("A due reminder does not replace an already-imminent pending request")
    func dueReminderKeepsImminentPendingRequest() {
        let keep = CleanupReminderPlanner.shouldReplacePendingRequest(
            isDue: true,
            pendingFireDate: now.addingTimeInterval(4),
            now: now
        )
        let replaceGuess = CleanupReminderPlanner.shouldReplacePendingRequest(
            isDue: true,
            pendingFireDate: now.addingTimeInterval(30 * 86_400),
            now: now
        )

        #expect(keep == false)
        #expect(replaceGuess == true)
    }

    private func snapshot(
        totalPhotoCount: Int,
        recentPhotoCount: Int
    ) -> CleanupReminderPlanner.Snapshot {
        CleanupReminderPlanner.Snapshot(
            totalPhotoCount: totalPhotoCount,
            totalEstimatedBytes: 0,
            recentPhotoCount: recentPhotoCount,
            recentEstimatedBytes: 0,
            capturedAt: now
        )
    }

    private func baseline(
        photoCount: Int,
        date: Date? = nil
    ) -> CleanupReminderPlanner.Baseline {
        CleanupReminderPlanner.Baseline(
            photoCount: photoCount,
            estimatedBytes: 0,
            date: date ?? now
        )
    }
}
