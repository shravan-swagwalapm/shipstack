---
name: ship-feature
description: Full-pipeline orchestrator — design through ship with vault knowledge. Chains superpowers (design, plan, execute) with ShipStack (scope, review, knowledge capture).
user_invocable: true
---

# /ship-feature — Full Pipeline Orchestrator

Read and follow `skills/shipstack/_preamble.md` before proceeding.

You are orchestrating the complete feature pipeline. This skill chains **superpowers** (design, planning, execution) with **ShipStack** (scope, review, knowledge capture) in a single flow with 5 user gates.

**Announce:** "Using /ship-feature to run the full pipeline: design → scope → plan → build → review → ship → learn."

## Flow Overview

```
GATE 1: DESIGN      (Superpowers brainstorming + ShipStack vault)
GATE 2: SCOPE        (ShipStack /challenge)
GATE 3: PLAN         (Superpowers writing-plans + ShipStack /review-plan)
GATE 4: BUILD+REVIEW (Superpowers subagent-driven-dev + ShipStack /review)
GATE 5: SHIP         (ShipStack /ship-check)
AUTO:   LEARN        (ShipStack /retro)
```

---

## GATE 1: DESIGN

Invoke the `superpowers:brainstorming` skill via the Skill tool.

**CRITICAL OVERRIDE:** When brainstorming completes and the spec is written + approved by the user, **do NOT invoke writing-plans.** The brainstorming skill says "The terminal state is invoking writing-plans" — **ignore that instruction.** Instead, return here and proceed to Gate 2.

The vault context loaded by the preamble ($PAST_MISTAKES, $DECISIONS, $LAST_SESSION) is already in your conversation. Superpowers brainstorming will benefit from it automatically — reference past mistakes and decisions when they're relevant during the design discussion.

**Artifact produced:** `docs/superpowers/specs/YYYY-MM-DD-<feature>-design.md`

Store the spec path as `$SPEC_PATH` — downstream gates need it.

**Gate:** After spec is written, self-reviewed, and user-approved → proceed to Gate 2.

---

## GATE 2: SCOPE

Invoke the ShipStack `/challenge` skill via the Skill tool.

Tell the challenge skill: "The design doc is at `$SPEC_PATH`" so it reads the correct file (superpowers writes to `docs/superpowers/specs/`, not `~/.shipstack/projects/$SLUG/designs/`).

The challenge skill will:
- Ask the user to choose a scope mode (EXPAND / SELECTIVE EXPAND / HOLD / REDUCE)
- Run temporal interrogation (what decisions now vs. during implementation?)
- Build an error & rescue map
- Write scope decisions to vault

**Artifact produced:** `~/.shipstack/projects/$SLUG/challenges/YYYY-MM-DD-<feature>.md`

**Gate:** After scope mode is locked and user confirms → proceed to Gate 3.

---

## GATE 3: PLAN

Invoke the `superpowers:writing-plans` skill via the Skill tool.

Provide it with both upstream artifacts:
- Design spec at `$SPEC_PATH`
- Challenge doc at `~/.shipstack/projects/$SLUG/challenges/...`

**CRITICAL OVERRIDE:** When writing-plans finishes the plan, it will offer an execution choice ("Subagent-Driven or Inline Execution?"). **Do NOT follow that prompt.** Instead, return here and run ShipStack's `/review-plan` first.

After the plan is written, invoke ShipStack `/review-plan` via the Skill tool. Tell it where the plan file is. The review-plan skill will:
- Check each planned component against `$PAST_MISTAKES`
- Produce ASCII architecture diagrams
- Build a test coverage matrix
- Flag any BLOCKER/CONCERN/NOTE findings

**Artifacts produced:**
- `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
- `~/.shipstack/projects/$SLUG/plan-reviews/YYYY-MM-DD-<feature>.md`

**Gate:** After plan review passes and user approves → proceed to Gate 4.

If review-plan finds BLOCKERs: fix the plan first, re-run review-plan. Do not proceed with unresolved blockers.

---

## GATE 4: BUILD + REVIEW

### Build

Invoke the `superpowers:subagent-driven-development` skill via the Skill tool.

Provide it the plan file path. It will:
- Dispatch fresh subagent per task
- Run spec compliance review after each task
- Run code quality review after each task
- Commit after each task

**CRITICAL OVERRIDE:** When subagent-driven-development completes all tasks, it will say to use `superpowers:finishing-a-development-branch`. **Do NOT invoke that skill.** Instead, return here and run ShipStack's `/review`.

### Review

Invoke ShipStack `/review` via the Skill tool.

The review skill will:
- Detect scope drift: cross-reference the diff against the design spec (DONE / PARTIAL / NOT DONE / UNPLANNED)
- Run past-mistakes-as-checklist: check every `$PAST_MISTAKES` entry against the diff
- Two-pass review: CRITICAL findings first, then INFORMATIONAL
- Auto-fix obvious issues, batch ASK-level issues for the user
- Write to `reviews.jsonl`

**Gate:** After all findings are resolved → proceed to Gate 5.

If the review finds CRITICAL issues: fix them (dispatch fix subagent or fix directly), then re-run `/review`. Do not proceed with unresolved criticals.

---

## GATE 5: SHIP

Invoke ShipStack `/ship-check` via the Skill tool.

The ship-check skill will:
- Build a readiness dashboard (all gates: design, challenge, plan-review, code-review, tests, past-mistakes)
- Check staleness: compare review commit hash against HEAD
- Run past-mistakes pre-ship sanity check
- Produce GO / NO-GO / RE-REVIEW verdict

**Gate:**
- **GO** → proceed to Learn phase
- **NO-GO** → fix blockers, re-run affected gates
- **RE-REVIEW** → re-run `/review` (commits happened since last review)

---

## AUTO: LEARN

Invoke ShipStack `/retro` via the Skill tool. This runs automatically after GO — no user gate needed.

The retro skill will:
- Detect work sessions from git log
- Aggregate eureka insights from the pipeline
- Write session journal to vault (`$vault_path/$SLUG/Sessions.md`)
- Extract new past mistakes to vault
- Update decisions in vault
- Update `handoff.md` for session continuity
- Calculate knowledge compound rate

---

## Orchestrator Rules

1. **Never skip gates.** Each gate exists because your input changes the outcome at that point.
2. **Never skip the learn phase.** The vault capture is what makes the next `/ship-feature` smarter.
3. **Respect the overrides.** Superpowers skills have their own terminal states — this orchestrator overrides them to insert ShipStack's knowledge phases.
4. **Pass artifact paths explicitly.** The two systems use different artifact locations. Always tell the downstream skill where to find upstream artifacts.
5. **If a gate fails, loop — don't skip.** BLOCKER in plan review → fix plan → re-review. CRITICAL in code review → fix code → re-review. NO-GO in ship-check → fix blockers → re-check.
