#!/usr/bin/env bash
# get-version.sh - Extract version from git tags or CHANGELOG.md
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[VERSION]${NC} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Get version from CHANGELOG.md
get_version_from_changelog() {
    local changelog_file="$PROJECT_ROOT/CHANGELOG.md"
    
    if [[ ! -f "$changelog_file" ]]; then
        return 1
    fi
    
    # Look for version pattern: ## [vX.Y.Z] or ## vX.Y.Z
    local version
    version=$(grep -m 1 '^## \[v[0-9]' "$changelog_file" 2>/dev/null | sed -E 's/^## \[v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || true)
    
    if [[ -z "$version" ]]; then
        # Try alternative format: ## vX.Y.Z
        version=$(grep -m 1 '^## v[0-9]' "$changelog_file" 2>/dev/null | sed -E 's/^## v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || true)
    fi
    
    if [[ -n "$version" ]]; then
        echo "$version"
        return 0
    fi
    
    return 1
}

# Get latest git tag version
get_version_from_git_tags() {
    # Fetch tags from remote
    git fetch --tags 2>/dev/null || true
    
    # Get latest version tag (format: vX.Y.Z)
    local latest_tag
    latest_tag=$(git tag -l "v*.*.*" | sort -V | tail -1 2>/dev/null || true)
    
    if [[ -n "$latest_tag" ]]; then
        # Remove 'v' prefix
        echo "${latest_tag#v}"
        return 0
    fi
    
    return 1
}

# Check if we're on main branch and clean (ignoring CHANGELOG.md)
check_git_state() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    
    if [[ "$current_branch" != "main" ]]; then
        error "Not on main branch. Current branch: $current_branch"
        return 1
    fi
    
    # Check for uncommitted changes (IGNORING CHANGELOG.md)
    local has_changes
    has_changes=$(git status --porcelain | grep -v "^[AM]  CHANGELOG.md$" | grep -v "^ M CHANGELOG.md$" || true)
    
    if [[ -n "$has_changes" ]]; then
        error "Working tree is not clean (excluding CHANGELOG.md changes)"
        error "Please commit or stash your changes before running this script"
        error "Uncommitted files (excluding CHANGELOG.md):"
        git status --porcelain | grep -v "CHANGELOG.md" >&2
        return 1
    fi
    
    # Show info if CHANGELOG.md has changes but continue
    local changelog_changes
    changelog_changes=$(git status --porcelain | grep "CHANGELOG.md" || true)
    if [[ -n "$changelog_changes" ]]; then
        log "CHANGELOG.md has uncommitted changes - this is allowed"
        log "Changes: $changelog_changes"
    fi
    
    return 0
}

# Check if this is the first push to origin/main
is_first_push() {
    # Check if origin/main exists
    if ! git rev-parse --verify origin/main >/dev/null 2>&1; then
        return 0  # No origin/main means first push
    fi
    
    # Check if there are any tags
    if ! git tag -l | grep -q "v[0-9]"; then
        return 0  # No version tags means first push
    fi
    
    return 1
}

# Main version detection logic
get_version() {
    local version=""
    local source=""
    
    # First, try to get version from CHANGELOG.md
    if version=$(get_version_from_changelog); then
        source="CHANGELOG.md"
        log "Version found in CHANGELOG.md: $version"
    elif version=$(get_version_from_git_tags); then
        source="git tags"
        log "Version found in git tags: $version"
    elif is_first_push; then
        version="1.0.0"
        source="default (first push)"
        log "First push detected, using default version: $version"
    else
        error "Could not determine version from any source"
        return 1
    fi
    
    # Output just the version number (for scripts)
    echo "$version"
    return 0
}

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Extract version number from git tags, CHANGELOG.md, or default to 1.0.0"
    echo ""
    echo "Options:"
    echo "  --check-git    Also validate git state (main branch, clean tree, ignores CHANGELOG.md)"
    echo "  --verbose      Show version source information"
    echo "  -h, --help     Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                    # Get version number only"
    echo "  $0 --verbose          # Show version and source"
    echo "  $0 --check-git        # Validate git state too"
}

# Parse arguments
CHECK_GIT=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-git)
            CHECK_GIT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Change to project root
cd "$PROJECT_ROOT"

# Check git state if requested
if [[ "$CHECK_GIT" == true ]]; then
    if ! check_git_state; then
        exit 1
    fi
    log "Git state is clean and on main branch"
fi

# Get and output version
if version=$(get_version); then
    if [[ "$VERBOSE" == true ]]; then
        log "Final version: $version"
    fi
    echo "$version"
    exit 0
else
    exit 1
fi