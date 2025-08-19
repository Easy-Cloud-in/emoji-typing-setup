#!/usr/bin/env bash
# User Configuration Setup Script
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEFAULT_CONFIG="$PROJECT_DIR/config/default.conf"
USER_CONFIG_DIR="$HOME/.config/emoji-typing-setup"
USER_CONFIG_FILE="$USER_CONFIG_DIR/user.conf"

log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
}

show_help() {
    cat << 'EOF'
User Configuration Setup

This script helps you create a custom configuration file for emoji-typing-setup.

USAGE:
    setup-user-config.sh [OPTIONS]

OPTIONS:
    --create        Create a new user configuration file
    --edit          Edit existing user configuration
    --reset         Reset user configuration to defaults
    --show          Show current user configuration
    --help          Show this help message

EXAMPLES:
    setup-user-config.sh --create    # Create new user config
    setup-user-config.sh --edit      # Edit with default editor
    setup-user-config.sh --show      # Display current config
EOF
}

create_user_config() {
    log_info "Creating user configuration..."
    
    # Create directory if it doesn't exist
    if [[ ! -d "$USER_CONFIG_DIR" ]]; then
        mkdir -p "$USER_CONFIG_DIR"
        log_success "Created directory: $USER_CONFIG_DIR"
    fi
    
    # Check if user config already exists
    if [[ -f "$USER_CONFIG_FILE" ]]; then
        log_warn "User configuration already exists: $USER_CONFIG_FILE"
        read -p "Do you want to overwrite it? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Operation cancelled"
            return 0
        fi
    fi
    
    # Copy template to user config
    if [[ -f "$DEFAULT_CONFIG" ]]; then
        cp "$DEFAULT_CONFIG" "$USER_CONFIG_FILE"
        log_success "Created user configuration: $USER_CONFIG_FILE"
        
        # Add header to indicate this is a user config
        {
            echo "# USER CONFIGURATION FILE"
            echo "# This file overrides settings in config/settings.conf"
            echo "# Modify the settings below to customize your installation"
            echo ""
            cat "$USER_CONFIG_FILE"
        } > "$USER_CONFIG_FILE.tmp" && mv "$USER_CONFIG_FILE.tmp" "$USER_CONFIG_FILE"
        
        log_info "You can now edit this file to customize your settings"
        log_info "Run: $0 --edit"
    else
        log_error "Template configuration not found: $DEFAULT_CONFIG"
        return 1
    fi
}

edit_user_config() {
    if [[ ! -f "$USER_CONFIG_FILE" ]]; then
        log_error "User configuration not found: $USER_CONFIG_FILE"
        log_info "Run: $0 --create"
        return 1
    fi
    
    # Determine editor
    local editor="${EDITOR:-nano}"
    if ! command -v "$editor" >/dev/null 2>&1; then
        editor="vi"
    fi
    
    log_info "Opening user configuration with $editor..."
    "$editor" "$USER_CONFIG_FILE"
    log_success "Configuration editing completed"
}

show_user_config() {
    if [[ ! -f "$USER_CONFIG_FILE" ]]; then
        log_warn "No user configuration found"
        log_info "Run: $0 --create to create one"
        return 0
    fi
    
    log_info "Current user configuration:"
    echo "File: $USER_CONFIG_FILE"
    echo "----------------------------------------"
    cat "$USER_CONFIG_FILE"
}

reset_user_config() {
    if [[ ! -f "$USER_CONFIG_FILE" ]]; then
        log_warn "No user configuration to reset"
        return 0
    fi
    
    log_warn "This will delete your current user configuration"
    read -p "Are you sure? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$USER_CONFIG_FILE"
        log_success "User configuration reset"
    else
        log_info "Operation cancelled"
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        return 0
    fi
    
    case "${1:-}" in
        --create)
            create_user_config
            ;;
        --edit)
            edit_user_config
            ;;
        --show)
            show_user_config
            ;;
        --reset)
            reset_user_config
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            return 1
            ;;
    esac
}

main "$@"