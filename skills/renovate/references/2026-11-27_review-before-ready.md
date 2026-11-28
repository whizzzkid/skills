---
class: principle
skill: wk-renovate
date: 2026-11-27
severity: medium
---

# Run the major-change adversarial review before the push

**Rule** — Step 4 found any major-class change → run the adversarial review before pushing (latest: while the PR is
still draft) and record its verdict in the PR body.

**Why** — The skill ordered review after mark-ready, assuming the agent controls the merge. A user enabled auto-merge
on the draft minutes after it opened; it merged on green CI and the review never ran, though the batch carried
pre-1.0 minor bumps (majors).

**Where** — `SKILL.md` → Step 5 lead-in and Step 6 adversarial-review bullet.
