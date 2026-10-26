#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "🚀 Iniciando compilação do Use Token Bar..."
./scripts/build_app.sh

APP_NAME="Use Token Bar.app"
SOURCE_APP="dist/${APP_NAME}"
TARGET_APP="/Applications/${APP_NAME}"
CLI_DIR="$HOME/.local/bin"
CLI_TARGET="${CLI_DIR}/use-token-bar"

echo "📂 Instalando aplicativo em /Applications..."
rm -rf "$TARGET_APP"
cp -R "$SOURCE_APP" "$TARGET_APP"

mkdir -p "$CLI_DIR"
cat << 'LAUNCHER' > "$CLI_TARGET"
#!/usr/bin/env bash
APP_PATH="/Applications/Use Token Bar.app"

case "$1" in
  start|"")
    echo "✨ Iniciando Use Token Bar na MenuBar..."
    open "$APP_PATH"
    ;;
  stop|quit)
    echo "🛑 Encerrando Use Token Bar..."
    pkill -f "UseTokenBar" || echo "App não estava em execução."
    ;;
  status)
    if pgrep -f "UseTokenBar" > /dev/null; then
      echo "🟢 Use Token Bar está em execução na MenuBar."
    else
      echo "⚪ Use Token Bar está fechado."
    fi
    ;;
  help|--help|-h)
    echo "Comandos do Use Token Bar CLI:"
    echo "  use-token-bar         - Inicia o aplicativo na MenuBar"
    echo "  use-token-bar stop    - Encerra o aplicativo"
    echo "  use-token-bar status  - Verifica o status de execução"
    ;;
  *)
    echo "Opção desconhecida: $1"
    echo "Use 'use-token-bar --help' para mais informações."
    exit 1
    ;;
esac
LAUNCHER
chmod +x "$CLI_TARGET"

echo ""
echo "🎉 Instalação concluída com sucesso!"
echo "📍 Aplicativo instalado em: ${TARGET_APP}"
echo "⚡ Comando CLI instalado em: ${CLI_TARGET}"
echo "💡 Para iniciar, execute: use-token-bar"
