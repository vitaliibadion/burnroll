import Foundation
import StoreKit
import SuperwallKit

@MainActor
final class SuperwallService {
    static let shared = SuperwallService()

    static let publicAPIKey = "pk_ilas0oLi3QtRpmgschnko"
    static let urlScheme = "burnroll"

    private static let userIDKey = "superwallUserID"
    private static var didConfigure = false

    private(set) weak var subscriptions: SubscriptionService?
    private weak var appState: AppState?
    private let delegate = SuperwallAnalyticsDelegate()

    private init() {}

    static func configure() {
        guard !didConfigure else { return }
        didConfigure = true

        let options = SuperwallOptions()
        #if DEBUG
        options.logging.level = .warn
        #endif

        Superwall.configure(
            apiKey: publicAPIKey,
            purchaseController: BurnRollPurchaseController.shared,
            options: options
        )
        Superwall.shared.delegate = shared.delegate
        Superwall.shared.identify(userId: stableUserID())
        Superwall.shared.subscriptionStatus = .unknown

        Task {
            await shared.syncSubscriptionStatus()
            await shared.confirmAssignmentsForAnalytics()
        }
    }

    static func handleDeepLink(_ url: URL) -> Bool {
        Superwall.handleDeepLink(url)
    }

    static func register(
        _ placement: String,
        params: [String: Any]? = nil,
        handler: PaywallPresentationHandler? = nil,
        feature: (() -> Void)? = nil
    ) {
        if let feature {
            Superwall.shared.register(
                placement: placement,
                params: params,
                handler: handler,
                feature: feature
            )
        } else {
            Superwall.shared.register(
                placement: placement,
                params: params,
                handler: handler
            )
        }
    }

    static func registerAnalyticsPlacement(_ name: String) {
        Superwall.shared.register(placement: name)
    }

    func attach(appState: AppState, subscriptions: SubscriptionService) {
        self.appState = appState
        self.subscriptions = subscriptions
        refreshUserAttributes()
    }

    func refreshAfterStoreChange() async {
        await subscriptions?.refreshFromStore()
        await syncSubscriptionStatus()
        refreshUserAttributes()
    }

    func syncSubscriptionStatus() async {
        var productIDs: Set<String> = []
        if let subscriptions, !subscriptions.purchasedProductIDs.isEmpty {
            productIDs = subscriptions.purchasedProductIDs
        } else {
            for await verification in Transaction.currentEntitlements {
                if case .verified(let transaction) = verification,
                   SubscriptionProductIDs.all.contains(transaction.productID) {
                    productIDs.insert(transaction.productID)
                }
            }
        }

        let deviceEntitlements = Superwall.shared.entitlements.byProductIds(productIDs)
        let webEntitlements = Superwall.shared.entitlements.web
        let entitlements = deviceEntitlements.union(webEntitlements)

        if entitlements.isEmpty {
            if productIDs.isEmpty {
                Superwall.shared.subscriptionStatus = .inactive
            } else {
                Superwall.shared.subscriptionStatus = .active([Entitlement(id: "pro")])
            }
        } else {
            Superwall.shared.subscriptionStatus = .active(entitlements)
        }
    }

    func refreshUserAttributes() {
        guard let appState else { return }
        let plan = subscriptions?.purchasedProductIDs
            .compactMap { id in SubscriptionPlan.allCases.first { $0.productID == id }?.rawValue }
            .sorted()
            .joined(separator: ",")

        Superwall.shared.setUserAttributes([
            "completed_onboarding": appState.hasCompletedOnboarding,
            "has_reviewed_media": appState.hasReviewedMedia,
            "is_subscribed": subscriptions?.isSubscribed ?? false,
            "selected_plan": plan ?? subscriptions?.selectedPlan.rawValue as Any,
            "cleanup_streak": appState.storageInsights.cleanupStreak,
            "locale": Locale.current.identifier
        ])
    }

    private func confirmAssignmentsForAnalytics() async {
        let assignments = await Superwall.shared.confirmAllAssignments()
        for assignment in assignments {
            AnalyticsService.setSuperwallCohort(
                experimentID: assignment.experimentId,
                variantID: assignment.variant.id
            )
        }
    }

    private static func stableUserID() -> String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: userIDKey), UUID(uuidString: existing) != nil {
            return existing
        }
        let userID = UUID().uuidString
        defaults.set(userID, forKey: userIDKey)
        return userID
    }
}

@MainActor
private final class SuperwallAnalyticsDelegate: SuperwallDelegate {
    func subscriptionStatusDidChange(
        from oldValue: SuperwallKit.SubscriptionStatus,
        to newValue: SuperwallKit.SubscriptionStatus
    ) {
        SuperwallService.shared.refreshUserAttributes()
        switch newValue {
        case .active:
            if !oldValue.isActive {
                AnalyticsService.logSuperwallForwarded(.subscriptionStarted)
            }
        case .inactive, .unknown:
            break
        }
    }

    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .paywallOpen:
            AnalyticsService.logSuperwallForwarded(.paywallStarted)
        case .paywallDecline:
            AnalyticsService.logSuperwallForwarded(.paywallDeclined)
        case .freeTrialStart:
            AnalyticsService.logSuperwallForwarded(.trialStarted)
        case .subscriptionStart:
            AnalyticsService.logSuperwallForwarded(.subscriptionStarted)
        case .transactionRestore:
            AnalyticsService.logSuperwallForwarded(.purchaseRestored)
        case .transactionFail:
            AnalyticsService.logSuperwallForwarded(.purchaseFailed)
        case .triggerFire(_, _):
            if let experimentID = eventInfo.params["experiment_id"] as? String,
               let variantID = eventInfo.params["variant_id"] as? String {
                AnalyticsService.setSuperwallCohort(
                    experimentID: experimentID,
                    variantID: variantID
                )
                Superwall.shared.setUserAttributes([
                    "sw_experiment_\(sanitizedID(experimentID))": true,
                    "sw_variant_\(sanitizedID(variantID))": true
                ])
            }
        default:
            break
        }
    }

    private func sanitizedID(_ value: String) -> String {
        let allowed = value.filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        return String(allowed.prefix(40))
    }
}
