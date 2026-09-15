import Foundation
import StoreKit
import SuperwallKit

enum BurnRollPurchaseControllerError: LocalizedError {
    case customProductNotHandled(String)

    var errorDescription: String? {
        switch self {
        case .customProductNotHandled(let productID):
            "Custom product \(productID) is not available through the App Store."
        }
    }
}

/// Routes Superwall paywall checkouts through StoreKit 2 and keeps Superwall's
/// `subscriptionStatus` in sync. Required because BurnRoll already owns IAP.
@MainActor
final class BurnRollPurchaseController: PurchaseController {
    static let shared = BurnRollPurchaseController()

    private var isHandlingAppStorePurchase = false
    private var isHandlingRestore = false

    func purchase(product: StoreProduct) async -> PurchaseResult {
        guard product.sk2Product != nil || product.sk1Product != nil else {
            return .failed(
                BurnRollPurchaseControllerError.customProductNotHandled(product.productIdentifier)
            )
        }

        if isHandlingAppStorePurchase, let sk2Product = product.sk2Product {
            return await purchaseWithStoreKit(sk2Product)
        }

        isHandlingAppStorePurchase = true
        defer { isHandlingAppStorePurchase = false }

        let result = await Superwall.shared.purchase(product)
        await SuperwallService.shared.refreshAfterStoreChange()
        return result
    }

    func restorePurchases() async -> RestorationResult {
        if isHandlingRestore {
            return await restoreWithStoreKit()
        }

        isHandlingRestore = true
        defer { isHandlingRestore = false }

        let result = await Superwall.shared.restorePurchases()
        await SuperwallService.shared.refreshAfterStoreChange()
        return result
    }

    private func purchaseWithStoreKit(_ product: StoreKit.Product) async -> PurchaseResult {
        guard let subscriptions = SuperwallService.shared.subscriptions else {
            return .failed(BurnRollPurchaseControllerError.customProductNotHandled(product.id))
        }

        let plan = SubscriptionPlan.allCases.first { $0.productID == product.id }
        let purchased: Bool
        if let plan {
            purchased = await subscriptions.purchase(plan)
        } else {
            purchased = await subscriptions.purchase(storeProduct: product)
        }

        await SuperwallService.shared.syncSubscriptionStatus()

        if purchased {
            return .purchased
        }
        if subscriptions.errorMessage == nil {
            return .cancelled
        }
        return .failed(BurnRollPurchaseControllerError.customProductNotHandled(product.id))
    }

    private func restoreWithStoreKit() async -> RestorationResult {
        guard let subscriptions = SuperwallService.shared.subscriptions else {
            return .failed(nil)
        }
        do {
            try await AppStore.sync()
            await subscriptions.refreshFromStore()
            await SuperwallService.shared.syncSubscriptionStatus()
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
