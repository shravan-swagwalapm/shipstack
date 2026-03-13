#!/bin/bash
# shipstack: Session Start Hook
# Fires when Claude Code starts a new conversation.
# Injects environment variables and reminds Claude to load project context.
#
# Install: Add to ~/.claude/settings.json under "hooks.SessionStart"
# See: hooks/settings-snippet.json

# Add local binaries to PATH (for CLI tools like obsidian, railway, etc.)
echo "export PATH=\$HOME/.local/bin:\$PATH" >> "$CLAUDE_ENV_FILE"

# Set project-specific environment variables
# Uncomment and customize:
# echo "export OBS=obsidian" >> "$CLAUDE_ENV_FILE"
# echo "export PROJECT_ROOT=\$HOME/my-project" >> "$CLAUDE_ENV_FILE"

# Remind Claude to load vault context
echo "Vault available. Remember to read vault context for the active project before starting work."
