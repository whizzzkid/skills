---
skill: wk-pr-merge
date: 2026-07-22
type: gap
severity: medium
---

GraphQL transient failures in Step 6 (stacked-child retargeting) block the merge when no fallback exists.

**What happened:** During Step 6 pre-merge child retargeting, a GraphQL `updatePullRequest` mutation failed with "Something went wrong while executing your query" (500-class error). The skill had no retry or fallback, so execution paused. The REST `gh pr edit --base` equivalent succeeded on the next attempt.

**Root cause:** Non-idempotent mutations like child retargeting can fail transiently on hosted GraphQL services (network blips, service brief unavailability). The skill assumes GraphQL succeeds and lacks a fallback to REST or a retry wrapper. This is a gap in robustness, not a correctness issue — the mutation itself is valid and retryable.

**Suggested fix:** Add explicit retry logic or fallback for Step 6 stacked-child retargeting: (1) detect 500-class GraphQL errors (transient, retryable); (2) retry up to 2×; (3) fall back to `gh pr edit --base` (REST) if GraphQL fails after retries. Document the quirk in Step 6 so future runs know transients are expected and benign.
