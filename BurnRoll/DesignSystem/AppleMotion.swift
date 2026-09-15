import SwiftUI

enum AppleMotion {
    static func spring(
        response: Double,
        dampingRatio: Double,
        initialVelocity: CGFloat = 0
    ) -> Animation {
        let omega = (2 * Double.pi) / max(response, 0.01)
        return .interpolatingSpring(
            mass: 1,
            stiffness: omega * omega,
            damping: 2 * dampingRatio * omega,
            initialVelocity: initialVelocity
        )
    }

    static func rubberband(
        _ overshoot: CGFloat,
        dimension: CGFloat,
        constant: CGFloat = 0.55
    ) -> CGFloat {
        let size = max(dimension, 1)
        return (overshoot * size * constant) / (size + constant * abs(overshoot))
    }

    static func relativeVelocity(
        gestureVelocity: CGFloat,
        from current: CGFloat,
        to target: CGFloat
    ) -> CGFloat {
        let remaining = target - current
        guard abs(remaining) > 0.5 else { return 0 }
        return gestureVelocity / remaining
    }
}

struct PressableButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
