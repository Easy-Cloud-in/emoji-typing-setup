# Version Management System

This project uses a centralized version management system that eliminates the need to manually update version numbers in multiple places.

## How It Works

### Version Sources (Priority Order)

1. **CHANGELOG.md** - Primary source

   - Format: `## [vX.Y.Z] - YYYY-MM-DD`
   - Example: `## [v1.2.3] - 2025-08-18`

2. **Git Tags** - Fallback source

   - Format: `vX.Y.Z`
   - Used when CHANGELOG.md doesn't have version info

3. **Default Version** - First push
   - Uses `1.0.0` for first push to origin/main
   - When no tags exist and no CHANGELOG.md version

### Scripts

#### `scripts/get-version.sh`

Core version extraction script.

```bash
# Get version only
./build/get-version.sh

# Get version with source info
./build/get-version.sh --verbose

# Validate git state (main branch, clean tree, ignores CHANGELOG.md)
./build/get-version.sh --check-git
```

#### `build/create-release.sh`

Complete release creation workflow.

```bash
# Create release (validates everything)
./build/create-release.sh

# Skip git validation
./build/create-release.sh --skip-checks

# See what would happen
./build/create-release.sh --dry-run
```

#### `build/dev.sh`

Development helper with version commands.

```bash
# Show current version
./build/dev.sh version

# Build (validates git state first)
./build/dev.sh build

# Create release
./build/dev.sh release
```

## Workflow

### For Development Builds

```bash
# Just build (will use current version)
./build/dev.sh build
```

### For Releases

1. **Update CHANGELOG.md**:

   ```markdown
   ## [v1.2.3] - 2025-08-18

   - feat: New feature
   - fix: Bug fix
   ```

2. **Commit changes**:

   ```bash
   git add CHANGELOG.md
   git commit -m "feat: Release v1.2.3"
   ```

3. **Create release**:
   ```bash
   ./build/dev.sh release
   ```

This will:

- Validate git state (main branch, clean, synced)
- Extract version from CHANGELOG.md
- Create git tag
- Build distribution package
- Push tag to origin

### Git State Requirements

For builds and releases, the system enforces:

- ✅ Must be on `main` branch
- ✅ Working tree must be clean (CHANGELOG.md changes are allowed)
- ✅ Must be synced with `origin/main` (for releases)

## Integration

### Build System

The build script (`build/build-dist.sh`) automatically uses the version system:

```bash
# Old way (hardcoded)
VERSION="2.1.0"

# New way (dynamic)
VERSION=$("$PROJECT_ROOT/scripts/get-version.sh")
```

### Git Hooks

Your git hooks are configured to:

- Auto-bump versions on push to main (`AUTO_VERSION_BUMP=true`)
- Use `1.0.0` as initial version (`INITIAL_VERSION="1.0.0"`)
- Update CHANGELOG.md automatically (`AUTO_CHANGELOG=true`)

## Examples

### First Release

```bash
# Update CHANGELOG.md
echo "## [v1.0.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "- feat: Initial release" >> CHANGELOG.md

# Commit and release
git add CHANGELOG.md
git commit -m "feat: Initial release v1.0.0"
./build/dev.sh release
```

### Subsequent Releases

```bash
# Update CHANGELOG.md with new version
# Commit changes
# Run release
./build/dev.sh release
```

### Quick Version Check

```bash
./build/dev.sh version
# Output: Current version: 1.2.3
```

## Benefits

- ✅ **Single Source of Truth**: Version defined in one place (CHANGELOG.md)
- ✅ **Automatic Validation**: Prevents releases from wrong branch/dirty state
- ✅ **Consistent Naming**: All packages use same version automatically (emoji-typing-setup-vX.Y.Z.zip)
- ✅ **Git Integration**: Works with tags and hooks
- ✅ **Fallback Logic**: Handles first push and missing changelog
- ✅ **Developer Friendly**: Simple commands for common tasks
