---
class: principle
skill: wk-pr-merge
date: 2026-06-23
---

**Rule**

In Step 2, poll and gate on `required == true` checks only. Never wait on, poll,
or block the merge for a non-required check — report it as informational.

**Why**

Informational checks (security scanners, dependency bots) often queue
indefinitely; blocking on them delays a merge whose required checks are all green.

**Where**

Step 2 — the `jq 'select(.required == true)'` filter already existed; this run
escalated the rule one notch to an explicit `**Important:**` bullet because a
fresh field report repeated the same waited-on-non-required failure (already-
covered re-violation → escalate).
