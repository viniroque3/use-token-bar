# Use Token Bar 🤖✨

**Use Token Bar** é um aplicativo nativo para macOS (Menu Bar / Status Bar) desenvolvido em **Swift** e **SwiftUI** para monitorar o consumo de tokens de inteligência artificial e a atividade de agentes autônomos em tempo real em ferramentas como **Antigravity IDE**, **Codex**, **VS Code** (GitHub Copilot, Cline, Roo Code), **Cursor** e **Ollama**.

---

## 🚀 Funcionalidades

- **Ícone Dinâmico na MenuBar**: Exibe o total de tokens da sessão, animação de pulso quando um agente está ativo e badge de status em tempo real.
- **Painel Interativo (Popover)**:
  - Total de tokens consumidos (Entrada, Saída, Cache).
  - Estimativa de custo em dólares com base nos modelos utilizados.
  - Velocidade em tempo real (tokens por segundo).
  - Gráfico de histórico recente utilizando SwiftUI Charts.
  - Lista de agentes e programas de IA ativos detectados no sistema.
- **Integração com Ferramentas de IA**:
  - **Antigravity IDE**: Leitura de conversas SQLite e transcripts de agentes em `~/.gemini/antigravity-ide/`.
  - **VS Code / Cline / Roo Code**: Monitoramento de tarefas e métricas de extensões em `Application Support/Code/`.
  - **Cursor / Codex / Ollama**: Detecção de processos ativos e chamadas locais.

---

## 🛠️ Tecnologias & Assets

- **Linguagem**: Swift 5.9+ / Swift 6 (Nativa para macOS).
- **Frameworks**: SwiftUI, AppKit (`MenuBarExtra`), Charts, Combine.
- **Design & Assets**:
  - Apple SF Symbols com suporte a renderização hierárquica e cores variáveis.
  - Padrões visuais alinhados às diretrizes do macOS Human Interface Guidelines.
  - Referências: [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols), [Apple Design Resources](https://developer.apple.com/design/resources/).

---

## 📦 Como Compilar e Executar

### Pré-requisitos
- macOS 14.0+ (Sonoma, Sequoia ou superior)
- Swift / Xcode Command Line Tools

### Compilação via Terminal
```bash
# Entrar no diretório do projeto
cd ~/Downloads/"Use Token Bar"

# Compilar o binário
swift build -c release

# Executar o app na barra de menus
.build/release/UseTokenBar
```

---

## 📋 Arquitetura e Roadmap

Consulte o arquivo [PLAN.md](PLAN.md) para detalhes da arquitetura técnica, pipeline de watchers e planejamento das próximas versões.
