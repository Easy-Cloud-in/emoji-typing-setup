# Build & Distribution

**📚 Navigation:** [🏠 Main README](../README.md) | [📖 Documentation](../docs/README.md)

---

This directory contains all build-related scripts and tools for the emoji-typing-setup project.

## Scripts

### Main Build & Release Scripts

- `create-distribution.sh` – Creates a distribution package, performs git validation, and optionally creates a GitHub release.
- `package.sh` – Builds the local zip package for distribution.

### Development Helper (if present)

- `dev.sh` – Main development workflow script.
- `get-version.sh` – Version extraction and validation.
- `create-release.sh` – Release workflow.
- `build-dist.sh` – Package builder.

### Usage Examples

```bash
# Create distribution package
./build/create-distribution.sh

# Create package and GitHub release
./build/create-distribution.sh --create-release

# Build local zip package only
./build/package.sh
```

## create-distribution.sh Flags & Usage

The `create-distribution.sh` script supports the following flags:

- `--ignore-changelog` &nbsp;&nbsp;&nbsp; Ignore uncommitted changes in CHANGELOG.md
- `--skip-checks` &nbsp;&nbsp;&nbsp; Skip all git validation checks (uncommitted changes, branch, sync)
- `--create-release` &nbsp;&nbsp;&nbsp; Automatically create a GitHub release after packaging
- `-h`, `--help` &nbsp;&nbsp;&nbsp; Show help message

### Example Commands

```bash
# Standard distribution creation
./build/create-distribution.sh

# Allow CHANGELOG.md changes
./build/create-distribution.sh --ignore-changelog

# Skip all git validation checks
./build/create-distribution.sh --skip-checks

# Create package and GitHub release
./build/create-distribution.sh --create-release

# Show help message
./build/create-distribution.sh --help
```

## Directory Structure

```
build/
├── README.md              # This file
├── create-distribution.sh # Distribution builder & release script
├── package.sh             # Local zip package builder
├── templates/             # Distribution templates (always fresh)
│   ├── README.md          # Distribution README template
│   ├── files.list         # Files to include in package
│   ├── install.sh         # Installer script for distribution
│   └── uninstall.sh       # Uninstaller script for distribution
└── staging/               # Temporary staging area (auto-cleaned)

../dist/                   # Output directory (clean - only zip files)
└── emoji-typing-setup-v*.zip
```

## Workflow

### Development

```bash
# Build and test
./build/package.sh
```

### Release

```bash
# Complete release workflow
./build/create-distribution.sh --create-release
```

This creates:

- Git tag (e.g., `v1.0.0`)
- Distribution package (`dist/emoji-typing-setup-v1.0.0.zip`)
- Pushes tag to origin and creates GitHub release (if requested)

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
build/templates/install.sh:install.sh
build/templates/uninstall.sh:uninstall.sh
```

Edit `build/templates/README.md` to customize the distribution README.

## Git State Requirements

Git validation is performed by `create-distribution.sh` (single validation point):

- ✅ Must be on `main` branch
- ✅ Working tree must be clean (**CHANGELOG.md changes are allowed**)
- ✅ Must be synced with `origin/main`

### Skip Validation

For development/testing, you can skip git validation:

```bash
# Skip git checks for build
./build/create-distribution.sh --skip-checks
```

**Note**: The `--skip-checks` flag disables git validation.

## Requirements

- Git repository with proper setup
- `zip` command available
- Bash shell environment
- Clean working tree on main branch (CHANGELOG.md changes allowed)

## Troubleshooting

- **Git errors:** Ensure you are on the `main` branch and your working tree is clean.
- **Missing zip:** Make sure the `zip` command is installed.
- **Permission issues:** Scripts set executable permissions automatically, but you may need to run `chmod +x *.sh` in some environments.

---