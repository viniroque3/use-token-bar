# Contributing to Use Token Bar

Thank you for your interest in contributing to **Use Token Bar**!

We welcome contributions of all kinds, including bug reports, feature suggestions, documentation improvements, and pull requests.

---

## Development Setup

### Prerequisites
- macOS 14.0 or newer (Apple Silicon or Intel)
- Xcode 15+ or Command Line Tools with Swift 5.9+

### Building the Project
```bash
# Clone the repository
git clone https://github.com/viniroque3/use-token-bar.git
cd use-token-bar

# Build the release binary
make build

# Package and run locally
make install
use-token-bar
```

---

## Submitting Pull Requests

1. **Fork the repository** and create a feature branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```
2. **Follow Code Conventions**:
   - Write clean, idiomatic Swift.
   - Adhere to the flat, minimalist Apple Human Interface Guidelines established in the project (pure white background, thin gray dividers, no card clutter).
   - Never commit hardcoded absolute user directories (always use `FileManager.default.homeDirectoryForCurrentUser` or `$HOME`).
3. **Commit your changes**:
   ```bash
   git commit -m "feat: add support for NewAITool watcher"
   ```
4. **Push and open a Pull Request** describing your changes and testing performed.

---

## Code of Conduct

Be respectful, inclusive, and professional in all interactions within this repository.
