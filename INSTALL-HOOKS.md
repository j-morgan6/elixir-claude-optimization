# Installing Elixir Optimization Hooks

The hooks for this plugin use Claude Code's native hook system (shell commands in settings.json), not YAML files.

## Installation Methods

### Method 1: Automatic (Recommended)

Run the install script which will merge hooks into your settings:

```bash
curl -sL https://raw.githubusercontent.com/j-morgan6/elixir-phoenix-guide/main/install.sh | bash
```

### Method 2: Manual Installation

1. Copy the hooks configuration:
```bash
cat hooks-settings.json
```

2. Merge it into your `~/.claude/settings.json` or `.claude/settings.json`

3. If you already have hooks, merge the `PreToolUse` arrays together

## What the Hooks Do

### Blocking Hooks (exit 2 - prevents the action)

1. **Missing @impl true** - Blocks callback functions without `@impl true` annotation
   - Catches: `def mount(`, `def handle_event(`, etc.
   - Message: "Missing @impl true before callback function"

2. **Hardcoded file paths** - Blocks hardcoded paths like `/uploads/` or `priv/static/`
   - Message: "Use Application.get_env(:app, :config_key) instead"

3. **Hardcoded file sizes** - Blocks hardcoded large numbers (file size limits)
   - Message: "Move to Application config"

### Warning Hooks (exit 1 - shows warning but allows)

4. **Nested if/else** - Warns about nested conditionals
   - Message: "Consider using pattern matching or case statements"

5. **Inefficient Enum chains** - Warns about multiple Enum.map/filter
   - Message: "Consider using a for comprehension"

6. **String concatenation in loops** - Warns about `<>` in Enum operations
   - Message: "Consider using IO lists or Enum.join"

## Testing Hooks

Create a file with anti-patterns:

```elixir
# Should block (missing @impl)
def handle_event("save", params, socket) do
  # Should block (hardcoded path)
  path = "/uploads/images"

  # Should block (hardcoded size)
  max_size = 10000000

  # Should warn (nested if)
  if user do
    if admin do
      :ok
    end
  end

  {:noreply, socket}
end
```

The hooks should fire on Write or Edit operations.

## Uninstalling Hooks

Remove the `hooks` section from your `~/.claude/settings.json` or `.claude/settings.json`.

## Hook System Reference

Claude Code hooks run shell commands when tools are used:
- **PreToolUse**: Before Write, Edit, Bash, etc.
- **PostToolUse**: After tool completes
- **exit 0**: Allow the action
- **exit 1**: Warning (shows message, allows action)
- **exit 2**: Block (shows message, prevents action)

Environment variables available:
- `$CLAUDE_HOOK_FILE_PATH`: File being edited/written
- `$CLAUDE_HOOK_TOOL_NAME`: Tool being used (Write, Edit, etc.)
