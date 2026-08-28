---
skill: wk-pr
date: 2026-08-28
type: correction
severity: medium
verified-against-source: no
---

Mark PRs ready immediately when a review bot gates approval on ready state

**What happened:** The agent created PRs in draft mode and held them draft
through the CI/self-review cycle. The user interrupted mid-run to direct that
every PR be marked ready for review immediately, because the repo's automated
review bot ({bot}) only reviews and auto-approves PRs in the ready state —
holding drafts delayed the approval pipeline for the whole stack.

**Root cause:** (unverified — inferred from symptom) The skill's default
"always create draft, mark ready only after CI green + self-review" flow
assumes human reviewers; it has no branch for repos where an automated
reviewer is the required approver and triggers on ready state, making early
ready the faster and intended path.

**Suggested fix:** Add a repo-signal check to the ready-state decision: when
the repository's required approval comes from an automated review bot that
triggers on ready (or the user directs it), mark the PR ready immediately
after creation instead of holding draft until CI green; keep the rest of the
post-creation workflow (self-review, CI poll, description sync) unchanged.
