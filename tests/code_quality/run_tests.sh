#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FIX="$ROOT/tests/code_quality/fixtures"
# Allow pointing the harness at a scratch copy of the script (used to prove
# the assertions actually discriminate against the pre-fix behavior).
SCRIPT="${CODE_QUALITY_SCRIPT:-$ROOT/scripts/code_quality.exs}"
failures=0

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

# 1. Guarded defs must never surface as when/2 (small-body fixture).
OUT=$(elixir "$SCRIPT" all "$FIX/guarded.ex" 2>&1)
echo "$OUT" | grep -q 'when/2' && fail 'guarded defs still parsed as when/2 (guarded.ex)'

# 2. Paren-less pipe calls must count as call sites.
OUT=$(elixir "$SCRIPT" all "$FIX/piped.ex" 2>&1)
echo "$OUT" | grep -qi 'normalize.*never called' && fail 'pipe call not recognized (piped.ex)'

# 3. Discriminating guarded-def fixture: identically-bodied guarded functions
#    under DIFFERENT names (fetch_thing/1 vs load_thing/1), bodies large enough
#    to clear @min_body_size. Pre-fix both parse as when/2 and are falsely
#    reported as duplicates; post-fix no report at all.
OUT=$(elixir "$SCRIPT" all "$FIX/guarded_a.ex" 2>&1)
echo "$OUT" | grep -q 'when/2' && fail 'differently-named guarded defs reported as when/2 duplicates (guarded_a.ex)'

# 4. Same-named guarded duplicates MUST still be reported, under the real
#    name (process_thing/1), never when/2. Proves duplication detection works.
OUT=$(elixir "$SCRIPT" all "$FIX/guarded_c.ex" 2>&1)
echo "$OUT" | grep -q 'process_thing/1' || fail 'real guarded duplicate not reported as process_thing/1 (guarded_c.ex)'
echo "$OUT" | grep -q 'when/2' && fail 'guarded duplicate reported as when/2 instead of process_thing/1 (guarded_c.ex)'

# 5. Call-site regex word boundary: a call to renormalize(...) must not mask
#    a truly-unused defp normalize; renormalize itself is used.
OUT=$(elixir "$SCRIPT" all "$FIX/masked.ex" 2>&1)
echo "$OUT" | grep -q '`normalize` defined' || fail 'unused defp normalize masked by renormalize( call (masked.ex)'
echo "$OUT" | grep -q '`renormalize` defined' && fail 'used defp renormalize falsely reported unused (masked.ex)'

if [ "$failures" -gt 0 ]; then
  echo "$failures assertion(s) failed"
  exit 1
fi
echo PASS
