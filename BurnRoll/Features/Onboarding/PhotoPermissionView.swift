import SwiftUI
import UIKit
@preconcurrency import Photos

struct PhotoPermissionView: View {
    @Environment(AppState.self) private var appState
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .fill(BurnRollTheme.surface)
                    .frame(width: 240, height: 240)
                    .shadow(color: BurnRollTheme.ember.opacity(0.16), radius: 30, y: 18)

                BurnRollIconTile(
                    systemName: "photo.badge.checkmark.fill",
                    role: .keep,
                    size: 120,
                    symbolSize: 58
                )
            }
            .accessibilityHidden(true)

            VStack(spacing: 14) {
                Text("Your memories stay yours.")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("BurnRoll processes your library on this iPhone. Photos access is needed to show items and delete only after you confirm.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BurnRollTheme.secondaryText)
            }

            PrivacyFootnote(alignment: .center)
                .padding(.horizontal, 12)

            if let errorMessage = appState.errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BurnRollTheme.burn)
                    .padding(14)
                    .background(BurnRollTheme.burn.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            }

            Spacer()

            if appState.authorizationStatus == .denied || appState.authorizationStatus == .restricted {
                PrimaryButton(title: String(localized: "Open Settings"), systemImage: "gear") {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }
            } else {
                PrimaryButton(
                    title: isRequesting ? String(localized: "Requesting Access…") : String(localized: "Allow Photos Access"),
                    systemImage: "photo.on.rectangle",
                    isEnabled: !isRequesting
                ) {
                    isRequesting = true
                    Task {
                        await appState.requestPhotoAccess()
                        isRequesting = false
                    }
                }
            }
        }
        .padding(24)
        .burnRollBackground()
        .task {
            #if DEBUG
            guard ScreenshotDemo.isActive else { return }
            guard appState.authorizationStatus == .notDetermined else { return }
            isRequesting = true
            await appState.requestPhotoAccess()
            isRequesting = false
            #endif
        }
    }
}
