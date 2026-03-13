# CLAUDE.md — {{Project Name}}

**Project**: {{one-line description}}
**Stack**: {{technologies}}
**Updated**: {{date}}

---

## Commands
```bash
npm run dev              # Dev server
npm run build            # Production build (must pass before deploy)
npm run lint             # Linting
npm test                 # Tests
```

---

## Critical Rules (Never Break These)

**Auth**:
- [Your auth rules here]

**Code**:
- Server Components by default — `'use client'` only when interactive
- [Your code rules here]

**Deploy**:
- `npm run build` must pass before deploy
- [Your deploy rules here]

---

## Key Files
| File | Purpose |
|------|---------|
| `middleware.ts` | Auth guard |
| `lib/api/` | Shared API utilities |
| `contexts/` | React contexts |

---

## Design Iteration Rule

After any visual change, screenshot and verify.
Never make >3 visual changes without a screenshot check.

---

## Full Context in Vault

> For architecture, past mistakes, decision history:
> Read from `~/ProductBrain/Projects/{{Project Name}}/`
