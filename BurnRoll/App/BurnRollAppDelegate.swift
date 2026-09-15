import UIKit
import SuperwallKit
@preconcurrency import UserNotifications

final class BurnRollAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        MainActor.assumeIsolated {
            SuperwallService.configure()
            AnalyticsService.configure()
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        Superwall.handleDeepLink(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            return Superwall.handleDeepLink(url)
        }
        return false
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        if notification.request.identifier == CleanupReminderService.requestIdentifier {
            NotificationCenter.default.post(
                name: CleanupReminderService.deliveredNotificationName,
                object: nil
            )
        }
        return [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if response.notification.request.identifier == CleanupReminderService.requestIdentifier {
            NotificationCenter.default.post(
                name: CleanupReminderService.deliveredNotificationName,
                object: nil
            )
        }
        await MainActor.run {
            AnalyticsService.log(.notificationOpened)
        }
    }
}
