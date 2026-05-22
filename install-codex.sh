#!/bin/bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Elixir Phoenix Guide for Codex${NC}"
echo "========================================="
echo ""

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS_DIR="$CODEX_HOME/skills"

if [ ! -d "$SOURCE_DIR/skills" ]; then
  echo -e "${RED}Error: skills directory not found at $SOURCE_DIR/skills${NC}"
  exit 1
fi

echo -e "${YELLOW}Installing skills into $CODEX_SKILLS_DIR...${NC}"
mkdir -p "$CODEX_SKILLS_DIR"

SKILL_COUNT=0
for skill_dir in "$SOURCE_DIR/skills"/*; do
  if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$CODEX_SKILLS_DIR/$skill_name"
    cp "$skill_dir/SKILL.md" "$CODEX_SKILLS_DIR/$skill_name/SKILL.md"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  fi
done

echo -e "${GREEN}Installed $SKILL_COUNT Codex skills${NC}"
echo ""
echo "Installed to: $CODEX_SKILLS_DIR"
echo -e "${YELLOW}Restart Codex to pick up the new skills.${NC}"
