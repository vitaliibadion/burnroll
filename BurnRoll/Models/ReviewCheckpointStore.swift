import Foundation

public struct ReviewCheckpointStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public static func applicationSupport(
        fileManager: FileManager = .default
    ) -> ReviewCheckpointStore {
        let baseURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory

        return ReviewCheckpointStore(
            fileURL: baseURL
                .appendingPathComponent("BurnRoll", isDirectory: true)
                .appendingPathComponent("review-checkpoint.log", isDirectory: false)
        )
    }

    public func load() -> Set<String> {
        guard
            let data = try? Data(contentsOf: fileURL),
            !data.isEmpty
        else {
            return []
        }

        var reviewedIdentifiers: Set<String> = []
        let contents = String(decoding: data, as: UTF8.self)

        for line in contents.split(separator: "\n", omittingEmptySubsequences: true) {
            guard
                let operation = line.first,
                let encodedIdentifier = Data(
                    base64Encoded: String(line.dropFirst())
                ),
                let identifier = String(data: encodedIdentifier, encoding: .utf8)
            else {
                continue
            }

            switch operation {
            case "+":
                reviewedIdentifiers.insert(identifier)
            case "-":
                reviewedIdentifiers.remove(identifier)
            default:
                continue
            }
        }

        return reviewedIdentifiers
    }

    public func recordReviewed(identifier: String) throws {
        try append(operation: "+", identifier: identifier)
    }

    public func recordNotReviewed(identifier: String) throws {
        try append(operation: "-", identifier: identifier)
    }

    public func reset() throws {
        try ensureParentDirectoryExists()
        try Data().write(to: fileURL, options: .atomic)
    }

    private func append(operation: Character, identifier: String) throws {
        try ensureParentDirectoryExists()

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            guard FileManager.default.createFile(atPath: fileURL.path, contents: nil) else {
                throw CocoaError(.fileWriteUnknown)
            }
        }

        let encodedIdentifier = Data(identifier.utf8).base64EncodedString()
        let entry = Data("\(operation)\(encodedIdentifier)\n".utf8)
        let handle = try FileHandle(forWritingTo: fileURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: entry)
    }

    private func ensureParentDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
