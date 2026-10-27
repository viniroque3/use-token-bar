<div align="center">
  <img src="assets/AppIcon-1024.png" width="96" height="96" alt="Use Token Bar Icon" style="border-radius: 20px;" />
  <h1>Use Token Bar</h1>
  <p><strong>Native, lightweight, real-time macOS menu bar monitor tracking AI developer tools, multi-project workflows, and token consumption.</strong></p>

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
      <img src="https://img.shields.io/badge/Download-UseTokenBar--v0.1.dmg-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Download .DMG" />
    </a>
  </p>
</div>

---

<div align="center">
  <img src="assets/screenshots/dashboard.png" width="380" alt="Use Token Bar Dashboard" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/screenshots/settings.png" width="380" alt="Use Token Bar Settings & History" />
  <p><em>Use Token Bar in action: Real-Time Token Monitor, Multi-Project Tracking, Desktop Widgets, and Settings</em></p>
</div>

---

## ⚡ Key Features

- **Multi-Project Concurrent Detection**: Simultaneously tracks multiple open workspaces and projects in **Antigravity IDE** and other coding tools without conflict. Displays per-project agents, individual step counts, and combined cumulative token metrics.
- **Dynamic Real-Time Model Detection**: Automatically identifies the model actively being prompted (e.g., `Gemini 3.8 Flash`, `Gemini 2.5 Pro`, `Claude 3.5 Sonnet`, `GPT-4o`, `Llama 3.3`) by inspecting live telemetry payloads.
- **Smart Active IDE Detection**: Prioritizes foreground editors and active background streaming agents (`Antigravity IDE`, `Cursor`, `VS Code`, `Ollama`).
- **Real-Time Throughput & Metrics**: Instant calculation of input tokens, output tokens, cache hits, streaming speeds (`t/s`), and estimated session cost.
- **Continuous Daily Usage Timeline**: Real-time vector chart visualizing the complete day's token consumption curve, capturing rapid generation bursts as upward slopes and inactivity as flat horizontal plateaus without artificial ramps.
- **Floating Desktop Widgets**:
  - **Small (200x145)**: Compact heads-up display with multi-project badges (`Antigravity (2P)`), token counts, cost, and streaming speed.
  - **Large (380x285)**: Full dashboard with vector mini-chart, clean spacing, and detailed breakdown.
- **Daily Token History (First 30 Records)**: Records the first 30 events of the day labeled by project, agent, model, tokens, and cost.
- **Instant Excel & CSV Export**:
  - **Excel (`.xls`)**: Formatted XML schema spreadsheet with headers, formulas, and totals.
  - **CSV (UTF-8 with BOM)**: Direct import compatibility with Microsoft Excel, Apple Numbers, and Google Sheets.
- **Safe Zero-Lock SQLite Reader**: Uses non-blocking `sqlite3_busy_timeout` and `SQLITE_OPEN_READONLY` to avoid lock contention with running IDE processes.
- **System Notifications & Launch at Login**: Native alerts when approaching session limits and seamless startup integration via `SMAppService`.

---

## 🚀 Multi-Project & Multi-Agent Tracking

When working across multiple repositories simultaneously (for example, working on `Use Token Bar` and a web frontend like `fivegen-web` at the same time in Antigravity IDE):

1. **Automatic Discovery**: The application monitors live SQLite Write-Ahead Logs (`.db-wal`) and modification times across conversation databases.
2. **Per-Project Agents**: Each active workspace is detected and listed individually in the **Connected Agents** section (e.g. `Antigravity (Use Token Bar)` and `Antigravity (fivegen-web)`).
3. **Execution State Isolation**: Each project maintains its own state dot:
   - 🟢 **Generating / Streaming**: Agent is actively synthesizing code or calling tools.
   - 🟠 **Running Tool**: Agent is executing shell commands or database operations.
   - 🔵 **Awaiting Prompt**: Task completed; waiting for next user instruction.
   - ⚪ **Idle**: Project open with recorded history.
4. **Aggregated Global Metrics**: Menu bar icons, total tokens, daily chart timelines, and cost calculations seamlessly accumulate the true total across all running projects.

---

## 📥 Installation & macOS Gatekeeper

### Method 1: Disk Image `.DMG` (Recommended)

1. Download the official installer: [**UseTokenBar-v0.1.dmg**](https://github.com/viniroque3/use-token-bar/releases/download/v0.1/UseTokenBar-v0.1.dmg).
2. Double-click the downloaded `.dmg` and drag **Use Token Bar** into your **Applications** folder.

#### ⚠️ How to Bypass macOS Gatekeeper Security Notice

As an independent open-source project distributed outside the Mac App Store (without a paid Apple Developer certificate), macOS Gatekeeper may display:
> *"The app cannot be opened because the developer cannot be verified"* or *"The app is damaged and can't be opened"*.

To open the application, use **one** of the options below:

##### Option 1: Terminal (Fastest - 1 Command)
Open **Terminal** and run:
```bash
xattr -cr "/Applications/Use Token Bar.app"
```
*This removes the quarantine attribute assigned by macOS to downloaded files.*

##### Option 2: Finder Context Menu
1. Open **Finder** and navigate to `/Applications`.
2. Right-click (or `Control + click`) on **Use Token Bar**.
3. Click **Open**.
4. In the confirmation dialog, click **Open**.

##### Option 3: System Settings
1. Open **System Settings**.
2. Go to **Privacy & Security**.
3. Scroll down to the **Security** section where you will see: *"Use Token Bar was blocked from opening..."*.
4. Click **Open Anyway** and confirm with your password or Touch ID.

---

### Method 2: Automatic Terminal Installation (Build from Source)

If you prefer building from source:

```bash
git clone https://github.com/viniroque3/use-token-bar.git
cd use-token-bar
make install
```

The installer builds the release binary, installs the `.app` into `/Applications`, and registers the `use-token-bar` CLI command in your Terminal.

---

## 🛠 Monitored Environments

| Environment / Tool | Inspection Method | Tracked Metrics |
| :--- | :--- | :--- |
| **Antigravity IDE** | Native Darwin SQLite3 (`conversations/*.db`) | Multi-project sessions, step payloads, topics, compactions |
| **VS Code (Copilot / Cline / Roo)** | Local Extension Storage & Task JSON | Input/output tokens, cache hits, estimated cost |
| **Cursor & Codex CLI** | POSIX Process Table & Workspaces | Lifecycle detection and active agent status |
| **Ollama / Local LLMs** | Async REST Polling (`localhost:11434`) | Loaded models and local telemetry |

---

## 💻 CLI Commands

You can also manage Use Token Bar directly from the terminal:

```bash
# Launch the application in the Menu Bar
use-token-bar

# Check running process status
use-token-bar status

# Terminate gracefully
use-token-bar stop
```

---

## 🔒 Security & Privacy Guarantee

- **100% Local**: No token counts, code snippets, or metrics are sent over the network.
- **Read-Only**: File access is strictly read-only (`SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX`).
- **Open Source**: Full transparency under the MIT License.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
