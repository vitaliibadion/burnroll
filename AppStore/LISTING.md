# App Store Connect listing values (v1.1.0)

Paste these into App Store Connect. Age rating is **not** an Xcode / Info.plist field; it lives only in Connect after you answer the questionnaire.

Name, subtitle, keywords, promotional text, description, and What’s New for every listing language live in local `ASO.md` (gitignored). Do not commit that file.

## URLs

| Field | Value |
| --- | --- |
| Privacy Policy URL | `https://vitaliibadion.github.io/burnroll/privacy/` |
| Support URL | `https://vitaliibadion.github.io/burnroll/support/` |

Terms of Use (in-app and App Store Connect if asked): `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

Publish `docs/` with GitHub Pages first. Apple will reject a 404 or a login-walled page. Privacy and Support must mention BurnRoll Pro billing (Apple processes payment, 3-day Weekly trial, restore, cancel in Apple Account → Subscriptions).

## Version 1.1.0 in Connect

1. App Store Connect → BurnRoll → **+ Version or Platform** → **1.1.0**.
2. Paste What’s New from `ASO.md` (English below). Attach the three Pro IAPs to this version.
3. Archive in Xcode with marketing version **1.1.0**, build **3**, then upload.

### What’s New (English)

```
BurnRoll Pro is here.

Unlimited Keep and Burn with an optional Apple subscription. Weekly includes a 3-day free trial. Monthly and Yearly have no trial. Cancel anytime in Apple Account → Subscriptions.

• Billed through your Apple Account
• Restore purchases in Settings
• Photos still stay on this iPhone
```

## App Privacy (nutrition labels)

Existing answers stay. For this subscription release, also declare **Purchase History**: not linked to identity, not used for tracking, purposes **App Functionality** and **Analytics**. Do not declare Payment Info — Apple collects card details, BurnRoll does not.

## Contact (also used as App Review contact)

| Field | Value |
| --- | --- |
| Developer / copyright | Vitalii Badion |
| Support email | burnrollsupport@gmail.com |
| Copyright | © 2026 Vitalii Badion |

The support email is shown in Settings and on the public pages. The legal name is App Store Connect metadata only (copyright and review contact). It is not required in the app or on the policy pages.

## Category

Photo & Video (primary). Utilities is a reasonable secondary if Connect asks for one.

## Age rating: 4+

BurnRoll is a personal Photos utility. It does not contain mature media, a social feed, chat, ads, or an unrestricted in-app browser. The user’s own camera roll is not treated as social user-generated content.

**Made for Kids:** No.

Answer the current App Store Connect age-rating questionnaire as follows. If Apple has renamed a row, keep the same intent: no mature content, no unrestricted web, no UGC visible to other people.

| Question | Answer |
| --- | --- |
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Gambling and Contests | None |
| Unrestricted Web Access | No |
| User-Generated Content (users can post content other people can see, without you reviewing all of it) | No |

Expected result: **4+**.

Do not enable **Made for Kids**. BurnRoll is a general-audience utility, not a children’s app.
