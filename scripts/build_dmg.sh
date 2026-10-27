#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "=== 1. Building release binary ==="
./scripts/build_app.sh

echo "=== 2. Creating DMG staging area ==="
DMG_STAGING="/tmp/UseTokenBar_DMG_Staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

cp -R "dist/Use Token Bar.app" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

cat << 'TXT' > "$DMG_STAGING/README_FIRST.txt"
==============================================================
           Use Token Bar - AI Token Monitor
==============================================================

INSTALLATION:
1. Drag "Use Token Bar.app" into the "Applications" folder.

MACOS SECURITY NOTICE (GATEKEEPER):
Because this is an independent open-source application without
a paid Apple Developer certificate, macOS Gatekeeper may display:
"The app cannot be opened because the developer cannot be verified"
or "The app is damaged and can't be opened".

HOW TO OPEN:
Option 1 (Fastest - 1 Command):
Open Terminal and run:
xattr -cr "/Applications/Use Token Bar.app"

Option 2:
Right-click (or Control + click) on "Use Token Bar.app" inside
your Applications folder and click "Open". In the prompt that
appears, click "Open".

Option 3:
Go to System Settings > Privacy & Security > scroll down to the
Security section and click "Open Anyway".
==============================================================
TXT

echo "=== 3. Packaging DMG ==="
DMG_PATH="dist/UseTokenBar-v0.2.dmg"
rm -f "$DMG_PATH"
hdiutil create -volname "Use Token Bar v0.2" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"

rm -rf "$DMG_STAGING"
echo "✅ DMG successfully packaged at: $DMG_PATH"
