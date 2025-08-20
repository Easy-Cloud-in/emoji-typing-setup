#!/usr/bin/env bash
# Simple uninstaller for emoji typing setup

set -e

echo "🧹 Uninstalling Emoji Typing..."

# Run the main uninstall
./src/emoji-typing-setup.sh uninstall

# Remove aliases
echo "🗑️  Removing aliases..."
./src/setup-aliases.sh remove

# Clean up any remaining files
rm -rf ~/.config/emoji-typing-setup 2>/dev/null || true
rm -f /tmp/emoji-typing-setup.log 2>/dev/null || true

echo ""
echo "✅ Uninstallation complete!"
echo "👋 Emoji typing has been removed from your system"
echo "💡 You may need to restart your terminal for alias removal to take effect"