import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch appState.route {
            case .onboarding:
                OnboardingView {
                    appState.finishOnboarding()
                }
            case .authorization:
                PhotoPermissionView()
            case .welcome:
                WelcomeView()
            case .cleaner:
                CleanerView()
            }
        }
        .animation(.snappy(duration: 0.38), value: appState.route)
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active:
                AnalyticsService.log(.sessionStarted)
                Task {
                    if appState.route == .authorization {
                        await appState.bootstrap()
                    }
                    await appState.refreshCleanupReminder()
                }
            case .background, .inactive:
                appState.endReviewSessionIfNeeded()
                if phase == .background {
                    AnalyticsService.log(.sessionEnded)
                }
            @unknown default:
                break
            }
        }
    }
}
