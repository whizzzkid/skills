---
skill: wk-sitrep
date: 2026-06-18
type: gap
severity: high
---

Subagents sent idle_notification instead of returning results directly, causing extra round-trips.

**What happened:** 3 of 5 parallel data-gathering agents sent bare `idle_notification` JSON messages when done instead of including their results in the final message. The orchestrator had to detect idleness, then send a follow-up `SendMessage` to request data — doubling latency for those agents.

**Root cause:** The subagent contract said "your output is markdown text the orchestrator pastes into a section" but did not instruct agents to actively `SendMessage` results back to the orchestrator. Agents interpreted their task as done once they had the data, without knowing to push it.

**Suggested fix:** Add to the subagent contract at Stage 2 (and Stage 2 of `end`):

```
- When your research is complete, send ALL results back to the orchestrator
  via SendMessage({to: "main", summary: "<agent-name> results", message: "<your full markdown results>"}). 
  Do NOT just go idle — actively push your output. The orchestrator does not poll; 
  it only receives what you send.
```

This eliminates the extra round-trip for every agent that currently requires a retrieval `SendMessage`.
