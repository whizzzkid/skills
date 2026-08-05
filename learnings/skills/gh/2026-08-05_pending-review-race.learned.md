---
skill: wk-gh
date: 2026-08-05
type: surprise
severity: medium
verified-against-source: yes
---

Pending-review discovery becomes stale during long review passes.

**What happened:** An initial query found no pending review, but a concurrent draft appeared before the create call and the API rejected the second draft with HTTP 422.

**Root cause:** GitHub permits one pending review per user on a pull request, while an early discovery query does not protect the later create operation from concurrent state changes.

**Suggested fix:** Re-query the current user's pending review immediately before creating one; if a draft appears or create returns HTTP 422, recover its body and comments, build a deduplicated union, and recreate only after preserving that content.
