@preconcurrency import Photos

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
}

