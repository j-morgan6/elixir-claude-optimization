#!/usr/bin/env bash
# PreToolUse hook for Bash. Reads hook JSON on stdin; blocks dangerous
# commands with a reason on stderr + exit 2 (the only channel Claude reads).
set -u
command -v jq >/dev/null 2>&1 || exit 0
CMD=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$CMD" ] || exit 0

if printf '%s' "$CMD" | grep -qE 'mix[[:space:]]+ecto\.reset'; then
  echo '🚫 mix ecto.reset destroys and recreates the database. Use mix ecto.rollback for safe rollbacks.' >&2
  exit 2
fi

if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push' \
   && printf '%s' "$CMD" | grep -qE '(^|[[:space:]])(-f|--force)([[:space:]]|$)' \
   && ! printf '%s' "$CMD" | grep -q -- '--force-with-lease'; then
  echo '🚫 Force push overwrites remote history. Use --force-with-lease instead.' >&2
  exit 2
fi
exit 0
