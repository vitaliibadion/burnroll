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
                    await appState.bootstrap()
                    await appState.refreshCleanupReminder()
                }
        }
    }
}
