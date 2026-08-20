# BurnRoll App Store submission checklist

Audited against Apple's App Review Guidelines and App Store Connect requirements for the v0.9 TestFlight beta.

Current status: core code, privacy copy, and analytics plumbing are in the project. Do not upload until every item in **Owner actions required before upload** is complete.

## Completed in the project

- [x] Final 1024×1024 App Icon is configured, opaque, and builds without asset-catalog errors.
- [x] `NSPhotoLibraryUsageDescription` explains reviewing, organizing, and removing photos on-device.
- [x] Photos permission is requested contextually after an explanatory screen, not automatically on launch.
- [x] Limited and full Photos authorization states are represented in Settings.
- [x] Destructive deletion requires a review queue, confirmation, and Apple Photos' system authorization.
- [x] Deleted items are accurately described as moving to Recently Deleted for up to 30 days.
- [x] Privacy manifest declares no tracking. It now declares product interaction, crash/diagnostic data, and device ID used by Firebase Analytics/Crashlytics.
- [x] The in-app privacy policy covers Photos, local reviewed state, Firebase Analytics, Crashlytics, and optional notifications.
- [x] Settings includes support contact for Vitalii Badion (`badion926@gmail.com`) and links to the public HTTPS privacy and support pages.
- [x] Static privacy and support pages live in `docs/` for GitHub Pages. Paste values and the 4+ age-rating answers from `AppStore/LISTING.md`.
- [x] The app has no account, purchases, ads, or BurnRoll backend. Photos stay on-device.
- [x] Analytics events are allowlisted and omit photo contents, filenames, paths, EXIF, and asset identifiers.
- [x] Notifications are optional, consent-first, locally scheduled, and can be disabled in the app.
- [x] `ITSAppUsesNonExemptEncryption` is `NO`; review this again if networking or encryption is added later.
- [x] Version and build are present (`0.9` / `1`).
- [x] The app is built with Xcode 26 and the iOS 26 SDK.

## Owner actions required before upload

- [ ] Add `BurnRoll/GoogleService-Info.plist` from the Firebase console for bundle ID `com.vitaliibadion.burnroll`. Confirm Analytics and Crashlytics receive a debug event and a test crash.
- [ ] Re-audit App Privacy in App Store Connect against the enabled Firebase SDKs and [Firebase's current Apple privacy documentation](https://firebase.google.com/docs/ios/app-privacy). Do not guess. Expected starting point for this build: no tracking; usage/diagnostics/device ID collected, not linked to an account.
- [ ] Select the correct paid Apple Developer **Team** in Signing & Capabilities if the current Team ID is not the shipping account.
- [ ] Confirm that `com.vitaliibadion.burnroll` is an App ID owned by that team, or replace it with your registered unique bundle identifier.
- [ ] Enable GitHub Pages on [`vitaliibadion/burnroll`](https://github.com/vitaliibadion/burnroll) (`main` / `/docs`) and confirm these HTTPS URLs load without a login: `https://vitaliibadion.github.io/burnroll/privacy/` and `https://vitaliibadion.github.io/burnroll/support/`.
- [ ] Paste those URLs into App Store Connect Privacy Policy URL and Support URL. Email alone is not a Support URL.
- [ ] Complete Apple's age-rating questionnaire using `AppStore/LISTING.md` (expected **4+**, Made for Kids: No). Do not skip renamed questions; keep the same intent.
- [ ] Add final description, keywords, promotional text if used, category, copyright owner (`© 2026 Vitalii Badion`), review contact (`Vitalii Badion` / `badion926@gmail.com`), screenshots, and all required localized metadata. Upload-ready iPhone 6.9" screenshots (1320×2868) are in `AppStore/Screenshots/`.
- [ ] Add App Review notes explaining that Photos access is core to the app and that deletion always requires review plus confirmation.
- [ ] Test on at least one physical iPhone with full Photos access, limited Photos access, denied access, iCloud-only assets, Live Photos, RAW, large videos, and Low Power/low-storage conditions.
- [ ] Confirm All / Reviewed / Not Reviewed switching stays responsive on a large library.
- [ ] Confirm a smart reminder can be scheduled, a test notification appears, and tapping it opens the app.
- [ ] Create a signed Release archive, run Xcode's **Validate App**, resolve every warning, then upload to App Store Connect/TestFlight.
- [ ] Run a TestFlight smoke test before selecting the build for review.

## Suggested App Review notes

> BurnRoll is an on-device Photos library review utility. Photos read/write permission is required to display the user's selected library and, only after the user adds items to a local burn queue and confirms, move those items to Apple Photos' Recently Deleted album. No media is uploaded to BurnRoll servers. Optional Firebase Analytics and Crashlytics collect product usage and crash diagnostics only; they do not receive photos or photo identifiers. Monthly notifications are optional and locally scheduled. No account or purchase is required.

## Required metadata references

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Upcoming submission requirements](https://developer.apple.com/news/upcoming-requirements/)
- [App privacy management](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [Required platform-version properties](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Required-reason API declarations](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)
- [Export compliance overview](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance)
- [Firebase Apple privacy](https://firebase.google.com/docs/ios/app-privacy)
