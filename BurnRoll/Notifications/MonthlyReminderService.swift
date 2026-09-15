import Foundation
import Observation
@preconcurrency import UserNotifications

@MainActor
@Observable
final class CleanupReminderService {
    enum SmartReminderRule: String, CaseIterable, Identifiable, Sendable {
        case photos500
        case storage5GB
        case days30

        var id: String { rawValue }

        var title: String {
            switch self {
            case .photos500: String(localized: "Photo count")
            case .storage5GB: String(localized: "5 GB")
            case .days30: String(localized: "30 days")
            }
        }

        var selectionTitle: String {
            switch self {
            case .photos500: String(localized: "Camera roll grows by a photo count")
            case .storage5GB: String(localized: "Camera roll grows by about 5 GB")
            case .days30: String(localized: "30 days have passed")
            }
        }

        var cadenceDescription: String {
            switch self {
            case .photos500: String(localized: "A selected number of new photos")
            case .storage5GB: String(localized: "Around 5 GB of new media")
            case .days30: String(localized: "30 days after your last check-in")
            }
        }

        var systemImage: String {
            switch self {
            case .photos500: "photo.stack.fill"
            case .storage5GB: "externaldrive.fill"
            case .days30: "calendar.badge.clock"
            }
        }

    }

    static let preferenceKey = "monthlyCleanupReminderEnabled"
    static let rulePreferenceKey = "cleanupSmartReminderRule"
    static let photoThresholdPreferenceKey = "cleanupReminderPhotoThreshold"
    nonisolated static let requestIdentifier = "com.burnroll.cleanup-reminder"
    static let testRequestIdentifier = "com.burnroll.cleanup-reminder-test"
    nonisolated static let deliveredNotificationName = Notification.Name("BurnRollCleanupReminderDelivered")
    static let minimumPhotoThreshold = 20
    static let maximumPhotoThreshold = 500
    static let defaultPhotoThreshold = 500
    static let photoThresholdStep = 10

    private static let legacyRequestIdentifier = "com.burnroll.monthly-cleanup-reminder"
    private static let baselinePhotoCountKey = "cleanupReminderBaselinePhotoCount"
    private static let baselineEstimatedBytesKey = "cleanupReminderBaselineEstimatedBytes"
    private static let baselineDateKey = "cleanupReminderBaselineDate"
    private static let duePendingKey = "cleanupReminderDuePending"

    private struct ReminderBaseline {
        let photoCount: Int
        let estimatedBytes: Int64
        let date: Date
    }

    private let center: UNUserNotificationCenter
    private let defaults: UserDefaults

    private(set) var isEnabled: Bool
    private(set) var rule: SmartReminderRule
    private(set) var photoThreshold: Int
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private(set) var nextReminderDate: Date?
    private(set) var observedPhotoCount = 0
    private(set) var accumulatedNewPhotos = 0
    private(set) var errorMessage: String?
    private var lastSnapshot: PhotoLibraryService.ReminderLibrarySnapshot?
    private var isRefreshing = false
    private var queuedSnapshot: PhotoLibraryService.ReminderLibrarySnapshot?
    private var deliveredObserver: (any NSObjectProtocol)?

    init(
        center: UNUserNotificationCenter = .current(),
        defaults: UserDefaults = .standard
    ) {
        self.center = center
        self.defaults = defaults
        isEnabled = defaults.bool(forKey: Self.preferenceKey)
        rule = defaults.string(forKey: Self.rulePreferenceKey)
            .flatMap(SmartReminderRule.init(rawValue:))
            ?? .days30
        let savedThreshold = defaults.integer(forKey: Self.photoThresholdPreferenceKey)
        photoThreshold = Self.normalizedPhotoThreshold(
            savedThreshold == 0 ? Self.defaultPhotoThreshold : savedThreshold
        )
        deliveredObserver = NotificationCenter.default.addObserver(
            forName: Self.deliveredNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleDeliveredReminder()
            }
        }
    }

    var selectedCadenceDescription: String {
        switch rule {
        case .photos500: String(localized: "After \(photoThreshold.formatted()) new photos")
        case .storage5GB, .days30: rule.cadenceDescription
        }
    }

    var statusText: String {
        guard isEnabled else { return String(localized: "Off") }

        switch rule {
        case .photos500:
            if accumulatedNewPhotos >= photoThreshold {
                return String(localized: "Due now")
            }
            return String(localized: "\(accumulatedNewPhotos.formatted()) of \(photoThreshold.formatted())")

        case .storage5GB:
            return nextReminderDate == nil && accumulatedNewPhotos == 0
                ? String(localized: "Waiting for growth")
                : String(localized: "Timing varies")

        case .days30:
            if observedPhotoCount == 0, nextReminderDate == nil {
                return String(localized: "No photos · skipped")
            }
            guard let nextReminderDate else { return rule.title }
            return String(localized: "Next: \(nextReminderDate.formatted(.dateTime.month(.abbreviated).day().hour().minute()))")
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        if isEnabled, !settings.authorizationStatus.allowsNotifications {
            disable()
        }
    }

    func enable(
        rule: SmartReminderRule,
        snapshot: PhotoLibraryService.ReminderLibrarySnapshot
    ) async throws -> Bool {
        errorMessage = nil
        var settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        if settings.authorizationStatus == .notDetermined {
            AnalyticsService.log(.notificationPermissionRequested)
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            AnalyticsService.log(granted ? .notificationPermissionGranted : .notificationPermissionDenied)
            settings = await center.notificationSettings()
            authorizationStatus = settings.authorizationStatus
        }

        guard settings.authorizationStatus.allowsNotifications else {
            disable()
            return false
        }

        self.rule = rule
        defaults.set(rule.rawValue, forKey: Self.rulePreferenceKey)
        defaults.set(false, forKey: Self.duePendingKey)
        let baseline = resetBaseline(with: snapshot)
        try await schedule(rule: rule, snapshot: snapshot, baseline: baseline)
        defaults.set(true, forKey: Self.preferenceKey)
        isEnabled = true
        return true
    }

    func updateRule(
        _ rule: SmartReminderRule,
        snapshot: PhotoLibraryService.ReminderLibrarySnapshot
    ) async throws -> Bool {
        self.rule = rule
        defaults.set(rule.rawValue, forKey: Self.rulePreferenceKey)
        guard isEnabled else { return true }

        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        guard settings.authorizationStatus.allowsNotifications else {
            disable()
            return false
        }

        defaults.set(false, forKey: Self.duePendingKey)
        let baseline = resetBaseline(with: snapshot)
        try await schedule(rule: rule, snapshot: snapshot, baseline: baseline)
        errorMessage = nil
        return true
    }

    func updatePhotoThreshold(
        _ threshold: Int,
        snapshot: PhotoLibraryService.ReminderLibrarySnapshot
    ) async throws -> Bool {
        let normalizedThreshold = Self.normalizedPhotoThreshold(threshold)
        photoThreshold = normalizedThreshold
        defaults.set(normalizedThreshold, forKey: Self.photoThresholdPreferenceKey)

        guard isEnabled, rule == .photos500 else { return true }

        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        guard settings.authorizationStatus.allowsNotifications else {
            disable()
            return false
        }

        defaults.set(false, forKey: Self.duePendingKey)
        let baseline = resetBaseline(with: snapshot)
        try await schedule(rule: rule, snapshot: snapshot, baseline: baseline)
        errorMessage = nil
        return true
    }

    func refreshIfEnabled(with snapshot: PhotoLibraryService.ReminderLibrarySnapshot) async {
        guard isEnabled else { return }

        if isRefreshing {
            queuedSnapshot = snapshot
            return
        }

        isRefreshing = true
        defer { isRefreshing = false }

        var currentSnapshot = snapshot
        while true {
            await performRefresh(with: currentSnapshot)
            guard let queuedSnapshot else { break }
            self.queuedSnapshot = nil
            currentSnapshot = queuedSnapshot
        }
    }

    func handleDeliveredReminder() {
        defaults.set(false, forKey: Self.duePendingKey)
        guard isEnabled, let lastSnapshot else { return }
        _ = resetBaseline(with: lastSnapshot)
        accumulatedNewPhotos = 0
    }

    func disable() {
        center.removePendingNotificationRequests(
            withIdentifiers: [
                Self.requestIdentifier,
                Self.testRequestIdentifier,
                Self.legacyRequestIdentifier
            ]
        )
        defaults.set(false, forKey: Self.preferenceKey)
        defaults.set(false, forKey: Self.duePendingKey)
        clearBaseline()
        isEnabled = false
        nextReminderDate = nil
        observedPhotoCount = 0
        accumulatedNewPhotos = 0
        lastSnapshot = nil
    }

    func notificationBody(photoCount: Int, usesSpecificCount: Bool = true) -> String {
        if usesSpecificCount, let estimate = CleanupTimeEstimate(photoCount: photoCount) {
            return String(
                localized: "You have \(photoCount) new photos. Want to clean them up? Reviewing should take \(estimate.localizedDurationPhrase)."
            )
        }

        return String(localized: "New photos may be waiting. Open BurnRoll for a quick cleanup.")
    }

    private func localizedNotificationBody(photoCount: Int, usesSpecificCount: Bool) -> String {
        notificationBody(photoCount: photoCount, usesSpecificCount: usesSpecificCount)
    }

    private func performRefresh(with snapshot: PhotoLibraryService.ReminderLibrarySnapshot) async {
        do {
            let settings = await center.notificationSettings()
            authorizationStatus = settings.authorizationStatus

            guard settings.authorizationStatus.allowsNotifications else {
                disable()
                return
            }

            let requests = await center.pendingNotificationRequests()
            let hasPendingReminder = requests.contains { $0.identifier == Self.requestIdentifier }
            let dueWasPending = defaults.bool(forKey: Self.duePendingKey)

            if dueWasPending, !hasPendingReminder {
                _ = resetBaseline(with: snapshot)
                defaults.set(false, forKey: Self.duePendingKey)
            }

            let baseline = loadBaseline() ?? resetBaseline(with: snapshot)
            try await schedule(rule: rule, snapshot: snapshot, baseline: baseline)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            AnalyticsService.recordNonFatal(context: "notification_schedule")
        }
    }

    private func schedule(
        rule: SmartReminderRule,
        snapshot: PhotoLibraryService.ReminderLibrarySnapshot,
        baseline: ReminderBaseline
    ) async throws {
        lastSnapshot = snapshot
        observedPhotoCount = snapshot.recentPhotoCount
        accumulatedNewPhotos = max(0, snapshot.totalPhotoCount - baseline.photoCount)

        guard let plan = CleanupReminderPlanner.plan(
            rule: rule.plannerRule,
            photoThreshold: photoThreshold,
            snapshot: snapshot.plannerSnapshot,
            baseline: CleanupReminderPlanner.Baseline(
                photoCount: baseline.photoCount,
                estimatedBytes: baseline.estimatedBytes,
                date: baseline.date
            )
        ) else {
            center.removePendingNotificationRequests(
                withIdentifiers: [Self.requestIdentifier, Self.legacyRequestIdentifier]
            )
            defaults.set(false, forKey: Self.duePendingKey)
            nextReminderDate = nil
            if rule == .days30 {
                _ = resetBaseline(with: snapshot)
            }
            return
        }

        let requests = await center.pendingNotificationRequests()
        let pendingRequest = requests.first { $0.identifier == Self.requestIdentifier }
        let pendingFireDate = pendingFireDate(for: pendingRequest, now: snapshot.capturedAt)

        if !CleanupReminderPlanner.shouldReplacePendingRequest(
            isDue: plan.isDue,
            pendingFireDate: pendingFireDate,
            now: snapshot.capturedAt
        ) {
            nextReminderDate = pendingFireDate ?? plan.fireDate
            return
        }

        center.removePendingNotificationRequests(
            withIdentifiers: [Self.requestIdentifier, Self.legacyRequestIdentifier]
        )

        let trigger: UNNotificationTrigger
        if plan.isDue {
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: CleanupReminderPlanner.dueDeliveryDelay,
                repeats: false
            )
            defaults.set(true, forKey: Self.duePendingKey)
            nextReminderDate = snapshot.capturedAt.addingTimeInterval(
                CleanupReminderPlanner.dueDeliveryDelay
            )
        } else {
            let calendar = Calendar.autoupdatingCurrent
            var dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: plan.fireDate
            )
            dateComponents.calendar = calendar
            dateComponents.timeZone = .autoupdatingCurrent
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
            defaults.set(false, forKey: Self.duePendingKey)
            nextReminderDate = (trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
                ?? plan.fireDate
        }

        let request = UNNotificationRequest(
            identifier: Self.requestIdentifier,
            content: notificationContent(
                photoCount: plan.photoCountForBody,
                usesSpecificCount: plan.usesSpecificCount
            ),
            trigger: trigger
        )

        try await center.add(request)
        AnalyticsService.log(.notificationScheduled)
    }

    private func pendingFireDate(
        for request: UNNotificationRequest?,
        now: Date
    ) -> Date? {
        guard let request else { return nil }

        if let intervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
            return now.addingTimeInterval(intervalTrigger.timeInterval)
        }

        return (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
    }

    private func notificationContent(
        photoCount: Int,
        usesSpecificCount: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Ready for a quick cleanup?")
        content.body = localizedNotificationBody(
            photoCount: photoCount,
            usesSpecificCount: usesSpecificCount
        )
        content.sound = .default
        content.threadIdentifier = "cleanup-smart"
        return content
    }

    @discardableResult
    private func resetBaseline(
        with snapshot: PhotoLibraryService.ReminderLibrarySnapshot
    ) -> ReminderBaseline {
        let baseline = ReminderBaseline(
            photoCount: snapshot.totalPhotoCount,
            estimatedBytes: snapshot.totalEstimatedBytes,
            date: snapshot.capturedAt
        )
        defaults.set(baseline.photoCount, forKey: Self.baselinePhotoCountKey)
        defaults.set(baseline.estimatedBytes, forKey: Self.baselineEstimatedBytesKey)
        defaults.set(baseline.date.timeIntervalSince1970, forKey: Self.baselineDateKey)
        return baseline
    }

    private func loadBaseline() -> ReminderBaseline? {
        guard
            let photoCount = defaults.object(forKey: Self.baselinePhotoCountKey) as? NSNumber,
            let estimatedBytes = defaults.object(forKey: Self.baselineEstimatedBytesKey) as? NSNumber,
            let dateValue = defaults.object(forKey: Self.baselineDateKey) as? NSNumber
        else {
            return nil
        }

        return ReminderBaseline(
            photoCount: photoCount.intValue,
            estimatedBytes: estimatedBytes.int64Value,
            date: Date(timeIntervalSince1970: dateValue.doubleValue)
        )
    }

    private func clearBaseline() {
        defaults.removeObject(forKey: Self.baselinePhotoCountKey)
        defaults.removeObject(forKey: Self.baselineEstimatedBytesKey)
        defaults.removeObject(forKey: Self.baselineDateKey)
    }

    private static func normalizedPhotoThreshold(_ threshold: Int) -> Int {
        let clamped = min(maximumPhotoThreshold, max(minimumPhotoThreshold, threshold))
        let stepsFromMinimum = Int(
            round(Double(clamped - minimumPhotoThreshold) / Double(photoThresholdStep))
        )
        return min(
            maximumPhotoThreshold,
            minimumPhotoThreshold + stepsFromMinimum * photoThresholdStep
        )
    }
}

private extension CleanupReminderService.SmartReminderRule {
    var plannerRule: CleanupReminderPlanner.Rule {
        switch self {
        case .photos500: .photos500
        case .storage5GB: .storage5GB
        case .days30: .days30
        }
    }
}

private extension PhotoLibraryService.ReminderLibrarySnapshot {
    var plannerSnapshot: CleanupReminderPlanner.Snapshot {
        CleanupReminderPlanner.Snapshot(
            totalPhotoCount: totalPhotoCount,
            totalEstimatedBytes: totalEstimatedBytes,
            recentPhotoCount: recentPhotoCount,
            recentEstimatedBytes: recentEstimatedBytes,
            capturedAt: capturedAt
        )
    }
}

private enum CleanupReminderError: LocalizedError {
    case notificationsDisabled

    var errorDescription: String? {
        String(localized: "Notifications are disabled for BurnRoll. Enable them in iOS Settings to use cleanup reminders.")
    }
}

private extension UNAuthorizationStatus {
    var allowsNotifications: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        @unknown default:
            false
        }
    }
}
