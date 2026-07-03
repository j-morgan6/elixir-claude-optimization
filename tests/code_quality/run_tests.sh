#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT=$(elixir "$ROOT/scripts/code_quality.exs" all "$ROOT/tests/code_quality/fixtures/guarded.ex" 2>&1)
echo "$OUT" | grep -q 'when/2' && { echo 'FAIL: guarded defs still parsed as when/2'; exit 1; }
OUT=$(elixir "$ROOT/scripts/code_quality.exs" all "$ROOT/tests/code_quality/fixtures/piped.ex" 2>&1)
echo "$OUT" | grep -qi 'normalize.*never called' && { echo 'FAIL: pipe call not recognized'; exit 1; }
echo PASS
