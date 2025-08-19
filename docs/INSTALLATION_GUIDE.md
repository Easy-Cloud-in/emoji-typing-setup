# Emoji Typing Setup - Installation Guide

## For End Users (Minimal Distribution)

### Simple Installation Steps

1. **Download** the minimal package from GitHub repository:

   - Go to the repository releases page
   - Download `emoji-typing-minimal-2.1.0.zip`

2. **Extract** the package:

   ```bash
   unzip emoji-typing-minimal-2.1.0.zip
   cd emoji-typing-minimal-2.1.0/
   ```

3. **Install** emoji typing:

   ```bash
   chmod +x *.sh
   ./emoji-typing-setup.sh install
   ```

4. **Start using** emoji typing with `Ctrl+;` or `Super+;`

### Available Commands

```bash
# Check current status
./emoji-typing-setup.sh status

# Enable/disable emoji typing
./emoji-typing-setup.sh enable
./emoji-typing-setup.sh disable

# Create backup of settings
./emoji-typing-setup.sh backup

# Restore from backup
./emoji-typing-setup.sh restore

# Complete removal
./remove-emoji-support.sh
```

### System Requirements

- Linux (Ubuntu/Debian-based distributions)
- GNOME desktop environment (recommended)
- Internet connection for package installation
- sudo privileges

---

## For Developers (Full Repository)

### Development Setup

1. **Clone** the full repository:

   ```bash
   git clone https://github.com/easy-cloud-dev/emoji-typing-setup.git
   cd emoji-typing-setup
   ```

2. **Build** minimal distribution:

   ```bash
   chmod +x build-minimal-dist.sh
   ./build-minimal-dist.sh
   ```

3. **Test** the installation:
   ```bash
   chmod +x emoji-typing-setup.sh
   ./emoji-typing-setup.sh status
   ```

### Building Distribution Package

The `build-minimal-dist.sh` script creates a minimal package containing only essential files:

- `emoji-typing-setup.sh` - Main installation script
- `remove-emoji-support.sh` - Removal script
- `config/settings.conf` - Configuration file
- `README.md` - Simplified user guide
- `LICENSE` - MIT license

**Package size**: ~12KB (much smaller than full repo)

### What's Excluded from Minimal Package

- Development documentation (`docs/`, `PROJECT_ANALYSIS.md`)
- Test files (`tests/`)
- GitHub workflows (`.github/`)
- Build scripts and development tools
- Detailed documentation

This keeps the end-user package lightweight and focused on functionality.

---

**Developed by**: [Easy-cloud](https://www.easy-cloud.in) | **Author**: Sakar SR
