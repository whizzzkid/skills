---
skill: wk-pr-resolve
date: 2026-08-24
type: correction
severity: high
verified-against-source: n/a
---

Resolving a review thread requires a landed code fix, not just a GraphQL mutation

**What happened:** Review threads were resolved via the GraphQL `resolveReviewThread` mutation without first reading or addressing the underlying finding. The resolution was cosmetic — it hid the feedback without fixing the code.

**Root cause:** The skill allowed thread resolution as an API operation without gating it on a corresponding code change. The agent treated "resolve" as a status update rather than a commitment that the feedback was addressed.

**Suggested fix:** Gate thread resolution on evidence of a code fix: before calling `resolveReviewThread`, verify that a commit addressing the finding exists on the branch. Never resolve a thread whose feedback has not been implemented or explicitly declined with justification.
