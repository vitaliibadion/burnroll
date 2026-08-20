import Foundation
import Testing
@testable import BurnRollCore

@Suite("Review checkpoint")
struct ReviewCheckpointStoreTests {
    @Test("Reviewed identifiers persist across store instances")
    func reviewedIdentifiersPersist() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileURL = directory.appendingPathComponent("checkpoint.log")
        let store = ReviewCheckpointStore(fileURL: fileURL)

        try store.recordReviewed(identifier: "photo-one/L0/001")
        try store.recordReviewed(identifier: "фото-two/L0/001")
        try store.recordNotReviewed(identifier: "photo-one/L0/001")

        let reloadedStore = ReviewCheckpointStore(fileURL: fileURL)
        #expect(reloadedStore.load() == ["фото-two/L0/001"])
    }

    @Test("Reset clears the complete review bookmark")
    func resetClearsBookmark() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ReviewCheckpointStore(
            fileURL: directory.appendingPathComponent("checkpoint.log")
        )

        try store.recordReviewed(identifier: "one")
        try store.recordReviewed(identifier: "two")
        try store.reset()

        #expect(store.load().isEmpty)
    }
}
