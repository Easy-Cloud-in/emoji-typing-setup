#!/usr/bin/env bash
set -e

LOG_FILE="/tmp/emoji-typing-setup.log"

# Configuration
BACKUP_DIR="$HOME/.config/emoji-typing-setup"
BACKUP_FILE="$BACKUP_DIR/input-sources-backup"

echo "🧹 Removing emoji typing support..."
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Starting emoji typing removal" >> "$LOG_FILE"

# Check if backup exists and try to restore from it first
if [[ -f "$BACKUP_FILE" ]]; then
    echo "📁 Found backup, restoring original input sources..."
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Found backup, restoring input sources" >> "$LOG_FILE"
    # Extract original sources from backup file
    original_sources=$(grep -v '^#' "$BACKUP_FILE" | head -n 1 | xargs)

    if [[ -n "$original_sources" ]]; then
        if gsettings set org.gnome.desktop.input-sources sources "$original_sources"; then
            echo "✅ Original input sources restored from backup"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] Restored input sources from backup" >> "$LOG_FILE"
        else
            echo "⚠️  Failed to restore from backup, using default..."
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Failed to restore from backup, using default" >> "$LOG_FILE"
            gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
        fi
    else
        echo "⚠️  Invalid backup file, using default..."
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Invalid backup file, using default input sources" >> "$LOG_FILE"
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
    fi
else
    echo "📝 No backup found, resetting to English (US)..."
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] No backup found, resetting to US English" >> "$LOG_FILE"
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
fi

# Only remove ibus-typing-booster, not core IBus components
echo "🗑️  Removing ibus-typing-booster package..."
if dpkg -l ibus-typing-booster 2>/dev/null | grep -q "^ii"; then
    # Validate sudo access
    if ! sudo -n true 2>/dev/null; then
        echo "🔐 This operation requires sudo privileges..."
        if ! sudo -v; then
            echo "❌ Failed to obtain sudo privileges"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Failed to obtain sudo privileges for package removal" >> "$LOG_FILE"
            exit 1
        fi
    fi

    sudo apt-get remove -y ibus-typing-booster
    sudo apt-get autoremove -y
    echo "✅ ibus-typing-booster removed"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] ibus-typing-booster removed" >> "$LOG_FILE"
else
    echo "ℹ️  ibus-typing-booster was not installed"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ibus-typing-booster was not installed" >> "$LOG_FILE"
fi

# Reset input method configuration
echo "🔧 Resetting input method configuration..."
if command -v im-config >/dev/null 2>&1; then
    im-config -n none
    echo "✅ Input method reset"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] Input method reset using im-config" >> "$LOG_FILE"
else
    echo "ℹ️  im-config not available, skipping"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] im-config not available, skipping input method reset" >> "$LOG_FILE"
fi

# Restart IBus if it's running
echo "🔄 Restarting IBus..."
if pgrep -x "ibus-daemon" >/dev/null; then
    ibus restart || true
    echo "✅ IBus restarted"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] IBus restarted" >> "$LOG_FILE"
else
    echo "ℹ️  IBus was not running"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] IBus was not running" >> "$LOG_FILE"
fi

# Clean up backup files
if [[ -f "$BACKUP_FILE" ]]; then
    echo "🧹 Cleaning up backup files..."
    rm -f "$BACKUP_FILE"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
    echo "✅ Backup files cleaned up"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] Backup files cleaned up" >> "$LOG_FILE"
fi

echo ""
echo "✅ Emoji typing support has been removed"
echo "🔄 Please log out and log back in (or reboot) to fully apply changes"
echo ""
echo "📋 What was done:"
echo "   • Restored original input sources (or reset to US English)"
echo "   • Removed ibus-typing-booster package"
echo "   • Reset input method configuration"
echo "   • Cleaned up backup files"
echo ""
echo "🛠️ If you encounter any issues:"
echo "   • Run './src/validate-installation.sh' for troubleshooting"
echo "   • Check 'docs/TROUBLESHOOTING.md' for common problems"
echo "   • Review the log file at '/tmp/emoji-typing-setup.log'"
