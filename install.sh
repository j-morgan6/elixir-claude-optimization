#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing Elixir Claude Code Optimization${NC}"
echo "==========================================="
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code CLI not found${NC}"
    echo "Please install Claude Code first: https://claude.ai/download"
    exit 1
fi

# Create Claude directory if it doesn't exist
CLAUDE_DIR="$HOME/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Creating ~/.claude directory...${NC}"
    mkdir -p "$CLAUDE_DIR"
fi

# Detect if running from git clone or curl
if [ -d "$(dirname "$0")/skills" ]; then
    # Running from cloned repo
    SOURCE_DIR="$(dirname "$0")"
    echo -e "${GREEN}Installing from local repository...${NC}"
else
    # Running from curl, need to download
    echo -e "${GREEN}Downloading from GitHub...${NC}"
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    REPO_URL="https://github.com/j-morgan6/elixir-claude-optimization"

    if command -v git &> /dev/null; then
        git clone "$REPO_URL" .
    else
        echo -e "${RED}Error: git not found and running from curl${NC}"
        echo "Please install git or clone the repository manually"
        exit 1
    fi

    SOURCE_DIR="$TEMP_DIR"
fi

# Install skills
echo -e "${YELLOW}Installing skills...${NC}"
mkdir -p "$CLAUDE_DIR/skills"
cp -r "$SOURCE_DIR/skills/"* "$CLAUDE_DIR/skills/"
echo -e "${GREEN}✓ Installed 4 skills${NC}"

# Install hooks
echo -e "${YELLOW}Installing hooks...${NC}"
mkdir -p "$CLAUDE_DIR/hooks"
cp -r "$SOURCE_DIR/hooks/"* "$CLAUDE_DIR/hooks/"
echo -e "${GREEN}✓ Installed 5 hooks${NC}"

# Install agent documentation
echo -e "${YELLOW}Installing agent documentation...${NC}"
mkdir -p "$CLAUDE_DIR/agents"
cp -r "$SOURCE_DIR/agents/"* "$CLAUDE_DIR/agents/"
echo -e "${GREEN}✓ Installed 4 agent docs${NC}"

# Copy CLAUDE.md template to current directory (optional)
if [ ! -f "CLAUDE.md" ] && [ -f "$SOURCE_DIR/CLAUDE.md.template" ]; then
    echo -e "${YELLOW}Would you like to copy CLAUDE.md template to current directory? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cp "$SOURCE_DIR/CLAUDE.md.template" "./CLAUDE.md"
        echo -e "${GREEN}✓ CLAUDE.md template copied (edit for your project)${NC}"
    fi
fi

# Cleanup if we downloaded
if [ "$SOURCE_DIR" = "$TEMP_DIR" ]; then
    cd ~
    rm -rf "$TEMP_DIR"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Installed components:"
echo "  • 4 Skills (elixir-patterns, phoenix-liveview, ecto-database, error-handling)"
echo "  • 5 Hooks (nested-if-else, hardcoded-config, inefficient-enum, missing-impl, string-concatenation)"
echo "  • 4 Agent docs (project-structure, liveview-checklist, ecto-conventions, testing-guide)"
echo ""
echo "These customizations will apply to all your Elixir projects."
echo ""
echo "Optional: Copy CLAUDE.md.template to your project root and customize it:"
echo "  cp ~/.claude/agents/../CLAUDE.md.template /path/to/your/project/CLAUDE.md"
echo ""
echo -e "${YELLOW}Restart Claude Code to load the new configuration.${NC}"
