---
class: principle
---

# Re-poll review threads before reporting PR status after a push

**Rule** — Before any PR status report that follows a push, wait until each bot reviewer has a review whose
`commit_id` equals `headRefOid`, then query unresolved `reviewThreads` via GraphQL. Any unresolved thread is open
work routed to `wk-pr-resolve`; never report the PR as "awaiting approval" while one remains.

**Why** — `statusCheckRollup` and `reviewDecision` describe CI and approval state, not findings. A review bot can post
a blocker as inline threads under an empty top-level review body, so neither the merge state nor the review summary
reveals it. REST `pulls/{n}/comments` carries no resolution state, so only the GraphQL thread query answers "is
anything still open". Verified: the REST reviews endpoint exposes `commit_id` and `user.type` per review, which is
what ties a bot's review to the current head.

**Where** — `SKILL.md` → Hard Rule 5 (*re-poll review threads before every status report after a push*) and Step 4
item 4. Sibling rules already ship in `wk-pr-resolve` Step 9.5 and `wk-workflow` Phase 6.5; this fold closes the gap
in `wk-pr`'s own status-report path. Not escalated there: the learning does not show those skills were active.
