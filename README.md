# BurnRoll

BurnRoll is a native, local-first iPhone camera roll cleaner. Swipe left to add an item to the burn queue, swipe right to keep it, then review and explicitly confirm before PhotoKit performs any deletion.

Version `1.1.0` is the next App Store release (build 3). Production remains `1.0` until this version ships. BurnRoll Pro is an optional auto-renewable subscription (Weekly with a 3-day trial, Monthly, and Yearly) purchased through Apple. The paywall is native SwiftUI; Superwall is used only for subscription status and analytics.

## Current implementation

- Three-page onboarding and read/write Photos authorization
- Newest-first PhotoKit fetch with All / Reviewed / Not Reviewed switching from a cached identifier index
- Memory-efficient thumbnails with `PHCachingImageManager` preheating
- Swipe-to-keep and swipe-to-burn interactions with haptics
- In-memory burn queue, storage estimate, and one-level undo
- Fullscreen photo zoom and user-initiated video playback
- Burn review, item removal, destructive confirmation, and PhotoKit deletion
- Optional local smart reminders evaluated when the app opens
- Firebase Analytics and Crashlytics for product usage and stability, with no photo contents or identifiers
- Light/dark adaptive visual system, Reduce Motion support, and VoiceOver actions
- Native BurnRoll Pro paywall with Weekly (3-day trial), Monthly, and Yearly auto-renewable subscriptions via StoreKit 2
- Localization for Dutch, English, French, German, Italian, Japanese, Korean, Polish, Brazilian Portuguese, Simplified Chinese, Spanish, and Ukrainian
- Pure Swift core state tests runnable with Swift Package Manager

## App Store URLs

Apple needs public HTTPS pages. The site source is `docs/`. After GitHub Pages is enabled on `/docs`:

- Privacy Policy: `https://vitaliibadion.github.io/burnroll/privacy/`
- Support: `https://vitaliibadion.github.io/burnroll/support/`

Support contact is `burnrollsupport@gmail.com`. Age-rating answers (4+) are in `AppStore/LISTING.md`.

## Tests

Run `swift test` from the repository root for session, review-scope, reminder-planner, and storage-estimation tests. An Xcode installation with a matching Swift SDK/toolchain is required.
