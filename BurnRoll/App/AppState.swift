import Observation
@preconcurrency import Photos

@MainActor
@Observable
final class AppState {
    struct DeletionSummary: Equatable, Sendable {
        let itemCount: Int
        let clearedBytes: Int64
        let reviewDuration: TimeInterval
    }

    struct StorageInsights: Equatable, Sendable {
        let spaceRecovered: Int64
        let photosBurned: Int
        let videosRemoved: Int
        let cleanupStreak: Int
    }

    enum Route: Equatable {
        case onboarding
        case paywall
        case authorization
        case welcome
        case cleaner
    }

    private enum DefaultsKey {
        static let completedOnboarding = "completedOnboarding"
        static let needsPaywall = "needsPaywall"
        static let hasCompletedSwipeHint = "hasCompletedSwipeHint"
        static let lastCleanupItemCount = "lastCleanupItemCount"
        static let lastCleanupClearedBytes = "lastCleanupClearedBytes"
        static let lastCleanupReviewDuration = "lastCleanupReviewDuration"
        static let totalCleanupItemCount = "totalCleanupItemCount"
        static let totalCleanupClearedBytes = "totalCleanupClearedBytes"
        static let totalCleanupReviewDuration = "totalCleanupReviewDuration"
        static let totalCleanupPhotoCount = "totalCleanupPhotoCount"
        static let totalCleanupVideoCount = "totalCleanupVideoCount"
        static let cleanupStreakCount = "cleanupStreakCount"
        static let cleanupStreakLastDate = "cleanupStreakLastDate"
    }

    let photoLibrary = PhotoLibraryService()
    let cleanupReminders: CleanupReminderService
    let subscriptions = SubscriptionService()
    private let defaults: UserDefaults
    private let reviewCheckpointStore: ReviewCheckpointStore

    var route: Route
    private(set) var isShowingLaunchFire = true
    private(set) var isReplayingOnboarding = false
    private(set) var hasCompletedSwipeHint: Bool
    private(set) var pendingSwipeHint = false
    private(set) var swipeHintGeneration = 0
    var session = SessionState()
    var authorizationStatus = PhotoAuthorizationService.status
    var isLoadingLibrary = false
    var errorMessage: String?
    var deletionErrorMessage: String?
    var isDeleting = false
    var isPaywallCoverPresented = false
    private(set) var shouldConfirmDeletionAfterPaywall = false
    private var resumeDeletionAfterPaywall = false
    private(set) var reviewedAssetIdentifiers: Set<String>
    private(set) var reviewCheckpointErrorMessage: String?
    private var newlyReviewedAssetIdentifiersInSession: Set<String> = []
    private var hasLoggedReviewSessionCompletion = false
    private(set) var lastDeletionSummary: DeletionSummary?
    private(set) var totalDeletionSummary = DeletionSummary(
        itemCount: 0,
        clearedBytes: 0,
        reviewDuration: 0
    )
    private(set) var storageInsights = StorageInsights(
        spaceRecovered: 0,
        photosBurned: 0,
        videosRemoved: 0,
        cleanupStreak: 0
    )
    private var cleanupStreak = CleanupStreak()
    private var photoLibraryChangeObserver: (any NSObjectProtocol)?
    private var routeAfterOnboardingReplay: Route = .welcome

    init(
        defaults: UserDefaults = .standard,
        reviewCheckpointStore: ReviewCheckpointStore = .applicationSupport()
    ) {
        self.defaults = defaults
        self.reviewCheckpointStore = reviewCheckpointStore
        reviewedAssetIdentifiers = reviewCheckpointStore.load()
        cleanupReminders = CleanupReminderService(defaults: defaults)
        hasCompletedSwipeHint = defaults.bool(forKey: DefaultsKey.hasCompletedSwipeHint)
        var completedOnboarding = defaults.bool(forKey: DefaultsKey.completedOnboarding)
        var needsPaywall = defaults.bool(forKey: DefaultsKey.needsPaywall)
        #if DEBUG
        if ScreenshotDemo.isActive {
            completedOnboarding = true
            needsPaywall = false
            hasCompletedSwipeHint = true
            isShowingLaunchFire = false
        }
        #endif
        if !completedOnboarding {
            route = .onboarding
        } else if needsPaywall {
            route = .paywall
        } else {
            route = .authorization
        }

        let itemCount = defaults.integer(forKey: DefaultsKey.lastCleanupItemCount)
        let clearedBytes = defaults.object(forKey: DefaultsKey.lastCleanupClearedBytes) as? Int64 ?? 0
        let reviewDuration = max(
            0,
            defaults.double(forKey: DefaultsKey.lastCleanupReviewDuration)
        )
        if itemCount > 0 {
            lastDeletionSummary = DeletionSummary(
                itemCount: itemCount,
                clearedBytes: max(0, clearedBytes),
                reviewDuration: reviewDuration
            )
        }

        let totalItemCount: Int
        let totalClearedBytes: Int64
        let totalReviewDuration: TimeInterval
        if defaults.object(forKey: DefaultsKey.totalCleanupItemCount) == nil {
            totalItemCount = itemCount
            totalClearedBytes = clearedBytes
            totalReviewDuration = reviewDuration
            defaults.set(totalItemCount, forKey: DefaultsKey.totalCleanupItemCount)
            defaults.set(totalClearedBytes, forKey: DefaultsKey.totalCleanupClearedBytes)
            defaults.set(totalReviewDuration, forKey: DefaultsKey.totalCleanupReviewDuration)
        } else {
            totalItemCount = defaults.integer(forKey: DefaultsKey.totalCleanupItemCount)
            totalClearedBytes = defaults.object(forKey: DefaultsKey.totalCleanupClearedBytes) as? Int64 ?? 0
            totalReviewDuration = max(
                0,
                defaults.double(forKey: DefaultsKey.totalCleanupReviewDuration)
            )
        }

        totalDeletionSummary = DeletionSummary(
            itemCount: max(0, totalItemCount),
            clearedBytes: max(0, totalClearedBytes),
            reviewDuration: totalReviewDuration
        )

        let savedStreakDate = (defaults.object(forKey: DefaultsKey.cleanupStreakLastDate) as? NSNumber)
            .map { Date(timeIntervalSince1970: $0.doubleValue) }
        cleanupStreak = CleanupStreak(
            currentCount: defaults.integer(forKey: DefaultsKey.cleanupStreakCount),
            lastCleanupDay: savedStreakDate
        )
        storageInsights = StorageInsights(
            spaceRecovered: max(0, totalClearedBytes),
            photosBurned: max(0, defaults.integer(forKey: DefaultsKey.totalCleanupPhotoCount)),
            videosRemoved: max(0, defaults.integer(forKey: DefaultsKey.totalCleanupVideoCount)),
            cleanupStreak: cleanupStreak.currentCount
        )

        photoLibraryChangeObserver = NotificationCenter.default.addObserver(
            forName: PhotoLibraryService.libraryDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.handlePhotoLibraryChange()
            }
        }

        SuperwallService.shared.attach(appState: self, subscriptions: subscriptions)
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: DefaultsKey.completedOnboarding)
    }

    var currentAsset: MediaAsset? {
        photoLibrary.mediaAsset(at: session.currentIndex)
    }

    var hasReviewedMedia: Bool {
        !reviewedAssetIdentifiers.isEmpty || session.reviewedCount > 0
    }

    var shouldPlaySwipeHint: Bool {
        pendingSwipeHint || (!hasCompletedSwipeHint && !hasReviewedMedia)
    }

    func completeSwipeHint() {
        pendingSwipeHint = false
        guard !hasCompletedSwipeHint else { return }
        hasCompletedSwipeHint = true
        defaults.set(true, forKey: DefaultsKey.hasCompletedSwipeHint)
    }

    func finishLaunchFire() {
        isShowingLaunchFire = false
    }

    func bootstrap() async {
        guard route != .onboarding, route != .paywall else { return }
        authorizationStatus = PhotoAuthorizationService.status
        updateCrashlyticsContext()

        if PhotoAuthorizationService.hasUsableAccess {
            loadLibraryAndShowWelcome()
        }
    }

    func replayOnboarding() {
        guard route != .onboarding else { return }
        routeAfterOnboardingReplay = route
        isReplayingOnboarding = true
        route = .onboarding
    }

    func finishOnboarding() {
        defaults.set(true, forKey: DefaultsKey.completedOnboarding)

        if isReplayingOnboarding {
            isReplayingOnboarding = false
            pendingSwipeHint = true
            swipeHintGeneration += 1
            restoreRouteAfterOnboardingReplay()
            return
        }

        AnalyticsService.log(.onboardingCompleted)
        SuperwallService.shared.refreshUserAttributes()
        if subscriptions.isSubscribed {
            defaults.set(false, forKey: DefaultsKey.needsPaywall)
            route = .authorization
        } else {
            defaults.set(true, forKey: DefaultsKey.needsPaywall)
            route = .paywall
        }
    }

    func finishPaywall() {
        defaults.set(false, forKey: DefaultsKey.needsPaywall)
        SuperwallService.shared.refreshUserAttributes()
        let resumeDeletion = resumeDeletionAfterPaywall
        resumeDeletionAfterPaywall = false
        if route == .paywall {
            route = .authorization
        }
        isPaywallCoverPresented = false
        if resumeDeletion, subscriptions.isSubscribed {
            shouldConfirmDeletionAfterPaywall = true
        }
    }

    func dismissPaywall() {
        AnalyticsService.log(.paywallDeclined)
        defaults.set(false, forKey: DefaultsKey.needsPaywall)
        SuperwallService.shared.refreshUserAttributes()
        resumeDeletionAfterPaywall = false
        shouldConfirmDeletionAfterPaywall = false
        if route == .paywall {
            route = .authorization
        }
        isPaywallCoverPresented = false
    }

    func presentPaywall(resumeDeletion: Bool = false) {
        guard !subscriptions.isSubscribed else { return }
        resumeDeletionAfterPaywall = resumeDeletion
        isPaywallCoverPresented = true
    }

    func presentPaywallForDeletion() {
        presentPaywall(resumeDeletion: true)
    }

    func consumeDeletionConfirmationAfterPaywall() {
        shouldConfirmDeletionAfterPaywall = false
    }

    private func restoreRouteAfterOnboardingReplay() {
        let destination = routeAfterOnboardingReplay
        routeAfterOnboardingReplay = .welcome

        switch destination {
        case .cleaner, .welcome:
            route = destination
        case .authorization, .onboarding, .paywall:
            if PhotoAuthorizationService.hasUsableAccess {
                loadLibraryAndShowWelcome()
            } else {
                route = .authorization
            }
        }
    }

    func requestPhotoAccess() async {
        errorMessage = nil
        AnalyticsService.log(.photoPermissionRequested)
        authorizationStatus = await PhotoAuthorizationService.requestAccess()

        switch authorizationStatus {
        case .authorized, .limited:
            AnalyticsService.log(
                .photoPermissionGranted,
                parameters: ["authorization_status": authorizationAnalyticsValue]
            )
            photoLibrary.startObservingLibraryChanges()
            loadLibraryAndShowWelcome()
            if authorizationStatus == .limited {
                try? await Task.sleep(for: .milliseconds(350))
                reloadVisibleLibrary()
                if photoLibrary.itemCount(for: .all) == 0 {
                    await PhotoAuthorizationService.presentLimitedLibraryPicker()
                    reloadVisibleLibrary()
                }
            }
        case .denied, .restricted:
            AnalyticsService.log(
                .photoPermissionDenied,
                parameters: ["authorization_status": authorizationAnalyticsValue]
            )
            errorMessage = String(localized: "BurnRoll needs Photos access so you can review and safely delete the items you choose.")
        case .notDetermined:
            break
        @unknown default:
            AnalyticsService.log(.photoPermissionDenied, parameters: ["authorization_status": "unknown"])
            errorMessage = String(localized: "Photos access is not available.")
        }
    }

    func refreshPhotoAuthorizationStatus() {
        authorizationStatus = PhotoAuthorizationService.status
    }

    func handlePhotoLibraryChange() async {
        authorizationStatus = PhotoAuthorizationService.status
        guard PhotoAuthorizationService.hasUsableAccess else { return }

        if authorizationStatus == .limited || photoLibrary.itemCount(for: .all) == 0 {
            reloadVisibleLibrary()
        }

        await refreshCleanupReminder()
    }

    func reloadVisibleLibrary() {
        guard PhotoAuthorizationService.hasUsableAccess else { return }

        let shouldResetSession = route != .cleaner || photoLibrary.itemCount(for: .all) == 0

        photoLibrary.loadNewestFirst(
            source: photoLibrary.selectedSource,
            reviewScope: photoLibrary.selectedReviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers,
            refreshCatalog: true
        )

        if shouldResetSession {
            if route == .cleaner {
                session.beginReviewingSource(totalAssetCount: photoLibrary.assetCount)
            } else {
                session.reset(totalAssetCount: photoLibrary.assetCount)
            }
        }

        updateCrashlyticsContext()
    }

    func refreshCleanupReminder() async {
        guard PhotoAuthorizationService.hasUsableAccess else { return }
        let snapshot = reminderSnapshot()
        await cleanupReminders.refreshIfEnabled(with: snapshot)
    }

    func reminderSnapshot() -> PhotoLibraryService.ReminderLibrarySnapshot {
        photoLibrary.reminderSnapshot(
            includeByteEstimates: cleanupReminders.rule == .storage5GB
        )
    }

    func refreshMediaCatalog() {
        photoLibrary.refreshAvailableSources(
            reviewScope: photoLibrary.selectedReviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers
        )
    }

    func loadLibraryAndShowWelcome() {
        isLoadingLibrary = true
        photoLibrary.startObservingLibraryChanges()
        photoLibrary.loadNewestFirst(
            reviewedAssetIdentifiers: reviewedAssetIdentifiers,
            refreshCatalog: true
        )
        session.reset(totalAssetCount: photoLibrary.assetCount)
        isLoadingLibrary = false
        updateCrashlyticsContext()
        route = .welcome
        applyScreenshotDemoIfNeeded()
    }

    func startCleaning() {
        SuperwallService.register(SuperwallPlacement.startCleaning)
        beginCleaningSession()
    }

    func beginCleaningSession() {
        session.beginReviewTiming(at: Date())
        hasLoggedReviewSessionCompletion = false
        AnalyticsService.log(.reviewSessionStarted)
        SuperwallService.shared.refreshUserAttributes()
        route = .cleaner
    }

    func selectMediaSource(_ source: PhotoLibraryService.MediaSource) {
        guard source.id != photoLibrary.selectedSource.id else { return }
        session.beginReviewTiming(at: Date())

        isLoadingLibrary = true
        photoLibrary.loadNewestFirst(
            source: source,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers
        )
        session.beginReviewingSource(totalAssetCount: photoLibrary.assetCount)
        isLoadingLibrary = false
        updateCrashlyticsContext()
    }

    func selectReviewScope(_ reviewScope: PhotoLibraryService.ReviewScope) {
        guard reviewScope != photoLibrary.selectedReviewScope else { return }
        session.beginReviewTiming(at: Date())

        let durationMilliseconds = photoLibrary.applyReviewScope(
            reviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers
        )
        session.beginReviewingSource(totalAssetCount: photoLibrary.assetCount)
        AnalyticsService.logFilter(
            reviewScope.analyticsFilterType,
            durationMilliseconds: durationMilliseconds
        )
        updateCrashlyticsContext()
    }

    func decide(_ decision: ReviewDecision) {
        guard let currentAsset else { return }
        completeSwipeHint()
        session.beginReviewTiming(at: Date())
        session.decide(decision, asset: currentAsset)
        markReviewed(currentAsset.id)
        AnalyticsService.logReviewDecision(
            isKeep: decision == .keep,
            isPhoto: currentAsset.mediaType == .photo
        )
    }

    func undo() {
        session.beginReviewTiming(at: Date())
        guard let undoneAction = session.undoLastAction() else { return }
        if
            session.decision(forAssetID: undoneAction.asset.id) == nil,
            newlyReviewedAssetIdentifiersInSession.contains(undoneAction.asset.id)
        {
            markNotReviewed(undoneAction.asset.id)
        }
    }

    func continueCleaning() {
        session.beginReviewTiming(at: Date())
    }

    func changeDecision(for asset: MediaAsset, to decision: ReviewDecision) {
        session.beginReviewTiming(at: Date())
        session.changeDecision(forAssetID: asset.id, to: decision)
    }

    func removeFromBurnQueue(id: String) {
        session.beginReviewTiming(at: Date())
        session.removeFromBurnQueue(id: id)
    }

    @discardableResult
    func resetReviewCheckpoint() -> Bool {
        do {
            try reviewCheckpointStore.reset()
            reviewedAssetIdentifiers.removeAll(keepingCapacity: true)
            newlyReviewedAssetIdentifiersInSession.removeAll(keepingCapacity: true)
            reviewCheckpointErrorMessage = nil

            isLoadingLibrary = true
            photoLibrary.loadNewestFirst(
                source: photoLibrary.selectedSource,
                reviewScope: .notReviewed,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers,
                refreshCatalog: true
            )
            session.beginReviewingSource(totalAssetCount: photoLibrary.assetCount)
            isLoadingLibrary = false
            updateCrashlyticsContext()
            return true
        } catch {
            reviewCheckpointErrorMessage = error.localizedDescription
            AnalyticsService.recordNonFatal(context: "review_checkpoint_reset")
            return false
        }
    }

    func deleteBurnQueue() async -> DeletionSummary? {
        let queuedAssets = session.burnQueue
        guard !queuedAssets.isEmpty else { return nil }
        guard subscriptions.isSubscribed else {
            presentPaywallForDeletion()
            return nil
        }
        session.beginReviewTiming(at: Date())

        isDeleting = true
        deletionErrorMessage = nil
        defer { isDeleting = false }

        do {
            let result = try await PhotoDeletionService.delete(
                localIdentifiers: queuedAssets.map(\.id)
            )
            session.discardUnavailableAssets(ids: result.unavailableIdentifiers)
            let deleted = session.completeDeletion(ids: result.deletedIdentifiers)
            removeFromReviewCheckpoint(
                identifiers: result.unavailableIdentifiers.union(result.deletedIdentifiers)
            )
            let reviewDuration = session.finishReviewTiming(at: Date())
            let summary = DeletionSummary(
                itemCount: deleted.count,
                clearedBytes: deleted.reduce(0) { $0 + $1.estimatedByteSize },
                reviewDuration: reviewDuration
            )
            lastDeletionSummary = summary
            totalDeletionSummary = DeletionSummary(
                itemCount: totalDeletionSummary.itemCount + summary.itemCount,
                clearedBytes: totalDeletionSummary.clearedBytes + summary.clearedBytes,
                reviewDuration: totalDeletionSummary.reviewDuration + summary.reviewDuration
            )
            let photosBurned = deleted.count { $0.mediaType == .photo }
            let videosRemoved = deleted.count { $0.mediaType == .video }
            cleanupStreak.recordCleanup()
            storageInsights = StorageInsights(
                spaceRecovered: totalDeletionSummary.clearedBytes,
                photosBurned: storageInsights.photosBurned + photosBurned,
                videosRemoved: storageInsights.videosRemoved + videosRemoved,
                cleanupStreak: cleanupStreak.currentCount
            )
            defaults.set(summary.itemCount, forKey: DefaultsKey.lastCleanupItemCount)
            defaults.set(summary.clearedBytes, forKey: DefaultsKey.lastCleanupClearedBytes)
            defaults.set(summary.reviewDuration, forKey: DefaultsKey.lastCleanupReviewDuration)
            defaults.set(totalDeletionSummary.itemCount, forKey: DefaultsKey.totalCleanupItemCount)
            defaults.set(totalDeletionSummary.clearedBytes, forKey: DefaultsKey.totalCleanupClearedBytes)
            defaults.set(
                totalDeletionSummary.reviewDuration,
                forKey: DefaultsKey.totalCleanupReviewDuration
            )
            defaults.set(storageInsights.photosBurned, forKey: DefaultsKey.totalCleanupPhotoCount)
            defaults.set(storageInsights.videosRemoved, forKey: DefaultsKey.totalCleanupVideoCount)
            defaults.set(cleanupStreak.currentCount, forKey: DefaultsKey.cleanupStreakCount)
            if let lastCleanupDay = cleanupStreak.lastCleanupDay {
                defaults.set(
                    lastCleanupDay.timeIntervalSince1970,
                    forKey: DefaultsKey.cleanupStreakLastDate
                )
            }
            return summary
        } catch {
            let deletionError = PhotoDeletionService.DeletionError.from(error)
            if deletionError.isUserCancellation {
                return nil
            }

            deletionErrorMessage = deletionError.localizedDescription
            AnalyticsService.recordNonFatal(context: "photo_deletion")
            return nil
        }
    }

    func endReviewSessionIfNeeded() {
        guard
            route == .cleaner,
            !hasLoggedReviewSessionCompletion,
            session.reviewedCount > 0
        else {
            return
        }

        hasLoggedReviewSessionCompletion = true
        AnalyticsService.log(
            .reviewSessionCompleted,
            parameters: ["photos_reviewed_count": session.reviewedCount]
        )
    }

    private func applyScreenshotDemoIfNeeded() {
        #if DEBUG
        guard ScreenshotDemo.isActive, photoLibrary.assetCount > 0 else { return }

        hasCompletedSwipeHint = true
        pendingSwipeHint = false
        isShowingLaunchFire = false

        let historyCount = min(9, max(0, photoLibrary.assetCount - 1))
        var decisions: [(MediaAsset, ReviewDecision)] = []
        for index in 1...max(1, historyCount) {
            guard let asset = photoLibrary.mediaAsset(at: index) else { continue }
            decisions.append((asset, index % 3 == 0 ? .keep : .burn))
        }
        session.seedScreenshotHistory(
            decisions: decisions,
            estimatedBytesOverride: 1_800_000_000
        )

        storageInsights = StorageInsights(
            spaceRecovered: 1_800_000_000,
            photosBurned: 86,
            videosRemoved: 7,
            cleanupStreak: 4
        )
        lastDeletionSummary = nil
        switch ScreenshotDemo.scene {
        case .complete, .storage:
            lastDeletionSummary = DeletionSummary(
                itemCount: 93,
                clearedBytes: 1_800_000_000,
                reviewDuration: 12 * 60
            )
        default:
            break
        }
        totalDeletionSummary = lastDeletionSummary ?? DeletionSummary(
            itemCount: 93,
            clearedBytes: 1_800_000_000,
            reviewDuration: 12 * 60
        )

        if ScreenshotDemo.shouldShowWelcome {
            route = .welcome
        } else {
            startCleaning()
        }
        #endif
    }

    private func markReviewed(_ identifier: String) {
        guard reviewedAssetIdentifiers.insert(identifier).inserted else { return }

        do {
            try reviewCheckpointStore.recordReviewed(identifier: identifier)
            newlyReviewedAssetIdentifiersInSession.insert(identifier)
            photoLibrary.updateReviewScopeCounts(markedReviewed: true)
            reviewCheckpointErrorMessage = nil
        } catch {
            reviewedAssetIdentifiers.remove(identifier)
            reviewCheckpointErrorMessage = error.localizedDescription
            AnalyticsService.recordNonFatal(context: "review_checkpoint_persist")
        }
    }

    private func markNotReviewed(
        _ identifier: String,
        updateLibraryCounts: Bool = true
    ) {
        guard reviewedAssetIdentifiers.remove(identifier) != nil else { return }

        do {
            try reviewCheckpointStore.recordNotReviewed(identifier: identifier)
            newlyReviewedAssetIdentifiersInSession.remove(identifier)
            if updateLibraryCounts {
                photoLibrary.updateReviewScopeCounts(markedReviewed: false)
            }
            reviewCheckpointErrorMessage = nil
        } catch {
            reviewedAssetIdentifiers.insert(identifier)
            reviewCheckpointErrorMessage = error.localizedDescription
            AnalyticsService.recordNonFatal(context: "review_checkpoint_persist")
        }
    }

    private func removeFromReviewCheckpoint(identifiers: Set<String>) {
        for identifier in identifiers {
            markNotReviewed(identifier, updateLibraryCounts: false)
        }
    }

    private func updateCrashlyticsContext() {
        AnalyticsService.setLibraryContext(
            authorizationStatus: authorizationAnalyticsValue,
            assetCount: photoLibrary.itemCount(for: .all),
            reviewScope: photoLibrary.selectedReviewScope.analyticsFilterType
        )
    }

    private var authorizationAnalyticsValue: String {
        switch authorizationStatus {
        case .authorized: "full"
        case .limited: "limited"
        case .denied: "denied"
        case .restricted: "restricted"
        case .notDetermined: "not_determined"
        @unknown default: "unknown"
        }
    }
}
