<div align="center">
  <img src="assets/AppIcon-1024.png" width="96" height="96" alt="Use Token Bar Icon" style="border-radius: 20px;" />
  <h1>Use Token Bar</h1>
  <p><strong>Monitor nativo, leve e em tempo real para a barra de menus do macOS, rastreando ferramentas de IA e consumo de tokens.</strong></p>

  <p>
    <a href="https://github.com/viniroque3/use-token-bar/releases/tag/v0.1"><img src="https://img.shields.io/badge/Release-v0.1-007AFF?style=flat-square&logo=apple&logoColor=white" alt="Release v0.1" /></a>
    <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 14+" />
    <img src="https://img.shields.io/badge/Architecture-Apple%20Silicon%20%2F%20Intel-007AFF?style=flat-square" alt="Universal" />
    <img src="https://img.shields.io/badge/Swift-5.9%20%2F%206.0-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9+" />
    <img src="https://img.shields.io/badge/Memory-%3C%2022%20MB%20RAM-34C759?style=flat-square" alt="Low Memory" />
    <img src="https://img.shields.io/badge/Privacy-100%25%20Local-5856D6?style=flat-square" alt="Local-First" />
    <img src="https://img.shields.io/badge/License-MIT-gray?style=flat-square" alt="License" />
  </p>

  <p>
    <a href="https://github.com/viniroque3/use-token-bar/releases/download/v0.1/UseTokenBar-v0.1.dmg">
      <img src="https://img.shields.io/badge/Download-UseTokenBar--v0.1.dmg-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Baixar .DMG" />
    </a>
  </p>
</div>

---

<div align="center">
  <img src="assets/screenshots/dashboard.png" width="380" alt="Use Token Bar Dashboard" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/screenshots/settings.png" width="380" alt="Use Token Bar Settings & History" />
  <p><em>Use Token Bar em ação: Monitor de Tokens em Tempo Real, Histórico Diário, Widgets e Configurações</em></p>
</div>

---

## ⚡ Recursos Principais

- **Integração Nativa à Barra de Menus (Menu Bar)**: Opera silenciosamente como um daemon `LSUIElement` ultra-leve sem ocupar espaço no Dock.
- **Detecção Dinâmica do Modelo em Tempo Real**: Identifica automaticamente o modelo que você está utilizando no momento (ex: `Gemini 3.8 Flash`, `Claude 3.5 Sonnet`, `GPT-4o`, `Llama 3.3`) sem necessidade de seleção manual.
- **Detecção Inteligente da IDE Ativa**: Monitora o editor em primeiro plano priorizando agentes ativos (`Antigravity IDE`, `Cursor`, `VS Code`, `Ollama`).
- **Throughput e Métricas em Tempo Real**: Rastreamento de tokens de entrada (input), saída (output), cache hits, velocidade (`t/s`) e custo acumulado.
- **Gráfico de Uso Diário Contínuo**: Timeline dinâmica ilustrando o consumo desde o início do uso no dia (`09:14`) até o momento atual ou pausa.
- **Widgets de Mesa Flutuantes**:
  - **Pequeno (200x145)**: Métricas essenciais com tipografia fine-line arredondada em Apple Blue.
  - **Grande (380x285)**: Visão completa com mini-gráfico vetorial sem sobreposição de textos e detalhamento por modelo/agente.
- **Histórico Diário de Tokens (Primeiros 30 Registros)**: Registra os 30 primeiros consumos do dia separando horário, IDE, agente, modelo, tokens e custo estimado.
- **Exportação Instantânea para Excel e CSV**:
  - **Excel (`.xls`)**: Planilha formatada com cabeçalhos e totais.
  - **CSV (UTF-8 com BOM)**: Compatibilidade nativa com Microsoft Excel, Numbers e Google Sheets.
- **Persistência Segura com SQLite**: Leitura somente-leitura com `sqlite3_busy_timeout` evitando bloqueios de escrita durante compactions e execuções ativas.
- **Notificações do Sistema e Início Automático**: Alertas nativos ao ultrapassar teto de tokens e suporte a inicialização no login via `SMAppService`.

---

## 📥 Instalação e Restrições do macOS (Gatekeeper)

### Método 1: Imagem de Disco `.DMG` (Recomendado)

1. Baixe o instalador oficial: [**UseTokenBar-v0.1.dmg**](https://github.com/viniroque3/use-token-bar/releases/download/v0.1/UseTokenBar-v0.1.dmg).
2. Dê um duplo-clique no `.dmg` baixado e arraste o **Use Token Bar** para a pasta **Applications**.

#### ⚠️ Como Liberar a Restrição de Segurança do macOS

Por ser um projeto open-source independente distribuído fora da Mac App Store (sem certificado pago de desenvolvedor Apple), o macOS Gatekeeper poderá exibir o aviso:
> *"O app não pode ser aberto porque o desenvolvedor não pôde ser verificado"* ou *"O app está danificado e não pode ser aberto"*.

Para liberar o aplicativo, utilize **uma** das opções abaixo:

##### Opção 1: Terminal (Mais Rápida - 1 Clique)
Abra o **Terminal** do seu Mac e cole o comando abaixo:
```bash
xattr -cr "/Applications/Use Token Bar.app"
```
*Este comando remove o atributo de quarentena imposto pelo download da internet.*

##### Opção 2: Pelo Menu de Contexto
1. Abra o **Finder** e acesse a pasta **Aplicativos** (`/Applications`).
2. Clique com o **botão direito** (ou `Control + clique`) no **Use Token Bar**.
3. Selecione **Abrir**.
4. Na janela de confirmação que surgir, clique no botão **Abrir**.

##### Opção 3: Ajustes do Sistema
1. Abra os **Ajustes do Sistema** (System Settings).
2. Vá em **Privacidade e Segurança** (Privacy & Security).
3. Role até a seção **Segurança** e você verá: *"Use Token Bar foi impedido de abrir..."*.
4. Clique em **Abrir Mesmo Assim** e confirme sua senha ou Touch ID.

---

### Método 2: Instalação Automática via Terminal (Compilação Local)

Se preferir compilar do código-fonte:

```bash
git clone https://github.com/viniroque3/use-token-bar.git
cd use-token-bar
make install
```

O instalador compilará a versão de release, instalará o `.app` em `/Applications` e criará o comando `use-token-bar` no seu Terminal.

---

## 🛠 Ambientes Monitorados

| Ambiente / Ferramenta | Método de Inspeção | Métricas Rastreadas |
| :--- | :--- | :--- |
| **Antigravity IDE** | SQLite3 Darwin Nativo (`conversations/*.db`) | Tokens por payload/passos, tópicos de conversa, compactions |
| **VS Code (Copilot / Cline / Roo)** | Storage local de extensões & Tarefas JSON | Tokens de entrada/saída, cache, custo estimado |
| **Cursor & Codex CLI** | Tabela de processos POSIX e workspaces | Detecção de ciclo de vida e atividade de agentes |
| **Ollama / LLMs Locais** | Polling assíncrono REST (`localhost:11434`) | Modelos carregados e telemetria local |

---

## 💻 Comandos CLI

Você também pode gerenciar o Use Token Bar pelo terminal:

```bash
# Iniciar o aplicativo na Menu Bar
use-token-bar

# Verificar status do processo
use-token-bar status

# Encerrar graciosamente
use-token-bar stop
```

---

## 🔒 Garantia de Segurança e Privacidade

- **100% Local**: Nenhum dado, token ou métrica é enviado para a internet.
- **Somente Leitura**: Acesso a bancos e logs estritamente em modo read-only (`SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX`).
- **Código Aberto**: Transparência total sob licença MIT.

---

## 📄 Licença

Distribuído sob a Licença MIT. Consulte [LICENSE](LICENSE) para obter mais detalhes.
