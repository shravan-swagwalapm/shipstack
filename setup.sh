#!/bin/bash
# shipstack v2.0 setup — Stateful Sprint Engine + Knowledge OS
# https://github.com/shravan-swagwalapm/shipstack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHIPSTACK_DIR="$HOME/.shipstack"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  shipstack v2.0 — Stateful Sprint Engine"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: CLAUDE.md
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "Found existing CLAUDE.md — backing up to CLAUDE.md.backup"
    cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup"
fi

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "[1/6] CLAUDE.md installed"

# Step 2: Templates
TEMPLATE_DIR="$CLAUDE_DIR/templates/shipstack"
mkdir -p "$TEMPLATE_DIR/memory"
cp "$SCRIPT_DIR/templates/"*.md "$TEMPLATE_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/templates/memory/"*.md "$TEMPLATE_DIR/memory/" 2>/dev/null || true
echo "[2/6] Templates installed"

# Step 3: Hooks
HOOKS_DIR="$CLAUDE_DIR/hooks"
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/session-start-vault.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/session-end-journal.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/guard.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/"*.sh
echo "[3/6] Hooks installed (session-start, session-end, guard)"

# Step 4: Skills (symlink)
SKILLS_DIR="$CLAUDE_DIR/skills/shipstack"
if [ -L "$SKILLS_DIR" ]; then
    rm "$SKILLS_DIR"  # Remove old symlink
fi
if [ -d "$SKILLS_DIR" ]; then
    echo "Found existing skills dir — backing up to skills-shipstack.backup"
    mv "$SKILLS_DIR" "$CLAUDE_DIR/skills/shipstack.backup"
fi
mkdir -p "$CLAUDE_DIR/skills"
ln -s "$SCRIPT_DIR/skills/shipstack" "$SKILLS_DIR"
echo "[4/6] Skills symlinked ($SKILLS_DIR → $SCRIPT_DIR/skills/shipstack)"

# Step 5: Pipeline directory (~/.shipstack/)
mkdir -p "$SHIPSTACK_DIR/projects" "$SHIPSTACK_DIR/analytics"

# Create default config if none exists
if [ ! -f "$SHIPSTACK_DIR/config.yaml" ]; then
    cat > "$SHIPSTACK_DIR/config.yaml" << 'YAML'
# shipstack v2.0 configuration
# See: https://github.com/shravan-swagwalapm/shipstack

# Path to your knowledge vault (Obsidian, plain markdown, etc.)
# Skills read past mistakes, decisions, and session journals from here.
vault_path: ~/knowledge

# Default scope mode for new sessions (EXPAND, SELECTIVE, HOLD, REDUCE)
default_scope_mode: HOLD

# Enable PreToolUse guard hook for scope enforcement
guard_enabled: true
YAML
    echo "[5/6] Pipeline directory created with default config"
else
    echo "[5/6] Pipeline directory exists — config preserved"
fi

# Step 6: Summary
echo "[6/6] Setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Edit ~/.shipstack/config.yaml:"
echo "     Set vault_path to your knowledge folder"
echo "     (e.g., ~/ProductBrain/Projects or ~/my-project/knowledge)"
echo ""
echo "  2. Add hooks to ~/.claude/settings.json:"
echo "     Merge the contents of hooks/settings-snippet.json"
echo ""
echo "  3. Start a session and try the pipeline:"
echo "     /brainstorm → /challenge → /review-plan → [build] → /review → /ship-check → /retro"
echo ""
echo "  Skills available: /brainstorm /challenge /review-plan /investigate /review /ship-check /retro"
echo ""
echo "For more: https://github.com/shravan-swagwalapm/shipstack"
echo ""
