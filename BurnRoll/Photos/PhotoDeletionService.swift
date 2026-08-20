import Foundation
@preconcurrency import Photos

enum PhotoDeletionService {
    struct DeletionResult: Sendable {
        let deletedIdentifiers: Set<String>
        let unavailableIdentifiers: Set<String>
    }

    enum DeletionError: LocalizedError {
        case noAssetsFound

        var errorDescription: String? {
            "The selected items could not be found in the Photos library."
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

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        }

        return DeletionResult(
            deletedIdentifiers: foundIdentifiers,
            unavailableIdentifiers: requestedIdentifiers.subtracting(foundIdentifiers)
        )
    }
}
