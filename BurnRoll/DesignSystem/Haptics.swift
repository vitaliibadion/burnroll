import UIKit

@MainActor
enum Haptics {
    nonisolated static let preferenceKey = "hapticsEnabled"

    static var isEnabled: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: preferenceKey) != nil else { return true }
        return defaults.bool(forKey: preferenceKey)
    }

    static func threshold() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
    }

    static func keep() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
    }

    static func burn() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.9)
    }

    static func undo() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func deletionSucceeded() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
