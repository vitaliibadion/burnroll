# App Store screenshots (next version)

Upload **iPhone 6.9"** images (**1320×2868**) in this order. They are real BurnRoll UI from Simulator, composed on marketing frames.

English lives in this folder. Other App Store languages are in locale subfolders (`nl/`, `fr/`, `de/`, `it/`, `ja/`, `ko/`, `pl/`, `pt-BR/`, `zh-Hans/`, `es/`, `uk/`).

1. `01-swipe-decide-done.png`
2. `02-burn-the-clutter.png`
3. `03-keep-what-matters.png`
4. `04-review-before-delete.png`
5. `05-photos-stay-on-iphone.png`
6. `06-clear-space-your-way.png`

App Preview (optional, 15s, 1320×2868, H.264): `preview-6.9.mp4`

## Locales

In-app copy is in `BurnRoll/Localizable.xcstrings` and `BurnRoll/InfoPlist.xcstrings`. Regenerate after string edits:

```sh
python3 AppStore/Localization/generate_xcstrings.py
```

Portuguese is **pt-BR**. Simplified Chinese is **zh-Hans**.

## Recapture

Debug-only launch arguments: `-ScreenshotDemo -ScreenshotScene <cleaner|keep|burn|review|privacy|storage|complete>`.

```sh
# English UI captures (does not uninstall; Photos permission stays)
./AppStore/Screenshots/capture.sh

# All store languages (same simulator; do not erase it)
LOCALES=all ./AppStore/Screenshots/capture.sh

# Marketing frames. English stays here; others write to AppStore/Screenshots/<locale>/
./AppStore/Screenshots/.venv/bin/python ./AppStore/Screenshots/compose.py
```

Uses a dedicated Simulator named **BurnRoll Screenshots**. First run: allow Photos when the system sheet appears (`Allow Full Access`). Demo JPEGs in `demo-roll/` are gitignored. Do not erase or uninstall that simulator unless you are ready to grant Photos again.

Previous AppScreens export (2026-08-20) is superseded by this set. Licence for that older export remains in `Licence.txt`.
