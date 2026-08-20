import Foundation

public enum ReviewDecision: String, Hashable, Sendable {
    case keep
    case burn
}

public struct ReviewAction: Equatable, Identifiable, Sendable {
    public let asset: MediaAsset
    public let decision: ReviewDecision
    public let indexBeforeAction: Int

    public var id: String { asset.id }

    public init(asset: MediaAsset, decision: ReviewDecision, indexBeforeAction: Int) {
        self.asset = asset
        self.decision = decision
        self.indexBeforeAction = indexBeforeAction
    }
}
