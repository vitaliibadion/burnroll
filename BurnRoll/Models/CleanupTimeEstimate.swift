import Foundation

public struct CleanupTimeEstimate: Equatable, Sendable {
    public static let maximumSeconds = 5 * 60

    public let photoCount: Int
    public let estimatedSeconds: Int

    public init?(photoCount: Int) {
        guard photoCount > 0 else { return nil }
        self.photoCount = photoCount
        estimatedSeconds = min(photoCount, Self.maximumSeconds)
    }

    public var durationPhrase: String {
        if estimatedSeconds >= Self.maximumSeconds {
            return "up to 5 minutes"
        }

        if estimatedSeconds < 60 {
            let unit = estimatedSeconds == 1 ? "second" : "seconds"
            return "about \(estimatedSeconds) \(unit)"
        }

        let minutes = estimatedSeconds / 60
        let seconds = estimatedSeconds % 60
        if seconds == 0 {
            let unit = minutes == 1 ? "minute" : "minutes"
            return "about \(minutes) \(unit)"
        }

        return "about \(minutes) min \(seconds) sec"
    }
}
