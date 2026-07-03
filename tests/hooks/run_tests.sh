#!/usr/bin/env bash
# Test harness for plugin hooks. Feeds Claude Code-shaped JSON on stdin,
# asserts exit codes and stderr content.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FIX="$ROOT/tests/hooks/fixtures"
PASS=0; FAIL=0

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
check force_lease_allowed  0 "$(b 'git push --force-with-lease origin main')" '' bash_guard.sh
check plain_push_allowed   0 "$(b 'git push origin main')"                  '' bash_guard.sh
check prod_env_allowed     0 "$(b 'MIX_ENV=prod mix assets.deploy')"        '' bash_guard.sh

# check_file
check to_atom_blocked      2 "$(j "$FIX/bad_to_atom.ex")"       'String.to_atom' check_file.sh
check fragment_blocked     2 "$(j "$FIX/bad_fragment.ex")"      'fragment'       check_file.sh
check redirect_blocked     2 "$(j "$FIX/bad_redirect.ex")"      'redirect'       check_file.sh
check impl_missing_blocked 2 "$(j "$FIX/bad_impl.ex")"          '@impl'          check_file.sh
check impl_ok_allowed      0 "$(j "$FIX/good_impl.ex")"         ''               check_file.sh
check plug_init_allowed    0 "$(j "$FIX/good_plug.ex")"         ''               check_file.sh
check clean_file_allowed   0 "$(j "$FIX/good_clean.ex")"        ''               check_file.sh
check test_file_skipped    0 "$(j "$FIX/skip_test.exs")"        ''               check_file.sh
check non_elixir_skipped   0 "$(j "$FIX/readme.md")"            ''               check_file.sh
check migration_flagged    2 "$(j "$FIX/migrations/20260101000000_bad_migration.exs")" 'on_delete' check_file.sh

echo "pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
