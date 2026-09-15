import Foundation

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { productID }

    var productID: String {
        "com.vitaliibadion.burnroll.pro.\(rawValue)"
    }

    var title: String {
        switch self {
        case .weekly: String(localized: "Weekly")
        case .monthly: String(localized: "Monthly")
        case .yearly: String(localized: "Annually")
        }
    }

    var periodLabel: String {
        switch self {
        case .weekly: String(localized: "per week")
        case .monthly: String(localized: "per month")
        case .yearly: String(localized: "per year")
        }
    }

    /// Shown when StoreKit products have not loaded yet.
    var fallbackPriceText: String {
        switch self {
        case .weekly: "$6.99"
        case .monthly: "$14.99"
        case .yearly: "$69.99"
        }
    }

    var includesFreeTrial: Bool {
        self == .weekly || self == .yearly
    }

    var isRecommended: Bool {
        self == .yearly
    }
}

enum SubscriptionProductIDs {
    static let all = SubscriptionPlan.allCases.map(\.productID)
    static let groupID = "2147580001"
}
