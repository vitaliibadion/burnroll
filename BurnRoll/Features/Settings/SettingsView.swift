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
    @State private var testStatusMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    CleanupCelebrationBanner(summary: appState.totalDeletionSummary)

                    settingsSection(title: "Storage insights") {
                        StorageInsightsView(
                            insights: appState.storageInsights,
                            totalBurnCount: appState.totalDeletionSummary.itemCount
                        )
                    }

                    settingsSection(title: "Experience") {
                        Toggle(isOn: $hapticsEnabled) {
                            settingLabel(
                                title: "Haptic feedback",
                                subtitle: "Feel decisions, undo, and successful deletion",
                                systemImage: "waveform.path"
                            )
                        }
                        .tint(BurnRollTheme.burn)
                        .onChange(of: hapticsEnabled) { _, enabled in
                            if enabled { Haptics.keep() }
                        }
                    }

                    settingsSection(title: "Reminders") {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: cleanupReminderBinding) {
                                settingLabel(
                                    title: "Smart reminder",
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
                                    "BurnRoll counts new photos when you open the app, and when your library changes while BurnRoll is open. "
                                    + "iOS cannot watch the camera roll after you leave, so open BurnRoll after taking photos to get the reminder. "
                                    + "The 30-day option still shows a scheduled date."
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

                            Button {
                                Task { await sendTestReminder() }
                            } label: {
                                HStack(spacing: 8) {
                                    BurnRollSymbol(systemName: "bell.badge.fill", size: 15, role: .burn)
                                    Text("Send test reminder")
                                    Spacer()
                                    Text("5 sec")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(BurnRollTheme.secondaryText)
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(BurnRollTheme.primaryText.opacity(0.07), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .disabled(!appState.cleanupReminders.isEnabled || isUpdatingReminder)
                            .opacity(appState.cleanupReminders.isEnabled ? 1 : 0.45)

                            if let testStatusMessage {
                                Text(testStatusMessage)
                                    .font(.caption)
                                    .foregroundStyle(BurnRollTheme.keep)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    settingsSection(title: "Photos access") {
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

                    settingsSection(title: "Privacy & data") {
                        VStack(alignment: .leading, spacing: 12) {
                            NavigationLink {
                                PrivacyPolicyView()
                            } label: {
                                settingsRow(
                                    title: "Privacy policy",
                                    subtitle: "How BurnRoll uses Photos, on-device state, analytics, and notifications",
                                    systemImage: "hand.raised.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            RecentlyDeletedNotice()
                        }
                    }

                    settingsSection(title: "Support") {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                UIApplication.shared.open(BurnRollLegal.supportMailtoURL)
                            } label: {
                                settingsRow(
                                    title: "Email \(BurnRollLegal.developerName)",
                                    subtitle: BurnRollLegal.supportEmail,
                                    systemImage: "envelope.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            Link(destination: BurnRollLegal.supportURL) {
                                settingsRow(
                                    title: "Support on the web",
                                    subtitle: "Public contact page for App Review and users",
                                    systemImage: "safari.fill"
                                )
                            }

                            Divider()
                                .overlay(BurnRollTheme.primaryText.opacity(0.08))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("BurnRoll \(BurnRollLegal.policyVersion)")
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
        .alert(item: $reminderAlert) { alert in
            switch alert {
            case .consent:
                Alert(
                    title: Text("Enable smart reminder?"),
                    message: Text(
                        "BurnRoll will schedule a local reminder for \(appState.cleanupReminders.selectedCadenceDescription.lowercased()). "
                        + "The prediction is calculated on-device and BurnRoll never uploads your photos."
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
                    testStatusMessage = nil
                    Haptics.threshold()
                }
            }
        )
    }

    private var reminderPreview: String {
        guard reminderSnapshot != nil else {
            return "Checking recent photos…"
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

                Text("\(Int(photoThresholdDraft).formatted()) photos")
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
            .accessibilityLabel("Photo reminder threshold")
            .accessibilityValue("\(Int(photoThresholdDraft)) photos")

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

    private func selectionTitle(
        for rule: CleanupReminderService.SmartReminderRule
    ) -> String {
        guard rule == .photos500 else { return rule.selectionTitle }
        return "Camera roll grows by \(Int(photoThresholdDraft).formatted()) photos"
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
                testStatusMessage = nil
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
            testStatusMessage = nil
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
            testStatusMessage = nil
            if updated {
                Haptics.threshold()
            } else {
                reminderAlert = .denied
            }
        } catch {
            reminderAlert = .failure(error.localizedDescription)
        }
    }

    private func sendTestReminder() async {
        isUpdatingReminder = true
        defer { isUpdatingReminder = false }

        do {
            let snapshot = appState.reminderSnapshot()
            reminderSnapshot = snapshot
            try await appState.cleanupReminders.scheduleTest(with: snapshot)
            testStatusMessage = "Test scheduled. Keep BurnRoll open or move it to the background; the banner will arrive in about 5 seconds."
            Haptics.keep()
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
        case .authorized: "Full library access"
        case .limited: "Selected photos access"
        case .denied: "Photos access is off"
        case .restricted: "Photos access is restricted"
        case .notDetermined: "Photos access not requested"
        @unknown default: "Photos access unavailable"
        }
    }

    private var photoAccessDescription: String {
        switch appState.authorizationStatus {
        case .authorized: "BurnRoll can show your full library"
        case .limited: "Only photos selected in iOS are available"
        case .denied: "Enable access to continue reviewing"
        case .restricted: "This device prevents Photos access"
        case .notDetermined: "Choose access when iOS asks"
        @unknown default: "Check the app’s iOS settings"
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
        case .authorized: "FULL"
        case .limited: "LIMITED"
        case .denied: "OFF"
        case .restricted: "RESTRICTED"
        case .notDetermined: "PENDING"
        @unknown default: "UNKNOWN"
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
        case .authorized: "Review Photos Access"
        case .limited: "Manage Selected Photos"
        case .denied, .restricted: "Open Photos Settings"
        case .notDetermined: "Choose Photos Access"
        @unknown default: "Open App Settings"
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

    private let paperInk = Color(red: 0.19, green: 0.095, blue: 0.055)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.065, blue: 0.045),
                            Color(red: 0.29, green: 0.095, blue: 0.045),
                            Color(red: 0.095, green: 0.052, blue: 0.060)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            AshPaperBurnArtwork()
                .allowsHitTesting(false)

            VStack(spacing: 9) {
                BurnRollSymbol(
                    systemName: "flame.fill",
                    size: 30,
                    weight: .bold,
                    role: .light
                )
                    .frame(width: 58, height: 58)
                    .background(.black.opacity(0.72), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(BurnRollTheme.ember.opacity(0.7), lineWidth: 1)
                    }
                    .shadow(color: BurnRollTheme.ember.opacity(0.32), radius: 10)

                Text("ESTIMATED SPACE RECOVERABLE")
                    .font(.caption.weight(.heavy))
                    .tracking(1.1)
                    .foregroundStyle(paperInk.opacity(0.70))

                Text(summary.clearedBytes.formattedByteCount)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .foregroundStyle(paperInk)
                    .contentTransition(.numericText())

                Text("From \(summary.itemCount.formatted()) \(summary.itemCount == 1 ? "item" : "items") moved to Recently Deleted")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(paperInk.opacity(0.78))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 34)
        }
        .frame(height: 238)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: BurnRollTheme.burn.opacity(0.18), radius: 24, y: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Estimated recoverable space, approximately \(summary.clearedBytes.formattedByteCount) from "
            + "\(summary.itemCount) items"
        )
    }
}
