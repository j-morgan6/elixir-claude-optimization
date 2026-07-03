#!/usr/bin/env bash
# Test harness for plugin hooks. Feeds Claude Code-shaped JSON on stdin,
# asserts exit codes and stderr content.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FIX="$ROOT/tests/hooks/fixtures"
PASS=0; FAIL=0

# Hermetic env: point the plugin data dir at a temp dir so no real user
# cache can leak into cache-aware checks; clean up on exit.
TMP_ENV_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_ENV_DIR"' EXIT
export CLAUDE_PLUGIN_DATA="$TMP_ENV_DIR/plugin_data"
unset CLAUDE_PROJECT_DIR 2>/dev/null || true

check() { # name, expected_exit, json, stderr_must_match (empty = don't care)
  local name="$1" want="$2" json="$3" pat="${4:-}"
  local err rc
  err=$(printf '%s' "$json" | bash "$ROOT/scripts/hooks/$5" 2>&1 >/dev/null); rc=$?
  if [ "$rc" -ne "$want" ]; then
    echo "FAIL $name: exit $rc (want $want)"; FAIL=$((FAIL+1)); return
  fi
  if [ -n "$pat" ] && ! printf '%s' "$err" | grep -q "$pat"; then
    echo "FAIL $name: stderr missing '$pat'"; FAIL=$((FAIL+1)); return
  fi
  PASS=$((PASS+1))
}

j() { printf '{"tool_input":{"file_path":"%s"}}' "$1"; }
b() { printf '{"tool_input":{"command":"%s"}}' "$1"; }

# bash_guard
check ecto_reset_blocked   2 "$(b 'mix ecto.reset')"                        'ecto.rollback' bash_guard.sh
check force_push_blocked   2 "$(b 'git push --force origin main')"          'force-with-lease' bash_guard.sh
check force_after_args     2 "$(b 'git push origin main --force')"          'force-with-lease' bash_guard.sh
check force_lease_allowed  0 "$(b 'git push --force-with-lease origin main')" '' bash_guard.sh
check plain_push_allowed   0 "$(b 'git push origin main')"                  '' bash_guard.sh
check prod_env_allowed     0 "$(b 'MIX_ENV=prod mix assets.deploy')"        '' bash_guard.sh

# fail-open: empty or malformed stdin must never block
check empty_stdin_bash     0 ''         '' bash_guard.sh
check garbage_stdin_bash   0 'not json' '' bash_guard.sh
check empty_stdin_file     0 ''         '' check_file.sh
check garbage_stdin_file   0 'not json' '' check_file.sh

# check_file — security
check to_atom_blocked      2 "$(j "$FIX/bad_to_atom.ex")"       'String.to_atom' check_file.sh
check fragment_blocked     2 "$(j "$FIX/bad_fragment.ex")"      'fragment'       check_file.sh
check sql_interp_blocked   2 "$(j "$FIX/bad_sql.ex")"           'parameterized'  check_file.sh
check redirect_blocked     2 "$(j "$FIX/bad_redirect.ex")"      'redirect'       check_file.sh
check logger_blocked       2 "$(j "$FIX/bad_logger.ex")"        'Logger'         check_file.sh
check timing_blocked       2 "$(j "$FIX/bad_timing.ex")"        'secure_compare' check_file.sh
check nil_check_allowed    0 "$(j "$FIX/good_nil_check.ex")"    ''               check_file.sh
check inspect_blocked      2 "$(j "$FIX/bad_inspect.ex")"       'IO.inspect'     check_file.sh
check raw_heex_blocked     2 "$(j "$FIX/bad_raw.heex")"         'raw'            check_file.sh

# check_file — deprecations
check form_for_blocked     2 "$(j "$FIX/bad_form_for.ex")"      'form_for'       check_file.sh
check live_redirect_blocked 2 "$(j "$FIX/bad_live_redirect.ex")" 'live_redirect' check_file.sh
check form_for_test_skipped 0 "$(j "$FIX/form_for_test.exs")"   ''               check_file.sh

# check_file — @impl / skips
check impl_missing_blocked 2 "$(j "$FIX/bad_impl.ex")"          '@impl'          check_file.sh
check impl_ok_allowed      0 "$(j "$FIX/good_impl.ex")"         ''               check_file.sh
check plug_init_allowed    0 "$(j "$FIX/good_plug.ex")"         ''               check_file.sh
check clean_file_allowed   0 "$(j "$FIX/good_clean.ex")"        ''               check_file.sh
check test_file_skipped    0 "$(j "$FIX/skip_test.exs")"        ''               check_file.sh
check non_elixir_skipped   0 "$(j "$FIX/readme.md")"            ''               check_file.sh

# check_file — migrations (independent fixtures per finding)
check migration_flagged    2 "$(j "$FIX/migrations/20260101000000_bad_migration.exs")" 'on_delete' check_file.sh
check migration_noindex    2 "$(j "$FIX/migrations/20260102000000_bad_migration_noindex.exs")" 'index' check_file.sh

# check_file — scope-aware @current_user (cache written with the same key
# formula detect_project.sh uses; no cache => no flag, cache => flag)
check scope_no_cache_allowed 0 "$(j "$FIX/bad_current_user.ex")" ''              check_file.sh
export CLAUDE_PROJECT_DIR="$TMP_ENV_DIR/proj"
mkdir -p "$CLAUDE_PROJECT_DIR" "$CLAUDE_PLUGIN_DATA/cache"
SKEY=$(printf '%s' "$CLAUDE_PROJECT_DIR" | shasum | cut -c1-12)
printf '{\n  "phoenix_has_scope": true,\n  "has_liveview": true\n}\n' > "$CLAUDE_PLUGIN_DATA/cache/$SKEY.json"
check scope_current_user_blocked 2 "$(j "$FIX/bad_current_user.ex")" 'current_scope' check_file.sh
unset CLAUDE_PROJECT_DIR
rm -f "$CLAUDE_PLUGIN_DATA/cache/$SKEY.json"

# writer/reader parity: with CLAUDE_PROJECT_DIR unset, detect_project.sh
# (walk-up writer) and check_file.sh (walk-up reader) must hash the same root.
PROJ2="$TMP_ENV_DIR/proj2"
mkdir -p "$PROJ2/lib"
printf 'defmodule P.MixProject do\n  use Mix.Project\n  def project, do: [app: :p, deps: [{:phoenix, "~> 1.8.0"}]]\nend\n' > "$PROJ2/mix.exs"
( cd "$PROJ2/lib" && bash "$ROOT/scripts/detect_project.sh" >/dev/null 2>&1 )
ERR=$( cd "$PROJ2/lib" && printf '%s' "$(j "$FIX/bad_current_user.ex")" | bash "$ROOT/scripts/hooks/check_file.sh" 2>&1 >/dev/null ); RC=$?
if [ "$RC" -eq 2 ] && printf '%s' "$ERR" | grep -q 'current_scope'; then
  PASS=$((PASS+1))
else
  echo "FAIL walkup_cache_parity: exit $RC (want 2 with current_scope finding)"; FAIL=$((FAIL+1))
fi

echo "pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
