#if DEBUG
import Foundation

enum ScreenshotDemo {
    enum Scene: String {
        case cleaner
        case keep
        case burn
        case review
        case welcome
        case storage
        case privacy
        case complete
    }

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-ScreenshotDemo")
    }

    static var scene: Scene {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let index = arguments.firstIndex(of: "-ScreenshotScene"),
            index + 1 < arguments.count,
            let scene = Scene(rawValue: arguments[index + 1])
        else {
            return .cleaner
        }
        return scene
    }

    /// Card drag used for Keep / Burn marketing frames.
    /// Stay well under `commitThreshold` so the photo still fills the deck
    /// and the KEEP / BURN capsule remains fully on-screen.
    static var posedCardOffset: CGFloat {
        switch scene {
        case .keep: 58
        case .burn: -58
        default: 0
        }
    }

    static var shouldOpenReview: Bool {
        scene == .review
    }

    static var shouldOpenSettings: Bool {
        scene == .storage
    }

    static var shouldShowWelcome: Bool {
        scene == .welcome || scene == .privacy
    }

    static var shouldShowCleaningComplete: Bool {
        scene == .complete
    }
}
#endif
