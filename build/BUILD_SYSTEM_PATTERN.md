# Easy-Cloud Build System Pattern

**Version**: 1.0  
**Author**: Sakar SR  
**Organization**: Easy-cloud (www.easy-cloud.in)  
**Date**: 2025-08-18

---

## Overview

This document defines the **Easy-Cloud Build System Pattern** - a standardized approach to version management, build processes, and release workflows for all Easy-cloud projects.

## Core Principles

1. **Single Source of Truth**: Version defined in CHANGELOG.md
2. **Clean Separation**: Build tools separate from project code
3. **Template-Driven**: Distribution packages built from templates
4. **Git-Aware**: Intelligent git state validation
5. **Developer-Friendly**: Simple commands, clear feedback
6. **CHANGELOG-Friendly**: Allow CHANGELOG.md changes during build/release

## Directory Structure

```
project-root/
├── build/                          # 🏗️ Build & Development Tools
│   ├── dev.sh                      # Main development helper
│   ├── get-version.sh              # Version extraction & validation
│   ├── create-release.sh           # Complete release workflow
│   ├── build-dist.sh               # Distribution package builder
│   ├── README.md                   # Build system documentation
│   ├── BUILD_SYSTEM_PATTERN.md     # This pattern file
│   ├── templates/                  # 📄 Distribution templates
│   │   ├── README.md               # Distribution README template
│   │   └── files.list              # Files to include specification
│   └── staging/                    # 🏗️ Temporary staging (auto-cleaned)
├── dist/                           # 📦 Clean - only zip files
│   └── project-name-vX.Y.Z.zip     # Generated packages
├── CHANGELOG.md                    # 📋 Version source & release notes
└── [project files...]
```

## Version Management Rules

### Version Sources (Priority Order)

1. **CHANGELOG.md** (Primary)

   - Format: `## [vX.Y.Z] - YYYY-MM-DD`
   - Example: `## [v1.2.3] - 2025-08-18`

2. **Git Tags** (Fallback)

   - Format: `vX.Y.Z`
   - Used when CHANGELOG.md has no version

3. **Default Version** (First Push)
   - Uses `1.0.0` for first push to origin/main
   - When no tags exist and no CHANGELOG.md version

### Git State Validation

**Requirements:**

- ✅ Must be on `main` branch
- ✅ Working tree must be clean
- ✅ **EXCEPTION**: CHANGELOG.md changes are ALWAYS allowed
- ✅ Must be synced with origin/main

**Validation Location**: All git state validation is performed in `build-dist.sh` to avoid duplication.

**Rationale**: Developers commonly update CHANGELOG.md and immediately run build/release. Single validation point ensures consistency.

## Build System Components

### 1. `build/dev.sh` - Development Helper

**Purpose**: Single entry point for all development tasks

**Commands**:

```bash
./build/dev.sh version              # Show current version
./build/dev.sh build                # Build distribution package
./build/dev.sh release              # Complete release workflow
./build/dev.sh test                 # Run validation tests
./build/dev.sh lint                 # Code quality checks
./build/dev.sh clean                # Clean temporary files
./build/dev.sh help                 # Show help
```

**Options**:

```bash
--skip-checks                       # Skip git state validation
```

**Examples**:

```bash
./build/dev.sh build --skip-checks  # Build without git validation
./build/dev.sh release --skip-checks # Release without git validation
```

### 2. `build/get-version.sh` - Version Management

**Purpose**: Extract version and validate git state

**Usage**:

```bash
./build/get-version.sh                    # Get version only
./build/get-version.sh --verbose          # Show version source
./build/get-version.sh --check-git        # Validate git state
```

**Behavior**:

- Reads CHANGELOG.md for version pattern
- Falls back to git tags if no CHANGELOG version
- Defaults to 1.0.0 for first push
- Validates git state (ignoring CHANGELOG.md changes)

### 3. `build/create-release.sh` - Release Workflow

**Purpose**: Complete release process with version/tag management

**Usage**:

```bash
./build/create-release.sh                 # Full release process
./build/create-release.sh --skip-checks   # Skip git validation
./build/create-release.sh --dry-run       # Show what would happen
```

**Process**:

1. Extract version from CHANGELOG.md
2. Check if tag already exists
3. Create git tag
4. Call `build-dist.sh` (which handles git validation and packaging)
5. Push tag to origin

**Note**: Git state validation is delegated to `build-dist.sh` to avoid duplication.

### 4. `build/build-dist.sh` - Package Builder

**Purpose**: Git validation and distribution package creation

**Usage**:

```bash
./build/build-dist.sh                     # Full validation and build
./build/build-dist.sh --skip-checks       # Skip git validation
```

**Process**:

1. **Git State Validation** (unless `--skip-checks`):
   - Verify on main branch
   - Check sync with origin/main
   - Ensure clean working tree (CHANGELOG.md changes allowed)
2. Clean staging area (`build/staging/`)
3. Copy files based on `build/templates/files.list`
4. Set proper permissions
5. Create zip file in `dist/`
6. Clean up staging area

**Output**: `dist/project-name-vX.Y.Z.zip`

**Note**: This is the single point for git validation to avoid duplication across scripts.

## Template System

### `build/templates/files.list`

**Purpose**: Define what files go in distribution package

**Format**:

```
# Comments start with #
source_path:destination_path
src/main-script.sh:main-script.sh
config/settings.conf:config/settings.conf
LICENSE:LICENSE
build/templates/README.md:README.md
```

### `build/templates/README.md`

**Purpose**: Distribution package README template

**Content**: User-facing installation and usage instructions

## Naming Conventions

### Package Names

- Format: `project-name-vX.Y.Z.zip`
- Example: `emoji-typing-setup-v1.2.3.zip`
- Always includes 'v' prefix in filename

### Git Tags

- Format: `vX.Y.Z`
- Example: `v1.2.3`
- Created automatically during release process

### CHANGELOG Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [v1.2.3] - 2025-08-18

- feat: Add new feature
- fix: Fix bug
- docs: Update documentation

## [v1.2.2] - 2025-08-17

- fix: Previous bug fix
```

## Workflow Patterns

### Development Workflow

```bash
# 1. Check current version
./build/dev.sh version

# 2. Build for testing
./build/dev.sh build --skip-checks

# 3. Test package
unzip dist/project-name-v*.zip
```

### Release Workflow

```bash
# 1. Update CHANGELOG.md
vim CHANGELOG.md
# Add: ## [v1.2.3] - 2025-08-18

# 2. Commit other changes (not CHANGELOG.md yet)
git add .
git commit -m "feat: Implement new feature"

# 3. Create release (CHANGELOG.md changes allowed)
./build/dev.sh release

# This will:
# - Extract version from CHANGELOG.md
# - Create tag v1.2.3
# - Call build-dist.sh which validates git state and builds package
# - Push tag to origin
```

### First Project Setup

```bash
# 1. Create directory structure
mkdir -p build/templates dist

# 2. Copy build system files
cp [pattern-files] build/

# 3. Create CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [v1.0.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "- feat: Initial release" >> CHANGELOG.md

# 4. Configure templates
vim build/templates/files.list
vim build/templates/README.md

# 5. Test build
./build/dev.sh build --skip-checks
```

## Integration with Git Hooks

**Compatible Settings**:

```bash
AUTO_VERSION_BUMP=true
VERSIONING_BRANCHES="main|master"
INITIAL_VERSION="1.0.0"
AUTO_CHANGELOG=true
CHANGELOG_FILE="CHANGELOG.md"
```

**Behavior**: Git hooks handle automatic versioning on push, build system handles manual releases.

## Error Handling

### Common Scenarios

1. **Not on main branch**:

   ```
   [ERROR] Not on main branch. Current branch: feature-xyz
   ```

2. **Uncommitted changes** (excluding CHANGELOG.md):

   ```
   [ERROR] Working tree is not clean (excluding CHANGELOG.md changes)
   [ERROR] Uncommitted files: src/script.sh
   ```

3. **CHANGELOG.md changes** (allowed):

   ```
   [VERSION] CHANGELOG.md has uncommitted changes - this is allowed
   [VERSION] Changes: M CHANGELOG.md
   ```

4. **Missing version**:
   ```
   [VERSION] First push detected, using default version: 1.0.0
   ```

## Customization Points

### Project-Specific Adaptations

1. **Package Name**: Update in `build/build-dist.sh`
2. **Files to Include**: Edit `build/templates/files.list`
3. **Distribution README**: Edit `build/templates/README.md`
4. **Additional Commands**: Add to `build/dev.sh`

### Optional Features

1. **Testing Integration**: Add test commands to `build/dev.sh`
2. **Linting**: Add shellcheck or other linters
3. **Documentation**: Add doc generation
4. **Deployment**: Add deployment commands

## Benefits

1. **Consistency**: Same pattern across all projects
2. **Reliability**: Validated git state, clean builds
3. **Simplicity**: Single command for complex workflows
4. **Flexibility**: Skip checks for development
5. **Maintainability**: Template-driven, well-documented
6. **Developer Experience**: CHANGELOG-friendly workflow

## Implementation Checklist

When implementing this pattern in a new project:

- [ ] Create `build/` directory structure
- [ ] Copy core build scripts (`dev.sh`, `get-version.sh`, etc.)
- [ ] Create `build/templates/files.list`
- [ ] Create `build/templates/README.md`
- [ ] Create initial `CHANGELOG.md`
- [ ] Update package name in `build/build-dist.sh`
- [ ] Test with `./build/dev.sh build --skip-checks`
- [ ] Test version extraction with `./build/dev.sh version`
- [ ] Document project-specific customizations

## Reference Implementation

This pattern was first implemented in the `emoji-typing-setup` project and serves as the reference implementation for all future Easy-cloud projects.

---

**Usage**: When starting a new project, reference this pattern file and implement the build system accordingly. This ensures consistency and reduces setup time across all Easy-cloud projects.
