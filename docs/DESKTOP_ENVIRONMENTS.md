# Desktop Environment Compatibility Guide

This guide provides detailed information about emoji typing setup compatibility across different Linux desktop environments.

## Table of Contents

- [Fully Supported Environments](#fully-supported-environments)
- [Partially Supported Environments](#partially-supported-environments)
- [Unsupported Environments](#unsupported-environments)
- [Environment-Specific Setup](#environment-specific-setup)
- [Troubleshooting by Environment](#troubleshooting-by-environment)

## Compatibility Matrix

| Desktop Environment | Support Level | Notes | Auto-detection |
|-------------------|---------------|-------|----------------|
| GNOME 3.x+ | ✅ Full | Native support | ✅ |
| Unity | ✅ Full | Uses GNOME settings | ✅ |
| Pop!_OS | ✅ Full | GNOME-based | ✅ |
| Ubuntu Desktop | ✅ Full | GNOME-based | ✅ |
| Budgie | ✅ Full | Uses GNOME settings | ✅ |
| KDE Plasma | ⚠️ Partial | Requires additional setup | ✅ |
| XFCE | ⚠️ Partial | Manual configuration needed | ✅ |
| MATE | ⚠️ Partial | Limited functionality | ✅ |
| Cinnamon | ⚠️ Partial | Some features missing | ✅ |
| LXQt | ❌ Limited | Basic support only | ✅ |
| LXDE | ❌ Limited | Basic support only | ✅ |
| i3/Sway | ❌ Manual | Command-line only | ❌ |
| Openbox | ❌ Manual | Command-line only | ❌ |

## Fully Supported Environments

### GNOME 3.x+

**Why it works**: This tool is designed specifically for GNOME's input source management system.

**Features**:
- ✅ Automatic configuration
- ✅ GUI input source switching
- ✅ Keyboard shortcut support
- ✅ System settings integration
- ✅ Session persistence

**Requirements**:
- GNOME 3.10 or later
- gsettings command
- ibus daemon

**Testing**:
```bash
# Verify GNOME version
gnome-shell --version

# Check input sources support
gsettings list-keys org.gnome.desktop.input-sources
```

### Unity Desktop

**Why it works**: Unity uses GNOME's underlying input method system.

**Features**:
- ✅ Full compatibility with GNOME settings
- ✅ Unity HUD integration
- ✅ Dash integration for input method switching

**Specific considerations**:
- Input method indicator in top panel
- Unity-specific keyboard shortcuts

**Testing**:
```bash
# Check Unity version
unity --version

# Verify settings compatibility
gsettings get com.canonical.Unity.Panel systray-whitelist
```

### Pop!_OS

**Why it works**: Based on GNOME with minimal modifications to input handling.

**Features**:
- ✅ All GNOME features
- ✅ Pop!_OS keyboard shortcuts
- ✅ Activities overview integration

**Pop!_OS specific settings**:
```bash
# Check Pop-specific overrides
dconf dump /org/gnome/shell/extensions/pop-shell/
```

### Ubuntu Desktop (GNOME)

**Why it works**: Ubuntu's GNOME implementation maintains full input method compatibility.

**Features**:
- ✅ Ubuntu-themed input method switcher
- ✅ Software center integration
- ✅ Snap package compatibility

**Ubuntu-specific considerations**:
```bash
# Check for snap conflicts
snap list | grep input

# Ubuntu's ibus configuration
ls /usr/share/ibus/
```

## Partially Supported Environments

### KDE Plasma

**Current limitations**:
- Input method switching uses different mechanism
- System Settings integration varies
- Qt applications may need additional configuration

**Setup requirements**:
```bash
# Install KDE ibus integration
sudo apt install ibus-qt4 ibus-qt5 kde-config-fcitx

# Set environment variables
echo 'export GTK_IM_MODULE=ibus' >> ~/.profile
echo 'export QT_IM_MODULE=ibus' >> ~/.profile
echo 'export XMODIFIERS=@im=ibus' >> ~/.profile
```

**KDE-specific configuration**:
1. Open System Settings
2. Go to Input Devices → Keyboard
3. Select "Advanced" tab
4. Configure input method switching

**Manual input source management**:
```bash
# KDE uses different gsettings schema
gsettings set org.kde.keyboard layouts "['us', 'typing-booster']"

# Or use KDE's kconfig
kwriteconfig5 --file kxkbrc --group Layout --key LayoutList "us,typing-booster"
```

### XFCE

**Current limitations**:
- No native input source management
- Requires manual environment setup
- Panel applets may not show input method status

**Setup requirements**:
```bash
# Install XFCE ibus panel applet
sudo apt install ibus-gtk3 xfce4-indicator-plugin

# Configure startup applications
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/ibus.desktop << EOF
[Desktop Entry]
Type=Application
Name=IBus Daemon
Exec=ibus-daemon -drx
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
```

**Environment configuration**:
```bash
# Add to ~/.xprofile or ~/.profile
cat >> ~/.xprofile << EOF
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
ibus-daemon -d -x &
EOF
```

**Panel configuration**:
1. Right-click on XFCE panel
2. Add new items → Indicator Plugin
3. Configure to show input method indicator

### MATE Desktop

**Current limitations**:
- Uses older input method system
- Limited emoji support in some applications
- Manual configuration required

**Setup requirements**:
```bash
# Install MATE-specific ibus components
sudo apt install ibus-gtk3 mate-indicator-applet

# Configure MATE settings
gsettings set org.mate.peripherals-keyboard-xkb.kbd layouts "['us', 'typing-booster']"
```

**MATE-specific configuration**:
```bash
# Add input method applet to panel
mate-panel --add-applet=IBusApplet
```

### Cinnamon

**Current limitations**:
- Different settings management system
- Input method switching may not work consistently

**Setup requirements**:
```bash
# Install Cinnamon ibus support
sudo apt install ibus-gtk3

# Configure through Cinnamon settings
cinnamon-settings keyboard
```

**Manual configuration**:
```bash
# Use dconf for Cinnamon-specific settings
dconf write /org/cinnamon/desktop/interface/keyboard-layouts "['us', 'typing-booster']"
```

## Environment-Specific Setup

### Wayland vs X11 Considerations

**Wayland sessions**:
- Some input method features may be limited
- Different environment variable requirements
- Session-specific behavior

**X11 sessions**:
- Full feature compatibility
- Traditional input method handling

**Detection and handling**:
```bash
# Check session type
echo $XDG_SESSION_TYPE

# Wayland-specific setup
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export QT_IM_MODULE=ibus
    export GTK_IM_MODULE=ibus
fi
```

### Display Manager Considerations

**GDM (GNOME Display Manager)**:
- Full integration with GNOME settings
- Session persistence

**LightDM**:
- Requires manual environment setup
- May need session scripts

**SDDM (KDE)**:
- KDE-specific configuration
- Different session handling

## Troubleshooting by Environment

### GNOME Issues

**Problem**: Settings not persisting after logout
```bash
# Check dconf database
dconf dump /org/gnome/desktop/input-sources/

# Reset if corrupted
dconf reset -f /org/gnome/desktop/input-sources/
```

**Problem**: Input method switching not working
```bash
# Check keyboard shortcuts
gsettings get org.gnome.desktop.wm.keybindings switch-input-source

# Reset to default
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
```

### KDE Issues

**Problem**: Qt applications not using ibus
```bash
# Check Qt IM module
echo $QT_IM_MODULE

# Test with Qt application
qtconfig-qt4  # Should show ibus in input method dropdown
```

**Problem**: Panel not showing input method indicator
```bash
# Add ibus widget to panel
right-click panel → Add Widgets → Input Method Panel
```

### XFCE Issues

**Problem**: IBus not starting automatically
```bash
# Check autostart entry
ls ~/.config/autostart/ibus.desktop

# Manually start ibus
ibus-daemon -drx
```

**Problem**: Environment variables not set
```bash
# Check current environment
env | grep -E "(GTK_IM|QT_IM|XMODIFIERS)"

# Source profile
source ~/.xprofile
```

## Manual Configuration Steps

### For Unsupported Environments

1. **Install base packages**:
```bash
sudo apt update
sudo apt install ibus ibus-typing-booster
```

2. **Set environment variables**:
```bash
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
```

3. **Start ibus daemon**:
```bash
ibus-daemon -drx
```

4. **Configure input engines**:
```bash
ibus-setup
# Add "Typing Booster" from the list
```

5. **Set up switching**:
```bash
# Configure keyboard shortcut for switching
# This varies by desktop environment
```

### Command Line Testing

**Test ibus functionality**:
```bash
# List available engines
ibus list-engine

# Switch to typing booster
ibus engine typing-booster

# Test in terminal
# Open a text editor and try typing
```

**Verify configuration**:
```bash
# Check current engine
ibus engine

# Monitor engine changes
ibus engine --monitor
```

## Future Compatibility

### Planned Improvements

- Better Wayland support detection
- Automated environment variable setup
- Desktop-specific configuration profiles
- GUI configuration tool for unsupported environments

### Known Limitations

- Some desktop environments may never have full support
- Wayland protocol limitations affect input method behavior
- Application-specific compatibility varies

## Contributing Environment Support

To add support for additional desktop environments:

1. **Test current functionality**
2. **Document specific requirements**
3. **Create environment detection logic**
4. **Add configuration templates**
5. **Update compatibility matrix**

### Testing Checklist

For each environment, verify:
- [ ] Package installation works
- [ ] Input method switching functions
- [ ] Settings persist across sessions
- [ ] Keyboard shortcuts work
- [ ] GUI integration is functional
- [ ] All applications support emoji input

## Environment Detection Code

The tool uses the following detection logic:

```bash
detect_desktop_environment() {
    local de=""
    
    # Primary detection methods
    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        de="$XDG_CURRENT_DESKTOP"
    elif [[ -n "${DESKTOP_SESSION:-}" ]]; then
        de="$DESKTOP_SESSION"
    fi
    
    # Fallback detection
    if [[ -z "$de" ]]; then
        if command -v gnome-shell >/dev/null 2>&1; then
            de="GNOME"
        elif command -v kwin >/dev/null 2>&1; then
            de="KDE"
        elif command -v xfce4-session >/dev/null 2>&1; then
            de="XFCE"
        fi
    fi
    
    echo "$de"
}
```

This ensures broad compatibility while providing appropriate warnings for unsupported environments.