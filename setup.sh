#!/bin/bash
# shipstack setup — Knowledge OS for AI-Assisted Development
# https://github.com/shravan-swagwalapm/shipstack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 shipstack — Knowledge OS Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: CLAUDE.md
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "⚠️  Found existing CLAUDE.md at $CLAUDE_DIR/CLAUDE.md"
    echo "   Backing up to CLAUDE.md.backup"
    cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup"
fi

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "✅ CLAUDE.md installed to $CLAUDE_DIR/"

# Step 2: Templates
TEMPLATE_DIR="$CLAUDE_DIR/templates/shipstack"
mkdir -p "$TEMPLATE_DIR/memory"
cp "$SCRIPT_DIR/templates/"*.md "$TEMPLATE_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/templates/memory/"*.md "$TEMPLATE_DIR/memory/" 2>/dev/null || true
echo "✅ Templates installed to $TEMPLATE_DIR/"

# Step 3: Hooks
HOOKS_DIR="$CLAUDE_DIR/hooks"
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/session-start-vault.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/session-end-journal.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/"*.sh
echo "✅ Hooks installed to $HOOKS_DIR/"

# Step 4: Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit ~/.claude/CLAUDE.md to customize for your style"
echo ""
echo "  2. Add hooks to your settings.json:"
echo "     Open ~/.claude/settings.json and merge the contents of"
echo "     hooks/settings-snippet.json into your hooks configuration."
echo ""
echo "  3. Create your first project vault:"
echo "     mkdir -p ~/ProductBrain/Projects/YourProject"
echo "     cp templates/shipstack/past-mistakes.md ~/ProductBrain/Projects/YourProject/"
echo "     cp templates/shipstack/project-claude.md ~/your-project/CLAUDE.md"
echo ""
echo "  4. Start a Claude Code session and watch the magic:"
echo "     cd ~/your-project && claude"
echo ""
echo "For more: https://github.com/shravan-swagwalapm/shipstack"
echo ""
