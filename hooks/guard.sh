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

# Get the tool name and file path from the hook input
# Claude Code passes tool info via environment variables
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only gate Edit and Write tools
case "$TOOL_NAME" in
    Edit|Write)
        # Extract file_path from JSON input
        FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('file_path',''))" 2>/dev/null)

        if [ -z "$FILE_PATH" ]; then
            exit 0  # Can't determine path, allow
        fi

        # Resolve to absolute path
        FILE_PATH=$(cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd)/$(basename "$FILE_PATH") 2>/dev/null || FILE_PATH="$FILE_PATH"

        # Check if file is within scope
        case "$FILE_PATH" in
            "$SCOPE_DIR"*)
                exit 0  # Within scope, allow
                ;;
            *)
                echo "BLOCKED by shipstack guard: Edit outside scope."
                echo "  Scope: $SCOPE_DIR"
                echo "  Target: $FILE_PATH"
                echo "  To remove scope lock: delete ~/.shipstack/freeze-scope.txt"
                exit 1  # Outside scope, block
                ;;
        esac
        ;;
    *)
        exit 0  # Not Edit/Write, allow
        ;;
esac
