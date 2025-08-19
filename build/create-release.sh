#!/usr/bin/env bash
# create-release.sh - Create a release with proper version management
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
    echo -e "${BLUE}[RELEASE]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Create a release with version from CHANGELOG.md"
    echo ""
    echo "Options:"
    echo "  --skip-checks     Skip git state validation"
    echo "  --dry-run         Show what would be done without executing"
    echo "  -h, --help        Show this help"
    echo ""
    echo "Process:"
    echo "  1. Validate git state (main branch, clean tree, synced)"
    echo "  2. Extract version from CHANGELOG.md"
    echo "  3. Create git tag"
    echo "  4. Build distribution package"
    echo "  5. Push tag to origin"
    echo ""
    echo "Prerequisites:"
    echo "  - Update CHANGELOG.md with new version: ## [vX.Y.Z] - YYYY-MM-DD"
    echo "  - Commit all changes"
    echo "  - Be on main branch"
}

# Parse arguments
SKIP_CHECKS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-checks)
            SKIP_CHECKS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
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

cd "$PROJECT_ROOT"

# Get version
log "Extracting version from CHANGELOG.md..."
if ! VERSION=$("$PROJECT_ROOT/build/get-version.sh"); then
    error "Failed to extract version from CHANGELOG.md"
    exit 1
fi

log "Version: $VERSION"

# Validate git state unless skipping
if [[ "$SKIP_CHECKS" == false ]]; then
    log "Validating git state..."
    
    if ! "$PROJECT_ROOT/build/get-version.sh" --check-git >/dev/null; then
        error "Git state validation failed"
        exit 1
    fi
    
    # Check if we're synced with origin
    log "Checking sync with origin/main..."
    git fetch origin
    
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse origin/main 2>/dev/null || echo "")
    
    if [[ -n "$remote_commit" && "$local_commit" != "$remote_commit" ]]; then
        error "Local main is not synced with origin/main"
        error "Please pull latest changes: git pull origin main"
        exit 1
    fi
    
    success "Git state is valid"
fi

# Check if tag already exists
TAG_NAME="v$VERSION"
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    error "Tag $TAG_NAME already exists"
    error "Please update CHANGELOG.md with a new version"
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "🔍 DRY RUN - Would execute:"
    echo "  1. Create tag: $TAG_NAME"
    echo "  2. Build distribution package"
    echo "  3. Push tag to origin"
    echo ""
    echo "To execute for real, run without --dry-run"
    exit 0
fi

# Create tag
log "Creating tag: $TAG_NAME"
git tag -a "$TAG_NAME" -m "Release $TAG_NAME"

# Build distribution
log "Building distribution package..."
if ! "$PROJECT_ROOT/build/build-dist.sh"; then
    error "Failed to build distribution package"
    error "Removing created tag..."
    git tag -d "$TAG_NAME"
    exit 1
fi

# Push tag
log "Pushing tag to origin..."
if ! git push origin "$TAG_NAME"; then
    error "Failed to push tag to origin"
    error "Tag created locally but not pushed"
    exit 1
fi

# Show success message
echo ""
success "Release $TAG_NAME created successfully!"
echo ""
echo "📋 Summary:"
echo "✅ Tag created: $TAG_NAME"
echo "✅ Distribution built: dist/emoji-typing-setup-v$VERSION.zip"
echo "✅ Tag pushed to origin"
echo ""
echo "🚀 Next steps:"
echo "  - Create GitHub release:"
echo "    gh release create $TAG_NAME \\"
echo "      --title \"$TAG_NAME\" \\"
echo "      --notes \"Release $TAG_NAME\" \\"
echo "      dist/emoji-typing-setup-v$VERSION.zip"