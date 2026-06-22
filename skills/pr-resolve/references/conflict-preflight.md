---
class: principle
---

**Rule** — Make a conflict-marker check (`git diff --check`) the first action of branch sync, before any fetch or comment read. Any markers present → resolve to a clean tree (or delegate to `wk-pr-update`) before triaging a single comment.

**Why** — Triaging on a conflicted tree embeds conflict markers into commits or generates suggestions against a stale diff. Conflict resolution belongs at sync time, not as a deferred "before you start" reminder the user has to supply.

**Where** — Step 2 sync pre-flight. A user reminder to "resolve conflicts first" is the signal this gate was skipped on a prior run.
