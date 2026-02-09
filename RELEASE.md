# Release Process

This document outlines the process for releasing new versions of the Elixir Claude Optimization plugin.

## Semantic Versioning

We follow [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** (x.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.x.0): New features, backward-compatible
- **PATCH** (0.0.x): Bug fixes, backward-compatible

## Current Version

**1.0.0** (Initial Release - v1.0)

See [ROADMAP.md](ROADMAP.md) for planned versions.

## Release Checklist

Before pushing any release to git, ensure ALL of the following are completed:

### 1. Update Version Numbers

Update the version in **THREE** places:

- [ ] `VERSION` file
- [ ] `.claude-plugin/plugin.json` (in the `version` field)
- [ ] `README.md` (in the version badge/header)

**Example for v1.1.0:**

```bash
# Update VERSION file
echo "1.1.0" > VERSION

# Update plugin.json (or edit manually)
sed -i.bak 's/"version": "[^"]*"/"version": "1.1.0"/' .claude-plugin/plugin.json

# Update README.md (update the version badge section)
# Edit manually to change version number
```

### 2. Update README.md

- [ ] Update version badge/number in header
- [ ] Update "What's Included" section if new skills/hooks added
- [ ] Add new skills to the skills list with descriptions
- [ ] Update hook counts if hooks were added/removed
- [ ] Update installation instructions if process changed
- [ ] Add new sections for major features

### 3. Update CHANGELOG.md

- [ ] Add new version section with release date
- [ ] List all changes under appropriate categories:
  - **Added**: New features/skills/hooks
  - **Changed**: Changes to existing functionality
  - **Deprecated**: Features that will be removed
  - **Removed**: Features that were removed
  - **Fixed**: Bug fixes
  - **Security**: Security fixes

### 4. Update Documentation

- [ ] Update skill documentation if patterns changed
- [ ] Update hook documentation if new hooks added
- [ ] Update agent documentation if guides changed
- [ ] Update INSTALL-HOOKS.md if hook installation changed

### 5. Test the Release

- [ ] Install plugin locally using `install.sh`
- [ ] Test all skills are loaded correctly
- [ ] Test all hooks are working
- [ ] Verify agent documentation is accessible
- [ ] Test in a sample Elixir project

### 6. Git Commit and Tag

```bash
# Stage all version-related files
git add VERSION .claude-plugin/plugin.json README.md CHANGELOG.md

# Additional files based on what changed
git add skills/ hooks-settings.json agents/ ROADMAP.md

# Commit with version number
git commit -m "Release v1.1.0: Skill discoverability improvements

- Updated skill descriptions with INVOKE BEFORE language
- Added file pattern detection metadata
- Created skill-discovery meta-skill
- Updated README with v1.1.0 information"

# Create annotated tag
git tag -a v1.1.0 -m "Release v1.1.0

Quick Wins: Skill Discoverability Improvements

Changes:
- Updated all skill descriptions with mandatory INVOKE BEFORE language
- Added file pattern detection metadata to all skills
- Created skill-discovery meta-skill for automatic skill detection
- Improved skill adoption through forcing functions

See CHANGELOG.md for full details."

# Push commits and tags
git push origin main
git push origin v1.1.0
```

### 7. Create GitHub Release

- [ ] Go to GitHub Releases page
- [ ] Create new release from tag
- [ ] Use tag version (e.g., v1.1.0) as release title
- [ ] Copy relevant CHANGELOG.md section as release notes
- [ ] Mark as pre-release if beta
- [ ] Publish release

### 8. Update Plugin Marketplace (if applicable)

- [ ] Update plugin listing with new version
- [ ] Update plugin description if changed
- [ ] Submit to marketplace (if required)

## Version Release Schedule (Planned)

Based on [ROADMAP.md](ROADMAP.md):

| Version | Name | Target | Effort | Status |
|---------|------|--------|--------|--------|
| v1.0.0 | Initial Release | ✅ Released | - | Complete |
| v1.1.0 | Quick Wins: Skill Discoverability | Week 1 | 8h | Planned |
| v1.2.0 | High-Impact Skills | Week 3 | 12h | Planned |
| v2.0.0 | Automation: Code Quality Detection | Week 7 | 60h | Planned |
| v2.1.0 | Polish: Additional Skills & Hooks | Week 10 | 24h | Planned |

## Quick Reference Commands

### Create Patch Release (Bug Fixes)

```bash
# Example: 1.0.0 → 1.0.1
echo "1.0.1" > VERSION
# Update plugin.json manually
git add VERSION .claude-plugin/plugin.json README.md CHANGELOG.md
git commit -m "Release v1.0.1: Bug fixes"
git tag -a v1.0.1 -m "Release v1.0.1 - Bug fixes"
git push origin main && git push origin v1.0.1
```

### Create Minor Release (New Features)

```bash
# Example: 1.0.1 → 1.1.0
echo "1.1.0" > VERSION
# Update plugin.json manually
git add VERSION .claude-plugin/plugin.json README.md CHANGELOG.md skills/ hooks-settings.json
git commit -m "Release v1.1.0: [Feature name]"
git tag -a v1.1.0 -m "Release v1.1.0 - [Feature description]"
git push origin main && git push origin v1.1.0
```

### Create Major Release (Breaking Changes)

```bash
# Example: 1.2.0 → 2.0.0
echo "2.0.0" > VERSION
# Update plugin.json manually
git add VERSION .claude-plugin/plugin.json README.md CHANGELOG.md
git commit -m "Release v2.0.0: [Breaking change description]"
git tag -a v2.0.0 -m "Release v2.0.0 - [Major feature]

BREAKING CHANGES:
- [List breaking changes]"
git push origin main && git push origin v2.0.0
```

## Pre-Release Checklist Template

Copy this checklist when preparing a release:

```markdown
## Release v[VERSION] Checklist

**Version Numbers Updated:**
- [ ] VERSION file
- [ ] .claude-plugin/plugin.json
- [ ] README.md version badge

**Documentation Updated:**
- [ ] README.md (features list, counts, examples)
- [ ] CHANGELOG.md (new version section)
- [ ] ROADMAP.md (mark items complete)
- [ ] Skill documentation (if changed)
- [ ] Hook documentation (if changed)

**Testing:**
- [ ] Local installation successful
- [ ] All skills load correctly
- [ ] All hooks work as expected
- [ ] Tested in sample Elixir project

**Git:**
- [ ] All files staged and committed
- [ ] Version tag created
- [ ] Pushed to origin

**Release:**
- [ ] GitHub release created
- [ ] Release notes published
- [ ] Plugin marketplace updated (if applicable)
```

## Rollback Process

If a release has critical issues:

```bash
# Revert to previous version tag
git revert [commit-hash]
git push origin main

# Update version numbers back
echo "[previous-version]" > VERSION
# Update plugin.json
git add VERSION .claude-plugin/plugin.json
git commit -m "Revert to v[previous-version] due to critical issue"
git push origin main

# Delete bad tag
git tag -d v[bad-version]
git push origin :refs/tags/v[bad-version]
```

## Notes

- Always test locally before releasing
- Write detailed commit messages and tag annotations
- Keep CHANGELOG.md up to date
- Never skip the checklist
- When in doubt, create a patch release first
