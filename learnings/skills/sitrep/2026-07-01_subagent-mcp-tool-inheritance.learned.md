---
skill: wk-sitrep
date: 2026-07-01
type: gap
severity: medium
---

Connector-dependent subagents (Slack, and OAuth-gated tools) cannot be assumed to inherit the orchestrator's MCP toolset.

**What happened:** During `end`, the Slack gathering subagent had no Slack MCP tools exposed at all — it returned blocked on all six threads it was asked to check, having no way to call `slack_read_thread`. The orchestrator recovered by running the thread reads directly in the main context, where the tools were available. Separately, the DX subagent hit an expired OAuth token on a compliance-dashboard MCP (soft block) and correctly fell back to CLI-computed metrics.

**Root cause:** The subagent contract assumes each roster agent can reach the MCP connector for its domain, but general-purpose subagents do not reliably inherit every MCP server the main orchestrator has. Slack (and other interactively-authenticated connectors) may be present in the main tool list yet absent from a spawned subagent's toolset. There is no pre-flight check that the subagent actually has the tools its task requires.

**Suggested fix:** For connector-dependent sweeps (Slack especially), either (a) have the orchestrator run those specific MCP reads in the main context rather than delegating, or (b) add a one-line capability probe to the subagent contract — "if your domain's MCP tools are not in your toolset, report `tool_unavailable` immediately rather than attempting and failing" — so the orchestrator can fall back fast instead of losing an agent's whole budget. Treat a subagent's "all items blocked, no tool access" as a hard signal to re-run in main, not as "nothing found."
