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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            Capsule(style: .continuous)
                .fill(isEnabled ? BurnRollTheme.burn : Color.secondary.opacity(0.5))
        )
        .disabled(!isEnabled)
    }
}
