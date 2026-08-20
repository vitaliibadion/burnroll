import Testing
@testable import BurnRollCore

@Suite("Cleanup time estimate")
struct CleanupTimeEstimateTests {
    @Test("Zero photos do not produce an estimate")
    func zeroPhotosAreSkipped() {
        #expect(CleanupTimeEstimate(photoCount: 0) == nil)
    }

    @Test("Each photo adds one second")
    func estimateUsesOneSecondPerPhoto() {
        #expect(CleanupTimeEstimate(photoCount: 1)?.estimatedSeconds == 1)
        #expect(CleanupTimeEstimate(photoCount: 59)?.durationPhrase == "about 59 seconds")
        #expect(CleanupTimeEstimate(photoCount: 60)?.durationPhrase == "about 1 minute")
        #expect(CleanupTimeEstimate(photoCount: 90)?.durationPhrase == "about 1 min 30 sec")
    }

    @Test("Estimate is capped at five minutes")
    func estimateCapsAtFiveMinutes() {
        let estimate = CleanupTimeEstimate(photoCount: 500)

        #expect(estimate?.estimatedSeconds == 300)
        #expect(estimate?.durationPhrase == "up to 5 minutes")
    }
}
