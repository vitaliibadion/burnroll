import UIKit

enum AppIconOption: String, CaseIterable, Identifiable {
    case classic
    case paper
    case ember

    var id: String { rawValue }

    /// `nil` restores the primary catalog icon.
    var alternateIconName: String? {
        switch self {
        case .classic: nil
        case .paper: "AppIconPaper"
        case .ember: "AppIconEmber"
        }
    }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .paper: "Paper"
        case .ember: "Ember"
        }
    }

    var previewImageName: String {
        switch self {
        case .classic: "AppIconPreviewClassic"
        case .paper: "AppIconPreviewPaper"
        case .ember: "AppIconPreviewEmber"
        }
    }

    static func matching(alternateIconName: String?) -> AppIconOption {
        allCases.first { $0.alternateIconName == alternateIconName } ?? .classic
    }
}

@MainActor
enum AppIconService {
    static var current: AppIconOption {
        AppIconOption.matching(alternateIconName: UIApplication.shared.alternateIconName)
    }

    static var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    static func set(_ option: AppIconOption) async throws {
        let name = option.alternateIconName
        guard UIApplication.shared.alternateIconName != name else { return }
        try await UIApplication.shared.setAlternateIconName(name)
    }
}
