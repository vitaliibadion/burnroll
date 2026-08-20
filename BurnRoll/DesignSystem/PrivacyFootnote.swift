import SwiftUI

struct PrivacyFootnote: View {
    var alignment: TextAlignment = .leading

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 4) {
            HStack(spacing: 6) {
                BurnRollSymbol(
                    systemName: "checkmark.shield.fill",
                    size: 13,
                    weight: .bold,
                    role: .keep
                )

                Text("100% ON-DEVICE PROCESSING")
                    .font(.caption.weight(.heavy))
                    .tracking(0.45)
                    .foregroundStyle(BurnRollTheme.keep)
            }

            Text("BurnRoll never uploads your photos to its servers.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BurnRollTheme.primaryText)

            Text("No photo contents in analytics.  •  No account required.")
                .font(.caption2.weight(.medium))
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .multilineTextAlignment(alignment)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            BurnRollTheme.keep.opacity(0.075),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(BurnRollTheme.keep.opacity(0.13), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "100 percent on-device photo processing. BurnRoll never uploads your photos to its servers. "
            + "No photo contents in analytics. No account required."
        )
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    private var frameAlignment: Alignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}
