# Changelog

All notable changes to the Elixir Claude Optimization plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- New battle-tested skills from real development (v1.2.0)
- Automated code quality detection system (v2.0.0)
- Additional skills and hooks (v2.1.0)

See [ROADMAP.md](ROADMAP.md) for detailed planning.

## [1.1.0] - 2026-02-09

### Added
- **skill-discovery meta-skill** - Systematic checklist for identifying applicable skills
  - File type detection for automatic skill suggestion
  - Task type detection for process skills
  - Priority-ordered skill invocation guide
  - Example workflows for common scenarios
  - Marked as priority 1 skill to invoke first

### Changed
- **All 7 existing skills updated** with mandatory "INVOKE BEFORE" language:
  - elixir-patterns: "INVOKE BEFORE writing any Elixir code"
  - phoenix-liveview: "INVOKE BEFORE implementing any LiveView feature"
  - ecto-database: "INVOKE BEFORE modifying any Ecto schema, query, or migration"
  - error-handling: "INVOKE BEFORE implementing error handling"
  - phoenix-uploads: "INVOKE BEFORE implementing file upload functionality"
  - phoenix-static-files: "INVOKE BEFORE serving uploaded files or static content"
  - liveview-lifecycle: "INVOKE BEFORE working with LiveView rendering phases"

- **File pattern metadata added** to all skills:
  - Skills now include file_patterns array for automatic detection
  - auto_suggest: true flag enables proactive skill suggestions
  - Pattern matching for .ex, .exs, .heex files and specific directories

### Impact
- Expected 50%+ increase in skill usage through forcing language
- Automatic skill suggestions when editing relevant files
- Systematic skill discovery prevents missing applicable guidance
- Better developer experience with proactive skill recommendations

## [1.0.0] - 2026-01-26

### Added
- **7 Skills** for Elixir and Phoenix development:
  - `elixir-patterns` - Pattern matching, pipes, with statements, naming conventions
  - `phoenix-liveview` - LiveView lifecycle, events, uploads, PubSub, navigation
  - `ecto-database` - Schemas, changesets, queries, associations, migrations
  - `error-handling` - Error tuples, with statements, supervisors, error boundaries
  - `phoenix-uploads` - File upload configuration, manual vs auto-upload patterns
  - `phoenix-static-files` - Static paths configuration and file serving
  - `liveview-lifecycle` - Render phases, safe assign access, mount initialization

- **10 Hooks** for real-time code quality enforcement:
  - Blocking hooks (5): missing-impl, hardcoded-paths, hardcoded-sizes, static-paths-validator, deprecated-components
  - Warning hooks (4): nested-if-else, inefficient-enum, string-concatenation, auto-upload-warning

- **4 Agent Documentation Files**:
  - `project-structure.md` - Directory layout and context boundaries
  - `liveview-checklist.md` - Step-by-step LiveView development guide
  - `ecto-conventions.md` - Comprehensive Ecto patterns and best practices
  - `testing-guide.md` - Testing patterns for contexts, LiveViews, and schemas

- **Installation Methods**:
  - Claude Code plugin marketplace installation
  - Quick install script
  - Manual installation guide

- **Project Template**:
  - CLAUDE.md.template for project-specific customization

### Documentation
- Comprehensive README with installation and usage instructions
- Hook installation guide (INSTALL-HOOKS.md)
- MIT License
- Installation script (install.sh)

---

## Version History Summary

| Version | Date | Description |
|---------|------|-------------|
| v1.1.0 | Pending | Skill discoverability improvements - 8 skills, forcing language, file patterns |
| v1.0.0 | 2026-01-26 | Initial release with 7 skills, 10 hooks, and 4 agent docs |

---

## Upgrade Guide

### From No Configuration → v1.0.0
Install using any of the three methods in README.md. No migration needed.

---

## Future Versions (Planned)

### v1.1.0 - Quick Wins: Skill Discoverability
**Target:** Week 1 after v1.0.0
**Focus:** Make existing skills more discoverable and enforce usage

**Planned Changes:**
- Update all skill descriptions with "INVOKE BEFORE" forcing language
- Add file pattern detection metadata to skills
- Create skill-discovery meta-skill

### v1.2.0 - High-Impact Skills
**Target:** Week 3 after v1.0.0
**Focus:** Add battle-tested patterns from real Phoenix development

**Planned Additions:**
- `phoenix-liveview-auth` - on_mount patterns, session handling
- `phoenix-file-uploads` - consume_uploaded_entries, static_paths
- `ecto-changeset-patterns` - cast_assoc, conditional validation
- `phoenix-auth-customization` - Extending phx.gen.auth

### v2.0.0 - Automation: Code Quality Detection
**Target:** Month 2 after v1.0.0
**Focus:** Automated detection of code quality issues

**Planned Features:**
- Code duplication detection system
- Template duplication detection
- ABC complexity analyzer
- Unused function detection

### v2.1.0 - Polish: Additional Skills & Hooks
**Target:** Month 3 after v1.0.0
**Focus:** Additional patterns and refinements

**Planned Additions:**
- `phoenix-pubsub-patterns` - Real-time update patterns
- `phoenix-authorization-patterns` - Owner-only actions, RBAC
- `ecto-nested-associations` - cast_assoc, Ecto.Multi
- Pre-migration and pre-commit hooks

---

[Unreleased]: https://github.com/j-morgan6/elixir-claude-optimization/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/j-morgan6/elixir-claude-optimization/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/j-morgan6/elixir-claude-optimization/releases/tag/v1.0.0
