---
class: principle
---

**Rule** — Before merge, detect any still-pending self-authored review on the PR
and submit it with `event: "COMMENT"`. A pending review that merges unsubmitted
is invisible documentation.

**Why** — Across several PRs the agent left self-review comments as pending
drafts, then proceeded toward merge. The user had to prompt twice to get the
design notes actually posted before the PR landed.

**Where** — `SKILL.md` → Step 4.5 (merge-gate submission), Quick Reference
table entry.
