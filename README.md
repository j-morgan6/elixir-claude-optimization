# Elixir Claude Code Optimization

**Version:** 1.1.2 | [Changelog](CHANGELOG.md)

A comprehensive configuration package for Claude Code that transforms it into an Elixir and Phoenix LiveView expert. This setup includes skills, hooks, and agent documentation that enforce best practices and provide intelligent guidance for idiomatic Elixir development.

> **v1.1.0 Released!** Skill discoverability improvements with mandatory "INVOKE BEFORE" language, file pattern detection, and new skill-discovery meta-skill.

## What's Included

### Skills (8 files)
Domain expertise that teaches Claude about Elixir/Phoenix patterns:
- **skill-discovery** - Meta-skill for identifying which skills to invoke (INVOKE FIRST)
- **elixir-patterns** - Pattern matching, pipes, with statements, naming conventions
- **phoenix-liveview** - LiveView lifecycle, events, uploads, PubSub, navigation
- **ecto-database** - Schemas, changesets, queries, associations, migrations
- **error-handling** - Error tuples, with statements, supervisors, error boundaries
- **phoenix-uploads** - File upload configuration, manual vs auto-upload, error handling
- **phoenix-static-files** - Static paths configuration, serving uploaded files, troubleshooting
- **liveview-lifecycle** - Render phases, safe assign access, mount initialization

**New in v1.1.0:** All skills now use mandatory "INVOKE BEFORE" language and include file pattern detection for automatic suggestions.

### Hooks (10 shell commands in settings.json)
Active enforcement rules that catch anti-patterns in real-time:

**Blocking (exit 2 - prevents action):**
- **missing-impl** - Blocks callbacks without @impl true
- **hardcoded-paths** - Blocks hardcoded file paths
- **hardcoded-sizes** - Blocks hardcoded file size limits
- **static-paths-validator** - Blocks file references not in static_paths()
- **deprecated-components** - Blocks deprecated Phoenix components (.flash_group, form_for, live_redirect)

**Warnings (exit 1 - shows warning, allows action):**
- **nested-if-else** - Warns about nested if/else, suggests pattern matching
- **inefficient-enum** - Warns about multiple Enum operations
- **string-concatenation** - Warns about string concatenation in loops
- **auto-upload-warning** - Warns when auto_upload: true is detected

### Agent Documentation (4 files)
Detailed reference material for complex tasks:
- **project-structure.md** - Directory layout and context boundaries
- **liveview-checklist.md** - Step-by-step LiveView development checklist
- **ecto-conventions.md** - Comprehensive Ecto patterns and best practices
- **testing-guide.md** - Testing patterns for contexts, LiveViews, and schemas

### Project Template
- **CLAUDE.md.template** - Project-specific instructions template

## Installation

> **Note:** Official marketplace publication is in progress. Once available, installation will be even simpler through the official Claude Code marketplace.

### Installing for the First Time

In a Claude Code session, use the interactive plugin manager:

```bash
# Step 1: Add the marketplace (first time only)
/plugin marketplace add j-morgan6/elixir-claude-optimization

# Step 2: Open the interactive plugin manager
/plugin

# This opens an interactive menu where you can:
# - Select the elixir-claude-optimization marketplace
# - Install the elixir-optimization plugin
# - Choose scope (user = all projects, project = current only)
# - Verify you have version 1.1.2 or higher
```

### Updating to Latest Version

If you already have the plugin installed:

```bash
# Open the interactive plugin manager
/plugin

# Select "Marketplaces" → "elixir-claude-optimization" → "Update"
# Then update the plugin from the menu
# Verify version shows 1.1.2 or higher
```

**Latest Updates:**
- Fixed marketplace version detection issue
- New **skill-discovery** meta-skill for systematic skill selection
- All skills updated with mandatory "INVOKE BEFORE" language
- File pattern detection for automatic skill suggestions

See [CHANGELOG.md](CHANGELOG.md) for full release notes and version history.

## Usage

Once installed, Claude Code will automatically:

1. **Load skills** based on code context - providing intelligent suggestions for Elixir patterns
2. **Enforce hooks** in real-time - catching anti-patterns as you write code
3. **Reference agent docs** when needed - accessing detailed information for complex tasks
4. **Follow CLAUDE.md** (if present) - respecting project-specific conventions

### Example Interactions

**Before (without optimization):**
```elixir
def process(user) do
  if user.status == :active do
    if user.role == :admin do
      :allowed
    else
      :denied
    end
  else
    :inactive
  end
end
```

**After (with hooks and skills):**
- Hook warns about nested if/else
- Skill suggests pattern matching
- Claude generates:

```elixir
def process(%{status: :active, role: :admin}), do: :allowed
def process(%{status: :active}), do: :denied
def process(_), do: :inactive
```

### Testing the Setup

1. Open a Phoenix/Elixir project in Claude Code
2. Ask Claude to create a LiveView
3. Observe:
   - Skills guide idiomatic implementation
   - Hooks catch anti-patterns (missing @impl, hardcoded values)
   - Agent docs provide detailed checklists

## What This Optimizes

### Code Quality
- **Blocks** callbacks without @impl true (prevents compilation)
- **Blocks** hardcoded file paths and sizes (prevents runtime issues)
- **Warns** about nested if/else (suggests pattern matching)
- **Warns** about inefficient Enum chains (suggests for comprehensions)
- **Warns** about string concatenation in loops (suggests IO lists)

### Developer Experience
- Proactive guidance on Elixir idioms
- Real-time feedback on code quality
- Detailed checklists for complex features
- Consistent conventions across projects
- Reduced iterations and corrections

### Learning
- Clear explanations of "why" not just "what"
- Links to relevant patterns and best practices
- Progressive disclosure of complexity
- Examples of idiomatic vs non-idiomatic code

## Comparison Project

This optimization package was created as part of a comparison study to measure the effectiveness of Claude Code customization for Elixir development. See the [comparison results](#) for quantitative data on:
- Hook interventions vs manual corrections
- Iterations to working code
- Code quality metrics (Credo scores)
- Developer experience improvements

## Project-Specific Setup

For project-specific instructions, you can create a `CLAUDE.md` file in your project root with:
- Your app name and description
- Project-specific contexts
- Custom commands and workflows
- Team conventions

This file will be automatically loaded by Claude Code when working in your project.

## File Structure

```
elixir-claude-optimization/
├── README.md                          # This file
├── skills/                            # Elixir expertise (8 skills)
│   ├── skill-discovery/SKILL.md
│   ├── elixir-patterns/SKILL.md
│   ├── phoenix-liveview/SKILL.md
│   ├── ecto-database/SKILL.md
│   ├── error-handling/SKILL.md
│   ├── phoenix-uploads/SKILL.md
│   ├── phoenix-static-files/SKILL.md
│   └── liveview-lifecycle/SKILL.md
├── hooks-settings.json                # Hook configuration
└── agents/                            # Reference documentation
    ├── project-structure.md
    ├── liveview-checklist.md
    ├── ecto-conventions.md
    └── testing-guide.md
```

## Requirements

- Claude Code CLI installed
- Elixir 1.15+ projects
- Phoenix 1.7+ (for LiveView features)

## Customization

After installation via the plugin manager, all configuration files are installed to `~/.claude/`:
- Skills: `~/.claude/skills/`
- Hooks: `~/.claude/settings.json`
- Agent docs: `~/.claude/agents/`

You can customize these files directly. Changes take effect after restarting Claude Code.

### Adding Custom Skills
Create new directories with `SKILL.md` files in `~/.claude/skills/`

### Modifying Existing Rules
Edit any skill or hook file - changes take effect on next Claude Code restart

## Checking Your Version

In a Claude Code session:
```bash
/plugin

# Or check version in the plugin list
# Navigate to your installed plugins and verify version 1.1.2 or higher
```

## Uninstall

In a Claude Code session:
```bash
/plugin

# Navigate to installed plugins
# Select elixir-optimization and choose "Uninstall"
```

## Contributing

Contributions welcome! Areas for improvement:
- Additional Elixir patterns and anti-patterns
- More Phoenix-specific hooks
- OTP and GenServer guidance
- Testing patterns and best practices
- Real-world examples and case studies

## License

MIT

## Acknowledgments

Inspired by the [Optimizing Claude Code](https://mays.co/optimizing-claude-code) article by Steven Mays.

## Related Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- [Phoenix Framework](https://www.phoenixframework.org/)
- [Credo (Static Analysis)](https://github.com/rrrene/credo)

---

**Note:** This configuration applies globally to all Elixir projects. For project-specific customizations, use the `CLAUDE.md.template` in your project root.
