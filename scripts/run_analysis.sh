#!/bin/bash
# Full Project Code Quality Analysis
# Runs all code quality checks across the entire project.
#
# Usage:
#   run_analysis.sh [directory]   — defaults to current directory

DIR="${1:-.}"
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
EXIT_CODE=0

if [ ! -d "$DIR/lib" ]; then
  echo "No lib/ directory found. Run from an Elixir project root."
  exit 1
fi

echo "Elixir Phoenix Guide — Code Quality Analysis"
echo "============================================="
echo ""

# Run Elixir code analysis
if command -v elixir >/dev/null 2>&1; then
  echo "Analyzing Elixir files..."
  elixir "$SCRIPTS_DIR/code_quality.exs" scan "$DIR/lib"
  if [ $? -ne 0 ]; then
    EXIT_CODE=1
  fi
else
  echo "Elixir not found. Skipping code analysis."
fi

echo ""
echo "Analysis complete."
exit $EXIT_CODE
