import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch appState.route {
            case .onboarding:
                OnboardingView(
                    isReplay: appState.isReplayingOnboarding,
                    hasReviewedMedia: appState.hasReviewedMedia
                ) {
                    appState.finishOnboarding()
                }
            case .paywall:
                PaywallView {
                    appState.finishPaywall()
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
        .overlay {
            if appState.isShowingLaunchFire {
                LaunchFireView()
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.42), value: appState.isShowingLaunchFire)
        .fullScreenCover(isPresented: screenshotCompletePresented) {
            CleaningCompleteView(
                summary: appState.lastDeletionSummary ?? AppState.DeletionSummary(
                    itemCount: 93,
                    clearedBytes: 1_800_000_000,
                    reviewDuration: 12 * 60
                )
            ) {}
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active:
                AnalyticsService.log(.sessionStarted)
                SuperwallService.shared.refreshUserAttributes()
                Task {
                    if appState.route == .authorization {
                        await appState.bootstrap()
                    }
                    await appState.handlePhotoLibraryChange()
                    await SuperwallService.shared.syncSubscriptionStatus()
                    if appState.route == .paywall, appState.subscriptions.isSubscribed {
                        appState.finishPaywall()
                    }
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
        .onOpenURL { url in
            _ = SuperwallService.handleDeepLink(url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if let url = activity.webpageURL {
                _ = SuperwallService.handleDeepLink(url)
            }
        }
    }

    private var screenshotCompletePresented: Binding<Bool> {
        #if DEBUG
        Binding(
            get: { ScreenshotDemo.isActive && ScreenshotDemo.shouldShowCleaningComplete },
            set: { _ in }
        )
        #else
        .constant(false)
        #endif
    }
}
