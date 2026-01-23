# Elixir Claude Code Optimization

A comprehensive configuration package for Claude Code that transforms it into an Elixir and Phoenix LiveView expert. This setup includes skills, hooks, and agent documentation that enforce best practices and provide intelligent guidance for idiomatic Elixir development.

## What's Included

### 🎓 Skills (4 files)
Domain expertise that teaches Claude about Elixir/Phoenix patterns:
- **elixir-patterns.md** - Pattern matching, pipes, with statements, naming conventions
- **phoenix-liveview.md** - LiveView lifecycle, events, uploads, PubSub, navigation
- **ecto-database.md** - Schemas, changesets, queries, associations, migrations
- **error-handling.md** - Error tuples, with statements, supervisors, error boundaries

### 🔒 Hooks (5 files)
Active enforcement rules that catch anti-patterns in real-time:
- **nested-if-else.yml** - Warns about nested if/else (prefer pattern matching)
- **hardcoded-config.yml** - Blocks hardcoded config values (use Application.get_env)
- **inefficient-enum.yml** - Warns about multiple Enum passes (use for comprehensions)
- **missing-impl.yml** - Blocks callback implementations without @impl true
- **string-concatenation.yml** - Warns about string concatenation in loops (use IO lists)

### 📚 Agent Documentation (4 files)
Detailed reference material for complex tasks:
- **project-structure.md** - Directory layout and context boundaries
- **liveview-checklist.md** - Step-by-step LiveView development checklist
- **ecto-conventions.md** - Comprehensive Ecto patterns and best practices
- **testing-guide.md** - Testing patterns for contexts, LiveViews, and schemas

### 📋 Project Template
- **CLAUDE.md.template** - Project-specific instructions template

## Installation

### Quick Install (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/j-morgan6/elixir-claude-optimization/main/install.sh | bash
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/j-morgan6/elixir-claude-optimization.git
cd elixir-claude-optimization
```

2. Copy files to your Claude configuration directory:
```bash
# Install skills
mkdir -p ~/.claude/skills
cp skills/* ~/.claude/skills/

# Install hooks
mkdir -p ~/.claude/hooks
cp hooks/* ~/.claude/hooks/

# Install agent documentation
mkdir -p ~/.claude/agents
cp agents/* ~/.claude/agents/
```

3. (Optional) Copy CLAUDE.md template to your project:
```bash
cp CLAUDE.md.template /path/to/your/project/CLAUDE.md
# Edit CLAUDE.md to match your project specifics
```

4. Restart Claude Code to load the configuration

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
- ✅ Enforces pattern matching over if/else
- ✅ Prevents hardcoded configuration
- ✅ Catches inefficient Enum operations
- ✅ Requires @impl on all callbacks
- ✅ Prevents string concatenation in loops

### Developer Experience
- 🎯 Proactive guidance on Elixir idioms
- 🎯 Real-time feedback on code quality
- 🎯 Detailed checklists for complex features
- 🎯 Consistent conventions across projects
- 🎯 Reduced iterations and corrections

### Learning
- 📖 Clear explanations of "why" not just "what"
- 📖 Links to relevant patterns and best practices
- 📖 Progressive disclosure of complexity
- 📖 Examples of idiomatic vs non-idiomatic code

## Comparison Project

This optimization package was created as part of a comparison study to measure the effectiveness of Claude Code customization for Elixir development. See the [comparison results](#) for quantitative data on:
- Hook interventions vs manual corrections
- Iterations to working code
- Code quality metrics (Credo scores)
- Developer experience improvements

## Project-Specific Setup

For project-specific instructions:

1. Copy `CLAUDE.md.template` to your project root as `CLAUDE.md`
2. Customize it with:
   - Your app name and description
   - Project-specific contexts
   - Custom commands and workflows
   - Team conventions

Example:
```bash
cp ~/.claude/agents/../CLAUDE.md.template ./CLAUDE.md
# Edit CLAUDE.md with your project details
git add CLAUDE.md
git commit -m "Add Claude Code project configuration"
```

## File Structure

```
elixir-claude-optimization/
├── README.md                          # This file
├── install.sh                         # Automated installer
├── CLAUDE.md.template                 # Project template
├── skills/                            # Elixir expertise
│   ├── elixir-patterns.md
│   ├── phoenix-liveview.md
│   ├── ecto-database.md
│   └── error-handling.md
├── hooks/                             # Real-time enforcement
│   ├── nested-if-else.yml
│   ├── hardcoded-config.yml
│   ├── inefficient-enum.yml
│   ├── missing-impl.yml
│   └── string-concatenation.yml
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

All files are Markdown or YAML - easy to modify for your needs:

### Adding Custom Skills
Create new `.md` files in `~/.claude/skills/` with your patterns

### Adding Custom Hooks
Create new `.yml` files in `~/.claude/hooks/`:

```yaml
---
name: my-custom-hook
description: What this checks
action: warn  # or "block"
patterns:
  - regex: 'pattern'
    message: |
      Explanation and fix
```

### Modifying Existing Rules
Edit any skill or hook file - changes take effect on next Claude Code restart

## Uninstall

```bash
# Remove skills
rm -rf ~/.claude/skills/elixir-patterns.md
rm -rf ~/.claude/skills/phoenix-liveview.md
rm -rf ~/.claude/skills/ecto-database.md
rm -rf ~/.claude/skills/error-handling.md

# Remove hooks
rm -rf ~/.claude/hooks/nested-if-else.yml
rm -rf ~/.claude/hooks/hardcoded-config.yml
rm -rf ~/.claude/hooks/inefficient-enum.yml
rm -rf ~/.claude/hooks/missing-impl.yml
rm -rf ~/.claude/hooks/string-concatenation.yml

# Remove agent docs
rm -rf ~/.claude/agents/project-structure.md
rm -rf ~/.claude/agents/liveview-checklist.md
rm -rf ~/.claude/agents/ecto-conventions.md
rm -rf ~/.claude/agents/testing-guide.md
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
