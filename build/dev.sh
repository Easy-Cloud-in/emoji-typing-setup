#!/usr/bin/env bash
# dev.sh - Simple development helper script
# Developed by: Easy-cloud (www.easy-cloud.in)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

show_help() {
    echo "Development Helper Script"
    echo "========================"
    echo ""
    echo "Usage: ./build/dev.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build     - Create distribution package"
    echo "  test      - Run validation tests"
    echo "  lint      - Check code quality (if shellcheck available)"
    echo "  clean     - Clean temporary files"
    echo "  version   - Show current version"
    echo "  release   - Create a new release"
    echo "  help      - Show this help"
    echo ""
    echo "Options:"
    echo "  --skip-checks    Skip git state validation (for build/release)"
    echo ""
    echo "Examples:"
    echo "  ./build/dev.sh build"
    echo "  ./build/dev.sh build --skip-checks"
    echo "  ./build/dev.sh version"
    echo "  ./build/dev.sh release --skip-checks"
}

build_dist() {
    echo "🏗️  Building distribution..."
    
    # Check git state before building (unless --skip-checks is passed)
    if [[ "${SKIP_GIT_CHECKS:-false}" != "true" ]]; then
        if ! "$PROJECT_ROOT/build/get-version.sh" --check-git >/dev/null; then
            echo "❌ Build failed: Git state validation failed"
            echo "   Make sure you're on main branch with clean working tree (CHANGELOG.md changes allowed)"
            echo "   Or use: ./build/dev.sh build --skip-checks"
            return 1
        fi
    else
        echo "⚠️  Skipping git state validation as requested"
    fi
    
    "$PROJECT_ROOT/build/build-dist.sh"
}

run_tests() {
    echo "🧪 Running tests..."
    if [[ -f "$PROJECT_ROOT/src/validate-installation.sh" ]]; then
        "$PROJECT_ROOT/src/validate-installation.sh"
    else
        echo "No validation script found"
    fi
}

lint_code() {
    echo "🔍 Checking code quality..."
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck "$PROJECT_ROOT"/src/*.sh "$PROJECT_ROOT"/build/*.sh
        echo "✅ Code quality checks passed"
    else
        echo "⚠️  shellcheck not available (install with: sudo apt install shellcheck)"
    fi
}

clean_temp() {
    echo "🧹 Cleaning temporary files..."
    rm -f /tmp/emoji-typing-setup.log
    rm -f /tmp/emoji-typing-setup.lock
    rm -rf /tmp/emoji-typing-setup-*
    rm -rf "$PROJECT_ROOT/dist"
    echo "✅ Cleanup completed"
}

show_version() {
    echo "📋 Version Information"
    echo "====================="
    echo ""
    if version=$("$PROJECT_ROOT/build/get-version.sh" --verbose 2>&1); then
        echo "Current version: $(echo "$version" | tail -1)"
    else
        echo "❌ Could not determine version"
    fi
    echo ""
}

create_release() {
    echo "🚀 Creating release..."
    "$PROJECT_ROOT/build/create-release.sh" "$@"
}

# Parse arguments
SKIP_GIT_CHECKS=false
COMMAND=""

# First pass: extract command and options
for arg in "$@"; do
    case $arg in
        --skip-checks)
            SKIP_GIT_CHECKS=true
            ;;
        build|test|lint|clean|version|release|help)
            if [[ -z "$COMMAND" ]]; then
                COMMAND="$arg"
            fi
            ;;
    esac
done

# If no command found, use first argument or default to help
if [[ -z "$COMMAND" ]]; then
    COMMAND="${1:-help}"
fi

case "$COMMAND" in
    build)
        build_dist
        ;;
    test)
        run_tests
        ;;
    lint)
        lint_code
        ;;
    clean)
        clean_temp
        ;;
    version)
        show_version
        ;;
    release)
        # Build first (includes git state validation), then create release
        build_dist
        
        # Pass remaining args to create_release, filtering out --skip-checks
        release_args=()
        for arg in "$@"; do
            if [[ "$arg" != "--skip-checks" && "$arg" != "release" ]]; then
                release_args+=("$arg")
            fi
        done
        if [[ "$SKIP_GIT_CHECKS" == "true" ]]; then
            release_args+=("--skip-checks")
        fi
        create_release "${release_args[@]}"
        ;;
    help|*)
        show_help
        ;;
esac