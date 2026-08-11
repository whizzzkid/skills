---
skill: wk-sitrep
date: 2026-08-10
type: correction
severity: high
verified-against-source: yes
---

A main-context fallback must replay the unavailable subagent's complete domain contract, not only the data needed
for the visible dashboard.

**What happened:** The calendar gathering subagent reported that its connector was unavailable. The orchestrator
successfully reran calendar access in the main context, but fetched only the current and prior workdays. It skipped
the required five-day interview scan, so mandatory prep and scorecard events were not created.

**Root cause:** The fallback was treated as an ad hoc data replacement rather than a replay of the calendar
subagent's complete prompt plus the orchestrator-owned follow-up stage. The skill says to rerun an unavailable
domain in the main context, but the execution did not preserve the domain's full time window and side-effect
obligations.

**Suggested fix:** Add a fallback completion checklist to `start`: when any gathering subagent returns
`tool_unavailable`, the main context must replay every query window and output field from that agent's prompt, then
run every dependent orchestrator action before compilation. For Calendar, explicitly gate Stage 3 on a recorded
five-day interview-scan result and either created scaffolding event links or a documented no-slot/write-access
fallback.
