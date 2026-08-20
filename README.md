# BurnRoll

BurnRoll is a native, local-first iPhone camera roll cleaner. Swipe left to add an item to the burn queue, swipe right to keep it, then review and explicitly confirm before PhotoKit performs any deletion.

Version `0.9` is the TestFlight beta line. There is no subscription or paywall.

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
- Pure Swift core state tests runnable with Swift Package Manager

## App Store URLs

Apple needs public HTTPS pages. The site source is `docs/`. After GitHub Pages is enabled on `/docs`:

- Privacy Policy: `https://vitaliibadion.github.io/burnroll/privacy/`
- Support: `https://vitaliibadion.github.io/burnroll/support/`

Support contact is `burnrollsupport@gmail.com`. Age-rating answers (4+) are in `AppStore/LISTING.md`.

## Tests

Run `swift test` from the repository root for session, review-scope, reminder-planner, and storage-estimation tests. An Xcode installation with a matching Swift SDK/toolchain is required.
