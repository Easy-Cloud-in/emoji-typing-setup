#!/usr/bin/env bash
# setup-build-system.sh - Bootstrap Easy-Cloud Build System Pattern
# Developed by: Easy-cloud (www.easy-cloud.in)
# Author: Sakar SR

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[SETUP]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

show_help() {
    echo "Easy-Cloud Build System Setup"
    echo "============================="
    echo ""
    echo "Usage: $0 [OPTIONS] <project-name>"
    echo ""
    echo "Options:"
    echo "  --target-dir DIR    Target directory (default: current directory)"
    echo "  --force            Overwrite existing files"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 my-new-project"
    echo "  $0 --target-dir /path/to/project my-project"
    echo "  $0 --force existing-project"
}

# Default values
TARGET_DIR="."
FORCE=false
PROJECT_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target-dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            else
                error "Multiple project names provided: $PROJECT_NAME and $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$PROJECT_NAME" ]]; then
    error "Project name is required"
    show_help
    exit 1
fi

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    error "Project name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

log "Setting up Easy-Cloud Build System for project: $PROJECT_NAME"
log "Target directory: $TARGET_DIR"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Check if build system already exists
if [[ -d "build" && "$FORCE" != "true" ]]; then
    error "Build directory already exists. Use --force to overwrite."
    exit 1
fi

# Create directory structure
log "Creating directory structure..."
mkdir -p build/templates
mkdir -p dist

# Copy build scripts (assuming this script is in the build directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Copying build system files..."

# Core build scripts
cp "$SCRIPT_DIR/dev.sh" build/
cp "$SCRIPT_DIR/get-version.sh" build/
cp "$SCRIPT_DIR/create-release.sh" build/
cp "$SCRIPT_DIR/build-dist.sh" build/
cp "$SCRIPT_DIR/BUILD_SYSTEM_PATTERN.md" build/

# Update package name in build-dist.sh
log "Configuring package name: $PROJECT_NAME"
sed -i "s/PACKAGE_NAME=\".*\"/PACKAGE_NAME=\"$PROJECT_NAME\"/" build/build-dist.sh

# Create template files
log "Creating template files..."

# Create files.list template
cat > build/templates/files.list << EOF
# Distribution Files List
# Format: source_path:destination_path
# Lines starting with # are comments

# Main scripts (update these paths for your project)
src/main-script.sh:main-script.sh

# Configuration (if applicable)
# config/settings.conf:config/settings.conf

# Documentation and legal
LICENSE:LICENSE
build/templates/README.md:README.md
EOF

# Create README template
cat > build/templates/README.md << EOF
# $PROJECT_NAME - Distribution Package

Quick setup tool for [describe your project].

**Developed by**: [Easy-cloud](https://www.easy-cloud.in) | **Author**: Sakar SR

## Quick Start

\`\`\`bash
# Extract and install
unzip $PROJECT_NAME-*.zip
cd $PROJECT_NAME-*/
chmod +x *.sh
./main-script.sh [options]
\`\`\`

## Commands

- \`./main-script.sh [command]\` - [Describe main functionality]

## Requirements

- [List system requirements]
- [List dependencies]

## Support

For issues or questions, visit: [www.easy-cloud.in](https://www.easy-cloud.in)

## Version

This package was built automatically from the $PROJECT_NAME project.
EOF

# Create initial CHANGELOG.md
if [[ ! -f "CHANGELOG.md" || "$FORCE" == "true" ]]; then
    log "Creating initial CHANGELOG.md..."
    cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

## [v1.0.0] - $(date +%Y-%m-%d)

- feat: Initial release
EOF
fi

# Create build README
log "Creating build documentation..."
cat > build/README.md << EOF
# Build & Distribution - $PROJECT_NAME

This directory contains all build-related scripts and tools for the $PROJECT_NAME project.

## Quick Start

\`\`\`bash
# Show current version
./build/dev.sh version

# Build distribution package
./build/dev.sh build

# Create complete release
./build/dev.sh release
\`\`\`

## Customization

1. **Edit files to include**: \`build/templates/files.list\`
2. **Edit distribution README**: \`build/templates/README.md\`
3. **Update version**: Edit \`CHANGELOG.md\` with new version

## Pattern Documentation

See \`build/BUILD_SYSTEM_PATTERN.md\` for complete documentation of the Easy-Cloud Build System Pattern.

---

**Generated by**: Easy-Cloud Build System Setup  
**Date**: $(date +%Y-%m-%d)
EOF

# Make scripts executable
log "Setting permissions..."
chmod +x build/*.sh

# Create .gitignore entries
if [[ -f ".gitignore" ]]; then
    if ! grep -q "build/staging" .gitignore; then
        echo "" >> .gitignore
        echo "# Build system" >> .gitignore
        echo "build/staging/" >> .gitignore
        echo "dist/" >> .gitignore
    fi
else
    log "Creating .gitignore..."
    cat > .gitignore << EOF
# Build system
build/staging/
dist/

# Common ignores
*.log
*.tmp
.DS_Store
EOF
fi

# Test the setup
log "Testing build system setup..."
if ./build/dev.sh version >/dev/null 2>&1; then
    success "Build system test passed!"
else
    warn "Build system test failed - you may need to customize the setup"
fi

echo ""
success "Easy-Cloud Build System setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Update build/templates/files.list with your project files"
echo "2. Customize build/templates/README.md for your project"
echo "3. Create your main project files"
echo "4. Test with: ./build/dev.sh build --skip-checks"
echo ""
echo "📖 Documentation:"
echo "- Build system: build/README.md"
echo "- Pattern reference: build/BUILD_SYSTEM_PATTERN.md"
echo ""
echo "🚀 Ready to build!"