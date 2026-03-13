---
name: feedback_testing
description: User correction — integration tests must use real database, not mocks
type: feedback
---

Integration tests must hit a real database, not mocks.

**Why:** Prior incident where mock/prod divergence masked a broken migration. Tests passed locally but the production deploy failed because the mock didn't match the actual schema.

**How to apply:** When writing tests that touch database queries, always use a test database with real migrations applied. Reserve mocks for external API calls only.
