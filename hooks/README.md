# Hooks

Hooks are shell commands that Claude Code executes automatically at specific lifecycle events. They're the **wiring** that makes shipstack's knowledge system automatic rather than manual.

## Available Hooks

### `session-start-vault.sh` — Boot Hook
**When**: Every time Claude Code starts a new conversation.
**What it does**:
1. Adds `~/.local/bin` to PATH (for CLI tools)
2. Sets project-specific environment variables
3. Prints a vault reminder so Claude loads context

### `session-end-journal.sh` — End-of-Session Hook
**When**: When a Claude Code session ends.
**What it does**:
1. Reminds you to write a session journal
2. Prompts for mistake extraction and decision records
3. Nudges MEMORY.md updates

## Installation

### 1. Copy hooks to your Claude config directory
```bash
cp hooks/session-start-vault.sh ~/.claude/hooks/
cp hooks/session-end-journal.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

### 2. Add hooks to settings.json
Open `~/.claude/settings.json` and merge the contents of `settings-snippet.json` into your existing hooks configuration.

If you don't have a `settings.json` yet:
```bash
cp hooks/settings-snippet.json ~/.claude/settings.json
```

### 3. Customize
Edit `session-start-vault.sh` to:
- Add your own CLI tools to PATH
- Set project-specific env vars
- Customize the vault reminder message

## How Hooks Work

Claude Code hooks fire at lifecycle events:
- **SessionStart**: When a new conversation begins
- **SessionEnd**: When a conversation ends
- **PreToolCall**: Before a tool is executed
- **PostToolCall**: After a tool completes

Each hook entry has:
- `matcher`: Glob pattern to match (empty = match all)
- `hooks`: Array of commands to run

Commands can:
- Write to `$CLAUDE_ENV_FILE` to inject environment variables
- Print to stdout to send messages to Claude
- Exit with non-zero to block the action (for PreToolCall)

## Writing Custom Hooks

```bash
#!/bin/bash
# Example: Pre-commit hook that reminds about past mistakes
echo "Check past-mistakes.md before committing. Any new lessons?"
```

For more on Claude Code hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
