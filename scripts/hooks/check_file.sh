#!/usr/bin/env bash
# PostToolUse hook for Write|Edit. Reads hook JSON on stdin, inspects the
# written Elixir/HEEx file, and reports all findings on stderr with exit 2
# so Claude receives them as feedback. Fails open on missing jq/file.
set -u
command -v jq >/dev/null 2>&1 || exit 0
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

case "$FILE" in
  *.ex|*.exs|*.heex) ;;
  *) exit 0 ;;
esac

IS_TEST=0
case "$FILE" in
  *_test.exs|*/test/*) IS_TEST=1 ;;
esac

FINDINGS=''
add() { FINDINGS="${FINDINGS}
• $1"; }

# --- project cache (written by detect_project.sh at SessionStart) ---
# Walk-up fallback mirrors detect_project.sh so writer and reader hash the
# same project root when CLAUDE_PROJECT_DIR is unset.
find_project_root() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/mix.exs" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "$PWD"
}
PROJ="${CLAUDE_PROJECT_DIR:-$(find_project_root)}"
CACHE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/elixir-phoenix-guide}/cache"
KEY=$(printf '%s' "$PROJ" | shasum | cut -c1-12)
CACHE="$CACHE_DIR/$KEY.json"
HAS_SCOPE=''
if [ -f "$CACHE" ]; then
  HAS_SCOPE=$(grep -o '"phoenix_has_scope":[[:space:]]*[a-z]*' "$CACHE" 2>/dev/null | grep -o '[a-z]*$')
fi

IS_EX=0
case "$FILE" in *.ex|*.exs) IS_EX=1 ;; esac

# --- security checks (skip test files) ---
if [ "$IS_TEST" -eq 0 ] && [ "$IS_EX" -eq 1 ]; then
  grep -qE 'String\.to_atom\(' "$FILE" && \
    add 'String.to_atom/1 — atom table exhaustion risk on user input. Whitelist with case, or String.to_existing_atom inside a rescue.'
  grep -qE 'fragment\("[^"]*#\{' "$FILE" && \
    add 'String interpolation inside Ecto fragment() — SQL injection. Use ? placeholders: fragment("lower(?)", field).'
  grep -qE 'Ecto\.Adapters\.SQL\.query!?\(' "$FILE" && grep -qE 'query!?\([^)]*"[^"]*#\{' "$FILE" && \
    add 'Raw SQL with interpolation — SQL injection. Use parameterized queries: query(Repo, "... WHERE id = $1", [id]).'
  grep -qE 'redirect\([^)]*to:[[:space:]]*(params|conn\.params|socket\.assigns)\[' "$FILE" && \
    add 'Open redirect — user-controlled URL. Use verified routes (~p) or whitelist the target.'
  grep -qE 'Logger\.(info|warning|warn|error|debug|notice)\(.*(password|token|secret|api_key|credentials|private_key)' "$FILE" && \
    add 'Possible sensitive data in Logger call — redact passwords/tokens/secrets before logging.'
  # Literal operands (nil/true/false) are presence checks, not secret
  # comparisons — filter them out on either side to avoid false positives.
  TIMING=$(grep -E '(token|secret|api_key|signature)[[:space:]]*==[[:space:]]*[a-z_]|[a-z_][[:space:]]*==[[:space:]]*(token|secret|api_key|signature)\b' "$FILE" 2>/dev/null \
    | grep -vE '==[[:space:]]*(nil|true|false)([^a-zA-Z0-9_]|$)' \
    | grep -vE '(^|[^a-zA-Z0-9_.])(nil|true|false)[[:space:]]*==')
  [ -n "$TIMING" ] && \
    add 'Timing-unsafe secret comparison with == — use Plug.Crypto.secure_compare/2.'
  grep -qE 'IO\.inspect\(|(^|[^a-zA-Z_.])dbg\(' "$FILE" && [ "${FILE##*.}" = "ex" ] && \
    add 'Debug call (IO.inspect/dbg) in lib code — remove before committing.'
fi

# --- XSS (includes heex, skip tests) ---
if [ "$IS_TEST" -eq 0 ]; then
  grep -qE '(^|[^a-zA-Z_])raw\(|Phoenix\.HTML\.raw\(' "$FILE" && \
    add 'raw/1 bypasses HTML escaping — XSS risk if content includes user input. Sanitize (HtmlSanitizeEx) or drop raw/1.'
fi

# --- deprecations (Phoenix 1.7+/1.8; skip test files) ---
if [ "$IS_TEST" -eq 0 ]; then
  grep -qE 'form_for\(' "$FILE" && \
    add 'form_for is deprecated — use <.form for={to_form(@changeset)}>.'
  grep -qE '(^|[^_a-zA-Z])(live_redirect|live_patch)\b' "$FILE" && \
    add 'live_redirect/live_patch are deprecated — use <.link navigate={...}>/<.link patch={...}> or push_navigate/push_patch.'
  if [ "$HAS_SCOPE" = "true" ] && grep -qE '@current_user\b' "$FILE" && ! grep -qE 'current_scope' "$FILE"; then
    add 'Phoenix 1.8 scope detected: use @current_scope (access user via @current_scope.user) instead of @current_user.'
  fi
fi

# --- @impl per-callback (lib .ex only; init/render excluded: Plug/components) ---
if [ "$IS_TEST" -eq 0 ] && [ "${FILE##*.}" = "ex" ]; then
  MISSING=$(awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*def (mount|handle_params|handle_event|handle_info|handle_call|handle_cast|handle_continue|handle_async|terminate)\(/ {
      if (prev !~ /@impl/) print NR": "$0
    }
    NF { prev = $0 }
  ' "$FILE")
  [ -n "$MISSING" ] && add "Callback(s) missing @impl true on the preceding line:
$MISSING"
fi

# --- migration safety ---
case "$FILE" in
  */migrations/*.exs)
    if grep -qE 'references\(' "$FILE" && ! grep -qE 'create[[:space:]]+(unique_)?index' "$FILE"; then
      add 'Migration adds references() without an index — add create index(:table, [:fk_id]).'
    fi
    if grep -qE 'references\(' "$FILE" && ! grep -q 'on_delete:' "$FILE"; then
      add 'references() without on_delete — specify :delete_all, :nilify_all, or :nothing explicitly.'
    fi
    ;;
esac

if [ -n "$FINDINGS" ]; then
  {
    echo "elixir-phoenix-guide checks flagged $FILE:"
    printf '%s\n' "$FINDINGS"
    echo ''
    echo 'Fix the issues above (or explain why they are intentional).'
  } >&2
  exit 2
fi
exit 0
