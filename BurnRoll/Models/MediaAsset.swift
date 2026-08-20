import Foundation

public struct MediaAsset: Identifiable, Hashable, Sendable {
    public enum MediaType: String, Hashable, Sendable {
        case photo = "Photo"
        case video = "Video"
    }

    public let id: String
    public let mediaType: MediaType
    public let creationDate: Date?
    public let estimatedByteSize: Int64
    public let duration: TimeInterval
    public let pixelWidth: Int
    public let pixelHeight: Int

    public init(
        id: String,
        mediaType: MediaType,
        creationDate: Date?,
        estimatedByteSize: Int64,
        duration: TimeInterval = 0,
        pixelWidth: Int = 0,
        pixelHeight: Int = 0
    ) {
        self.id = id
        self.mediaType = mediaType
        self.creationDate = creationDate
        self.estimatedByteSize = max(0, estimatedByteSize)
        self.duration = max(0, duration)
        self.pixelWidth = max(0, pixelWidth)
        self.pixelHeight = max(0, pixelHeight)
    }
}

public enum StorageEstimator {
    /// PhotoKit does not expose asset file size without loading resource data.
    /// This deliberately cheap estimate avoids downloading iCloud originals.
    public static func estimatedBytes(
        mediaType: MediaAsset.MediaType,
        pixelWidth: Int,
        pixelHeight: Int,
        duration: TimeInterval
    ) -> Int64 {
        switch mediaType {
        case .photo:
            let pixels = Int64(max(0, pixelWidth)) * Int64(max(0, pixelHeight))
            return max(250_000, Int64(Double(pixels) * 0.35))
        case .video:
            // Approximate a typical phone video at 8 Mbit/s.
            return max(1_000_000, Int64(max(0, duration) * 1_000_000))
        }
    }
}

