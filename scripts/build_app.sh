#!/usr/bin/env bash
set -e

echo "🔨 Compilando release binary com Swift..."
swift build -c release

APP_NAME="Use Token Bar"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Empacotando ${APP_DIR}..."
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp ".build/release/UseTokenBar" "${MACOS_DIR}/UseTokenBar"
chmod +x "${MACOS_DIR}/UseTokenBar"

cat << 'PLIST' > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>UseTokenBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.viniroque.usetokenbar</string>
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
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "✅ Aplicativo empacotado com sucesso em: ${APP_DIR}"
