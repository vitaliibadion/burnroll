import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics

/// Product analytics and crash reporting. Events describe app behavior only.
/// Photo contents, identifiers, filenames, paths, and EXIF are never logged.
@MainActor
enum AnalyticsService {
    enum Event: String {
        case appOpened = "app_opened"
        case sessionStarted = "session_started"
        case sessionEnded = "session_ended"
        case onboardingStarted = "onboarding_started"
        case onboardingCompleted = "onboarding_completed"
        case photoPermissionRequested = "photo_permission_requested"
        case photoPermissionGranted = "photo_permission_granted"
        case photoPermissionDenied = "photo_permission_denied"
        case reviewSessionStarted = "review_session_started"
        case photoReviewed = "photo_reviewed"
        case photoKept = "photo_kept"
        case photoMarkedForDeletion = "photo_marked_for_deletion"
        case reviewSessionCompleted = "review_session_completed"
        case filterSelected = "filter_selected"
        case filterRenderCompleted = "filter_render_completed"
        case notificationPermissionRequested = "notification_permission_requested"
        case notificationPermissionGranted = "notification_permission_granted"
        case notificationPermissionDenied = "notification_permission_denied"
        case notificationScheduled = "notification_scheduled"
        case notificationOpened = "notification_opened"
    }

    enum FilterType: String {
        case all
        case reviewed
        case notReviewed = "not_reviewed"
    }

    private static let allowedParameterKeys: Set<String> = [
        "app_version",
        "build_number",
        "device_category",
        "os_version",
        "filter_type",
        "filter_render_duration_ms",
        "photos_reviewed_count",
        "session_duration_ms",
        "decision",
        "media_type",
        "authorization_status"
    ]

    private static let allowedStringValues: Set<String> = [
        "phone",
        "pad",
        "mac",
        "tv",
        "carplay",
        "vision",
        "unspecified",
        "all",
        "reviewed",
        "not_reviewed",
        "keep",
        "burn",
        "photo",
        "video",
        "full",
        "limited",
        "denied",
        "restricted",
        "not_determined",
        "unknown"
    ]

    private static var configured = false
    private static var cachedDeviceCategory = "phone"
    private static var cachedOSVersion = ""

    static var isEnabled: Bool { configured }

    static func configure() {
        guard !configured else { return }
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else {
            return
        }

        FirebaseApp.configure()
        cachedDeviceCategory = currentDeviceCategory()
        cachedOSVersion = UIDevice.current.systemVersion
        configured = true
        log(.appOpened, parameters: contextParameters())
    }

    static func log(_ event: Event, parameters: [String: Any] = [:]) {
        guard isEnabled else { return }

        var payload = contextParameters()
        for (key, value) in parameters {
            payload[key] = value
        }

        Analytics.logEvent(event.rawValue, parameters: sanitized(payload))
    }

    static func logFilter(
        _ filterType: FilterType,
        durationMilliseconds: Int
    ) {
        let parameters: [String: Any] = [
            "filter_type": filterType.rawValue,
            "filter_render_duration_ms": max(0, durationMilliseconds)
        ]
        log(.filterSelected, parameters: parameters)
        log(.filterRenderCompleted, parameters: parameters)
    }

    static func logReviewDecision(isKeep: Bool, isPhoto: Bool) {
        let parameters: [String: Any] = [
            "decision": isKeep ? "keep" : "burn",
            "media_type": isPhoto ? "photo" : "video"
        ]
        log(.photoReviewed, parameters: parameters)
        log(isKeep ? .photoKept : .photoMarkedForDeletion, parameters: parameters)
    }

    static func recordNonFatal(context: String, code: Int = 1) {
        guard isEnabled else { return }

        let error = NSError(
            domain: "BurnRoll.\(sanitizedContext(context))",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: "\(sanitizedContext(context)) failed"]
        )
        Crashlytics.crashlytics().record(error: error)
    }

    static func setLibraryContext(
        authorizationStatus: String,
        assetCount: Int,
        reviewScope: FilterType
    ) {
        guard isEnabled else { return }

        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCustomValue(sanitizedContext(authorizationStatus), forKey: "authorization_status")
        crashlytics.setCustomValue(max(0, assetCount), forKey: "library_asset_count")
        crashlytics.setCustomValue(reviewScope.rawValue, forKey: "review_scope")
    }

    private static func contextParameters() -> [String: Any] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        return [
            "app_version": version,
            "build_number": build,
            "device_category": cachedDeviceCategory,
            "os_version": cachedOSVersion
        ]
    }

    private static func currentDeviceCategory() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: "phone"
        case .pad: "pad"
        case .mac: "mac"
        case .tv: "tv"
        case .carPlay: "carplay"
        case .vision: "vision"
        case .unspecified: "unspecified"
        @unknown default: "unknown"
        }
    }

    private static func sanitized(_ parameters: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        result.reserveCapacity(parameters.count)

        for (key, value) in parameters {
            guard allowedParameterKeys.contains(key) else { continue }

            switch value {
            case let number as Int:
                result[key] = number
            case let number as Int64:
                result[key] = Int(clamping: number)
            case let number as Double:
                result[key] = number
            case let string as String:
                if key == "app_version" || key == "build_number" || key == "os_version" {
                    guard isSafeVersionString(string) else { continue }
                    result[key] = string
                } else if allowedStringValues.contains(string) {
                    result[key] = string
                }
            default:
                continue
            }
        }

        return result
    }

    private static func isSafeVersionString(_ string: String) -> Bool {
        guard string.count <= 24 else { return false }
        return string.allSatisfy { $0.isNumber || $0 == "." || $0 == "-" }
    }

    private static func sanitizedContext(_ context: String) -> String {
        let allowed = context.filter { $0.isLetter || $0 == "_" }
        return allowed.isEmpty ? "unknown" : String(allowed.prefix(40))
    }
}
