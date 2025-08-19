# Build & Distribution

**📚 Navigation:** [🏠 Main README](../README.md) | [📖 Documentation](../docs/README.md)

---

This directory contains all build-related scripts and tools for the emoji-typing-setup project.

## 📋 Pattern Documentation

- **Quick Reference**: [PATTERN_SUMMARY.md](PATTERN_SUMMARY.md) - When you say "use Easy-Cloud pattern"
- **Full Documentation**: [BUILD_SYSTEM_PATTERN.md](BUILD_SYSTEM_PATTERN.md) - Complete pattern specification
- **Setup Script**: [setup-build-system.sh](setup-build-system.sh) - Bootstrap new projects

## Scripts

### `dev.sh` - Development Helper

Main development workflow script.

```bash
# Show current version
./build/dev.sh version

# Build distribution package
./build/dev.sh build

# Create complete release
./build/dev.sh release

# Run tests
./build/dev.sh test

# Check code quality
./build/dev.sh lint

# Clean temporary files
./build/dev.sh clean
```

### `get-version.sh` - Version Management

Core version extraction and validation.

```bash
# Get version only
./build/get-version.sh

# Get version with source info
./build/get-version.sh --verbose

# Validate git state (main branch, clean tree)
./build/get-version.sh --check-git
```

### `create-release.sh` - Release Workflow

Complete release creation process with version/tag management.

```bash
# Create release (git validation handled by build-dist.sh)
./build/create-release.sh

# Skip git validation
./build/create-release.sh --skip-checks

# See what would happen
./build/create-release.sh --dry-run
```

### `build-dist.sh` - Package Builder

Performs git validation and creates the distribution zip file.

```bash
# Build distribution package (includes git validation)
./build/build-dist.sh

# Skip git validation for development
./build/build-dist.sh --skip-checks
```

## Directory Structure

```
build/
├── README.md              # This file
├── dev.sh                 # Main development helper
├── get-version.sh         # Version extraction
├── create-release.sh      # Release workflow
├── build-dist.sh          # Package builder
├── templates/             # Distribution templates (always fresh)
│   ├── README.md          # Distribution README template
│   └── files.list         # Files to include in package
└── staging/               # Temporary staging area (auto-cleaned)

../dist/                   # Output directory (clean - only zip files)
└── emoji-typing-setup-*.zip
```

## Workflow

### Development

```bash
# Check version
./build/dev.sh version

# Build and test
./build/dev.sh build
```

### Release

```bash
# Complete release workflow
./build/dev.sh release
```

This creates:

- Git tag (e.g., `v1.0.0`)
- Distribution package (`dist/emoji-typing-setup-v1.0.0.zip`)
- Pushes tag to origin

## Version Management

Version is automatically determined from:

1. **CHANGELOG.md** (primary) - Format: `## [vX.Y.Z] - YYYY-MM-DD`
2. **Git tags** (fallback) - Format: `vX.Y.Z`
3. **Default** (first push) - Uses `1.0.0`

## Build Process

### How It Works

1. **Clean Staging**: `build/staging/` is always recreated fresh
2. **Copy Files**: Based on `build/templates/files.list` specification
3. **Set Permissions**: Make scripts executable, configs readable
4. **Create Package**: Zip from staging area to `dist/`
5. **Cleanup**: Remove staging area (keeps build clean)

### Customizing Distribution

Edit `build/templates/files.list` to control what goes in the package:

```
# Format: source_path:destination_path
src/emoji-typing-setup.sh:emoji-typing-setup.sh
config/settings.conf:config/settings.conf
LICENSE:LICENSE
```

Edit `build/templates/README.md` to customize the distribution README.

## Git State Requirements

Git validation is performed by `build-dist.sh` (single validation point):

- ✅ Must be on `main` branch
- ✅ Working tree must be clean (**CHANGELOG.md changes are allowed**)
- ✅ Must be synced with `origin/main`

### Skip Validation

For development/testing, you can skip git validation:

```bash
# Skip git checks for build
./build/dev.sh build --skip-checks

# Skip git checks for release
./build/dev.sh release --skip-checks
```

**Note**: The `--skip-checks` flag is passed through to `build-dist.sh` which handles all validation.

## Requirements

- Git repository with proper setup
- `zip` command available
- Bash shell environment
- Clean working tree on main branch (CHANGELOG.md changes allowed)
