#!/usr/bin/env bash
# setup-aliases.sh - Set up convenient emoji typing aliases
# Part of Emoji Typing Setup project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the absolute path to the toggle script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOGGLE_SCRIPT="$SCRIPT_DIR/toggle-emoji-support.sh"

# Detect shell configuration file with error handling
detect_shell_config() {
    local shell_name
    
    # Check if SHELL variable is set
    if [[ -z "$SHELL" ]]; then
        echo -e "${YELLOW}⚠️  Warning: SHELL environment variable not set, defaulting to bash${NC}" >&2
        shell_name="bash"
    else
        shell_name=$(basename "$SHELL")
    fi
    
    # Check if HOME is set
    if [[ -z "$HOME" ]]; then
        echo -e "${RED}❌ ERROR: HOME environment variable not set${NC}" >&2
        return 1
    fi
    
    case "$shell_name" in
        bash)
            # Priority order: .bashrc, .bash_profile, create .bashrc
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"  # Will be created if needed
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Warning: Unknown shell '$shell_name', defaulting to bash config${NC}" >&2
            echo "$HOME/.bashrc"
            ;;
    esac
}

# Set up aliases for bash/zsh with error handling
setup_bash_zsh_aliases() {
    local config_file="$1"
    local config_dir
    config_dir=$(dirname "$config_file")
    
    # Check if config directory exists and is writable
    if [[ ! -d "$config_dir" ]]; then
        echo -e "${RED}❌ ERROR: Directory $config_dir does not exist${NC}" >&2
        return 1
    fi
    
    if [[ ! -w "$config_dir" ]]; then
        echo -e "${RED}❌ ERROR: No write permission to $config_dir${NC}" >&2
        return 1
    fi
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        echo -e "${BLUE}ℹ️  Creating new config file: $config_file${NC}"
        if ! touch "$config_file"; then
            echo -e "${RED}❌ ERROR: Cannot create $config_file${NC}" >&2
            return 1
        fi
    fi
    
    # Check if config file is writable
    if [[ ! -w "$config_file" ]]; then
        echo -e "${RED}❌ ERROR: No write permission to $config_file${NC}" >&2
        return 1
    fi
    
    local aliases_block="
# Emoji Typing Setup aliases - Added by emoji-typing-setup
alias emoji-on=\"$TOGGLE_SCRIPT --enable-emoji\"
alias emoji-off=\"$TOGGLE_SCRIPT --disable-emoji\"
alias emoji-status=\"$TOGGLE_SCRIPT --status\"
# End Emoji Typing Setup aliases"

    # Check if aliases already exist
    if grep -q "# Emoji Typing Setup aliases" "$config_file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Aliases already exist in $config_file${NC}"
        echo -e "${BLUE}ℹ️  Updating existing aliases...${NC}"
        
        # Remove old aliases block and add new one
        if ! sed -i '/# Emoji Typing Setup aliases/,/# End Emoji Typing Setup aliases/d' "$config_file"; then
            echo -e "${RED}❌ ERROR: Failed to update existing aliases${NC}" >&2
            return 1
        fi
    fi

    # Add aliases to config file
    if echo "$aliases_block" >> "$config_file"; then
        echo -e "${GREEN}✅ Aliases added to $config_file${NC}"
        return 0
    else
        echo -e "${RED}❌ ERROR: Failed to write aliases to $config_file${NC}" >&2
        return 1
    fi
}

# Set up aliases for fish shell with error handling
setup_fish_aliases() {
    local config_file="$1"
    local config_dir
    config_dir=$(dirname "$config_file")
    
    # Create config directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        echo -e "${BLUE}ℹ️  Creating fish config directory: $config_dir${NC}"
        if ! mkdir -p "$config_dir"; then
            echo -e "${RED}❌ ERROR: Cannot create directory $config_dir${NC}" >&2
            return 1
        fi
    fi
    
    # Check if config directory is writable
    if [[ ! -w "$config_dir" ]]; then
        echo -e "${RED}❌ ERROR: No write permission to $config_dir${NC}" >&2
        return 1
    fi
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        echo -e "${BLUE}ℹ️  Creating new fish config file: $config_file${NC}"
        if ! touch "$config_file"; then
            echo -e "${RED}❌ ERROR: Cannot create $config_file${NC}" >&2
            return 1
        fi
    fi
    
    # Check if config file is writable
    if [[ ! -w "$config_file" ]]; then
        echo -e "${RED}❌ ERROR: No write permission to $config_file${NC}" >&2
        return 1
    fi
    
    local aliases_block="
# Emoji Typing Setup aliases - Added by emoji-typing-setup
alias emoji-on=\"$TOGGLE_SCRIPT --enable-emoji\"
alias emoji-off=\"$TOGGLE_SCRIPT --disable-emoji\"
alias emoji-status=\"$TOGGLE_SCRIPT --status\"
# End Emoji Typing Setup aliases"

    # Check if aliases already exist
    if grep -q "# Emoji Typing Setup aliases" "$config_file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Aliases already exist in $config_file${NC}"
        echo -e "${BLUE}ℹ️  Updating existing aliases...${NC}"
        
        # Remove old aliases block and add new one
        if ! sed -i '/# Emoji Typing Setup aliases/,/# End Emoji Typing Setup aliases/d' "$config_file"; then
            echo -e "${RED}❌ ERROR: Failed to update existing aliases${NC}" >&2
            return 1
        fi
    fi

    # Add aliases to config file
    if echo "$aliases_block" >> "$config_file"; then
        echo -e "${GREEN}✅ Aliases added to $config_file${NC}"
        return 0
    else
        echo -e "${RED}❌ ERROR: Failed to write aliases to $config_file${NC}" >&2
        return 1
    fi
}

# Remove aliases from configuration file with error handling
remove_aliases() {
    local config_file="$1"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        echo -e "${YELLOW}⚠️  Config file does not exist: $config_file${NC}"
        return 0
    fi
    
    # Check if config file is writable
    if [[ ! -w "$config_file" ]]; then
        echo -e "${RED}❌ ERROR: No write permission to $config_file${NC}" >&2
        return 1
    fi
    
    # Check if aliases exist
    if grep -q "# Emoji Typing Setup aliases" "$config_file" 2>/dev/null; then
        if sed -i '/# Emoji Typing Setup aliases/,/# End Emoji Typing Setup aliases/d' "$config_file"; then
            echo -e "${GREEN}✅ Aliases removed from $config_file${NC}"
            return 0
        else
            echo -e "${RED}❌ ERROR: Failed to remove aliases from $config_file${NC}" >&2
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  No aliases found in $config_file${NC}"
        return 0
    fi
}

# Show current aliases
show_aliases() {
    echo -e "${BLUE}=== Emoji Typing Aliases ===${NC}"
    echo -e "${GREEN}emoji-on${NC}      - Enable emoji typing"
    echo -e "${GREEN}emoji-off${NC}     - Disable emoji typing"  
    echo -e "${GREEN}emoji-status${NC}  - Show current status"
    echo
    echo -e "${YELLOW}Note: You may need to restart your terminal or run 'source ~/.bashrc' for aliases to take effect${NC}"
}

# Main function
main() {
    case "${1:-install}" in
        install)
            echo -e "${BLUE}🚀 Setting up emoji typing aliases...${NC}"
            
            # Check if toggle script exists
            if [[ ! -f "$TOGGLE_SCRIPT" ]]; then
                echo -e "${RED}❌ ERROR: Toggle script not found: $TOGGLE_SCRIPT${NC}" >&2
                exit 1
            fi
            
            # Make toggle script executable
            if ! chmod +x "$TOGGLE_SCRIPT"; then
                echo -e "${RED}❌ ERROR: Cannot make toggle script executable${NC}" >&2
                exit 1
            fi
            
            # Detect and set up aliases for current shell
            local config_file
            if ! config_file=$(detect_shell_config); then
                echo -e "${RED}❌ ERROR: Failed to detect shell configuration${NC}" >&2
                exit 1
            fi
            
            echo -e "${BLUE}ℹ️  Detected shell config: $config_file${NC}"
            
            # Set up aliases based on shell type
            if [[ "$config_file" == *"config.fish" ]]; then
                if ! setup_fish_aliases "$config_file"; then
                    echo -e "${RED}❌ ERROR: Failed to set up fish aliases${NC}" >&2
                    exit 1
                fi
            else
                if ! setup_bash_zsh_aliases "$config_file"; then
                    echo -e "${RED}❌ ERROR: Failed to set up bash/zsh aliases${NC}" >&2
                    exit 1
                fi
            fi
            
            show_aliases
            ;;
        remove)
            echo -e "${YELLOW}🗑️  Removing emoji typing aliases...${NC}"
            
            local config_file
            if ! config_file=$(detect_shell_config); then
                echo -e "${RED}❌ ERROR: Failed to detect shell configuration${NC}" >&2
                exit 1
            fi
            
            if ! remove_aliases "$config_file"; then
                echo -e "${RED}❌ ERROR: Failed to remove aliases${NC}" >&2
                exit 1
            fi
            ;;
        show)
            show_aliases
            ;;
        *)
            echo "Usage: $0 [install|remove|show]"
            echo "  install  - Add emoji typing aliases to shell config (default)"
            echo "  remove   - Remove emoji typing aliases from shell config"
            echo "  show     - Show available aliases"
            exit 1
            ;;
    esac
}

main "$@"