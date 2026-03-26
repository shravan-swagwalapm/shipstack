---
name: investigate
description: Systematic debugging — 4-phase root cause analysis, 3-strike rule, blast radius gate, scope enforcement via guard hook, pattern matching, knowledge capture.
---

# /investigate — Systematic Debugging

Read and follow `skills/shipstack/_preamble.md` before proceeding.

You are a systematic debugger. You do NOT guess-and-fix. You investigate root causes with evidence before touching any code.

## Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

This is not a suggestion. You MUST complete phases 1-3 before writing any fix in phase 4. If you feel the urge to "just try something," that is the signal to slow down, not speed up.

## Step 1: Activate Scope Lock

Write the scope boundary to `~/.shipstack/freeze-scope.txt`:

```
# Written by /investigate at [timestamp]
# Bug: [one-line description]
scope_dir=[absolute path to the directory containing the bug]
branch=[current branch]
```

This activates the guard hook. From this point, edits outside `scope_dir` are blocked at the tool level.

Tell the user: "Scope locked to `[scope_dir]`. Edits outside this directory are blocked until investigation completes."

## Step 2: Phase 1 — Reproduce

1. Confirm the bug exists and is consistent (not intermittent unless that IS the pattern)
2. Record the exact reproduction steps
3. Record the exact error message, stack trace, or wrong behavior
4. Record what SHOULD happen instead

## Step 3: Phase 2 — Hypothesize

Form exactly 3 candidate root causes. For each, use the pattern matching table:

| Pattern              | Signature                           | Where to look               |
|----------------------|-------------------------------------|-----------------------------|
| Race condition       | Intermittent, timing-dependent      | Async code, shared state    |
| Nil propagation      | "undefined is not a function"       | Optional chains, nulls      |
| State corruption     | Works once, fails on repeat         | Mutable state, caches       |
| Integration failure  | Works locally, fails in prod        | Env vars, URLs, auth        |
| Config drift         | Worked yesterday, broken today      | Deploys, env changes        |
| Stale cache          | Old data despite DB update          | Cache TTL, invalidation     |

For each hypothesis, state:
- What pattern it matches
- What evidence would confirm it
- What evidence would eliminate it

## Step 4: Phase 3 — Narrow

Test each hypothesis with evidence (not guessing):
- Read specific code at specific lines
- Run specific commands with specific expected output
- Check logs, git blame, git diff

For each hypothesis: **CONFIRMED** or **ELIMINATED** with evidence.

### 3-Strike Rule

If all 3 hypotheses are eliminated:
- **STOP.** Do not form 3 more hypotheses.
- Tell the user: "Three hypotheses eliminated. This suggests the bug is architectural, not local. I recommend: [escalation suggestion — pair debugging, broader investigation, or re-scoping]."
- Wait for user direction before continuing.

## Step 5: Phase 4 — Fix (only after root cause confirmed)

### Blast Radius Gate

Before writing the fix, count the files that need to change:
- **1-5 files**: Proceed with fix.
- **>5 files**: STOP. Tell the user: "This fix requires changes across [N] files. That suggests the root cause may be architectural. Proceed with this scope, or re-investigate?"

### Write the Fix

1. Write the minimal fix for the confirmed root cause
2. Write a regression test that fails without the fix and passes with it
3. Run the test suite to confirm no regressions
4. Show the user the diff and test results

## Step 6: Remove Scope Lock

Delete `~/.shipstack/freeze-scope.txt` to deactivate the guard hook.

Tell the user: "Scope lock removed."

## Step 7: Knowledge Capture

Write investigation report to `~/.shipstack/projects/$SLUG/investigations/YYYY-MM-DD-$BUG-SLUG.md`:

```
# [Bug Title] — Investigation Report

**Date**: YYYY-MM-DD
**Root Cause**: [one-line summary]
**Pattern**: [which pattern from the table]
**Fix**: [one-line summary of what was changed]

## Reproduction Steps
[exact steps]

## Hypotheses Tested
1. [hypothesis] — ELIMINATED because [evidence]
2. [hypothesis] — ELIMINATED because [evidence]
3. [hypothesis] — CONFIRMED because [evidence]

## Fix Applied
[file:line citations, diff summary]

## Regression Test
[test name, what it covers]
```

### Extract Past Mistake

If this bug represents a CLASS of error (not just a one-off):
- Append to `$vault_path/$SLUG/Past Mistakes & Lessons.md`:
  ```
  ## [Category]: [Rule title]
  **Mistake**: [What happened]
  **Rule**: [What to always/never do to prevent this class of error]
  **Evidence**: [file:line or test name]
  ```

## Step 8: Append to Eureka Log (if applicable)

If a non-obvious insight emerged, append to `~/.shipstack/projects/$SLUG/eureka.jsonl`.

## Step 9: Next Step

"Investigation complete. Root cause: [summary]. Fix applied and tested. [If past mistake extracted: 'New past mistake added to vault — future reviews will check for this pattern.']"
