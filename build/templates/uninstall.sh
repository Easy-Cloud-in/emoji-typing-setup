#!/usr/bin/env bash
# Simple uninstaller for emoji typing setup (Distribution Package)
# This version is specifically for the zip distribution package

set -e

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Uninstalling Emoji Typing..."

# Run the main uninstall (script is in root directory in zip package)
"$SCRIPT_DIR/emoji-typing-setup.sh" uninstall

# Remove aliases
echo "🗑️  Removing aliases..."
"$SCRIPT_DIR/setup-aliases.sh" remove

# Clean up any remaining files
rm -rf ~/.config/emoji-typing-setup 2>/dev/null || true
rm -f /tmp/emoji-typing-setup.log 2>/dev/null || true

echo ""
echo "✅ Uninstallation complete!"
echo "👋 Emoji typing has been removed from your system"
echo "💡 You may need to restart your terminal for alias removal to take effect"