#!/bin/bash
# shipstack: Guard Hook (PreToolUse)
# Enforces scope boundaries during /investigate and other skills.
# Blocks Edit/Write operations outside the declared scope directory.
#
# Install: Add to ~/.claude/settings.json under "hooks.PreToolUse"
# See: hooks/settings-snippet.json

FREEZE_FILE="$HOME/.shipstack/freeze-scope.txt"

# If no freeze file exists, allow everything
if [ ! -f "$FREEZE_FILE" ]; then
    exit 0
fi

# Read the scope directory from freeze file
SCOPE_DIR=$(grep "^scope_dir=" "$FREEZE_FILE" | cut -d'=' -f2-)

# If scope_dir is empty or not set, allow everything
if [ -z "$SCOPE_DIR" ]; then
    exit 0
fi

# Check if guard is disabled in config
CONFIG_FILE="$HOME/.shipstack/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    GUARD_ENABLED=$(grep "^guard_enabled:" "$CONFIG_FILE" | awk '{print $2}')
    if [ "$GUARD_ENABLED" = "false" ]; then
        exit 0
    fi
fi

# Read hook input from stdin (Claude Code passes JSON via stdin)
INPUT=$(cat)

# Extract file_path from JSON input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0  # Can't determine path, allow
fi

# Check if file is within scope
case "$FILE_PATH" in
    "$SCOPE_DIR"*)
        exit 0  # Within scope, allow
        ;;
    *)
        # Output JSON to block the operation
        cat <<BLOCK
{"decision":"block","reason":"BLOCKED by shipstack guard: Edit outside scope.\n  Scope: $SCOPE_DIR\n  Target: $FILE_PATH\n  To remove scope lock: delete ~/.shipstack/freeze-scope.txt"}
BLOCK
        exit 0
        ;;
esac
