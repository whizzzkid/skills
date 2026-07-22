---
class: principle
---

**Rule:** Treat 500-class GraphQL errors on Step 6 stacked-child retargeting as
retryable transients, not hard failures — retry up to 2×, then use the REST
`gh pr edit --base` equivalent. Never pause the merge on one.

**Why:** Non-idempotent mutations on hosted GraphQL services fail transiently
("Something went wrong while executing your query"); the mutation is valid and
the REST path is robust. Pausing mid-merge on a benign blip is a robustness gap,
not a correctness issue.

**Where:** wk-pr-merge, Step 6 (retarget stacked children before merge).
