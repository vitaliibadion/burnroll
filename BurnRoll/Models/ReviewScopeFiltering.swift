import Foundation

public enum ReviewScopeFiltering: Sendable {
    public enum Scope: String, Sendable {
        case notReviewed
        case reviewed
        case all
    }

    public struct Counts: Equatable, Sendable {
        public let notReviewed: Int
        public let reviewed: Int
        public let all: Int

        public init(notReviewed: Int, reviewed: Int, all: Int) {
            self.notReviewed = max(0, notReviewed)
            self.reviewed = max(0, reviewed)
            self.all = max(0, all)
        }

        public func value(for scope: Scope) -> Int {
            switch scope {
            case .notReviewed: notReviewed
            case .reviewed: reviewed
            case .all: all
            }
        }
    }

    public static func includes(isReviewed: Bool, scope: Scope) -> Bool {
        switch scope {
        case .notReviewed: !isReviewed
        case .reviewed: isReviewed
        case .all: true
        }
    }

    public static func visibleIndexes(
        identifiers: [String],
        reviewedIdentifiers: Set<String>,
        scope: Scope
    ) -> [Int] {
        switch scope {
        case .all:
            return Array(identifiers.indices)
        case .reviewed, .notReviewed:
            var indexes: [Int] = []
            indexes.reserveCapacity(identifiers.count)
            for (index, identifier) in identifiers.enumerated() {
                if includes(
                    isReviewed: reviewedIdentifiers.contains(identifier),
                    scope: scope
                ) {
                    indexes.append(index)
                }
            }
            return indexes
        }
    }

    public static func counts(
        identifiers: [String],
        reviewedIdentifiers: Set<String>
    ) -> Counts {
        var reviewedCount = 0
        for identifier in identifiers where reviewedIdentifiers.contains(identifier) {
            reviewedCount += 1
        }

        return Counts(
            notReviewed: identifiers.count - reviewedCount,
            reviewed: reviewedCount,
            all: identifiers.count
        )
    }
}
