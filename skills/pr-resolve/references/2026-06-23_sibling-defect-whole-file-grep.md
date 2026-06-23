---
class: principle
skill: wk-pr-resolve
date: 2026-06-23
---

**Rule**

In the Step 6 issue-class scan, for a value/message/constant-reporting defect,
grep the *whole changed file* (not just the diff) for every site of the same
shape and fix each unless divergence is justified.

**Why**

A refactor that extracts a helper clones the flagged defect onto a sibling line.
The diff scan finds it, but a fix pass targeting only the originally-flagged line
leaves the sibling broken — caught post-commit by the adversarial subagent,
forcing a second fix commit.

**Where**

Step 6 issue-class scan, per-class list (value/message/constant class). Same root
principle as the wk-adversarial-review sibling-grep reference.
