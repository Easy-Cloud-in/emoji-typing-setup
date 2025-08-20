# Emoji Typing Setup

A simple tool to configure emoji typing functionality on Linux systems.

## Features

- Easy installation and configuration of emoji typing
- Support for GNOME-based desktop environments
- Backup and restore functionality for input sources
- Command-line interface with multiple operations

## Quick Install

```bash
# One-line install (recommended)
curl -sSL https://raw.githubusercontent.com/your-repo/main/quick-install.sh | bash
```

## Manual Installation

```bash
# Clone the repository
git clone <repository-url>
cd emoji-typing-setup

# Quick install with aliases (recommended)
chmod +x quick-install.sh
./quick-install.sh
```

### Alternative Installation Methods

```bash
# Step-by-step installation (without aliases)
./src/emoji-typing-setup.sh install

# Add aliases separately (optional)
./src/setup-aliases.sh install
```

## Usage

### Quick Commands (Aliases)

After installation, these convenient aliases are available:

```bash
# Enable emoji typing
emoji-on

# Disable emoji typing
emoji-off

# Check current status
emoji-status
```

### Full Command Interface

```bash
# Install emoji typing support
./src/emoji-typing-setup.sh install

# Enable emoji typing
./src/emoji-typing-setup.sh enable

# Disable emoji typing
./src/emoji-typing-setup.sh disable

# Check current status
./src/emoji-typing-setup.sh status

# Uninstall emoji typing support
./src/emoji-typing-setup.sh uninstall

# Show help
./src/emoji-typing-setup.sh help
```

## Requirements

- Linux system (Ubuntu, Fedora, Pop!\_OS, etc.)
- GNOME-based desktop environment (see [COMPATIBILITY.md](COMPATIBILITY.md))
- sudo privileges for installation

## Quick Test

```bash
# Test if everything is working
./test-emoji.sh
```

## License

MIT License
