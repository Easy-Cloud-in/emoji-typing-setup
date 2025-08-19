#!/usr/bin/env bash
# build-dist.sh - Create distribution packages
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$SCRIPT_DIR"
STAGING_DIR="$BUILD_DIR/staging"
TEMPLATES_DIR="$BUILD_DIR/templates"
DIST_DIR="$PROJECT_ROOT/dist"
PACKAGE_NAME="emoji-typing-setup"

# Parse arguments
SKIP_CHECKS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-checks)
            SKIP_CHECKS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[BUILD]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Perform git state validation
validate_git_state() {
    if [[ "$SKIP_CHECKS" == true ]]; then
        log "⚠️  Skipping git state validation as requested"
        return 0
    fi
    
    log "🔍 Performing git state validation..."
    
    # Check if we're on the main branch
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if [[ "$current_branch" != "main" ]]; then
        error "Not on main branch. Current branch: $current_branch"
        error "Please switch to main branch before building."
        return 1
    fi
    
    # Fetch latest changes from origin
    log "📡 Fetching latest changes from origin..."
    git fetch origin
    
    # Check if main is up to date with origin/main
    local local_commit remote_commit
    local_commit=$(git rev-parse main)
    remote_commit=$(git rev-parse origin/main 2>/dev/null || echo "")
    
    if [[ -n "$remote_commit" && "$local_commit" != "$remote_commit" ]]; then
        error "Local main branch is not up to date with origin/main"
        error "Local:  $local_commit"
        error "Remote: $remote_commit"
        error "Please pull latest changes: git pull origin main"
        return 1
    fi
    
    # Check working tree status (allow CHANGELOG.md changes)
    local git_status filtered_status
    git_status=$(git status --porcelain)
    filtered_status=$(echo "$git_status" | grep -v "CHANGELOG.md" || true)
    
    if [[ -n "$filtered_status" ]]; then
        error "Working tree is not clean (excluding CHANGELOG.md)"
        error "Uncommitted changes:"
        echo "$filtered_status" >&2
        error "Please commit or stash your changes before building."
        return 1
    fi
    
    # Show info if CHANGELOG.md has changes but continue
    local changelog_changes
    changelog_changes=$(echo "$git_status" | grep "CHANGELOG.md" || true)
    if [[ -n "$changelog_changes" ]]; then
        log "ℹ️  Note: CHANGELOG.md has uncommitted changes (this is allowed)"
        log "   Changes: $changelog_changes"
    fi
    
    success "Git state validation passed!"
    log "   - On main branch: $current_branch"
    log "   - Up to date with origin/main"
    log "   - Working tree clean (CHANGELOG.md changes allowed)"
}

# Check dependencies
check_dependencies() {
    if ! command -v zip >/dev/null 2>&1; then
        error "zip command not found. Please install zip utility"
        exit 1
    fi
    
    if [[ ! -f "$TEMPLATES_DIR/files.list" ]]; then
        error "files.list template not found: $TEMPLATES_DIR/files.list"
        exit 1
    fi
}

# Clean and prepare staging area
prepare_staging() {
    log "Preparing staging area..."
    
    # Always start fresh
    rm -rf "$STAGING_DIR"
    mkdir -p "$STAGING_DIR/$PACKAGE_NAME"
    
    log "Staging area cleaned and ready: $STAGING_DIR"
}

# Copy files based on files.list template
copy_distribution_files() {
    log "Copying distribution files..."
    
    while IFS=':' read -r source_path dest_path || [[ -n "$source_path" ]]; do
        # Skip comments and empty lines
        [[ "$source_path" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$source_path" ]] && continue
        
        # Handle default destination path
        if [[ -z "$dest_path" ]]; then
            dest_path="$(basename "$source_path")"
        fi
        
        local full_source="$PROJECT_ROOT/$source_path"
        local full_dest="$STAGING_DIR/$PACKAGE_NAME/$dest_path"
        
        # Create destination directory if needed
        mkdir -p "$(dirname "$full_dest")"
        
        # Copy file
        if [[ -f "$full_source" ]]; then
            cp "$full_source" "$full_dest"
            log "  ✓ $source_path → $dest_path"
        else
            error "Source file not found: $full_source"
            return 1
        fi
    done < "$TEMPLATES_DIR/files.list"
}

# Set proper permissions
set_permissions() {
    log "Setting file permissions..."
    
    # Make shell scripts executable
    find "$STAGING_DIR/$PACKAGE_NAME" -name "*.sh" -exec chmod +x {} \;
    
    # Ensure config files are readable
    find "$STAGING_DIR/$PACKAGE_NAME" -name "*.conf" -exec chmod 644 {} \;
}

# Create final distribution package
create_package() {
    log "Creating distribution package..."
    
    # Ensure dist directory exists
    mkdir -p "$DIST_DIR"
    
    # Remove any existing package with same name
    rm -f "$DIST_DIR/$ARCHIVE_NAME"
    
    # Create zip from staging area
    cd "$STAGING_DIR"
    zip -r "$DIST_DIR/$ARCHIVE_NAME" "$PACKAGE_NAME/" >/dev/null
    
    local archive_size
    archive_size=$(du -h "$DIST_DIR/$ARCHIVE_NAME" | cut -f1)
    
    success "Distribution created: $ARCHIVE_NAME ($archive_size)"
    echo "📁 Location: $DIST_DIR/$ARCHIVE_NAME"
}

# Clean up staging area
cleanup_staging() {
    log "Cleaning up staging area..."
    rm -rf "$STAGING_DIR"
}

# Main build process
build_distribution() {
    # Get version dynamically (after git validation)
    if ! VERSION=$("$BUILD_DIR/get-version.sh"); then
        error "Failed to determine version"
        exit 1
    fi
    
    ARCHIVE_NAME="${PACKAGE_NAME}-v${VERSION}.zip"
    
    log "Building distribution package for version v$VERSION"
    
    prepare_staging
    copy_distribution_files
    set_permissions
    create_package
    cleanup_staging
}

main() {
    echo "🏗️  Building Emoji Typing Setup Distribution"
    echo "==========================================="
    
    cd "$PROJECT_ROOT"
    
    validate_git_state
    check_dependencies
    build_distribution
    
    echo "✅ Build complete!"
    echo ""
    echo "📋 Package Contents:"
    echo "   Version: v$VERSION"
    echo "   Package: $ARCHIVE_NAME"
    echo "   Location: $DIST_DIR/"
    echo ""
    echo "🚀 Ready for distribution!"
}

main "$@"