---
class: principle
skill: wk-sitrep
date: 2026-11-25
---

# Brief gathering agents with exact tool names, not just keywords

- **Rule:** Before Stage 2 dispatch, load each roster connector's schemas once in the main context by exact name
  (`select:<name>,…`) and give every gathering agent the exact tool names it needs beside the ToolSearch keyword. The
  subagent contract probes those exact names before any keyword search; a keyword search returning only auth stubs or
  unrelated tools is not proof of absence. Main-context replay stays the fallback.
- **Why:** Three gathering agents ran keyword tool searches, got only OAuth stubs or unrelated tools, and returned
  `tool_unavailable`. The orchestrator then loaded the same connectors by exact name and replayed all three domains,
  costing three extra main-context passes and a degraded first report.
- **Verified:** A keyword search caps results at the top N: searching a ticket-tracker keyword returned that
  connector's write and fetch tools while omitting its query tool, and a connector registered only as auth stubs
  surfaces nothing usable by keyword. Exact-name select is deterministic. Whether subagents inherit connectors at all
  remains governed by the existing PROBE TOOLS FIRST clause; this rule removes the false-negative class only.
- **Where:** `SKILL.md` → `start` Stage 2, bullet before Block handling; `references/subagent-contract.md` →
  PROBE TOOLS FIRST clause.
