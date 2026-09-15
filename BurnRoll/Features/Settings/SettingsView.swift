import SwiftUI
import UIKit
@preconcurrency import Photos

struct SettingsView: View {
    private enum ReminderAlert: Identifiable {
        case consent
        case denied
        case failure(String)

        var id: String {
            switch self {
            case .consent: "consent"
            case .denied: "denied"
            case .failure: "failure"
            }
        }
    }

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(Haptics.preferenceKey) private var hapticsEnabled = true
    @State private var reminderAlert: ReminderAlert?
    @State private var isUpdatingReminder = false
    @State private var reminderSnapshot: PhotoLibraryService.ReminderLibrarySnapshot?
    @State private var photoThresholdDraft = Double(CleanupReminderService.defaultPhotoThreshold)
    @State private var selectedAppIcon = AppIconService.current
    @State private var isChangingAppIcon = false
    @State private var appIconErrorMessage: String?
    @State private var restoreAlertMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    CleanupCelebrationBanner(summary: appState.totalDeletionSummary)

                    settingsSection(title: String(localized: "Storage insights")) {
                        StorageInsightsView(
                            insights: appState.storageInsights,
                            totalBurnCount: appState.totalDeletionSummary.itemCount
                        )
                    }

                    settingsSection(title: String(localized: "Experience")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $hapticsEnabled) {
                                settingLabel(
                                    title: String(localized: "Haptic feedback"),
                                    subtitle: String(localized: "Feel decisions, undo, and successful deletion"),
                                    systemImage: "waveform.path"
                                )
                            }
                            .tint(BurnRollTheme.burn)
                            .onChange(of: hapticsEnabled) { _, enabled in
                                if enabled { Haptics.keep() }
                            }

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            appIconPicker

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Button {
                                appState.replayOnboarding()
                                dismiss()
                            } label: {
                                settingsRow(
                                    title: String(localized: "How to use BurnRoll"),
                                    subtitle: String(localized: "Replay the intro. Your reviews and Photos access stay as they are."),
                                    systemImage: "sparkles.rectangle.stack"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Button {
                                Task { await restorePurchases() }
                            } label: {
                                settingsRow(
                                    title: String(localized: "Restore purchases"),
                                    subtitle: String(localized: "Bring back a trial or plan bought with this Apple Account"),
                                    systemImage: "arrow.clockwise"
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(appState.subscriptions.isPurchasing)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Button {
                                Task { await redeemOfferCode() }
                            } label: {
                                settingsRow(
                                    title: String(localized: "Redeem code"),
                                    subtitle: String(localized: "Use an App Store offer code for BurnRoll Pro"),
                                    systemImage: "gift.fill"
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(appState.subscriptions.isPurchasing)
                        }
                    }

                    settingsSection(title: String(localized: "Reminders")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: cleanupReminderBinding) {
                                settingLabel(
                                    title: String(localized: "Smart reminder"),
                                    subtitle: appState.cleanupReminders.selectedCadenceDescription,
                                    systemImage: "bell.and.waves.left.and.right.fill"
                                )
                            }
                            .tint(BurnRollTheme.burn)
                            .disabled(isUpdatingReminder)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("REMIND ME WHEN")
                                    .font(.caption2.weight(.bold))
                                    .tracking(0.7)
                                    .foregroundStyle(BurnRollTheme.secondaryText)

                                ForEach(CleanupReminderService.SmartReminderRule.allCases) { rule in
                                    Button {
                                        guard rule != appState.cleanupReminders.rule else { return }
                                        Task { await updateReminderRule(rule) }
                                    } label: {
                                        HStack(spacing: 12) {
                                            BurnRollIconTile(
                                                systemName: rule.systemImage,
                                                role: rule == appState.cleanupReminders.rule ? .keep : .neutral,
                                                size: 34,
                                                symbolSize: 14
                                            )

                                            Text(selectionTitle(for: rule))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(BurnRollTheme.primaryText)
                                                .multilineTextAlignment(.leading)

                                            Spacer(minLength: 8)

                                            Image(
                                                systemName: rule == appState.cleanupReminders.rule
                                                    ? "checkmark.circle.fill"
                                                    : "circle"
                                            )
                                                .font(.title3.weight(.semibold))
                                                .foregroundStyle(
                                                    rule == appState.cleanupReminders.rule
                                                        ? BurnRollTheme.keep
                                                        : BurnRollTheme.secondaryText
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(
                                            rule == appState.cleanupReminders.rule
                                                ? BurnRollTheme.keep.opacity(0.10)
                                                : BurnRollTheme.primaryText.opacity(0.045),
                                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityAddTraits(
                                        rule == appState.cleanupReminders.rule ? .isSelected : []
                                    )
                                }
                            }
                            .disabled(!reminderControlsEnabled)
                            .opacity(reminderControlsEnabled ? 1 : 0.42)

                            if appState.cleanupReminders.rule == .photos500 {
                                photoThresholdSlider
                            }

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("NOTIFICATION PREVIEW")
                                        .font(.caption2.weight(.bold))
                                        .tracking(0.7)
                                        .foregroundStyle(BurnRollTheme.secondaryText)

                                    Spacer()

                                    if isUpdatingReminder {
                                        ProgressView()
                                            .controlSize(.small)
                                    } else {
                                        Text(appState.cleanupReminders.statusText.uppercased())
                                            .font(.caption2.weight(.heavy))
                                            .foregroundStyle(
                                                appState.cleanupReminders.isEnabled
                                                    ? BurnRollTheme.keep
                                                    : BurnRollTheme.secondaryText
                                            )
                                    }
                                }

                                Text(reminderPreview)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BurnRollTheme.primaryText)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(
                                    String(
                                        localized: "BurnRoll counts new photos when you open the app, and when your library changes while BurnRoll is open. iOS cannot watch the camera roll after you leave, so open BurnRoll after taking photos to get the reminder. The 30-day option still shows a scheduled date."
                                    )
                                )
                                    .font(.caption)
                                    .foregroundStyle(BurnRollTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .background(
                                BurnRollTheme.primaryText.opacity(0.055),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                        }
                    }

                    settingsSection(title: String(localized: "Photos access")) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                settingLabel(
                                    title: photoAccessTitle,
                                    subtitle: photoAccessDescription,
                                    systemImage: photoAccessSystemImage
                                )

                                Spacer(minLength: 8)

                                Text(photoAccessBadge)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(photoAccessColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(photoAccessColor.opacity(0.12), in: Capsule())
                            }

                            Button {
                                openPhotoSettings()
                            } label: {
                                HStack(spacing: 8) {
                                    BurnRollSymbol(
                                        systemName: "arrow.up.forward.app",
                                        size: 15,
                                        role: .neutral
                                    )
                                    Text(photoAccessButtonTitle)
                                }
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(BurnRollTheme.primaryText.opacity(0.07), in: Capsule())
                            }
                            .buttonStyle(.plain)

                            PrivacyFootnote()
                        }
                    }

                    settingsSection(title: String(localized: "Privacy & data")) {
                        VStack(alignment: .leading, spacing: 12) {
                            NavigationLink {
                                PrivacyPolicyView()
                            } label: {
                                settingsRow(
                                    title: String(localized: "Privacy policy"),
                                    subtitle: String(localized: "How BurnRoll uses Photos, on-device state, analytics, and notifications"),
                                    systemImage: "hand.raised.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Link(destination: BurnRollLegal.termsOfUseURL) {
                                settingsRow(
                                    title: String(localized: "Terms of Use"),
                                    subtitle: String(localized: "Apple’s standard licensed application end user license"),
                                    systemImage: "doc.text.fill"
                                )
                            }

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            RecentlyDeletedNotice()
                        }
                    }

                    settingsSection(title: String(localized: "Support")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                UIApplication.shared.open(BurnRollLegal.supportMailtoURL)
                            } label: {
                                settingsRow(
                                    title: String(localized: "Email us"),
                                    subtitle: BurnRollLegal.supportEmail,
                                    systemImage: "envelope.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Link(destination: BurnRollLegal.supportURL) {
                                settingsRow(
                                    title: String(localized: "Support on the web"),
                                    subtitle: String(localized: "Public contact page for App Review and users"),
                                    systemImage: "safari.fill"
                                )
                            }

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "BurnRoll \(BurnRollLegal.policyVersion)"))
                                    .font(.subheadline.weight(.semibold))
                                Text(BurnRollLegal.copyright)
                                    .font(.caption)
                                    .foregroundStyle(BurnRollTheme.secondaryText)
                            }
                            .padding(.leading, 6)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 14)
            }
            .scrollIndicators(.visible)
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .burnRollBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            appState.refreshPhotoAuthorizationStatus()
            photoThresholdDraft = Double(appState.cleanupReminders.photoThreshold)
            selectedAppIcon = AppIconService.current
            refreshReminderSnapshot()
            Task {
                await appState.cleanupReminders.refreshAuthorizationStatus()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            appState.refreshPhotoAuthorizationStatus()
            refreshReminderSnapshot()
            Task {
                await appState.cleanupReminders.refreshAuthorizationStatus()
                await appState.refreshCleanupReminder()
            }
        }
        .alert(
            String(localized: "Restore purchases"),
            isPresented: Binding(
                get: { restoreAlertMessage != nil },
                set: { if !$0 { restoreAlertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreAlertMessage ?? "")
        }
        .alert(item: $reminderAlert) { alert in
            switch alert {
            case .consent:
                Alert(
                    title: Text("Enable smart reminder?"),
                    message: Text(
                        String(
                            localized: "BurnRoll will schedule a local reminder for \(appState.cleanupReminders.selectedCadenceDescription). The prediction is calculated on-device and BurnRoll never uploads your photos."
                        )
                    ),
                    primaryButton: .default(Text("Continue")) {
                        Task { await enableCleanupReminder() }
                    },
                    secondaryButton: .cancel(Text("Not now"))
                )
            case .denied:
                Alert(
                    title: Text("Notifications are off"),
                    message: Text(
                        "Allow notifications for BurnRoll in iOS Settings to use cleanup reminders."
                    ),
                    primaryButton: .default(Text("Open Settings")) {
                        openNotificationSettings()
                    },
                    secondaryButton: .cancel()
                )
            case .failure(let message):
                Alert(
                    title: Text("Reminder couldn’t be scheduled"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var cleanupReminderBinding: Binding<Bool> {
        Binding(
            get: { appState.cleanupReminders.isEnabled },
            set: { shouldEnable in
                if shouldEnable {
                    reminderAlert = .consent
                } else {
                    appState.cleanupReminders.disable()
                    Haptics.threshold()
                }
            }
        )
    }

    private var reminderPreview: String {
        guard reminderSnapshot != nil else {
            return String(localized: "Checking recent photos…")
        }

        if appState.cleanupReminders.rule == .photos500 {
            let accumulated = appState.cleanupReminders.accumulatedNewPhotos
            return appState.cleanupReminders.notificationBody(
                photoCount: accumulated,
                usesSpecificCount: accumulated > 0
            )
        }

        return appState.cleanupReminders.notificationBody(
            photoCount: reminderSnapshot?.recentPhotoCount ?? 0
        )
    }

    private var reminderControlsEnabled: Bool {
        appState.cleanupReminders.isEnabled && !isUpdatingReminder
    }

    private var photoThresholdSlider: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PHOTO THRESHOLD")
                    .font(.caption2.weight(.bold))
                    .tracking(0.7)
                    .foregroundStyle(BurnRollTheme.secondaryText)

                Spacer()

                Text(L10n.photos(Int(photoThresholdDraft)))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(BurnRollTheme.ember)
                    .contentTransition(.numericText())
            }

            Slider(
                value: $photoThresholdDraft,
                in: Double(CleanupReminderService.minimumPhotoThreshold)...Double(CleanupReminderService.maximumPhotoThreshold),
                step: Double(CleanupReminderService.photoThresholdStep),
                onEditingChanged: { isEditing in
                    guard !isEditing else { return }
                    Task { await updatePhotoThreshold() }
                }
            )
            .tint(BurnRollTheme.burn)
            .disabled(!reminderControlsEnabled)
            .accessibilityLabel(String(localized: "Photo reminder threshold"))
            .accessibilityValue(L10n.photos(Int(photoThresholdDraft)))

            HStack {
                Text("20")
                Spacer()
                Text("500")
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(BurnRollTheme.secondaryText)
        }
        .padding(14)
        .background(
            BurnRollTheme.primaryText.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .opacity(reminderControlsEnabled ? 1 : 0.42)
    }

    private func restorePurchases() async {
        SuperwallService.register(SuperwallPlacement.restorePurchases)
        if await appState.subscriptions.restore() {
            restoreAlertMessage = String(localized: "Purchases restored.")
        } else if let message = appState.subscriptions.errorMessage {
            restoreAlertMessage = message
        }
    }

    private func redeemOfferCode() async {
        SuperwallService.register(SuperwallPlacement.redeemOfferCode)
        if await appState.subscriptions.redeemOfferCode() {
            restoreAlertMessage = String(localized: "Code redeemed. BurnRoll Pro is unlocked.")
        } else if let message = appState.subscriptions.errorMessage {
            restoreAlertMessage = message
        }
    }

    private func selectionTitle(
        for rule: CleanupReminderService.SmartReminderRule
    ) -> String {
        guard rule == .photos500 else { return rule.selectionTitle }
        return String(localized: "Camera roll grows by \(Int(photoThresholdDraft).formatted()) photos")
    }

    private func enableCleanupReminder() async {
        isUpdatingReminder = true
        defer { isUpdatingReminder = false }

        do {
            let rule = appState.cleanupReminders.rule
            let snapshot = appState.reminderSnapshot()
            reminderSnapshot = snapshot
            let enabled = try await appState.cleanupReminders.enable(
                rule: rule,
                snapshot: snapshot
            )
            if enabled {
                Haptics.keep()
            } else {
                reminderAlert = .denied
            }
        } catch {
            reminderAlert = .failure(error.localizedDescription)
        }
    }

    private func updateReminderRule(
        _ rule: CleanupReminderService.SmartReminderRule
    ) async {
        isUpdatingReminder = true
        defer { isUpdatingReminder = false }

        do {
            let snapshot = appState.reminderSnapshot()
            reminderSnapshot = snapshot
            let updated = try await appState.cleanupReminders.updateRule(
                rule,
                snapshot: snapshot
            )
            if updated {
                Haptics.threshold()
            } else {
                reminderAlert = .denied
            }
        } catch {
            reminderAlert = .failure(error.localizedDescription)
        }
    }

    private func updatePhotoThreshold() async {
        isUpdatingReminder = true
        defer { isUpdatingReminder = false }

        do {
            let snapshot = appState.reminderSnapshot()
            reminderSnapshot = snapshot
            let updated = try await appState.cleanupReminders.updatePhotoThreshold(
                Int(photoThresholdDraft),
                snapshot: snapshot
            )
            photoThresholdDraft = Double(appState.cleanupReminders.photoThreshold)
            if updated {
                Haptics.threshold()
            } else {
                reminderAlert = .denied
            }
        } catch {
            reminderAlert = .failure(error.localizedDescription)
        }
    }

    private func refreshReminderSnapshot() {
        guard PhotoAuthorizationService.hasUsableAccess else {
            reminderSnapshot = nil
            return
        }

        reminderSnapshot = appState.reminderSnapshot()
    }

    private var appIconPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            settingLabel(
                title: String(localized: "App icon"),
                subtitle: String(localized: "Choose how BurnRoll looks on your Home Screen. iOS will ask you to confirm."),
                systemImage: "app.fill"
            )

            HStack(spacing: 12) {
                ForEach(AppIconOption.allCases) { option in
                    Button {
                        Task { await selectAppIcon(option) }
                    } label: {
                        VStack(spacing: 8) {
                            Image(option.previewImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            selectedAppIcon == option
                                                ? BurnRollTheme.keep
                                                : Color.white.opacity(0.10),
                                            lineWidth: selectedAppIcon == option ? 3 : 1
                                        )
                                }
                                .shadow(color: .black.opacity(0.22), radius: 8, y: 4)

                            HStack(spacing: 4) {
                                if selectedAppIcon == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(BurnRollTheme.keep)
                                }
                                Text(option.title)
                                    .foregroundStyle(BurnRollTheme.primaryText)
                            }
                            .font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .disabled(isChangingAppIcon)
                    .accessibilityAddTraits(selectedAppIcon == option ? .isSelected : [])
                    .accessibilityLabel(String(localized: "\(option.title) app icon"))
                }
            }

            if let appIconErrorMessage {
                Text(appIconErrorMessage)
                    .font(.caption)
                    .foregroundStyle(BurnRollTheme.burn)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func selectAppIcon(_ option: AppIconOption) async {
        guard option != selectedAppIcon else { return }
        appIconErrorMessage = nil
        isChangingAppIcon = true
        defer { isChangingAppIcon = false }

        do {
            try await AppIconService.set(option)
            selectedAppIcon = AppIconService.current
        } catch {
            selectedAppIcon = AppIconService.current
            appIconErrorMessage = String(localized: "Couldn't change the Home Screen icon. Try again on a device.")
        }
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(BurnRollTheme.secondaryText)
                .padding(.leading, 6)

            content()
                .padding(16)
                .background(BurnRollTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func settingLabel(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            BurnRollIconTile(
                systemName: systemImage,
                role: .automatic,
                size: 38,
                symbolSize: 16
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func settingsRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            settingLabel(title: title, subtitle: subtitle, systemImage: systemImage)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(BurnRollTheme.secondaryText)
        }
    }

    private var photoAccessTitle: String {
        switch appState.authorizationStatus {
        case .authorized: String(localized: "Full library access")
        case .limited: String(localized: "Selected photos access")
        case .denied: String(localized: "Photos access is off")
        case .restricted: String(localized: "Photos access is restricted")
        case .notDetermined: String(localized: "Photos access not requested")
        @unknown default: String(localized: "Photos access unavailable")
        }
    }

    private var photoAccessDescription: String {
        switch appState.authorizationStatus {
        case .authorized: String(localized: "BurnRoll can show your full library")
        case .limited: String(localized: "Only photos selected in iOS are available")
        case .denied: String(localized: "Enable access to continue reviewing")
        case .restricted: String(localized: "This device prevents Photos access")
        case .notDetermined: String(localized: "Choose access when iOS asks")
        @unknown default: String(localized: "Check the app’s iOS settings")
        }
    }

    private var photoAccessSystemImage: String {
        switch appState.authorizationStatus {
        case .authorized: "photo.badge.checkmark.fill"
        case .limited: "photo.on.rectangle.angled"
        case .denied, .restricted: "photo.badge.exclamationmark"
        case .notDetermined: "photo.badge.plus"
        @unknown default: "photo"
        }
    }

    private var photoAccessBadge: String {
        switch appState.authorizationStatus {
        case .authorized: String(localized: "FULL")
        case .limited: String(localized: "LIMITED")
        case .denied: String(localized: "OFF")
        case .restricted: String(localized: "RESTRICTED")
        case .notDetermined: String(localized: "PENDING")
        @unknown default: String(localized: "UNKNOWN")
        }
    }

    private var photoAccessColor: Color {
        switch appState.authorizationStatus {
        case .authorized: BurnRollTheme.keep
        case .limited, .notDetermined: BurnRollTheme.ember
        case .denied, .restricted: BurnRollTheme.burn
        @unknown default: BurnRollTheme.secondaryText
        }
    }

    private var photoAccessButtonTitle: String {
        switch appState.authorizationStatus {
        case .authorized: String(localized: "Review Photos Access")
        case .limited: String(localized: "Manage Selected Photos")
        case .denied, .restricted: String(localized: "Open Photos Settings")
        case .notDetermined: String(localized: "Choose Photos Access")
        @unknown default: String(localized: "Open App Settings")
        }
    }

    private func openPhotoSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    private func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            openPhotoSettings()
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}

private struct CleanupCelebrationBanner: View {
    let summary: AppState.DeletionSummary

    var body: some View {
        BurnedPaperSpaceCard(
            recoveredBytes: summary.clearedBytes,
            itemCount: summary.itemCount
        )
        .frame(height: 238)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(
                localized: "Estimated recoverable space, approximately \(summary.clearedBytes.formattedByteCount) from \(summary.itemCount) items"
            )
        )
    }
}
