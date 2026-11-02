---
class: principle
---

**Rule** — In Phase 2, detect the current user's own `PENDING` review on the PR and fetch its body and
review-specific comments up front. Footer-marked (agent-authored) comments are unverified candidate findings:
re-verify them in Phase 3 and re-anchor them from the current-head blob. Never load them into the exclusion list or
the re-review loop. Unfootered comments are the user's own work and carry over verbatim. Phase 5 deletes the draft
and recreates the union through the append path.

**Why** — An interrupted run leaves a draft the author has never seen, so treating it as prior review state either
suppresses its findings as "duplicates" or skips re-checking them. GitHub allows one pending review per user per PR,
so a fresh create 422s, and pending comments return `line: null`, so anchors must be rebuilt rather than copied. The
footer tells an agent draft apart from a human one; deleting a human draft without carrying it forward destroys work
(consistent with `wk-gh`'s compare-and-recover union).

**Where** — [`wk-pr-review`](../README.md) Phase 2 "Own pending draft" bullet; recreate mechanics in
[`posting-pending-review.md`](posting-pending-review.md) "Append to existing pending review".
