# Easy-Cloud Build System - Quick Reference

**When you say**: _"Use the Easy-Cloud build system pattern"_

## What to Implement:

### 1. Directory Structure

```
build/
├── dev.sh                 # Main development helper
├── get-version.sh         # Version extraction (CHANGELOG.md → git tags → 1.0.0)
├── create-release.sh      # Complete release workflow
├── build-dist.sh          # Distribution package builder
├── templates/
│   ├── files.list         # What files to include
│   └── README.md          # Distribution README template
└── staging/               # Temporary (auto-cleaned)

dist/                      # Clean - only zip files
└── project-name-vX.Y.Z.zip

CHANGELOG.md               # Version source
```

### 2. Key Behaviors

**Version Management:**

- Primary: CHANGELOG.md format `## [vX.Y.Z] - YYYY-MM-DD`
- Fallback: Git tags `vX.Y.Z`
- Default: `1.0.0` for first push

**Git State Validation:**

- ✅ Must be on main branch
- ✅ Working tree clean
- ✅ **EXCEPTION**: CHANGELOG.md changes ALWAYS allowed
- ✅ Synced with origin/main (for releases)

**Build Process:**

- Always fresh staging area
- Template-driven file copying
- Clean dist directory (only zips)
- Proper permissions

### 3. Commands

```bash
./build/dev.sh version              # Show version
./build/dev.sh build                # Build package
./build/dev.sh release              # Complete release
./build/dev.sh build --skip-checks  # Skip git validation
```

### 4. Workflow

```bash
# 1. Update CHANGELOG.md
## [v1.2.3] - 2025-08-18

# 2. Build/release (CHANGELOG.md changes allowed!)
./build/dev.sh release

# Creates: tag v1.2.3 + dist/project-name-v1.2.3.zip
```

### 5. Setup New Project

```bash
# Copy build system
cp -r existing-project/build/ new-project/

# Or use setup script
./build/setup-build-system.sh new-project-name

# Customize
vim build/templates/files.list      # What files to include
vim build/templates/README.md       # Distribution README
```

## Key Files to Customize:

1. **`build/build-dist.sh`**: Update `PACKAGE_NAME`
2. **`build/templates/files.list`**: Define what goes in package
3. **`build/templates/README.md`**: Distribution documentation
4. **`CHANGELOG.md`**: Version source and release notes

## Pattern Benefits:

- ✅ Single source of truth (CHANGELOG.md)
- ✅ CHANGELOG-friendly workflow
- ✅ Clean separation (build vs project)
- ✅ Template-driven packages
- ✅ Consistent across projects
- ✅ Developer-friendly commands

---

**Reference Implementation**: `emoji-typing-setup` project  
**Full Documentation**: `build/BUILD_SYSTEM_PATTERN.md`
