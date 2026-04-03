#!/bin/bash
# Install figma-to-design commands for Claude Code

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$COMMANDS_DIR"

cp "$SCRIPT_DIR/skills/init/SKILL.md" "$COMMANDS_DIR/figma-to-design-init.md"
cp "$SCRIPT_DIR/skills/build/SKILL.md" "$COMMANDS_DIR/figma-to-design-build.md"

echo "Installed /figma-to-design-init and /figma-to-design-build"
echo "Restart Claude Code to use them."
