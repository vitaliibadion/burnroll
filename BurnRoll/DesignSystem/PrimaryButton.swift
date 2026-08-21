import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    BurnRollSymbol(
                        systemName: systemImage,
                        size: 17,
                        weight: .bold,
                        role: .light
                    )
                }
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                Capsule(style: .continuous)
                    .fill(isEnabled ? BurnRollTheme.burn : Color.secondary.opacity(0.5))
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
