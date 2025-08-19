# Project Structure

```
emoji-typing-setup/
├── README.md                    # Main project documentation
├── LICENSE                      # MIT License
├── PROJECT_STRUCTURE.md         # This file
├──
├── src/                         # Source code
│   ├── emoji-typing-setup.sh    # Main installation script
│   ├── remove-emoji-support.sh  # Removal script
│   └── validate-installation.sh # Validation script
├──
├── config/                      # Configuration files
│   └── settings.conf            # Core configuration settings
├──
├── build/                       # Build & Development Tools
│   ├── build-dist.sh            # Distribution package builder
│   ├── dev.sh                   # Development helper script
│   ├── get-version.sh           # Version extraction script
│   ├── create-release.sh        # Release workflow script
│   ├── README.md                # Build documentation
│   ├── templates/               # Distribution templates (always fresh)
│   │   ├── README.md            # Distribution README template
│   │   └── files.list           # Files to include specification
│   └── staging/                 # Temporary staging area (auto-cleaned)
├──
├── scripts/                     # Project-specific scripts
│   ├── performance-monitor.sh   # Performance monitoring
│   └── setup-user-config.sh     # User configuration setup
├──
├── dist/                        # Distribution packages (generated)
│   └── emoji-typing-setup-*.zip # Clean - only zip files
├──
├── docs/                        # Documentation
│   ├── INSTALLATION_GUIDE.md    # User installation guide
│   ├── DISTRIBUTION_STRATEGY.md # Distribution approach
│   ├── RELEASE_CHECKLIST.md     # Release process
│   └── CONTRIBUTING.md          # Contributing guidelines
├──
├── tests/                       # Test files (if any)
├──
├── dist/                        # Generated distribution packages
│   └── emoji-typing-minimal-*.zip
└──
└── .github/                     # GitHub workflows and templates
```

## Key Principles

1. **Simple Structure**: No unnecessary build tools like Makefiles
2. **Clear Separation**: Source, docs, build tools, and output are separated
3. **User-Friendly**: End users only interact with the distributed zip file
4. **Developer-Friendly**: Clear development workflow with helper scripts

## For End Users

Download `emoji-typing-minimal-*.zip` from releases and run:

```bash
unzip emoji-typing-minimal-*.zip
cd emoji-typing-minimal-*/
./emoji-typing-setup.sh install
```

## For Developers

```bash
# Build distribution
./scripts/dev.sh build

# Run tests
./scripts/dev.sh test

# Check code quality
./scripts/dev.sh lint

# Clean temporary files
./scripts/dev.sh clean
```
