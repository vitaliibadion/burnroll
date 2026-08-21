@preconcurrency import Photos
import PhotosUI
import UIKit

enum PhotoAuthorizationService {
    static var status: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    static var hasUsableAccess: Bool {
        switch status {
        case .authorized, .limited:
            true
        default:
            false
        }
    }

    static func requestAccess() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    /// Completes the limited-library selection. `requestAuthorization` can return
    /// `.limited` before PhotoKit exposes the chosen assets; presenting this
    /// picker (or waiting for `photoLibraryDidChange`) is what commits them.
    @MainActor
    static func presentLimitedLibraryPicker() async {
        guard status == .limited, let presenter = topViewController() else { return }
        _ = await PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: presenter)
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
            ?? scenes.first?.windows.first
        guard var controller = window?.rootViewController else { return nil }
        while let presented = controller.presentedViewController {
            controller = presented
        }
        return controller
    }
}

