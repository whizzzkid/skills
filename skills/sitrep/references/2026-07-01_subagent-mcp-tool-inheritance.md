---
class: principle
---

- **Rule:** Spawned subagents do NOT reliably inherit the orchestrator's MCP connectors (Slack, OAuth-gated tools). The subagent contract must require a capability probe: if the domain's MCP tools are absent from the subagent's toolset, return `tool_unavailable: true` immediately rather than failing item-by-item.
- **Why:** An interactively-authenticated connector present in the main tool list can be missing from a general-purpose subagent's toolset, silently burning the agent's whole budget on unfulfillable reads.
- **Where:** Stage 2 SUBAGENT CONTRACT ("PROBE TOOLS FIRST"); soft/hard block handling treats a `tool_unavailable` return as a capability-inheritance failure → orchestrator re-runs that domain in the main context, not as "nothing found".
