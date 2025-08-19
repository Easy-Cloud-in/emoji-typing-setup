#!/usr/bin/env bash
# Performance monitoring script for emoji-typing-setup
# This script helps identify performance bottlenecks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/../emoji-typing-setup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

# Measure command execution time
measure_time() {
    local cmd="$1"
    local description="$2"
    
    log_info "Testing: $description"
    
    local start_time end_time duration
    start_time=$(date +%s.%N)
    
    # Execute command and capture output
    if eval "$cmd" >/dev/null 2>&1; then
        end_time=$(date +%s.%N)
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
        
        if command -v bc >/dev/null 2>&1; then
            log_success "$description completed in ${duration}s"
        else
            log_success "$description completed (timing unavailable)"
        fi
        return 0
    else
        end_time=$(date +%s.%N)
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
        
        if command -v bc >/dev/null 2>&1; then
            log_warn "$description failed after ${duration}s"
        else
            log_warn "$description failed (timing unavailable)"
        fi
        return 1
    fi
}

# Performance test suite
main() {
    echo "🚀 Emoji Typing Setup - Performance Monitor"
    echo "==========================================="
    echo
    
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo "❌ Main script not found: $MAIN_SCRIPT"
        exit 1
    fi
    
    # Test basic commands
    measure_time "$MAIN_SCRIPT --help" "Help command"
    measure_time "$MAIN_SCRIPT status" "Status command"
    
    # Test with different verbosity levels
    measure_time "$MAIN_SCRIPT --quiet status" "Quiet status"
    measure_time "$MAIN_SCRIPT --verbose status" "Verbose status"
    
    # Test configuration loading
    measure_time "$MAIN_SCRIPT --log-level DEBUG status" "Debug mode status"
    
    echo
    echo "📊 Performance Summary"
    echo "====================="
    echo "• Help command should complete in < 1s"
    echo "• Status command should complete in < 3s"
    echo "• Verbose mode may take slightly longer"
    echo "• Debug mode includes additional checks"
    
    if ! command -v bc >/dev/null 2>&1; then
        echo
        log_warn "Install 'bc' for precise timing measurements: sudo apt install bc"
    fi
}

main "$@"