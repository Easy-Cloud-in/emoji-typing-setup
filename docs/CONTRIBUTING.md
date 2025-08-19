# Contributing to Emoji Typing Setup

We welcome contributions to the Emoji Typing Setup project! This document provides guidelines for contributing to help ensure a smooth collaboration process.

**Developed by**: [Easy-cloud](https://www.easy-cloud.in)  
**Author**: Sakar SR  
**License**: MIT License  

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

- Linux system (Ubuntu/Debian preferred for testing)
- Bash 4.0 or later
- Git
- Basic knowledge of shell scripting
- Understanding of Linux input methods and desktop environments

### Development Dependencies

```bash
# Install development dependencies
sudo apt update
sudo apt install -y \
    shellcheck \
    bats \
    ibus \
    ibus-typing-booster \
    libglib2.0-bin

# For documentation
sudo apt install -y pandoc
```

## Development Setup

1. **Fork and Clone**
   ```bash
   # Fork the repository on GitHub first
   git clone https://github.com/easy-cloud-dev/emoji-typing-setup.git
   cd emoji-typing-setup
   ```

2. **Set up development environment**
   ```bash
   # Make scripts executable
   chmod +x emoji-typing-setup.sh
   
   # Create a development branch
   git checkout -b feature/your-feature-name
   ```

3. **Verify setup**
   ```bash
   # Run basic tests
   ./emoji-typing-setup.sh --help
   ./emoji-typing-setup.sh status
   ```

## Contributing Guidelines

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**: Fix existing issues
- **Features**: Add new functionality
- **Documentation**: Improve or add documentation
- **Testing**: Add or improve tests
- **Desktop environment support**: Add support for new desktop environments
- **Translations**: Localization support (future)

### Before You Start

1. **Check existing issues**: Look for existing issues or discussions
2. **Open an issue**: For new features, open an issue to discuss first
3. **Small changes first**: Start with small, focused changes
4. **One feature per PR**: Keep pull requests focused on a single feature or fix

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Make your changes**
   - Follow coding standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test thoroughly**
   ```bash
   # Run linting
   shellcheck emoji-typing-setup.sh
   
   # Run tests
   bats tests/test_main.bats
   
   # Test on different environments
   ./test-on-multiple-environments.sh
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add support for KDE desktop environment"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/descriptive-name
   # Create pull request on GitHub
   ```

## Code Style

### Shell Script Standards

We follow these shell scripting best practices:

1. **Use bash shebang**:
   ```bash
   #!/usr/bin/env bash
   ```

2. **Enable strict mode**:
   ```bash
   set -euo pipefail
   ```

3. **Use proper quoting**:
   ```bash
   # Good
   local file_path="$1"
   [[ -f "$file_path" ]]
   
   # Avoid
   local file_path=$1
   [[ -f $file_path ]]
   ```

4. **Function naming**:
   ```bash
   # Use descriptive names with underscores
   check_package_installed() {
       # Function body
   }
   ```

5. **Variable naming**:
   ```bash
   # Constants in UPPER_CASE
   readonly DEFAULT_CONFIG_FILE="/path/to/config"
   
   # Local variables in lower_case
   local current_desktop="$XDG_CURRENT_DESKTOP"
   ```

6. **Error handling**:
   ```bash
   # Check command success
   if ! command -v gsettings >/dev/null 2>&1; then
       log "ERROR" "gsettings not found"
       return 1
   fi
   
   # Use || for error handling
   gsettings set key value || {
       log "ERROR" "Failed to set gsettings"
       return 1
   }
   ```

### Code Organization

1. **File structure**:
   ```bash
   # Script header
   #!/usr/bin/env bash
   # Description and metadata
   
   # Global configuration
   set -euo pipefail
   
   # Constants
   readonly SCRIPT_NAME="$(basename "$0")"
   
   # Global variables
   VERBOSE=false
   
   # Helper functions
   log() { ... }
   
   # Main functions
   install_packages() { ... }
   
   # Main execution
   main "$@"
   ```

2. **Function order**:
   - Helper functions first
   - Main functionality functions
   - Command handlers
   - Main function last

3. **Comments and documentation**:
   ```bash
   # Function documentation
   # Usage: check_package_installed <package_name>
   # Returns: 0 if installed, 1 if not installed
   check_package_installed() {
       local package="$1"
       dpkg -l "$package" 2>/dev/null | grep -q "^ii"
   }
   ```

### Linting

Use shellcheck to verify code quality:

```bash
# Install shellcheck
sudo apt install shellcheck

# Check the main script
shellcheck emoji-typing-setup.sh

# Check with specific shell
shellcheck -s bash emoji-typing-setup.sh

# Ignore specific warnings (use sparingly)
# shellcheck disable=SC2034
unused_variable="value"
```

## Testing

### Test Requirements

- All new functionality must include tests
- Tests should cover both success and failure cases
- Tests must not require root privileges
- Tests should work in isolated environments

### Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test_main.bats

# Run with verbose output
bats --verbose tests/test_main.bats

# Run single test
bats tests/test_main.bats --filter "status command"
```

### Writing Tests

Use the BATS testing framework:

```bash
#!/usr/bin/env bats

@test "function returns correct value" {
    # Setup
    local expected="expected_output"
    
    # Execute
    run your_function "input"
    
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "$expected" ]
}

@test "function handles error gracefully" {
    # Test error conditions
    run your_function "invalid_input"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error message"* ]]
}
```

### Test Mocking

For system dependencies, use mock functions:

```bash
# Mock gsettings for testing
mock_gsettings() {
    cat > "$TEST_DIR/gsettings" << 'EOF'
#!/bin/bash
echo "[('xkb', 'us')]"
EOF
    chmod +x "$TEST_DIR/gsettings"
    export PATH="$TEST_DIR:$PATH"
}
```

## Submitting Changes

### Pull Request Process

1. **Ensure CI passes**: All tests and linting must pass
2. **Update documentation**: Include documentation updates
3. **Add tests**: Include tests for new functionality
4. **Write clear commit messages**: Use conventional commit format
5. **Keep PRs focused**: One feature or fix per PR

### Commit Message Format

Use conventional commit messages:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

Examples:
```
feat(kde): add support for KDE Plasma desktop environment

Add detection and configuration support for KDE Plasma,
including Qt input method integration.

Closes #42
```

```
fix(backup): handle corrupted backup files gracefully

Previously, corrupted backup files would cause the restore
command to fail. Now we validate backup files and provide
clear error messages.

Fixes #38
```

### PR Requirements

- [ ] Tests pass
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Changes are backward compatible
- [ ] Commit messages follow convention
- [ ] PR description explains the changes

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Other: ___________

## Testing
- [ ] Added tests for new functionality
- [ ] All tests pass locally
- [ ] Tested on multiple desktop environments

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Changes are backward compatible
```

## Reporting Issues

### Bug Reports

Use the issue template:

```markdown
**Describe the bug**
Clear description of the problem

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. See error

**Expected behavior**
What you expected to happen

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Desktop Environment: [e.g., GNOME 42]
- Script Version: [e.g., 2.0.0]

**Additional context**
- Output of `./emoji-typing-setup.sh status`
- Log file contents
- Any additional information
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired functionality

**Describe alternatives considered**
Any alternative solutions or features

**Additional context**
Screenshots, mockups, or examples
```

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment:

- **Be respectful**: Treat all participants with respect
- **Be inclusive**: Welcome newcomers and diverse perspectives  
- **Be collaborative**: Work together constructively
- **Be patient**: Help others learn and grow
- **Be professional**: Keep discussions focused and productive

### Communication

- **GitHub Issues**: For bugs, features, and discussions
- **Pull Requests**: For code review and collaboration
- **Discussions**: For general questions and community interaction

### Getting Help

- Check existing documentation first
- Search existing issues before creating new ones
- Provide detailed information when asking questions
- Be patient - maintainers are volunteers

## Development Resources

### Easy-cloud Resources

- **Website**: [www.easy-cloud.in](https://www.easy-cloud.in)
- **Project Repository**: [GitHub - Easy-cloud/emoji-typing-setup](https://github.com/easy-cloud-dev/emoji-typing-setup)
- **Support**: Contact through Easy-cloud website

### Technical References

- [Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
- [BATS Testing Framework](https://bats-core.readthedocs.io/)
- [ShellCheck Documentation](https://www.shellcheck.net/)
- [IBus Documentation](https://github.com/ibus/ibus/wiki)
- [GNOME Input Sources](https://help.gnome.org/users/gnome-help/stable/keyboard-inputmethods.html)

### Learning Resources

- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Linux Input Method Framework](https://en.wikipedia.org/wiki/Input_method)
- [Desktop Environment Standards](https://specifications.freedesktop.org/)

## Release Process

### Versioning

We follow Semantic Versioning (SemVer):
- MAJOR: Incompatible API changes
- MINOR: New functionality (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Version number is updated
- [ ] Changelog is updated
- [ ] Release notes are prepared

## Acknowledgments

This project is developed and maintained by **Easy-cloud** (www.easy-cloud.in) under the leadership of **Sakar SR**. We appreciate all community contributions that help make Linux emoji typing accessible to everyone.

### Contact Information

- **Developer**: Easy-cloud (www.easy-cloud.in)
- **Author**: Sakar SR
- **License**: MIT License
- **Support**: Visit our website for technical support and inquiries

---

Thank you for contributing to Emoji Typing Setup! Your contributions help make Linux emoji typing accessible to everyone.

**Easy-cloud** - Simplifying cloud and system management solutions.