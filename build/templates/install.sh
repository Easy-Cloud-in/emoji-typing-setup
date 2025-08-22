#!/usr/bin/env bash
# Simple one-command installer for emoji typing on Linux (Distribution Package)
# This version is specifically for the zip distribution package

set -e

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Installing Emoji Typing for Linux..."

# Make scripts executable (all scripts are in root directory in zip package)
chmod +x "$SCRIPT_DIR"/*.sh

# Run the main installation
"$SCRIPT_DIR/emoji-typing-setup.sh" install

# Set up convenient aliases
echo ""
echo "🔧 Setting up convenient aliases..."
"$SCRIPT_DIR/setup-aliases.sh" install

echo ""
echo "✅ Installation complete!"
echo "💡 Use Ctrl+; or Super+; to access emoji typing"
echo ""
echo "🎯 Quick commands now available:"
echo "   emoji-on      - Enable emoji typing"
echo "   emoji-off     - Disable emoji typing"
echo "   emoji-status  - Check current status"
echo ""
echo "📖 Run '$SCRIPT_DIR/emoji-typing-setup.sh help' for more options"