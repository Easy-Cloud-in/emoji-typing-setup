# Troubleshooting Guide

## Common Issues

### 1. "Package not found" error

```bash
sudo apt update
./install.sh
```

### 2. Emoji typing not working after install

```bash
# Log out and log back in, then test
./test-emoji.sh
```

### 3. Wrong desktop environment detected

```bash
# Force install (use with caution)
./src/emoji-typing-setup.sh --force install
```

### 4. Permission denied errors

```bash
# Make sure scripts are executable
chmod +x *.sh src/*.sh
```

### 5. IBus not starting

```bash
# Restart IBus
ibus restart
# Or reboot your system
```

## Getting Help

1. Run the validation script: `./src/validate-installation.sh`
2. Check the log file: `cat /tmp/emoji-typing-setup.log`
3. Test your system: `./test-emoji.sh`

## Manual Cleanup

If something goes wrong:

```bash
./uninstall.sh
# Or manually:
sudo apt remove ibus-typing-booster
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
```
