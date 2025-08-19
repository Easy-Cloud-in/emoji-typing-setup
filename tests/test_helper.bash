#!/usr/bin/env bash
# Test helper functions for emoji-typing-setup tests

# Setup test environment with mocks
setup_mocks() {
    export TEST_DIR="$(mktemp -d)"
    
    # Mock gsettings (GNOME settings)
    cat > "$TEST_DIR/gsettings" << 'EOF'
#!/bin/bash
case "$1 $2 $3" in
    "get org.gnome.desktop.input-sources sources")
        echo "[('xkb', 'us')]"
        ;;
    "set org.gnome.desktop.input-sources sources"*)
        echo "Settings updated" >&2
        exit 0
        ;;
    "list-schemas"*)
        echo "org.gnome.desktop.input-sources"
        ;;
    *)
        exit 0
        ;;
esac
EOF
    chmod +x "$TEST_DIR/gsettings"

    # Mock dpkg (package manager)
    cat > "$TEST_DIR/dpkg" << 'EOF'
#!/bin/bash
if [[ "$*" == *"-s ibus-typing-booster"* ]]; then
    echo "Package: ibus-typing-booster"
    echo "Status: install ok installed"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/dpkg"

    # Mock apt-get (package installer)
    cat > "$TEST_DIR/apt-get" << 'EOF'
#!/bin/bash
case "$1" in
    "update") echo "Reading package lists..." >&2 ;;
    "install") echo "Installing ibus-typing-booster..." >&2 ;;
esac
exit 0
EOF
    chmod +x "$TEST_DIR/apt-get"

    # Mock other required commands
    for cmd in ibus grep sed awk mkdir chmod; do
        echo '#!/bin/bash' > "$TEST_DIR/$cmd"
        echo 'exit 0' >> "$TEST_DIR/$cmd"
        chmod +x "$TEST_DIR/$cmd"
    done

    export PATH="$TEST_DIR:$PATH"
}

# Cleanup test environment
cleanup_mocks() {
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Create a test configuration
create_test_config() {
    local config_dir="$1"
    mkdir -p "$config_dir"
    
    cat > "$config_dir/settings.conf" << 'EOF'
SCRIPT_NAME="emoji-typing-setup"
SCRIPT_VERSION="2.1.0"
BACKUP_DIR="$HOME/.config/emoji-typing-setup"
BACKUP_FILE="$BACKUP_DIR/input-sources-backup"
LOCK_FILE="/tmp/emoji-typing-setup.lock"
REQUIRED_PACKAGE="ibus-typing-booster"
REQUIRED_COMMANDS="gsettings ibus grep sed awk mkdir chmod dpkg apt-get"
GSETTINGS_SCHEMA="org.gnome.desktop.input-sources"
GSETTINGS_KEY_SOURCES="sources"
DEFAULT_SOURCES_ENABLED="[('ibus', 'typing-booster'), ('xkb', 'us')]"
DEFAULT_SOURCES_DISABLED="[('xkb', 'us')]"
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_DEPENDENCY_ERROR=2
EXIT_SYSTEM_ERROR=4
LOG_LEVEL="INFO"
VERBOSE=false
QUIET=false
AUTO_INSTALL=false
FORCE_INSTALL=false
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m'
EOF
}