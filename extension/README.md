# Purse Chrome Extension (Flutter Web)

This wraps the Flutter web build of Purse as a Chrome extension popup.

## Build the Flutter web app
1. From repo root: `flutter build web`
2. Copy everything from `build/web/` into `extension/`
   - Ensure `extension/index.html` and `extension/main.dart.js` exist after copying.

## Icons
Place your PNG icons at `extension/icons/` with sizes 16, 32, 48, 128. Update `manifest.json` if you change paths or names.

## Load unpacked in Chrome
1. Go to `chrome://extensions`
2. Enable **Developer mode** (top right)
3. Click **Load unpacked** and select the `extension/` folder
4. The extension popup will show the Flutter app (uses `index.html`)

## Rebuild flow
- After Flutter code changes: `flutter build web`
- Copy updated `build/web/*` into `extension/`
- In `chrome://extensions`, click **Reload** on the extension

## Notes
- This uses Manifest V3. No background scripts required because the popup is the app.
- If you prefer opening in a new tab instead of a popup, add a background service worker that calls `chrome.tabs.create({ url: "index.html" })` and bind it to a command or action.
