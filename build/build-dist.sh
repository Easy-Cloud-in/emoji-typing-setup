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

# Get version dynamically
if ! VERSION=$("$BUILD_DIR/get-version.sh"); then
    error "Failed to determine version"
    exit 1
fi

ARCHIVE_NAME="${PACKAGE_NAME}-v${VERSION}.zip"

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