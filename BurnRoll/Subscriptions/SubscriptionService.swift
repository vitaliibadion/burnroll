import Foundation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoadingProducts = false
    private(set) var isPurchasing = false
    var errorMessage: String?
    var selectedPlan: SubscriptionPlan = .weekly

    private var updatesTask: Task<Void, Never>?
    private var didStart = false

    var isSubscribed: Bool {
        !purchasedProductIDs.isEmpty
    }

    func start() {
        guard !didStart else { return }
        didStart = true
        updatesTask = Task { [weak self] in
            for await verification in Transaction.updates {
                guard let self else { return }
                if let transaction = await self.verified(verification) {
                    await transaction.finish()
                    await self.refreshPurchases()
                }
            }
        }
        Task { await loadProducts() }
        Task { await refreshPurchases() }
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let loaded = try await Product.products(for: SubscriptionProductIDs.all)
            products = SubscriptionPlan.allCases.compactMap { plan in
                loaded.first { $0.id == plan.productID }
            }
        } catch {
            errorMessage = String(localized: "Couldn't load plans. Check your connection and try again.")
        }
    }

    func priceText(for plan: SubscriptionPlan) -> String {
        if let product = product(for: plan) {
            return product.displayPrice
        }
        return plan.fallbackPriceText
    }

    var trialPriceText: String {
        if let offer = product(for: .weekly)?.subscription?.introductoryOffer {
            return offer.displayPrice
        }
        return "$0.00"
    }

    func purchaseSelected() async -> Bool {
        await purchase(selectedPlan)
    }

    func purchase(_ plan: SubscriptionPlan) async -> Bool {
        errorMessage = nil
        guard let product = product(for: plan) else {
            await loadProducts()
            guard let product = product(for: plan) else {
                errorMessage = String(localized: "Couldn't load plans. Check your connection and try again.")
                return false
            }
            return await purchase(product, plan: plan)
        }
        return await purchase(product, plan: plan)
    }

    func purchase(storeProduct: Product) async -> Bool {
        errorMessage = nil
        let plan = SubscriptionPlan.allCases.first { $0.productID == storeProduct.id }
        return await purchase(storeProduct, plan: plan)
    }

    func refreshFromStore() async {
        await refreshPurchases()
    }

    func restore() async -> Bool {
        errorMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshPurchases()
            if isSubscribed {
                return true
            }
            errorMessage = String(localized: "No purchases to restore.")
            return false
        } catch {
            errorMessage = String(localized: "Couldn't restore purchases. Try again.")
            return false
        }
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        products.first { $0.id == plan.productID }
    }

    private func purchase(_ product: Product, plan: SubscriptionPlan?) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if let transaction = await verified(verification) {
                    await transaction.finish()
                    await refreshPurchases()
                    if let plan {
                        selectedPlan = plan
                    }
                    return isSubscribed
                }
                errorMessage = String(localized: "Purchase couldn't be verified. Try again.")
                return false
            case .userCancelled:
                return false
            case .pending:
                errorMessage = String(localized: "Purchase is pending approval.")
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = String(localized: "Purchase couldn't be completed. Try again.")
            return false
        }
    }

    private func refreshPurchases() async {
        var active: Set<String> = []
        for await verification in Transaction.currentEntitlements {
            if let transaction = await verified(verification),
               SubscriptionProductIDs.all.contains(transaction.productID) {
                active.insert(transaction.productID)
            }
        }
        purchasedProductIDs = active
        await SuperwallService.shared.syncSubscriptionStatus()
        SuperwallService.shared.refreshUserAttributes()
    }

    private func verified<T>(_ result: VerificationResult<T>) async -> T? {
        switch result {
        case .unverified:
            nil
        case .verified(let value):
            value
        }
    }
}
