import UIKit
@preconcurrency import UserNotifications

final class BurnRollAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        MainActor.assumeIsolated {
            AnalyticsService.configure()
        }
        UNUserNotificationCenter.current().delegate = self
        return true
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
