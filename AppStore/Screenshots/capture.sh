#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SHOTS="$ROOT/AppStore/Screenshots"
CAPTURES="$SHOTS/captures"
DEMO="$SHOTS/demo-roll"
BUNDLE="com.vitaliibadion.burnroll"
DEVICE_NAME="BurnRoll Screenshots"
SCHEME="BurnRoll"

# LOCALES="en" (default) or "all" or a comma list: "nl,fr,de"
LOCALES_ARG="${LOCALES:-en}"
# Uninstall wipes Photos permission. Keep the installed app unless you need a clean install.
REINSTALL="${REINSTALL:-0}"

locale_apple_args() {
  case "$1" in
    en) echo "(en-US)" "en_US" ;;
    nl) echo "(nl)" "nl_NL" ;;
    fr) echo "(fr)" "fr_FR" ;;
    de) echo "(de)" "de_DE" ;;
    it) echo "(it)" "it_IT" ;;
    ja) echo "(ja)" "ja_JP" ;;
    ko) echo "(ko)" "ko_KR" ;;
    pl) echo "(pl)" "pl_PL" ;;
    pt-BR) echo "(pt-BR)" "pt_BR" ;;
    zh-Hans) echo "(zh-Hans)" "zh_CN" ;;
    es) echo "(es)" "es_ES" ;;
    uk) echo "(uk)" "uk_UA" ;;
    *) echo "Unknown locale $1" >&2; return 1 ;;
  esac
}

mkdir -p "$CAPTURES"

if ! xcrun simctl list devices | grep -q "$DEVICE_NAME"; then
  echo "Creating $DEVICE_NAME"
  xcrun simctl create "$DEVICE_NAME" "iPhone 17 Pro Max"
fi

# Don't erase by default: it wipes Photos permission on the screenshot device.
if [[ "${ERASE_SIM:-0}" == "1" ]]; then
  echo "Erasing and booting $DEVICE_NAME"
  xcrun simctl shutdown "$DEVICE_NAME" 2>/dev/null || true
  xcrun simctl erase "$DEVICE_NAME"
fi
xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_NAME" -b

UDID="$(xcrun simctl list devices | sed -n 's/.*BurnRoll Screenshots (\([A-F0-9-]\{36\}\)).*/\1/p' | head -1)"
echo "UDID $UDID"

echo "Building BurnRoll"
xcodebuild \
  -project "$ROOT/BurnRoll.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
  -derivedDataPath "$ROOT/DerivedData/ScreenshotDemo" \
  CODE_SIGNING_ALLOWED=YES \
  build

APP="$(find "$ROOT/DerivedData/ScreenshotDemo" -name 'BurnRoll.app' -type d | head -1)"
echo "App $APP"

if [[ "$REINSTALL" == "1" ]]; then
  xcrun simctl uninstall "$UDID" "$BUNDLE" 2>/dev/null || true
fi
xcrun simctl install "$UDID" "$APP"

echo "Seeding demo camera roll"
for name in 03-cat 04-city 05-market 06-lake 07-coffee 08-picnic 09-road 10-plants 02-coast 01-dinner; do
  xcrun simctl addmedia "$UDID" "$DEMO/demo-roll-$name.jpg"
done

xcrun simctl ui "$UDID" appearance light
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --batteryLevel 100 \
  --batteryState charged \
  --cellularBars 4 \
  --wifiBars 3 \
  --operatorName "" || true

echo "Granting Photos via in-app prompt"
xcrun simctl launch "$UDID" "$BUNDLE" -ScreenshotDemo -ScreenshotScene cleaner
sleep 2.5
osascript "$SHOTS/tap-photos-permission.applescript" || true
sleep 2.5
xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
sleep 0.6

if [[ "$LOCALES_ARG" == "all" ]]; then
  LOCALES_LIST=(en nl fr de it ja ko pl pt-BR zh-Hans es uk)
else
  LOCALES_LIST=("${(@s/,/)LOCALES_ARG}")
fi

capture_scene() {
  local locale="$1"
  local languages="$2"
  local apple_locale="$3"
  local scene="$4"
  local file="$5"
  local out_dir="$6"
  echo "Capturing $locale $scene -> $out_dir/$file"
  mkdir -p "$out_dir"
  xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$BUNDLE" -AppleLanguages "$languages" -AppleLocale "$apple_locale" -ScreenshotDemo -ScreenshotScene "$scene"
  sleep 3.2
  xcrun simctl io "$UDID" screenshot "$out_dir/$file"
}

for locale in "${LOCALES_LIST[@]}"; do
  locale="${locale// /}"
  args=($(locale_apple_args "$locale"))
  languages="${args[1]}"
  apple_locale="${args[2]}"
  out_dir="$CAPTURES"
  if [[ "$locale" != "en" ]]; then
    out_dir="$CAPTURES/$locale"
  fi
  capture_scene "$locale" "$languages" "$apple_locale" cleaner 01-cleaner.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" burn 02-burn.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" keep 03-keep.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" review 04-review.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" privacy 05-privacy.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" storage 06-storage.png "$out_dir"
  capture_scene "$locale" "$languages" "$apple_locale" complete 07-complete.png "$out_dir"
done

echo "Captures written to $CAPTURES"
