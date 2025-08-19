# Development Guide

## Quick Start

```bash
# Clone the repository
git clone https://github.com/easy-cloud-dev/emoji-typing-setup.git
cd emoji-typing-setup

# Make scripts executable
chmod +x scripts/dev.sh
chmod +x build/build-dist.sh
```

## Development Workflow

### Building Distribution

```bash
# Create distribution package
./scripts/dev.sh build

# Output: dist/emoji-typing-minimal-2.1.0.zip
```

### Testing

```bash
# Run validation tests
./scripts/dev.sh test

# Test the main script directly
./src/emoji-typing-setup.sh status
```

### Code Quality

```bash
# Check code quality (requires shellcheck)
./scripts/dev.sh lint

# Install shellcheck if needed
sudo apt install shellcheck
```

### Cleanup

```bash
# Clean temporary files
./scripts/dev.sh clean
```

## Project Structure

- `src/` - Main source code
- `config/` - Configuration files
- `build/` - Build scripts
- `scripts/` - Development helpers
- `docs/` - Documentation
- `dist/` - Generated packages (not in git)

## Release Process

1. Update version in `build/build-dist.sh`
2. Run `./scripts/dev.sh build`
3. Test the generated package
4. Create GitHub release with the zip file

## No Makefile Needed

This project intentionally avoids Makefiles because:

- It's a simple shell script project
- End users don't need build tools
- Keeps dependencies minimal
- Reduces complexity

The `./scripts/dev.sh` script provides all necessary development commands in a simple, clear way.
