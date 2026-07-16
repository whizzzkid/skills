---
class: principle
---

**Rule:** A gathering subagent can stall indefinitely — emitting only idle
events, never a substantive result and never a `tool_unavailable` flag — even
after repeated nudges. Cap nudges at 3; after 3 with no substantive result,
treat that domain as `tool_unavailable` by default, degrade gracefully (carry
forward the prior day's items for it with a "not reverified — agent
unresponsive" note), and move on. Never block the whole run on one stalled
agent.

**Why:** The subagent contract requires agents to push results but has no
timeout/escalation ceiling, so a silent-failure loop is indistinguishable from
"still working" and can hang the run.

**Where:** wk-sitrep Stage 2 block-handling pointer + `references/subagent-contract.md`
"Orchestrator: unresponsive-agent ceiling" section.
