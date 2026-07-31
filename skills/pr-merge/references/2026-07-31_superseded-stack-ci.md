---
class: principle
---

# Prefer the newest same-head workflow run

**Rule:** A cancelled required check is non-terminal while a newer run of the same workflow and HEAD is live. Wait
for the replacement; otherwise use the newest matching run's terminal conclusion.

**Why:** One publication can trigger overlapping workflows. Concurrency may cancel the older run before its queued
replacement starts, so the older conclusion is no longer authoritative.

**Where:** `wk-pr-merge` required-check classification delegates this case to
[`wk-gh`](../../gh/README.md) status-rollup handling.
