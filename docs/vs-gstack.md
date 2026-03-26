# shipstack vs gstack

> A respectful comparison. gstack is Garry Tan's AI coding setup (48K+ stars). shipstack takes a different — and now complementary — approach.

## The Core Difference

**gstack** is a stateless sprint engine — 20+ role-based skills that chain via filesystem artifacts. Powerful workflow, but every session starts cold.

**shipstack** is a stateful sprint engine + knowledge OS — 7 pipeline skills that chain via artifacts AND read accumulated knowledge. Every session is smarter than the last.

## Feature Comparison

| Feature | gstack | shipstack v1.0 | shipstack v2.0 |
|---------|--------|---------------|----------------|
| **Pipeline skills** | 20+ role-based skills | None | 7 focused skills |
| **Artifact bus** | `~/.gstack/projects/$SLUG/` | None | `~/.shipstack/projects/$SLUG/` |
| **Knowledge persistence** | None | Past mistakes, decisions, journals | Past mistakes, decisions, journals |
| **Reviews with memory** | Generic review | Write-only | Past-mistakes-as-checklist in every review |
| **Scope enforcement** | Prompt-level | Prompt-level (gears) | Tool-level (PreToolUse guard hook) |
| **Session continuity** | Handoff notes | Session journals | Handoff + vault + pipeline artifacts |
| **Pre-ship quality gate** | Review readiness dashboard | None | Readiness dashboard + staleness detection |
| **Adversarial review** | Yes | No | Yes + informed by past failures |
| **Debugging** | `/investigate` with freeze hooks | Manual | `/investigate` with scope lock + knowledge capture |
| **Retrospective** | Git stats + analytics | Manual | Git stats + knowledge compound rate |
| **Dependencies** | Bun, Playwright | Zero | Zero |
| **Cross-agent** | Claude, Codex, Gemini, Cursor | Claude Code | Claude Code (cross-agent in v3.0) |

## What We Absorbed from gstack

shipstack v2.0 absorbed 7 patterns from gstack:

1. **Filesystem-as-bus pipeline** — skills write artifacts that downstream skills discover
2. **Review JSONL log** — append-only review entries with staleness detection
3. **Scope enforcement via PreToolUse hooks** — physical tool-level blocking, not just prompt
4. **Adversarial spec review loop** — cold subagent reviews with no brainstorming context
5. **Anti-sycophancy worked examples** — concrete BAD/GOOD behavioral templates
6. **Temporal interrogation** — front-load decisions before implementation
7. **Staleness detection** — reviews from Tuesday don't auto-approve Friday's code

## What We Added That gstack Can't

1. **Past-mistakes-as-checklist** — every `/review` checks the diff against every known failure pattern from your vault
2. **Decision record integration** — `/challenge` reads settled decisions and prevents re-debating
3. **Knowledge compound rate** — `/retro` tracks how much your vault grew and whether past mistakes are getting triggered less
4. **Automatic knowledge capture** — `/retro` writes session journals, extracts new past mistakes, and updates decisions to your vault
5. **Session continuity via vault** — not just handoff notes, but full knowledge context

## The Flywheel

```
/review finds bug → /retro captures class → past-mistakes updated →
next /review checks against it → bug class never ships again →
/retro shows compound rate improving → trust in system increases
```

After 50 sessions, every review skill has seen every class of bug your team has ever shipped.

## When to Use What

**Use gstack if**: You want maximum skill coverage out of the box. You work on many short-lived projects. You need cross-agent support (Codex, Gemini, Cursor).

**Use shipstack if**: You're building production software over weeks/months. You want your AI to learn and improve across sessions. You value knowledge compound over tool count.

**Use both**: They're not mutually exclusive. gstack's browser QA + shipstack's knowledge layer is a powerful combo.
