---
skill: wk-pr-merge
date: 2026-07-10
type: correction
severity: medium
---

Do not resolve the author's own self-review threads as pre-merge cleanup; attempt the merge and let it proceed with them open.

**What happened:** At Step 4 the skill instructed resolving remaining unresolved self-review threads (author's own design-rationale notes) before merging, and attempted the GraphQL `resolveReviewThread` mutation. The user rejected this: self-review threads should be left as-is, and the PR merged without resolving them.

**Root cause:** Step 4's "resolve remaining self-review threads as pre-merge cleanup" assumes branch protection counts all unresolved threads regardless of author. When it does not (or the user does not want their own review notes auto-resolved), the resolve step is both unnecessary and unwanted — the author's self-review threads are informational and not the agent's to close.

**Suggested fix:** Default to NOT resolving the author's own self-review threads at merge time. Proceed straight to the merge attempt; only if the merge is actually rejected by branch protection for unresolved threads should resolution be raised — and then ask the user first rather than auto-resolving. Never treat auto-resolving self-authored threads as routine cleanup.
