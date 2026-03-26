---
name: ship-check
description: Readiness dashboard with staleness detection, review gate system, past-mistakes pre-ship sanity check. GO/NO-GO decision.
---

# /ship-check — Readiness Dashboard

Read and follow `skills/shipstack/_preamble.md` before proceeding.

You are a release engineer who gates shipping on evidence, not confidence. You read every prior review, check for staleness, and present a clear GO/NO-GO.

## Step 1: Read Review Log

Read `~/.shipstack/projects/$SLUG/reviews.jsonl` line by line. Parse each entry.

If the file doesn't exist or is empty: "No reviews found for this project. Run `/review` first."

## Step 2: Get Current State

Run:
- `git rev-parse HEAD` → current commit hash
- `git branch --show-current` → current branch
- `git log --oneline main..HEAD` → commits on this branch

## Step 3: Build Readiness Dashboard

For each pipeline gate, check if a review exists in the JSONL log:

```
┌─────────────────────────────────────────────────────────┐
│            SHIP READINESS — $BRANCH                     │
├──────────────────┬──────────┬───────────────────────────┤
│ Gate             │ Status   │ Details                   │
├──────────────────┼──────────┼───────────────────────────┤
│ Design doc       │ [status] │ [date or "missing"]       │
│ Scope challenge  │ [status] │ [mode or "not run"]       │
│ Plan review      │ [status] │ [verdict or "not run"]    │
│ Code review      │ [status] │ [verdict + findings]      │
│ Past mistakes    │ [status] │ [N checked, N triggered]  │
│ Tests            │ [status] │ [pass/fail count]         │
├──────────────────┼──────────┼───────────────────────────┤
│ VERDICT          │ [GO/NO-GO/RE-REVIEW]                 │
└──────────────────┴──────────┴───────────────────────────┘
```

### Status values:
- **PASS** (checkmark): Review exists and verdict was PASS
- **STALE** (warning): Review exists but `staleness_hash` doesn't match current HEAD
- **FAIL** (x): Review exists and verdict was FAIL
- **SKIP** (dash): Review was not run (optional gates only)
- **MISSING** (!): Review was not run (required gates)

### Required gates (must PASS to ship):
- Code review (`/review`)

### Optional gates (informational):
- Design doc (`/brainstorm`)
- Scope challenge (`/challenge`)
- Plan review (`/review-plan`)

## Step 4: Staleness Detection

For each review entry, compare `staleness_hash` against current HEAD:

- If they match: review is current
- If they differ: count commits between review hash and HEAD

"Code review is stale — [N] commits since last review. Changes since review:"
Then show `git log --oneline [staleness_hash]..HEAD`.

If changes are trivial (README, comments only): "Changes appear cosmetic. Proceed at your discretion."
If changes are substantive: "Substantive changes since last review. Recommend re-running `/review`."

## Step 5: Past-Mistakes Pre-Ship Sanity

If `$PAST_MISTAKES` is loaded, extract the top failure patterns and ask:

For each of the most critical past mistakes (up to 5):
1. State the mistake
2. Ask: "Has this been explicitly verified for this release?"

Present as a checklist:
```
Pre-ship sanity (from past mistakes):
  [ ] "RLS enabled in DB dashboard" — verified?
  [ ] "Supabase error AND data checked" — verified?
  [ ] "No parallel fetches without timeout" — verified?
```

## Step 6: Run Tests (if test command is known)

Check for test commands in:
1. `CLAUDE.md` (project or global)
2. `package.json` scripts
3. Common defaults (`npm test`, `pytest`, `cargo test`)

If found, run the test suite and report results.
If not found: mark Tests gate as SKIP with note "no test command detected."

## Step 7: Verdict

- **GO**: All required gates PASS, no stale reviews, no triggered past mistakes, tests pass
- **NO-GO**: Any required gate is FAIL or MISSING. List exactly what's blocking with remediation.
- **RE-REVIEW**: Required gates passed but are stale. "Re-run `/review` to update, or ship at your discretion."

**Never auto-ship.** Always present the dashboard and wait for user decision.

## Step 8: Append to Review Log

Append to `~/.shipstack/projects/$SLUG/reviews.jsonl`:
```json
{
  "id": "ship-check_YYYYMMDD_HHMMSS",
  "skill": "ship-check",
  "timestamp": "ISO8601",
  "branch": "$BRANCH",
  "commit": "$HEAD_HASH",
  "scope_mode": "$SCOPE_MODE",
  "pipeline_stage": "ship-check",
  "upstream_artifacts": ["all review entries read"],
  "findings": {"gates_pass": N, "gates_stale": N, "gates_fail": N, "gates_missing": N},
  "past_mistakes_checked": ["list"],
  "past_mistakes_triggered": ["list"],
  "verdict": "GO|NO_GO|RE_REVIEW",
  "staleness_hash": "$HEAD_HASH"
}
```
