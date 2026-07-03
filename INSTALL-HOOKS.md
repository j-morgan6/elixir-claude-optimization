# Hooks

Hooks ship **inside the plugin** (`hooks/hooks.json`) and activate
automatically when you install it:

```
/plugin marketplace add j-morgan6/elixir-phoenix-guide
/plugin install elixir-phoenix-guide@elixir-phoenix-guide
```

No settings.json editing, no script copying.

## What runs

| Event | Check |
|---|---|
| SessionStart | Detects Phoenix/LiveView/Ecto/Oban and caches project facts (in the plugin data dir, never your repo) |
| PreToolUse (Bash) | Blocks `mix ecto.reset` and `git push --force` (suggests `--force-with-lease`) |
| PostToolUse (Write/Edit on .ex/.exs/.heex) | Security (String.to_atom, SQL-injection fragments, open redirects, raw/1, secrets in logs, timing-unsafe ==, IO.inspect/dbg debug calls), Phoenix deprecations (form_for, live_redirect/live_patch, @current_user under 1.8 scopes), missing `@impl true`, migration FK/on_delete safety |

The PreToolUse and PostToolUse checks require `jq` (they silently no-op without it): `brew install jq`. SessionStart's `detect_project.sh` has no `jq` dependency — it always runs.

## How feedback works

Claude Code hooks communicate through **exit code 2 with the reason on
stderr** — that reason is fed back to Claude, which fixes the issue. Exit 0
means no findings. There is no separate "warning" tier.

## Writing your own

Hooks receive JSON on stdin. Get the file path with:

```bash
FILE=$(jq -r '.tool_input.file_path // empty')
```

(`$CLAUDE_PROJECT_DIR` is the project root; there is no
`CLAUDE_HOOK_FILE_PATH` environment variable.)

## Manual install (not using the plugin manager)

Copy the entries from `hooks/hooks.json` into `~/.claude/settings.json`,
replacing `${CLAUDE_PLUGIN_ROOT}` with the absolute path of your checkout.
When merging, **append** to existing event arrays — don't replace them.

## Testing

`bash tests/hooks/run_tests.sh` exercises every check with fixture files.
