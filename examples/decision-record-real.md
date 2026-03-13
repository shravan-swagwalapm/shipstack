# Decision Record — Real Example (Anonymized)

---
type: decision
project: "ProjectX"
status: decided
created: "2026-02-10"
decided: "2026-02-11"
tags: [decision, auth, architecture]
---

# Decision: Authentication Strategy for Multi-Channel Platform

## Context

The platform needs to support authentication across web (primary), mobile app (future), and admin dashboard. Currently using cookie-based sessions with a single auth provider. Requirements:
- Support phone-based OTP (primary market uses phone numbers, not email)
- Admin access must be completely separated from user access
- Must work with existing RLS policies in the database

## Options Considered

### Option A: Extend Current Cookie Sessions + Add Phone OTP
- **Pros:** Minimal code changes, works with existing RLS, battle-tested session handling
- **Cons:** Cookie sessions don't transfer to mobile apps, admin/user separation is a hack (role check in middleware), phone OTP requires third-party integration
- **Effort:** 3-5 days

### Option B: JWT Tokens + Custom Auth Server
- **Pros:** Works across web and mobile, clean admin separation with different token scopes, full control
- **Cons:** Must build token refresh, revocation, and storage from scratch. Security surface area is massive. Needs dedicated infrastructure.
- **Effort:** 3-4 weeks

### Option C: Database Auth Provider + OTP Service Integration
- **Pros:** Leverages existing database auth (handles tokens, refresh, RLS automatically), just need to wire phone OTP as a custom provider, admin separation via role assignments table
- **Cons:** Tied to database provider's auth implementation, phone OTP needs separate rate limiting
- **Effort:** 1 week

## Decision

**Chosen:** Option C

**Rationale:**
1. The database provider already handles token lifecycle, refresh, and RLS integration — rebuilding this (Option B) is weeks of security-critical code with no user-facing benefit.
2. Option A's cookie-only approach blocks mobile app expansion.
3. Option C gives us phone OTP support in ~1 week while preserving all existing auth flows.
4. Admin separation via role assignments table (not token scopes) is actually more flexible — supports multi-role users without multiple tokens.

## Consequences
- Must implement rate limiting for OTP from day 1 (not post-launch)
- Phone numbers stored as `+[country_code][number]` format
- Third-party OTP provider template must be approved before production
- Legacy role column in profiles table remains but is secondary to role assignments table
- Mobile app (future) will use the same auth flow with token storage in secure keychain
