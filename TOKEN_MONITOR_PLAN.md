# Plano de Incorporação de Recursos: Token Monitor ➔ Use Token Bar

Este documento estabelece o plano arquitetural e técnico para incorporar os recursos mais avançados do repositório **[Javis603/token-monitor](https://github.com/Javis603/token-monitor)** dentro do **Use Token Bar**, respeitando integralmente o **Design System nativo Apple** já estabelecido:
- **Fundo Branco Puro** (`Color.white`)
- **Gráficos e Acentos em Fine Line Azul Apple** (`#007AFF`)
- **Zero Pílulas** (utilização de cartões com cantos arredondados contínuos, divisores sutis e indicadores de status em pontos minimalistas)
- **Cantos Arredondados de 24pt** na janela e 12-14pt nos cartões internos
- **Arquitetura 100% Nativa em Swift/SwiftUI** (< 25MB de RAM, sem sobrecarga de Electron)

---

## 1. Mapeamento de Recursos do Token Monitor

| Recurso do Token Monitor | Como Funciona no Repositório Original (Electron/Node) | Adaptação para o Use Token Bar (Swift Nativo) |
| :--- | :--- | :--- |
| **Suporte a 40+ Ferramentas de IA** | Dependência do `tokscale` (JS) lendo pastas locais (`~/.claude`, `~/.codex`, Cursor, Zed). | **Coleção de Parsers Swift Nativos**: Módulo `ToolAdapters` escaneando diretórios conhecidos de forma assíncrona. |
| **Limites de Provedor & Rate Limits** | Inspirado no `CodexBar`, monitora limites de 5 horas e cotas semanais (Claude/Codex). | **QuotaTracker**: Barras de progresso com traço fino e contadores de tempo para reset ("Reseta em 2h 45m"). |
| **Heatmap de Atividade (30-365 dias)** | Matriz no estilo GitHub exibindo intensidade de tokens consumidos por dia. | **Mini-Heatmap SwiftUI**: Grade com tons de azul Apple em fundo branco sem elementos em pílula. |
| **Preservação de Dados (Arquivo Local)** | Salva dados diários para não perder histórico quando as IAs limpam seus logs. | **ArchiveEngine SQLite**: Armazena agregados diários em `~/.use_token_bar/history.sqlite`. |
| **Multi-Device Sync** | Servidor hub Node.js local / Cloudflare Worker / iCloud Drive. | **iCloud Sync Nativo**: Leitura/escrita via `NSFileCoordinator` na pasta iCloud Drive do usuário, sem servidores externos. |
| **Suporte a Moedas & Assinaturas** | Exibição em USD, EUR, CNY e controle de assinaturas fixas (Pro $20). | **CurrencyManager**: Conversão instantânea para Real (R$), Dólar ($) e Euro (€), com soma de assinaturas ativas. |

---

## 2. Nova Arquitetura de Módulos (Swift)

```mermaid
graph TD
    subgraph Adaptadores de Fontes Locais (ToolAdapters)
        A1[Antigravity SQLite Reader]
        A2[Claude Code ~/.claude/projects]
        A3[Codex CLI ~/.codex]
        A4[Cursor & VS Code Workspaces]
        A5[Ollama & Local LLM Endpoints]
        A6[Zed, Factory Droid, Cline]
    end

    subgraph Motores Centrais (Core Services)
        Aggregator[TokenAggregator Engine]
        Quota[Quota & RateLimit Service]
        Archive[SQLite Archive Engine]
        Cloud[iCloud Sync Coordinator]
    end

    subgraph Interface Apple (Design System Fundo Branco)
        UI[DashboardView 450px]
        Chart[Fine Line Blue Chart & Mini Heatmap]
        QuotaBars[Fine Line Quota Progress Bars]
        ModelBanner[Apple Card Model Selector]
        AgentList[Connected Agents Clean List]
    end

    A1 & A2 & A3 & A4 & A5 & A6 --> Aggregator
    Aggregator --> Quota
    Aggregator --> Archive
    Archive --> Cloud
    Aggregator --> UI
    UI --> Chart
    UI --> QuotaBars
    UI --> ModelBanner
    UI --> AgentList
```

---

## 3. Especificação das Novas Funcionalidades

### 3.1. Módulo de Limites de Uso e Cotas (AI Tool Limits)
- **O que faz**: Monitora os limites de requisições e tokens por janela de tempo (ex: limite de 5 horas do Claude Pro / Codex e cotas diárias).
- **Design System**:
  - Cartão retangular suave (`cornerRadius: 12`, fundo `#F8F9FA`, borda de 1px cinza sutil).
  - Barra de progresso ultra-fina (espessura 3px) na cor azul Apple (`#007AFF`).
  - Rótulo de texto sem pílula: `68% da cota utilizada • Reseta em 1h 24m`.

### 3.2. Mini-Heatmap de Atividade (30 Dias)
- **O que faz**: Exibe os últimos 30 dias em pequenos quadrados com cantos levemente arredondados (`cornerRadius: 2`), cuja opacidade de azul Apple reflete o volume de tokens gerados no dia.
- **Design System**:
  - Alinhado com o fundo branco do app.
  - Hover ou toque exibe a data e a contagem exata de tokens daquele dia.

### 3.3. Multi-Moeda & Custos de Assinaturas
- **O que faz**:
  - Alternância entre **BRL (R$)** e **USD ($)** com taxa de câmbio configurável.
  - Seção de "Assinaturas Ativas": Adicione planos fixos (ex: ChatGPT Plus R$ 100/mês, Claude Pro R$ 110/mês, Cursor Pro R$ 110/mês) para ter o custo real somado ao consumo avulso de tokens.

### 3.4. Catálogo Expandido de Leitores de Logs
- **Antigravity IDE**: Mantém o driver de alta performance `libsqlite3` lendo `steps` ativos em tempo real.
- **Claude Code**: Leitor de transcripts em `~/.claude/projects/**/*.jsonl`.
- **Codex CLI**: Leitor de histórico em `~/.codex/sessions/`.
- **Cursor**: Leitor de workspaceStorage e logs de chat.
- **Ollama / Local**: Leitor contínuo de endpoints locais.

### 3.5. Sincronização via iCloud Drive
- Permite que quem trabalha em mais de um Mac (ex: MacBook e Mac Mini/Studio) veja o total consolidado de tokens consumidos no dia sem precisar de servidores locais ou login de terceiros.

---

## 4. Fases do Plano de Execução

- [ ] **Etapa 1: Adaptadores de Ferramentas Adicionais**
  - Implementar o `ClaudeCodeWatcher` para ler sessões e tokens do Claude Code CLI (`~/.claude`).
  - Implementar o `CodexWatcher` para ler histórico do Codex.
  - Unificar todos os provedores dentro do `TokenAggregator`.

- [ ] **Etapa 2: Módulo de Cotas e Rate Limits (AI Limits)**
  - Criar `QuotaModel` e `QuotaProgressView` com traço fino azul Apple.
  - Adicionar cronômetro decrescente para o horário de reset da cota.

- [ ] **Etapa 3: Suporte a Múltiplas Moedas (BRL / USD / EUR)**
  - Adicionar seletor de moeda nas configurações (`R$`, `$`, `€`).
  - Adicionar cálculo de assinaturas mensais fixas ao custo estimado.

- [ ] **Etapa 4: Mini-Heatmap de Atividade Diária**
  - Implementar visualização compacta de matriz de calor dos últimos 30 dias em SwiftUI, integrada de forma harmônica ao fundo branco.

- [ ] **Etapa 5: Histórico Local Permanente (Archive SQLite)**
  - Criar banco de dados local para manter o histórico de consumo mesmo após as ferramentas de IA limparem suas conversas antigas.
