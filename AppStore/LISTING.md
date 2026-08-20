# App Store Connect listing values (v0.9)

Paste these into App Store Connect. Age rating is **not** an Xcode / Info.plist field; it lives only in Connect after you answer the questionnaire.

## URLs

| Field | Value |
| --- | --- |
| Privacy Policy URL | `https://vitaliibadion.github.io/burnroll/privacy/` |
| Support URL | `https://vitaliibadion.github.io/burnroll/support/` |

Publish `docs/` with GitHub Pages first. Apple will reject a 404 or a login-walled page.

## Contact (also used as App Review contact)

| Field | Value |
| --- | --- |
| Developer / copyright | Vitalii Badion |
| Support email | badion926@gmail.com |
| Copyright | © 2026 Vitalii Badion |

The in-app Settings screen emails this address and links to the Support URL.

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
