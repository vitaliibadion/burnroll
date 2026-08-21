import Foundation
@preconcurrency import Photos

enum PhotoDeletionService {
    struct DeletionResult: Sendable {
        let deletedIdentifiers: Set<String>
        let unavailableIdentifiers: Set<String>
    }

    enum DeletionError: LocalizedError, Equatable {
        case noAssetsFound
        case userCancelled
        case failed

        var errorDescription: String? {
            switch self {
            case .noAssetsFound:
                "The selected items could not be found in the Photos library."
            case .userCancelled:
                "Deletion was cancelled. Your burn queue is unchanged."
            case .failed:
                "Photos couldn’t complete the deletion. Try again, and confirm Delete on the system sheet."
            }
        }

        var isUserCancellation: Bool { self == .userCancelled }

        static func from(_ error: Error) -> DeletionError {
            if let deletionError = error as? DeletionError {
                return deletionError
            }

            if error is CancellationError {
                return .userCancelled
            }

            if isUserCancelledPhotosError(error) {
                return .userCancelled
            }

            return .failed
        }

        private static func isUserCancelledPhotosError(_ error: Error) -> Bool {
            var current: NSError? = error as NSError
            var seen = Set<ObjectIdentifier>()

            while let nsError = current {
                let identity = ObjectIdentifier(nsError)
                guard seen.insert(identity).inserted else { break }

                if nsError.code == CocoaError.userCancelled.rawValue
                    || nsError.code == PHPhotosError.userCancelled.rawValue {
                    return true
                }

                if nsError.domain == PHPhotosErrorDomain,
                   nsError.code == PHPhotosError.userCancelled.rawValue {
                    return true
                }

                current = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
            }

            return false
        }
    }

    static func delete(localIdentifiers: [String]) async throws -> DeletionResult {
        let requestedIdentifiers = Set(localIdentifiers)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
        guard assets.count > 0 else { throw DeletionError.noAssetsFound }

        var foundIdentifiers = Set<String>()
        assets.enumerateObjects { asset, _, _ in
            foundIdentifiers.insert(asset.localIdentifier)
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets)
            }
        } catch {
            throw DeletionError.from(error)
        }

        return DeletionResult(
            deletedIdentifiers: foundIdentifiers,
            unavailableIdentifiers: requestedIdentifiers.subtracting(foundIdentifiers)
        )
    }
}
