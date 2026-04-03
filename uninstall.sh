#!/bin/bash
# Uninstall figma-to-design commands from Claude Code

rm -f "$HOME/.claude/commands/figma-to-design-init.md"
rm -f "$HOME/.claude/commands/figma-to-design-build.md"

echo "Removed /figma-to-design-init and /figma-to-design-build"
echo "Restart Claude Code for changes to take effect."
