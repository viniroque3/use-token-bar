#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "🚀 Building Use Token Bar release binary..."
./scripts/build_app.sh

APP_NAME="Use Token Bar.app"
SOURCE_APP="dist/${APP_NAME}"
TARGET_APP="/Applications/${APP_NAME}"
CLI_DIR="$HOME/.local/bin"
CLI_TARGET="${CLI_DIR}/use-token-bar"

echo "📂 Installing application into /Applications..."
rm -rf "$TARGET_APP"
cp -R "$SOURCE_APP" "$TARGET_APP"

mkdir -p "$CLI_DIR"
cat << 'LAUNCHER' > "$CLI_TARGET"
#!/usr/bin/env bash
APP_PATH="/Applications/Use Token Bar.app"

case "$1" in
  start|"")
    echo "✨ Launching Use Token Bar..."
    open "$APP_PATH"
    ;;
  stop|quit)
    echo "🛑 Quitting Use Token Bar..."
    pkill -f "UseTokenBar" || echo "App is not running."
    ;;
  status)
    if pgrep -f "UseTokenBar" > /dev/null; then
      echo "🟢 Use Token Bar is running in the Menu Bar."
    else
      echo "⚪ Use Token Bar is closed."
    fi
    ;;
  help|--help|-h)
    echo "Use Token Bar CLI Commands:"
    echo "  use-token-bar         - Launch the application in the Menu Bar"
    echo "  use-token-bar stop    - Terminate the application"
    echo "  use-token-bar status  - Check running process status"
    ;;
  *)
    echo "Unknown option: $1"
    echo "Run 'use-token-bar --help' for available commands."
    exit 1
    ;;
esac
LAUNCHER
chmod +x "$CLI_TARGET"

echo ""
echo "🎉 Installation completed successfully!"
echo "📍 Application installed to: ${TARGET_APP}"
echo "⚡ CLI launcher available at: ${CLI_TARGET}"
echo "💡 To start immediately, run: use-token-bar"
