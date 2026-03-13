#!/bin/bash
# shipstack: Session End Hook
# Fires when a Claude Code session ends.
# Reminds you to capture learnings before context is lost.
#
# Install: Add to ~/.claude/settings.json under "hooks.SessionEnd"
# See: hooks/settings-snippet.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📓 Session ending — capture your learnings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Before you close this terminal, consider:"
echo "  1. Write a session journal (templates/session-journal.md)"
echo "  2. Extract any mistakes → past-mistakes.md"
echo "  3. Record any architectural decisions → decision-record.md"
echo "  4. Update MEMORY.md if Claude learned something reusable"
echo ""
echo "Your future self will thank you."
echo ""
