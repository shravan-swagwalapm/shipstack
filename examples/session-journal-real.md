# Session Journal — Real Example (Anonymized)

---
type: session
project: "ProjectX"
date: "2026-02-26"
duration: "4 hours"
tags: [claude-session, performance, architecture]
---

# Session: Dashboard Performance Rewrite

## Goal
> Rewrite the student dashboard from 11 parallel client-side fetches to a single BFF (Backend-for-Frontend) API route. Mobile users were experiencing 10+ second load times due to browser connection limits.

## What We Built
- New `/api/dashboard/student` BFF route with `Promise.allSettled` for 8 parallel server-side queries
- Custom result extractors: `extractSupabase()` for DB queries, `extractPlain()` for computed data
- Client-side SWR cache layer with 5-minute TTL using localStorage
- Error state components with retry capability on every data section
- AbortController integration for cohort switching (prevents stale data from wrong cohort)

## Key Decisions Made
- Used `Promise.allSettled` over `Promise.all` — one failed query shouldn't crash the entire dashboard
- Split extractors because Supabase "fulfills" even on errors (it returns `{ data: null, error }` instead of rejecting)
- Cached via localStorage rather than a service worker — simpler, good enough for our scale
- Used `AbortSignal.any()` to combine timeout + navigation abort signals

## Bugs Fixed
- Ranking query used `.single()` which crashed for new students with no ranking → switched to `.maybeSingle()`
- Attendance query had no cohort filter — students in 2 cohorts saw blended stats → scoped via junction table
- `fetchWithTimeout` was overwriting the caller's AbortSignal → used `AbortSignal.any()` to combine signals
- Legacy `sessions.cohort_id` column used instead of proper junction table join

## Learnings
- Browser has ~6 TCP connections per host. With 11 fetches + WebSocket for realtime, you hit connection starvation on mobile. BFF pattern is the fix.
- `Promise.allSettled` marks Supabase errors as "fulfilled" because the Supabase client never rejects. You need domain-specific extractors.
- SWR cache via localStorage is a cheap, high-impact pattern — return visits are instant, and stale data is better than a loading spinner.

## Mistakes / What I'd Do Differently
- Should have built the BFF route from the start instead of adding individual fetches one by one. The incremental approach created the problem.
- Didn't test with 2+ cohorts initially — the cohort filter bug would have been caught immediately.

## CLAUDE.md Updates Needed
- Add: "Use `.maybeSingle()` not `.single()` when row may not exist"
- Add: "Always scope queries via junction table for multi-entity relationships"
- Add: "Use `AbortSignal.any()` to combine timeout + external abort signals"
- Add: "SWR cache key format: `app-name-v{N}-` — bump version on shape changes"

## Next Session TODO
- [ ] Add error states to remaining 8 pages (only dashboard has them so far)
- [ ] Set up fetchWithTimeout as a shared utility (currently duplicated in 3 files)
- [ ] Profile the BFF route — target <500ms server-side response time
- [ ] Consider adding Suspense boundaries for progressive loading
