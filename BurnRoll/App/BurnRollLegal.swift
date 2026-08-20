import Foundation

/// Public listing copy shared by Settings and the GitHub Pages site in `docs/`.
/// After changing policy text, update `docs/privacy/index.html` to match.
enum BurnRollLegal {
    static let developerName = "Vitalii Badion"
    static let supportEmail = "burnrollsupport@gmail.com"
    static let copyright = "© 2026 Vitalii Badion"
    static let policyVersion = "0.9"

    static let privacyPolicyURL = URL(string: "https://vitaliibadion.github.io/burnroll/privacy/")!
    static let supportURL = URL(string: "https://vitaliibadion.github.io/burnroll/support/")!
    static let supportMailtoURL = URL(string: "mailto:burnrollsupport@gmail.com")!

    static let ageRating = "4+"

    struct PolicySection: Identifiable {
        let title: String
        let text: String
        var id: String { title }
    }

    static let recentlyDeletedNotice =
        "Apple Photos keeps deleted items in Recently Deleted for up to 30 days. "
        + "Empty that album to recover storage immediately."

    static let policySections: [PolicySection] = [
        PolicySection(
            title: "Photos and videos",
            text: "BurnRoll requires Photo Library access for its core functionality. With your permission, it uses Apple’s Photos framework to display the library you make available, calculate local counts and estimates, and move only the items you confirm to Recently Deleted. Photos are processed locally on this device. BurnRoll does not upload your photos or videos to BurnRoll servers, and photo contents are not sent to Firebase Analytics."
        ),
        PolicySection(
            title: "iCloud Photos",
            text: "If you use iCloud Photos, Apple may download or synchronize library items according to your iCloud settings. Deletions made through BurnRoll may also synchronize across devices signed in to the same Apple Account. This Apple service is separate from BurnRoll and is controlled by your device and iCloud settings."
        ),
        PolicySection(
            title: "Reviewed state",
            text: "BurnRoll stores a local checkpoint of Apple Photos identifiers so it can remember which items you have already reviewed and show All, Reviewed, and Not Reviewed collections. That checkpoint contains no photo or video data and remains on this device unless a future release adds optional cloud sync. Review history, deletion choices, filenames, and other photo-library metadata are not uploaded to Firebase."
        ),
        PolicySection(
            title: "On-device preferences",
            text: "BurnRoll also stores onboarding status, haptic and reminder choices, cleanup counts, size estimates and review durations, and the date of your last confirmed cleanup for streak calculation. There is no BurnRoll account. These preferences remain on the device until you change them, reset the review bookmark, reset the app, or delete the app."
        ),
        PolicySection(
            title: "Analytics",
            text: "BurnRoll uses Firebase Analytics to understand aggregate product usage, such as app launches, session activity, onboarding and permission outcomes, filter selection, and counts of review actions. Firebase may also receive technical app and device information. Analytics do not include your photos, image thumbnails, filenames, file paths, EXIF metadata, or identifiers that uniquely identify a photo."
        ),
        PolicySection(
            title: "Crash reporting",
            text: "BurnRoll uses Firebase Crashlytics for crash diagnostics and application stability. Crash reports describe the app’s technical state. They are not used to send your photos or photo-library contents."
        ),
        PolicySection(
            title: "Notifications",
            text: "Cleanup reminders are optional and require your permission. If you opt in, BurnRoll stores an on-device library baseline and schedules a local reminder for your selected threshold of 20–500 additional photos, approximately 5 GB of estimated media growth, or an exact 30-day interval. iOS does not continuously wake BurnRoll to inspect Photos while the app is closed, so BurnRoll evaluates accumulation when the app opens and schedules a conservative local reminder. You can send a five-second test, turn reminders off in BurnRoll Settings, or change notification permission in iOS Settings."
        ),
        PolicySection(
            title: "Your controls",
            text: "You can limit or revoke Photos and notification access at any time in iOS Settings. BurnRoll does not retain a server copy of your library or preferences, so there is no remote personal-data account to delete."
        ),
        PolicySection(
            title: "Contact",
            text: "BurnRoll is developed by Vitalii Badion. For privacy or support questions, email burnrollsupport@gmail.com."
        )
    ]
}
