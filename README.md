# Emoji Typing Setup

A comprehensive tool to configure emoji typing support on Linux systems using ibus-typing-booster. Developed by **Easy-cloud** (www.easy-cloud.in) to provide seamless emoji input methods for GNOME-based desktop environments.

## 🚀 About

This project simplifies the process of enabling emoji typing on Linux systems by providing an automated setup tool that handles package installation, configuration, and management of emoji input methods.

**Developed by**: [Easy-cloud](https://www.easy-cloud.in)  
**Author**: Sakar SR  
**License**: MIT License

## ✨ Features

- 🚀 **One-command installation** of emoji typing support
- 🔄 **Toggle emoji support** on/off as primary input method
- 📊 **Status checking** with detailed system information
- 💾 **Automatic backup/restore** of input source configurations
- 🛡️ **Safety checks** and dependency validation
- 🗑️ **Complete uninstallation** with cleanup
- 🔍 **Verbose and quiet modes** for different use cases
- 🖥️ **Desktop environment detection** and compatibility warnings
- 📝 **Comprehensive logging** with rotation and levels
- 🔐 **Lock management** to prevent concurrent executions
- ⚡ **Enhanced error handling** and recovery mechanisms

## 📋 System Requirements

- **Operating System**: Linux (Debian/Ubuntu-based distributions)
- **Desktop Environment**: GNOME, Unity, or GNOME-based (recommended)
- **Package Manager**: apt
- **Dependencies**: gsettings, ibus, grep, sed, awk
- **Privileges**: sudo access for package installation

## 📦 Installation

### For End Users (Recommended)

**Download the minimal package** for easy installation:

1. **Download** `emoji-typing-minimal-2.1.0.zip` from the repository releases
2. **Extract and install**:
   ```bash
   unzip emoji-typing-minimal-2.1.0.zip
   cd emoji-typing-minimal-2.1.0/
   chmod +x *.sh
   ./emoji-typing-setup.sh install
   ```

### For Developers (Full Repository)

```bash
git clone https://github.com/easy-cloud-dev/emoji-typing-setup.git
cd emoji-typing-setup
chmod +x emoji-typing-setup.sh
./emoji-typing-setup.sh install
```

## 🎯 Usage

### Basic Commands

```bash
# Install complete emoji typing setup
./emoji-typing-setup.sh install

# Enable emoji typing (set as primary input method)
./emoji-typing-setup.sh enable

# Disable emoji typing (restore original layout)
./emoji-typing-setup.sh disable

# Check current status and system information
./emoji-typing-setup.sh status

# Create backup of current input sources
./emoji-typing-setup.sh backup

# Restore previous settings from backup
./emoji-typing-setup.sh restore

# Uninstall emoji typing support completely
./emoji-typing-setup.sh uninstall

# Show detailed help information
./emoji-typing-setup.sh help
```

### Advanced Options

```bash
# Verbose output for debugging
./emoji-typing-setup.sh --verbose install

# Quiet mode (minimal output)
./emoji-typing-setup.sh --quiet enable

# Auto-install without prompts
./emoji-typing-setup.sh --yes install

# Force installation on unsupported systems
./emoji-typing-setup.sh --force install

# Custom log level
./emoji-typing-setup.sh --log-level DEBUG status

# Custom log file location
./emoji-typing-setup.sh --log-file /tmp/my-setup.log install
```

### Command Reference

| Command     | Description                                         | Requirements      |
| ----------- | --------------------------------------------------- | ----------------- |
| `install`   | Install ibus-typing-booster and enable emoji typing | sudo access       |
| `enable`    | Enable emoji typing as primary input method         | Package installed |
| `disable`   | Disable emoji typing, restore original layout       | -                 |
| `status`    | Show comprehensive system and configuration status  | -                 |
| `backup`    | Create backup of current input source settings      | -                 |
| `restore`   | Restore input sources from backup file              | Backup exists     |
| `uninstall` | Remove emoji typing support and cleanup             | sudo access       |
| `help`      | Display detailed help and usage information         | -                 |

### Options Reference

| Option              | Short | Description                                           |
| ------------------- | ----- | ----------------------------------------------------- |
| `--verbose`         | `-v`  | Enable verbose output and debug messages              |
| `--quiet`           | `-q`  | Suppress all output except errors                     |
| `--yes`             | `-y`  | Auto-answer yes to all prompts                        |
| `--force`           | `-f`  | Force operation even if system checks fail            |
| `--log-level LEVEL` | -     | Set logging level (DEBUG, INFO, WARN, ERROR, SUCCESS) |
| `--log-file FILE`   | -     | Specify custom log file location                      |
| `--help`            | `-h`  | Show help message and exit                            |

## 🔧 How It Works

### Installation Process

1. **System Compatibility Check**: Validates Linux distribution and desktop environment
2. **Dependency Validation**: Ensures all required commands are available
3. **Environment Detection**: Identifies GNOME-based desktop environments
4. **Package Installation**: Safely installs ibus-typing-booster with error handling
5. **Configuration Setup**: Configures input sources with emoji typing enabled
6. **Backup Creation**: Automatically backs up original settings with timestamps

### Configuration Management

The tool manages GNOME's input sources through `gsettings` schema `org.gnome.desktop.input-sources`:

- **Emoji Enabled**: `[('ibus', 'typing-booster'), ('xkb', 'us')]`
- **Emoji Disabled**: `[('xkb', 'us')]`
- **Backup Format**: Timestamped files with metadata

### Safety Features

- **Automatic Backups**: Settings backed up before any changes
- **Lock File Management**: Prevents concurrent script execution
- **Dependency Validation**: Comprehensive system requirement checks
- **Signal Handling**: Graceful handling of interruption signals
- **Log Rotation**: Automatic log file rotation when size limits exceeded
- **Error Recovery**: Detailed error messages with recovery suggestions

## 📁 Project Structure

```
emoji-typing-setup/
├── README.md                    # Project documentation
├── LICENSE                      # MIT License file
├── src/                         # Source code
│   ├── emoji-typing-setup.sh    # Main installation script
│   ├── remove-emoji-support.sh  # Removal script
│   └── validate-installation.sh # Validation script
├── config/                      # Configuration files
│   └── settings.conf            # Core configuration settings
├── build/                       # Build tools
│   └── build-dist.sh            # Distribution package builder
├── scripts/                     # Development scripts
│   └── dev.sh                   # Development helper script
├── docs/                        # Documentation
│   ├── INSTALLATION_GUIDE.md    # User installation guide
│   ├── DISTRIBUTION_STRATEGY.md # Distribution approach
│   └── CONTRIBUTING.md          # Contributing guidelines
├── dist/                        # Generated distribution packages
│   └── emoji-typing-minimal-*.zip
└── tests/                       # Test scripts and validation
```

## ⚙️ Configuration

### Configuration System

The script uses a two-tier configuration system:

#### Main Configuration: `config/settings.conf`

Contains core settings automatically loaded by the script:

- **Script Information**: Version, name, and metadata
- **File Paths**: Log files, backup directories, lock files
- **Package Information**: Required packages and commands
- **GSettings Configuration**: GNOME desktop input source settings
- **Logging Configuration**: Log levels, rotation, and file management
- **Exit Codes**: Standardized error and success codes
- **Color Codes**: Terminal output formatting

#### User Configuration: `~/.config/emoji-typing-setup/user.conf` (Optional)

For user customization without modifying the main configuration:

- Copy `config/default.conf` to `~/.config/emoji-typing-setup/user.conf`
- Customize any settings to override defaults
- Settings are automatically loaded if the file exists

#### Configuration Template: `config/default.conf`

Reference template showing all available configuration options:

- Comprehensive documentation of all settings
- Examples for advanced configurations
- Future feature roadmap

### User Configuration Directory

Settings and backups are stored in `~/.config/emoji-typing-setup/`:

- `input-sources-backup` - Latest settings backup with timestamp
- `user.conf` - Optional user configuration overrides

## 🐛 Troubleshooting

### Common Issues

**"Configuration file not found"**

```bash
# Ensure config directory exists
ls -la emoji-typing-setup/config/settings.conf
```

**"gsettings schema not found"**

```bash
# Install required GNOME libraries
sudo apt update && sudo apt install -y libglib2.0-bin
```

**"ibus command not found"**

```bash
# Install IBus input framework
sudo apt update && sudo apt install -y ibus
```

**"Permission denied" errors**

```bash
# Make script executable
chmod +x emoji-typing-setup.sh
```

**Changes not taking effect**

- Log out and back in to your desktop session
- Restart GNOME Shell: `Alt+F2`, type `r`, press Enter
- Reboot your system if necessary

### Keyboard Shortcuts

Once installed and enabled, use these shortcuts to access emoji typing:

- **Ctrl + ;** (Control + Semicolon)
- **Super + ;** (Windows key + Semicolon)

### Desktop Environment Compatibility

| Environment | Support Level   | Notes                        |
| ----------- | --------------- | ---------------------------- |
| GNOME       | ✅ Full Support | Native gsettings integration |
| Ubuntu      | ✅ Full Support | GNOME-based environment      |
| Pop!\_OS    | ✅ Full Support | GNOME-based environment      |
| Unity       | ✅ Full Support | Uses GNOME settings backend  |
| KDE Plasma  | ⚠️ Limited      | May work with --force flag   |
| XFCE        | ⚠️ Limited      | May work with --force flag   |
| Other DEs   | ❌ Unsupported  | Use --force to attempt       |

### Debug and Logging

The enhanced version includes comprehensive logging:

```bash
# View current log
tail -f /var/log/emoji-typing-setup.log

# Debug mode with verbose output
./emoji-typing-setup.sh --verbose --log-level DEBUG install

# Check script status and configuration
./emoji-typing-setup.sh status
```

## 📦 Distribution Package

### For End Users

We provide a **minimal distribution package** (`emoji-typing-minimal-2.1.0.zip`) that contains only the essential files needed for emoji typing setup:

- **Size**: ~12KB (vs 100KB+ full repository)
- **Contents**: Main script, removal script, configuration, license, and simple README
- **Installation**: Download, extract, and run - no development files to confuse users

### For Developers

To create the distribution package:

```bash
./scripts/dev.sh build
# Creates dist/emoji-typing-minimal-2.1.0.zip
```

This approach separates user-facing distribution from development files, providing a cleaner experience for end users while maintaining full development capabilities.

## 🧪 Development and Testing

### Testing the Script

```bash
# Test all functionality
./emoji-typing-setup.sh --verbose status
./emoji-typing-setup.sh --verbose backup
./emoji-typing-setup.sh --verbose install
./emoji-typing-setup.sh --verbose disable
./emoji-typing-setup.sh --verbose enable
./emoji-typing-setup.sh --verbose restore
```

### Contributing

We welcome contributions from the community! Please see [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Test thoroughly on multiple distributions
4. Submit a pull request with detailed description

### Development Roadmap

See [plan.md](plan.md) for detailed development plans and progress tracking.

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.

```
MIT License

Copyright (c) 2024 Easy-cloud (www.easy-cloud.in)
Author: Sakar SR
```

## 🙏 Acknowledgments

- **Easy-cloud Team**: For project development and maintenance
- **IBus Community**: For the excellent ibus-typing-booster input method
- **GNOME Project**: For the robust desktop environment and gsettings
- **Open Source Community**: For inspiration and collaborative development

## 📞 Support

For support, questions, or contributions:

- **Website**: [www.easy-cloud.in](https://www.easy-cloud.in)
- **GitHub Issues**: Create an issue for bug reports or feature requests
- **End Users**: Download the minimal package for simplified installation
- **Developers**: Full repository with documentation and development tools

---

**Note**: This tool modifies system input method settings. While automatic backups are created, we recommend testing in a non-production environment first. The tool is designed with safety in mind, but system configuration changes should always be approached with caution.

**Easy-cloud** - Simplifying cloud and system management solutions.
