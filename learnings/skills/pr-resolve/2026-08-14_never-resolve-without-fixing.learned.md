---
skill: wk-pr-resolve
date: 2026-08-14
type: correction
severity: high
verified-against-source: n/a
---

Never resolve a review thread without first implementing the fix

**What happened:** Agent resolved a {bot} review thread via GraphQL `resolveReviewThread` mutation without actually fixing the underlying finding. User caught it: "did you just resolve it without fixing it?" The PR remained blocked because the finding was still present in code.

**Root cause:** Agent treated thread resolution as a bookkeeping step rather than a post-fix confirmation step. The resolve action was decoupled from the code-change action.

**Suggested fix:** Enforce ordering in the resolve flow: (1) implement the code fix, (2) commit and push, (3) confirm CI passes, (4) only then resolve the thread. Never resolve a thread as a way to dismiss a finding — resolution means the finding has been addressed in code.
