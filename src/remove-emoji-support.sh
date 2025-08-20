#!/usr/bin/env bash
set -e

# Configuration
BACKUP_DIR="$HOME/.config/emoji-typing-setup"
BACKUP_FILE="$BACKUP_DIR/input-sources-backup"

echo "🧹 Removing emoji typing support..."

# Check if backup exists and try to restore from it first
if [[ -f "$BACKUP_FILE" ]]; then
    echo "📁 Found backup, restoring original input sources..."
    
    # Extract original sources from backup file
    original_sources=$(grep -v '^#' "$BACKUP_FILE" | head -n 1 | xargs)
    
    if [[ -n "$original_sources" ]]; then
        if gsettings set org.gnome.desktop.input-sources sources "$original_sources"; then
            echo "✅ Original input sources restored from backup"
        else
            echo "⚠️  Failed to restore from backup, using default..."
            gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
        fi
    else
        echo "⚠️  Invalid backup file, using default..."
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
    fi
else
    echo "📝 No backup found, resetting to English (US)..."
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
            exit 1
        fi
    fi
    
    sudo apt-get remove -y ibus-typing-booster
    sudo apt-get autoremove -y
    echo "✅ ibus-typing-booster removed"
else
    echo "ℹ️  ibus-typing-booster was not installed"
fi

# Reset input method configuration
echo "🔧 Resetting input method configuration..."
if command -v im-config >/dev/null 2>&1; then
    im-config -n none
    echo "✅ Input method reset"
else
    echo "ℹ️  im-config not available, skipping"
fi

# Restart IBus if it's running
echo "🔄 Restarting IBus..."
if pgrep -x "ibus-daemon" >/dev/null; then
    ibus restart || true
    echo "✅ IBus restarted"
else
    echo "ℹ️  IBus was not running"
fi

# Clean up backup files
if [[ -f "$BACKUP_FILE" ]]; then
    echo "🧹 Cleaning up backup files..."
    rm -f "$BACKUP_FILE"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
    echo "✅ Backup files cleaned up"
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
