# Security & Privacy Policy

## 100% Local-First Architecture

**Use Token Bar** is designed with strict privacy and security by default:
- **Zero Network Telemetry**: The application sends no telemetry, usage statistics, or analytics to any remote server.
- **Local Read-Only Inspection**: Token monitoring operates exclusively by reading local log files and SQLite databases on the host machine using read-only database connections (`SQLITE_OPEN_READONLY`).
- **No Cloud Dependencies**: No third-party API keys or accounts are required for the application to function.
- **Sandboxed Execution**: Only accesses standard local AI tool directories (such as `~/.gemini/antigravity-ide`, `~/.claude`, and `~/Library/Application Support/Code`).

---

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please report it responsibly by opening a confidential GitHub Security Advisory or submitting an issue.
