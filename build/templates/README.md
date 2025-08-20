# Emoji Typing Setup - Distribution Package

Quick setup tool for emoji typing on Linux systems using ibus-typing-booster.

**Developed by**: [Easy-cloud](https://www.easy-cloud.in) | **Author**: Sakar SR

## Quick Start

```bash
# Extract and install
unzip emoji-typing-setup-*.zip
cd emoji-typing-setup-*/
chmod +x *.sh
./install.sh
```

**Alternative installation:**

```bash
# Direct installation (without aliases)
./emoji-typing-setup.sh install
```

After installation, convenient aliases are automatically set up:

```bash
# Quick commands (available after installation)
emoji-on      # Enable emoji typing
emoji-off     # Disable emoji typing
emoji-status  # Check current status
```

_Note: You may need to restart your terminal or run `source ~/.bashrc` for aliases to take effect._

## Command Flags and Usage

### Installation Flags

- `./emoji-typing-setup.sh install` - Basic installation of emoji typing
- `./emoji-typing-setup.sh install --verbose` - Install with detailed output showing each step
- `./emoji-typing-setup.sh install --no-confirm` - Install without requiring confirmation prompts
- `./emoji-typing-setup.sh install --custom-config /path/to/config` - Install with a custom configuration file
- `./emoji-typing-setup.sh install --language en` - Install with specific language support (default: en)
- `./emoji-typing-setup.sh install --version latest` - Install the latest version
- `./emoji-typing-setup.sh install --version 1.2.3` - Install a specific version

### Quick Commands (Aliases)

After installation, these convenient aliases are available:

- `emoji-on` - Enable emoji typing
- `emoji-off` - Disable emoji typing
- `emoji-status` - Check current status

### Management Flags (Full Commands)

- `./emoji-typing-setup.sh enable` - Enable emoji typing
- `./emoji-typing-setup.sh enable --user-only` - Enable for current user only
- `./emoji-typing-setup.sh disable` - Disable emoji typing
- `./emoji-typing-setup.sh disable --force` - Force disable even if in use
- `./emoji-typing-setup.sh status` - Check status of emoji typing
- `./emoji-typing-setup.sh status --verbose` - Check status with detailed information

### Alias Management

- `./setup-aliases.sh install` - Set up convenient aliases (done automatically during install)
- `./setup-aliases.sh remove` - Remove aliases from shell configuration
- `./setup-aliases.sh show` - Display available aliases

### Uninstallation

```bash
# Complete uninstall (removes aliases too)
./uninstall.sh
```

### Removal Flags (Advanced)

- `./remove-emoji-support.sh` - Basic removal of emoji typing support
- `./remove-emoji-support.sh --purge` - Complete removal including configuration files
- `./remove-emoji-support.sh --backup /path/to/backup` - Backup configuration before removal
- `./remove-emoji-support.sh --no-restart` - Do not restart services after removal

## Requirements

- Linux (Ubuntu/Debian-based)
- GNOME desktop environment
- sudo access

## Support

For issues or questions, visit: [www.easy-cloud.in](https://www.easy-cloud.in)

## Version

This package was built automatically from the emoji-typing-setup project.
