# shipstack

> Your AI coding tool forgets everything between sessions. Mine doesn't.

**shipstack** is a stateful sprint engine + knowledge OS for AI-assisted development. It turns Claude Code from a stateless tool into a learning partner with a full workflow pipeline that gets smarter with every session.

I built 4 production products with this system — an education platform, a content engine with 5 autonomous agents, a RAG pipeline with 160K+ vectors, and a video production pipeline. Every pattern in this repo is battle-tested.

## What is this?

Most AI coding setups focus on tools — browser automation, linting, testing. shipstack focuses on **knowledge**:

- **Memory** that persists across sessions
- **Past mistakes** that prevent the same class of bug twice
- **Decision records** that capture why, not just what
- **Session journals** that give your next session full context
- **Playbooks** with production-tested code snippets

Zero dependencies. Just markdown files and shell scripts. No Obsidian required — it's just folders of `.md` files.

## What's New in v2.0: Pipeline Skills

v2.0 adds 7 pipeline skills that chain together via filesystem artifacts. Every skill reads your accumulated knowledge (past mistakes, decisions) and writes pipeline artifacts for downstream skills.

```
/brainstorm ──→ /challenge ──→ /review-plan ──→ [BUILD] ──→ /review ──→ /ship-check ──→ /retro
                                                   ↑                         ↑
                                              /investigate              /guard (hook)
```

| Skill | Role | What It Does |
|-------|------|-------------|
| `/brainstorm` | Product Thinker | 6 forcing questions, adversarial spec review, anti-sycophancy |
| `/challenge` | CEO/Founder | 4 scope modes, temporal interrogation, expansion ceremony |
| `/review-plan` | Eng Manager | ASCII diagrams, test matrix, past-mistakes injection |
| `/investigate` | Debugger | 4-phase root cause, 3-strike rule, scope lock via guard hook |
| `/review` | Staff Engineer | Scope drift detection, past-mistakes-as-checklist, adversarial scaling |
| `/ship-check` | Release Engineer | Readiness dashboard, staleness detection, GO/NO-GO |
| `/retro` | Eng Manager | Session detection, eureka aggregation, auto knowledge capture |

The key differentiator: **every skill reads past mistakes from your vault.** A code review that knows "we got burned by `.single()` last month" is categorically different from a generic review.

```
gstack:     Session 1 → Session 2 → Session 3 (all fresh, same quality)
shipstack:  Session 1 → Session 2 → Session 3 (each session smarter than the last)
```

## shipstack vs gstack

[Garry Tan's gstack](https://github.com/garrytan/gstack) is a great AI coding setup. Here's where shipstack differs:

| Dimension | gstack | shipstack |
|-----------|--------|-----------|
| **Memory** | None — Claude forgets between sessions | Auto-memory with YAML frontmatter, persistent across sessions |
| **Past mistakes** | None — same bugs repeat | Mistake → rule extraction. Claude learns from failures. |
| **Decision records** | None — rationale is lost | ADR templates with options, tradeoffs, consequences |
| **Session journals** | None — context resets every time | Journals capture learnings, decisions, next TODOs |
| **Identity** | Defines Claude's expertise | Defines the **relationship**: human decides what, Claude decides how |
| **Playbooks** | Not included | Battle-tested patterns for 3 stacks |
| **Hooks** | Not included | Session start/end hooks wire the system automatically |
| **Evidence** | Review mode | Every claim needs evidence — running output, file:line citations |
| **Cognitive gears** | 4 modes (research, innovate, build, review) | 3 gears (SCOPE EXPAND, HOLD, REDUCE) — never blend |
| **Dependencies** | Playwright MCP, browser tools | Zero — just markdown + shell scripts |
| **Review** | Single-pass | Two-pass: CRITICAL first → INFORMATIONAL second |

```
gstack:    Session 1 → Session 2 → Session 3
           (fresh)     (fresh)     (fresh)

shipstack: Session 1 → Journal → Session 2 → Journal → Session 3
           (fresh)     (saved)   (context)   (saved)   (deep context)
```

> [Detailed comparison →](docs/vs-gstack.md)

## The CLAUDE.md

The heart of shipstack is a 74-line `CLAUDE.md` that defines how Claude operates:

```markdown
# Identity
Your CTO. You (the human) decide what. Claude decides how and holds the bar.
Push back with data, not opinion. Lead with recommendation + tradeoffs.

# Think → Build → Prove
Gears (never blend): SCOPE EXPAND → SCOPE HOLD → SCOPE REDUCE

1. Load context — vault, past mistakes, project CLAUDE.md
2. Challenge the ask — right problem? right time?
3. Map the system — boundaries, data flows, failure modes
4. Plan — gear: SCOPE HOLD. Only build what was asked.
5. Build in stages — verify each step
6. Prove — every claim needs evidence

# Priority
Correct → Simple → Maintainable → Fast → Elegant (strict order)

# Quality Bar
- Review (two-pass): CRITICAL first → INFORMATIONAL second
- Ship check: scale? zero? malice? reversible? 6-month maintainability?
```

> [Full CLAUDE.md →](CLAUDE.md) · [Philosophy behind each principle →](docs/philosophy.md)

## The Memory System

Claude Code has built-in auto-memory. shipstack structures it with YAML frontmatter and an index file. No Obsidian needed — this is just Claude Code's native memory system with better organization:

```markdown
# MEMORY.md (always in context)
## Project: My App
- [Current sprint focus](memory/project_status.md)
- [User preferences](memory/user_role.md)
- [Testing corrections](memory/feedback_testing.md)
```

Each memory file has a type (`user`, `feedback`, `project`, `reference`) and a description that helps Claude decide when to load it:

```yaml
---
name: feedback_testing
description: Integration tests must use real database, not mocks
type: feedback
---
Integration tests must hit a real database, not mocks.
**Why:** Mock/prod divergence masked a broken migration.
**How to apply:** Use a test database with real migrations. Reserve mocks for external APIs only.
```

> [Memory templates →](templates/MEMORY.md)

## The Past Mistakes System

This is shipstack's superpower. Every bug becomes a rule that prevents the **class** of error:

```markdown
## Auth Bugs
- Admin users had wrong role in legacy table → **Always check ALL role storage locations**
- RLS disabled despite migration defining it → **ALWAYS verify in DB dashboard after migrations**

## API & Network
- 11 parallel fetches, no timeouts → **Use BFF routes for dashboards (1 request, server-side parallelism)**
- Supabase returns errors as data, not exceptions → **Always check BOTH data AND error fields**
```

After 50 sessions, your past mistakes file is a goldmine. Claude reads it at session start and avoids every documented class of error automatically.

> [Real examples (anonymized) →](examples/past-mistakes-real.md)

## Playbooks

Production-tested patterns with copy-paste code snippets:

| Playbook | What You Get |
|----------|-------------|
| [Next.js + Supabase](playbooks/nextjs-supabase.md) | BFF routes, `.maybeSingle()`, error states, SWR caching, security checklist |
| [Python AI/RAG](playbooks/python-ai-rag.md) | FAISS queries, cache-first pipeline, voice synthesis via HTTP |
| [Multi-Agent Systems](playbooks/multi-agent-system.md) | Model-to-task matching, config-level delegation control, cost rails |

## Hooks

Hooks wire the knowledge system into Claude Code's lifecycle:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "bash ~/.claude/hooks/session-start-vault.sh"
      }]
    }]
  }
}
```

- **Session start**: Injects PATH, sets env vars, reminds Claude to load vault context
- **Session end**: Prompts you to capture learnings before context is lost
- **Guard hook** (v2.0): PreToolUse hook that blocks edits outside declared scope during `/investigate`

> [Hook setup guide →](hooks/README.md)

## Demo

See the full shipstack loop in action — from boot to ship:

1. Boot → hook fires, vault reminder
2. Context load → past mistakes, last session journal
3. Challenge → Claude pushes back on scope
4. Gear: SCOPE HOLD → plan mode
5. Build → step-by-step with verification
6. Prove → evidence (running output, file:line)
7. Review → two-pass (CRITICAL → INFORMATIONAL)
8. Ship check → scale/zero/malice/reversibility
9. Session journal → learnings captured
10. Past mistakes → new rule extracted

> [Full demo transcript →](examples/demo-session.md)

## Install

### One-command setup
```bash
git clone https://github.com/shravan-swagwalapm/shipstack.git
cd shipstack
chmod +x setup.sh
./setup.sh
```

### Manual setup
1. Copy `CLAUDE.md` to `~/.claude/CLAUDE.md`
2. Copy `templates/` to `~/.claude/templates/shipstack/`
3. Copy `hooks/*.sh` to `~/.claude/hooks/` and `chmod +x`
4. Merge `hooks/settings-snippet.json` into `~/.claude/settings.json`
5. Create your project knowledge folder: `mkdir -p ~/projects/YourProject/knowledge` (or use Obsidian, Notion, any folder — it's just markdown files)
6. Skills are auto-symlinked by `setup.sh`. To update: `cd shipstack && git pull`

### Customize
- Edit `CLAUDE.md` to match your style and priorities
- Add project-specific patterns to `templates/project-claude.md`
- Write your first session journal after your next Claude session

## Philosophy

Every principle in shipstack has a reason:

- **Why "Correct → Simple → Maintainable → Fast → Elegant"** in that exact order
- **Why cognitive gears** and why you must never blend them
- **Why evidence-first** — confident assertions without proof are lies
- **Why past mistakes > documentation** — docs describe intentions, mistakes describe reality
- **Why zero dependencies** — the most reliable software is plain text

> [Deep dive →](docs/philosophy.md)

## Structure

```
shipstack/
├── CLAUDE.md                    # The enhanced global CLAUDE.md
├── setup.sh                     # One-command install (v2.0)
├── skills/
│   └── shipstack/
│       ├── _preamble.md         # Shared: config, slug, vault loading
│       ├── brainstorm/SKILL.md  # Design thinking + adversarial review
│       ├── challenge/SKILL.md   # Scope modes + temporal interrogation
│       ├── review-plan/SKILL.md # Eng review + test matrix
│       ├── investigate/SKILL.md # 4-phase debugging + scope lock
│       ├── review/SKILL.md      # Code review + past-mistakes checklist
│       ├── ship-check/SKILL.md  # Readiness dashboard + staleness
│       └── retro/SKILL.md       # Retrospective + knowledge capture
├── templates/
│   ├── MEMORY.md                # Memory index template
│   ├── handoff.md               # Session handoff template (v2.0)
│   ├── memory/                  # Example memory files
│   ├── session-journal.md       # Session journal template
│   ├── decision-record.md       # ADR template
│   ├── past-mistakes.md         # Mistake → rule template
│   └── project-claude.md        # Per-project CLAUDE.md template
├── hooks/
│   ├── session-start-vault.sh   # Boot hook (v2.0: handoff + pipeline context)
│   ├── session-end-journal.sh   # End-of-session hook (v2.0: suggests /retro)
│   ├── guard.sh                 # PreToolUse scope enforcement (v2.0)
│   └── settings-snippet.json    # Copy-paste for settings.json
├── playbooks/                   # Production-tested patterns
├── examples/                    # Real-world usage (anonymized)
└── docs/
    ├── philosophy.md            # Deep "why" behind each principle
    └── vs-gstack.md             # Direct comparison
```

## License

MIT — take what works, make it yours.

---

Built by [Shravan Tickoo](https://linkedin.com/in/shravantickoo). Star it, fork it, ship with it.
