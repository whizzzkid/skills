---
skill: wk-sitrep
date: 2026-07-16
type: gap
severity: medium
---

A gathering subagent (email domain) can go fully unresponsive — returning only idle events, never a substantive result or a `tool_unavailable` flag — even after repeated nudges.

**What happened:** After 6 escalating nudges over several minutes, the email-gathering agent never produced markdown results or an explicit `tool_unavailable: true` signal. The orchestrator eventually gave up and carried forward the prior day's email items unchanged, with an explicit "not reverified today" note in the rendered page.

**Root cause:** The subagent contract requires agents to actively push results via a message-send call, but has no timeout/escalation ceiling — an agent stuck in a bad tool call or silent failure loop can stall indefinitely with no distinguishable signal from "still working."

**Suggested fix:** Add a hard nudge ceiling (e.g. 3 nudges) to the contract, after which the orchestrator should treat the domain as `tool_unavailable` by default, degrade gracefully by carrying forward the prior day's items for that domain with an explicit "not reverified — agent unresponsive" note, and move on rather than blocking the run.
