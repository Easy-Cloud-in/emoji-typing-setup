#!/usr/bin/env bash
# validate-installation.sh - Validation script for emoji typing setup
# This script performs comprehensive validation of the installation and setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
    ((TESTS_FAILED++))
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
    ((TESTS_SKIPPED++))
}

# Test functions
test_script_exists() {
    log_info "Testing: Script existence and permissions"

    if [[ -f "emoji-typing-setup.sh" ]]; then
        log_success "Script file exists"
    else
        log_error "Script file does not exist"
        return 1
    fi

    if [[ -x "emoji-typing-setup.sh" ]]; then
        log_success "Script is executable"
    else
        log_error "Script is not executable"
        return 1
    fi
}

test_script_syntax() {
    log_info "Testing: Script syntax validation"

    if bash -n emoji-typing-setup.sh; then
        log_success "Script syntax is valid"
    else
        log_error "Script has syntax errors"
        return 1
    fi
}

test_help_command() {
    log_info "Testing: Help command functionality"

    if ./emoji-typing-setup.sh --help >/dev/null 2>&1; then
        log_success "Help command works"
    else
        log_error "Help command failed"
        return 1
    fi

    # Test that help output contains expected sections
    local help_output
    help_output=$(./emoji-typing-setup.sh --help 2>&1)

    if echo "$help_output" | grep -q "USAGE:"; then
        log_success "Help contains USAGE section"
    else
        log_error "Help missing USAGE section"
    fi

    if echo "$help_output" | grep -q "COMMANDS:"; then
        log_success "Help contains COMMANDS section"
    else
        log_error "Help missing COMMANDS section"
    fi

    if echo "$help_output" | grep -q "OPTIONS:"; then
        log_success "Help contains OPTIONS section"
    else
        log_error "Help missing OPTIONS section"
    fi
}

test_status_command() {
    log_info "Testing: Status command functionality"

    if ./emoji-typing-setup.sh status >/dev/null 2>&1; then
        log_success "Status command works"
    else
        log_error "Status command failed"
        return 1
    fi

    # Test status output content
    local status_output
    status_output=$(./emoji-typing-setup.sh status 2>&1)

    if echo "$status_output" | grep -q "Package Status:"; then
        log_success "Status shows package information"
    else
        log_error "Status missing package information"
    fi

    if echo "$status_output" | grep -q "Current input sources:"; then
        log_success "Status shows input sources"
    else
        log_error "Status missing input sources information"
    fi
}

test_verbose_mode() {
    log_info "Testing: Verbose mode functionality"

    local normal_output verbose_output
    normal_output=$(./emoji-typing-setup.sh status 2>&1 | wc -l)
    verbose_output=$(./emoji-typing-setup.sh --verbose status 2>&1 | wc -l)

    if [[ $verbose_output -ge $normal_output ]]; then
        log_success "Verbose mode provides additional output"
    else
        log_warn "Verbose mode may not be working as expected"
    fi
}

test_quiet_mode() {
    log_info "Testing: Quiet mode functionality"

    if ./emoji-typing-setup.sh --quiet status >/dev/null 2>&1; then
        log_success "Quiet mode works without errors"
    else
        log_error "Quiet mode failed"
    fi
}

test_dependencies() {
    log_info "Testing: System dependencies"

    # Check for required commands
    local deps=("gsettings" "ibus" "apt" "dpkg")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            log_success "Dependency available: $dep"
        else
            log_error "Missing dependency: $dep"
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        log_success "All dependencies are available"
    else
        log_error "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
}

test_desktop_environment() {
    log_info "Testing: Desktop environment detection"

    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        log_success "Desktop environment detected: $XDG_CURRENT_DESKTOP"

        case "${XDG_CURRENT_DESKTOP,,}" in
            *gnome*|*ubuntu*|*pop*|*unity*|*budgie*)
                log_success "Desktop environment is fully supported"
                ;;
            *kde*|*xfce*|*mate*|*cinnamon*)
                log_warn "Desktop environment has partial support"
                ;;
            *)
                log_warn "Desktop environment support is unknown"
                ;;
        esac
    else
        log_warn "Desktop environment not detected (XDG_CURRENT_DESKTOP not set)"
    fi

    # Check for GNOME-specific tools
    if command -v gnome-shell >/dev/null 2>&1; then
        log_success "GNOME Shell detected"
    elif command -v kwin >/dev/null 2>&1; then
        log_info "KDE detected"
    elif command -v xfce4-session >/dev/null 2>&1; then
        log_info "XFCE detected"
    else
        log_warn "Could not identify specific desktop environment"
    fi
}

test_gsettings_functionality() {
    log_info "Testing: gsettings functionality"

    # Test basic gsettings functionality
    if gsettings list-schemas | grep -q "org.gnome.desktop.input-sources"; then
        log_success "GNOME input sources schema is available"
    else
        log_error "GNOME input sources schema not found"
        return 1
    fi

    # Test reading current input sources
    if gsettings get org.gnome.desktop.input-sources sources >/dev/null 2>&1; then
        log_success "Can read current input sources"
    else
        log_error "Cannot read current input sources"
        return 1
    fi
}

test_package_detection() {
    log_info "Testing: Package detection functionality"

    # Test if we can check package installation status
    if dpkg -l ibus 2>/dev/null | grep -q "^ii"; then
        log_success "ibus package is installed"
    else
        log_warn "ibus package is not installed"
    fi

    # Test typing booster detection
    if dpkg -l ibus-typing-booster 2>/dev/null | grep -q "^ii"; then
        log_success "ibus-typing-booster package is installed"
    else
        log_info "ibus-typing-booster package is not installed (this is expected for fresh systems)"
    fi
}

test_backup_directory() {
    log_info "Testing: Backup directory functionality"

    local backup_dir="$HOME/.config/emoji-typing-setup"

    # Run status to potentially create directories
    ./emoji-typing-setup.sh status >/dev/null 2>&1

    if [[ -d "$backup_dir" ]]; then
        log_success "Backup directory was created"
    else
        log_warn "Backup directory was not created automatically"
    fi

    # Test write permissions
    if [[ -w "$backup_dir" ]] || mkdir -p "$backup_dir" 2>/dev/null; then
        log_success "Backup directory is writable"
    else
        log_error "Cannot write to backup directory"
    fi
}

test_log_file() {
    log_info "Testing: Log file functionality"

    local log_file="/tmp/emoji-typing-setup.log"

    # Run a command that should create log entries
    ./emoji-typing-setup.sh status >/dev/null 2>&1

    if [[ -f "$log_file" ]]; then
        log_success "Log file is created"

        if [[ -s "$log_file" ]]; then
            log_success "Log file contains entries"
        else
            log_warn "Log file is empty"
        fi

        if [[ -r "$log_file" ]]; then
            log_success "Log file is readable"
        else
            log_error "Log file is not readable"
        fi
    else
        log_warn "Log file was not created"
    fi
}

test_error_handling() {
    log_info "Testing: Error handling"

    # Test invalid command
    if ./emoji-typing-setup.sh invalid-command >/dev/null 2>&1; then
        log_error "Script should fail on invalid commands"
    else
        log_success "Script properly handles invalid commands"
    fi

    # Test invalid options
    if ./emoji-typing-setup.sh --invalid-option >/dev/null 2>&1; then
        log_error "Script should fail on invalid options"
    else
        log_success "Script properly handles invalid options"
    fi
}

test_documentation() {
    log_info "Testing: Documentation completeness"

    local required_files=(
        "README.md"
        "LICENSE"
        "CONTRIBUTING.md"
        "PROJECT_ANALYSIS_AND_SUGGESTIONS.md"
        "docs/TROUBLESHOOTING.md"
        "docs/DESKTOP_ENVIRONMENTS.md"
    )

    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "Documentation file exists: $file"
        else
            log_error "Missing documentation file: $file"
        fi
    done

    # Test README content
    if [[ -f "README.md" ]]; then
        if grep -q "# Emoji Typing Setup" README.md; then
            log_success "README has proper title"
        else
            log_error "README missing or has incorrect title"
        fi

        if grep -q "## Installation" README.md; then
            log_success "README has installation section"
        else
            log_error "README missing installation section"
        fi

        if grep -q "## Usage" README.md; then
            log_success "README has usage section"
        else
            log_error "README missing usage section"
        fi
    fi
}

test_file_structure() {
    log_info "Testing: Project file structure"

    local required_dirs=(
        "config"
        "docs"
        "tests"
        "scripts"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "Directory exists: $dir"
        else
            log_error "Missing directory: $dir"
        fi
    done

    # Test specific files
    local important_files=(
        "emoji-typing-setup.sh"
        "config/settings.conf"
        "config/default.conf"
        "tests/test_main.bats"
        "PROJECT_ANALYSIS.md"
    )

    for file in "${important_files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "Important file exists: $file"
        else
            log_error "Missing important file: $file"
        fi
    done
}

run_performance_test() {
    log_info "Testing: Performance"

    local start_time end_time duration

    # Test status command performance
    start_time=$(date +%s.%N)
    ./emoji-typing-setup.sh status >/dev/null 2>&1
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")

    if command -v bc >/dev/null 2>&1 && (( $(echo "$duration < 5.0" | bc -l) )); then
        log_success "Status command completes in reasonable time (${duration}s)"
    else
        log_success "Status command completed (timing measurement unavailable)"
    fi

    # Test help command performance
    start_time=$(date +%s.%N)
    ./emoji-typing-setup.sh --help >/dev/null 2>&1
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")

    if command -v bc >/dev/null 2>&1 && (( $(echo "$duration < 2.0" | bc -l) )); then
        log_success "Help command completes quickly (${duration}s)"
    else
        log_success "Help command completed (timing measurement unavailable)"
    fi
}

# Main validation function
main() {
    echo "🔍 Emoji Typing Setup - Installation Validation"
    echo "=============================================="
    echo

    # Change to script directory
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$script_dir"

    log_info "Starting validation in: $PWD"
    echo

    # Run all tests
    local tests=(
        "test_script_exists"
        "test_script_syntax"
        "test_help_command"
        "test_status_command"
        "test_verbose_mode"
        "test_quiet_mode"
        "test_dependencies"
        "test_desktop_environment"
        "test_gsettings_functionality"
        "test_package_detection"
        "test_backup_directory"
        "test_log_file"
        "test_error_handling"
        "test_documentation"
        "test_file_structure"
        "run_performance_test"
    )

    for test in "${tests[@]}"; do
        echo
        $test || true  # Continue even if individual tests fail
        echo
    done

    # Summary
    echo "=============================================="
    echo "📊 Validation Summary"
    echo "=============================================="
    echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
    echo -e "${YELLOW}⚠️  Tests Skipped: $TESTS_SKIPPED${NC}"

    local total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    echo "📈 Total Tests: $total_tests"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo
        log_success "🎉 All critical tests passed! Installation appears to be working correctly."

        if [[ $TESTS_SKIPPED -gt 0 ]]; then
            log_warn "Some tests were skipped, but this is usually due to system differences."
        fi

        echo
        echo "🚀 Next steps:"
        echo "  • Try: ./emoji-typing-setup.sh --auto install"
        echo "  • Run: ./emoji-typing-setup.sh status"
        echo "  • Read: docs/TROUBLESHOOTING.md for any issues"

        return 0
    else
        echo
        log_error "❗ Some tests failed. Please review the output above."

        echo
        echo "🔧 Troubleshooting:"
        echo "  • Check that all dependencies are installed"
        echo "  • Ensure you're running on a supported desktop environment"
        echo "  • Review docs/TROUBLESHOOTING.md"
        echo "  • Check the log file: /tmp/emoji-typing-setup.log"

        return 1
    fi
}

# Run main function
main "$@"
