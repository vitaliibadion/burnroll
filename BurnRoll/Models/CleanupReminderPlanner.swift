import Foundation

public struct CleanupReminderPlanner: Sendable {
    public static let fiveGigabytes: Int64 = 5 * 1_024 * 1_024 * 1_024
    public static let predictionWindowDays = 30.0
    public static let maximumPredictionDays = 365.0
    public static let dueDeliveryDelay: TimeInterval = 5
    public static let imminentGraceInterval: TimeInterval = 120
    public static let minimumDeliveryDelay: TimeInterval = 60

    public enum Rule: String, Sendable {
        case photos500
        case storage5GB
        case days30
    }

    public struct Snapshot: Equatable, Sendable {
        public let totalPhotoCount: Int
        public let totalEstimatedBytes: Int64
        public let recentPhotoCount: Int
        public let recentEstimatedBytes: Int64
        public let capturedAt: Date

        public init(
            totalPhotoCount: Int,
            totalEstimatedBytes: Int64,
            recentPhotoCount: Int,
            recentEstimatedBytes: Int64,
            capturedAt: Date
        ) {
            self.totalPhotoCount = max(0, totalPhotoCount)
            self.totalEstimatedBytes = max(0, totalEstimatedBytes)
            self.recentPhotoCount = max(0, recentPhotoCount)
            self.recentEstimatedBytes = max(0, recentEstimatedBytes)
            self.capturedAt = capturedAt
        }
    }

    public struct Baseline: Equatable, Sendable {
        public let photoCount: Int
        public let estimatedBytes: Int64
        public let date: Date

        public init(photoCount: Int, estimatedBytes: Int64, date: Date) {
            self.photoCount = max(0, photoCount)
            self.estimatedBytes = max(0, estimatedBytes)
            self.date = date
        }
    }

    public struct Plan: Equatable, Sendable {
        public let fireDate: Date
        public let photoCountForBody: Int
        public let usesSpecificCount: Bool
        public let isDue: Bool

        public init(
            fireDate: Date,
            photoCountForBody: Int,
            usesSpecificCount: Bool,
            isDue: Bool = false
        ) {
            self.fireDate = fireDate
            self.photoCountForBody = max(0, photoCountForBody)
            self.usesSpecificCount = usesSpecificCount
            self.isDue = isDue
        }
    }

    public static func plan(
        rule: Rule,
        photoThreshold: Int,
        snapshot: Snapshot,
        baseline: Baseline,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Plan? {
        let now = snapshot.capturedAt
        let minimumDeliveryDate = now.addingTimeInterval(minimumDeliveryDelay)
        let dueDate = now.addingTimeInterval(dueDeliveryDelay)

        switch rule {
        case .days30:
            let target = calendar.date(byAdding: .day, value: 30, to: baseline.date)
                ?? baseline.date.addingTimeInterval(30 * 86_400)

            if target <= now {
                guard snapshot.recentPhotoCount > 0 else {
                    return nil
                }

                return Plan(
                    fireDate: dueDate,
                    photoCountForBody: snapshot.recentPhotoCount,
                    usesSpecificCount: true,
                    isDue: true
                )
            }

            return Plan(
                fireDate: max(target, minimumDeliveryDate),
                photoCountForBody: snapshot.recentPhotoCount,
                usesSpecificCount: snapshot.recentPhotoCount > 0
            )

        case .photos500:
            let accumulated = max(0, snapshot.totalPhotoCount - baseline.photoCount)
            if accumulated >= photoThreshold {
                return Plan(
                    fireDate: dueDate,
                    photoCountForBody: accumulated,
                    usesSpecificCount: true,
                    isDue: true
                )
            }

            let remaining = max(0, photoThreshold - accumulated)
            let recentDailyRate = Double(snapshot.recentPhotoCount) / predictionWindowDays
            let minimumDailyRate = Double(max(photoThreshold, 1)) / maximumPredictionDays
            return Plan(
                fireDate: max(
                    predictionDate(
                        remaining: Double(remaining),
                        dailyRate: max(recentDailyRate, minimumDailyRate),
                        relativeTo: now
                    ),
                    minimumDeliveryDate
                ),
                photoCountForBody: max(accumulated, snapshot.recentPhotoCount),
                usesSpecificCount: false
            )

        case .storage5GB:
            let accumulatedBytes = max(0, snapshot.totalEstimatedBytes - baseline.estimatedBytes)
            if accumulatedBytes >= fiveGigabytes {
                return Plan(
                    fireDate: dueDate,
                    photoCountForBody: max(0, snapshot.totalPhotoCount - baseline.photoCount),
                    usesSpecificCount: true,
                    isDue: true
                )
            }

            let remaining = max(0, fiveGigabytes - accumulatedBytes)
            let recentDailyRate = Double(snapshot.recentEstimatedBytes) / predictionWindowDays
            let minimumDailyRate = Double(fiveGigabytes) / maximumPredictionDays
            return Plan(
                fireDate: max(
                    predictionDate(
                        remaining: Double(remaining),
                        dailyRate: max(recentDailyRate, minimumDailyRate),
                        relativeTo: now
                    ),
                    minimumDeliveryDate
                ),
                photoCountForBody: max(0, snapshot.totalPhotoCount - baseline.photoCount),
                usesSpecificCount: false
            )
        }
    }

    public static func notificationBody(photoCount: Int, usesSpecificCount: Bool) -> String {
        if usesSpecificCount, let estimate = CleanupTimeEstimate(photoCount: photoCount) {
            let noun = photoCount == 1 ? "photo" : "photos"
            return "You have \(photoCount.formatted()) new \(noun). Want to clean them up? "
                + "Reviewing should take \(estimate.durationPhrase)."
        }

        return "New photos may be waiting. Open BurnRoll for a quick cleanup."
    }

    public static func shouldReplacePendingRequest(
        isDue: Bool,
        pendingFireDate: Date?,
        now: Date
    ) -> Bool {
        guard let pendingFireDate else { return true }
        guard isDue else { return true }

        let remaining = pendingFireDate.timeIntervalSince(now)
        return remaining > imminentGraceInterval || remaining < -1
    }

    private static func predictionDate(
        remaining: Double,
        dailyRate: Double,
        relativeTo date: Date
    ) -> Date {
        guard remaining > 0 else { return date.addingTimeInterval(minimumDeliveryDelay) }
        let days = min(
            maximumPredictionDays,
            max(1, ceil(remaining / max(dailyRate, .leastNonzeroMagnitude)))
        )
        return date.addingTimeInterval(days * 86_400)
    }
}
