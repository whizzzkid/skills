---
skill: wk-sitrep
date: 2026-11-25
type: gap
severity: medium
verified-against-source: no
---

Gathering subagents reported three connectors missing that the main session loaded fine by exact tool name.

**What happened:** The directory, review-cycle and ticket-tracker agents each ran a keyword tool search ("lattice", "greenhouse", "jira") and got only OAuth stubs or unrelated tools, so they returned `tool_unavailable`. The orchestrator then loaded the same connectors by selecting their exact tool names and replayed all three domains successfully, at the cost of three extra main-context passes and a degraded first report.

**Root cause:** (unverified — inferred from symptom) A keyword search from inside a subagent ranks stub and unrelated tools above the real connector tools, whereas an exact-name select resolves them. The brief only gives the keyword hint.

**Suggested fix:** In the Stage 2 roster, give each agent line the exact tool-name prefix to select (for example `select:<server-prefix>__*` names) as well as the keyword, and keep "replay in main" as the fallback. Also have the orchestrator pre-load these connector schemas once before dispatch so a replay is a single call.
