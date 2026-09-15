import SwiftUI

@main
struct BurnRollApp: App {
    @UIApplicationDelegateAdaptor(BurnRollAppDelegate.self) private var appDelegate
    @State private var appState: AppState

    init() {
        SuperwallService.configure()
        _appState = State(initialValue: AppState())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(appState.subscriptions)
                .task {
                    let startedAt = Date()
                    appState.subscriptions.start()
                    await SuperwallService.shared.syncSubscriptionStatus()
                    await appState.bootstrap()
                    await appState.refreshCleanupReminder()
                    var minimumDuration: TimeInterval = 1.45
                    #if DEBUG
                    if ScreenshotDemo.isActive {
                        minimumDuration = 0
                    }
                    #endif
                    let remaining = minimumDuration - Date().timeIntervalSince(startedAt)
                    if remaining > 0 {
                        try? await Task.sleep(for: .seconds(remaining))
                    }
                    withAnimation(.easeOut(duration: 0.42)) {
                        appState.finishLaunchFire()
                    }
                }
        }
    }
}

