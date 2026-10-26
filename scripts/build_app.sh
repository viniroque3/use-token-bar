#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "🔨 Compiling release binary with Swift..."
swift build -c release

APP_NAME="Use Token Bar"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Packaging ${APP_DIR}..."
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp ".build/release/UseTokenBar" "${MACOS_DIR}/UseTokenBar"
chmod +x "${MACOS_DIR}/UseTokenBar"

# Copy App Icon resources
if [ -f "assets/AppIcon.icns" ]; then
    cp "assets/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
    cp "assets/AppIcon-1024.png" "${RESOURCES_DIR}/AppIcon.png"
fi

cat << 'PLIST' > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>UseTokenBar</string>
    <key>CFBundleIdentifier</key>
    <string>app.usetokenbar.macos</string>
    <key>CFBundleName</key>
    <string>Use Token Bar</string>
    <key>CFBundleDisplayName</key>
    <string>Use Token Bar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Use Token Bar. All rights reserved.</string>
</dict>
</plist>
PLIST

echo "✅ App packaged successfully with AppIcon: ${APP_DIR}"
