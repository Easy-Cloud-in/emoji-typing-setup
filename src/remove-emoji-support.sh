#!/usr/bin/env bash
set -e

echo "🧹 Removing ibus-typing-booster and related packages..."
sudo apt purge -y ibus-typing-booster ibus-gtk ibus-gtk3 ibus-gtk4 ibus-clutter
sudo apt autoremove -y

echo "🔧 Resetting input sources to English (US)..."
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"

echo "🔧 Resetting default input method..."
im-config -n none

echo "🔄 Restarting IBus (safe to ignore if it's gone)..."
ibus restart || true

echo ""
echo "✅ System restored to normal typing (English US only)."
echo "👉 Please log out and log back in (or reboot) to fully apply changes."
