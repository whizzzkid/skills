---
class: principle
---

**Rule**

In the branch-sync step, detecting that the branch is behind its base and acting
on it are one atomic unit. A positive behind-count obligates the base merge before
any review comment is read — reporting the count and continuing is a violation.

**Why**

A sync check with two parts (detect, then act) invites treating detection alone as
"done": the count gets logged and the agent moves straight to triage, leaving the
branch on a stale base until a human notices. Suggestions and fixes then build on
the wrong base.

**Where**

Step 2 (Sync Branch) — the "Integrate the base branch" bullet now states the
obligation inline; the merge command lives in commands.md §2.
