import SwiftUI

enum BurnRollSymbolRole: Equatable {
    case automatic
    case burn
    case keep
    case photo
    case neutral
    case light
    case warning
}

struct BurnRollSymbol: View {
    let systemName: String
    var size: CGFloat = 18
    var weight: Font.Weight = .semibold
    var role: BurnRollSymbolRole = .automatic

    var body: some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: size, weight: weight))
            .foregroundStyle(foregroundStyle)
            .accessibilityHidden(true)
    }

    private var foregroundStyle: AnyShapeStyle {
        switch resolvedRole {
        case .burn, .photo:
            AnyShapeStyle(
                LinearGradient(
                    colors: [BurnRollTheme.ember, BurnRollTheme.burn],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .keep:
            AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.59, green: 0.80, blue: 0.20), BurnRollTheme.keep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .warning:
            AnyShapeStyle(Color(red: 1.0, green: 0.27, blue: 0.30))
        case .light:
            AnyShapeStyle(Color.white)
        case .neutral, .automatic:
            AnyShapeStyle(BurnRollTheme.secondaryText)
        }
    }

    private var resolvedRole: BurnRollSymbolRole {
        guard role == .automatic else { return role }

        if systemName.contains("flame")
            || systemName.contains("trash")
            || systemName.contains("waveform")
            || systemName.contains("sparkles")
            || systemName.contains("bolt")
            || systemName.contains("calendar")
            || systemName.contains("iphone") {
            return .burn
        }
        if systemName.contains("heart")
            || systemName.contains("checkmark")
            || systemName.contains("shield")
            || systemName.contains("lock") {
            return .keep
        }
        if systemName.contains("photo")
            || systemName.contains("video")
            || systemName.contains("camera")
            || systemName.contains("rectangle.stack") {
            return .photo
        }
        if systemName.contains("exclamationmark") {
            return .warning
        }
        return .neutral
    }
}

struct BurnRollIconTile: View {
    let systemName: String
    var role: BurnRollSymbolRole = .automatic
    var size: CGFloat = 44
    var symbolSize: CGFloat = 19
    var isSelected = false

    var body: some View {
        BurnRollSymbol(
            systemName: systemName,
            size: symbolSize,
            weight: .bold,
            role: isSelected ? .light : role
        )
        .frame(width: size, height: size)
        .background(tileBackground)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .strokeBorder(.white.opacity(isSelected ? 0.18 : 0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
        .accessibilityHidden(true)
    }

    private var tileBackground: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [BurnRollTheme.ember, BurnRollTheme.burn],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(
            LinearGradient(
                colors: [Color(red: 0.13, green: 0.125, blue: 0.12), Color(red: 0.055, green: 0.05, blue: 0.047)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct BurnRollBrandMark: View {
    var size: CGFloat = 104

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.14, green: 0.135, blue: 0.13), Color(red: 0.045, green: 0.041, blue: 0.039)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            BurnRollSymbol(
                systemName: "flame.fill",
                size: size * 0.58,
                weight: .black,
                role: .burn
            )
            .offset(y: -size * 0.08)

            Image(systemName: "photo.stack.fill")
                .symbolRenderingMode(.monochrome)
                .font(.system(size: size * 0.35, weight: .black))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.55), radius: 3, y: 2)
                .offset(y: size * 0.19)
                .accessibilityHidden(true)
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .strokeBorder(.white.opacity(0.09), lineWidth: 1)
        }
        .shadow(color: BurnRollTheme.burn.opacity(0.20), radius: size * 0.18, y: size * 0.09)
        .accessibilityHidden(true)
    }
}
