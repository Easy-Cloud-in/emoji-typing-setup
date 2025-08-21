#!/usr/bin/env bash
# Simple one-command installer for emoji typing on Linux
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/main/install.sh | bash

set -e

echo "🚀 Installing Emoji Typing for Linux..."

# Make scripts executable
chmod +x src/*.sh

# Run the main installation
./src/emoji-typing-setup.sh install

# Set up convenient aliases
echo ""
echo "🔧 Setting up convenient aliases..."
./src/setup-aliases.sh install

echo ""
echo "✅ Installation complete!"
echo "💡 Use Ctrl+; or Super+; to access emoji typing"
echo ""
echo "🎯 Quick commands now available:"
echo "   emoji-on      - Enable emoji typing"
echo "   emoji-off     - Disable emoji typing"
echo "   emoji-status  - Check current status"
echo ""
echo "📖 Run './src/emoji-typing-setup.sh help' for more options"
echo ""
echo "🔄 Please restart your terminal or log out and log back in for all changes to take effect."
echo ""
echo "🛠️ If you encounter any issues:"
echo "   • Run './src/validate-installation.sh' for troubleshooting"
echo "   • Check 'docs/TROUBLESHOOTING.md' for common problems"
echo "   • Review the log file at '/tmp/emoji-typing-setup.log'"
