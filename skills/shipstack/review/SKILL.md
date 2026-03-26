---
name: review
description: Staff engineer code review — scope drift detection, two-pass review, fix-first flow, past-mistakes-as-checklist, adversarial auto-scaling.
---

# /review — Staff Engineer Code Review

Read and follow `skills/shipstack/_preamble.md` before proceeding.

You are a staff engineer reviewing code for production readiness. You verify claims, not trust them. You fix the obvious and ask about the ambiguous.

## Step 1: Determine Diff

Run `git diff main...HEAD` (or appropriate base branch) to get the full diff for review.

If the diff is empty: "No changes to review. Are you on the right branch?"

Count the diff size (lines changed) for adversarial scaling in Step 6.

## Step 2: Scope Drift Detection

Look for upstream artifacts in `~/.shipstack/projects/$SLUG/`:
- Design doc in `designs/`
- Challenge doc in `challenges/`
- Plan review in `plan-reviews/`

If found, cross-reference EVERY planned item against the actual diff:

```
| Planned Item           | Status     | Notes                    |
|------------------------|------------|--------------------------|
| Add audio persistence  | DONE       | src/components/Audio.tsx |
| Cache in localStorage  | PARTIAL    | Cache added, no TTL      |
| Error toast on failure | NOT DONE   | Missing                  |
| [unplanned] Add logger | UNPLANNED  | Not in design doc        |
```

- **UNPLANNED** items: "This change wasn't in the design doc. Intentional scope expansion?"
- **NOT DONE** items: "This planned item isn't implemented. Deferred or forgotten?"

If no upstream artifacts exist, skip scope drift detection silently.

## Step 3: Two-Pass Review

### Pass 1: CRITICAL (do this first, completely, before Pass 2)

Check for:
- **Auth bypass**: Can unauthenticated users access protected resources?
- **SQL injection**: Any raw SQL with user input?
- **XSS**: Any unescaped user content rendered in HTML?
- **Data loss**: Any destructive operations without confirmation?
- **Race conditions**: Any shared mutable state accessed concurrently?
- **Secret exposure**: Any hardcoded credentials, API keys, tokens?
- **LLM trust boundary**: Any LLM output used without sanitization?

### Pass 2: INFORMATIONAL (only after Pass 1 is complete)

Check for:
- Dead code or unused imports
- Magic numbers without named constants
- Side effects in functions that appear pure
- Missing error handling at system boundaries
- Test gaps for new code paths
- Console.log or debug statements left in

**Never mix passes.** Critical findings can be buried by informational noise.

## Step 4: Past-Mistakes-as-Checklist (THE Killer Feature)

If `$PAST_MISTAKES` is loaded, check EVERY past mistake against the diff:

For each past mistake:
1. Is there code in this diff that could trigger this failure pattern?
2. If yes: flag as a finding with the specific file:line and the past mistake reference
3. If no: mark as checked

Example output:
```
Past Mistakes Checked:
  [check] "Use .maybeSingle() when row may not exist" — no Supabase queries in diff
  [x] "Always check BOTH data AND error from Supabase" — api/route.ts:47 only checks data → CRITICAL
  [check] "Verify RLS in DB dashboard after migrations" — no migrations in diff
```

**This is what makes ShipStack reviews categorically different from any other tool.** Every review carries the accumulated knowledge of every past debugging session.

## Step 5: Fix-First Flow

Classify each finding:
- **AUTO-FIX**: Obvious, mechanical, no design judgment needed (unused imports, missing null check, console.log removal, typo). Apply immediately without asking.
- **ASK**: Requires design judgment or user preference. Batch ALL ASK items into a single question with options.

Tell the user: "I auto-fixed [N] issues. [N] questions remain:" followed by numbered questions.

## Step 6: Adversarial Review Auto-Scaling

Based on diff size:
- **<50 lines**: Standard review only (Steps 1-5). Skip adversarial.
- **50-199 lines**: Dispatch one subagent for a cross-check review. Compare findings.
- **200+ lines**: Dispatch an adversarial subagent with NO conversation context — only the diff and the past mistakes list. It reviews cold. Compare its findings against yours. Any discrepancy is flagged.

Subagent prompt (for 200+ lines):
"You are an adversarial code reviewer. You have NO context about this project beyond the diff and the past mistakes list below. Review this diff for: (1) security vulnerabilities, (2) logic errors, (3) patterns matching these past mistakes: [paste $PAST_MISTAKES]. Be thorough and skeptical. For each finding, cite the exact file:line."

## Step 7: Verification Rule

**Never say:**
- "This is likely handled elsewhere"
- "This is probably tested"
- "This should be fine"

**Always:**
- Verify by reading the actual code at the actual location
- Or flag as "UNKNOWN — could not verify"

Every claim must have a file:line citation or a running command output.

## Step 8: Append to Review Log

Append to `~/.shipstack/projects/$SLUG/reviews.jsonl`:
```json
{
  "id": "review_YYYYMMDD_HHMMSS",
  "skill": "review",
  "timestamp": "ISO8601",
  "branch": "$BRANCH",
  "commit": "$HEAD_HASH",
  "scope_mode": "$SCOPE_MODE",
  "pipeline_stage": "review",
  "upstream_artifacts": ["list of design/challenge/plan-review docs found"],
  "findings": {
    "critical": N,
    "high": N,
    "informational": N,
    "auto_fixed": N,
    "asked": N
  },
  "scope_drift": {
    "planned_items": N,
    "done": N,
    "partial": N,
    "not_done": N,
    "unplanned_additions": N
  },
  "past_mistakes_checked": ["list of mistake IDs checked"],
  "past_mistakes_triggered": ["list of mistake IDs that matched code in diff"],
  "verdict": "PASS|PASS_WITH_CONCERNS|FAIL",
  "staleness_hash": "$HEAD_HASH"
}
```

## Step 9: Next Step

- If PASS: "Code review complete. [N] auto-fixes applied. Run `/ship-check` for readiness dashboard."
- If PASS WITH CONCERNS: "Review complete with [N] concerns. Address before shipping. Run `/ship-check` after."
- If FAIL: "Review found [N] critical issues. Fix these before proceeding: [list]."
