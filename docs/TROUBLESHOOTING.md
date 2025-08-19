# Troubleshooting Guide

This guide covers common issues you might encounter when using the emoji typing setup tool and their solutions.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Configuration Problems](#configuration-problems)
- [Desktop Environment Issues](#desktop-environment-issues)
- [Package Management Issues](#package-management-issues)
- [Permission Problems](#permission-problems)
- [Input Method Issues](#input-method-issues)
- [Recovery and Restoration](#recovery-and-restoration)
- [System-Specific Issues](#system-specific-issues)
- [Advanced Troubleshooting](#advanced-troubleshooting)

## Installation Issues

### "gsettings not found" Error

**Problem**: The script reports that `gsettings` command is not available.

**Solution**:
```bash
# Install the required package
sudo apt update && sudo apt install -y libglib2.0-bin

# Verify installation
gsettings --version
```

**Alternative for other distributions**:
- **Fedora/RHEL**: `sudo dnf install glib2-devel`
- **Arch Linux**: `sudo pacman -S glib2`

### "ibus not found" Error

**Problem**: The script cannot find the `ibus` command.

**Solution**:
```bash
# Install ibus
sudo apt update && sudo apt install -y ibus

# Start ibus daemon
ibus-daemon -drx

# Verify installation
ibus version
```

### Package Installation Fails

**Problem**: `ibus-typing-booster` installation fails.

**Symptoms**:
- "Package not found" errors
- "Unable to locate package" messages
- Dependency conflicts

**Solutions**:

1. **Update package lists**:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

2. **Check repository availability**:
   ```bash
   apt search ibus-typing-booster
   ```

3. **Install from universe repository** (Ubuntu):
   ```bash
   sudo add-apt-repository universe
   sudo apt update
   sudo apt install ibus-typing-booster
   ```

4. **Manual installation**:
   ```bash
   # Download from official repository
   wget http://archive.ubuntu.com/ubuntu/pool/universe/i/ibus-typing-booster/ibus-typing-booster_2.18.14-1_all.deb
   sudo dpkg -i ibus-typing-booster_2.18.14-1_all.deb
   sudo apt-get install -f  # Fix dependencies
   ```

## Configuration Problems

### Settings Not Taking Effect

**Problem**: Configuration changes don't apply after running the script.

**Symptoms**:
- Emoji typing still not working after enabling
- Input sources remain unchanged
- Settings revert after reboot

**Solutions**:

1. **Complete logout/login cycle**:
   ```bash
   # Log out completely and log back in
   # Or restart your system
   sudo reboot
   ```

2. **Restart GNOME Shell** (X11 only):
   ```bash
   # Press Alt+F2, type 'r', press Enter
   # Or use command:
   busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
   ```

3. **Manually restart ibus**:
   ```bash
   ibus exit
   ibus-daemon -drx
   ```

4. **Clear ibus cache**:
   ```bash
   rm -rf ~/.cache/ibus
   ibus restart
   ```

### Wrong Input Sources Configuration

**Problem**: Input sources are not configured correctly.

**Debugging**:
```bash
# Check current configuration
gsettings get org.gnome.desktop.input-sources sources

# Check available input sources
gsettings list-keys org.gnome.desktop.input-sources

# List all ibus engines
ibus list-engine
```

**Manual fix**:
```bash
# Reset to English only
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"

# Add typing booster
gsettings set org.gnome.desktop.input-sources sources "[('ibus', 'typing-booster'), ('xkb', 'us')]"
```

## Desktop Environment Issues

### Unsupported Desktop Environment

**Problem**: Script warns about unsupported desktop environment.

**Supported environments**:
- GNOME 3.x+
- Unity
- Pop!_OS
- Ubuntu Desktop

**Partially supported**:
- KDE Plasma
- XFCE
- MATE
- Cinnamon

**Solutions**:

1. **Force installation** (use with caution):
   ```bash
   ./emoji-typing-setup.sh --force install
   ```

2. **KDE Plasma specific**:
   ```bash
   # Install ibus support for KDE
   sudo apt install ibus-qt4 ibus-qt5

   # Configure in System Settings > Input Devices > Keyboard
   ```

3. **XFCE specific**:
   ```bash
   # Add to ~/.xprofile or ~/.profile
   export GTK_IM_MODULE=ibus
   export XMODIFIERS=@im=ibus
   export QT_IM_MODULE=ibus
   ibus-daemon -d -x
   ```

### Wayland vs X11 Issues

**Problem**: Different behavior on Wayland vs X11 sessions.

**Check your session type**:
```bash
echo $XDG_SESSION_TYPE
```

**Wayland-specific issues**:
- Some keyboard shortcuts may not work
- Input method switching may behave differently

**Solution**:
```bash
# Switch to X11 session at login screen
# Or add to ~/.profile for Wayland:
export WAYLAND_DISPLAY=""
export GDK_BACKEND="x11"
```

## Package Management Issues

### Sudo Password Issues

**Problem**: Script fails when requesting sudo password.

**Solutions**:

1. **Run with proper sudo access**:
   ```bash
   # Test sudo access first
   sudo -v
   ./emoji-typing-setup.sh install
   ```

2. **Configure passwordless sudo** (for automated environments):
   ```bash
   # Add to /etc/sudoers (use visudo)
   username ALL=(ALL) NOPASSWD: /usr/bin/apt
   ```

3. **Run as root** (not recommended for desktop use):
   ```bash
   sudo ./emoji-typing-setup.sh install
   ```

### Repository Issues

**Problem**: Package repositories are not accessible or outdated.

**Solutions**:

1. **Update repository information**:
   ```bash
   sudo apt update
   sudo apt list --upgradable
   ```

2. **Fix broken repositories**:
   ```bash
   sudo apt --fix-broken install
   sudo dpkg --configure -a
   ```

3. **Add missing repositories**:
   ```bash
   # For Ubuntu derivatives
   sudo apt-add-repository -y ppa:typing-booster/ppa
   sudo apt update
   ```

## Permission Problems

### Configuration Directory Access

**Problem**: Cannot create configuration or backup directories.

**Symptoms**:
```
mkdir: cannot create directory '/home/user/.config/emoji-typing-setup': Permission denied
```

**Solutions**:
```bash
# Fix ownership of config directory
sudo chown -R $USER:$USER ~/.config/

# Create directory manually
mkdir -p ~/.config/emoji-typing-setup

# Check permissions
ls -la ~/.config/
```

### Log File Permissions

**Problem**: Cannot write to log file.

**Solutions**:
```bash
# Change log location in script or config
export LOG_FILE="$HOME/.local/share/emoji-typing-setup.log"

# Or fix /tmp permissions
sudo chmod 1777 /tmp
```

## Input Method Issues

### Emoji Typing Not Working

**Problem**: Emoji input doesn't work even after successful installation.

**Debugging steps**:

1. **Verify installation**:
   ```bash
   ./emoji-typing-setup.sh status
   dpkg -l | grep ibus-typing-booster
   ```

2. **Check ibus configuration**:
   ```bash
   ibus list-engine | grep typing-booster
   ibus engine typing-booster
   ```

3. **Test input method switching**:
   ```bash
   # Use Super+Space or configured hotkey
   # Or manually switch via settings
   ```

4. **Check environment variables**:
   ```bash
   echo $GTK_IM_MODULE
   echo $QT_IM_MODULE
   echo $XMODIFIERS
   ```

### Input Method Switching Not Working

**Problem**: Cannot switch between input methods.

**Solutions**:

1. **Check keyboard shortcuts**:
   ```bash
   # In GNOME Settings > Keyboard > Keyboard Shortcuts
   # Look for "Switch to next input source"
   ```

2. **Reset input method configuration**:
   ```bash
   gsettings reset org.gnome.desktop.input-sources sources
   ./emoji-typing-setup.sh restore
   ```

3. **Manual switching**:
   ```bash
   # Use GUI: Settings > Region & Language > Input Sources
   # Or use command line:
   gsettings set org.gnome.desktop.input-sources current 0  # First source
   gsettings set org.gnome.desktop.input-sources current 1  # Second source
   ```

## Recovery and Restoration

### Restore from Backup

**Problem**: Need to restore previous configuration.

**Solutions**:
```bash
# Use built-in restore function
./emoji-typing-setup.sh restore

# Or manual restore
cat ~/.config/emoji-typing-setup/input-sources-backup
# Copy the sources line and apply it:
gsettings set org.gnome.desktop.input-sources sources "COPIED_SOURCES"
```

### Complete Reset

**Problem**: Configuration is completely broken and needs reset.

**Steps**:
```bash
# 1. Remove all input method configuration
gsettings reset org.gnome.desktop.input-sources sources
gsettings reset org.gnome.desktop.input-sources current

# 2. Stop ibus
ibus exit

# 3. Clear ibus cache
rm -rf ~/.cache/ibus
rm -rf ~/.config/ibus

# 4. Restart ibus
ibus-daemon -drx

# 5. Reinstall if needed
./emoji-typing-setup.sh uninstall
./emoji-typing-setup.sh install
```

### Emergency Recovery

**Problem**: System becomes unusable due to input method issues.

**Emergency steps**:
```bash
# 1. Switch to text console: Ctrl+Alt+F2
# 2. Login with username/password
# 3. Reset to safe configuration:
export DISPLAY=:0
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"

# 4. Return to desktop: Ctrl+Alt+F1 or F7
# 5. Complete the recovery:
./emoji-typing-setup.sh restore
```

## System-Specific Issues

### Ubuntu 20.04/22.04 Issues

**Common problems**:
- Snap packages interfering with ibus
- Wayland session differences

**Solutions**:
```bash
# Disable conflicting snap packages
sudo snap list | grep input
sudo snap remove problematic-package

# Use X11 session instead of Wayland
# Select "Ubuntu on Xorg" at login
```

### Pop!_OS Issues

**Common problems**:
- Custom keyboard shortcuts
- Different default input method

**Solutions**:
```bash
# Check Pop!_OS specific settings
dconf dump /org/gnome/desktop/input-sources/

# Reset Pop!_OS keyboard settings
dconf reset -f /org/gnome/desktop/wm/keybindings/
```

### Fedora/CentOS Issues

**Package management differences**:
```bash
# Use dnf instead of apt
sudo dnf install ibus-typing-booster

# Different service management
sudo systemctl enable ibus
sudo systemctl start ibus
```

## Advanced Troubleshooting

### Debug Mode

Enable verbose logging for detailed troubleshooting:
```bash
./emoji-typing-setup.sh --verbose status
./emoji-typing-setup.sh --verbose install
```

Check log files:
```bash
tail -f /tmp/emoji-typing-setup.log
```

### System Information Collection

Collect system information for support:
```bash
# Create a system info report
{
    echo "=== System Information ==="
    uname -a
    lsb_release -a
    echo
    
    echo "=== Desktop Environment ==="
    echo "XDG_CURRENT_DESKTOP: $XDG_CURRENT_DESKTOP"
    echo "XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
    echo "GDMSESSION: $GDMSESSION"
    echo
    
    echo "=== Package Information ==="
    dpkg -l | grep -E "(ibus|typing-booster|gnome)"
    echo
    
    echo "=== Current Configuration ==="
    gsettings get org.gnome.desktop.input-sources sources
    echo
    
    echo "=== IBus Status ==="
    ps aux | grep ibus
    ibus list-engine | head -10
    echo
    
    echo "=== Environment Variables ==="
    env | grep -E "(GTK_IM|QT_IM|XMODIFIERS)"
    
} > /tmp/emoji-typing-debug-info.txt

echo "Debug information saved to /tmp/emoji-typing-debug-info.txt"
```

### Manual Testing

Test components individually:
```bash
# Test gsettings
gsettings list-schemas | grep desktop.input-sources

# Test ibus daemon
ibus-daemon -drx
ibus list-engine

# Test typing booster specifically
ibus engine typing-booster

# Test configuration changes
gsettings monitor org.gnome.desktop.input-sources sources
```

### Network Issues

If packages cannot be downloaded:
```bash
# Test network connectivity
ping -c 3 archive.ubuntu.com
curl -I http://archive.ubuntu.com

# Check proxy settings
env | grep -i proxy

# Test with different mirrors
sudo sed -i 's|archive.ubuntu.com|mirror.ubuntu.com|g' /etc/apt/sources.list
sudo apt update
```

## Getting Additional Help

If these troubleshooting steps don't resolve your issue:

1. **Collect debug information** using the script above
2. **Check project issues** on GitHub
3. **Search community forums** for your specific distribution
4. **Contact support** with the debug information

### Useful Resources

- [IBus Documentation](https://github.com/ibus/ibus/wiki)
- [GNOME Input Sources](https://help.gnome.org/users/gnome-help/stable/keyboard-inputmethods.html)
- [Ubuntu Community Help](https://help.ubuntu.com/)
- [ibus-typing-booster GitHub](https://github.com/mike-fabian/ibus-typing-booster)

### Emergency Contacts

For critical system issues:
- Use recovery mode from GRUB menu
- Boot from live USB/CD if needed
- Contact your system administrator if on managed systems