#!/usr/bin/env bash
# Regenerates the Copilot port from the canonical skills/scripts.
# Instruction files keep their existing applyTo frontmatter; bodies are
# replaced with the corresponding SKILL.md body (first frontmatter block stripped).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/copilot/.github/instructions"

# extract_frontmatter FILE -> prints the first ---...--- block inclusive
extract_frontmatter() {
  awk 'NR==1 && /^---$/ {infm=1; print; next}
       infm && /^---$/ {print; exit}
       infm {print}' "$1"
}

# extract_body FILE -> prints everything AFTER the first frontmatter block
extract_body() {
  awk 'NR==1 && /^---$/ {infm=1; next}
       infm && /^---$/ {infm=0; body=1; next}
       infm {next}
       body {print}' "$1"
}

for skill_dir in "$ROOT"/skills/*/; do
  name=$(basename "$skill_dir")
  src="$skill_dir/SKILL.md"
  dst="$DEST/$name.instructions.md"
  if [ ! -f "$dst" ]; then
    echo "SKIP $name (no instruction file — create it manually with an applyTo header)" >&2
    continue
  fi
  { extract_frontmatter "$dst"; extract_body "$src"; } > "$dst.tmp"
  mv "$dst.tmp" "$dst"
  echo "synced $name"
done

for s in code_quality.exs detect_project.sh run_analysis.sh; do
  [ -f "$ROOT/scripts/$s" ] && cp "$ROOT/scripts/$s" "$ROOT/copilot/scripts/$s" && echo "copied $s"
done

echo "Done. Review with: cd copilot && git diff"
