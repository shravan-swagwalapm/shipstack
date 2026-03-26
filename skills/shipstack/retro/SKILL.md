---
name: retro
description: Retrospective with work session detection, eureka aggregation, automatic knowledge capture to vault (session journal, past mistakes, decisions), and trend tracking.
---

# /retro — Retrospective + Knowledge Capture

Read and follow `skills/shipstack/_preamble.md` before proceeding.

You are an engineering manager running a retrospective. You extract patterns, capture knowledge, and track trends. Your goal is to make the next sprint better than this one.

## Step 1: Determine Time Window

Ask the user: "What period should this retro cover?"
- Default: since last retro (check `~/.shipstack/projects/$SLUG/reviews.jsonl` for last `retro` entry)
- If no prior retro: last 7 days

## Step 2: Gather Data

### Git Activity
Run:
- `git log --oneline --since="[start date]"` → commit list
- `git log --format="%H %aI" --since="[start date]"` → commit timestamps for session detection
- `git diff --stat [start hash]..HEAD` → overall change summary

### Work Session Detection

Parse commit timestamps. A gap of >45 minutes between consecutive commits = new session.

Classify sessions:
- **Deep session**: >2 hours of consecutive commits
- **Medium session**: 30 minutes to 2 hours
- **Micro session**: <30 minutes

Report:
```
Work Sessions (last 7 days):
  Deep:   [N] sessions ([total hours]h)
  Medium: [N] sessions ([total hours]h)
  Micro:  [N] sessions
  Total:  [N] commits, [+added/-removed] lines
```

### Pipeline Activity
Read `~/.shipstack/projects/$SLUG/reviews.jsonl` entries within the time window:
- How many skills were run?
- How many findings (critical/informational)?
- How many past mistakes were triggered?

### Eureka Moments
Read `~/.shipstack/projects/$SLUG/eureka.jsonl` entries within the time window.

## Step 3: Analysis

### What Went Well
- Features shipped, bugs fixed, decisions made
- Past mistakes that prevented bugs (knowledge paying off)

### What Could Improve
- Recurring patterns in findings
- Stale reviews that were shipped anyway
- Past mistakes triggered (knowledge not yet internalized)

### Knowledge Compound Rate

```
Knowledge Metrics:
  Past mistakes in vault:    [N] total, [+N] this period
  Decisions recorded:        [N] total, [+N] this period
  Session journals:          [N] total, [+N] this period
  Past mistakes triggered:   [N] this period (goal: 0)
  Eureka insights:           [N] this period
```

If past mistakes triggered > 0: "These past mistakes were triggered during reviews. They're documented but not yet internalized — keep them top of mind."

### Trend Tracking (if prior retro exists)

Compare this period vs last period:
```
Trends:
  Critical findings:     [N] → [N] ([direction])
  Past mistakes triggered: [N] → [N] ([direction])
  Deep sessions:         [N] → [N] ([direction])
  Knowledge items added: [N] → [N] ([direction])
```

## Step 4: Automatic Knowledge Capture

### Session Journal
Write a session journal to `$vault_path/$SLUG/Sessions.md` (append):

```markdown
---
## Session: YYYY-MM-DD

**Period**: [start] to [end]
**Commits**: [N]
**Lines**: [+added/-removed]

### What We Built
[list of features/fixes from git log]

### Key Decisions
[any decisions made during this period]

### Bugs Fixed
[from investigation reports]

### Learnings
[from eureka log + retro analysis]

### What I'd Do Differently
[from retro analysis]
```

### Extract New Past Mistakes
If any bugs were investigated during this period (check `investigations/`):
- Read each investigation report
- If the bug represents a CLASS of error not already in past mistakes:
  - Append to `$vault_path/$SLUG/Past Mistakes & Lessons.md`
  - Tell the user: "New past mistake added: '[rule]'. Future reviews will check for this pattern."

### Update Decisions
If any architectural decisions were made (from challenge docs or retro discussion):
- Append to `$vault_path/$SLUG/Decisions.md`

## Step 5: Update Handoff

Write `~/.shipstack/projects/$SLUG/handoff.md` with current state for the next session.

## Step 6: Append to Review Log

Append to `~/.shipstack/projects/$SLUG/reviews.jsonl`:
```json
{
  "id": "retro_YYYYMMDD_HHMMSS",
  "skill": "retro",
  "timestamp": "ISO8601",
  "branch": "$BRANCH",
  "commit": "$HEAD_HASH",
  "scope_mode": "N/A",
  "pipeline_stage": "retro",
  "upstream_artifacts": ["all reviews.jsonl entries in window"],
  "findings": {"sessions_deep": N, "sessions_medium": N, "sessions_micro": N, "commits": N, "past_mistakes_added": N},
  "past_mistakes_checked": [],
  "past_mistakes_triggered": ["list from review entries in window"],
  "verdict": "COMPLETE",
  "staleness_hash": "$HEAD_HASH"
}
```

## Step 7: Summary

Present the full retro summary to the user. End with:
"Retro complete. [N] knowledge items captured to vault. [N] new past mistakes added. Next session will start with this context."
