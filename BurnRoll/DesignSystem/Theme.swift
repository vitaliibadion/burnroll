import SwiftUI
import UIKit

enum BurnRollTheme {
    static let background = Color(
        light: UIColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1),
        dark: UIColor(red: 0.055, green: 0.05, blue: 0.045, alpha: 1)
    )

    static let surface = Color(
        light: UIColor(red: 1, green: 0.99, blue: 0.96, alpha: 1),
        dark: UIColor(red: 0.12, green: 0.11, blue: 0.10, alpha: 1)
    )

    static let primaryText = Color(
        light: UIColor(red: 0.12, green: 0.105, blue: 0.09, alpha: 1),
        dark: UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1)
    )

    static let secondaryText = Color(
        light: UIColor(red: 0.39, green: 0.35, blue: 0.31, alpha: 1),
        dark: UIColor(red: 0.72, green: 0.69, blue: 0.64, alpha: 1)
    )

    static let burn = Color(red: 0.96, green: 0.27, blue: 0.08)
    static let ember = Color(red: 1.0, green: 0.52, blue: 0.08)
    static let keep = Color(red: 0.16, green: 0.66, blue: 0.36)
}

private extension Color {
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

struct BurnRollBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(BurnRollTheme.primaryText)
            .background(BurnRollTheme.background.ignoresSafeArea())
    }
}

extension View {
    func burnRollBackground() -> some View {
        modifier(BurnRollBackground())
    }
}
