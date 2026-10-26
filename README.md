<div align="center">
  <img src="assets/AppIcon-1024.png" width="96" height="96" alt="Use Token Bar Icon" style="border-radius: 20px;" />
  <h1>Use Token Bar</h1>
  <p><strong>Lightweight, real-time native macOS status bar monitor for AI coding tools and token throughput.</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 14+" />
    <img src="https://img.shields.io/badge/Architecture-Apple%20Silicon%20%2F%20Intel-007AFF?style=flat-square" alt="Universal" />
    <img src="https://img.shields.io/badge/Swift-5.9%20%2F%206.0-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9+" />
    <img src="https://img.shields.io/badge/Memory-%3C%2022%20MB%20RAM-34C759?style=flat-square" alt="Low Memory" />
    <img src="https://img.shields.io/badge/Privacy-100%25%20Local-5856D6?style=flat-square" alt="Local-First" />
    <img src="https://img.shields.io/badge/License-MIT-gray?style=flat-square" alt="License" />
  </p>
</div>

---

## Overview

**Use Token Bar** is a native macOS application that lives in your Menu Bar, delivering live visibility into your AI token consumption, streaming speed, estimated costs, and autonomous agent tasks across coding environments — without the bulk of web-wrapped desktop widgets.

Built natively in **Swift** and **SwiftUI** using Apple's Human Interface Guidelines, it operates on a flat, minimalist canvas with thin dividers and pure typography.

---

## Key Highlights

- **Native macOS Menu Bar Integration**: Runs as a lightweight `LSUIElement` daemon without cluttering your macOS Dock.
- **Real-Time Token Throughput**: Live tracking of input tokens, output tokens, and cache hits with fine-line Apple Blue telemetry charts.
- **Dynamic Active Model Identification**: Automatically detects and displays the active model in use (e.g., `Gemini 3.8 Flash`, `Argon Reasoning`, `Claude Opus 5.5`).
- **Deep Local Inspection**:
  - **Antigravity IDE**: Direct read-only `SQLite3` engine inspecting active step states (`status = 2`) and payload volumes in `~/.gemini/antigravity-ide/conversations/`.
  - **VS Code & Extensions**: Monitors Cline, Roo Code, and GitHub Copilot session storage.
  - **Local LLMs**: Discovers active Ollama endpoints (`http://localhost:11434/api/tags`).
  - **CLI Agents & Cursor**: Background process detection with Darwin process tables.
- **Configurable Cost & Thresholds**: Set custom pricing per million tokens and trigger native macOS system notifications when reaching session limits.
- **Session Reports**: Export detailed usage audits directly to CSV with a single click.
- **Launch at Login**: Native startup management powered by `SMAppService`.

---

## Supported Environments

| Environment / Tool | Inspection Method | Metrics Tracked |
| :--- | :--- | :--- |
| **Antigravity IDE** | Native Darwin `libsqlite3` (`conversations/*.db`) | Step counts, active agent status, session token volume |
| **VS Code (Copilot / Cline / Roo)** | Local Extension Storage & Task JSONs | In/out token accounting, cache reads/writes, cost estimate |
| **Ollama / Local LLMs** | Asynchronous Local REST Polling (`11434/api/tags`) | Local model catalog, runtime availability |
| **Cursor & Codex CLI** | POSIX Process Table & Workspace Storage | Process lifecycle, active agent executions |

---

## Installation

### Method 1: Automated Script & CLI (Recommended)

Clone the repository and run the installer:

```bash
git clone https://github.com/viniroque3/use-token-bar.git
cd use-token-bar
make install
```

This compiles an optimized release binary, packages `Use Token Bar.app` into `/Applications`, and installs the `use-token-bar` command in `~/.local/bin`.

### Method 2: Manual Swift Build

```bash
swift build -c release
./scripts/build_app.sh
open "dist/Use Token Bar.app"
```

---

## Command Line Interface (CLI)

Control Use Token Bar directly from your terminal:

```bash
# Launch the application in the Menu Bar
use-token-bar

# Check running daemon status
use-token-bar status

# Gracefully terminate the application
use-token-bar stop
```

---

## Technical Architecture

```
Use Token Bar/
├── Package.swift                    # Swift Package Manager configuration
├── Makefile                         # Professional build, install & package automation
├── assets/                          # Official macOS Retina icons and master PNG
│   ├── AppIcon-1024.png             # Master 1024x1024 application asset
│   └── AppIcon.icns                 # Multi-resolution macOS bundle icon
├── scripts/
│   ├── build_app.sh                 # Release packager generating .app bundle
│   └── install.sh                   # Self-contained installer and CLI link manager
├── Sources/
│   └── UseTokenBar/
│       ├── App/                     # Application entry point & MenuBarExtra coordinator
│       ├── Models/                  # Agent state, token metrics & user preference storage
│       ├── Services/                # Antigravity SQLite engine, process and watcher services
│       └── Views/                   # Flat SwiftUI typographic views & fine-line charts
└── .github/
    └── workflows/ci.yml             # Automated GitHub Actions macOS compilation check
```

---

## Security & Privacy Guarantee

- **100% Local**: No network telemetry, analytics, or external API calls.
- **Read-Only**: Accesses local logs and SQLite databases in strictly read-only mode (`SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX`).
- **Transparent**: Fully open source under the MIT License.

---

## Contributing

Contributions are welcome! Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for development setup instructions and guidelines.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
