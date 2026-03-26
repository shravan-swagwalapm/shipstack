#!/bin/bash
# shipstack v2.0: Session End Hook
# Fires when a Claude Code session ends.
# Prompts for knowledge capture and suggests /retro.
#
# Install: Add to ~/.claude/settings.json under "hooks.SessionEnd"
# See: hooks/settings-snippet.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  shipstack — Session ending"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Before you close, consider:"
echo "  1. Run /retro to auto-capture learnings to vault"
echo "  2. Or manually:"
echo "     - Write a session journal"
echo "     - Extract mistakes → past-mistakes.md"
echo "     - Record decisions → decision-record.md"
echo ""
echo "Your future self (and your AI CTO) will thank you."
echo ""
