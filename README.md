# Emoji Typing Setup

**Developed by [Easy-Cloud](https://www.easy-cloud.in)**  
**Author: Sakar SR**

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

### Alternative Installation via Release Zip

1. Download the latest zip file from the [Releases](https://github.com/your-repo/releases) page.
2. Extract the zip file:
    ```bash
    unzip emoji-typing-setup-x.y.z.zip
    cd emoji-typing-setup-x.y.z
    ```
3. Run the installer:
    ```bash
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

## Troubleshooting & Support

- **Restart Required:** After installation or uninstallation, please restart your terminal or log out and log back in for all changes to take effect.
- **Troubleshooting:**  
  - Run `./src/validate-installation.sh` for a comprehensive check and troubleshooting.
  - Check `docs/TROUBLESHOOTING.md` for common problems and solutions.
  - Review the log file at `/tmp/emoji-typing-setup.log` for detailed error and status messages.

## Manual Alias Setup (for unsupported shells)

If your shell is not directly supported, you can manually add these aliases to your shell configuration file:

```bash
alias emoji-on="~/path/to/emoji-typing-setup/src/toggle-emoji-support.sh --enable-emoji"
alias emoji-off="~/path/to/emoji-typing-setup/src/toggle-emoji-support.sh --disable-emoji"
alias emoji-status="~/path/to/emoji-typing-setup/src/toggle-emoji-support.sh --status"
```

Replace `~/path/to/emoji-typing-setup` with the actual path to your installation.

## Quick Test

```bash
# Test if everything is working
./test-emoji.sh
```

## License

MIT License
