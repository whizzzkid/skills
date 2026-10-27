---
skill: wk-sitrep
date: 2026-10-27
type: correction
severity: medium
verified-against-source: n/a
---

A gathering agent reported a deadline as "Fri" with a date that is actually a Saturday.

**What happened:** A chat-derived deadline arrived labeled with the wrong weekday for its date. Compiled as-is, the page would have shown a false day-of-week, which the user has zero tolerance for.

**Root cause:** The subagent contract asks for dates but not for weekday verification, and agents copy the weekday wording from the source message.

**Suggested fix:** Require the orchestrator to recompute every weekday label from its date (e.g. `date -j -f %Y-%m-%d <d> +%A`) before writing it, and state the corrected weekday when the source disagrees.
