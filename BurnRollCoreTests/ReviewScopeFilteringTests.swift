import Foundation
import Testing
@testable import BurnRollCore

@Suite("Review scope filtering")
struct ReviewScopeFilteringTests {
    private let identifiers = ["a", "b", "c", "d", "e"]
    private let reviewed: Set<String> = ["b", "d"]

    @Test("All scope keeps canonical order without rebuilding identifiers")
    func allScopeReturnsEveryIndex() {
        let indexes = ReviewScopeFiltering.visibleIndexes(
            identifiers: identifiers,
            reviewedIdentifiers: reviewed,
            scope: .all
        )

        #expect(indexes == [0, 1, 2, 3, 4])
    }

    @Test("Reviewed scope uses hashed lookup instead of scanning unmatched assets extra times")
    func reviewedScopeReturnsOnlyReviewedIndexes() {
        let indexes = ReviewScopeFiltering.visibleIndexes(
            identifiers: identifiers,
            reviewedIdentifiers: reviewed,
            scope: .reviewed
        )

        #expect(indexes == [1, 3])
    }

    @Test("Not reviewed scope excludes remembered identifiers")
    func notReviewedScopeExcludesReviewedIdentifiers() {
        let indexes = ReviewScopeFiltering.visibleIndexes(
            identifiers: identifiers,
            reviewedIdentifiers: reviewed,
            scope: .notReviewed
        )

        #expect(indexes == [0, 2, 4])
    }

    @Test("Counts are derived from the canonical identifier list")
    func countsMatchCanonicalCollection() {
        let counts = ReviewScopeFiltering.counts(
            identifiers: identifiers,
            reviewedIdentifiers: reviewed
        )

        #expect(counts.all == 5)
        #expect(counts.reviewed == 2)
        #expect(counts.notReviewed == 3)
        #expect(counts.value(for: .reviewed) == 2)
    }

    @Test("Identifiers missing from the library do not inflate reviewed counts")
    func missingLibraryAssetsAreIgnored() {
        let counts = ReviewScopeFiltering.counts(
            identifiers: identifiers,
            reviewedIdentifiers: reviewed.union(["deleted-asset"])
        )

        #expect(counts.reviewed == 2)
        #expect(counts.all == 5)
    }
}
