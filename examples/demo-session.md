# Demo Session: The Full shipstack Loop

> This transcript shows how shipstack's knowledge system works in practice — from boot to ship. Every step builds on context from previous sessions.

---

## 1. Boot — Hook Fires

```
$ claude

Vault available. Remember to read vault context for the active project before starting work.
```

Claude's session-start hook fires, injecting PATH and reminding to load context.

---

## 2. Context Load

**User**: "Add a bulk export feature to the admin dashboard."

**Claude**: *Before writing any code, Claude loads context:*

> Reading project CLAUDE.md...
> Reading past mistakes...
> Reading last session journal...
>
> I see from past mistakes that:
> - CSV imports had data quality issues (spam accounts) → need validation
> - `.single()` caused crashes for empty results → use `.maybeSingle()`
> - 11 parallel fetches caused connection starvation → use BFF pattern
>
> From last session: the dashboard was rewritten to use a BFF route.
> The export should follow the same server-side pattern.

---

## 3. Challenge the Ask

**Claude**: "Before building: a few questions.

1. **Right problem?** Are admins actually requesting bulk export, or is this speculative?
2. **Right scope?** Should this export all data or just the current filtered view?
3. **Right time?** I see from the session journal that 8 pages still need error states. Should we finish that first?

My recommendation: build export for the current filtered view only (SCOPE HOLD). Full data export is a different feature with different security implications."

**User**: "Good catch. Current filtered view only. The error states can wait — this is blocking a partner demo on Friday."

---

## 4. Gear: SCOPE HOLD — Plan Mode

**Claude**: *Entering plan mode. Gear: SCOPE HOLD.*

```
Plan: Admin Bulk Export (filtered view)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Add export API route: /api/admin/export
   - Accepts same filter params as the list page
   - Server-side query (uses createAdminClient)
   - Returns CSV with proper headers

2. Add export button to admin list page
   - Uses current filter state
   - Shows loading indicator during generation
   - Downloads file via blob URL

3. Security: verify admin role, sanitize filter params,
   rate limit (max 10 exports/hour)

Estimate: ~45 minutes. No database changes needed.
```

---

## 5. Build — With Verification

**Claude**: *Building step 1...*

```ts
// app/api/admin/export/route.ts
export async function GET(request: NextRequest) {
  const admin = await verifyAdmin(request)
  if (!admin) return unauthorized()

  const params = sanitizeFilterParams(request.nextUrl.searchParams)
  // ... query with filters, generate CSV
}
```

*Step 1 complete. Verifying: running `curl` against the endpoint...*

```
$ curl -H "Cookie: ..." "http://localhost:3000/api/admin/export?status=active"
HTTP/1.1 200 OK
Content-Type: text/csv
Content-Disposition: attachment; filename="export-2026-03-01.csv"

id,name,email,status,joined
1,User A,a@example.com,active,2026-01-15
...
```

*Prediction matched reality. Moving to step 2.*

---

## 6. Prove — Evidence First

**Claude**: *All 3 steps complete. Running full verification:*

```
✅ Export API returns CSV with correct headers
✅ Filter params are sanitized (tested with SQL injection attempt)
✅ Non-admin users get 401
✅ Rate limit triggers after 10 requests
✅ Export button shows loading state
✅ File downloads with timestamped filename
✅ Empty result set returns CSV with headers only (no crash)
```

*Every claim above has running output. File references: `app/api/admin/export/route.ts:1-45`, `components/admin/export-button.tsx:1-28`.*

---

## 7. Review — Two Pass

**Claude**: *Running two-pass review:*

**CRITICAL (security/data)**:
- ✅ Admin verification via `verifyAdmin()` (not just role check)
- ✅ Filter params sanitized before query
- ✅ Rate limiting in place
- ✅ No PII in exported filenames
- ⚠️ CSV injection possible if user data contains `=`, `+`, `-`, `@` prefixes → **Adding prefix sanitization**

**INFORMATIONAL**:
- Export function could be extracted if we add more export types later
- No test coverage yet — recommend adding in next session

---

## 8. Ship Check

**Claude**:
- **At scale?** CSV generation is synchronous — fine for <10K rows. If we ever need more, move to background job.
- **At zero?** Empty filter returns headers-only CSV. ✅
- **With malice?** SQL injection blocked by sanitization. CSV injection now blocked. Rate limited.
- **Can we undo this?** Yes — export is read-only, no state mutation.
- **6-month test?** Clear function names, filter params match list page 1:1, single responsibility.

---

## 9. Session Journal

**Claude**: *Capturing session learnings:*

```markdown
# Session: Admin Bulk Export

## Goal
Add filtered CSV export to admin dashboard for partner demo.

## What We Built
- /api/admin/export route with filter support
- Export button component with loading state
- CSV injection prevention

## Bugs Fixed
- CSV injection vulnerability (prefix sanitization added)

## Learnings
- CSV injection is a real attack vector — any user-generated
  data in CSV needs prefix sanitization for =, +, -, @
- BFF pattern from last session made this easy — same query
  pattern, different output format

## Next Session TODO
- [ ] Add test coverage for export route
- [ ] Finish error states on remaining 8 pages
```

---

## 10. Past Mistakes Update

**Claude**: *Extracting lesson:*

```markdown
## CSV Export (2026-03-01)
- CSV cells starting with `=`, `+`, `-`, `@` can trigger formula
  execution in Excel → **Always sanitize CSV cell values by prefixing
  with a single quote or tab character when the first character is
  a formula trigger**
```

> This rule will prevent the same class of vulnerability in every future CSV export, across all projects.

---

## The Loop

This is shipstack's core loop:

```
Boot → Context → Challenge → Plan → Build → Prove → Review → Ship Check → Journal → Mistakes
  ↑                                                                                        |
  └────────────────────────── Next session starts here ────────────────────────────────────┘
```

Every session starts with the output of previous sessions. Claude gets smarter over time — not by training, but by reading its own notes.
