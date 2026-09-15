import Foundation

enum L10n {
    static func items(_ count: Int) -> String {
        String(localized: "\(count) items")
    }

    static func photos(_ count: Int) -> String {
        String(localized: "\(count) photos")
    }
}

extension MediaAsset.MediaType {
    var localizedTitle: String {
        switch self {
        case .photo: String(localized: "Photo")
        case .video: String(localized: "Video")
        }
    }
}

extension CleanupTimeEstimate {
    var localizedDurationPhrase: String {
        if estimatedSeconds >= Self.maximumSeconds {
            return String(localized: "up to 5 minutes")
        }
        if estimatedSeconds < 60 {
            return String(localized: "about \(estimatedSeconds) seconds")
        }
        let minutes = estimatedSeconds / 60
        let seconds = estimatedSeconds % 60
        if seconds == 0 {
            return String(localized: "about \(minutes) minutes")
        }
        return String(localized: "about \(minutes) min \(seconds) sec")
    }
}
