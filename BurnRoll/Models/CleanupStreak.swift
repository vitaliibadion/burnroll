import Foundation

public struct CleanupStreak: Equatable, Sendable {
    public private(set) var currentCount: Int
    public private(set) var lastCleanupDay: Date?

    public init(currentCount: Int = 0, lastCleanupDay: Date? = nil) {
        self.currentCount = max(0, currentCount)
        self.lastCleanupDay = lastCleanupDay
    }

    public mutating func recordCleanup(
        on date: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let cleanupDay = calendar.startOfDay(for: date)

        guard let lastCleanupDay else {
            currentCount = 1
            self.lastCleanupDay = cleanupDay
            return
        }

        let previousDay = calendar.startOfDay(for: lastCleanupDay)
        let dayGap = calendar.dateComponents(
            [.day],
            from: previousDay,
            to: cleanupDay
        ).day ?? 0

        switch dayGap {
        case 0:
            return
        case 1:
            currentCount += 1
            self.lastCleanupDay = cleanupDay
        case 2...:
            currentCount = 1
            self.lastCleanupDay = cleanupDay
        default:
            // Ignore a device clock moving backwards rather than corrupting the streak.
            return
        }
    }
}
