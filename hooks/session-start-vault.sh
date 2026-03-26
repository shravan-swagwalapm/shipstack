#!/bin/bash
# shipstack v2.0: Session Start Hook
# Fires when Claude Code starts a new conversation.
# Injects environment, reads pipeline state, reminds to load context.
#
# Install: Add to ~/.claude/settings.json under "hooks.SessionStart"
# See: hooks/settings-snippet.json

# Add local binaries to PATH
echo "export PATH=\$HOME/.local/bin:\$PATH" >> "$CLAUDE_ENV_FILE"

# Ensure shipstack directory exists
mkdir -p "$HOME/.shipstack/projects" "$HOME/.shipstack/analytics"

# Detect project slug from git remote or directory name
SLUG=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    REMOTE=$(git remote get-url origin 2>/dev/null)
    if [ -n "$REMOTE" ]; then
        SLUG=$(basename "$REMOTE" .git)
    fi
fi
if [ -z "$SLUG" ]; then
    SLUG=$(basename "$(pwd)")
fi

# Export slug for Claude
echo "export SHIPSTACK_SLUG=$SLUG" >> "$CLAUDE_ENV_FILE"

# Check for handoff from prior session
HANDOFF="$HOME/.shipstack/projects/$SLUG/handoff.md"
if [ -f "$HANDOFF" ]; then
    echo "shipstack: Prior session handoff found for '$SLUG'."
    echo "Read ~/.shipstack/projects/$SLUG/handoff.md to resume where you left off."
else
    echo "shipstack: No prior handoff for '$SLUG'. Fresh session."
fi

# Check for active scope lock
if [ -f "$HOME/.shipstack/freeze-scope.txt" ]; then
    SCOPE_DIR=$(grep "^scope_dir=" "$HOME/.shipstack/freeze-scope.txt" | cut -d'=' -f2-)
    echo "WARNING: Scope lock active from prior /investigate session. Scope: $SCOPE_DIR"
    echo "Delete ~/.shipstack/freeze-scope.txt to clear."
fi

# Vault reminder
echo "Vault available. Remember to read vault context for the active project before starting work."
echo "Pipeline skills available: /brainstorm /challenge /review-plan /investigate /review /ship-check /retro"
