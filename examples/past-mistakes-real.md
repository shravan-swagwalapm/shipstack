# Past Mistakes — Real Examples (Anonymized)

> These are real mistakes from production projects, anonymized and extracted. Each follows the pattern: **What happened → Rule to prevent the CLASS of error.**

## Auth & Permissions

1. **Admin users had wrong role in legacy table** despite correct role in the new assignments table → **When migrating role systems, always check ALL role storage locations. Dual-check until legacy is fully deprecated.**

2. **`router.refresh()` didn't sync state after role switch** — UI showed stale role data → **Use `window.location.reload()` for auth state changes. Client-side router refresh doesn't clear React state trees.**

3. **RLS was disabled on a table despite the migration defining it** — data was exposed → **ALWAYS verify RLS status in the database dashboard after running migrations. Migrations can fail silently.**

4. **Client component queried other users' data via anonymous key** → **Cross-user queries MUST use a server-side admin client, never a user-scoped client.**

## Data Quality

5. **CSV import contained spam/test accounts** — 332 users imported but only 325 were real → **Always validate and deduplicate data before bulk operations. Query existing DB first, match against import, skip non-existent.**

6. **Form used `type="date"` for a deadline field** — users couldn't set a time, only a date → **Always use `datetime-local` for deadline/timestamp fields. `date` inputs silently discard time information.**

## API & Network

7. **11 parallel fetches from a dashboard page with no timeouts** — page hung on slow connections, loader spun forever → **Wrap all fetches in `fetchWithTimeout()` with AbortController. Use BFF routes for dashboards (1 request, server-side parallelism).**

8. **Supabase query returned `{ data: null, error: ... }` but code only checked `data`** — errors were silently ignored → **Always check BOTH `data` AND `error` from database client responses. The client never throws — it returns error objects.**

## Agent Systems

9. **Prompt instruction "don't delegate" was ignored by the LLM** — agent kept delegating to other agents → **Disable delegation at the config level (`allowAgents: []`), not in the prompt. LLMs are unreliable prompt followers.**

10. **Changed agent behavior in prompt but old behavior persisted** — session history overrode new instructions → **Clear session files when changing agent behavior. Old conversation history takes precedence over updated system prompts.**

---

> **Pattern**: Notice how each rule addresses the **class** of error, not the specific instance.
> - "Check both tables" → class: migration-era dual storage
> - "Verify in dashboard" → class: silent migration failures
> - "Config-level, not prompt-level" → class: LLM instruction unreliability
