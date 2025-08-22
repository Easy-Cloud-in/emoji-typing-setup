#!/usr/bin/env bash
# emoji-typing-setup.sh - Enhanced emoji typing configuration tool
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR
# Version: 2.1.0
# License: MIT License
# Refactored: $(date +"%Y-%m-%d")
#
# Copyright (c) 2024 Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

set -euo pipefail

# Source configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/settings.conf"
USER_CONFIG_FILE="$HOME/.config/emoji-typing-setup/user.conf"

# Load main configuration
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
    exit 1
fi

# Load user configuration overrides if available
if [ -f "$USER_CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$USER_CONFIG_FILE"
    debug "Loaded user configuration: $USER_CONFIG_FILE"
fi

# Set color variables from config
RED="$COLOR_RED"
GREEN="$COLOR_GREEN"
YELLOW="$COLOR_YELLOW"
BLUE="$COLOR_BLUE"
NC="$COLOR_NC"

# Global variables for command line parsing
COMMAND=""
NEED_LOCK=false

# ============================================================================
# LOGGING SYSTEM WITH ROTATION
# ============================================================================

# Convert log level name to numeric value
get_log_level_value() {
    local level="$1"
    case "$level" in
        DEBUG)   echo "$LOG_LEVEL_DEBUG" ;;
        INFO)    echo "$LOG_LEVEL_INFO" ;;
        WARN)    echo "$LOG_LEVEL_WARN" ;;
        ERROR)   echo "$LOG_LEVEL_ERROR" ;;
        SUCCESS) echo "$LOG_LEVEL_SUCCESS" ;;
        *)       echo "$LOG_LEVEL_INFO" ;;
    esac
}

# Rotate log files when they exceed maximum size
rotate_log_files() {
    if [ ! -f "$LOG_FILE" ]; then
        return 0
    fi

    local log_size
    log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)

    if [ "$log_size" -gt "$LOG_MAX_SIZE" ]; then
        # Rotate existing backups
        for ((i = LOG_BACKUP_COUNT - 1; i >= 1; i--)); do
            local current_backup="${LOG_FILE}.${i}"
            local next_backup="${LOG_FILE}.$((i + 1))"
            [ -f "$current_backup" ] && mv "$current_backup" "$next_backup"
        done

        # Move current log to .1
        mv "$LOG_FILE" "${LOG_FILE}.1"
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

# Enhanced logging function with levels and rotation
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if this log level should be printed
    local current_level_value
    local message_level_value
    current_level_value=$(get_log_level_value "$LOG_LEVEL")
    message_level_value=$(get_log_level_value "$level")

    # Only log if message level is >= current log level
    if [ "$message_level_value" -ge "$current_level_value" ]; then
        # Console output (unless quiet mode)
        if [[ "$QUIET" != true ]]; then
            case "$level" in
                ERROR)   echo -e "${RED}❌ ERROR: $message${NC}" >&2 ;;
                WARN)    echo -e "${YELLOW}⚠️  WARNING: $message${NC}" ;;
                SUCCESS) echo -e "${GREEN}✅ $message${NC}" ;;
                INFO)    echo -e "${BLUE}ℹ️  $message${NC}" ;;
                DEBUG)   [[ "$VERBOSE" == true ]] && echo -e "${YELLOW}🐛 DEBUG: $message${NC}" ;;
            esac
        fi

        # File logging (if log file is writable)
        if [[ -w "$(dirname "$LOG_FILE")" ]]; then
            rotate_log_files
            echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
        fi
    fi
}

# Debug logging wrapper
debug() {
    log "DEBUG" "$*"
}

# ============================================================================
# INPUT VALIDATION
# ============================================================================

# Validate that required commands are available
validate_dependencies() {
    local missing_commands=()

    # Check each required command
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log "ERROR" "Missing required commands: ${missing_commands[*]}"
        log "ERROR" "Please install the missing dependencies and try again"
        return $EXIT_DEPENDENCY_ERROR
    fi

    return $EXIT_SUCCESS
}

# Validate command line arguments
validate_arguments() {
    # Check if command is provided
    if [ -z "$COMMAND" ]; then
        log "ERROR" "No command specified"
        return $EXIT_INVALID_ARGS
    fi

    # Validate command
    case "$COMMAND" in
        install|uninstall|enable|disable|status|backup|restore|help)
            return $EXIT_SUCCESS
            ;;
        *)
            log "ERROR" "Invalid command: $COMMAND"
            log "ERROR" "Valid commands: install, uninstall, enable, disable, status, backup, restore, help"
            return $EXIT_INVALID_ARGS
            ;;
    esac
}

# Validate system environment
validate_environment() {
    # Check if running on supported desktop environment
    local de
    de=$(detect_desktop_environment)

    if [ "$de" = "unknown" ]; then
        log "WARN" "Unknown or unsupported desktop environment"
        log "WARN" "This script is designed for GNOME-based environments"

        if [ "$FORCE_INSTALL" != true ]; then
            log "ERROR" "Use --force to override this check"
            return $EXIT_SYSTEM_ERROR
        fi
    fi

    return $EXIT_SUCCESS
}

# ============================================================================
# SYSTEM COMPATIBILITY AND DETECTION
# ============================================================================

# Detect the current desktop environment
detect_desktop_environment() {
    if [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
        case "${XDG_CURRENT_DESKTOP,,}" in
            *gnome*) echo "gnome" ;;
            *kde*) echo "kde" ;;
            *xfce*) echo "xfce" ;;
            *unity*) echo "unity" ;;
            *) echo "unknown" ;;
        esac
    elif [ -n "${DESKTOP_SESSION:-}" ]; then
        case "${DESKTOP_SESSION,,}" in
            gnome*) echo "gnome" ;;
            kde*) echo "kde" ;;
            xfce*) echo "xfce" ;;
            unity*) echo "unity" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

# Check system compatibility
check_system_compatibility() {
    log "INFO" "Checking system compatibility..."

    # Check if GSettings schema is available
    if ! gsettings list-schemas | grep -q "$GSETTINGS_SCHEMA"; then
        log "ERROR" "GSettings schema '$GSETTINGS_SCHEMA' not found"
        log "ERROR" "This usually means GNOME desktop is not installed"
        return $EXIT_SYSTEM_ERROR
    fi

    # Check IBus availability
    if ! command -v ibus >/dev/null 2>&1; then
        log "ERROR" "IBus is not available on this system"
        return $EXIT_DEPENDENCY_ERROR
    fi

    log "SUCCESS" "System compatibility check passed"
    return $EXIT_SUCCESS
}

# ============================================================================
# LOCK MANAGEMENT
# ============================================================================

# Acquire exclusive lock to prevent concurrent execution
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")

        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log "ERROR" "Another instance is already running (PID: $lock_pid)"
            return $EXIT_SYSTEM_ERROR
        else
            log "WARN" "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi

    # Create lock file with current PID
    echo $$ > "$LOCK_FILE"
    debug "Lock acquired (PID: $$)"
    return $EXIT_SUCCESS
}

# Check if lock is required for the given command
check_lock_required() {
    case "$COMMAND" in
        install|uninstall|enable|disable|restore|backup)
            return 0  # Lock required
            ;;
        *)
            return 1  # Lock not required
            ;;
    esac
}

# ============================================================================
# CLEANUP AND SIGNAL HANDLING
# ============================================================================

# Cleanup function called on script exit
cleanup() {
    local exit_code=$?

    # Remove lock file if we created it
    if [[ -f "$LOCK_FILE" ]] && [[ "$NEED_LOCK" == true ]]; then
        rm -f "$LOCK_FILE" 2>/dev/null || true
        debug "Lock released"
    fi

    # Log script completion
    if [ $exit_code -eq 0 ]; then
        debug "Script completed successfully"
    else
        debug "Script exited with code: $exit_code"
    fi

    exit $exit_code
}
trap cleanup EXIT

# Handle interruption signals
handle_signal() {
    local signal="$1"
    log "WARN" "Received signal: $signal"
    log "INFO" "Cleaning up and exiting..."
    exit $EXIT_USER_ABORT
}
trap 'handle_signal SIGINT' SIGINT
trap 'handle_signal SIGTERM' SIGTERM

# ============================================================================
# DIRECTORY AND FILE MANAGEMENT
# ============================================================================

# Set up required directories with proper permissions
setup_directories() {
    log "DEBUG" "Setting up directories..."

    # Create backup directory if it doesn't exist
    if [[ ! -d "$BACKUP_DIR" ]]; then
        if ! mkdir -p "$BACKUP_DIR"; then
            log "ERROR" "Failed to create backup directory: $BACKUP_DIR"
            return $EXIT_PERMISSION_ERROR
        fi
        chmod 755 "$BACKUP_DIR"
        debug "Created backup directory: $BACKUP_DIR"
    fi

    # Create log directory if it doesn't exist
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        if ! mkdir -p "$log_dir"; then
            log "WARN" "Failed to create log directory: $log_dir"
            # Continue without failing - logging to stderr instead
        else
            chmod 755 "$log_dir"
            debug "Created log directory: $log_dir"
        fi
    fi

    return $EXIT_SUCCESS
}

# ============================================================================
# CORE FUNCTIONALITY
# ============================================================================

# Get current input sources from GSettings
get_current_sources() {
    gsettings get "$GSETTINGS_SCHEMA" "$GSETTINGS_KEY_SOURCES" 2>/dev/null || echo "[]"
}

# Check if a package is installed
check_package_installed() {
    local package="$1"
    dpkg -s "$package" >/dev/null 2>&1
}

# Safe APT update with error handling
safe_apt_update() {
    log "INFO" "Updating package lists..."

    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if sudo apt-get update >/dev/null 2>&1; then
            log "SUCCESS" "Package lists updated successfully"
            return $EXIT_SUCCESS
        fi

        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            log "WARN" "APT update failed, retrying... ($retry_count/$max_retries)"
            sleep 2
        fi
    done

    log "ERROR" "Failed to update package lists after $max_retries attempts"
    return $EXIT_DEPENDENCY_ERROR
}

# Validate sudo access
validate_sudo_access() {
    if ! sudo -n true 2>/dev/null; then
        log "INFO" "This operation requires sudo privileges"
        if ! sudo -v; then
            log "ERROR" "Failed to obtain sudo privileges"
            return $EXIT_PERMISSION_ERROR
        fi
    fi
    return $EXIT_SUCCESS
}

# Install typing booster package
install_typing_booster() {
    log "INFO" "Installing $REQUIRED_PACKAGE..."

    # Check if already installed
    if check_package_installed "$REQUIRED_PACKAGE"; then
        log "INFO" "$REQUIRED_PACKAGE is already installed"
        return $EXIT_SUCCESS
    fi

    # Validate sudo access
    if ! validate_sudo_access; then
        return $EXIT_PERMISSION_ERROR
    fi

    # Update package lists
    if ! safe_apt_update; then
        return $EXIT_DEPENDENCY_ERROR
    fi

    # Install the package
    if sudo apt-get install -y "$REQUIRED_PACKAGE" >/dev/null 2>&1; then
        log "SUCCESS" "Successfully installed $REQUIRED_PACKAGE"
        return $EXIT_SUCCESS
    else
        log "ERROR" "Failed to install $REQUIRED_PACKAGE"
        log "ERROR" "Please check your internet connection and try again"
        return $EXIT_DEPENDENCY_ERROR
    fi
}

# Backup current input source settings
backup_current_settings() {
    log "INFO" "Backing up current input sources..."

    local current_sources
    current_sources=$(get_current_sources)

    # Create backup file with timestamp and current settings
    {
        echo "# Emoji Typing Setup - Settings Backup"
        echo "# Created: $(date)"
        echo "# Hostname: $(hostname)"
        echo "# User: $(whoami)"
        echo "# Original input sources:"
        echo "$current_sources"
    } > "$BACKUP_FILE"

    # Set secure permissions
    chmod 600 "$BACKUP_FILE"

    log "SUCCESS" "Settings backed up to: $BACKUP_FILE"
    return $EXIT_SUCCESS
}

# Restore settings from backup
restore_settings() {
    if [[ ! -f "$BACKUP_FILE" ]]; then
        log "ERROR" "No backup found at: $BACKUP_FILE"
        return $EXIT_SYSTEM_ERROR
    fi

    log "INFO" "Restoring input sources from backup..."

    # Extract original sources from backup file
    local original_sources
    original_sources=$(grep -v '^#' "$BACKUP_FILE" | head -n 1 | xargs)

    if [[ -z "$original_sources" ]]; then
        log "ERROR" "Invalid backup file format"
        return $EXIT_SYSTEM_ERROR
    fi

    # Restore the settings
    if gsettings set "$GSETTINGS_SCHEMA" "$GSETTINGS_KEY_SOURCES" "$original_sources"; then
        log "SUCCESS" "Original input sources have been restored"
        return $EXIT_SUCCESS
    else
        log "ERROR" "Failed to restore settings"
        return $EXIT_SYSTEM_ERROR
    fi
}

# Enable emoji typing functionality
enable_emoji_typing() {
    log "INFO" "Enabling emoji typing..."

    # Backup current settings if not already done
    if [[ ! -f "$BACKUP_FILE" ]]; then
        if ! backup_current_settings; then
            log "ERROR" "Failed to backup current settings"
            return $EXIT_SYSTEM_ERROR
        fi
    fi

    # Set typing booster as input source
    if gsettings set "$GSETTINGS_SCHEMA" "$GSETTINGS_KEY_SOURCES" "$DEFAULT_SOURCES_ENABLED"; then
        log "SUCCESS" "Emoji typing has been enabled"
        log "INFO" "You may need to log out and back in for changes to take full effect"
        return $EXIT_SUCCESS
    else
        log "ERROR" "Failed to enable emoji typing"
        return $EXIT_SYSTEM_ERROR
    fi
}

# Disable emoji typing functionality
disable_emoji_typing() {
    log "INFO" "Disabling emoji typing..."

    # Try to restore from backup first
    if [[ -f "$BACKUP_FILE" ]]; then
        if restore_settings; then
            return $EXIT_SUCCESS
        else
            log "WARN" "Failed to restore from backup, using default settings"
        fi
    fi

    # Fallback to default disabled layout
    if gsettings set "$GSETTINGS_SCHEMA" "$GSETTINGS_KEY_SOURCES" "$DEFAULT_SOURCES_DISABLED"; then
        log "SUCCESS" "Emoji typing has been disabled"
        return $EXIT_SUCCESS
    else
        log "ERROR" "Failed to disable emoji typing"
        return $EXIT_SYSTEM_ERROR
    fi
}

# Show current system status
show_status() {
    local current_sources
    current_sources=$(get_current_sources)

    echo -e "${BLUE}=== Emoji Typing Setup Status ===${NC}"
    echo -e "Script Version: ${YELLOW}$SCRIPT_VERSION${NC}"
    echo -e "Configuration: ${YELLOW}$CONFIG_FILE${NC}"
    echo -e "Desktop Environment: ${YELLOW}$(detect_desktop_environment)${NC}"
    echo
    echo -e "Current input sources: ${YELLOW}$current_sources${NC}"

    if [[ "$current_sources" == *typing-booster* ]]; then
        echo -e "Emoji typing status: ${GREEN}ENABLED${NC}"
    else
        echo -e "Emoji typing status: ${RED}DISABLED${NC}"
    fi

    # Check package status
    if check_package_installed "$REQUIRED_PACKAGE"; then
        echo -e "Package status: ${GREEN}$REQUIRED_PACKAGE is installed${NC}"
    else
        echo -e "Package status: ${RED}$REQUIRED_PACKAGE is not installed${NC}"
    fi

    # Check backup status
    if [[ -f "$BACKUP_FILE" ]]; then
        local backup_date
        backup_date=$(head -n 5 "$BACKUP_FILE" | grep "# Created:" | cut -d: -f2- | xargs)
        echo -e "Settings backup: ${GREEN}Available${NC} (${backup_date})"
    else
        echo -e "Settings backup: ${YELLOW}Not found${NC}"
    fi

    return $EXIT_SUCCESS
}

# Uninstall emoji support completely
uninstall_emoji_support() {
    log "INFO" "Uninstalling emoji support..."

    # First disable emoji typing
    if ! disable_emoji_typing; then
        log "WARN" "Could not disable emoji typing cleanly"
    fi

    # Remove the package
    if check_package_installed "$REQUIRED_PACKAGE"; then
        log "INFO" "Removing $REQUIRED_PACKAGE package..."
        if sudo apt-get remove -y "$REQUIRED_PACKAGE" >/dev/null 2>&1; then
            log "SUCCESS" "Successfully removed $REQUIRED_PACKAGE"
        else
            log "ERROR" "Failed to remove $REQUIRED_PACKAGE"
            return $EXIT_SYSTEM_ERROR
        fi
    else
        log "INFO" "$REQUIRED_PACKAGE is not installed"
    fi

    # Clean up backup files
    if [[ -f "$BACKUP_FILE" ]]; then
        log "INFO" "Removing backup file..."
        rm -f "$BACKUP_FILE"
        # Try to remove directory if empty
        rmdir "$BACKUP_DIR" 2>/dev/null || true
        log "SUCCESS" "Backup file removed"
    fi

    log "SUCCESS" "Emoji support has been completely uninstalled"
    return $EXIT_SUCCESS
}

# ============================================================================
# COMMAND HANDLERS
# ============================================================================

# Handle install command
handle_install() {
    log "INFO" "Starting emoji typing installation..."

    # Install required package
    if ! install_typing_booster; then
        log "ERROR" "Package installation failed"
        return $EXIT_DEPENDENCY_ERROR
    fi

    # Enable emoji typing
    if ! enable_emoji_typing; then
        log "ERROR" "Failed to enable emoji typing"
        return $EXIT_SYSTEM_ERROR
    fi

    log "SUCCESS" "Emoji typing setup completed successfully!"
    log "INFO" "You can now use Ctrl+; or Super+; to access emoji typing"

    return $EXIT_SUCCESS
}

# Handle uninstall command
handle_uninstall() {
    log "INFO" "Starting emoji typing uninstallation..."

    if ! uninstall_emoji_support; then
        log "ERROR" "Uninstallation failed"
        return $EXIT_SYSTEM_ERROR
    fi

    return $EXIT_SUCCESS
}

# Handle enable command
handle_enable() {
    log "INFO" "Enabling emoji typing..."

    # Check if package is installed
    if ! check_package_installed "$REQUIRED_PACKAGE"; then
        log "ERROR" "$REQUIRED_PACKAGE is not installed"
        log "INFO" "Run '$SCRIPT_NAME install' to install the required package first"
        return $EXIT_DEPENDENCY_ERROR
    fi

    if ! enable_emoji_typing; then
        return $EXIT_SYSTEM_ERROR
    fi

    return $EXIT_SUCCESS
}

# Handle disable command
handle_disable() {
    log "INFO" "Disabling emoji typing..."

    if ! disable_emoji_typing; then
        return $EXIT_SYSTEM_ERROR
    fi

    return $EXIT_SUCCESS
}

# Handle status command
handle_status() {
    show_status
    return $EXIT_SUCCESS
}

# Handle backup command
handle_backup() {
    log "INFO" "Creating backup of current settings..."

    if ! backup_current_settings; then
        return $EXIT_SYSTEM_ERROR
    fi

    return $EXIT_SUCCESS
}

# Handle restore command
handle_restore() {
    log "INFO" "Restoring settings from backup..."

    if ! restore_settings; then
        return $EXIT_SYSTEM_ERROR
    fi

    return $EXIT_SUCCESS
}

# ============================================================================
# HELP AND USAGE
# ============================================================================

# Display help information
show_help() {
    cat << 'EOF'
Emoji Typing Setup - Enhanced emoji typing configuration tool

USAGE:
    emoji-typing-setup.sh [OPTIONS] COMMAND

COMMANDS:
    install                 Install ibus-typing-booster and enable emoji typing
    uninstall              Remove ibus-typing-booster and restore original settings
    enable                 Enable emoji typing (package must be installed)
    disable                Disable emoji typing and restore original layout
    status                 Show current emoji typing status
    backup                 Create a backup of current input source settings
    restore                Restore input sources from backup
    help                   Show this help message

OPTIONS:
    -v, --verbose          Enable verbose output (shows debug messages)
    -q, --quiet            Suppress all output except errors
    -f, --force            Force operation even if system checks fail
    -y, --yes              Automatically answer yes to prompts (auto-install)
    --log-level LEVEL      Set logging level (DEBUG, INFO, WARN, ERROR, SUCCESS)
    --log-file FILE        Specify custom log file location

EXAMPLES:
    emoji-typing-setup.sh install
    emoji-typing-setup.sh status
    emoji-typing-setup.sh --verbose enable
    emoji-typing-setup.sh --quiet disable
    emoji-typing-setup.sh --log-level DEBUG install

KEYBOARD SHORTCUTS:
    Once installed, use Ctrl+; or Super+; to access emoji typing.

For more information, visit: https://www.easy-cloud.in
Project Repository: https://github.com/easy-cloud-dev/emoji-typing-setup
EOF
}

# ============================================================================
# COMMAND LINE PARSING
# ============================================================================

# Parse command line arguments
parse_arguments() {
    # Set defaults
    COMMAND=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            install|uninstall|enable|disable|status|backup|restore|help)
                if [[ -n "$COMMAND" ]]; then
                    log "ERROR" "Multiple commands specified: $COMMAND and $1"
                    exit $EXIT_INVALID_ARGS
                fi
                COMMAND="$1"
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                ;;
            -q|--quiet)
                QUIET=true
                ;;
            -f|--force)
                FORCE_INSTALL=true
                ;;
            -y|--yes)
                AUTO_INSTALL=true
                ;;
            --log-level)
                if [[ -n "${2:-}" ]]; then
                    LOG_LEVEL="$2"
                    shift
                else
                    log "ERROR" "--log-level requires an argument (DEBUG, INFO, WARN, ERROR, SUCCESS)"
                    exit $EXIT_INVALID_ARGS
                fi
                ;;
            --log-file)
                if [[ -n "${2:-}" ]]; then
                    LOG_FILE="$2"
                    shift
                else
                    log "ERROR" "--log-file requires an argument"
                    exit $EXIT_INVALID_ARGS
                fi
                ;;
            -h|--help)
                show_help
                exit $EXIT_SUCCESS
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_help
                exit $EXIT_INVALID_ARGS
                ;;
        esac
        shift
    done

    # Default to help if no command specified
    if [[ -z "$COMMAND" ]]; then
        COMMAND="help"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Main function - entry point of the script
main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Show help and exit if requested
    if [[ "$COMMAND" == "help" ]]; then
        show_help
        exit $EXIT_SUCCESS
    fi

    # Validate arguments
    if ! validate_arguments; then
        show_help
        exit $EXIT_INVALID_ARGS
    fi

    # Set up directories
    if ! setup_directories; then
        exit $EXIT_PERMISSION_ERROR
    fi

    # Acquire lock if needed
    if check_lock_required; then
        NEED_LOCK=true
        if ! acquire_lock; then
            exit $EXIT_SYSTEM_ERROR
        fi
    fi

    # Validate dependencies
    if ! validate_dependencies; then
        exit $EXIT_DEPENDENCY_ERROR
    fi

    # Check system compatibility
    if ! check_system_compatibility; then
        exit $EXIT_SYSTEM_ERROR
    fi

    # Validate environment
    if ! validate_environment; then
        exit $EXIT_SYSTEM_ERROR
    fi

    # Execute the requested command
    case "$COMMAND" in
        install)
            handle_install
            ;;
        uninstall)
            handle_uninstall
            ;;
        enable)
            handle_enable
            ;;
        disable)
            handle_disable
            ;;
        status)
            handle_status
            ;;
        backup)
            handle_backup
            ;;
        restore)
            handle_restore
            ;;
        *)
            log "ERROR" "Unknown command: $COMMAND"
            show_help
            exit $EXIT_INVALID_ARGS
            ;;
    esac

    return $?
}

# Start the script
main "$@"
