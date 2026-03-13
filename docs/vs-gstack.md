# shipstack vs gstack

> A respectful comparison. gstack is Garry Tan's AI coding setup. shipstack takes a different approach.

## What gstack Does Well

- **Cognitive modes**: Structured thinking patterns (research → innovate → build → review)
- **Browser automation**: Playwright MCP for visual verification
- **Clear structure**: Well-organized CLAUDE.md with strong principles
- **Community**: Open source with active development

## Where shipstack Differs

| Dimension | gstack | shipstack |
|-----------|--------|-----------|
| **Memory** | None — Claude forgets between sessions | Auto-memory system with YAML frontmatter, persistent across sessions |
| **Past mistakes** | None — same bugs repeat | Mistake → rule extraction system. Claude learns from failures. |
| **Decision records** | None — rationale is lost | ADR templates with options, tradeoffs, consequences |
| **Session journals** | None — context resets | Session journals capture learnings, decisions, next TODOs |
| **Identity** | Defines Claude's expertise areas | Defines the **relationship**: human decides what, Claude decides how |
| **Playbooks** | Not included | Battle-tested patterns for 3 stacks (Next.js, Python AI, Multi-Agent) |
| **Hooks** | Not included | Session start/end hooks wire the system automatically |
| **Evidence** | Review mode checks for issues | Every claim needs evidence — running output, file:line citations |
| **Cognitive gears** | 4 modes (research, innovate, build, review) | 3 gears (SCOPE EXPAND, SCOPE HOLD, SCOPE REDUCE) — never blend |
| **Dependencies** | Playwright MCP, browser tools | Zero dependencies — just markdown + shell scripts |
| **Review** | Single-pass review | Two-pass: CRITICAL first (security, data) → INFORMATIONAL second |

## The Core Difference

gstack is a **tool configuration**. It sets up Claude with good defaults and useful tools.

shipstack is a **knowledge operating system**. It creates a learning loop where every session makes future sessions better.

```
gstack:   Session 1 ──→ Session 2 ──→ Session 3
          (fresh)       (fresh)       (fresh)

shipstack: Session 1 ──→ Journal ──→ Session 2 ──→ Journal ──→ Session 3
           (fresh)       (saved)     (context)     (saved)     (deep context)
```

After 10 sessions with gstack, Claude knows nothing about your project.
After 10 sessions with shipstack, Claude knows your architecture, your past mistakes, your decisions, your patterns, and your preferences.

## When to Use What

**Use gstack if**: You primarily need browser automation and visual QA. You work on many short-lived projects. You prefer tool-based workflows.

**Use shipstack if**: You're building production software over weeks/months. You want Claude to learn and improve across sessions. You value knowledge capture over tool automation.

**Use both**: They're not mutually exclusive. You can use gstack's Playwright MCP setup alongside shipstack's knowledge system. Take what works from each.

## What We Took From gstack

shipstack absorbed two ideas from gstack:

1. **Cognitive modes → Gears**: gstack's research/innovate/build/review modes inspired shipstack's SCOPE EXPAND/HOLD/REDUCE gears. The key difference: gstack's modes are task types, shipstack's gears are scope disciplines.

2. **Explicit review pass**: gstack includes a review mode. shipstack splits this into two passes (CRITICAL → INFORMATIONAL) because mixing security review with style review is how vulnerabilities get missed.
