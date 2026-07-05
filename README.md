# Elixir Phoenix Guide for Claude Code

**Version:** 2.4.0 | [Changelog](CHANGELOG.md)

An essential development guide for Claude Code that ensures idiomatic Elixir and Phoenix LiveView code. This plugin includes enforced skills, plugin-native hooks, automated code quality analysis, and reference documentation that actively guide and validate your Elixir development workflow.

> **v2.4.0 Released!** Hooks now ship and run entirely inside the plugin — no settings.json merging, no script installation. See [CHANGELOG.md](CHANGELOG.md) for details.

## What's Included

### Skills (19 essential files)
Consolidated domain expertise with enforced patterns:
- **elixir-essentials** - Core Elixir patterns: pattern matching, pipes, with statements, error handling
- **phoenix-liveview-essentials** - Complete LiveView guide: lifecycle, events, rendering phases, state management
- **ecto-essentials** - Database operations: schemas, changesets, queries, migrations, associations
- **phoenix-uploads** - File uploads and static file serving workflow
- **testing-essentials** - Testing patterns: DataCase/ConnCase setup, fixtures, LiveView tests, TDD workflow
- **otp-essentials** - OTP patterns: GenServer, Supervisor, Task, Agent, DynamicSupervisor, Registry, ETS
- **oban-essentials** - Background jobs: workers, queues, idempotency, unique jobs, cron, testing with Oban.Testing
- **code-quality** - Automated code quality detection: duplication, complexity, unused functions
- **phoenix-liveview-auth** - LiveView authentication: on_mount, current_scope, import conflicts, session handling
- **ecto-changeset-patterns** - Advanced changesets: separate per operation, cast_assoc pitfalls, composition
- **phoenix-auth-customization** - Extending phx.gen.auth: custom fields, migrations, fixture updates
- **phoenix-pubsub-patterns** - Real-time updates: subscriptions, broadcasting from contexts, topic naming
- **phoenix-authorization-patterns** - Access control: server-side authz, ownership, policy modules, scoped queries
- **ecto-nested-associations** - Nested data: cast_assoc, cast_embed, Ecto.Multi, cascades, FK indexes
- **security-essentials** - Security enforcement: atom exhaustion, SQL injection, XSS, open redirects, timing attacks
- **deployment-gotchas** - Deployment pitfalls: runtime.exs, release migrations, PHX_HOST, health checks, secrets
- **phoenix-channels-essentials** - Channels: socket auth, topic authorization, Presence, handle_in patterns
- **telemetry-essentials** - Observability: structured logging, :telemetry, Ecto events, LiveDashboard, metrics
- **phoenix-json-api** - JSON APIs: :api pipeline, FallbackController, pagination, versioning, Bearer auth

Each skill includes a RULES section with 6-11 non-negotiable patterns that must be followed.

**Note on auto_suggest metadata:** Skills include `auto_suggest: true` and `file_patterns` metadata for future Claude Code enhancements. These fields are not currently active in the Claude Code runtime but are included for forward compatibility.

### Hooks (ship inside the plugin)
Hooks live in `hooks/hooks.json` and activate automatically when the plugin is installed — no settings.json editing, no script copying:

| Event | Check |
|---|---|
| SessionStart | Detects Phoenix/LiveView/Ecto/Oban and caches project facts (in the plugin data dir, never your repo) |
| PreToolUse (Bash) | Blocks `mix ecto.reset` and `git push --force` (suggests `--force-with-lease`) |
| PostToolUse (Write/Edit on .ex/.exs/.heex) | Security (String.to_atom, SQL-injection fragments, open redirects, raw/1, secrets in logs, timing-unsafe ==, IO.inspect/dbg debug calls), Phoenix deprecations (form_for, live_redirect/live_patch, @current_user under 1.8 scopes), missing `@impl true`, migration FK/on_delete safety |

Feedback works through **exit code 2 with the reason on stderr** — Claude reads that and fixes the issue. Exit 0 means no findings; there is no separate "warning" tier. See [INSTALL-HOOKS.md](INSTALL-HOOKS.md) for the full write-up, manual install (without the plugin manager), and how to write your own hooks.

### Analysis Scripts (3 scripts)
Automated code quality analysis tools, run on demand from a checkout (they are not installed anywhere by the plugin manager or `install.sh`):
- **code_quality.exs** - AST-based Elixir analysis: duplication detection, ABC complexity, unused function detection (`elixir scripts/code_quality.exs scan lib/`)
- **detect_project.sh** - Project stack detection used by the SessionStart hook
- **run_analysis.sh** - Full project analysis runner

### Reference Documentation (4 files)
Detailed reference material in `docs/reference/` for complex tasks:
- **project-structure.md** - Directory layout and context boundaries
- **liveview-checklist.md** - Step-by-step LiveView development checklist
- **ecto-conventions.md** - Comprehensive Ecto patterns and best practices
- **testing-guide.md** - Testing patterns for contexts, LiveViews, and schemas

### Project Template
- **CLAUDE.md.template** - Project-specific instructions template

## Installation

> **Note:** Official marketplace publication is in progress. Once available, installation will be even simpler through the official Claude Code marketplace.

### Installing for the First Time

In a Claude Code session:

```bash
# Step 1: Add the marketplace (first time only)
/plugin marketplace add j-morgan6/elixir-phoenix-guide

# Step 2: Install the plugin
/plugin install elixir-phoenix-guide@elixir-phoenix-guide
```

Skills and hooks activate automatically — nothing else to configure. Optional extras (the `CLAUDE.md` project template, cleanup of legacy pre-2.4.0 installs) are available via `./install.sh` from a checkout:

```bash
git clone https://github.com/j-morgan6/elixir-phoenix-guide.git
cd elixir-phoenix-guide
./install.sh
```

### Updating to Latest Version

If you already have the plugin installed:

```bash
# Open the interactive plugin manager
/plugin

# Select "Marketplaces" → "elixir-phoenix-guide" → "Update"
# Then update the plugin from the menu
# Verify version shows 2.4.0 or higher
```

**Latest Updates (v2.4.0):**
- Hooks are now plugin-native (`hooks/hooks.json`) — they run automatically on install with no settings.json merging and no script installation
- Phoenix 1.8 accuracy fixes across skills: corrected LiveView assigns, test setup, auth imports, and other community-reported issues
- Differentiated "Use when…" trigger descriptions across all 19 skills, so Claude selects the right skill instead of guessing
- Total: 19 skills, 3 hook events (SessionStart, PreToolUse, PostToolUse), 3 analysis scripts, 4 reference docs

See [CHANGELOG.md](CHANGELOG.md) for full release notes and version history.

## Usage

Once installed, Claude Code will automatically:

1. **Load skills** based on code context - providing intelligent suggestions for Elixir patterns
2. **Enforce hooks** in real-time - catching anti-patterns as you write code
3. **Consult reference docs** when needed - accessing detailed information for complex tasks
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

**After (with skills guiding idiomatic Elixir):**
- Skill suggests pattern matching over nested conditionals
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
   - Hooks catch anti-patterns (missing @impl, security issues, Phoenix deprecations)
   - Reference docs provide detailed checklists

## What This Optimizes

### Code Quality
- **Flags** callbacks without @impl true (reported to Claude after the write, for it to fix)
- **Blocks** dangerous Bash commands: `mix ecto.reset`, `git push --force`
- **Flags** security risks: String.to_atom/1, SQL-injection in fragments/raw queries, open redirects, timing-unsafe comparisons, secrets in Logger calls, IO.inspect/dbg left in lib code
- **Flags** raw/1 (XSS risk) and deprecated Phoenix APIs (form_for, live_redirect/live_patch, @current_user under Phoenix 1.8 scopes)
- **Checks** migrations for missing FK indexes and missing on_delete strategies
- **Detects** code duplication and high ABC complexity (threshold: 30) on demand via `elixir scripts/code_quality.exs scan lib/`

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

## Why This Exists

This plugin was created to ensure Claude Code consistently produces idiomatic Elixir and Phoenix code by making best practices impossible to ignore, not just available. It combines enforced patterns, real-time validation, and comprehensive guidance for all Elixir development work.

## Project-Specific Setup

For project-specific instructions, you can create a `CLAUDE.md` file in your project root with:
- Your app name and description
- Project-specific contexts
- Custom commands and workflows
- Team conventions

This file will be automatically loaded by Claude Code when working in your project.

## File Structure

```
elixir-phoenix-guide/
├── README.md                          # This file
├── INSTALL-HOOKS.md                   # Hook behavior reference
├── CLAUDE.md.template                 # Project-specific instructions template
├── install.sh                         # Optional extras: CLAUDE.md template + legacy cleanup
├── skills/                            # Elixir expertise (19 skills)
│   ├── elixir-essentials/SKILL.md
│   ├── phoenix-liveview-essentials/SKILL.md
│   ├── ecto-essentials/SKILL.md
│   ├── phoenix-uploads/SKILL.md
│   ├── testing-essentials/SKILL.md
│   ├── otp-essentials/SKILL.md
│   ├── oban-essentials/SKILL.md
│   ├── code-quality/SKILL.md
│   ├── phoenix-liveview-auth/SKILL.md
│   ├── ecto-changeset-patterns/SKILL.md
│   ├── phoenix-auth-customization/SKILL.md
│   ├── phoenix-pubsub-patterns/SKILL.md
│   ├── phoenix-authorization-patterns/SKILL.md
│   ├── ecto-nested-associations/SKILL.md
│   ├── security-essentials/SKILL.md
│   ├── deployment-gotchas/SKILL.md
│   ├── phoenix-channels-essentials/SKILL.md
│   ├── telemetry-essentials/SKILL.md
│   └── phoenix-json-api/SKILL.md
├── hooks/
│   └── hooks.json                    # SessionStart + PreToolUse + PostToolUse config
├── scripts/                           # Analysis and detection scripts
│   ├── code_quality.exs              # AST-based Elixir analysis (on demand)
│   ├── detect_project.sh             # Project stack detection (used by SessionStart)
│   ├── run_analysis.sh               # Full project analysis runner (on demand)
│   ├── sync_copilot.sh               # regenerate the Copilot port from skills/
│   └── hooks/                        # Scripts the shipped hooks actually run
│       ├── bash_guard.sh             # PreToolUse (Bash)
│       └── check_file.sh             # PostToolUse (Write|Edit)
├── tests/
│   ├── hooks/run_tests.sh            # Hook test harness (fixture-based)
│   └── code_quality/run_tests.sh     # code_quality.exs test harness
└── docs/reference/                    # Reference documentation
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

The plugin manager installs skills and hooks from this repo's checkout under
`~/.claude/plugins/marketplaces/elixir-phoenix-guide/` — it does not copy
files into `~/.claude/skills/` or merge anything into `~/.claude/settings.json`.
To customize behavior, fork the repo (or add a project-level
`hooks/hooks.json` override) rather than hand-editing the installed checkout,
since plugin updates overwrite it.

### Adding Custom Skills
Add new directories with `SKILL.md` files under `skills/` in your fork.

### Modifying Existing Rules
Edit any skill file or the scripts under `scripts/hooks/` in your fork — changes take effect on next Claude Code restart.

## Checking Your Version

In a Claude Code session:
```bash
/plugin

# Or check version in the plugin list
# Navigate to your installed plugins and verify version 2.4.0 or higher
```

## Troubleshooting

### Plugin shows old version after update

The `/plugin` update command may not refresh its local cache automatically. If the version shown doesn't match the latest release, run:

```bash
cd ~/.claude/plugins/marketplaces/elixir-phoenix-guide && git pull
```

Then re-run `/plugin` and update the plugin from the menu.

## Uninstall

In a Claude Code session:
```bash
/plugin

# Navigate to installed plugins
# Select elixir-phoenix-guide and choose "Uninstall"
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
