---
skill: wk-pr-merge
date: 2026-06-22
type: correction
severity: high
---

Unresolved non-blocker bot comments should not block the merge; propose a Jira ticket instead and proceed.

**What happened:** The skill fetched unresolved review threads, found two open {bot} findings (Minor: abstraction-quality on a helper function, Minor: missing beta-branch test coverage), and stalled — presenting them as blockers before merge instead of proposing to track them as follow-up tickets. The user merged manually and asked the skill to change this behavior.

**Root cause:** Step 4's HARD RULE ("count ALL unresolved non-outdated threads") correctly prevents merging with open reviewer/bot blockers, but the skill did not distinguish severity. Minor/Info findings with no code correctness risk are not merge blockers — they are follow-up candidates. The skill treated any unresolved bot thread as a hard stop.

**Suggested fix:** In Step 4, after collecting unresolved bot threads, triage by severity before blocking:
- Severity = Blocker or Major → invoke `wk-pr-resolve`, do not merge.
- Severity = Minor or Info → propose one Jira ticket per finding (or a single omnibus ticket). Draft the Jira body using the finding text and ask the user for the epic/parent to file it under. Resolve each thread with a "Tracked in [TICKET]" reply, then continue to merge. If the user declines, leave threads open and proceed anyway — Minor threads must not block a merge-ready PR.
