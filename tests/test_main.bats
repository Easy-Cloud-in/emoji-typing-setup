#!/usr/bin/env bats
# Simple test suite for emoji-typing-setup
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR
# License: MIT License

# Test setup
setup() {
    # Store original environment
    export ORIGINAL_PATH="$PATH"
    export ORIGINAL_XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-}"

    # Create test environment
    export TEST_DIR="$(mktemp -d)"
    export TEST_CONFIG_DIR="$TEST_DIR/config"
    export TEST_CONFIG_FILE="$TEST_CONFIG_DIR/settings.conf"

    mkdir -p "$TEST_CONFIG_DIR"

    # Create minimal working config
    cat > "$TEST_CONFIG_FILE" << 'EOF'
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

    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../emoji-typing-setup-new.sh"
    [ -f "$SCRIPT_PATH" ]
}

teardown() {
    export PATH="$ORIGINAL_PATH"
    export XDG_CURRENT_DESKTOP="$ORIGINAL_XDG_CURRENT_DESKTOP"
    [ -d "$TEST_DIR" ] && rm -rf "$TEST_DIR"
}

# Create simple mocks that simulate a working system
setup_mocks() {
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

@test "emoji typing setup works correctly end-to-end" {
    # Set up working environment
    setup_mocks
    export XDG_CURRENT_DESKTOP="GNOME"

    # Test 1: Install should work
    run "$SCRIPT_PATH" --yes install
    [ "$status" -eq 0 ]
    [[ "$output" == *"completed successfully"* ]] || [[ "$output" == *"already installed"* ]]

    # Test 2: Status should show emoji typing is working
    run "$SCRIPT_PATH" status
    [ "$status" -eq 0 ]
    [[ "$output" == *"Status"* ]]

    # Test 3: Enable/disable should work
    run "$SCRIPT_PATH" enable
    [ "$status" -eq 0 ]

    run "$SCRIPT_PATH" disable
    [ "$status" -eq 0 ]

    echo "✅ Emoji typing setup is working correctly!"
}
