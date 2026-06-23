---
class: principle
skill: wk-adversarial-review
date: 2026-06-23
---

**Rule**

When fixing a value/message/constant-reporting defect, grep the *entire changed
file* (not just the flagged line) for every site of the same shape before
committing; treat each match as the same fix unless divergence is justified.

**Why**

A refactor that extracts a helper clones the original defect onto a different
line in the same file. Fixing only the flagged location leaves the sibling
shipping the same bug — caught late (post-commit) by the adversarial subagent.

**Where**

Step 7 fix-loop item 2 (parallel-sibling fix).
