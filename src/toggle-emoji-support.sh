#!/usr/bin/env bash
# toggle-emoji-support.sh - Convenient wrapper for emoji typing control
# Part of Emoji Typing Setup project
# Version: 1.0.0

set -euo pipefail

# Get script directory and main script path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/emoji-typing-setup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Show usage information
show_usage() {
    cat << 'EOF'
Usage: toggle-emoji-support.sh [OPTION]

OPTIONS:
    --enable-emoji     Enable emoji typing functionality
    --disable-emoji    Disable emoji typing functionality  
    --status          Show current emoji typing status
    -h, --help        Show this help message

EXAMPLES:
    toggle-emoji-support.sh --enable-emoji
    toggle-emoji-support.sh --disable-emoji
    toggle-emoji-support.sh --status

This is a convenience wrapper around emoji-typing-setup.sh
EOF
}

# Main function
main() {
    # Check if main script exists
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo -e "${RED}❌ ERROR: Main script not found: $MAIN_SCRIPT${NC}" >&2
        exit 1
    fi

    # Make sure main script is executable
    chmod +x "$MAIN_SCRIPT"

    # Parse arguments
    case "${1:-}" in
        --enable-emoji)
            echo -e "${BLUE}🚀 Enabling emoji typing...${NC}"
            "$MAIN_SCRIPT" enable
            ;;
        --disable-emoji)
            echo -e "${YELLOW}⏸️  Disabling emoji typing...${NC}"
            "$MAIN_SCRIPT" disable
            ;;
        --status)
            "$MAIN_SCRIPT" status
            ;;
        -h|--help|"")
            show_usage
            ;;
        *)
            echo -e "${RED}❌ ERROR: Unknown option: $1${NC}" >&2
            echo
            show_usage
            exit 1
            ;;
    esac
}

main "$@"