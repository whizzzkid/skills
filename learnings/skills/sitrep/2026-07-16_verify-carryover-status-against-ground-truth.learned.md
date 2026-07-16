---
skill: wk-sitrep
date: 2026-07-16
type: pattern
severity: medium
---

Cross-checking gathering-agent-reported carry-over status against ground truth (not just the agent's own report) surfaced an auto-transition candidate the agent had missed.

**What happened:** The tracker-gathering agent reported a ticket's linked PR status as "unchanged: In Review." An independent PR-status check on the linked PR found it had actually merged several days earlier, inside the auto-transition window — meaning the ticket was in fact eligible for auto-transition and the agent's cross-check was stale or wrong.

**Root cause:** Subagents report what they observed at gather time, but a linked cross-system reference (PR ↔ ticket) can drift between the subagent's check and the orchestrator's compile step, or the subagent's own merge-check logic can be incomplete.

**Suggested fix:** Before compiling Stage 2b auto-transition candidates, always re-verify each ticket's linked-PR merge state directly (e.g. `gh pr view <url> --json state,mergedAt`) rather than trusting the tracker agent's cross-check report as final — treat agent-reported "unchanged" status as a claim to verify, not a fact.
