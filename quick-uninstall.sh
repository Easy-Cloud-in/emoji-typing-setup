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
echo "🔄 Please restart your terminal or log out and log back in for all changes to take effect."
echo ""
echo "🛠️ If you encounter any issues:"
echo "   • Run './src/validate-installation.sh' for troubleshooting"
echo "   • Check 'docs/TROUBLESHOOTING.md' for common problems"
echo "   • Review the log file at '/tmp/emoji-typing-setup.log'"
