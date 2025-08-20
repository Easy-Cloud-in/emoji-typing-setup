#!/usr/bin/env bash
# Quick test to verify emoji typing is working

echo "🧪 Testing Emoji Typing Setup..."
echo ""

# Check if typing booster is installed
if dpkg -l ibus-typing-booster 2>/dev/null | grep -q "^ii"; then
    echo "✅ ibus-typing-booster is installed"
else
    echo "❌ ibus-typing-booster is not installed"
    echo "💡 Run: ./install.sh"
    exit 1
fi

# Check current input sources
current_sources=$(gsettings get org.gnome.desktop.input-sources sources 2>/dev/null || echo "[]")
if [[ "$current_sources" == *typing-booster* ]]; then
    echo "✅ Emoji typing is enabled"
else
    echo "❌ Emoji typing is not enabled"
    echo "💡 Run: ./src/emoji-typing-setup.sh enable"
    exit 1
fi

echo ""
echo "🎉 Everything looks good!"
echo "💡 Try pressing Ctrl+; or Super+; to test emoji typing"
echo "🔍 Type 'heart' and you should see ❤️ suggestions"