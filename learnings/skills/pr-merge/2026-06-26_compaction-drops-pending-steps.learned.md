---
skill: wk-pr-merge
date: 2026-06-26
type: gap
severity: high
---

Context compaction silently drops Steps 8-10 when it occurs mid-Steps-7-10 unit.

**What happened:** Compaction occurred right after Step 7 (ticket transition). The compaction summary correctly described Steps 8-10 as pending, but the session resumed without a guard ensuring they ran before any other work.

**Root cause:** The HARD RULE "Steps 7-10 are one unit; a user question mid-flow is not a stop signal" covers user digressions but not compaction — an automatic mid-turn interruption that a resuming session cannot distinguish from a clean start.

**Suggested fix:** Add a compaction-recovery instruction: when resuming from a compaction summary that shows pr-merge was active and Steps 8-10 are listed as pending, execute them before any other work. The compaction summary is the authoritative source for which steps remain.
