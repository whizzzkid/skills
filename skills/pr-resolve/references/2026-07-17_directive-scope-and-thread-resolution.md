---
class: principle
---

**Rule** — A user's shorthand directive constrains *volume*, not the skill's step
sequence. "Just fix and push" means fewer comments / faster lifecycle; it never
truncates a later binding step (especially Step 9.5 CI watch). Separately, a "don't
post"/"no replies" directive bans publishing content (replies, new comments,
dismissal bodies) — never thread resolution.

**Why** — Interpreting "just fix and push" as "do nothing after push" skipped the CI
watch; an infra-side build failure went unnoticed until the user asked why. Treating
"don't post" as "don't resolve threads" leaves the merge blocked. Thread resolution is
an internal state change that unblocks merge, not a post that surfaces feedback.

**Where** — Hard Rule 15 (directive scope) and Hard Rule 2 (post-vs-resolve). Steps
and state-changes are binding unless explicitly exempted ("skip CI wait", "don't push
yet").
