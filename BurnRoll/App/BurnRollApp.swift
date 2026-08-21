import SwiftUI

@main
struct BurnRollApp: App {
    @UIApplicationDelegateAdaptor(BurnRollAppDelegate.self) private var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task {
                    let startedAt = Date()
                    await appState.bootstrap()
                    await appState.refreshCleanupReminder()
                    let minimumDuration: TimeInterval = 1.45
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
