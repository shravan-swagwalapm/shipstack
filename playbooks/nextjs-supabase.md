# Playbook: Next.js + Supabase

> Patterns from a production education platform serving 500+ users.

## 1. Server Components by Default

Use Server Components for everything. Only add `'use client'` when you need interactivity (event handlers, hooks, browser APIs).

```tsx
// ✅ Server Component (default) — data fetched at build/request time
export default async function DashboardPage() {
  const supabase = await createClient()
  const { data } = await supabase.from('sessions').select('*')
  return <SessionList sessions={data ?? []} />
}

// ✅ Client Component — only when interactive
'use client'
export function SessionFilter({ onFilter }: { onFilter: (v: string) => void }) {
  return <input onChange={(e) => onFilter(e.target.value)} />
}
```

## 2. BFF Pattern for Dashboards

**Problem**: 11 parallel fetches from the client = connection starvation on mobile (browsers limit ~6 connections per host).

**Solution**: One API route, server-side parallelism with `Promise.allSettled`.

```ts
// app/api/dashboard/route.ts
import { createClient, createAdminClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = await createClient()
  const admin = await createAdminClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const results = await Promise.allSettled([
    supabase.from('sessions').select('id, title, date').order('date', { ascending: false }),
    supabase.from('progress').select('*').eq('user_id', user.id),
    admin.from('announcements').select('*').eq('active', true),
  ])

  // Extract results — Supabase never rejects, so check .error field
  const extract = (r: PromiseSettledResult<any>) => {
    if (r.status === 'rejected') return { data: null, error: r.reason }
    if (r.value.error) return { data: null, error: r.value.error }
    return { data: r.value.data, error: null }
  }

  const [sessions, progress, announcements] = results.map(extract)

  return NextResponse.json({
    sessions: sessions.data ?? [],
    progress: progress.data ?? [],
    announcements: announcements.data ?? [],
  })
}
```

## 3. `.maybeSingle()` Not `.single()`

**Problem**: `.single()` throws PGRST116 when 0 rows match. New users with no data = crash.

```ts
// ❌ Crashes for new users
const { data } = await supabase.from('rankings').select('*').eq('user_id', userId).single()

// ✅ Returns null for new users
const { data } = await supabase.from('rankings').select('*').eq('user_id', userId).maybeSingle()
```

## 4. Error State Pattern

Every page needs: loading → error (with retry) → empty → data.

```tsx
'use client'
import { useState, useEffect, useCallback } from 'react'

export default function ResourcesPage() {
  const [items, setItems] = useState<Resource[]>([])
  const [loading, setLoading] = useState(true)
  const [fetchError, setFetchError] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    setLoading(true)  // Always set loading at TOP of fetch
    setFetchError(null)
    try {
      const res = await fetch('/api/resources')
      if (!res.ok) throw new Error('Failed to load resources')
      const data = await res.json()
      setItems(data.resources)
    } catch (err) {
      setFetchError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  if (loading) return <Skeleton />
  // Show error ONLY when no data — keep stale data visible on re-fetch failure
  if (fetchError && items.length === 0) {
    return <ErrorState message={fetchError} onRetry={fetchData} />
  }
  if (items.length === 0) return <EmptyState />
  return <ResourceGrid items={items} />
}
```

## 5. SWR Cache for Resilience

Cache dashboard data client-side so return visits are instant.

```ts
const CACHE_KEY = 'my-app-dashboard-v2-'  // Bump version on shape changes
const CACHE_TTL = 5 * 60 * 1000          // 5 minutes

function getCached<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(CACHE_KEY + key)
    if (!raw) return null
    const { data, ts } = JSON.parse(raw)
    if (Date.now() - ts > CACHE_TTL) return null
    return data
  } catch { return null }
}

function setCache(key: string, data: unknown) {
  localStorage.setItem(CACHE_KEY + key, JSON.stringify({ data, ts: Date.now() }))
}
```

## 6. Security Checklist

- [ ] RLS enabled on every table (verify in Supabase Dashboard after migrations)
- [ ] `createAdminClient()` for cross-user queries (server-side only)
- [ ] `createClient()` for user-scoped queries (subject to RLS)
- [ ] Input sanitization before `.ilike()` or `.or()` filters
- [ ] URL protocol whitelist (`http:`, `https:` only) for user-submitted URLs
- [ ] `fetchWithTimeout()` on all external API calls (15s default)
- [ ] `DOMPurify.sanitize()` on all `dangerouslySetInnerHTML`
