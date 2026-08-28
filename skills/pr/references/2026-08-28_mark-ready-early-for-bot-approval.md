---
class: principle
---

# Mark ready early when automated reviewer gates on ready state

**Rule** — When the user directs immediate ready (or a repo's automated review
bot requires ready state to trigger), mark the PR ready immediately after
creation instead of waiting for the full CI + self-review cycle. Continue
self-review, CI polling, and feedback triage in the post-ready flow.

**Why** — Some repos have automated review bots (required approvers) that only
review PRs in ready state. Holding draft through the full CI/self-review cycle
delays bot approval and blocks the entire stack. The post-creation workflow
steps are not gated on draft status — they run identically on a ready PR.

**Where** — Step 2, under the draft-mode rule as the early-ready override.
