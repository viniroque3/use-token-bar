# Use Token Bar 🤖✨

**Use Token Bar** é um aplicativo nativo para macOS (Menu Bar / Status Bar) desenvolvido em **Swift** e **SwiftUI** para monitorar em tempo real o consumo de tokens de inteligência artificial e a atividade de agentes autônomos em ferramentas como **Antigravity IDE**, **Codex**, **VS Code** (GitHub Copilot, Cline, Roo Code), **Cursor** e **Ollama**.

---

## 🚀 Funcionalidades

- **Ícone Dinâmico na MenuBar**:
  - Exibe o total de tokens da sessão ou contagem de agentes ativos.
  - Animação de pulso e indicador verde/laranja em tempo real durante geração de tokens.
  - Modos configuráveis: *Ícone + Tokens*, *Apenas Ícone* ou *Ícone + Agentes*.
- **Painel Interativo (Popover)**:
  - Total de tokens consumidos (Entrada, Saída, Cache).
  - Estimativa de custo customizável ($/milhão de tokens).
  - Velocidade em tempo real (tokens por segundo).
  - Alerta visual quando o consumo ultrapassa o limite da sessão.
  - Gráfico de histórico recente com interpolação suave via SwiftUI Charts.
  - Lista de agentes e programas de IA ativos detectados no sistema.
- **Painel de Configurações Integrado**:
  - Ajuste de limites de alerta na sessão.
  - Ajuste de custo por modelo/provedor.
  - Alteração instantânea do modo de exibição na barra de menus.
- **Monitoramento Profundo**:
  - **Antigravity IDE**: Leitura direta via driver C `SQLite3` dos bancos de conversação (`~/.gemini/antigravity-ide/conversations/*.db`) identificando passos ativos (`status = 2`), passos concluídos e tamanho do payload.
  - **VS Code / Cline / Roo Code**: Monitoramento de tarefas e métricas de extensões em `Application Support/Code/`.
  - **Ollama**: Verificação assíncrona de modelos disponíveis na API local (`http://localhost:11434/api/tags`).
  - **Cursor / Codex / Processos**: Detecção de processos do sistema operacional.

---

## ⚡ Instalação Rápida (Linha de Comando)

Você pode compilar e instalar o app diretamente em `/Applications` e configurar o utilitário CLI:

```bash
cd ~/Downloads/"Use Token Bar"
./scripts/install.sh
# ou simplesmente:
make install
```

### 💻 Como Usar o Comando CLI

Após a instalação, o utilitário `use-token-bar` fica disponível no seu Terminal:

```bash
# Iniciar o aplicativo na MenuBar:
use-token-bar

# Verificar status de execução:
use-token-bar status

# Encerrar o aplicativo:
use-token-bar stop
```

---

## 🛠️ Tecnologias & Assets

- **Linguagem**: Swift 5.9+ / Swift 6 (Nativa para macOS).
- **Frameworks**: SwiftUI, AppKit (`MenuBarExtra`), Charts, Combine, SQLite3 (`libsqlite3`).
- **Design & Assets**:
  - Apple SF Symbols com suporte a renderização hierárquica e cores variáveis.
  - Diretrizes do macOS Human Interface Guidelines.
  - Configuração `LSUIElement = true` no `Info.plist` (app de status bar sem ícone no Dock).

---

## 📋 Arquitetura e Roadmap

Consulte o arquivo [PLAN.md](PLAN.md) para detalhes da arquitetura técnica, pipeline de watchers e planejamento das próximas versões.
