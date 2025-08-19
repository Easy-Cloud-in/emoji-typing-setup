# Release Checklist

## Creating a New Distribution Release

### Pre-Release Steps

1. **Update Version Numbers**

   - [ ] Update `SCRIPT_VERSION` in `config/settings.conf`
   - [ ] Update version in `build-minimal-dist.sh` (PACKAGE_NAME and VERSION variables)
   - [ ] Update version references in documentation

2. **Test the Main Script**

   - [ ] Test installation: `./emoji-typing-setup.sh install`
   - [ ] Test status: `./emoji-typing-setup.sh status`
   - [ ] Test enable/disable: `./emoji-typing-setup.sh enable/disable`
   - [ ] Test removal: `./remove-emoji-support.sh`

3. **Build and Test Distribution Package**
   - [ ] Run: `./build-minimal-dist.sh`
   - [ ] Extract and test the generated zip:
     ```bash
     cd dist/
     unzip emoji-typing-minimal-*.zip
     cd emoji-typing-minimal-*/
     ./emoji-typing-setup.sh status
     ```

### Release Steps

4. **Create GitHub Release**

   - [ ] Create new tag: `git tag v2.1.0`
   - [ ] Push tag: `git push origin v2.1.0`
   - [ ] Create GitHub release with tag
   - [ ] Upload `dist/emoji-typing-minimal-*.zip` as release asset
   - [ ] Write release notes

5. **Update Documentation**
   - [ ] Update download links in README.md if needed
   - [ ] Verify installation instructions are current
   - [ ] Update any version-specific references

### Post-Release Verification

6. **Test End-User Experience**

   - [ ] Download the zip from GitHub releases
   - [ ] Follow the installation guide exactly as written
   - [ ] Verify emoji typing works with Ctrl+; or Super+;

7. **Update Distribution Links**
   - [ ] Update any external documentation
   - [ ] Notify users of new release if needed

## Version Numbering

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes or major feature additions
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, small improvements

## File Checklist

Essential files that must be in every distribution:

- [ ] `emoji-typing-setup.sh` - Main script
- [ ] `remove-emoji-support.sh` - Removal script
- [ ] `config/settings.conf` - Configuration
- [ ] `README.md` - User guide (simplified)
- [ ] `LICENSE` - MIT license

## Testing Environments

Test on these environments when possible:

- [ ] Ubuntu 20.04+ with GNOME
- [ ] Ubuntu 22.04+ with GNOME
- [ ] Pop!\_OS with GNOME
- [ ] Other GNOME-based distributions

---

**Developed by**: [Easy-cloud](https://www.easy-cloud.in) | **Author**: Sakar SR
