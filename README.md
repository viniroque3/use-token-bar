# Use Token Bar

**Use Token Bar** is a lightweight, native macOS Menu Bar application built with **Swift** and **SwiftUI** to monitor real-time AI token consumption, speed, and active agent processes across tools such as **Antigravity IDE**, **Codex**, **VS Code** (GitHub Copilot, Cline, Roo Code), **Cursor**, and **Ollama**.

---

## Features

- **Minimal Native Status Bar**:
  - Live token ticker or agent count.
  - Optional model name display (e.g., `3.8 Flash • 24.5k`).
  - Subtle status dot when generating tokens.
- **Clean Apple Typographic Interface**:
  - Pure white background with delicate hairline dividers (no card clutter, no unnecessary icons).
  - Apple Blue fine-line real-time throughput chart.
  - Active model indicator and one-click model switcher (`Gemini 3.8 Flash`, `Argon Reasoning`, `Claude Opus 5.5`).
  - Live metric breakdown: Total Tokens, Estimated Cost, Speed (tokens/sec), Input, Output, and Cache.
  - Active autonomous agent list with live action states.
- **Deep Local Monitoring**:
  - **Antigravity IDE**: Real-time read-only SQLite inspection (`~/.gemini/antigravity-ide/conversations/*.db`) querying step states (`status = 2`) and payload sizes.
  - **VS Code / Cline / Roo Code**: Extension task monitoring in `Application Support/Code/`.
  - **Ollama**: Local API health and model list polling (`http://localhost:11434/api/tags`).
  - **Cursor / Codex**: Operating system process detection.
- **System Integrations**:
  - Native macOS notifications (`UserNotifications`) when customizable session token thresholds are crossed.
  - Automatic launch on system boot via `SMAppService` (Launch at Login).
  - One-click CSV usage report export.

---

## Installation & Setup

### Quick Install (Command Line)
Compile and install directly to `/Applications` and configure the CLI launcher:

```bash
cd ~/Downloads/"Use Token Bar"
./scripts/install.sh
# or:
make install
```

### CLI Commands
Once installed, use the `use-token-bar` command from any terminal:

```bash
# Launch app in Menu Bar
use-token-bar

# Check running status
use-token-bar status

# Terminate app
use-token-bar stop
```

---

## Technical Architecture

- **Language**: Swift 5.9+ / Swift 6 (Native macOS arm64).
- **Frameworks**: SwiftUI, AppKit (`MenuBarExtra`), Charts, Combine, SQLite3 (`libsqlite3`), ServiceManagement, UserNotifications.
- **Configuration**: Configured with `LSUIElement = true` in `Info.plist` to run exclusively in the Menu Bar without docking.
- **Memory Footprint**: < 22 MB RAM with zero background battery impact.

---

## License

MIT License.
