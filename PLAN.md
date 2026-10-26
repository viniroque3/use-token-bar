# Plano de Arquitetura e Implementação: Use Token Bar

**Use Token Bar** é um aplicativo nativo para a barra de menus do macOS (macOS Status Bar / MenuBarExtra), projetado para monitorar em tempo real o consumo de tokens de inteligência artificial e a atividade de agentes autônomos em programas como **Antigravity IDE**, **Codex**, **VS Code** (GitHub Copilot, Cline, Roo Code), **Cursor** e **Ollama**.

---

## 1. Repositórios de Assets e Recursos Visuais para macOS (GitHub)

| Repositório / Recurso | Descrição | Utilidade no Projeto |
| :--- | :--- | :--- |
| **[SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols)** | Framework Swift para acesso seguro com tipagem estática a mais de 5.000 símbolos do Apple SF Symbols. | Ícones nativos com animação de pulso e modos `.hierarchical` / `.palette` na MenuBar. |
| **[Apple Design Resources](https://developer.apple.com/design/resources/) / [taxvui/apple-design-resources](https://github.com/taxvui/apple-design-resources)** | Templates e guias de iconografia, métricas e layouts nativos da Apple. | Conformidade visual com macOS Sequoia / Sonoma (cantos arredondados, margens, tipografia San Francisco). |
| **[Lucide Icons](https://github.com/lucide-icons/lucide)** | Coleção de ícones vetoriais modernos e consistentes em SVG. | Ícones vetoriais de fornecedores de IA (OpenAI, Anthropic, Gemini, Ollama, Meta). |
| **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** | Projeto de referência para componentes dinâmicos e customizáveis na Status Bar do macOS. | Padrões de renderização leve e micro-badges para métricas em tempo real. |
| **[macos-menubar-wireguard](https://github.com/aequitas/macos-menubar-wireguard)** | Estrutura de menubar minimalista e reativa em Swift/SwiftUI. | Padrões de arquitetura de `NSStatusItem` e controle de ciclo de vida. |

---

## 2. Escolha da Linguagem e Stack Tecnológica

### Linguagem Escolhida: **Swift 5.9+ / 6 (SwiftUI + AppKit + SQLite3 + ServiceManagement + UserNotifications)**

- **Desempenho e Consumo Mínimo de Recursos**: Uso de memória < 22MB, zero consumo perceptível de bateria e CPU idle < 0.2%.
- **Integração Nativa com o macOS**: `MenuBarExtra` com estilo `.window` para popover fluido, `LSUIElement` para ocultação do ícone no Dock.
- **Leitura Nativa de Bancos de Dados**: Driver C `libsqlite3` nativo no Darwin para inspeção dos bancos `~/.gemini/antigravity-ide/conversations/*.db` em modo somente leitura sem locks.
- **Notificações e Inicialização**: Integração nativa com `UNUserNotificationCenter` e `SMAppService.mainApp`.

---

## 3. Status das Fases de Implementação

- [x] **Fase 1 (Estrutura e Fundação)**: Inicialização do repositório Git, repositório GitHub (`use-token-bar`), estrutura SPM e modelos de dados.
- [x] **Fase 2 (UI da MenuBar & Painel Interativo)**:
  - Implementação de `MenuBarExtra` com modos dinâmicos (Modelo + Tokens, Ícone + Tokens, Apenas Ícone, Ícone + Agentes).
  - Popover com cards de métricas (Tokens, Custo Estimado, Velocidade t/s, Entrada/Saída/Cache).
  - Gráfico em tempo real de consumo recente com `Charts`.
  - Painel de configurações com ajuste de custo e limite de alerta de tokens na sessão.
- [x] **Fase 3 (Watchers de Agentes em Tempo Real)**:
  - `AntigravityWatcher`: Conexão direta com SQLite (`sqlite3_open_v2`) para contagem de passos ativos (`status = 2`), passos concluídos e bytes de payload.
  - `VSCodeWatcher`: Monitoramento das pastas de extensões de agentes (Cline, Roo Code, Copilot).
  - `LocalAIService`: Detecção assíncrona da API do Ollama (`11434/api/tags`).
  - `ProcessMonitor`: Varredura de processos em segundo plano no macOS.
- [x] **Fase 4 (Empacotamento e Distribuição)**:
  - Script `scripts/build_app.sh` que gera o bundle `dist/Use Token Bar.app` com `Info.plist` e `LSUIElement = true`.
  - Instalador `scripts/install.sh` (`make install`) para instalação em `/Applications/Use Token Bar.app` e CLI `use-token-bar`.
- [x] **Fase 5 (Recursos do Sistema e Polimento Final)**:
  - `LaunchAtLoginService`: Registro nativo no macOS via `SMAppService` para inicialização automática no login.
  - `NotificationService`: Disparo de notificações de alerta do macOS (`UNUserNotificationCenter`) com som quando o teto de tokens é atingido.
  - `ExportReportService`: Exportação de relatórios da sessão em formato CSV com timestamps, modelo, tokens e custos para `~/Downloads`.
  - Interface ampliada para 450px com seletor de IA ativa (3.8 Flash, Argon, Opus 5.5).
