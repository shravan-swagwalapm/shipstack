# Philosophy

> Why shipstack works the way it does. Every principle has a reason.

## Why "Correct → Simple → Maintainable → Fast → Elegant"

This is a strict ordering, not a wishlist. Here's why:

**Correct** comes first because nothing else matters if it's wrong. A fast, elegant solution that produces incorrect results is worse than a slow, ugly one that works. This seems obvious, but under deadline pressure, correctness is the first casualty.

**Simple** beats complex because simplicity is a feature. Simple code has fewer bugs, is easier to review, and is faster to change. When two correct solutions exist, pick the simpler one — even if it means duplicating a few lines instead of creating an abstraction.

**Maintainable** means someone else (including future you) can understand and modify this code. This means clear naming, obvious data flow, and minimal indirection. If you need a comment to explain what code does, the code should be rewritten.

**Fast** comes fourth because premature optimization is real. Make it correct, simple, and maintainable first. Then profile. Then optimize the hot path. Most code is not on the hot path.

**Elegant** is last because elegance is subjective and often counterproductive. "Elegant" solutions tend to be clever, and clever code is hard to debug. As Brian Kernighan said: "Everyone knows that debugging is twice as hard as writing a program. So if you're as clever as you can be when you write it, how will you ever debug it?"

## Why Cognitive Gears

Builders constantly context-switch between three modes of thinking, often without realizing it:

**SCOPE EXPAND**: "What if we also added..." — This is the vision gear. It's essential for brainstorming, product thinking, and long-term planning. But it's poison during implementation.

**SCOPE HOLD**: "We said we'd build X. Let's build X." — This is the execution gear. Bulletproof rigor. Resist every temptation to add "just one more thing." The plan is the plan.

**SCOPE REDUCE**: "What's the minimum that ships?" — This is the MVP gear. Cut everything that isn't load-bearing. Ship something real, learn from reality, then expand.

The rule is: **never blend gears**. When you're in SCOPE HOLD, don't entertain SCOPE EXPAND ideas. Write them down for later. When you're in SCOPE REDUCE, don't resist cutting — that's SCOPE HOLD leaking in.

Most failed projects fail because they blend gears: they try to build the MVP while simultaneously expanding scope. The result is a half-built, over-scoped mess.

## Why Evidence-First

"Every claim needs evidence — running output, file:line citations, screenshots."

This principle exists because AI assistants (and humans) are confident liars. Without evidence:
- "The test passes" might mean "I think it should pass"
- "The bug is fixed" might mean "I changed something nearby"
- "It's secure" might mean "I added a check somewhere"

Evidence forces truth. If you can't show the output, you haven't verified it. If you can't point to the file and line, you might be describing code that doesn't exist.

This applies to humans too. In code reviews, don't say "I tested it" — show the test output. Don't say "it works on mobile" — show the screenshot.

## Why Past Mistakes > Documentation

Traditional docs describe how things work. Past mistakes describe how things break. The latter is more valuable because:

1. **Docs describe intentions. Mistakes describe reality.** The architecture doc says "RLS protects all tables." Past mistakes says "RLS was disabled on the profiles table despite the migration defining it."

2. **Docs are generic. Mistakes are specific.** A Next.js tutorial says "use server components." Past mistakes says "using `.single()` instead of `.maybeSingle()` crashes when new users have no ranking data."

3. **Docs decay. Mistakes compound.** Documentation goes stale the moment code changes. But a mistake log — "CSV imports had spam accounts → always validate before bulk operations" — is timeless because the class of error is universal.

The key insight: extract the **class** of error, not the specific instance. "Use `.maybeSingle()` for rankings" is a fix. "Use `.maybeSingle()` when the row may not exist" is a rule that prevents an entire category of bugs.

## Why Session Journals

Without session journals, every conversation starts from zero. You spend 20 minutes re-explaining context that Claude had 4 hours ago.

Session journals solve this by capturing:
- **What was built**: So you don't rebuild it
- **What was decided**: So you don't re-debate it
- **What was learned**: So you don't re-discover it
- **What's next**: So you don't re-plan it

The compound effect is powerful. After 10 sessions, your vault contains a complete history of architectural decisions, known bugs, failed approaches, and working patterns. Claude loads this context in seconds and builds on it.

## Why Decision Records

Most technical debt comes from decisions that made sense at the time but nobody remembers the context. Three months later, someone asks "why did we use X instead of Y?" and the answer is lost.

Decision records capture:
- **What we decided**: The actual choice
- **What we considered**: The alternatives
- **Why we chose it**: The rationale (constraints, tradeoffs, deadlines)
- **What it means**: The consequences

This prevents two failure modes:
1. **Re-debating settled decisions** because nobody remembers the rationale
2. **Blindly continuing with decisions whose constraints have changed** because nobody remembers the original constraints

## Why Zero Dependencies

shipstack is just markdown files and shell scripts. No npm packages. No Python dependencies. No build step. No runtime.

This is intentional:
- **It can't break**: No dependency updates, no version conflicts, no supply chain attacks
- **It works everywhere**: Any system with bash and a text editor
- **It's forkable**: Copy the files, customize them, done
- **It's understandable**: You can read every file in 30 minutes

The most reliable software is the software that doesn't exist. The second most reliable is plain text.

## Why the Two-Pass Review

Code reviews catch two fundamentally different types of issues:

**CRITICAL**: Security vulnerabilities (auth bypass, SQL injection, XSS), data integrity issues (data loss, corruption), and correctness bugs. These must be found and fixed. Missing a critical issue is a failure.

**INFORMATIONAL**: Dead code, missing tests, suboptimal patterns, style issues. These are nice to fix but don't cause incidents. Missing an informational issue is fine.

The two-pass approach ensures you never mix these. In a single-pass review, it's easy to spend 30 minutes bikeshedding variable names while missing an auth bypass. The two-pass forces you to find all critical issues first, then (and only then) move to informational improvements.

## Why "Can We Undo This?"

The ship check asks: "What breaks at scale? At zero? With malice? Can we undo this? When someone else touches this in 6 months?"

"Can we undo this?" is the most underrated question in software engineering. It's the difference between:
- A database migration that adds a column (undoable) vs. one that drops a column (not undoable)
- A feature flag deployment (undoable) vs. a data migration (not undoable)
- A soft delete (undoable) vs. a hard delete (not undoable)

Prefer reversible actions. When an action is irreversible, that's when you double the verification. The cost of pausing to confirm is low. The cost of an unwanted irreversible action is infinite.
