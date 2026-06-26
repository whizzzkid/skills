---
class: principle
---

**Rule** — Self-review launches before the CI poll, never after CI green. Tie
the precondition structurally: do not start the CI poll until the pending
self-review draft is posted.

**Why** — CI takes minutes; staging the self-review draft in that window means
the PR is closer to ready when CI finishes. The intuitive "CI green → then
review" ordering is a recurring violation that overrides the rule; the
structural gate makes the deferral impossible to reach.

**Where** — Step 3, item 2 of the post-creation workflow.
